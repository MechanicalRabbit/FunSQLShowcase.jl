# eICU demo.

module eICU

export connect_eicu_crd_demo

using DBInterface
using DuckDB
using FunSQL
using Pkg.Artifacts
using ..DataFrameConnections

function connect_eicu_crd_demo()
    path = joinpath(artifact"eicu-crd-demo", "eicu-crd-demo-2.0.1.duckdb")
    conn = DBInterface.connect(DuckDB.DB)
    DBInterface.execute(conn, "ATTACH '$(path)' AS eicu (READ_ONLY)")
    catalog = FunSQL.reflect(conn, catalog = "eicu")
    DataFrameConnection(FunSQL.SQLConnection(conn; catalog))
end

end
