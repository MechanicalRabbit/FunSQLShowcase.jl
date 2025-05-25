using DuckDB

let conn = DBInterface.connect(DuckDB.DB, ":memory:")
    functions_query = """
        SELECT function_name, 
           sum(CASE WHEN function_type == 'aggregate' THEN 1
               ELSE 0 END) > 0 AS is_aggregate
        FROM duckdb_functions()
        WHERE NOT starts_with(function_name, '__')
          AND NOT starts_with(function_name, '!__')
        GROUP BY function_name
        ORDER BY function_name
        """
    fun_names = [x for x in names(FunSQL) if startswith(string(x), "funsql_")]
    stmt = DBInterface.prepare(conn, functions_query)
    curs = DBInterface.execute(stmt)

    for row in curs
        (fn, is_agg) = (row[:function_name], row[:is_aggregate])
        fun  = Symbol("funsql_$fn")
        name = QuoteNode(Symbol(fn))
        if in(fun, fun_names)
            continue
        end
        closure = is_agg ? FunSQL.AggClosure : FunSQL.FunClosure
        eval(:(
            begin
                const $fun = $closure($name)
                export $fun
            end))
    end

    for fun in fun_names
        eval(:(
            begin
                const $fun = FunSQL.$fun
                export $fun
            end))
    end
end
