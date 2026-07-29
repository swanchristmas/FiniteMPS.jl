"""
    local_space(nmax::Integer) -> NamedTuple

Construct the repo-private `U₁ charge × SU₂ spin` electron-phonon local space.
The boson multiplicity basis is ordered as `|0⟩, ..., |nmax⟩`, and `fusion`
maps `electron_space ⊗ boson_space` into the returned `pspace`.
"""
function local_space(nmax::Integer)
    nmax < 0 && throw(DomainError(nmax, "nmax must be non-negative"))

    cutoff = Int(nmax)
    db = cutoff + 1
    electron_space = U1SU2Fermion.pspace
    boson_space = Rep[U₁×SU₂]((0, 0) => db)
    pspace = fuse(electron_space, boson_space)
    fusion = isometry(pspace, electron_space ⊗ boson_space)

    electron_identity = isometry(electron_space, electron_space)
    boson_identity = isometry(boson_space, boson_space)
    b_boson = TensorMap(zeros, Float64, boson_space, boson_space)
    b_block = block(b_boson, Irrep[U₁×SU₂](0, 0))
    for occupation in 1:cutoff
        b_block[occupation, occupation + 1] = sqrt(occupation)
    end
    bdag_boson = adjoint(b_boson)
    nb_boson = bdag_boson * b_boson
    x_boson = b_boson + bdag_boson

    lift_electron(operator) = fusion * (operator ⊗ boson_identity) * adjoint(fusion)
    lift_boson(operator) = fusion * (electron_identity ⊗ operator) * adjoint(fusion)

    Z = lift_electron(U1SU2Fermion.Z)
    n = lift_electron(U1SU2Fermion.n)
    nd = lift_electron(U1SU2Fermion.nd)
    b = lift_boson(b_boson)
    bdag = lift_boson(bdag_boson)
    nb = lift_boson(nb_boson)
    x = lift_boson(x_boson)
    nx = fusion * (U1SU2Fermion.n ⊗ x_boson) * adjoint(fusion)

    FdagF = _lift_hopping_channels(U1SU2Fermion.FdagF, fusion, boson_identity)
    FFdag = _lift_hopping_channels(U1SU2Fermion.FFdag, fusion, boson_identity)

    return (;
        nmax = cutoff,
        db,
        electron_space,
        boson_space,
        pspace,
        fusion,
        Z,
        n,
        nd,
        b,
        bdag,
        nb,
        x,
        nx,
        FdagF,
        FFdag,
    )
end

function _lift_hopping_channels(channels, fusion, boson_identity)
    left, right = channels

    left_auxiliary = domain(left)[2]
    left_auxiliary_identity = isometry(left_auxiliary, left_auxiliary)
    expanded_left = permute(left ⊗ boson_identity, ((1, 2), (3, 5, 4)))
    lifted_left = fusion * expanded_left * (adjoint(fusion) ⊗ left_auxiliary_identity)

    right_auxiliary = codomain(right)[1]
    right_auxiliary_identity = isometry(right_auxiliary, right_auxiliary)
    lifted_right =
        (right_auxiliary_identity ⊗ fusion) * (right ⊗ boson_identity) * adjoint(fusion)

    return lifted_left, lifted_right
end
