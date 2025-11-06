### A Pluto.jl notebook ###
# v0.20.20

#> [frontmatter]
#> order = "2"
#> title = "MIMIC-IV Overview"

using Markdown
using InteractiveUtils

# ╔═╡ 6da59f7a-8c98-4022-8b5e-f35892213631
begin
	import Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
end

# ╔═╡ d21919f4-1f35-4165-9d96-44917e88bd07
using Revise

# ╔═╡ b9beff0c-1727-43a3-a0ac-e1e451a2f4f2
begin
	using FunSQL
	using FunSQLShowcase.DynamicQueries
	using FunSQLShowcase.SummarizeQueries
	using FunSQLShowcase.ValidateQueries
	using FunSQLShowcase.MIMIC
	using FunSQLShowcase.PlutoLayout
end

# ╔═╡ b8e5e6ff-3641-4295-80f5-f283195866f0
md"""
# MIMIC-IV Overview
"""

# ╔═╡ 61a24b4f-45ba-4451-87a4-f22b4378bb18
md"""Return number of patient records in the MIMIC-IV database."""

# ╔═╡ 3f730b0d-9b20-4829-af49-6e79be08e83e
md"""## MIMIC Reference"""

# ╔═╡ 6a793e26-8b04-5bcb-a3ee-1cfd2200e76e
md"""
### admissions
Detailed information about hospital stays. Contains all hospitalizations in the database with admission/discharge times, demographic information, admission source, discharge location, insurance, and patient demographics for each hospital visit. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/admissions/))
"""

# ╔═╡ 88a7b91d-09b6-5184-952a-78e140a3640b
md"""
### caregiver
The caregiver table lists deidentified provider identifiers used in the ICU module. As of MIMIC-IV v2.2, this table simply lists all unique caregiver_id in the database to distinguish ICU caregivers from hospital-wide providers. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/caregiver/))
"""

# ╔═╡ 45aa871b-f1fc-5ded-a51d-9e68f0124a3e
md"""
### chartevents
Charted items occurring during the ICU stay. Contains the majority of information documented in the ICU including routine vital signs, ventilator settings, laboratory values, code status, mental status, and other clinical measurements from the MetaVision ICU database. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/chartevents/))
"""

# ╔═╡ 63d0ab43-8d85-56be-b9ba-14ffcbb8f250
md"""
### d_hcpcs
Dimension table for hcpcsevents; provides a description of CPT codes. Used to acquire human readable definitions for codes used in the hcpcsevents table, primarily corresponding to hospital billing. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/d_hcpcs/))
"""

# ╔═╡ 2bf0647f-7569-57f1-a7fe-67c66ed7912c
md"""
### d\_icd\_diagnoses
Dimension table for diagnoses\_icd; provides a description of ICD-9/ICD-10 billed diagnoses. Defines International Classification of Diseases codes for diagnoses assigned at the end of patient stays for hospital billing. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/d_icd_diagnoses/))
"""

# ╔═╡ 4ddcc2a2-0c2e-5926-bb2d-8e5dd65fee04
md"""
### d\_icd\_procedures

Dimension table for procedures\_icd; provides a description of ICD-9/ICD-10 billed procedures. Defines International Classification of Diseases codes for procedures assigned at the end of patient stays for hospital billing and procedure identification. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/d_icd_procedures/))
"""

# ╔═╡ 5855d188-7e88-531e-906b-5040c6700512
md"""
### d_items
Dimension table describing itemid. Defines concepts recorded in the events table in the ICU module. Contains definitions for all measurements in the ICU databases including labels, categories, units, and reference ranges. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/d_items/))
"""

# ╔═╡ a2d0d683-adde-5b9d-9093-77301b1c6eb1
md"""
### d_labitems
Dimension table for labevents provides a description of all lab items. Contains definitions for all laboratory measurements with fluid type, category, and concept labels, many mapped to LOINC codes. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/d_labitems/))
"""

# ╔═╡ 369478eb-bf06-5836-a6b5-27537cecabeb
md"""
### datetimeevents
Documented information which is in a date format (e.g. date of last dialysis). Contains all date formatted data from the MetaVision ICU database with anonymized dates that maintain chronological relationships. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/datetimesevents/))
"""

# ╔═╡ db6813be-ca00-5a1d-8655-7b46cd0155ec
md"""
### diagnoses_icd
Billed ICD-9/ICD-10 diagnoses for hospitalizations. Contains records of all diagnoses a patient was billed for during their hospital stay, determined by trained personnel who read clinical notes. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/diagnoses_icd/))
"""

