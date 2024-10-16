# using Combinatorics, Plots

# # Natural unit constants
# k_B = 1.0  # Boltzmann constant (natural units)
# h = 1.0    # Planck's constant (natural units)
# ν = 1.0    # Frequency of oscillators (arbitrary units)
# ε = 1.0    # Energy quantum (arbitrary units)
# N_A = 50   # Number of oscillators in system A
# N_B = 50   # Number of oscillators in system B

# # Function to compute the number of microstates Ω(q, N) using BigInt
# function microstates(q::BigInt, N::BigInt)
#     return binomial(q + N - 1, q)
# end

# # Function to calculate entropy
# function entropy(Ω)
#     return log(Ω)
# end

# # Function to calculate temperature from change in entropy
# function calculate_temperature(S_current, S_previous, ΔE)
#     return ΔE / (S_current - S_previous)
# end

# # Function to simulate entropy, temperature, and heat capacity
# function simulate_entropy_temperature_variation(q_A_init, q_B_init, N_A, N_B, max_steps=1000)
#     # Initialize q_A and q_B as BigInt
#     q_A = BigInt(q_A_init)
#     q_B = BigInt(q_B_init)

#     # Lists to store entropy, temperature, heat capacity, and q_A, q_B histories
#     SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist = [], [], [], [], [], [], [], []

#     # Store initial entropy
#     Ω_A = microstates(q_A, BigInt(N_A))
#     Ω_B = microstates(q_B, BigInt(N_B))
#     S_A_prev = entropy(Ω_A)
#     S_B_prev = entropy(Ω_B)

#     for step in 1:max_steps
#         # Calculate the number of microstates for each system
#         Ω_A = microstates(q_A, BigInt(N_A))
#         Ω_B = microstates(q_B, BigInt(N_B))

#         # Calculate entropy for each system
#         S_A = entropy(Ω_A)
#         S_B = entropy(Ω_B)

#         # Store entropy
#         push!(SA_hist, S_A)
#         push!(SB_hist, S_B)

#         # Store q_A and q_B
#         push!(q_A_hist, q_A)
#         push!(q_B_hist, q_B)

#         # Calculate temperature
#         if step > 1
#             T_A = calculate_temperature(S_A, S_A_prev, 1)
#             T_B = calculate_temperature(S_B, S_B_prev, 1)
#             push!(TA_hist, T_A)
#             push!(TB_hist, T_B)
#         else
#             push!(TA_hist, NaN)
#             push!(TB_hist, NaN)
#         end

#         # Calculate heat capacity
#         if step > 1 && TA_hist[end-1] != NaN && TB_hist[end-1] != NaN
#             C_VA = (S_A - S_A_prev) / (T_A - TA_hist[end-1])
#             C_VB = (S_B - S_B_prev) / (T_B - TB_hist[end-1])
#             push!(C_VA_hist, C_VA)
#             push!(C_VB_hist, C_VB)
#         else
#             push!(C_VA_hist, NaN)
#             push!(C_VB_hist, NaN)
#         end

#         # Store previous entropies for the next step
#         S_A_prev = S_A
#         S_B_prev = S_B

#         # Redistribute energy (randomly choose one energy quantum to transfer)
#         if q_A > 0 && rand() < 0.5
#             q_A -= 1
#             q_B += 1
#         elseif q_B > 0
#             q_B -= 1
#             q_A += 1
#         end

#         # Stop if energy difference is small (equilibrium)
#         if abs(q_A - q_B) < 1e-5  # Using a small threshold for equilibrium
#             break
#         end
#     end

#     return SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist
# end

# # Initial number of energy quanta for two Einstein solids
# q_A_init = 400  # Initial energy quanta in solid A
# q_B_init = 300  # Initial energy quanta in solid B

# # Run the simulation to get entropy, temperature, and heat capacity histories
# SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist = simulate_entropy_temperature_variation(q_A_init, q_B_init, N_A, N_B)

# # Plotting

# # 1. Temperature vs Heat Capacity
# plot(1:length(TA_hist), TA_hist, label="Temperature A", xlabel="Steps", ylabel="Temperature", title="Temperature vs Heat Capacity", legend=:topright)
# plot!(1:length(C_VA_hist), C_VA_hist, label="Heat Capacity A")
# plot!(1:length(TB_hist), TB_hist, label="Temperature B")
# plot!(1:length(C_VB_hist), C_VB_hist, label="Heat Capacity B")

# # 2. Temperature vs q_A and q_B
# plot(1:length(TA_hist), TA_hist, label="Temperature A", xlabel="Steps", ylabel="Values", title="Temperature vs q_A and q_B", legend=:topright)
# plot!(1:length(q_A_hist), q_A_hist, label="q_A")
# plot!(1:length(q_B_hist), q_B_hist, label="q_B")

