using Documenter, FiniteMPS

pages = ["Home" => "index.md",
	"Tutorial" => ["tutorial/Threading.md",
		"tutorial/Hamiltonian.md",
		"tutorial/Observable.md",
		"tutorial/Heisenberg.md",
		"tutorial/Hubbard.md"],
	"Local Space" => ["localspace/Spin.md",
		"localspace/Fermion.md",
	],
	"Library" => ["lib/TensorWrappers.md",
		"lib/MPS.md",
		"lib/Environment.md",
		"lib/ProjHam.md",
		"lib/IntrTree.md",
		"lib/ObsTree.md",
		"lib/ITP.md",
		"lib/Algebra.md",
		"lib/Algorithm.md",
		"lib/Deprecate.md",
	],
	"Index" => ["index/index.md"],
]


makedocs(;
	modules = [FiniteMPS],
	sitename = "FiniteMPS.jl",
	authors = "Qiaoyi Li",
	warnonly = [:missing_docs, :cross_references],
	pages = pages,
	pagesonly = true,
)


github_repository = get(ENV, "GITHUB_REPOSITORY", "")
github_ref = get(ENV, "GITHUB_REF", "")
run_heavy_docs = get(ENV, "FINITEMPS_RUN_HEAVY_DOCS", "false") == "true"

if !run_heavy_docs && github_repository == "Qiaoyi-Li/FiniteMPS.jl" && !isempty(github_ref)
	@show github_ref
	devbranch, devurl = github_ref == "refs/heads/dev" ? ("dev", "dev") : ("main", "stable")
	deploydocs(
		repo = "github.com/Qiaoyi-Li/FiniteMPS.jl",
		devbranch = devbranch,
		devurl = devurl,
		push_preview = true,
	)
end