# ╔═╡ f0f6fa19-f4ab-5b64-85f3-cae157af2746
md"""
### drgcodes
Billed diagnosis related group (DRG) codes for hospitalizations. Contains DRG codes used by the hospital to obtain reimbursement, corresponding to the primary reason for a patient's hospital stay. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/drgcodes/))
"""

# ╔═╡ cff29412-91b5-5e64-9c91-94840c6f985e
md"""
### emar
The Electronic Medicine Administration Record (eMAR); barcode scanning of medications at the time of administration. Records actual administrations of medications to patients, populated by bedside nursing staff scanning barcodes. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/emar/))
"""

# ╔═╡ 4106363b-ca62-5a3e-9b32-a3ad1e65e886
md"""
### emar_detail
Supplementary information for electronic administrations recorded in emar. Contains detailed information for each medicine administration including dose due, dose given, pharmacy orders, and administration parameters. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/emar_detail/))
"""

# ╔═╡ a6ccab39-ddd4-58d8-914c-b034a742f391
md"""
### hcpcsevents
Billed events occurring during the hospitalization. Includes CPT codes and other healthcare procedure coding events associated with hospital billing. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/hcpcsevents/))
"""

# ╔═╡ c0f39384-f29c-53b5-b58e-306bbad133f4
md"""
### icustays
Tracking information for ICU stays including admission and discharge times. Defines each ICU stay in the database using STAY_ID, derived from the transfers table with consecutive ICU stays merged into single entries. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/icustays/))
"""

# ╔═╡ cdcb523f-a328-5745-b8d3-94b39c6ffd16
md"""
### ingredientevents
Ingredients of continuous or intermittent administrations including nutritional and water content. Contains ingredients contained within inputs data for patients in the ICU, derived from rate and time information. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/ingredientevents/))
"""

# ╔═╡ 3427ec28-fbfc-5f99-8bf4-b762185883ad
md"""
### inputevents
Information documented regarding continuous infusions or intermittent administrations. Contains input data for patients from the MetaVision ICU database including medications, solutions, and nutritional inputs with rates and amounts. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/inputevents/))
"""

# ╔═╡ b4bfb019-9b96-588b-b04f-a5ff9c74812d
md"""
### labevents
Laboratory measurements sourced from patient derived specimens. Stores results of all laboratory measurements including hematology, blood gases, chemistry panels, and specialized tests from the hospital laboratory database. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/labevents/))
"""

# ╔═╡ b7b8e0fd-090a-51a3-a748-38a29f4654f3
md"""
### microbiologyevents
Microbiology cultures. Contains microbiology test results including bacterial cultures, organism identification, and antibiotic sensitivity testing from patient specimens. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/microbiologyevents/))
"""

# ╔═╡ 075a236c-eab7-52ea-aa83-ce5a85a6c7e9
md"""
### omr
The Online Medical Record (OMR) table contains miscellaneous information from the EHR. Stores miscellaneous information documented in the electronic health record, useful for outpatient measurements like blood pressure, weight, height, and BMI. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/omr/))
"""

# ╔═╡ 07242aa1-0d63-5a3b-873a-ed8df3116453
md"""
### outputevents
Information regarding patient outputs including urine, drainage, and so on. Contains output data for patients from the MetaVision ICU database documenting substances removed from or lost by patients. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/outputevents/))
"""

# ╔═╡ b902e20a-2325-55d8-9c75-5f633dea4b2f
md"""
### patients
Patients' gender, age, and date of death if information exists. Contains information that is consistent for the lifetime of a patient including demographics, anchor age/year for temporal analysis, and date of death when available. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/patients/))
"""

# ╔═╡ 31667412-b62f-58cb-9375-ed92d0014824
md"""
### pharmacy
Formulary, dosing, and other information for prescribed medications. Provides detailed information regarding filled medications prescribed to patients including dose, frequency, route, and duration of prescriptions. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/pharmacy/))
"""

# ╔═╡ 8fb6a81d-2faf-5eb8-9e07-0f939b68cf58
md"""
### poe
Orders made by providers relating to patient care. Contains provider order entry (POE) orders which are the general interface through which care providers enter treatment and procedure orders. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/poe/))
"""

# ╔═╡ 9112c1b0-bd45-568a-bd17-32a7b43a197e
md"""
### poe_detail
Supplementary information for orders made by providers in the hospital. Uses an Entity-Attribute-Value model to provide flexible description of POE orders with heterogeneous attributes. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/poe_detail/))
"""

