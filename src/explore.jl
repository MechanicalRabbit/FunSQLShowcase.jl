function explore(db, table::Symbol)
    query = @funsql(from($table).summary(exact=true))
    result = PlutoFunSQL.query(db, query)
    @htl("""
        <div>$result</div>
    """)
end


# Helpers to build notebook fragments for tables.

struct NotebookCell
    uuid::UUID
    text::String
    visible::Bool
end

NotebookCell(id::String, text::String; visible=true) =
    NotebookCell(uuid5(uuid_ns, id), text, visible)

const uuid_ns = UUID("4c43ef92-fccd-430d-bda2-68b1f98aa576")
const cell_prefix = "# ╔═╡ "
const visible_prefix = "# ╠═"
const hidden_prefix = "# ╟─"

function build_explore_cells(db::Symbol, conn::T) where T <: FunSQL.SQLConnection
    tables = [string(t) for t in sort(collect(keys(conn.catalog)))]
    cells = NotebookCell[]
    for name in tables
        push!(cells, NotebookCell(name, """md"### $name"\n"""; visible=false))
        push!(cells, NotebookCell(name * "e", "PlutoFunSQL.explore($db, :$name)\n"))
    end
    retval = [cell_prefix * string(t.uuid) * "\n" * t.text * "\n" for t in cells]
    append!(retval, [ (t.visible ? visible_prefix : hidden_prefix) *
                          string(t.uuid)* "\n" for t in cells])
    println(join(retval))
end
