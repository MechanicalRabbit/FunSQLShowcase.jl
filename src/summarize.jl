# Column summary.

module SummarizeQueries

export funsql_summarize, funsql_summarize_database

using FunSQL
using ..DuckDBQueries

struct SummarizeNode <: FunSQL.TabularNode
    names::Vector{Symbol}
    type::Bool
    top_k::Int
    nested::Bool
    exact::Bool

    SummarizeNode(; names = Symbol[], type = true, top_k = 0, nested = false, exact = false) =
        new(names, type, top_k, nested, exact)
end

SummarizeNode(names...; type = true, top_k = 0, nested = false, exact = false) =
    SummarizeNode(names = Symbol[names...], type = type, top_k = top_k, nested = nested, exact = exact)


"""
    Summarize(; names = [], type = true, top_k = 0, nested = false, exact = false)
    Summarize(names...; type = true, top_k = 0, nested = false, exact = false)

The `Summarize` combinator computes a number of aggregates over a tabular query.
"""
const Summarize = FunSQL.SQLQueryCtor{SummarizeNode}(:Summarize)
const funsql_summarize = Summarize

function FunSQL.PrettyPrinting.quoteof(n::SummarizeNode, ctx::FunSQL.QuoteContext)
    ex = Expr(:call, :Summarize, FunSQL.quoteof(n.names)...)
    if n.type
        push!(ex.args, Expr(:kw, :type, n.type))
    end
    if n.top_k > 0
        push!(ex.args, Expr(:kw, :top_k, n.top_k))
    end
    if n.nested
        push!(ex.args, Expr(:kw, :nested, n.nested))
    end
    if n.exact
        push!(ex.args, Expr(:kw, :exact, n.exact))
    end
    ex
end

function FunSQL.resolve(n::SummarizeNode, ctx)
    label = FunSQL.label(ctx.tail)
    tail = FunSQL.resolve(ctx)
    t = FunSQL.row_type(tail)
    for name in n.names
        if !haskey(t.fields, name)
            throw(
                FunSQL.ReferenceError(
                    FunSQL.REFERENCE_ERROR_TYPE.UNDEFINED_NAME,
                    name = name,
                    path = FunSQL.get_path(ctx)))
        end
    end
    names = isempty(n.names) ? Set(keys(t.fields)) : Set(n.names)
    cases = _summarize_cases(t, names, n.nested)
    if isempty(cases) && !n.nested
        cases = _summarize_cases(t, names, true)
    end
    cols = last.(cases)
    max_i = length(cases)
    args = FunSQL.SQLQuery[]
    push!(args, :column => _summarize_switch(first.(cases)))
    if n.type
        push!(args, :type => _summarize_switch(map(col -> @funsql(typeof(any_value($col))), cols)))
    end
    push!(
        args,
        :n_not_null => _summarize_switch(map(col -> @funsql(count($col)), cols)),
        :pct_not_null => _summarize_switch(map(col -> @funsql(floor(100 * count($col) / count())), cols)))
    if n.exact
        push!(args, :ndv => _summarize_switch(map(col -> @funsql(count_distinct($col)), cols)))
    else
        push!(args, :appx_ndv => _summarize_switch(map(col -> @funsql(approx_count_distinct($col)), cols)))
    end
    if n.top_k > 0
        for i = 1:n.top_k
            push!(
                args,
                Symbol("appx_top_$i") =>
                    _summarize_switch(map(col ->
                        @funsql(_summarize_approx_top($col, $(n.top_k), $i)), cols)))
        end
    end
    q = @funsql begin
        $tail
        group()
        cross_join(summary_case => from(unnest(generate_series(1, $max_i)), columns = [index]), private = true)
        define(args = $args)
    end
    FunSQL.resolve(q, ctx)
end

function _summarize_cases(t, name_set, nested)
    cases = Tuple{String, FunSQL.SQLQuery}[]
    for (f, ft) in t.fields
        f in name_set || continue
        if ft isa FunSQL.ScalarType
            push!(cases, (String(f), FunSQL.Get(f)))
        elseif ft isa FunSQL.RowType && nested
            subcases = _summarize_cases(ft, Set(keys(ft.fields)), nested)
            for (n, q) in subcases
                push!(cases, ("$f.$n", FunSQL.Get(f) |> q))
            end
        end
    end
    cases
end

function _summarize_switch(branches)
    args = FunSQL.SQLQuery[]
    for (i, branch) in enumerate(branches)
        push!(args, @funsql(summary_case.index == $i), branch)
    end
    FunSQL.Fun.case(args = args)
end

@funsql _summarize_approx_top(q, k, i) =
    list_extract(
        fun(`list_transform(?, x -> x::varchar)`,
            agg(`approx_top_k(?, ?) FILTER (WHERE ? IS NOT NULL)`, $q, $k, $q)), $i)

struct SummarizeDatabaseNode <: FunSQL.TabularNode
    include::Union{Regex, Nothing}
    exclude::Union{Regex, Nothing}
    filter::Union{FunSQL.SQLQuery, Nothing}

    SummarizeDatabaseNode(; include = nothing, exclude = nothing, filter = nothing) =
        new(include, exclude, filter)
end

FunSQL.terminal(::Type{SummarizeDatabaseNode}) =
    true

"""
    SummarizeDatabase(; include = nothing, exclude = nothing, filter = nothing)

The `SummarizeDatabase` combinator database tables and their size.
"""

const SummarizeDatabase = FunSQL.SQLQueryCtor{SummarizeDatabaseNode}(:SummarizeDatabase)
const funsql_summarize_database = SummarizeDatabase

function FunSQL.PrettyPrinting.quoteof(n::SummarizeDatabaseNode, ctx::FunSQL.QuoteContext)
    ex = Expr(:call, :SummarizeDatabase)
    if n.include !== nothing
        push!(ex.args, Expr(:kw, :include, FunSQL.quoteof(n.include)))
    end
    if n.exclude !== nothing
        push!(ex.args, Expr(:kw, :exclude, FunSQL.quoteof(n.exclude)))
    end
    if n.filter !== nothing
        push!(ex.args, Expr(:kw, :filter, FunSQL.quoteof(n.filter)))
    end
    ex
end

function FunSQL.resolve(n::SummarizeDatabaseNode, ctx)
    names = sort(collect(keys(ctx.catalog)))
    include = n.include
    if include !== nothing
        names = [name for name in names if occursin(include, String(name))]
    end
    exclude = n.exclude
    if exclude !== nothing
        names = [name for name in names if !occursin(exclude, String(name))]
    end
    filter = n.filter
    args = FunSQL.SQLQuery[]
    for name in names
        arg = @funsql from($name)
        if filter !== nothing
            arg = @funsql $arg.filter($filter)
            try
                arg = FunSQL.resolve(arg, ctx)
            catch e
                e isa FunSQL.ReferenceError || rethrow()
                continue
            end
        end
        arg = @funsql $arg.group().define(name => $(String(name)), n => count())
        push!(args, arg)
    end
    q = @funsql append(args = $args)
    FunSQL.resolve(q, ctx)
end

end