# # 3. Entropy vs q_A and q_B
# plot(1:length(SA_hist), SA_hist, label="Entropy A", xlabel="Steps", ylabel="Values", title="Entropy vs q_A and q_B", legend=:topright)
# plot!(1:length(SB_hist), SB_hist, label="Entropy B")
# plot!(1:length(q_A_hist), q_A_hist, label="q_A")
# plot!(1:length(q_B_hist), q_B_hist, label="q_B")



# using Combinatorics, Plots

# # Natural unit constants
# k_B = 1.0  # Boltzmann constant (natural units)
# h = 1.0    # Planck's constant (natural units)
# ν = 1.0    # Frequency of oscillators (arbitrary units)
# ε = 1.0    # Energy quantum (arbitrary units)
# N_A = 50   # Number of oscillators in system A
# N_B = 50   # Number of oscillators in system B

# # Function to compute the number of microstates Ω(q, N) using BigInt
# function microstates(q::BigInt, N::BigInt)
#     return binomial(q + N - 1, q)
# end

# # Function to calculate entropy
# function entropy(Ω)
#     return log(Ω)
# end

# # Function to calculate temperature from change in entropy
# function calculate_temperature(S_current, S_previous, ΔE)
#     return ΔE / (S_current - S_previous)
# end

# # Function to simulate entropy, temperature, and heat capacity
# function simulate_entropy_temperature_variation(q_A_init, q_B_init, N_A, N_B, max_steps=1000)
#     # Initialize q_A and q_B as BigInt
#     q_A = BigInt(q_A_init)
#     q_B = BigInt(q_B_init)

#     # Lists to store entropy, temperature, heat capacity, and q_A, q_B histories
#     SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist = [], [], [], [], [], [], [], []

#     # Store initial entropy
#     Ω_A = microstates(q_A, BigInt(N_A))
#     Ω_B = microstates(q_B, BigInt(N_B))
#     S_A_prev = entropy(Ω_A)
#     S_B_prev = entropy(Ω_B)

#     for step in 1:max_steps
#         # Calculate the number of microstates for each system
#         Ω_A = microstates(q_A, BigInt(N_A))
#         Ω_B = microstates(q_B, BigInt(N_B))

#         # Calculate entropy for each system
#         S_A = entropy(Ω_A)
#         S_B = entropy(Ω_B)

#         # Store entropy
#         push!(SA_hist, S_A)
#         push!(SB_hist, S_B)

#         # Store q_A and q_B
#         push!(q_A_hist, q_A)
#         push!(q_B_hist, q_B)

#         # Calculate temperature
#         if step > 1
#             T_A = calculate_temperature(S_A, S_A_prev, 1)
#             T_B = calculate_temperature(S_B, S_B_prev, 1)
#             push!(TA_hist, T_A)
#             push!(TB_hist, T_B)
#         else
#             push!(TA_hist, NaN)
#             push!(TB_hist, NaN)
#         end

#         # Calculate heat capacity
#         if step > 1
#             C_VA = (S_A - S_A_prev) / (T_A - TA_hist[end-1])
#             C_VB = (S_B - S_B_prev) / (T_B - TB_hist[end-1])
#             push!(C_VA_hist, C_VA)
#             push!(C_VB_hist, C_VB)
#         else
#             push!(C_VA_hist, NaN)
#             push!(C_VB_hist, NaN)
#         end

#         # Store previous entropies for the next step
#         S_A_prev = S_A
#         S_B_prev = S_B

#         # Redistribute energy (randomly choose one energy quantum to transfer)
#         if q_A > 0 && rand() < 0.5
#             q_A -= 1
#             q_B += 1
#         elseif q_B > 0
#             q_B -= 1
#             q_A += 1
#         end

#         # Stop if energy difference is small (equilibrium)
#         if abs(q_A - q_B) < 1e-5  # Using a small threshold for equilibrium
#             break
#         end
#     end

#     return SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist
# end

# # Initial number of energy quanta for two Einstein solids
# q_A_init = 400  # Initial energy quanta in solid A
# q_B_init = 300  # Initial energy quanta in solid B

# # Run the simulation to get entropy, temperature, and heat capacity histories
# SA_hist, SB_hist, TA_hist, TB_hist, C_VA_hist, C_VB_hist, q_A_hist, q_B_hist = simulate_entropy_temperature_variation(q_A_init, q_B_init, N_A, N_B)

# # Plotting

