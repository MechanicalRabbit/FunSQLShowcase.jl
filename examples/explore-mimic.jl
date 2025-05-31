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
## MIMIC-IV Database Overview
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient records in the MIMIC-IV database."""

# ╔═╡ 3f730b0d-9b20-4829-af49-6e79be08e83e
md"""## MIMIC Reference"""

# ╔═╡ 6a793e26-8b04-5bcb-a3ee-1cfd2200e76e
md"### admissions"

# ╔═╡ 88a7b91d-09b6-5184-952a-78e140a3640b
md"### caregiver"

# ╔═╡ 45aa871b-f1fc-5ded-a51d-9e68f0124a3e
md"### chartevents"

# ╔═╡ 63d0ab43-8d85-56be-b9ba-14ffcbb8f250
md"### d_hcpcs"

# ╔═╡ 2bf0647f-7569-57f1-a7fe-67c66ed7912c
md"### d\_icd\_diagnoses"

# ╔═╡ 4ddcc2a2-0c2e-5926-bb2d-8e5dd65fee04
md"### d\_icd\_procedures"

# ╔═╡ 5855d188-7e88-531e-906b-5040c6700512
md"### d_items"

# ╔═╡ a2d0d683-adde-5b9d-9093-77301b1c6eb1
md"### d_labitems"

# ╔═╡ 369478eb-bf06-5836-a6b5-27537cecabeb
md"### datetimeevents"

# ╔═╡ db6813be-ca00-5a1d-8655-7b46cd0155ec
md"### diagnoses_icd"

# ╔═╡ f0f6fa19-f4ab-5b64-85f3-cae157af2746
md"### drgcodes"

# ╔═╡ cff29412-91b5-5e64-9c91-94840c6f985e
md"### emar"

# ╔═╡ 4106363b-ca62-5a3e-9b32-a3ad1e65e886
md"### emar_detail"

# ╔═╡ a6ccab39-ddd4-58d8-914c-b034a742f391
md"### hcpcsevents"

# ╔═╡ c0f39384-f29c-53b5-b58e-306bbad133f4
md"### icustays"

# ╔═╡ cdcb523f-a328-5745-b8d3-94b39c6ffd16
md"### ingredientevents"

# ╔═╡ 3427ec28-fbfc-5f99-8bf4-b762185883ad
md"### inputevents"

# ╔═╡ b4bfb019-9b96-588b-b04f-a5ff9c74812d
md"### labevents"

# ╔═╡ b7b8e0fd-090a-51a3-a748-38a29f4654f3
md"### microbiologyevents"

# ╔═╡ 075a236c-eab7-52ea-aa83-ce5a85a6c7e9
md"### omr"

# ╔═╡ 07242aa1-0d63-5a3b-873a-ed8df3116453
md"### outputevents"

# ╔═╡ b902e20a-2325-55d8-9c75-5f633dea4b2f
md"### patients"

# ╔═╡ 31667412-b62f-58cb-9375-ed92d0014824
md"### pharmacy"

# ╔═╡ 8fb6a81d-2faf-5eb8-9e07-0f939b68cf58
md"### poe"

# ╔═╡ 9112c1b0-bd45-568a-bd17-32a7b43a197e
md"### poe_detail"

# ╔═╡ cf8cecbb-d083-5c80-9fdb-90e8c39a58b1
md"### prescriptions"

# ╔═╡ 294fcd73-2147-530d-a384-6122575ce46f
md"### procedureevents"

# ╔═╡ 13e5ec7e-c23f-55ae-97df-94af2be9a756
md"### procedures_icd"

# ╔═╡ 5871b498-db7c-587f-9ef1-4db814e982e0
md"### provider"

# ╔═╡ 94dcd7dd-d95b-57fe-8087-8e12d636ec83
md"### services"

# ╔═╡ ea0569be-391d-5b5e-8dbd-5f9005587ba4
md"### transfers"

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

	mimic_dbfile = joinpath(artifact"mimic-iv-demo", "mimic-iv-demo-2.2.duckdb")
	#mimic_dbfile = "/opt/physionet/mimic-iv-3.1.duckdb"
    DuckDB.execute(db_conn, "ATTACH '$(mimic_dbfile)' AS mimic (READ_ONLY);")
	mimic_catalog = FunSQL.reflect(db_conn; catalog = "mimic")
    mimic_db = FunSQL.SQLConnection(db_conn; catalog = mimic_catalog)
    macro mimic(q)
        return PlutoFunSQL.query_macro(__module__, __source__, mimic_db, q)
    end
    nothing
end

# ╔═╡ c88a31f9-9065-4457-b9c9-19f10f7a2172
@mimic begin
    from(patients)
	snoop_fields()
    count_records()
end

# ╔═╡ b4063097-f70b-5178-8d6f-1e69081ce9c8
PlutoFunSQL.explore(mimic_db, :admissions)

# ╔═╡ 5ac65f7f-bed8-51a7-9f98-c9d18e6afe05
PlutoFunSQL.explore(mimic_db, :caregiver)

