

using Plots

# Define parameters

ks=1

α = 0.3

β = 0.8

ρ=0.25

δ=0.2

B=(ρ + δ)/α

k_grid = [(1+(0.25/250)*(i-251))*ks for i in 1:501] # Discrete grid for capital


# Tolerance level for convergence
tol = 1e-6

# Utility function

function utility(c)

    if c > 0

        return log(c)

    else

        return -Inf  # log is undefined for non-positive consumption

    end

end


# Initial value function

global v = Dict(k => 0.0 for k in k_grid)

global policy = Dict(k => 0.0 for k in k_grid)


# Function for the next iteration of the value function

function next_value_function(v, k_grid, B, β)

    v_new = Dict(k => -Inf for k in k_grid)  # Initialize new value function

    for k in k_grid

        max_val = -Inf

        max_k = -Inf

        for k_prime in k_grid

            c = B * k^α + (1-δ)*k - k_prime  # consumption

            val = utility(c) + β * v[k_prime]  # Bellman equation

            if val > max_val

                max_val = val

                max_k = k_prime

            end

        end

        v_new[k] = max_val

        policy[k] = max_k

    end

    return v_new

end

# value function iteration until convergence
diff = Inf # Initialize difference
global iteration = 0


# Value function iteration
while diff > tol
    global iteration += 1
    println("Iteration $iteration:")
    
    v_new = next_value_function(v, k_grid, B, β)

    # Calculate the maximum absolute difference between v_new and v_new
    global diff = maximum(abs,(v_new[k] - v[k] for k in k_grid))

    # Update value function for next iteration
    global v = v_new

    # Print the current value function
    for (k, val) in v
        println("v($k)=$val")
    end
    println("Max difference: $diff")
    println()
end

for (k, val) in policy

    println("k($k)= $val")

end


# Extract value function and policy into arrays for plotting
k_values = collect(k_grid)
v_values = [v[k] for k in k_grid]
policy_values = [policy[k] for k in k_grid]

# Plot Value Function
plot(k_values, v_values, label="Value Function", xlabel="k", ylabel="v(k)", title="Value Function N=501", legend=:topright)
savefig("figures/plot1-9_value.png")  # save the value function plot

# plot policy function
plot(k_values, policy_values, label="Policy Function", xlabel="k", ylabel="k'", title="Policy Function N=501", legend=:topright)
savefig("figures/plot1-9_policy.png")  # Save the policy function plot


# Extract value function and policy into arrays for plotting


k_index = Dict()
c_index = Dict()

# number of iterations
iterations = 100

# Function to find the closest key to k0, excluding exact matches
function find_closest_value(dict, k0)
    # Get all keys
    key_list = collect(keys(dict))
    
    # Calculate absolute differences between k0 and the keys
    differences = abs.(key_list .- k0)
    
    # Find the index of the minimum difference
    closest_idx = argmin(differences)
    
    # Retrieve the closest key and corresponding value
    closest_key = key_list[closest_idx]
    closest_value = dict[closest_key]
    
    return closest_key, closest_value
end

k_initial = 0.9*ks
# Iteratively update k0 and find closest values
# Iteratively update k_initial and store closest values
for i in 1:iterations
    closest_key, closest_value = find_closest_value(policy, k_initial)
    k_index[i] = closest_value
    c_index[i] = B* k_initial^(0.3) + (1-δ)*k_initial - closest_value
    # Update k_initial with the closest value for the next iteration
    global k_initial = closest_value
end

k_values = [k_index[i] for i in 1:iterations]
c_values = [c_index[i] for i in 1:iterations]

# Plot the iterations
plot(1:iterations, k_values, xlabel="Iteration", ylabel="k Value", title="first 100 elements", marker=:circle)
savefig("figures/plot1-9_k-value.png")  # save the value function plot

plot(1:iterations, c_values, xlabel="Iteration", ylabel="C Value", title="first 100 elements", marker=:circle)
savefig("figures/plot1-9_c-value.png")  # save the value function plot



using XLSX


# Create a dictionary with the iteration, k_values, and c_values
iterations = collect(1:iterations)  # Convert to a vector
k_values = collect(k_values)  # Ensure k_values is a vector
c_values = collect(c_values)  # Ensure c_values is a vector

# Combine all data into a table-like structure
table_data = hcat(iterations, k_values, c_values)

# Write the data to an Excel file
XLSX.openxlsx("tables/values_output_p1-9.xlsx", mode="w") do xf
    sheet = xf[1]
    # Write headers
    sheet["A1"] = "Iteration"
    sheet["B1"] = "K Values"
    sheet["C1"] = "C Values"
    
    # Write the table data starting from A2
    for i in 1:size(table_data, 1)
        sheet["A$(i+1)"] = table_data[i, 1]
        sheet["B$(i+1)"] = table_data[i, 2]
        sheet["C$(i+1)"] = table_data[i, 3]
    end
end
