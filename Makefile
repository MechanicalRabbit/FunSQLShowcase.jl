help: #: show this help
	@echo "Available targets:"
	@sed -n -e 's/^\([^:@]*\):.*#: \(.*\)/  make \1  |\2/p' Makefile | column -t -s '|'
.PHONY: help

shell: #: start Julia REPL with FunSQLShowcase loaded
	julia --project -e "using Revise; using FunSQL, FunSQLShowcase;" -i
.PHONY: shell

pluto: #: start a Pluto notebook server
	julia --project -e 'using Pluto; Pluto.run(dismiss_motivational_quotes = true, enable_ai_editor_features = false)'
.PHONY: pluto

build: #: export Pluto notebooks to HTML
	julia --project build.jl
.PHONY: build

serve: #: start HTTP server for exported HTML
	python -m http.server -d build
.PHONY: serve

pkg_instantiate: #: instantiate the project
	julia --project -e 'using Pkg; Pkg.instantiate()'
.PHONY: pkg_instantiate

pkg_update: #: update Julia project dependencies
	julia --project -e 'using Pkg; Pkg.update()'
.PHONY: pkg_update
