module TallyQueries

export funsql_tally

using FunSQL
using ..DuckDBQueries

""" tally(keys...)

Count the number of input rows for each distinct combination of `keys`.

The output includes the grouping keys and two additional columns:
- `n` -- number of rows in each group
- `%` -- percentage of the total number of rows

# Examples

```julia
@funsql begin
    from(person)
    tally(gender_concept_id)
end
```
"""
@funsql tally(keys...) = begin
    group($(keys...))
    define(n => count())
    partition(name = _tally_all)
    define(`%` => floor(1000 * n / _tally_all.sum(n)) / 10)
    order(n.desc())
end

end
