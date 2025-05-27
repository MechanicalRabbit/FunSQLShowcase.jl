mutable struct SummaryNode <: FunSQL.TabularNode
    names::Vector{Symbol}
    type::Bool
    top_k::Int
    nested::Bool
    exact::Bool

    SummaryNode(; names = Symbol[], type = true, top_k = 0, nested = false, exact = false) =
        new(names, type, top_k, nested, exact)
end

SummaryNode(names...; type = true, top_k = 0, nested = false, exact = false) =
    SummaryNode(names = Symbol[names...], type = type, top_k = top_k, nested = nested, exact = exact)


"""
    Summary(; names = [], type = true, top_k = 0, nested = false, exact = false)
    Summary(names...; type = true, top_k = 0, nested = false, exact = false)

The `Summary` combinator computes a number of aggregates over a tabular query.
"""
const Summary = FunSQL.SQLQueryCtor{SummaryNode}(:Summary)
const funsql_summary = Summary
export funsql_summary

function FunSQL.PrettyPrinting.quoteof(n::SummaryNode, ctx::FunSQL.QuoteContext)
    ex = Expr(:call, :Summary, FunSQL.quoteof(n.names)...)
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

function FunSQL.resolve(n::SummaryNode, ctx)
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
    cases = _summary_cases(t, names, n.nested)
    if isempty(cases) && !n.nested
        cases = _summary_cases(t, names, true)
    end
    cols = last.(cases)
    max_i = length(cases)
    args = FunSQL.SQLQuery[]
    push!(args, :column => _summary_switch(first.(cases)))
    if n.type
        push!(args, :type => _summary_switch(map(col -> @funsql(typeof(any_value($col))), cols)))
    end
    push!(
        args,
        :n_not_null => _summary_switch(map(col -> @funsql(count($col)), cols)),
        :pct_not_null => _summary_switch(map(col -> @funsql(floor(100 * count($col) / count())), cols)))
    if n.exact
        push!(args, :ndv => _summary_switch(map(col -> @funsql(count_distinct($col)), cols)))
    else
        push!(args, :appx_ndv => _summary_switch(map(col -> @funsql(approx_count_distinct($col)), cols)))
    end
    if n.top_k > 0
        for i = 1:n.top_k
            push!(
                args,
                Symbol("appx_top_$i") =>
                    _summary_switch(map(col ->
                        @funsql(_summary_approx_top($col, $(n.top_k), $i)), cols)))
        end
    end
    q = @funsql begin
        $tail
        group()
        cross_join(summary_case => from(unnest(generate_series(1, $max_i)), columns = [index]))
        define(args = $args)
    end
    FunSQL.resolve(q, ctx)
end

function _summary_cases(t, name_set, nested)
    cases = Tuple{String, FunSQL.SQLQuery}[]
    for (f, ft) in t.fields
        f in name_set || continue
        if ft isa FunSQL.ScalarType
            push!(cases, (String(f), FunSQL.Get(f)))
        elseif ft isa FunSQL.RowType && nested
            subcases = _summary_cases(ft, Set(keys(ft.fields)), nested)
            for (n, q) in subcases
                push!(cases, ("$f.$n", FunSQL.Get(f) |> q))
            end
        end
    end
    cases
end

function _summary_switch(branches)
    args = FunSQL.SQLQuery[]
    for (i, branch) in enumerate(branches)
        push!(args, @funsql(summary_case.index == $i), branch)
    end
    FunSQL.Fun.case(args = args)
end

@funsql _summary_approx_top(q, k, i) =
    list_extract(
        fun(`list_transform(?, x -> x::varchar)`,
            agg(`approx_top_k(?, ?) FILTER (WHERE ? IS NOT NULL)`, $q, $k, $q)), $i)
