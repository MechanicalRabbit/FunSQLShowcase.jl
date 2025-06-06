# Include logic needed for DuckDB dialect specific to FunSQL needs.
# We plan to add this logic, with different implementation, to FunSQL.jl

using DuckDB
using FunSQL
using DBInterface

# We need to identify macros that are aggregates, but this isn't in the
# duckdb_functions(), therefore we list them all here, as copied from
# the documentation; see https://github.com/duckdb/duckdb/issues/17645
const duckdb_aggregates = [
 # collected from https://duckdb.org/docs/stable/sql/functions/aggregates
 # general aggregate functions
 "any_value", "arbitrary", "arg_max", "arg_max_null", "arg_min",
 "arg_min_null", "array_agg", "avg", "bit_and", "bit_or", "bitstring_agg",
 "bit_xor", "bool_and", "bool_or", "corr", "count", "covar_pop", "covar_samp",
 "entropy", "favg", "first", "fsum", "geomean", "histogram",
 "histogram_exact", "kurtosis", "kurtosis_pop", "last", "list", "mad", "max",
 "max_by", "median", "min", "min_by", "mode", "product", "quantile_cont",
 "quantile_disc", "regr_avgx", "regr_avgy", "regr_count", "regr_intercept",
 "regr_r2", "regr_slope", "regr_sxx", "regr_sxy", "regr_syy", "skewness",
 "stddev_pop", "stddev_samp", "string_agg", "sum", "var_pop", "var_samp",
 "weighted_avg",
 # genaral aggregate aliases
 "geometric_mean", "argmax", "argmin", "group_concat", "listagg", "wavg",
 "sumkahan", "kahan_sum", "list", "mean",
 # statisticial aggregages
 "corr", "covar_pop", "covar_samp", "entropy", "kurtosis_pop",
 "kurtosis", "mad", "median", "mode", "quantile_cont", "quantile_disc",
 "regr_avgx", "regr_avgy", "regr_count", "regr_intercept", "regr_r2",
 "regr_slope", "regr_sxx", "regr_sxy", "regr_syy", "skewness",
 "stddev_pop", "stddev_samp", "var_pop", "var_samp",
 # statisticial aggregate aliases
 "quantile", "stddev", "variance",
 # approximate aggreates
 "approx_count_distinct", "approx_quantile", "approx_top_k", "reservoir_quantile",
 # ordered set aggregate functions
 "mode", "percentile_cont", "quantile_cont", "percentile_disc", "quantile_disc",
 # miscallaneous aggreate functions
 "grouping"
]

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
    mod_names = filter(x -> startswith(string(x), "funsql_"), names(@__MODULE__, all=true))
    fun_names = filter(x -> startswith(string(x), "funsql_"), names(FunSQL))
    stmt = DBInterface.prepare(conn, functions_query)
    curs = DBInterface.execute(stmt)

    for row in curs
        (fn, is_agg) = (row[:function_name], row[:is_aggregate])
        # mark additional macros that are aggregages
        is_agg = is_agg || fn in duckdb_aggregates
        fun  = Symbol("funsql_$fn")
        name = QuoteNode(Symbol(fn))
        fun in union(fun_names, mod_names) ? continue : nothing
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

    for fun in mod_names
        eval(:(
            begin
                export $fun
            end))
    end
end