# ╔═╡ cf8cecbb-d083-5c80-9fdb-90e8c39a58b1
md"""
### prescriptions
Prescribed medications. Provides information about prescribed medications including drug names, coded identifiers (GSN, NDC), product strength, formulary dose, and route of administration. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/prescriptions/))
"""

# ╔═╡ 294fcd73-2147-530d-a384-6122575ce46f
md"""
### procedureevents
Procedures documented during the ICU stay (e.g. ventilation), though not necessarily conducted within the ICU (e.g. x-ray imaging). Contains procedures for ICU patients from the MetaVision database, though documentation is not required and varies by procedure type. ([docs](https://mimic.mit.edu/docs/iv/modules/icu/procedureevents/))
"""

# ╔═╡ 13e5ec7e-c23f-55ae-97df-94af2be9a756
md"""
### procedures_icd
Billed procedures for patients during their hospital stay. Contains records of all procedures a patient was billed for during their hospital stay using ICD-9 and ICD-10 ontologies, including only hospital-billed procedures. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/procedures_icd/))
"""

# ╔═╡ 5871b498-db7c-587f-9ef1-4db814e982e0
md"""
### provider
The provider table lists deidentified provider identifiers used in the database. As of MIMIC-IV v2.2, simply lists all unique provider_id in the database for hospital-wide providers. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/provider/))
"""

# ╔═╡ 94dcd7dd-d95b-57fe-8087-8e12d636ec83
md"""
### services
The hospital service(s) which cared for the patient during their hospitalization. Describes the service that a patient was admitted under, used to identify the type of care received (e.g., surgical, medical, cardiac) regardless of physical location. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/services/))
"""

# ╔═╡ ea0569be-391d-5b5e-8dbd-5f9005587ba4
md"""
### transfers
Detailed information about patients' unit transfers. Contains physical locations for patients throughout their hospital stay, tracking patient movements between different care units and wards. ([docs](https://mimic.mit.edu/docs/iv/modules/hosp/transfers/))
"""

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
@funsql tally() = begin
	group()
	define(n => count())
end

# ╔═╡ 9e9b6698-a772-4479-b11c-36046cf3fc21
md"""
### Notebook Setup

- use dependencies needed for querying
- connect to the MIMIC IV demo database
- define @mimic macro to use that database
- configure Pluto layout
"""

# ╔═╡ e11a84c6-e762-47d9-a366-13c9b39d7e3f
mimic_db = connect_mimic_iv_demo()

# ╔═╡ 9a9e8bbd-17ab-41aa-b744-78fb13c8ac30
macro mimic(ex, args...)
	esc(:(@funsql($mimic_db, $ex, $(args...))))
end

# ╔═╡ c88a31f9-9065-4457-b9c9-19f10f7a2172
@mimic begin
	from(patients)
	snoop_fields()
	tally()
end

# ╔═╡ c4e5994f-4001-4a65-bef7-5bcb85783db1
@mimic summarize_database()

# ╔═╡ b4063097-f70b-5178-8d6f-1e69081ce9c8
@mimic from(admissions).summarize()

# ╔═╡ 4380c98a-cc71-4dbe-9718-ae446f1ce238
@mimic validate_primary_key(admissions, hadm_id)

# ╔═╡ 49558038-c04d-40b8-9d04-92e9d431a7c2
@mimic validate_foreign_key(admissions, subject_id, patients)

# ╔═╡ 5ac65f7f-bed8-51a7-9f98-c9d18e6afe05
@mimic from(caregiver).summarize()

# ╔═╡ d1e40c08-34e0-5a4b-85a2-58dd1d05cf4a
@mimic from(chartevents).summarize()

# ╔═╡ 36ccbb35-f24b-4751-8a57-3fc349501e53
@mimic append(
    validate_foreign_key(chartevents, subject_id, patients),
    validate_foreign_key(chartevents, hadm_id, admissions),
    validate_foreign_key(chartevents, stay_id, icustays),
    validate_foreign_key(chartevents, itemid, d_items)
)

# ╔═╡ a8d1fb96-ff6a-5df8-af66-2f52c86ae2b7
@mimic from(d_hcpcs).summarize()

# ╔═╡ dc244bb4-2edd-471b-a7ab-bd390d35eb0f
@mimic validate_primary_key(d_hcpcs, code)

# ╔═╡ 24e4580a-717b-5a18-94da-e200099299d9
@mimic from(d_icd_diagnoses).summarize()

