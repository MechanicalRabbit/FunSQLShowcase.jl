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


"""
    PlutoSidebar(title = "Table of Contents", index = false)

Add a collapsible sidebar that displays the table of contents.

- `title`: The heading at the top of the sidebar.
- `index`: If true, include links to all notebooks listed in `pluto_export.json`.

To ensure that the table of contents is consistent across all notebooks in
`pluto_export.json`, each notebook must contain exactly one H1 heading that
should also match the title specified in the notebook's frontmatter.
"""
struct PlutoSidebar
    title::String
    index::Bool

    PlutoSidebar(; title = "Table of Contents", index = false) =
        new(title, index)
end

Base.show(io::IO, mime::MIME"text/html", sidebar::PlutoSidebar) =
    show(io, mime, convert(HypertextLiteral.Result, sidebar))

convert(::Type{HypertextLiteral.Result}, sidebar::PlutoSidebar) =
    # Adapted from https://github.com/JuliaPluto/PlutoUI.jl/blob/main/src/TableOfContents.jl
    @htl """
    <style>
      .pluto-funsql-sidebar {
        position: sticky;
        top: 0;
        margin-right: 1rem;
        padding-left: 1rem;
        width: 17rem;
        max-height: 100svh;
        flex: 0 0 auto;
        font-size: 14.5px;
        font-weight: 400;
        z-index: 40;
        overflow: auto;
        font-family: var(--system-ui-font-stack);
        background: var(--main-bg-color);
      }

      @media print {
        .pluto-funsql-sidebar {
          display: none;
        }
      }

      .pluto-funsql-sidebar-hidden {
        margin-left: -14.5rem;
      }

      .pluto-funsql-sidebar > nav {
        position: sticky;
        top: 1rem;
        margin: 1rem 0;
        padding: 1em;
        border-radius: 1rem;
        color: var(--pluto-output-color);
        background-color: var(--main-bg-color);
        --main-bg-color: #fafafa;
        --pluto-output-color: hsl(0, 0%, 36%);
        --pluto-output-h-color: hsl(0, 0%, 21%);
        --sidebar-li-active-bg: rgb(235, 235, 235);
        --icon-filter: unset;
      }

      @media (prefers-color-scheme: dark) {
        .pluto-funsql-sidebar > nav {
          --main-bg-color: #303030;
          --pluto-output-color: hsl(0, 0%, 90%);
          --pluto-output-h-color: hsl(0, 0%, 97%);
          --sidebar-li-active-bg: rgb(82, 82, 82);
          --icon-filter: invert(1);
        }
      }

      .pluto-funsql-sidebar > nav > header {
        display: flex;
        align-items: center;
        gap: 0.8rem;
        font-variant-caps: petite-caps;
        color: var(--pluto-output-h-color);
      }

      .pluto-funsql-sidebar.pluto-funsql-sidebar-hidden > nav > header {
        flex-direction: row-reverse;
        margin-bottom: 0;
      }

      .pluto-funsql-sidebar-toggle {
        cursor: pointer;
        display: flex;
      }

      .pluto-funsql-sidebar-toggle::before {
        content: "";
        display: inline-block;
        height: 1.2em;
        width: 1.2em;
        background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LW88L3RpdGxlPjxsaW5lIHgxPSIxNjAiIHkxPSIxNDQiIHgyPSI0NDgiIHkyPSIxNDQiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDozMnB4Ii8+PGxpbmUgeDE9IjE2MCIgeTE9IjI1NiIgeDI9IjQ0OCIgeTI9IjI1NiIgc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzAwMDtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLXdpZHRoOjMycHgiLz48bGluZSB4MT0iMTYwIiB5MT0iMzY4IiB4Mj0iNDQ4IiB5Mj0iMzY4IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6MzJweCIvPjxjaXJjbGUgY3g9IjgwIiBjeT0iMTQ0IiByPSIxNiIgc3R5bGU9ImZpbGw6bm9uZTtzdHJva2U6IzAwMDtzdHJva2UtbGluZWNhcDpyb3VuZDtzdHJva2UtbGluZWpvaW46cm91bmQ7c3Ryb2tlLXdpZHRoOjMycHgiLz48Y2lyY2xlIGN4PSI4MCIgY3k9IjI1NiIgcj0iMTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDozMnB4Ii8+PGNpcmNsZSBjeD0iODAiIGN5PSIzNjgiIHI9IjE2IiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6MzJweCIvPjwvc3ZnPg==");
        background-size: 1.2em;
        filter: var(--icon-filter);
      }

      .pluto-funsql-sidebar-toggle:hover::before {
        background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LWE8L3RpdGxlPjxwb2x5bGluZSBwb2ludHM9IjI0NCA0MDAgMTAwIDI1NiAyNDQgMTEyIiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6NDhweCIvPjxsaW5lIHgxPSIxMjAiIHkxPSIyNTYiIHgyPSI0MTIiIHkyPSIyNTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDo0OHB4Ii8+PC9zdmc+");
      }

      .pluto-funsql-sidebar-hidden .pluto-funsql-sidebar-toggle:hover::before {
        background-image: url("data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MTIiIGhlaWdodD0iNTEyIiB2aWV3Qm94PSIwIDAgNTEyIDUxMiI+PHRpdGxlPmlvbmljb25zLXY1LWE8L3RpdGxlPjxwb2x5bGluZSBwb2ludHM9IjI2OCAxMTIgNDEyIDI1NiAyNjggNDAwIiBzdHlsZT0iZmlsbDpub25lO3N0cm9rZTojMDAwO3N0cm9rZS1saW5lY2FwOnJvdW5kO3N0cm9rZS1saW5lam9pbjpyb3VuZDtzdHJva2Utd2lkdGg6NDhweCIvPjxsaW5lIHgxPSIzOTIiIHkxPSIyNTYiIHgyPSIxMDAiIHkyPSIyNTYiIHN0eWxlPSJmaWxsOm5vbmU7c3Ryb2tlOiMwMDA7c3Ryb2tlLWxpbmVjYXA6cm91bmQ7c3Ryb2tlLWxpbmVqb2luOnJvdW5kO3N0cm9rZS13aWR0aDo0OHB4Ii8+PC9zdmc+");
      }

      .pluto-funsql-sidebar > nav > section {
        padding-top: 1em;
        margin-top: 1em;
        margin-bottom: 1em;
        border-top: 2px dotted var(--pluto-output-color);
      }

      .pluto-funsql-sidebar-hidden > nav > section {
        display: none;
      }

      .pluto-funsql-sidebar > nav > section > ul {
        list-style: none;
        padding: 0;
        margin: 0;
      }

      .pluto-funsql-sidebar > nav > section > ul > li {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        border-radius: 0.5em;
      }

      .pluto-funsql-sidebar > nav > section > ul > li.pluto-funsql-sidebar-link-current {
        background: var(--sidebar-li-active-bg);
      }

      .pluto-funsql-sidebar a {
        text-decoration: none;
        color: var(--pluto-output-color);
      }

      .pluto-funsql-sidebar a:hover {
        color: var(--pluto-output-h-color);
      }

      .pluto-funsql-sidebar-link-H1 {
        margin-top: 0.5em;
        font-weight: 500;
        padding: 0 10px;
      }

      .pluto-funsql-sidebar-link-H2 {
        padding: 0 10px 0 20px;
      }

      .pluto-funsql-sidebar-link-H3 {
        padding: 0 10px 0 30px;
      }

      .pluto-funsql-sidebar > nav > section > p {
        padding: 0;
        margin: 0.5em 10px;
        font-style: italic;
      }
    </style>

    <aside class="pluto-funsql-sidebar" style="display: none">
      <nav>
        <header>
          <span class="pluto-funsql-sidebar-toggle"></span>
          <span class="pluto-funsql-sidebar-title">$(sidebar.title)</span>
        </header>
        <section><p>Loading Table of Contents&hellip;</p></section>
      </nav>
      <script>
        const cellNode = currentScript.closest("pluto-cell")
        const notebookNode = currentScript.closest("pluto-notebook")
        const editorNode = currentScript.closest("pluto-editor")
        const isStaticPreview = editorNode.classList.contains("static_preview")
        const sidebarNode = currentScript.parentElement
        const toggleNode = sidebarNode.querySelector(".pluto-funsql-sidebar-toggle")
        editorNode.parentElement.prepend(sidebarNode)
        sidebarNode.style.display = null

        const onToggle = () => {
          sidebarNode.classList.toggle("pluto-funsql-sidebar-hidden")
        }
        toggleNode.addEventListener("click", onToggle)

        const fetchExternalLinks = async () => {
          if (!$(sidebar.index)) {
            return [[], null]
          }
          try {
            if (!isStaticPreview) {
              throw(Error("In development, links to other notebooks are not available"))
            }
            const response = await fetch("pluto_export.json")
            if (!response.ok) {
              throw(Error(response.statusText))
            }
            const json = await response.json()
            let ns = Object.values(json.notebooks)
            ns.sort((a, b) => {
              const a_order = Number(a.frontmatter?.order)
              const b_order = Number(b.frontmatter?.order)
              if (isNaN(a_order) && isNaN(b_order)) {
                return a.id < b.id ? -1 : a.id > b.id ? 1 : 0
              }
              else if (isNaN(a_order)) {
                return 1
              }
              else if (isNaN(b_order)) {
                return -1
              }
              else {
                return a_order - b_order
              }
            })
            return [ns, null]
          }
          catch (err) {
            return [[], err]
          }
        }

        const [externalLinks, externalLinksError] = await fetchExternalLinks()

        let currentLink = null;
        const hToLinkMap = new Map()
        const hIntersectingSet = new Set()
        const hObserver = new IntersectionObserver((entries) => {
          for (const entry of entries) {
            if (entry.isIntersecting) {
              hIntersectingSet.add(entry.target)
            }
            else {
              hIntersectingSet.delete(entry.target)
            }
          }
          let nextCurrentLink = null
          for (const [h, liNode] of hToLinkMap) {
            if (!h || hIntersectingSet.has(h)) {
              nextCurrentLink = liNode
            }
            if (nextCurrentLink !== currentLink) {
              if (currentLink) {
                currentLink.classList.remove("pluto-funsql-sidebar-link-current")
              }
              if (nextCurrentLink) {
                nextCurrentLink.classList.add("pluto-funsql-sidebar-link-current")
              }
              currentLink = nextCurrentLink
            }
          }
        }, { rootMargin: "1000000px 0px -75% 0px" })

        const makeInternalLinks = () => {
          const links = []
          hObserver.disconnect()
          hToLinkMap.clear()
          hIntersectingSet.clear()
          currentLink = null
          const hs = Array.from(notebookNode.querySelectorAll("pluto-cell h1, pluto-cell h2, pluto-cell h3"))
          for (const h of hs) {
            const aNode = document.createElement("a")
            const id = h.closest("pluto-cell").id
            aNode.href = `#\${id}`
            aNode.title = h.innerText
            aNode.innerHTML = h.innerHTML
            const liNode = html`<li class="pluto-funsql-sidebar-link-\${h.tagName} pluto-funsql-sidebar-link-internal">\${aNode}</li>`
            links.push(liNode)
            hToLinkMap.set(h, liNode)
            hObserver.observe(h)
          }
          return links
        }

        const makeLinks = () => {
          const currentPath = window.location.pathname.split("/").pop() || "index.html"
          let links = []
          let hasInternal = false
          for (const l of externalLinks) {
            if (l.html_path == currentPath) {
              links = links.concat(makeInternalLinks())
              hasInternal = true
            }
            else {
              const title = l.frontmatter.title ?? l.id.replace(/\\.jl\$/, "")
              const aNode = document.createElement("a")
              aNode.href = l.html_path == "index.html" ? "./" : l.html_path
              aNode.innerText = aNode.title = title
              links.push(html`<li class="pluto-funsql-sidebar-link-H1">\${aNode}</li>`)
            }
          }
          if (!hasInternal) {
            links = links.concat(makeInternalLinks())
          }
          return links
        }

        const updateLinks = () => {
          const sectionNode = document.createElement("section")
          const links = makeLinks()
          if (links.length > 0) {
            sectionNode.append(html`<ul>\${links}</ul>`)
          }
          if (externalLinksError) {
            const pNode = document.createElement("p")
            pNode.innerText = externalLinksError.message
            sectionNode.append(pNode)
          }
          sidebarNode.querySelector("section").replaceWith(sectionNode)
        }

        updateLinks()

        const cellObservers = []

        const updateCellObservers = () => {
          cellObservers.forEach((o) => o.disconnect())
          cellObservers.length = 0
          for (const node of notebookNode.getElementsByTagName("pluto-cell")) {
            const o = new MutationObserver(updateLinks)
            o.observe(node, { attributeFilter: ["class"] })
            cellObservers.push(o)
          }
        }

        updateCellObservers()

        const notebookObserver = new MutationObserver(() => {
          updateLinks()
          updateCellObservers()
        })

        notebookObserver.observe(notebookNode, { childList: true })

        invalidation.then(() => {
          hObserver.disconnect()
          cellObservers.forEach((o) => o.disconnect())
          notebookObserver.disconnect()
          toggleNode.removeEventListener("click", onToggle)
          sidebarNode.remove()
        })
      </script>
    </aside>
    """


