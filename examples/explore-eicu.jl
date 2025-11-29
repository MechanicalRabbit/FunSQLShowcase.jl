### A Pluto.jl notebook ###
# v0.20.21

#> [frontmatter]
#> order = "3"
#> title = "eICU Overview"

using Markdown
using InteractiveUtils

# ╔═╡ 97cd4db7-8e95-46b6-8d5e-73f93d422ee9
begin
	import Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
end

# ╔═╡ 422116fe-4e99-44ce-9c5b-7fd28b406909
using Revise

# ╔═╡ a8833e04-7eee-4df4-86f8-6a7a5c53a17b
using HypertextLiteral, ProgressLogging

# ╔═╡ af75d0c6-7193-4c0a-aad9-880afc521f62
begin
	using FunSQL
	using FunSQLShowcase.DuckDBQueries
	using FunSQLShowcase.DynamicQueries
	using FunSQLShowcase.SummarizeQueries
	using FunSQLShowcase.ValidateQueries
	using FunSQLShowcase.TallyQueries
	using FunSQLShowcase.eICU
	using FunSQLShowcase.PlutoLayout
end

# ╔═╡ b8e5e6ff-3641-4295-80f5-f283195866f0
md"""
## eICU Overview
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient admission records in the eICU database."""

# ╔═╡ fff8f53f-f08e-44c6-94a9-17e8d213c497
md"""
## Appendix
These represent technical details needed to setup the notebook.
"""

# ╔═╡ 9e9b6698-a772-4479-b11c-36046cf3fc21
md"""
### Notebook Setup

- use dependencies needed for querying
- create an in-memory database
- attach the eICU-CRD and MIMIC IV demo database
- define @eicu macro to use that database
"""

# ╔═╡ e2857b19-c6e7-429e-a11b-23817b07d68f
eicu_db = connect_eicu_crd_demo()

# ╔═╡ 3096a920-7658-41a1-8e13-7504aa773f44
macro eicu(ex, args...)
	esc(:(@funsql($eicu_db, $ex, $(args...))))
end

# ╔═╡ c88a31f9-9065-4457-b9c9-19f10f7a2172
@eicu begin
	from(patient)
	snoop_fields()
	tally()
end

# ╔═╡ d9d744a0-1229-4052-aae0-bdbe7e99c4cd
@eicu summarize_database()

# ╔═╡ 74dd3c6e-6632-4f94-8980-d9065912bc3b
begin
	let parts = []
	@progress for t in sort(collect(keys(eicu_db.wrapped.catalog)))
		push!(parts, @htl("""
          <dt>$t</dt>
		  <dd>$(@eicu from($t).summarize(exact=true))</dd>
    	"""))
	end		
	@htl("<dl>$parts</dl>")
	end
end

# ╔═╡ f597883d-51b8-4524-96a8-51351082e063
@eicu begin
	from(patient)
	group()
	define(max_hospid => max(hospitalid)) # FunSQL
	define(any_age => any_value(age)) # DuckDB aggregate as marked
	define(geomean_hospid => geomean(hospitalid)) # DuckDB aggregate macro
end

# ╔═╡ d26a457f-3fd3-476c-9364-7c46128adb02
PlutoFluid()

# ╔═╡ 1abfdeb1-d9d1-42d6-bafb-4f0fa12afbe0
PlutoSidebar(index = true)

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═c88a31f9-9065-4457-b9c9-19f10f7a2172
# ╠═d9d744a0-1229-4052-aae0-bdbe7e99c4cd
# ╠═74dd3c6e-6632-4f94-8980-d9065912bc3b
# ╠═f597883d-51b8-4524-96a8-51351082e063
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╟─9e9b6698-a772-4479-b11c-36046cf3fc21
# ╠═e2857b19-c6e7-429e-a11b-23817b07d68f
# ╠═3096a920-7658-41a1-8e13-7504aa773f44
# ╠═97cd4db7-8e95-46b6-8d5e-73f93d422ee9
# ╠═422116fe-4e99-44ce-9c5b-7fd28b406909
# ╠═a8833e04-7eee-4df4-86f8-6a7a5c53a17b
# ╠═af75d0c6-7193-4c0a-aad9-880afc521f62
# ╠═d26a457f-3fd3-476c-9364-7c46128adb02
# ╠═1abfdeb1-d9d1-42d6-bafb-4f0fa12afbe0
