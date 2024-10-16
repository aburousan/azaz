# # # using HTTP
# # # using DataFrames
# # # using CSV

# # # function fetch_gaia_data(query::String)
# # #     url = "https://gea.esac.esa.int/tap-server/tap/sync"
# # #     params = Dict(
# # #         "REQUEST" => "doQuery",
# # #         "LANG" => "ADQL",
# # #         "FORMAT" => "csv",
# # #         "QUERY" => query
# # #     )
# # #     encoded_params = join(["$k=$(HTTP.escapeuri(v))" for (k, v) in params], "&")
# # #     response = HTTP.post(url, ["Content-Type" => "application/x-www-form-urlencoded"], encoded_params)
# # #     if response.status == 200
# # #         data = CSV.read(IOBuffer(response.body), DataFrame)
# # #         return data
# # #     else
# # #         error("Error: ", response.status, "\n", String(response.body))
# # #     end
# # # end

# # # function filter_missing_values(df::DataFrame)
# # #     clean_data = dropmissing(df)
# # #     return clean_data
# # # end

# # # query = """
# # # SELECT TOP 10
# # #     source_id,
# # #     ra,
# # #     dec,
# # #     parallax,
# # #     phot_g_mean_mag
# # # FROM gaiadr3.gaia_source
# # # WHERE ra BETWEEN 0 AND 10
# # #   AND dec BETWEEN -10 AND 10
# # # """

# # # query1 = """
# # # SELECT
# # #     source_id,
# # #     ra,
# # #     dec,
# # #     parallax,
# # #     phot_g_mean_mag
# # # FROM gaiadr3.gaia_source
# # # WHERE ra BETWEEN 0 AND 100
# # #   AND dec BETWEEN -30 AND 30
# # # """

# # # function filter_missing_values(df::DataFrame)
# # #     # Filter rows containing missing values
# # #     clean_data = dropmissing(df)
# # #     return clean_data
# # # end


# # # data = fetch_gaia_data(query1)
# # # dat_fil = filter_missing_values(data)
# # # println(dat_fil)

# # # using Symbolics
# # # using SymbolicNumericIntegration
# # # @variables x

# # # # Define the inner product function for the Legendre polynomials
# # # function inner_product(f, g, a ,b, w)
# # #     return integrate(f * g * w, (x, a, b); detailed=false, symbolic = true)
# # # end

# # # # Gram-Schmidt process to orthogonalize a set of functions
# # # function gram_schmidt(funcs,a,b;w=1)
# # #     orthogonal_polynomials = []

# # #     for i in 1:length(funcs)
# # #         # Start with the current function
# # #         f_i = funcs[i]
        
# # #         # Subtract the projection onto the previous polynomials
# # #         for j in 1:(i-1)
# # #             proj = inner_product(orthogonal_polynomials[j], f_i, a,b,w) /
# # #                    inner_product(orthogonal_polynomials[j], orthogonal_polynomials[j], a,b,w)
# # #             f_i -= simplify(proj * orthogonal_polynomials[j])
# # #         end

# # #         # Store the orthogonal polynomial without normalization
# # #         push!(orthogonal_polynomials, simplify(f_i))
# # #     end

# # #     return orthogonal_polynomials
# # # end

# # # function find_min_coeff(p)
# # #     h = [p.coeff(x,i) for i in 0:degree(p)]
# # #     h = filter(k -> k != 0, h)
# # #     return h[1]
# # # end

# # # function last_val(p)
# # #     aa = p/find_min_coeff(p)
# # #     return simplify(aa)   
# # # end
# # # # Define the monomials (1, x, x^2, x^3, ...)
# # # monomials = [x^i for i in 0:2]  # Generate up to x^3 (first four Legendre polynomials)

# # # # Apply Gram-Schmidt to generate the Legendre polynomials
# # # legendre_polynomials = gram_schmidt(monomials,-1,1;w=1/sqrt(1-x^2))

# # # # Remove denominators from the polynomials
# # # # legendre_polynomials = [p/find_min_coeff(p) for p in legendre_polynomials]
# # # legendre_polynomials = last_val.(legendre_polynomials)