# # 1. Temperature vs Heat Capacity
# plot(TA_hist,C_VA_hist,label="Temperature A", xlabel="Steps", ylabel="Temperature", title="Temperature vs Heat Capacity")
# plot!(TB_hist,C_VB_hist, label="Heat Capacity A", ylabel="Heat Capacity")

# # 2. Temperature vs q_A and q_B
# plot(1:length(TA_hist), TA_hist, label="Temperature A", xlabel="Steps", ylabel="Temperature", title="Temperature vs q_A and q_B")
# plot!(1:length(TB_hist), TB_hist, label="Temperature B")
# # 3. Entropy vs q_A and q_B
# plot(TA_hist, SA_hist, label="Entropy A", xlabel="Temp", ylabel="Entropy", title="Entropy vs q_A and q_B")
# plot!(TB_hist, SB_hist, label="Entropy B")
# # plot!(TB_hist, SB_hist, label="Total Entropy")
# # plot!(1:length(q_A_hist), q_A_hist, label="q_A")
# # plot!(1:length(q_B_hist), q_B_hist, label="q_B")



# using Combinatorics, Plots

# # Function to compute the number of microstates Ω(q, N)
# function microstates(q, N)
#     return binomial(BigInt(q) + N - 1, q)
# end

# # Function to calculate entropy S
# function entropy(Ω)
#     return log(Ω)
# end

# # Function to compute the derivative of microstates with respect to energy
# function d_omega_d_E(q, N)
#     return microstates(q - 1, N)  # Represents the number of microstates for (q-1)
# end

# # Function to simulate the interaction of two Einstein solids
# function simulate_einstein_solids(q_A_init, q_B_init, N_A, N_B, max_steps=10000)
#     # Initialize energy quanta for solids A and B
#     q_A = q_A_init
#     q_B = q_B_init

#     # Lists to store the entropy, temperatures, and energy quanta
#     SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist = [], [], [], [], [], [], []

#     for step in 1:max_steps
#         # Calculate the number of microstates for each system
#         Ω_A = microstates(q_A, N_A)
#         Ω_B = microstates(q_B, N_B)

#         # Calculate entropy for each system
#         S_A = entropy(Ω_A)
#         S_B = entropy(Ω_B)

#         # Store the current state
#         push!(SA_hist, S_A)
#         push!(SB_hist, S_B)
#         push!(q_A_hist, q_A)
#         push!(q_B_hist, q_B)

#         # Calculate total entropy
#         total_entropy = S_A + S_B
#         push!(total_entropy_hist, total_entropy)

#         # Calculate temperature (only if previous values are defined)
#         if step > 1
#             dΩ_A_dE = d_omega_d_E(q_A, N_A)
#             dΩ_B_dE = d_omega_d_E(q_B, N_B)

#             T_A = Ω_A / dΩ_A_dE
#             T_B = Ω_B / dΩ_B_dE

#             push!(TA_hist, T_A)
#             push!(TB_hist, T_B)
#         else
#             push!(TA_hist, NaN)
#             push!(TB_hist, NaN)
#         end

#         # Randomly redistribute energy
#         if q_A > 0 && q_B < (N_B + q_B)  # Ensuring q_B does not exceed max quanta
#             if rand() < 0.5  # Transfer one quantum from A to B
#                 q_A -= 1
#                 q_B += 1
#             else  # Transfer one quantum from B to A
#                 q_A += 1
#                 q_B -= 1
#             end
#         end

#         # Check for thermal equilibrium (when temperatures are close)
#         if step > 1 && abs(T_A - T_B) < 1e-5
#             break
#         end
#     end

#     return SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist
# end

# # Parameters
# q_A_init = 200  # Initial energy quanta in solid A
# q_B_init = 100  # Initial energy quanta in solid B
# N_A = 300        # Number of oscillators in solid A
# N_B = 300       # Number of oscillators in solid B

# # Run the simulation
# SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist = simulate_einstein_solids(q_A_init, q_B_init, N_A, N_B)

# # Plotting

# # 1. Plot Entropy vs Energy Quanta
# plot(1:length(SA_hist), SA_hist, label="Entropy A", xlabel="Steps", ylabel="Entropy", title="Entropy of Einstein Solids")
# plot!(1:length(SB_hist), SB_hist, label="Entropy B")
# plot!(1:length(total_entropy_hist), total_entropy_hist, label="Total Entropy", linestyle=:dash)

# # 2. Plot Temperature vs Energy Quanta
# plot(1:length(TA_hist), TA_hist, label="Temperature A", xlabel="Steps", ylabel="Temperature", title="Temperature of Einstein Solids")
# plot!(1:length(TB_hist), TB_hist, label="Temperature B")