"""
    PlutoIndex()

Display a list of notebooks loaded from `pluto_export.json`.  Each list
entry shows the notebook's title and description, which can be edited in
the notebook's frontmatter.
"""
struct PlutoIndex
end

Base.show(io::IO, mime::MIME"text/html", index::PlutoIndex) =
    show(io, mime, convert(HypertextLiteral.Result, index))

convert(::Type{HypertextLiteral.Result}, ::PlutoIndex) =
    @htl """
    <style>
      .pluto-funsql-index {
        font-family: var(--system-ui-font-stack);
        padding: 1rem;
        margin: 1rem 0;
        border-radius: 1rem;
        color: var(--pluto-output-color);
        background-color: var(--main-bg-color);
        --main-bg-color: #fafafa;
        --pluto-output-color: hsl(0, 0%, 36%);
        --pluto-output-h-color: hsl(0, 0%, 21%);
        --sidebar-li-active-bg: rgb(235, 235, 235);
      }

      @media (prefers-color-scheme: dark) {
        .pluto-funsql-index {
          --main-bg-color: #303030;
          --pluto-output-color: hsl(0, 0%, 90%);
          --pluto-output-h-color: hsl(0, 0%, 97%);
          --sidebar-li-active-bg: rgb(82, 82, 82);
        }
      }

      .pluto-funsql-index > section > ol {
        font-weight: 500;
        margin: 0;
      }

      .pluto-funsql-index > section > ol > li {
        margin: 0.5em 0;
      }

      .pluto-funsql-index li a {
        display: inline-flex;
        flex-direction: column;
        text-decoration: none;
        color: var(--pluto-output-color);
      }

      .pluto-funsql-index li a:hover {
        color: var(--pluto-output-h-color);
      }

      .pluto-funsql-index li small {
        font-weight: 400;
      }

      .pluto-funsql-index > section > p {
        padding: 0;
        margin: 0.5em 10px;
        font-style: italic;
      }
    </style>

    <nav class="pluto-funsql-index">
      <section><p>Loading notebook index&hellip;</p></section>
      <script>
        const navNode = currentScript.closest("nav")

        const fetchExternalLinks = async () => {
          try {
            if (!window.pluto_disable_ui) {
              throw(Error("In development, notebook index is not available"))
            }
            const response = await fetch("pluto_export.json")
            if (!response.ok) {
              throw(Error(response.statusText))
            }
            const json = await response.json()
            let ns = Object.values(json.notebooks)
            ns.sort((a, b) => {
              const a_order = Number(a.frontmatter?.order)
              const b_order = Number(b.frontmatter?.order)
              if (isNaN(a_order) && isNaN(b_order)) {
                return a.id < b.id ? -1 : a.id > b.id ? 1 : 0
              }
              else if (isNaN(a_order)) {
                return 1
              }
              else if (isNaN(b_order)) {
                return -1
              }
              else {
                return a_order - b_order
              }
            })
            return [ns, null]
          }
          catch (err) {
            return [[], err]
          }
        }

        const [externalLinks, externalLinksError] = await fetchExternalLinks()

        const makeLinks = () => {
          const currentPath = window.location.pathname.split("/").pop() || "index.html"
          let links = []
          for (const l of externalLinks) {
            const title = l.frontmatter.title ?? n.id.replace(/\\.jl\$/, "")
            const description = l.frontmatter.description
            const current = l.html_path == currentPath
            const aNode = document.createElement("a")
            aNode.href = l.html_path == "index.html" ? "./" : l.html_path
            aNode.innerText = aNode.title = title
            if (current) {
              aNode.classList.add("pluto-funsql-index-current")
            }
            if (description) {
              const smallNode = document.createElement("small")
              smallNode.innerText = description
              aNode.append(smallNode)
            }
            links.push(html`<li>\${aNode}</li>`)
          }
          return links
        }

        const sectionNode = document.createElement("section")
        const links = makeLinks()
        if (links.length > 0) {
          sectionNode.append(html`<ol>\${links}</ol>`)
        }
        if (externalLinksError) {
          const pNode = document.createElement("p")
          pNode.innerText = externalLinksError.message
          sectionNode.append(pNode)
        }
        navNode.querySelector("section").replaceWith(sectionNode)
      </script>
    </nav>
    """
