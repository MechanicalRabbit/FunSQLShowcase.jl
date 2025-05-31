### A Pluto.jl notebook ###
# v0.20.9

using Markdown
using InteractiveUtils

# ╔═╡ ea49a14e-80c3-4d84-9749-6e192e7bb092
begin
    using Pkg, Pkg.Artifacts
    Pkg.activate(Base.current_project())
    Pkg.instantiate() # download Artifacts.toml
    using Revise
    using DataFrames
	using Observables
	using Pluto
	using PlutoUI
	using ProgressLogging
	using HypertextLiteral
    using FunSQL
    using DuckDB
    using DBInterface
    using PlutoFunSQL
end

# ╔═╡ b8e5e6ff-3641-4295-80f5-f283195866f0
md"""
## eICU Database Overview
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient admission records in the eICU database."""

# ╔═╡ fff8f53f-f08e-44c6-94a9-17e8d213c497
md"""
## Appendix
These represent technical details needed to setup the notebook.
"""

# ╔═╡ 605f262b-8e25-4b72-8d24-b3e2c2b1fdb9
md"""
### Query Combinators
"""

# ╔═╡ 7d693006-5560-4245-941b-06ee72cdf531
@funsql begin
    count_records() = group().select(count())
end

# ╔═╡ 9e9b6698-a772-4479-b11c-36046cf3fc21
md"""
### Notebook Setup

- use dependencies needed for querying
- create an in-memory database
- attach the eICU-CRD and MIMIC IV demo database
- define @eicu macro to use that database
"""

# ╔═╡ fa2bac9e-31ac-11f0-0569-d7837ec459af
begin
    db_conn = DBInterface.connect(DuckDB.DB)

    eicu_dbfile = joinpath(artifact"eicu-crd-demo", "eicu-crd-demo-2.0.1.duckdb")
    DBInterface.execute(db_conn, "ATTACH '$(eicu_dbfile)' AS eicu (READ_ONLY);")
    eicu_catalog = FunSQL.reflect(db_conn; catalog = "eicu")
    eicu_db = FunSQL.SQLConnection(db_conn; catalog = eicu_catalog)
    macro eicu(q)
        return PlutoFunSQL.query_macro(__module__, __source__, eicu_db, q)
    end

    nothing
end

# ╔═╡ c88a31f9-9065-4457-b9c9-19f10f7a2172
@eicu begin
    from(patient)
	snoop_fields()
    count_records()
end

# ╔═╡ 74dd3c6e-6632-4f94-8980-d9065912bc3b
begin
	let parts = []
	@progress for t in sort(collect(keys(eicu_catalog)))
		push!(parts, @htl("""
          <dt>$t</dt>
		  <dd>$(@eicu begin
		    from($t)
		    summary(exact=true)
		  end)</dd>
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
	define(geomean_hospid => geomean(hospitalid)) # DuckDB aggregate marcro
end

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═c88a31f9-9065-4457-b9c9-19f10f7a2172
# ╠═74dd3c6e-6632-4f94-8980-d9065912bc3b
# ╠═f597883d-51b8-4524-96a8-51351082e063
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╟─605f262b-8e25-4b72-8d24-b3e2c2b1fdb9
# ╠═7d693006-5560-4245-941b-06ee72cdf531
# ╟─9e9b6698-a772-4479-b11c-36046cf3fc21
# ╠═fa2bac9e-31ac-11f0-0569-d7837ec459af
# ╠═ea49a14e-80c3-4d84-9749-6e192e7bb092