# # # # Display the Legendre polynomials without fractional coefficients
# # # for (i, poly) in enumerate(legendre_polynomials)
# # #     println("P_$(i-1)(x) = $poly")
# # # end

# # using SymPy
# # x = Sym("x")
# # function inner_product(f, g, a ,b, w)
# #     return integrate(f * g * w, (x, a, b))
# # end

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
# #     fact1 = [sympy.poly(i,x) for i in orthogonal_polynomials]
# #     fact = [p.coeffs()[length(p.coeffs())] for p in fact1]

# #     return orthogonal_polynomials ./fact
# # end

# # function normalized(p,a,b,w)
# #     k = inner_product(p,p,a,b,w)
# #     return p/k
# # end
# # monomials = [x^i for i in 0:2]  # Generate up to x^3 (first four Legendre polynomials)

# # # Apply Gram-Schmidt to generate the Legendre polynomials
# # legendre_polynomials = gram_schmidt(monomials,-1,1;w=x^0)
# # normalized(legendre_polynomials[1],1)
# # leg_f = normalized.(legendre_polynomials,-1,1,1)

# # normalized(legendre_polynomials[1],-1,1,1)


# using Printf, Plots

# # Define the number of microstates (binomial coefficient) for a given N and k (number of heads)
# function omega(N::Int, k::Int)
#     return binomial(BigInt(N), BigInt(k))  # Use BigInt to prevent overflow
# end

# # Define temperature as d(log(omega))/dE
# function temperature(N, k)
#     if k == 0 || k == N
#         return Inf  # Avoid division by zero at boundaries
#     else
#         return 1 / (log(omega(N, k + 1)) - log(omega(N, k)))
#     end
# end

# # Entropy S = k_B * log(omega(E)) (here, we assume k_B = 1 for simplicity)
# function entropy(N, k)
#     return log(omega(N, k))
# end

# # Simulate the system and collect data for plotting
# function simulate_coin_toss(N)
#     energies = 0:N
#     microstates = [omega(N, k) for k in energies]
#     temperatures = [temperature(N, k) for k in energies]
#     entropies = [entropy(N, k) for k in energies]
#     return energies, microstates, temperatures, entropies
# end

# # Plot results
# function plot_results(N)
#     energies, microstates, temperatures, entropies = simulate_coin_toss(N)

#     # Plot microstates
#     plot(energies, microstates, label="Microstates (Ω)", xlabel="Energy (Number of Heads)", ylabel="Number of Microstates", lw=2)
#     savefig("microstates.png")  # Save the plot

#     # Plot temperature
#     plot(energies, temperatures, label="Temperature (T)", xlabel="Energy (Number of Heads)", ylabel="Temperature (T)", lw=2, color=:red)
#     savefig("temperature.png")  # Save the plot

#     # Plot entropy
#     plot(energies, entropies, label="Entropy (S)", xlabel="Energy (Number of Heads)", ylabel="Entropy (S)", lw=2, color=:green)
#     savefig("entropy.png")  # Save the plot

#     # Show all plots
#     plot!(layout = (3, 1), xlabel="Energy (Number of Heads)")
# end

# # Number of coins
# N = 1000  # You can now handle larger N due to BigInt

# # Plot results for N coins
# plot_results(N)


# #--------------------------------------------------------------------------------
# using Printf, Plots

# # Define the number of microstates (binomial coefficient) for a given N and k (number of heads)
# function omega(N::Int, k::Int)
#     return binomial(BigInt(N), BigInt(k))  # Use BigInt to avoid overflow
# end

# # Define temperature as d(log(omega))/dE
# function temperature(N, k)
#     # Handle edge cases for k
#     if k <= 0 || k >= N
#         return Inf  # Return infinity for boundary cases
#     end

#     try
#         # Attempt to calculate the temperature
#         temp = 1 / (log(omega(N, k + 1)) - log(omega(N, k)))