# ╔═╡ 27db1140-43f4-4436-9fe8-e95860b63b08
@mimic validate_primary_key(d_icd_diagnoses, [icd_code, icd_version])

# ╔═╡ 7c9d0f34-5a5c-5cfe-9642-7c1f8723013a
@mimic from(d_icd_procedures).summarize()

# ╔═╡ f0d8cdf7-576a-4bb7-bbe2-21289911e144
@mimic validate_primary_key(d_icd_procedures, [icd_code, icd_version])

# ╔═╡ b84f17b0-067b-5409-b0c1-9565a8b6cded
@mimic from(d_items).summarize()

# ╔═╡ 62a25ae2-1713-411f-a0ff-d92870aa10be
@mimic validate_primary_key(d_items, itemid)

# ╔═╡ b0a6b805-eda8-5f69-aa08-a3ba63e581cf
@mimic from(d_labitems).summarize()

# ╔═╡ 59fd04bb-d33e-430d-868a-9936f4be4100
@mimic validate_primary_key(d_labitems, itemid)

# ╔═╡ 5115bcac-01e2-53e7-ada2-b4cc4475cca0
@mimic from(datetimeevents).summarize()

# ╔═╡ a9983ea8-32d0-4a33-8456-386fbaae3687
@mimic validate_primary_key(datetimeevents, [stay_id, itemid, charttime])

# ╔═╡ f848137e-9f87-4211-b3cc-658a2f7e8d5f
@mimic append(
    validate_foreign_key(datetimeevents, subject_id, patients),
    validate_foreign_key(datetimeevents, hadm_id, admissions),
    validate_foreign_key(datetimeevents, stay_id, icustays),
    validate_foreign_key(datetimeevents, itemid, d_items)
)

# ╔═╡ a5dde77f-402f-53a8-b3ff-b796b5d58b39
@mimic from(diagnoses_icd).summarize()

# ╔═╡ b659e5b3-3385-4a3a-9776-261904cb3fe8
@mimic validate_primary_key(diagnoses_icd, [hadm_id, seq_num, icd_code, icd_version])

# ╔═╡ 66a1dc19-6cc0-4ea8-8074-e25a5fcd5cb4
@mimic append(
    validate_foreign_key(diagnoses_icd, subject_id, patients),
    validate_foreign_key(diagnoses_icd, hadm_id, admissions)
)

# ╔═╡ 9d83259e-e662-512e-9d97-8f17f7193f36
@mimic from(drgcodes).summarize()

# ╔═╡ a4ec730f-0da0-4b3e-8697-593fdd2c4b70
@mimic append(
    validate_foreign_key(drgcodes, subject_id, patients),
    validate_foreign_key(drgcodes, hadm_id, admissions)
)

# ╔═╡ ac69632c-5ca2-591c-9b00-82d580784f8e
@mimic from(emar).summarize()

# ╔═╡ 6285abb7-8a41-444b-aa22-daa3585a4565
@mimic validate_primary_key(emar, emar_id)

# ╔═╡ cac22a41-dc99-4053-aca0-4fc7eb7d7e16
@mimic append(
    validate_foreign_key(emar, subject_id, patients),
    validate_foreign_key(emar, hadm_id, admissions)
)

# ╔═╡ eab46aeb-b577-5997-ab9e-f5b53ca27ef4
@mimic from(emar_detail).summarize()

# ╔═╡ 13ddb5c1-afdd-40b3-9505-b3960614ada0
@mimic append(
    validate_foreign_key(emar_detail, subject_id, patients),
    validate_foreign_key(emar_detail, emar_id, emar)
)

# ╔═╡ 467c543a-7643-5f8f-8186-857965d065ad
@mimic from(hcpcsevents).summarize()

# ╔═╡ ebe81545-d3db-4e2b-8cd7-e8934f3e5ff5
@mimic validate_primary_key(hcpcsevents, [hadm_id, hcpcs_cd, seq_num])

# ╔═╡ d3f690d7-d0c7-4609-96a3-df3e7ea75b73
@mimic append(
    validate_foreign_key(hcpcsevents, subject_id, patients),
    validate_foreign_key(hcpcsevents, hadm_id, admissions),
    validate_foreign_key(hcpcsevents, hcpcs_cd, d_hcpcs, code)
)

# ╔═╡ ffbf98c8-256e-570d-8c1f-8c9a750e88c2
@mimic from(icustays).summarize()

# ╔═╡ f9dedce0-056a-48ea-882c-864ebf8813a6
@mimic validate_primary_key(icustays, stay_id)

