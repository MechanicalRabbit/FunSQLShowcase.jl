# Custom layout for Pluto notebooks.

"""
    PlutoFluid()

Expand Pluto to span the full width of the screen.

When this widget is rendered, the notebook content is moved to the left
edge of the screen.  Output cells are styled to favor prose-friendly width
but can expand to the right up to the screen edge.  This layout works best
with a sidebar on the left.
"""
struct PlutoFluid
end

Base.show(io::IO, mime::MIME"text/html", fluid::PlutoFluid) =
    show(io, mime, convert(HypertextLiteral.Result, fluid))

convert(::Type{HypertextLiteral.Result}, ::PlutoFluid) =
    @htl """
    <style>
      pluto-editor > header#pluto-nav, pluto-editor > footer {
        width: calc(100% - 1rem);
        margin-left: 1rem;
      }

      pluto-editor > main {
        max-width: unset;
        padding-right: 3rem;
        margin-right: 0;
        --prose-width: 800px;
      }

      pluto-output {
        min-width: min(100%, var(--prose-width));
        width: min-content;
        max-width: 100%;
      }

      pluto-output figure {
        margin-block-start: 0;
        margin-block-end: var(--pluto-cell-spacing);
        display: flex;
        flex-direction: column;
        align-items: center;
      }

      pluto-output figure:first-child {
        margin-block-start: 0;
      }

      pluto-output figure:last-child {
        margin-block-end: 0;
      }

      pluto-output figure img {
        max-width: unset;
      }
    """