#         # Ensure temperature is positive
#         if temp < 0
#             println("Warning: Negative temperature calculated for N=$N, k=$k. Adjusting to positive.")
#             return 0.0  # Or return Inf or another value based on your needs
#         end

#         return temp
#     catch e
#         println("Error calculating temperature for N=$N, k=$k: $e")
#         return Inf  # Return infinity on error
#     end
# end

# # Simulate heat transfer between two systems
# function simulate_heat_transfer(N1, k1, N2, k2, max_steps)
#     T1_history = Float64[]  # Store temperature history of system 1
#     T2_history = Float64[]  # Store temperature history of system 2

#     for step in 1:max_steps
#         # Compute the temperature of both systems
#         T1 = temperature(N1, k1)
#         T2 = temperature(N2, k2)

#         # Append temperatures to the history
#         push!(T1_history, T1)
#         push!(T2_history, T2)

#         # Print temperatures for debugging
#         println("Step: $step, T1: $T1, T2: $T2, k1: $k1, k2: $k2")

#         # If both temperatures are not finite, break the loop
#         if !isfinite(T1) || !isfinite(T2)
#             println("Breaking due to non-finite temperatures at step $step: T1=$T1, T2=$T2")
#             break
#         end

#         # If the temperatures are close enough, stop the simulation (thermal equilibrium)
#         if abs(T1 - T2) < 1e-3
#             println("Reaching thermal equilibrium at step $step: T1=$T1, T2=$T2")
#             break
#         end

#         # Determine energy transfer based on temperature difference
#         energy_transfer = max(1, Int(floor(abs(T1 - T2) * 10)))  # Ensure energy_transfer is an integer

#         # Perform energy transfer while ensuring k1 and k2 remain valid
#         if T1 > T2
#             k1 = max(0, k1 - energy_transfer)  # System 1 loses energy
#             k2 = min(N2, k2 + energy_transfer)  # System 2 gains energy
#         elseif T2 > T1
#             k1 = min(N1, k1 + energy_transfer)  # System 1 gains energy
#             k2 = max(0, k2 - energy_transfer)  # System 2 loses energy
#         end

#         # Check for edge cases where k1 or k2 might go out of bounds
#         if k1 < 0 || k1 > N1 || k2 < 0 || k2 > N2
#             println("Invalid state reached: k1 = $k1, k2 = $k2")
#             break
#         end
#     end

#     return T1_history, T2_history
# end

# function plot_temperature_variation(T1_history, T2_history)
#     steps = 1:length(T1_history)
#     plot(steps, T1_history, label="System 1 Temperature", xlabel="Steps", ylabel="Temperature", lw=2, color=:blue)
#     plot!(steps, T2_history, label="System 2 Temperature", lw=2, color=:red)
#     savefig("temperature_equilibrium.png")
# end

# # Initial number of coins and heads (energy) in both systems
# N1 = 1000  # Number of coins in system 1
# k1 = 750   # Initial number of heads (energy level) in system 1
# N2 = 1000  # Number of coins in system 2
# k2 = 250   # Initial number of heads (energy level) in system 2

# # Simulate the heat transfer between the two systems
# max_steps = 2000  # Maximum number of steps in the simulation
# T1_history, T2_history = simulate_heat_transfer(N1, k1, N2, k2, max_steps)

# # Plot the temperature variation
# plot_temperature_variation(T1_history, T2_history)

# #-----------------------------------------------------------
# using Random, Printf

# # Define a new omega(E) for a more realistic system
# function omega(E)
#     return E^3  # Example: omega is proportional to E^3 for a system with multiple degrees of freedom.
# end

# # Define temperature using the relation: 1/kT = d(log(omega(E)))/dE
# function temperature(E)
#     g = x -> ForwardDiff.derivative(x -> log(omega(x)), x)
#     return 1 / g(E)
# end

# # Simulate heat transfer between two bodies
# function heat_transfer(E1, E2, k, steps)
#     println("Initial energy: E1 = $E1, E2 = $E2")

#     for step in 1:steps
#         # Randomly choose a small energy δ to transfer between the bodies
#         δE = 0.2