# ╔═╡ d1e40c08-34e0-5a4b-85a2-58dd1d05cf4a
PlutoFunSQL.explore(mimic_db, :chartevents)

# ╔═╡ a8d1fb96-ff6a-5df8-af66-2f52c86ae2b7
PlutoFunSQL.explore(mimic_db, :d_hcpcs)

# ╔═╡ 24e4580a-717b-5a18-94da-e200099299d9
PlutoFunSQL.explore(mimic_db, :d_icd_diagnoses)

# ╔═╡ 7c9d0f34-5a5c-5cfe-9642-7c1f8723013a
PlutoFunSQL.explore(mimic_db, :d_icd_procedures)

# ╔═╡ b84f17b0-067b-5409-b0c1-9565a8b6cded
PlutoFunSQL.explore(mimic_db, :d_items)

# ╔═╡ b0a6b805-eda8-5f69-aa08-a3ba63e581cf
PlutoFunSQL.explore(mimic_db, :d_labitems)

# ╔═╡ 5115bcac-01e2-53e7-ada2-b4cc4475cca0
PlutoFunSQL.explore(mimic_db, :datetimeevents)

# ╔═╡ a5dde77f-402f-53a8-b3ff-b796b5d58b39
PlutoFunSQL.explore(mimic_db, :diagnoses_icd)

# ╔═╡ 9d83259e-e662-512e-9d97-8f17f7193f36
PlutoFunSQL.explore(mimic_db, :drgcodes)

# ╔═╡ ac69632c-5ca2-591c-9b00-82d580784f8e
PlutoFunSQL.explore(mimic_db, :emar)

# ╔═╡ eab46aeb-b577-5997-ab9e-f5b53ca27ef4
PlutoFunSQL.explore(mimic_db, :emar_detail)

# ╔═╡ 467c543a-7643-5f8f-8186-857965d065ad
PlutoFunSQL.explore(mimic_db, :hcpcsevents)

# ╔═╡ ffbf98c8-256e-570d-8c1f-8c9a750e88c2
PlutoFunSQL.explore(mimic_db, :icustays)

# ╔═╡ ce4463f4-f035-5470-a252-36a055141ddf
PlutoFunSQL.explore(mimic_db, :ingredientevents)

# ╔═╡ ddae11ac-4d81-516d-ae78-58becbe26a7f
PlutoFunSQL.explore(mimic_db, :inputevents)

# ╔═╡ 348201c0-19ee-5d16-a4fc-0b247c11a0e4
PlutoFunSQL.explore(mimic_db, :labevents)

# ╔═╡ bb4c7afd-d6bc-50a4-aaeb-0eb30d7be0c3
PlutoFunSQL.explore(mimic_db, :microbiologyevents)

# ╔═╡ 3d5fc847-e255-5649-b50c-a252cca3cb75
PlutoFunSQL.explore(mimic_db, :omr)

# ╔═╡ e31c9ff3-db7b-53bf-94db-a3d9f0e37689
PlutoFunSQL.explore(mimic_db, :outputevents)

# ╔═╡ acd51a10-1177-50a4-9455-0195988e6fbe
PlutoFunSQL.explore(mimic_db, :patients)

# ╔═╡ 8ae6071d-f455-5b65-b87e-6c76d4ee24a9
PlutoFunSQL.explore(mimic_db, :pharmacy)

# ╔═╡ 37a435b6-dd78-5789-89c8-22e1471c6e43
PlutoFunSQL.explore(mimic_db, :poe)

# ╔═╡ e26611a1-e580-52cd-8822-f45ef5ae90e9
PlutoFunSQL.explore(mimic_db, :poe_detail)

# ╔═╡ 0e9bc6d8-5ff9-5319-a7f8-1db7a4fb5716
PlutoFunSQL.explore(mimic_db, :prescriptions)

# ╔═╡ 9bf8df73-15fa-5bbc-af70-fcfb65b9fd06
PlutoFunSQL.explore(mimic_db, :procedureevents)

# ╔═╡ 8630dbb4-3742-5baa-9b3d-28b55e19ce9b
PlutoFunSQL.explore(mimic_db, :procedures_icd)

# ╔═╡ d9c20d7c-2bf1-5630-bee7-5ff9659d9e91
PlutoFunSQL.explore(mimic_db, :provider)

# ╔═╡ fe2c071e-94e1-598c-a911-b555dfb22dfa
PlutoFunSQL.explore(mimic_db, :services)