# # 3. Plot q_A and q_B
# plot(1:length(q_A_hist), q_A_hist, label="q_A", xlabel="Steps", ylabel="Energy Quanta", title="Energy Quanta in Einstein Solids")
# plot!(1:length(q_B_hist), q_B_hist, label="q_B")



# using Combinatorics, Plots

# # Set the plotting backend to PlotlyJS
# plotlyjs()

# # Function to compute the number of microstates Ω(q, N)
# function microstates(q, N)
#     return binomial(BigInt(q) + N - 1, q)
# end

# # Function to calculate entropy S
# function entropy(Ω)
#     return log(Ω)
# end

# # Function to compute the derivative of microstates with respect to energy
# function d_omega_d_E(q, N)
#     return microstates(q - 1, N)  # Represents the number of microstates for (q-1)
# end

# # Function to simulate the interaction of two Einstein solids
# function simulate_einstein_solids(q_A_init, q_B_init, N_A, N_B, max_steps=10000)
#     # Initialize energy quanta for solids A and B
#     q_A = q_A_init
#     q_B = q_B_init

#     # Lists to store the entropy, temperatures, and energy quanta
#     SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist = [], [], [], [], [], [], []

#     for step in 1:max_steps
#         # Calculate the number of microstates for each system
#         Ω_A = microstates(q_A, N_A)
#         Ω_B = microstates(q_B, N_B)

#         # Calculate entropy for each system
#         S_A = entropy(Ω_A)
#         S_B = entropy(Ω_B)

#         # Store the current state
#         push!(SA_hist, S_A)
#         push!(SB_hist, S_B)
#         push!(q_A_hist, q_A)
#         push!(q_B_hist, q_B)

#         # Calculate total entropy
#         total_entropy = S_A + S_B
#         push!(total_entropy_hist, total_entropy)

#         # Calculate temperature using T = Ω / (dΩ/dE)
#         if q_A > 0  # Ensure we don't attempt to access negative quanta
#             dΩ_A_dE = d_omega_d_E(q_A, N_A)
#             T_A = Ω_A / dΩ_A_dE
#             push!(TA_hist, T_A)
#         else
#             push!(TA_hist, NaN)
#         end

#         if q_B > 0  # Ensure we don't attempt to access negative quanta
#             dΩ_B_dE = d_omega_d_E(q_B, N_B)
#             T_B = Ω_B / dΩ_B_dE
#             push!(TB_hist, T_B)
#         else
#             push!(TB_hist, NaN)
#         end

#         # Randomly redistribute energy with a more controlled approach
#         if q_A > 0 && q_B < (N_B + q_B)  # Ensuring q_B does not exceed max quanta
#             if rand() < 0.5  # Transfer one quantum from A to B
#                 q_A -= 1
#                 q_B += 1
#             end
#         end
        
#         if q_B > 0 && q_A < (N_A + q_A)  # Ensuring q_A does not exceed max quanta
#             if rand() < 0.5  # Transfer one quantum from B to A
#                 q_B -= 1
#                 q_A += 1
#             end
#         end

#         # Check for thermal equilibrium (when temperatures are close)
#         if step > 1 && abs(T_A - T_B) < 1e-5
#             break
#         end
#     end

#     return SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist
# end

# # Parameters
# q_A_init = 400  # Initial energy quanta in solid A
# q_B_init = 300  # Initial energy quanta in solid B
# N_A = 50        # Number of oscillators in solid A
# N_B = 50        # Number of oscillators in solid B

# # Run the simulation
# SA_hist, SB_hist, TA_hist, TB_hist, q_A_hist, q_B_hist, total_entropy_hist = simulate_einstein_solids(q_A_init, q_B_init, N_A, N_B)

# # Plotting

# # 1. Plot Entropy vs Energy Quanta
# plot(1:length(SA_hist), SA_hist, label="Entropy A", xlabel="Steps", ylabel="Entropy", title="Entropy of Einstein Solids")
# plot!(1:length(SB_hist), SB_hist, label="Entropy B")
# plot!(1:length(total_entropy_hist), total_entropy_hist, label="Total Entropy", linestyle=:dash)

# # 2. Plot Temperature vs Energy Quanta
# plot(1:length(TA_hist), TA_hist, label="Temperature A", xlabel="Steps", ylabel="Temperature", title="Temperature of Einstein Solids")
# plot!(1:length(TB_hist), TB_hist, label="Temperature B")

# # 3. Plot q_A and q_B
# plot(1:length(q_A_hist), q_A_hist, label="q_A", xlabel="Steps", ylabel="Energy Quanta", title="Energy Quanta in Einstein Solids")
# plot!(1:length(q_B_hist), q_B_hist, label="q_B")
