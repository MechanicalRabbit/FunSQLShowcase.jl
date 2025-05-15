help: #: show this help
	@echo "Available targets:"
	@sed -n -e 's/^\([^:@]*\):.*#: \(.*\)/  make \1  |\2/p' Makefile | column -t -s '|'
.PHONY: help

shell: #: start Julia directly without Pluto
	julia --project -e "using FunSQL, Revise; using PlutoFunSQL;" -i
.PHONY: shell

pluto: #: start a Pluto notebook process
	julia --project -e 'using Pluto; Pluto.run(;dismiss_motivational_quotes=true, enable_ai_editor_features=false)'
.PHONY: pluto

pkg_update: #: update all Julia packages
	julia --project -e 'using Pkg; Pkg.instantiate(); Pkg.resolve(); Pkg.update();'
.PHONY: pkg_update

