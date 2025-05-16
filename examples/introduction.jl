### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ ea49a14e-80c3-4d84-9749-6e192e7bb092
begin
    using Pkg, Pkg.Artifacts
    Pkg.activate(Base.current_project())
    Pkg.instantiate() # download Artifacts.toml
    using Revise
    using DataFrames
    using FunSQL
    using DuckDB
    using DBInterface
    using PlutoFunSQL
end

# ╔═╡ b8e5e6ff-3641-4295-80f5-f283195866f0
md"""
## eICU-CRD Database Overview
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient records in the eICU-CRD database."""

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
- attach the eICU-CRD demo database
- define @eicu macro to use that database
"""

# ╔═╡ fa2bac9e-31ac-11f0-0569-d7837ec459af
begin
    conn = DBInterface.connect(DuckDB.DB)
    eicu_dbfile = joinpath(artifact"eicu-crd-demo", "eicu-crd-demo-2.0.1.duckdb")
    DBInterface.execute(conn, "ATTACH '$(eicu_dbfile)' AS eicu (READ_ONLY);")
    catalog = FunSQL.reflect(conn; catalog = "eicu")
    db = FunSQL.SQLConnection(conn; catalog)
    macro eicu(q)
        return PlutoFunSQL.query_macro(__module__, __source__, db, q)
    end
end

# ╔═╡ c88a31f9-9065-4457-b9c9-19f10f7a2172
@eicu begin
    from(patient)
    count_records()
end

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═c88a31f9-9065-4457-b9c9-19f10f7a2172
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╟─605f262b-8e25-4b72-8d24-b3e2c2b1fdb9
# ╠═7d693006-5560-4245-941b-06ee72cdf531
# ╟─9e9b6698-a772-4479-b11c-36046cf3fc21
# ╠═fa2bac9e-31ac-11f0-0569-d7837ec459af
# ╠═ea49a14e-80c3-4d84-9749-6e192e7bb092
