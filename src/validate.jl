module ValidateQueries

export funsql_validate_primary_key, funsql_validate_foreign_key

using FunSQL
using ..DuckDBQueries

@funsql begin

""" validate_primary_key(source, columns)

validate the primary key constraints by checking for nulls and duplicates,
returning total records, null count, duplicate count, etc.
"""
validate_primary_key(source::FunSQL.SQLQuery, columns::Vector{Symbol}) = begin
    $source
    group($(columns...))
    define(key_is_not_null => and(args = $[
        @funsql(is_not_null($column)) for column in columns
    ]))
    group()
    define(
        primary_key => $(_primary_key_name(source, columns)),
        n => sum(count()),                    # Total records
        ndv => count(filter = key_is_not_null), # Distinct valid keys
        n_null => nullif(sum(count(), filter = !key_is_not_null), 0),
        n_dup => nullif(sum(count(),
            filter = count() > 1 && key_is_not_null), 0),
        ndv_dup => nullif(count(
            filter = count() > 1 && key_is_not_null), 0))
    define(is_valid => is_null(n_null) && is_null(n_dup),
        after = primary_key)
    define(pct_null => floor(100 * n_null / n), after = n_null)
    define(pct_dup => floor(100 * n_dup / n), after = n_dup)
end

# Convenience wrapper for table symbol with column vector
validate_primary_key(table::Symbol, columns::Vector{Symbol}) =
    validate_primary_key(from($table), $columns)

# Convenience wrapper for single column primary key
validate_primary_key(source::Union{FunSQL.SQLQuery, Symbol}, column::Symbol) =
    validate_primary_key($source, [$column])

# Validate primary key across multiple sources (tables)
validate_primary_key(sources::Vector, columns) =
    append(args = $[
        @funsql(validate_primary_key($source, $columns))
        for source in sources
    ])

""" validate_foreign_key(source, source_columns, target, target_columns)

validate foreign key relationships between source and target tables,
returning metrics about referential integrity and cardinality
"""
validate_foreign_key(source::FunSQL.SQLQuery, source_columns::Vector{Symbol},
                     target::FunSQL.SQLQuery, target_columns::Vector{Symbol}) = begin
    join(
        source => $source.group($(source_columns...)).define(is_present => true),
        on = true)
    join(
        target => $target.group($(target_columns...)).define(is_present => true),
        on = and(args = $[
            @funsql(source.$source_column == target.$target_column)
            for (source_column, target_column)
            in zip(source_columns, target_columns)
        ]),
        left = true,
        right = true)
    define(
        source_is_present => coalesce(source.is_present, false),
        source_key_is_not_null => and(args = $[
            @funsql(is_not_null(source.$source_column))
            for source_column in source_columns
        ]),
        target_is_present => coalesce(target.is_present, false),
        target_key_is_not_null => and(args = $[
            @funsql(is_not_null(target.$target_column))
            for target_column in target_columns
        ]))
    group()
    define(
        foreign_key => $(_foreign_key_name(source, source_columns,
                                          target, target_columns)),
        is_valid => coalesce(!bool_or(source_key_is_not_null &&
                                     !target_is_present), true),
        n => sum(source.count()),           # Total source records
        n_linked => sum(source.count(), filter = target_is_present),
        n_bad => sum(source.count(),
            filter = source_key_is_not_null && !target_is_present),
        ndv_bad => nullif(count(
            filter = source_key_is_not_null && !target_is_present), 0),
        n_tgt => sum(target.count()),       # Total target records
        n_tgt_linked => sum(target.count(), filter = source_is_present),
        med_card => median(source.count(), filter = target_is_present),
        max_card => max(source.count(), filter = target_is_present))
    define(pct_linked => floor(100 * n_linked / n), after = n_linked)
    define(pct_bad => floor(100 * n_bad / n), after = n_bad)
    define(pct_tgt_linked => floor(100 * n_tgt_linked / n_tgt),
        after = n_tgt_linked)
end

# Convenience wrapper for single column foreign keys
validate_foreign_key(source::Union{FunSQL.SQLQuery, Symbol},
                     source_column::Symbol,
                     target::Union{FunSQL.SQLQuery, Symbol},
                     target_column::Symbol) =
    validate_foreign_key($source, [$source_column], $target, [$target_column])

# Convenience wrapper for source query with target table symbol
validate_foreign_key(source::Union{FunSQL.SQLQuery, Symbol},
                     source_columns::Vector{Symbol},
                     target_table::Symbol,
                     target_columns::Vector{Symbol}) =
    validate_foreign_key($source, $source_columns,
                         from($target_table), $target_columns)

# Convenience wrapper for source table symbol with target query
validate_foreign_key(source_table::Symbol,
                     source_columns::Vector{Symbol},
                     target::FunSQL.SQLQuery,
                     target_columns::Vector{Symbol}) =
    validate_foreign_key(from($source_table), $source_columns,
                         $target, $target_columns)

# Validate foreign key across multiple source tables
validate_foreign_key(sources::Vector, source_columns, target, target_columns) =
    append(args = $[
        @funsql(validate_foreign_key($source, $source_columns,
                                     $target, $target_columns))
        for source in sources
    ])

# Convenience wrapper when target columns match source columns
validate_foreign_key(source, source_columns, target) =
    validate_foreign_key($source, $source_columns, $target, $source_columns)

end

function _primary_key_name(source, columns)
    table = FunSQL.label(source)
    if length(columns) == 1
        "$(table).$(columns[1])"
    else
        "$(table) ($(join(string.(columns), ", ")))"
    end
end

function _foreign_key_name(source, source_columns, target, target_columns)
    source_table = FunSQL.label(source)
    target_table = FunSQL.label(target)
    if length(source_columns) == length(target_columns) == 1
        "$(source_table).$(source_columns[1]) → $(target_table).$(target_columns[1])"
    else
        source_cols = join(string.(source_columns), ", ")
        target_cols = join(string.(target_columns), ", ")
        "$(source_table) ($(source_cols)) → $(target_table) ($(target_cols))"
    end
end

end