#         # Only transfer energy if the final energies are positive
#         if (E1 - δE >= 0) && (E2 + δE >= 0)
#             # Calculate initial temperatures
#             T1 = temperature(E1)
#             T2 = temperature(E2)

#             # Transfer the energy if the system entropy increases (i.e., heat flows from hot to cold)
#             if T1 > T2
#                 E1 -= δE
#                 E2 += δE
#             elseif T2 > T1
#                 E1 += δE
#                 E2 -= δE
#             end
#         end

#         # Print energies and temperatures after each step
#         @printf("Step %d: E1 = %.2f, E2 = %.2f, T1 = %.2f, T2 = %.2f\n", step, E1, E2, temperature(E1), temperature(E2))
#     end

#     return E1, E2
# end

# # Initial energy of body 1 and body 2
# E1 = 10.0
# E2 = 5.0

# # Boltzmann constant (can be set to 1 for simplicity)
# k = 1.0

# # Number of simulation steps
# steps = 100

# # Simulate heat transfer
# final_E1, final_E2 = heat_transfer(E1, E2, k, steps)

# println("Final energy: E1 = $final_E1, E2 = $final_E2")


# #-=----------------------------------------------------------------------------------------------------------
# #-------------------------------------------------------------------------------------------------------------

# using ForwardDiff
# using Plots
# function omega1(E)
#     return E^3
# end
# function omega2(E)
#     return E^4
# end
# function temperature1(E)
#     g = x -> ForwardDiff.derivative(x -> log(omega1(x)), x)
#     return 1 / g(E)
# end
# function temperature2(E)
#     g = x -> ForwardDiff.derivative(x -> log(omega2(x)), x)
#     return 1 / g(E)
# end
# function heat_transfer(E1, E2, steps)
#     energies_1 = [E1]; energies_2 = [E2]
#     temperatures_1 = [temperature1(E1)]
#     temperatures_2 = [temperature2(E2)]
#     for step in 1:steps
#         δE = 0.1
#         if (E1 - δE >= 0) && (E2 + δE >= 0)
#             T1 = temperature1(E1)
#             T2 = temperature2(E2)
#             if T1 > T2
#                 E1 -= δE; E2 += δE
#             elseif T2 > T1
#                 E1 += δE; E2 -= δE
#             end
#             push!(energies_1, E1); push!(energies_2, E2)
#             push!(temperatures_1, temperature1(E1))
#             push!(temperatures_2, temperature2(E2))
#         end
#     end
#     return energies_1, energies_2, temperatures_1, temperatures_2
# end

# # Initial energy of body 1 and body 2
# E1 = 10.0
# E2 = 5.0

# # Number of simulation steps
# steps = 50

# # Simulate heat transfer
# energies_1, energies_2, temperatures_1, temperatures_2 = heat_transfer(E1, E2, steps)

# # Plot energies
# plot(energies_1, label="Energy of Body 1 (E1)", xlabel="Steps", ylabel="Energy", lw=2,title="Energy Transfer between Bodies")
# plot!(energies_2,lw=2, label="Energy of Body 2 (E2)")

# # Plot temperatures
# plot(temperatures_1, lw=2, label="Temperature of Body 1 (T1)", xlabel="Steps", ylabel="Temperature", title="Temperature Equilibration between Bodies")
# plot!(temperatures_2,lw=2, label="Temperature of Body 2 (T2)")





#-------------------------------------------

# using Plots

# # Define the omega function using BigInt to avoid overflow
# function omega(N::Int, k::Int)
#     return binomial(BigInt(N), BigInt(k))  # Use BigInt for large binomial calculations
# end

# # Define temperature as d(log(omega))/dE
# function temperature(N, k)
#     if k == 0 || k == N
#         return Inf  # Avoid division by zero at boundaries
#     else
#         return 1 / (log(omega(N, k + 1)) - log(omega(N, k)))
#     end
# end

# # Entropy S = log(omega(E)) (assuming k_B = 1)
# function entropy(N, k)
#     return log(omega(N, k))
# end

