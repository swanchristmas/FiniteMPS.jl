const HH_LOCAL_ATOL = 1e-12

function _boson_top_projector(site_space)
    projector = TensorMap(zeros, Float64, site_space.boson_space, site_space.boson_space)
    block(projector, Irrep[U₁×SU₂](0, 0))[end, end] = 1
    return projector
end

@testset "alternating local spaces" begin
    @test_throws ArgumentError("nmax must be a non-Boolean integer cutoff") HubbardHolstein.local_space(
        true,
    )
    @test_throws DomainError HubbardHolstein.local_space(-1)
    @test_throws MethodError HubbardHolstein.local_space(1.0)
    @testset "cutoff representation $(typeof(nmax))" for nmax in (
        Int32(1),
        Int64(1),
        UInt32(1),
        UInt64(1),
        big(1),
    )
        site_space = HubbardHolstein.local_space(nmax)
        @test site_space.nmax == nmax
        @test typeof(site_space.nmax) === typeof(nmax)
        @test site_space.db == nmax + 1
        @test dim(site_space.boson_space) == 2
    end

    @testset "nmax = $nmax" for nmax in (0, 1, 3)
        site_space = HubbardHolstein.local_space(nmax)
        boson_identity = isometry(site_space.boson_space, site_space.boson_space)

        @test site_space.nmax == nmax
        @test site_space.db == nmax + 1
        @test site_space.electron_space == U1SU2Fermion.pspace
        @test dim(site_space.electron_space) == 4
        @test site_space.boson_space == Rep[U₁×SU₂]((0, 0) => site_space.db)
        @test dim(site_space.boson_space) == site_space.db

        @test site_space.Z === U1SU2Fermion.Z
        @test site_space.n === U1SU2Fermion.n
        @test site_space.nd === U1SU2Fermion.nd
        @test site_space.FdagF === U1SU2Fermion.FdagF
        @test site_space.FFdag === U1SU2Fermion.FFdag
        @test !hasproperty(site_space, :pspace)
        @test !hasproperty(site_space, :fusion)
        @test !hasproperty(site_space, :nx)

        @test domain(site_space.b)[1] == site_space.boson_space
        @test codomain(site_space.b)[1] == site_space.boson_space
        @test norm(site_space.bdag - adjoint(site_space.b)) ≤ HH_LOCAL_ATOL
        @test norm(site_space.nb - site_space.bdag * site_space.b) ≤ HH_LOCAL_ATOL
        @test norm(site_space.x - adjoint(site_space.x)) ≤ HH_LOCAL_ATOL

        top = _boson_top_projector(site_space)
        commutator = site_space.b * site_space.bdag - site_space.bdag * site_space.b
        cutoff_commutator = boson_identity - site_space.db * top
        @test norm(commutator - cutoff_commutator) ≤ HH_LOCAL_ATOL
        @test norm(
            site_space.nb * site_space.b - site_space.b * site_space.nb + site_space.b,
        ) ≤ HH_LOCAL_ATOL
        @test norm(
            site_space.nb * site_space.bdag - site_space.bdag * site_space.nb -
            site_space.bdag,
        ) ≤ HH_LOCAL_ATOL

        if iszero(nmax)
            pspaces = [
                site_space.electron_space,
                site_space.boson_space,
                site_space.electron_space,
                site_space.boson_space,
            ]
            @test length(pspaces) == 4
            @test dim(pspaces[2]) == dim(pspaces[4]) == 1
            @test norm(site_space.b) ≤ HH_LOCAL_ATOL
            @test norm(site_space.bdag) ≤ HH_LOCAL_ATOL
            @test norm(site_space.nb) ≤ HH_LOCAL_ATOL
            @test norm(site_space.x) ≤ HH_LOCAL_ATOL
        end
    end
end

@testset "alternating Automata compatibility" begin
    site_space = HubbardHolstein.local_space(2)
    pspaces = [
        site_space.electron_space,
        site_space.boson_space,
        site_space.electron_space,
        site_space.boson_space,
    ]
    Zsites = [site_space.Z, nothing, site_space.Z, nothing]

    Tree = InteractionTree(4)
    addIntr!(
        Tree,
        site_space.FdagF,
        (1, 3),
        (true, true),
        -1.0;
        Z = Zsites,
        pspace = pspaces,
        name = (:Fdag, :F),
    )

    @test any(O -> O isa IdentityOperator && getPhysSpace(O) == pspaces[2], Tree.Ops[2])
    @test any(O -> getOpName(O) == "ZF" && getPhysSpace(O) == pspaces[3], Tree.Ops[3])

    addIntr!(
        Tree,
        (site_space.n, site_space.x),
        (1, 2),
        (false, false),
        1.0;
        pspace = pspaces,
        name = (:n, :x),
    )

    @test haskey(Tree.Refs, "nx")
    @test haskey(Tree.Refs["nx"], (1, 2))
    @test all(eachindex(Tree.Ops)) do si
        all(O -> getPhysSpace(O) == pspaces[si], Tree.Ops[si])
    end

    H = AutomataMPO(Tree; compress = 0)
    @test length(H) == 4
    @test all(eachindex(H)) do si
        all(O -> isnothing(O) || getPhysSpace(O) == pspaces[si], H[si])
    end
end