# ╔═╡ 613b7dbc-58bd-5bd0-9606-597865ab1d84
PlutoFunSQL.explore(mimic_db, :transfers)

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═c88a31f9-9065-4457-b9c9-19f10f7a2172
# ╟─3f730b0d-9b20-4829-af49-6e79be08e83e
# ╟─6a793e26-8b04-5bcb-a3ee-1cfd2200e76e
# ╠═b4063097-f70b-5178-8d6f-1e69081ce9c8
# ╟─88a7b91d-09b6-5184-952a-78e140a3640b
# ╠═5ac65f7f-bed8-51a7-9f98-c9d18e6afe05
# ╟─45aa871b-f1fc-5ded-a51d-9e68f0124a3e
# ╠═d1e40c08-34e0-5a4b-85a2-58dd1d05cf4a
# ╟─63d0ab43-8d85-56be-b9ba-14ffcbb8f250
# ╠═a8d1fb96-ff6a-5df8-af66-2f52c86ae2b7
# ╟─2bf0647f-7569-57f1-a7fe-67c66ed7912c
# ╠═24e4580a-717b-5a18-94da-e200099299d9
# ╟─4ddcc2a2-0c2e-5926-bb2d-8e5dd65fee04
# ╠═7c9d0f34-5a5c-5cfe-9642-7c1f8723013a
# ╟─5855d188-7e88-531e-906b-5040c6700512
# ╠═b84f17b0-067b-5409-b0c1-9565a8b6cded
# ╟─a2d0d683-adde-5b9d-9093-77301b1c6eb1
# ╠═b0a6b805-eda8-5f69-aa08-a3ba63e581cf
# ╟─369478eb-bf06-5836-a6b5-27537cecabeb
# ╠═5115bcac-01e2-53e7-ada2-b4cc4475cca0
# ╟─db6813be-ca00-5a1d-8655-7b46cd0155ec
# ╠═a5dde77f-402f-53a8-b3ff-b796b5d58b39
# ╟─f0f6fa19-f4ab-5b64-85f3-cae157af2746
# ╠═9d83259e-e662-512e-9d97-8f17f7193f36
# ╟─cff29412-91b5-5e64-9c91-94840c6f985e
# ╠═ac69632c-5ca2-591c-9b00-82d580784f8e
# ╟─4106363b-ca62-5a3e-9b32-a3ad1e65e886
# ╠═eab46aeb-b577-5997-ab9e-f5b53ca27ef4
# ╟─a6ccab39-ddd4-58d8-914c-b034a742f391
# ╠═467c543a-7643-5f8f-8186-857965d065ad
# ╟─c0f39384-f29c-53b5-b58e-306bbad133f4
# ╠═ffbf98c8-256e-570d-8c1f-8c9a750e88c2
# ╟─cdcb523f-a328-5745-b8d3-94b39c6ffd16
# ╠═ce4463f4-f035-5470-a252-36a055141ddf
# ╟─3427ec28-fbfc-5f99-8bf4-b762185883ad
# ╠═ddae11ac-4d81-516d-ae78-58becbe26a7f
# ╟─b4bfb019-9b96-588b-b04f-a5ff9c74812d
# ╠═348201c0-19ee-5d16-a4fc-0b247c11a0e4
# ╟─b7b8e0fd-090a-51a3-a748-38a29f4654f3
# ╠═bb4c7afd-d6bc-50a4-aaeb-0eb30d7be0c3
# ╟─075a236c-eab7-52ea-aa83-ce5a85a6c7e9
# ╠═3d5fc847-e255-5649-b50c-a252cca3cb75
# ╟─07242aa1-0d63-5a3b-873a-ed8df3116453
# ╠═e31c9ff3-db7b-53bf-94db-a3d9f0e37689
# ╟─b902e20a-2325-55d8-9c75-5f633dea4b2f
# ╠═acd51a10-1177-50a4-9455-0195988e6fbe
# ╟─31667412-b62f-58cb-9375-ed92d0014824
# ╠═8ae6071d-f455-5b65-b87e-6c76d4ee24a9
# ╟─8fb6a81d-2faf-5eb8-9e07-0f939b68cf58
# ╠═37a435b6-dd78-5789-89c8-22e1471c6e43
# ╟─9112c1b0-bd45-568a-bd17-32a7b43a197e
# ╠═e26611a1-e580-52cd-8822-f45ef5ae90e9
# ╟─cf8cecbb-d083-5c80-9fdb-90e8c39a58b1
# ╠═0e9bc6d8-5ff9-5319-a7f8-1db7a4fb5716
# ╟─294fcd73-2147-530d-a384-6122575ce46f
# ╠═9bf8df73-15fa-5bbc-af70-fcfb65b9fd06
# ╟─13e5ec7e-c23f-55ae-97df-94af2be9a756
# ╠═8630dbb4-3742-5baa-9b3d-28b55e19ce9b
# ╟─5871b498-db7c-587f-9ef1-4db814e982e0
# ╠═d9c20d7c-2bf1-5630-bee7-5ff9659d9e91
# ╟─94dcd7dd-d95b-57fe-8087-8e12d636ec83
# ╠═fe2c071e-94e1-598c-a911-b555dfb22dfa
# ╟─ea0569be-391d-5b5e-8dbd-5f9005587ba4
# ╠═613b7dbc-58bd-5bd0-9606-597865ab1d84
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╟─605f262b-8e25-4b72-8d24-b3e2c2b1fdb9
# ╠═7d693006-5560-4245-941b-06ee72cdf531
# ╟─9e9b6698-a772-4479-b11c-36046cf3fc21
# ╠═fa2bac9e-31ac-11f0-0569-d7837ec459af
# ╠═ea49a14e-80c3-4d84-9749-6e192e7bb092
