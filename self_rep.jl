# # using HTTP
# # using DataFrames
# # using CSV

# # function fetch_gaia_data(query::String)
# #     url = "https://gea.esac.esa.int/tap-server/tap/sync"
# #     params = Dict(
# #         "REQUEST" => "doQuery",
# #         "LANG" => "ADQL",
# #         "FORMAT" => "csv",
# #         "QUERY" => query
# #     )
# #     encoded_params = join(["$k=$(HTTP.escapeuri(v))" for (k, v) in params], "&")
# #     response = HTTP.post(url, ["Content-Type" => "application/x-www-form-urlencoded"], encoded_params)
# #     if response.status == 200
# #         data = CSV.read(IOBuffer(response.body), DataFrame)
# #         return data
# #     else
# #         error("Error: ", response.status, "\n", String(response.body))
# #     end
# # end

# # function filter_missing_values(df::DataFrame)
# #     clean_data = dropmissing(df)
# #     return clean_data
# # end

# # query = """
# # SELECT TOP 10
# #     source_id,
# #     ra,
# #     dec,
# #     parallax,
# #     phot_g_mean_mag
# # FROM gaiadr3.gaia_source
# # WHERE ra BETWEEN 0 AND 10
# #   AND dec BETWEEN -10 AND 10
# # """

# # query1 = """
# # SELECT
# #     source_id,
# #     ra,
# #     dec,
# #     parallax,
# #     phot_g_mean_mag
# # FROM gaiadr3.gaia_source
# # WHERE ra BETWEEN 0 AND 100
# #   AND dec BETWEEN -30 AND 30
# # """

# # function filter_missing_values(df::DataFrame)
# #     # Filter rows containing missing values
# #     clean_data = dropmissing(df)
# #     return clean_data
# # end


# # data = fetch_gaia_data(query1)
# # dat_fil = filter_missing_values(data)
# # println(dat_fil)

# # using Symbolics
# # using SymbolicNumericIntegration
# # @variables x

# # # Define the inner product function for the Legendre polynomials
# # function inner_product(f, g, a ,b, w)
# #     return integrate(f * g * w, (x, a, b); detailed=false, symbolic = true)
# # end

# # # Gram-Schmidt process to orthogonalize a set of functions
# # function gram_schmidt(funcs,a,b;w=1)
# #     orthogonal_polynomials = []

# #     for i in 1:length(funcs)
# #         # Start with the current function
# #         f_i = funcs[i]
        
# #         # Subtract the projection onto the previous polynomials
# #         for j in 1:(i-1)
# #             proj = inner_product(orthogonal_polynomials[j], f_i, a,b,w) /
# #                    inner_product(orthogonal_polynomials[j], orthogonal_polynomials[j], a,b,w)
# #             f_i -= simplify(proj * orthogonal_polynomials[j])
# #         end

# #         # Store the orthogonal polynomial without normalization
# #         push!(orthogonal_polynomials, simplify(f_i))
# #     end

# #     return orthogonal_polynomials
# # end

# # function find_min_coeff(p)
# #     h = [p.coeff(x,i) for i in 0:degree(p)]
# #     h = filter(k -> k != 0, h)
# #     return h[1]
# # end

# # function last_val(p)
# #     aa = p/find_min_coeff(p)
# #     return simplify(aa)   
# # end
# # # Define the monomials (1, x, x^2, x^3, ...)
# # monomials = [x^i for i in 0:2]  # Generate up to x^3 (first four Legendre polynomials)

# # # Apply Gram-Schmidt to generate the Legendre polynomials
# # legendre_polynomials = gram_schmidt(monomials,-1,1;w=1/sqrt(1-x^2))

# # # Remove denominators from the polynomials
# # # legendre_polynomials = [p/find_min_coeff(p) for p in legendre_polynomials]
# # legendre_polynomials = last_val.(legendre_polynomials)

# # # Display the Legendre polynomials without fractional coefficients
# # for (i, poly) in enumerate(legendre_polynomials)
# #     println("P_$(i-1)(x) = $poly")
# # end

# using SymPy
# x = Sym("x")
# function inner_product(f, g, a ,b, w)
#     return integrate(f * g * w, (x, a, b))
# end

# function gram_schmidt(funcs,a,b;w=1)
#     orthogonal_polynomials = []

#     for i in 1:length(funcs)
#         # Start with the current function
#         f_i = funcs[i]
        
#         # Subtract the projection onto the previous polynomials
#         for j in 1:(i-1)
#             proj = inner_product(orthogonal_polynomials[j], f_i, a,b,w) /
#                    inner_product(orthogonal_polynomials[j], orthogonal_polynomials[j], a,b,w)
#             f_i -= simplify(proj * orthogonal_polynomials[j])
#         end

#         # Store the orthogonal polynomial without normalization
#         push!(orthogonal_polynomials, simplify(f_i))
#     end
#     fact1 = [sympy.poly(i,x) for i in orthogonal_polynomials]
#     fact = [p.coeffs()[length(p.coeffs())] for p in fact1]

#     return orthogonal_polynomials ./fact
# end

# function normalized(p,a,b,w)
#     k = inner_product(p,p,a,b,w)
#     return p/k
# end
# monomials = [x^i for i in 0:2]  # Generate up to x^3 (first four Legendre polynomials)

# # Apply Gram-Schmidt to generate the Legendre polynomials
# legendre_polynomials = gram_schmidt(monomials,-1,1;w=x^0)
# normalized(legendre_polynomials[1],1)
# leg_f = normalized.(legendre_polynomials,-1,1,1)

# normalized(legendre_polynomials[1],-1,1,1)