# ╔═╡ 81bc9694-3514-4c27-9f68-f1ca4cfbe295
@mimic append(
    validate_foreign_key(icustays, subject_id, patients),
    validate_foreign_key(icustays, hadm_id, admissions)
)

# ╔═╡ ce4463f4-f035-5470-a252-36a055141ddf
@mimic from(ingredientevents).summarize()

# ╔═╡ ddae11ac-4d81-516d-ae78-58becbe26a7f
@mimic from(inputevents).summarize()

# ╔═╡ a3738ca7-781c-47ab-bece-6d50178b3b1b
@mimic validate_primary_key(inputevents, [orderid, itemid])

# ╔═╡ 7ab3188b-2940-493c-bf2d-5f91f30a4277
@mimic append(
    validate_foreign_key(inputevents, subject_id, patients),
    validate_foreign_key(inputevents, hadm_id, admissions),
    validate_foreign_key(inputevents, stay_id, icustays),
    validate_foreign_key(inputevents, itemid, d_items)
)

# ╔═╡ 348201c0-19ee-5d16-a4fc-0b247c11a0e4
@mimic from(labevents).summarize()

# ╔═╡ 73dbb553-4f72-422e-a98c-49b2c309ec64
@mimic validate_primary_key(labevents, labevent_id)

# ╔═╡ 90231d65-d190-4e32-b9ad-a2d59782300a
@mimic append(
    validate_foreign_key(labevents, subject_id, patients),
    validate_foreign_key(labevents, itemid, d_labitems)
)

# ╔═╡ bb4c7afd-d6bc-50a4-aaeb-0eb30d7be0c3
@mimic from(microbiologyevents).summarize()

# ╔═╡ 4fb2cc59-d8f5-49df-94fa-cbb9a6aa3a6a
@mimic validate_primary_key(microbiologyevents, microevent_id)

# ╔═╡ e8126ba2-f1f4-4a74-a5e7-1dd9fd513cb7
@mimic append(
    validate_foreign_key(microbiologyevents, subject_id, patients),
    validate_foreign_key(microbiologyevents, hadm_id, admissions)
)

# ╔═╡ 3d5fc847-e255-5649-b50c-a252cca3cb75
@mimic from(omr).summarize()

# ╔═╡ e31c9ff3-db7b-53bf-94db-a3d9f0e37689
@mimic from(outputevents).summarize()

# ╔═╡ 18166175-9a71-40e3-8525-8fd9ebd7b665
@mimic validate_primary_key(outputevents, [stay_id, charttime, itemid])

# ╔═╡ 86bb6468-91e7-47a5-b049-4059ca03cec1
@mimic append(
    validate_foreign_key(outputevents, subject_id, patients),
    validate_foreign_key(outputevents, hadm_id, admissions),
    validate_foreign_key(outputevents, stay_id, icustays),
    validate_foreign_key(outputevents, itemid, d_items)
)

# ╔═╡ acd51a10-1177-50a4-9455-0195988e6fbe
@mimic from(patients).summarize()

# ╔═╡ 092a34b3-2764-4072-8174-fd4dd7c42b64
@mimic validate_primary_key(patients, subject_id)

# ╔═╡ 8ae6071d-f455-5b65-b87e-6c76d4ee24a9
@mimic from(pharmacy).summarize()

# ╔═╡ 85392e55-c489-4765-b7aa-709698f73fa4
@mimic validate_primary_key(pharmacy, pharmacy_id)

# ╔═╡ e149b716-5f4b-4570-849e-41d2cdeb5ee9
@mimic append(
    validate_foreign_key(pharmacy, subject_id, patients),
    validate_foreign_key(pharmacy, hadm_id, admissions)
)

# ╔═╡ 37a435b6-dd78-5789-89c8-22e1471c6e43
@mimic from(poe).summarize()

# ╔═╡ 2d54db68-4406-4c4f-9e00-16a26f3b2737
@mimic validate_primary_key(poe, poe_id)

# ╔═╡ 9f1f9488-7b5d-454b-b550-4cefecc663bb
@mimic append(
    validate_foreign_key(poe, subject_id, patients),
    validate_foreign_key(poe, hadm_id, admissions)
)

# ╔═╡ e26611a1-e580-52cd-8822-f45ef5ae90e9
@mimic from(poe_detail).summarize()

# ╔═╡ 8d0a8cb2-c8ba-43a9-bb53-c36aa5c38813
@mimic validate_primary_key(poe_detail, [poe_id, field_name])

