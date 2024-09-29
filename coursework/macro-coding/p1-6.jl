
# Define parameters

α = 0.3

β = 0.6

B = (α * β)^(-1)

k_grid = [0.8, 0.9, 1.0, 1.1, 1.2]  # Discrete grid for capital


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

            c = B * k^α - k_prime  # consumption

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
plot(k_values, v_values, label="Value Function", xlabel="k", ylabel="v(k)", title="Value Function", legend=:topright)
savefig("figures/plot1-6_value.png")  # save the value function plot

# plot policy function
plot(k_values, policy_values, label="Policy Function", xlabel="k", ylabel="k'", title="Policy Function", legend=:topright)
savefig("figures/plot1-6_policy.png")  # Save the policy function plot
