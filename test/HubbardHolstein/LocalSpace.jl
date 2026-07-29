const HH_LOCAL_ATOL = 1e-12

function _bare_boson_operator(site_space)
    b = TensorMap(zeros, Float64, site_space.boson_space, site_space.boson_space)
    b_block = block(b, Irrep[U₁×SU₂](0, 0))
    for occupation in 1:site_space.nmax
        b_block[occupation, occupation + 1] = sqrt(occupation)
    end
    return b
end

function _boson_top_projector(site_space)
    projector = TensorMap(zeros, Float64, site_space.boson_space, site_space.boson_space)
    block(projector, Irrep[U₁×SU₂](0, 0))[end, end] = 1
    return projector
end

function _test_hopping_lift(site_space, lifted, electronic, left_charge_change)
    boson_identity = isometry(site_space.boson_space, site_space.boson_space)
    left_auxiliary = domain(electronic[1])[2]
    left_auxiliary_identity = isometry(left_auxiliary, left_auxiliary)
    expected_left = permute(electronic[1] ⊗ boson_identity, ((1, 2), (3, 5, 4)))
    unfused_left =
        adjoint(site_space.fusion) * lifted[1] *
        (site_space.fusion ⊗ left_auxiliary_identity)

    right_auxiliary = codomain(electronic[2])[1]
    right_auxiliary_identity = isometry(right_auxiliary, right_auxiliary)
    expected_right = electronic[2] ⊗ boson_identity
    unfused_right =
        (right_auxiliary_identity ⊗ adjoint(site_space.fusion)) *
        lifted[2] *
        site_space.fusion

    @test numout(lifted[1]) == 1
    @test numin(lifted[1]) == 2
    @test codomain(lifted[1])[1] == site_space.pspace
    @test domain(lifted[1])[1] == site_space.pspace
    @test domain(lifted[1])[2] == left_auxiliary
    @test norm(unfused_left - expected_left) ≤ HH_LOCAL_ATOL
    @test norm(
        site_space.n * lifted[1] -
        lifted[1] * (site_space.n ⊗ left_auxiliary_identity) -
        left_charge_change * lifted[1],
    ) ≤ HH_LOCAL_ATOL
    @test norm(
        site_space.Z * lifted[1] +
        lifted[1] * (site_space.Z ⊗ left_auxiliary_identity),
    ) ≤ HH_LOCAL_ATOL

    @test numout(lifted[2]) == 2
    @test numin(lifted[2]) == 1
    @test codomain(lifted[2])[1] == right_auxiliary
    @test codomain(lifted[2])[2] == site_space.pspace
    @test domain(lifted[2])[1] == site_space.pspace
    @test norm(unfused_right - expected_right) ≤ HH_LOCAL_ATOL
    @test norm(
        (right_auxiliary_identity ⊗ site_space.n) * lifted[2] -
        lifted[2] * site_space.n +
        left_charge_change * lifted[2],
    ) ≤ HH_LOCAL_ATOL
    @test norm(
        (right_auxiliary_identity ⊗ site_space.Z) * lifted[2] +
        lifted[2] * site_space.Z,
    ) ≤ HH_LOCAL_ATOL
end

