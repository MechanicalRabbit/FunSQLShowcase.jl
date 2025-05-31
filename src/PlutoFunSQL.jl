module PlutoFunSQL

using DBInterface
using DataFrames
using FunSQL
using FunSQL: @dissect, Chain, Fun, Var
using HypertextLiteral
using UUIDs

include("resolve.jl")
include("query.jl")
include("summary.jl")
include("explore.jl")

# keep last; export all funsql_
include("duckdb.jl")

end
