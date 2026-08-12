"""
    local_space(nmax::Int) -> NamedTuple

Construct the separate electron and truncated-phonon local spaces used by the
repo-private alternating-site Hubbard-Holstein example. The phonon
multiplicity basis is ordered as `|0⟩, ..., |nmax⟩`.
"""
function local_space(nmax::Int)
    nmax < 0 && throw(DomainError(nmax, "nmax must be non-negative"))

    db = nmax + 1
    electron_space = U1SU2Fermion.pspace
    boson_space = Rep[U₁×SU₂]((0, 0) => db)

    b = TensorMap(zeros, Float64, boson_space, boson_space)
    b_block = block(b, Irrep[U₁×SU₂](0, 0))
    for occupation in 1:nmax
        b_block[occupation, occupation + 1] = sqrt(occupation)
    end
    bdag = adjoint(b)
    nb = bdag * b
    x = b + bdag

    return (;
        nmax,
        db,
        electron_space,
        boson_space,
        Z = U1SU2Fermion.Z,
        n = U1SU2Fermion.n,
        nd = U1SU2Fermion.nd,
        FdagF = U1SU2Fermion.FdagF,
        FFdag = U1SU2Fermion.FFdag,
        b,
        bdag,
        nb,
        x,
    )
end
