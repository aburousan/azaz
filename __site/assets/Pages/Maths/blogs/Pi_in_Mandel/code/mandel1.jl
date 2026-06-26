# This file was generated, do not modify it. # hide
function mandel_check(c,max_ita=1000)
    z = 0
    for i in 1:max_ita
        z = z^2 + c
        if abs(z) >= 2
            print(c," is not in mandelbrot set upto set iter no.")
            break
        else
            if i==max_ita && abs(z)<2
                print(c," is in mandelbrot set upto set iter no.")
            end
        end
    end
end
mandel_check(1)