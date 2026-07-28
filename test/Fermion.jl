using LinearAlgebra: norm
using Random

@testset "U₁×SU₂ fermion projected hopping" begin
	fermion = U₁SU₂Fermion
	@test U1SU2Fermion === fermion

	(; pspace, n, nd, ne, FdagF, FdagProjF, Z) = fermion
	@test ne ≈ one(ne) - n + nd
	@test adjoint(ne) ≈ ne
	@test ne * ne ≈ ne
	@test iszero(norm(ne * nd))

	Fdag10, F01, Fdag21, F12 = FdagProjF
	@test Fdag10 + Fdag21 ≈ FdagF[1]
	@test F01 + F12 ≈ FdagF[2]
	@test F01 ≈ permute(adjoint(Fdag10), ((2, 1), (3,)))
	@test F12 ≈ permute(adjoint(Fdag21), ((2, 1), (3,)))

	Π₀, Π₂ = ne, nd
	Π₁ = one(ne) - Π₀ - Π₂
	@tensor E10[a; b c] := Π₁[a d] * FdagF[1][d e c] * Π₀[e b]
	@tensor E01[a b; c] := Π₀[b d] * FdagF[2][a d e] * Π₁[e c]
	@tensor E21[a; b c] := Π₂[a d] * FdagF[1][d e c] * Π₁[e b]
	@tensor E12[a b; c] := Π₁[b d] * FdagF[2][a d e] * Π₂[e c]
	@test Fdag10 ≈ E10
	@test F01 ≈ E01
	@test Fdag21 ≈ E21
	@test F12 ≈ E12

	channels = ((Fdag10, F01), (Fdag21, F12), (Fdag21, F01), (Fdag10, F12))
	obs_tree = ObservableTree(2)
	for (i, ops) in enumerate(channels)
		names = (Symbol("Fdag$(i)"), Symbol("F$(i)"))
		intr_name = Symbol("hop$(i)")
		addObs!(obs_tree, ops, (1, 2), (true, true); Z, name = names, IntrName = intr_name)
	end
	@test length(obs_tree.Refs) == length(channels)

	Random.seed!(31)
	aspace = [Rep[U₁×SU₂]((0, 0) => 1), Rep[U₁×SU₂]((q, s) => 1 for q in -1:1 for s in 0:1//2:1)]
	ψ = randMPS(ComplexF64, pspace, aspace)
	for sites in ((1, 2), (2, 1))
		split_tree = InteractionTree(2)
		for (i, ops) in enumerate(channels)
			names = (Symbol("Fdag$(i)"), Symbol("F$(i)"))
			addIntr!(split_tree, ops, sites, (true, true), 1.0; Z, name = names)
		end
		full_tree = InteractionTree(2)
		addIntr!(full_tree, FdagF, sites, (true, true), 1.0; Z, name = (:Fdag, :F))

		split_H = AutomataMPO(split_tree)
		full_H = AutomataMPO(full_tree)
		@test split_H isa SparseMPO{2}
		@test length(split_H) == 2
		split_env = Environment(adjoint(ψ), split_H, ψ)
		full_env = Environment(adjoint(ψ), full_H, ψ)
		@test scalar!(split_env) ≈ scalar!(full_env)
	end
end
