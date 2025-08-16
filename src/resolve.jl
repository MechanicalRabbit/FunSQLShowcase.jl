# Adjust the query based on the input columns.

module DynamicQueries

export funsql_custom_resolve, funsql_snoop_fields

using FunSQL

mutable struct CustomResolveNode <: FunSQL.AbstractSQLNode
    resolve::Any
    resolve_scalar::Any
    terminal::Bool

    CustomResolveNode(; resolve = nothing, resolve_scalar = nothing, terminal = false) =
        new(resolve, resolve_scalar, terminal)
end

CustomResolveNode(resolve; terminal = false) =
    CustomResolveNode(resolve = resolve, terminal = terminal)


"""
    CustomResolve(; resolve = nothing, resolve_scalar = nothing, terminal = false)
    CustomResolve(resolve; terminal = false)

The `CustomResolve` combinator provides an opportunity to transform the node based
upon its tail, including label and fields.
"""
const CustomResolve = FunSQL.SQLQueryCtor{CustomResolveNode}(:CustomResolve)
const funsql_custom_resolve = CustomResolve

function FunSQL.PrettyPrinting.quoteof(n::CustomResolveNode, ctx::FunSQL.QuoteContext)
    ex = Expr(:call, :custom_resolve) # nameof(CustomResolve)
    if n.resolve !== nothing
        push!(ex.args, Expr(:kw, :resolve, FunSQL.quoteof(n.resolve)))
    end
    if n.resolve_scalar !== nothing
        push!(ex.args, Expr(:kw, :resolve_scalar, FunSQL.quoteof(n.resolve_scalar)))
    end
    if n.terminal
        push!(ex.args, Expr(:kw, :terminal, n.terminal))
    end
    ex
end

function FunSQL.resolve(n::CustomResolveNode, ctx)
    f = n.resolve
    if f === nothing
        throw(FunSQL.IllFormedError(path = FunSQL.get_path(ctx)))
    end
    FunSQL.resolve(convert(FunSQL.SQLQuery, f(n, ctx)), ctx)
end

function FunSQL.resolve_scalar(n::CustomResolveNode, ctx)
    f = n.resolve_scalar
    if f === nothing
        throw(FunSQL.IllFormedError(path = FunSQL.get_path(ctx)))
    end
    FunSQL.resolve_scalar(convert(FunSQL.SQLQuery, f(n, ctx)), ctx)
end

"""
    @funsql snoop_fields()

display the current query's label and field names

# Examples

```julia
using PlutoFunSQL

@funsql conn begin
    from(patients)
    snoop_fields()  # Will log: patients, [:subject_id, :gender, :anchor_age, ...]
    limit(0)
end
```

# See Also
- [`CustomResolve`](@ref) for creating context-aware query transformations
"""
funsql_snoop_fields() =
    CustomResolve() do n, ctx
        tail′ = FunSQL.resolve(ctx)
        label = FunSQL.label(ctx.tail)
        t = FunSQL.row_type(tail′)
        @info label, collect(keys(t.fields))
        tail′
    end

end
