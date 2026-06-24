module FormWrapper

using FORM_jll

export evaluate_form

"""
    evaluate_form(script::String)

Executes a FORM script passed as a string using the `form` binary provided by `FORM_jll`.
Automatically appends `Print +s;` and `.end` to the script.
Returns the standard output of the FORM execution as a String.
"""
function evaluate_form(script::String)
    # We append 'Off statistics;' to hide execution times, 'Print +s;' to print each term on a new line, and '.end' to terminate the FORM script.
    full_script = "Off statistics;\n" * script * "\nPrint +s;\n.end\n"
    
    # Create a temporary directory to store our script file safely
    mktempdir() do dir
        frm_path = joinpath(dir, "calc.frm")
        
        # Write our FORM code to the temporary file
        write(frm_path, full_script)
        
        out = IOBuffer()
        
        # form() provides the path to the FORM executable.
        # We run it in quiet mode (-q) to suppress startup text, and capture the output.
        form() do form_exe
            run(pipeline(`$form_exe -q $frm_path`, stdout=out))
        end
        
        # Convert the captured bytes into a Julia String and return it
        return String(take!(out))
    end
end

end # module