# ╔═╡ 959a9bb5-45e0-44dd-a7e1-3647a7ff1ba0
@mimic append(
    validate_foreign_key(poe_detail, subject_id, patients),
    validate_foreign_key(poe_detail, poe_id, poe)
)

# ╔═╡ 0e9bc6d8-5ff9-5319-a7f8-1db7a4fb5716
@mimic from(prescriptions).summarize()

# ╔═╡ 52acb2ae-4a48-443b-99ab-daa4e55aa731
@mimic validate_primary_key(prescriptions, [pharmacy_id, drug_type, drug])

# ╔═╡ 13ebad9f-6cd3-464e-b197-c26337d23436
@mimic append(
    validate_foreign_key(prescriptions, subject_id, patients),
    validate_foreign_key(prescriptions, hadm_id, admissions)
)

# ╔═╡ 9bf8df73-15fa-5bbc-af70-fcfb65b9fd06
@mimic from(procedureevents).summarize()

# ╔═╡ 9b354c13-2732-4af6-bda2-95966ea406b3
@mimic validate_primary_key(procedureevents, orderid)

# ╔═╡ 25e3d9d8-aa67-4742-b362-d9942151c98c
@mimic append(
    validate_foreign_key(procedureevents, subject_id, patients),
    validate_foreign_key(procedureevents, hadm_id, admissions),
    validate_foreign_key(procedureevents, stay_id, icustays),
    validate_foreign_key(procedureevents, itemid, d_items)
)

# ╔═╡ 8630dbb4-3742-5baa-9b3d-28b55e19ce9b
@mimic from(procedures_icd).summarize()

# ╔═╡ 349972ad-f23f-4b19-aebe-870f6527fd2b
@mimic validate_primary_key(procedures_icd, [hadm_id, seq_num, icd_code, icd_version])

# ╔═╡ 9599ee54-bd4b-4e72-99a5-64adf8a663c4
@mimic append(
    validate_foreign_key(procedures_icd, subject_id, patients),
    validate_foreign_key(procedures_icd, hadm_id, admissions)
)

# ╔═╡ d9c20d7c-2bf1-5630-bee7-5ff9659d9e91
@mimic from(provider).summarize()

# ╔═╡ fe2c071e-94e1-598c-a911-b555dfb22dfa
@mimic from(services).summarize()

# ╔═╡ 3c04f998-311b-4309-a093-b451ec7b09d7
@mimic validate_primary_key(services, [hadm_id, transfertime, curr_service])

# ╔═╡ 5a5227ae-c450-4e90-bbed-016437f993de
@mimic append(
    validate_foreign_key(services, subject_id, patients),
    validate_foreign_key(services, hadm_id, admissions)
)

# ╔═╡ 613b7dbc-58bd-5bd0-9606-597865ab1d84
@mimic from(transfers).summarize()

# ╔═╡ 240fe1fa-5bdd-4846-9352-a9b3d55ac834
@mimic validate_primary_key(transfers, transfer_id)

# ╔═╡ d576fbe9-0d03-463d-9df7-b87a5566ce0c
@mimic validate_foreign_key(transfers, subject_id, patients)

# ╔═╡ 0cae47a3-2a77-4c88-8b86-6049ef38c34a
PlutoFluid()

# ╔═╡ 5a5b05a0-2fd1-4e2e-bea6-b10a2b1a2302
PlutoSidebar(index = true)

