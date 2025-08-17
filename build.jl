using PlutoSliderServer

function notebook_order(root, path)
    fm = PlutoSliderServer.Pluto.frontmatter(joinpath(root, path))
    order_s = get(fm, "order", nothing)
    order = typemax(Int)
    if order_s isa String
        order = something(tryparse(Int, order_s), order)
    end
    order
end

const notebook_paths =
    sort(PlutoSliderServer.find_notebook_files_recursive("examples"), by = Base.Fix1(notebook_order, "examples"))
const Export_output_dir = "build"
const Export_cache_dir = "cache"
const Export_offer_binder = false

PlutoSliderServer.export_directory("examples"; notebook_paths, Export_output_dir, Export_cache_dir, Export_offer_binder)
