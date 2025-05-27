module PlutoFunSQL

using DataFrames
using DBInterface
using FunSQL
using FunSQL: @dissect, Chain, Fun, Var

include("resolve.jl")
include("query.jl")
include("summary.jl")

# keep last; export all funsql_
include("duckdb.jl")

end
