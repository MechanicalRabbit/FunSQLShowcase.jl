function query_macro(__module__, __source__, db, q)
    db = esc(db)
    ex = FunSQL.transliterate(q, FunSQL.TransliterateContext(__module__, __source__))
    return quote
        PlutoFunSQL.DataFrames.DataFrame(
            PlutoFunSQL.DBInterface.execute($db, $ex))
    end
end

macro query(db, q)
    return query_macro(__module__, __source__, db, q)
end