# ╔═╡ Cell order:
# ╟─b8e5e6ff-3641-4295-80f5-f283195866f0
# ╟─61a24b4f-45ba-4451-87a4-f22b4378bb18
# ╠═c88a31f9-9065-4457-b9c9-19f10f7a2172
# ╟─3f730b0d-9b20-4829-af49-6e79be08e83e
# ╠═c4e5994f-4001-4a65-bef7-5bcb85783db1
# ╟─6a793e26-8b04-5bcb-a3ee-1cfd2200e76e
# ╠═b4063097-f70b-5178-8d6f-1e69081ce9c8
# ╠═4380c98a-cc71-4dbe-9718-ae446f1ce238
# ╠═49558038-c04d-40b8-9d04-92e9d431a7c2
# ╟─88a7b91d-09b6-5184-952a-78e140a3640b
# ╠═5ac65f7f-bed8-51a7-9f98-c9d18e6afe05
# ╟─45aa871b-f1fc-5ded-a51d-9e68f0124a3e
# ╠═d1e40c08-34e0-5a4b-85a2-58dd1d05cf4a
# ╠═36ccbb35-f24b-4751-8a57-3fc349501e53
# ╟─63d0ab43-8d85-56be-b9ba-14ffcbb8f250
# ╠═a8d1fb96-ff6a-5df8-af66-2f52c86ae2b7
# ╠═dc244bb4-2edd-471b-a7ab-bd390d35eb0f
# ╟─2bf0647f-7569-57f1-a7fe-67c66ed7912c
# ╠═24e4580a-717b-5a18-94da-e200099299d9
# ╠═27db1140-43f4-4436-9fe8-e95860b63b08
# ╟─4ddcc2a2-0c2e-5926-bb2d-8e5dd65fee04
# ╠═7c9d0f34-5a5c-5cfe-9642-7c1f8723013a
# ╠═f0d8cdf7-576a-4bb7-bbe2-21289911e144
# ╟─5855d188-7e88-531e-906b-5040c6700512
# ╠═b84f17b0-067b-5409-b0c1-9565a8b6cded
# ╠═62a25ae2-1713-411f-a0ff-d92870aa10be
# ╟─a2d0d683-adde-5b9d-9093-77301b1c6eb1
# ╠═b0a6b805-eda8-5f69-aa08-a3ba63e581cf
# ╠═59fd04bb-d33e-430d-868a-9936f4be4100
# ╟─369478eb-bf06-5836-a6b5-27537cecabeb
# ╠═5115bcac-01e2-53e7-ada2-b4cc4475cca0
# ╠═a9983ea8-32d0-4a33-8456-386fbaae3687
# ╠═f848137e-9f87-4211-b3cc-658a2f7e8d5f
# ╟─db6813be-ca00-5a1d-8655-7b46cd0155ec
# ╠═a5dde77f-402f-53a8-b3ff-b796b5d58b39
# ╠═b659e5b3-3385-4a3a-9776-261904cb3fe8
# ╠═66a1dc19-6cc0-4ea8-8074-e25a5fcd5cb4
# ╟─f0f6fa19-f4ab-5b64-85f3-cae157af2746
# ╠═9d83259e-e662-512e-9d97-8f17f7193f36
# ╠═a4ec730f-0da0-4b3e-8697-593fdd2c4b70
# ╟─cff29412-91b5-5e64-9c91-94840c6f985e
# ╠═ac69632c-5ca2-591c-9b00-82d580784f8e
# ╠═6285abb7-8a41-444b-aa22-daa3585a4565
# ╠═cac22a41-dc99-4053-aca0-4fc7eb7d7e16
# ╟─4106363b-ca62-5a3e-9b32-a3ad1e65e886
# ╠═eab46aeb-b577-5997-ab9e-f5b53ca27ef4
# ╠═13ddb5c1-afdd-40b3-9505-b3960614ada0
# ╟─a6ccab39-ddd4-58d8-914c-b034a742f391
# ╠═467c543a-7643-5f8f-8186-857965d065ad
# ╠═ebe81545-d3db-4e2b-8cd7-e8934f3e5ff5
# ╠═d3f690d7-d0c7-4609-96a3-df3e7ea75b73
# ╟─c0f39384-f29c-53b5-b58e-306bbad133f4
# ╠═ffbf98c8-256e-570d-8c1f-8c9a750e88c2
# ╠═f9dedce0-056a-48ea-882c-864ebf8813a6
# ╠═81bc9694-3514-4c27-9f68-f1ca4cfbe295
# ╟─cdcb523f-a328-5745-b8d3-94b39c6ffd16
# ╠═ce4463f4-f035-5470-a252-36a055141ddf
# ╟─3427ec28-fbfc-5f99-8bf4-b762185883ad
# ╠═ddae11ac-4d81-516d-ae78-58becbe26a7f
# ╠═a3738ca7-781c-47ab-bece-6d50178b3b1b
# ╠═7ab3188b-2940-493c-bf2d-5f91f30a4277
# ╟─b4bfb019-9b96-588b-b04f-a5ff9c74812d
# ╠═348201c0-19ee-5d16-a4fc-0b247c11a0e4
# ╠═73dbb553-4f72-422e-a98c-49b2c309ec64
# ╠═90231d65-d190-4e32-b9ad-a2d59782300a
# ╟─b7b8e0fd-090a-51a3-a748-38a29f4654f3
# ╠═bb4c7afd-d6bc-50a4-aaeb-0eb30d7be0c3
# ╠═4fb2cc59-d8f5-49df-94fa-cbb9a6aa3a6a
# ╠═e8126ba2-f1f4-4a74-a5e7-1dd9fd513cb7
# ╟─075a236c-eab7-52ea-aa83-ce5a85a6c7e9
# ╠═3d5fc847-e255-5649-b50c-a252cca3cb75
# ╟─07242aa1-0d63-5a3b-873a-ed8df3116453
# ╠═e31c9ff3-db7b-53bf-94db-a3d9f0e37689
# ╠═18166175-9a71-40e3-8525-8fd9ebd7b665
# ╠═86bb6468-91e7-47a5-b049-4059ca03cec1
# ╟─b902e20a-2325-55d8-9c75-5f633dea4b2f
# ╠═acd51a10-1177-50a4-9455-0195988e6fbe
# ╠═092a34b3-2764-4072-8174-fd4dd7c42b64
# ╟─31667412-b62f-58cb-9375-ed92d0014824
# ╠═8ae6071d-f455-5b65-b87e-6c76d4ee24a9
# ╠═85392e55-c489-4765-b7aa-709698f73fa4
# ╠═e149b716-5f4b-4570-849e-41d2cdeb5ee9
# ╟─8fb6a81d-2faf-5eb8-9e07-0f939b68cf58
# ╠═37a435b6-dd78-5789-89c8-22e1471c6e43
# ╠═2d54db68-4406-4c4f-9e00-16a26f3b2737
# ╠═9f1f9488-7b5d-454b-b550-4cefecc663bb
# ╟─9112c1b0-bd45-568a-bd17-32a7b43a197e
# ╠═e26611a1-e580-52cd-8822-f45ef5ae90e9
# ╠═8d0a8cb2-c8ba-43a9-bb53-c36aa5c38813
# ╠═959a9bb5-45e0-44dd-a7e1-3647a7ff1ba0
# ╟─cf8cecbb-d083-5c80-9fdb-90e8c39a58b1
# ╠═0e9bc6d8-5ff9-5319-a7f8-1db7a4fb5716
# ╠═52acb2ae-4a48-443b-99ab-daa4e55aa731
# ╠═13ebad9f-6cd3-464e-b197-c26337d23436
# ╟─294fcd73-2147-530d-a384-6122575ce46f
# ╠═9bf8df73-15fa-5bbc-af70-fcfb65b9fd06
# ╠═9b354c13-2732-4af6-bda2-95966ea406b3
# ╠═25e3d9d8-aa67-4742-b362-d9942151c98c
# ╟─13e5ec7e-c23f-55ae-97df-94af2be9a756
# ╠═8630dbb4-3742-5baa-9b3d-28b55e19ce9b
# ╠═349972ad-f23f-4b19-aebe-870f6527fd2b
# ╠═9599ee54-bd4b-4e72-99a5-64adf8a663c4
# ╟─5871b498-db7c-587f-9ef1-4db814e982e0
# ╠═d9c20d7c-2bf1-5630-bee7-5ff9659d9e91
# ╟─94dcd7dd-d95b-57fe-8087-8e12d636ec83
# ╠═fe2c071e-94e1-598c-a911-b555dfb22dfa
# ╠═3c04f998-311b-4309-a093-b451ec7b09d7
# ╠═5a5227ae-c450-4e90-bbed-016437f993de
# ╟─ea0569be-391d-5b5e-8dbd-5f9005587ba4
# ╠═613b7dbc-58bd-5bd0-9606-597865ab1d84
# ╠═240fe1fa-5bdd-4846-9352-a9b3d55ac834
# ╠═d576fbe9-0d03-463d-9df7-b87a5566ce0c
# ╟─fff8f53f-f08e-44c6-94a9-17e8d213c497
# ╟─605f262b-8e25-4b72-8d24-b3e2c2b1fdb9
# ╠═7d693006-5560-4245-941b-06ee72cdf531
# ╟─9e9b6698-a772-4479-b11c-36046cf3fc21
# ╠═e11a84c6-e762-47d9-a366-13c9b39d7e3f
# ╠═9a9e8bbd-17ab-41aa-b744-78fb13c8ac30
# ╠═6da59f7a-8c98-4022-8b5e-f35892213631
# ╠═d21919f4-1f35-4165-9d96-44917e88bd07
# ╠═b9beff0c-1727-43a3-a0ac-e1e451a2f4f2
# ╠═0cae47a3-2a77-4c88-8b86-6049ef38c34a
# ╠═5a5b05a0-2fd1-4e2e-bea6-b10a2b1a2302
