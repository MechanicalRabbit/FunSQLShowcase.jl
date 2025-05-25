module PlutoFunSQL

using DataFrames
using DBInterface
using FunSQL
using FunSQL: @dissect, Chain, Fun, Var

include("query.jl")
include("duckdb.jl")

end
