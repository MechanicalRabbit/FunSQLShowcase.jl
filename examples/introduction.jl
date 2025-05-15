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
	using FunSQL
	using DuckDB
    using PlutoFunSQL
end

# ╔═╡ b8e5e6ff-3641-4295-80f5-f283195866f0
md"""
### Introduction

This is a simple FunSQL example using the eICU-CRD sample database.
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient records in the eICU-CRD database."""

# ╔═╡ fff8f53f-f08e-44c6-94a9-17e8d213c497
md"""Create an in-memory database. Attach the eICU-CRD demo database."""

# ╔═╡ fa2bac9e-31ac-11f0-0569-d7837ec459af
begin
	global conn = DuckDB.DB()
	eicu_dbfile = joinpath(artifact"eicu-crd-demo", "eicu-crd-demo-2.0.1.duckdb")
	DuckDB.execute(conn, "ATTACH '$(eicu_dbfile)' AS eicu (READ_ONLY);")
	nothing
end

# ╔═╡ 2dae23ee-b4b4-4e62-bc44-8296f1d7c0f6
DuckDB.execute(conn, "SELECT count(), count(distinct uniquepid) FROM eicu.patient")

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═2dae23ee-b4b4-4e62-bc44-8296f1d7c0f6
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╠═fa2bac9e-31ac-11f0-0569-d7837ec459af
# ╠═ea49a14e-80c3-4d84-9749-6e192e7bb092
