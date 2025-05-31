function query_macro(__module__, __source__, db, q)
    db = esc(db)
    ex = FunSQL.transliterate(q, FunSQL.TransliterateContext(__module__, __source__))
    return :(PlutoFunSQL.query($db, $ex))
end

macro query(expr)
    @dissect(expr, Expr(:tuple, (local db), (local q))) ||
       throw(ArgumentError("@query has two args, the connection and the query"))
    return query_macro(__module__, __source__, db, q)
end

function query(database, query)
    PlutoFunSQL.DataFrames.DataFrame(
        PlutoFunSQL.DBInterface.execute(database, query))
end
