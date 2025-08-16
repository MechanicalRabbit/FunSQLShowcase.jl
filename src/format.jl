# Custom Pluto formatter for DataFrame objects.

module PlutoCustomFormat

using DataFrames
using HypertextLiteral
using Tables

const CustomFormatType = Union{AbstractDataFrame}

function format_output(df::AbstractDataFrame; context)
    buf = IOBuffer(sizehint = 0)
    io = IOContext(buf, context)
    mime = MIME"text/html"()
    htl = _format_table(Tables.rows(df))
    show(io, mime, htl)
    return (String(take!(buf)), mime)
end

function _format_table(t)
    @htl """
    <figure class="pluto-funsql-table pluto-funsql-scroll">
    <table>
    $(_format_table_caption(t))
    $(_format_table_thead(t))
    $(_format_table_tbody(t))
    </table>
    $(_format_table_style(t))
    </figure>
    """
end

function _format_table_caption(t)
end

function _format_table_thead(t)
    names = Tables.columnnames(t)
    @htl """
    <thead>
    <tr><th></th>$([@htl """<th scope="col">$name</th>""" for name in names])</tr>
    </thead>
    """
end

function _format_table_tbody(t; limit = 1000)
    w = length(Tables.columnnames(t))
    h = length(t)
    if h > 0
        if limit === nothing || h <= limit + 5
            indexes = collect(1:h)
        else
            indexes = collect(1:limit)
            push!(indexes, 0, h)
        end
        @htl """
        $([i != 0 ? _format_table_row(t, i) : _format_table_ellipsis(w) for i in indexes])
        """
    else
        @htl """
        <tbody>
        <tr><td colspan="$(w + 1)" class="pluto-funsql-empty"><div>⌀<small>(This table has no rows)</small></div></td></tr>
        </tbody>
        """
    end
end

function _format_table_row(t, i)
    @htl """
    <tr tabindex="-1"><th scope="row">$i</th>$([_format_table_cell(v) for v in t[i]])</tr>
    """
end

function _format_table_cell(v)
    if v === missing
        @htl """<td class="pluto-funsql-missing"></td>"""
    elseif v isa Number
        @htl """<td class="pluto-funsql-number">$(sprint(print, v; context = :compact => true))</td>"""
    else
        @htl """<td>$v</td>"""
    end
end

function _format_table_ellipsis(w)
    @htl """
    <tr><th class="pluto-funsql-ellipsis">⋮</td>$(w > 0 ? @htl("""<td colspan="$w"></td>""") : "")</tr>
    """
end

function _format_table_style(t)
    @htl """
    <style>
    .pluto-funsql-table > table { width: max-content; }
    .pluto-funsql-table > table > caption { padding: .2rem .5rem; }
    .pluto-funsql-table > table > thead > tr > th { vertical-align; baseline; }
    .pluto-funsql-table > table > tbody > tr:first-child > th { border-top: 1px solid var(--table-border-color); }
    .pluto-funsql-table > table > tbody > tr:first-child > td { border-top: 1px solid var(--table-border-color); }
    .pluto-funsql-table > table > tbody > tr > th { vertical-align: baseline; }
    .pluto-funsql-table > table > tbody > tr > td { max-width: 300px; vertical-align: baseline; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .pluto-funsql-table > table > tbody > tr > td.pluto-funsql-number { text-align: right; }
    .pluto-funsql-table > table > tbody > tr > td.pluto-funsql-empty > div { display: flex; flex-direction: column; align-items: center; font-size: 1.5rem; }
    .pluto-funsql-table > table > tbody > tr > td.pluto-funsql-empty > div > small { font-size: 0.5rem; }
    .pluto-funsql-table > table > tbody > tr:focus > td { overflow: unset; text-overflow: unset; white-space: unset; }
    .pluto-funsql-table > table > thead > tr > th { position: sticky; top: -1px; background: var(--main-bg-color); background-clip: padding-box; z-index: 1; }
    .pluto-funsql-table > table > thead > tr > th:first-child { position: sticky; left: -10px; background: var(--main-bg-color); background-clip: padding-box; z-index: 2; }
    .pluto-funsql-table > table > tbody > tr > th:first-child { position: sticky; left: -10px; background: var(--main-bg-color); background-clip: padding-box; }
    .pluto-funsql-scroll { max-height: 502px; overflow: auto; will-change: scroll-position; }
    </style>
    """
end

end
