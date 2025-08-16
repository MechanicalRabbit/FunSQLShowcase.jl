module PlutoRunnerExt

using FunSQLShowcase

function __init__()
    # Enable custom Pluto formatters defined in FunSQLShowcase.
    @eval begin
        function Main.PlutoRunner.format_output(val::FunSQLShowcase.PlutoCustomFormat.CustomFormatType; context = Main.PlutoRunner.default_iocontext)::Main.PlutoRunner.MimedOutput
            try
                FunSQLShowcase.PlutoCustomFormat.format_output(val; context)
            catch ex
                title = ErrorException("Failed to show value: \n" * sprint(Main.PlutoRunner.try_showerror, ex))
                bt = stacktrace(catch_backtrace())
                Main.PlutoRunner.format_output(CapturedException(title, bt))
            end
        end
    end
end

end
