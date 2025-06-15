# Wrapper over DBInterface.Connection that uses DataFrame as a cursor.

struct DataFrameConnection{WrappedConnType} <: DBInterface.Connection
    wrapped::WrappedConnType

    DataFrameConnection{WrappedConnType}(wrapped::WrappedConnType) where {WrappedConnType} =
        new{WrappedConnType}(wrapped)
end

DataFrameConnection(wrapped::WrappedConnType) where {WrappedConnType} =
    DataFrameConnection{WrappedConnType}(wrapped)

function Base.show(io::IO, conn::DataFrameConnection)
    print(io, "DataFrameConnection(")
    show(io, conn.wrapped)
    print(io, ")")
end

struct DataFrameStatement{WrappedConnType, WrappedStmtType} <: DBInterface.Statement
    conn::DataFrameConnection{WrappedConnType}
    wrapped::WrappedStmtType

    DataFrameStatement{WrappedConnType, WrappedStmtType}(conn::DataFrameConnection{WrappedConnType}, wrapped::WrappedStmtType) where {WrappedConnType, WrappedStmtType} =
        new(conn, wrapped)
end

DataFrameStatement(conn::DataFrameConnection{WrappedConnType}, stmt::WrappedStmtType) where {WrappedConnType, WrappedStmtType} =
    DataFrameStatement{WrappedConnType, WrappedStmtType}(conn, stmt)

function Base.show(io::IO, stmt::DataFrameStatement)
    print(io, "DataFrameStatement(")
    show(io, stmt.conn)
    print(io, ", ")
    show(io, stmt.wrapped)
    print(io, ")")
end

const DataFrameSQLType = Union{FunSQL.SQLQuery, FunSQL.SQLSyntax, AbstractString}

function DBInterface.connect(::Type{DataFrameConnection{WrappedConnType}}, args...; kws...) where {WrappedConnType}
    wrapped = DBInterface.connect(WrappedConnType, args...; kws...)
    DataFrameConnection(wrapped)
end

DBInterface.prepare(conn::DataFrameConnection, sql::DataFrameSQLType) =
    DataFrameStatement(conn, DBInterface.prepare(conn.wrapped, sql))

DBInterface.execute(conn::DataFrameConnection, sql::DataFrameSQLType; params...) =
    DBInterface.execute(conn, sql, values(params))

DBInterface.execute(conn::DataFrameConnection, sql::DataFrameSQLType, params) =
    DBInterface.execute(DBInterface.prepare(conn, sql), params)

function DBInterface.execute(stmt::DataFrameStatement, params)
    cr = DBInterface.execute(stmt.wrapped, params)
    df = DataFrame(cr)
    DBInterface.close!(cr)
    df
end

DBInterface.getconnection(stmt::DataFrameStatement) =
    stmt.conn

DBInterface.close!(stmt::DataFrameStatement) =
    DBInterface.close!(stmt.wrapped)

DBInterface.close!(::DataFrame) =
    nothing
