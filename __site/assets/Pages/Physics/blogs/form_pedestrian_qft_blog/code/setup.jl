# This file was generated, do not modify it. # hide
using FORM_jll

function evaluate_form(script::String)
    # We append 'Format 255;' to use the full horizontal width, 'Off statistics;' to hide execution times, and '.end' to terminate the FORM script.
    full_script = "Format 255;\nOff statistics;\n" * script * "\nPrint;\n.end\n"
    
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