# # Simulate the system and collect data for plotting
# function simulate_coin_toss(N)
#     energies = 0:N
#     microstates = [omega(N, k) for k in energies]
#     temperatures = [temperature(N, k) for k in energies]
#     entropies = [entropy(N, k) for k in energies]
#     return energies, microstates, temperatures, entropies
# end

# # Plot results in a combined layout
# function plot_results(N)
#     # Simulate the system
#     energies, microstates, temperatures, entropies = simulate_coin_toss(N)

#     # Create a 3-panel plot
#     plot(layout = (3, 1), size = (600, 900))

#     # Plot microstates
#     plot!(energies, microstates, lw=2, xlabel="Energy (Number of Heads)", ylabel="Microstates (Ω)", title="Microstates (Ω)", subplot=1)

#     # Plot temperature
#     plot!(energies, temperatures, lw=2, color=:red, xlabel="Energy (Number of Heads)", ylabel="Temperature (T)", title="Temperature (T)", subplot=2)

#     # Plot entropy
#     plot!(energies, entropies, lw=2, color=:green, xlabel="Energy (Number of Heads)", ylabel="Entropy (S)", title="Entropy (S)", subplot=3)
# end

# # Call the plotting function with N = 50 (for example)
# plot_results(50)



#----------------------------------------------------------------------------------------------------------------------------------------
# using Plots
# using ForwardDiff

# # Binomial function to compute microstates
# function omega(N::Int, k::Int)
#     return binomial(BigInt(N), BigInt(k))  # Use BigInt for large binomial calculations
# end

# # Overload omega to handle ForwardDiff.Dual type for automatic differentiation
# function omega(N::Int, k::ForwardDiff.Dual)
#     # We don't use binomial here, we just return the original value
#     return BigInt(Int(k))  # Simply return the value as it is for derivative calculations
# end

# # Define temperature using ForwardDiff for the numerical derivative of Omega
# function temperature(N, k)
#     if k == 0 || k == N
#         return Inf  # Avoid division by zero at boundaries
#     else
#         # Define the log(omega) function
#         log_omega(k) = log(omega(N, k))

#         # Use ForwardDiff to compute the derivative of log(omega) with respect to k
#         dlog_omega = ForwardDiff.derivative(log_omega, k)

#         # Return the temperature
#         if dlog_omega > 0
#             return 1 / dlog_omega
#         else
#             return Inf  # Avoid negative temperature
#         end
#     end
# end

# # Simulate heat transfer between two systems while keeping total energy constant
# function heat_transfer(N1, E1, N2, E2, steps)
#     total_energy = E1 + E2  # Total energy (number of heads) remains constant

#     # Store temperature over time
#     temperatures1 = [temperature(N1, E1)]
#     temperatures2 = [temperature(N2, E2)]

#     for step in 1:steps
#         δE = 1  # Energy step to transfer

#         T1 = temperature(N1, E1)
#         T2 = temperature(N2, E2)

#         # Transfer energy between the systems
#         if T1 > T2 && E1 > 0 && E2 < N2
#             E1 -= δE
#             E2 += δE
#         elseif T2 > T1 && E2 > 0 && E1 < N1
#             E2 -= δE
#             E1 += δE
#         end

#         # Recalculate temperature and store for both systems
#         push!(temperatures1, temperature(N1, E1))
#         push!(temperatures2, temperature(N2, E2))
#     end

#     return temperatures1, temperatures2
# end

# # Plotting function to show temperature evolution
# function plot_temperature_evolution(N1, E1, N2, E2, steps)
#     temperatures1, temperatures2 = heat_transfer(N1, E1, N2, E2, steps)

#     # Plot temperature evolution
#     plot(1:steps+1, temperatures1, label="T1 (System 1)", xlabel="Steps", ylabel="Temperature", lw=2, color=:blue, title="Temperature Evolution")
#     plot!(1:steps+1, temperatures2, label="T2 (System 2)", lw=2, color=:red)
# end