@testset "composite local space" begin
    @test_throws DomainError HubbardHolstein.local_space(-1)

    @testset "nmax = $nmax" for nmax in (0, 1, 3)
        site_space = HubbardHolstein.local_space(nmax)
        electron_identity = isometry(site_space.electron_space, site_space.electron_space)
        boson_identity = isometry(site_space.boson_space, site_space.boson_space)
        cell_identity = isometry(site_space.pspace, site_space.pspace)
        product_identity = isometry(
            site_space.electron_space ⊗ site_space.boson_space,
            site_space.electron_space ⊗ site_space.boson_space,
        )

        @test site_space.db == nmax + 1
        @test site_space.boson_space == Rep[U₁×SU₂]((0, 0) => site_space.db)
        @test site_space.pspace == fuse(site_space.electron_space, site_space.boson_space)
        @test dim(site_space.pspace) == 4 * site_space.db
        @test norm(site_space.fusion * adjoint(site_space.fusion) - cell_identity) ≤
              HH_LOCAL_ATOL
        @test norm(adjoint(site_space.fusion) * site_space.fusion - product_identity) ≤
              HH_LOCAL_ATOL

        for (lifted, electronic) in (
            (site_space.Z, U1SU2Fermion.Z),
            (site_space.n, U1SU2Fermion.n),
            (site_space.nd, U1SU2Fermion.nd),
        )
            @test norm(
                adjoint(site_space.fusion) * lifted * site_space.fusion -
                electronic ⊗ boson_identity,
            ) ≤ HH_LOCAL_ATOL
        end

        bare_b = _bare_boson_operator(site_space)
        @test norm(
            adjoint(site_space.fusion) * site_space.b * site_space.fusion -
            electron_identity ⊗ bare_b,
        ) ≤ HH_LOCAL_ATOL
        @test norm(
            adjoint(site_space.fusion) * site_space.nb * site_space.fusion -
            electron_identity ⊗ (adjoint(bare_b) * bare_b),
        ) ≤ HH_LOCAL_ATOL
        @test norm(
            adjoint(site_space.fusion) * site_space.x * site_space.fusion -
            electron_identity ⊗ (bare_b + adjoint(bare_b)),
        ) ≤ HH_LOCAL_ATOL
        @test norm(
            adjoint(site_space.fusion) * site_space.nx * site_space.fusion -
            U1SU2Fermion.n ⊗ (bare_b + adjoint(bare_b)),
        ) ≤ HH_LOCAL_ATOL
        @test norm(site_space.bdag - adjoint(site_space.b)) ≤ HH_LOCAL_ATOL
        @test norm(site_space.nb - site_space.bdag * site_space.b) ≤ HH_LOCAL_ATOL
        @test norm(site_space.x - adjoint(site_space.x)) ≤ HH_LOCAL_ATOL
        @test norm(site_space.nx - site_space.n * site_space.x) ≤ HH_LOCAL_ATOL

        top = site_space.fusion *
              (electron_identity ⊗ _boson_top_projector(site_space)) *
              adjoint(site_space.fusion)
        commutator = site_space.b * site_space.bdag - site_space.bdag * site_space.b
        cutoff_commutator = cell_identity - site_space.db * top
        @test norm(commutator - cutoff_commutator) ≤ HH_LOCAL_ATOL
        @test norm(
            site_space.nb * site_space.b - site_space.b * site_space.nb + site_space.b,
        ) ≤ HH_LOCAL_ATOL
        @test norm(
            site_space.nb * site_space.bdag - site_space.bdag * site_space.nb -
            site_space.bdag,
        ) ≤ HH_LOCAL_ATOL

        for electronic in (site_space.Z, site_space.n, site_space.nd)
            for phononic in (site_space.b, site_space.bdag, site_space.nb, site_space.x)
                @test norm(electronic * phononic - phononic * electronic) ≤ HH_LOCAL_ATOL
            end
        end
        @test norm(site_space.Z * site_space.Z - cell_identity) ≤ HH_LOCAL_ATOL

        _test_hopping_lift(site_space, site_space.FdagF, U1SU2Fermion.FdagF, 1)
        _test_hopping_lift(site_space, site_space.FFdag, U1SU2Fermion.FFdag, -1)

        if iszero(nmax)
            @test site_space.pspace == site_space.electron_space
            @test norm(site_space.b) ≤ HH_LOCAL_ATOL
            @test norm(site_space.bdag) ≤ HH_LOCAL_ATOL
            @test norm(site_space.nb) ≤ HH_LOCAL_ATOL
            @test norm(site_space.x) ≤ HH_LOCAL_ATOL
            @test norm(site_space.nx) ≤ HH_LOCAL_ATOL
        end
    end
end
