module PlutoFunSQL

using DBInterface
using DataFrames
using FunSQL
using FunSQL: @dissect, Chain, Fun, Var
using HypertextLiteral
using UUIDs
using AbstractPlutoDingetjes
using HTTP

include("resolve.jl")
include("summary.jl")
include("validate.jl")
include("drawio.jl")

# keep last; export all funsql_
include("duckdb.jl")

# Export main functionality
export funsql_custom_resolve, funsql_summary, funsql_snoop_fields
export funsql_validate_primary_key, funsql_validate_foreign_key

funsql_and = var"funsql_&&"
export funsql_and
funsql_or = var"funsql_||"
export funsql_or

end
