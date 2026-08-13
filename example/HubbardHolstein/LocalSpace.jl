"""
    local_space(nmax::Integer) -> NamedTuple

Construct the separate electron and truncated-phonon local spaces used by the
repo-private alternating-site Hubbard-Holstein example. The phonon
multiplicity basis is ordered as `|0⟩, ..., |nmax⟩`.

`nmax` may use any non-Boolean integer representation. It must be non-negative,
and its successor must be representable in the same integer type.
"""
function local_space(nmax::Integer)
    nmax isa Bool && throw(ArgumentError("nmax must be a non-Boolean integer cutoff"))
    nmax < zero(nmax) && throw(DomainError(nmax, "nmax must be non-negative"))

    db = Base.Checked.checked_add(nmax, oneunit(nmax))
    electron_space = U1SU2Fermion.pspace
    boson_space = Rep[U₁×SU₂]((0, 0) => db)

    b = TensorMap(zeros, Float64, boson_space, boson_space)
    b_block = block(b, Irrep[U₁×SU₂](0, 0))
    for occupation in oneunit(nmax):nmax
        b_block[occupation, occupation + oneunit(occupation)] = sqrt(occupation)
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