# # Example simulation parameters
# N1 = 10  # Number of coins in system 1
# E1 = 5   # Initial energy (number of heads) in system 1
# N2 = 10  # Number of coins in system 2
# E2 = 5   # Initial energy (number of heads) in system 2 (total E1 + E2 = 10)
# steps = 100  # Number of steps for the simulation

# # Run the simulation and plot the temperature evolution
# plot_temperature_evolution(N1, E1, N2, E2, steps)


# using Random
# using Plots

# # Function to initialize the 1D array of magnetic dipoles
# function initialize_grid(size::Int)
#     return rand(Bool, size)  # Randomly initialize dipoles to +1 or -1
# end

# # Function to calculate the energy of a 1D configuration
# function calculate_energy(grid::Array{Bool, 1})
#     size = length(grid)
#     energy = 0
#     for i in 1:size
#         # Periodic boundary conditions
#         left = grid[mod1(i - 1, size)]
#         right = grid[mod1(i + 1, size)]
#         # Calculate energy contributions from neighboring dipoles
#         energy -= grid[i] * (left + right)
#     end
#     return energy / 2  # Each pair counted twice
# end

# # Function to generate microstates for given grid configuration
# function generate_microstates(grid::Array{Bool, 1})
#     size = length(grid)
#     states = []
#     for state in 0:2^size - 1
#         microstate = [(state >> i) & 1 == 1 for i in 0:size-1]  # Generate each microstate
#         push!(states, microstate)
#     end
#     return states
# end

# # Function to calculate the number of accessible microstates at a given energy level
# function count_microstates_at_energy(grid::Array{Bool, 1}, temperature::Float64)
#     microstates = generate_microstates(grid)
#     energy_count = Dict{Float64, Float64}()  # Change the dictionary value type to Float64

#     # Count energies of each microstate
#     for microstate in microstates
#         energy = calculate_energy(microstate)
#         energy_count[energy] = get(energy_count, energy, 0.0) + 1.0  # Accumulate counts as Float64
#     end
    
#     # Normalize by the total number of microstates to get probabilities
#     total_microstates = length(microstates)
#     for (energy, count) in energy_count
#         energy_count[energy] = count / total_microstates  # Probabilities as Float64
#     end
    
#     return energy_count
# end

# # Function to simulate temperature equilibrium
# function simulate_temperature_equilibrium(size::Int, temperature::Float64, steps::Int)
#     grid = initialize_grid(size)
#     energies = zeros(Float64, steps)
#     magnetizations = zeros(Float64, steps)
#     entropies = zeros(Float64, steps)

#     for step in 1:steps
#         # Randomly choose a dipole to flip
#         i = rand(1:size)
#         current_energy = calculate_energy(grid)

#         # Flip the dipole
#         grid[i] = !grid[i]
#         new_energy = calculate_energy(grid)

#         # Calculate energy change
#         delta_energy = new_energy - current_energy

#         # Metropolis acceptance criteria
#         if delta_energy > 0 && rand() > exp(-delta_energy / temperature)
#             grid[i] = !grid[i]  # Revert the flip if not accepted
#         end

#         energies[step] = calculate_energy(grid)
#         magnetizations[step] = sum(grid) / size  # Normalize by size
        
#         # Count microstates and calculate entropy
#         energy_count = count_microstates_at_energy(grid, temperature)
#         entropies[step] = -sum(v -> v * log(v), values(energy_count))  # Entropy from the probabilities
#     end
    
#     return energies, magnetizations, entropies
# end

# # Parameters
# size = 10              # Size of the 1D grid (can be adjusted for larger size)
# temperature = 2.5      # Temperature for the simulation
# steps = 1000           # Number of simulation steps

# # Run the simulation
# energies, magnetizations, entropies = simulate_temperature_equilibrium(size, temperature, steps)

# # Plotting the energy, magnetization, and entropy over time
# plot(1:steps, energies, label="Energy", xlabel="Steps", ylabel="Value", title="Energy, Magnetization, and Entropy in 1D Ferromagnetic Material Simulation", legend=:topright)
# plot!(1:steps, magnetizations, label="Magnetization")
# plot!(1:steps, entropies, label="Entropy")

