# Define parameters

α = 0.3

β = 0.6

B = (α * β)^(-1)

k_grid = [0.8, 0.9, 1.0, 1.1, 1.2]  # Discrete grid for capital


# Number of iterations for value function iteration
max_iter = 3


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


# Value function iteration

for iter in 1:max_iter

    println("Iteration $iter:")

    global v = next_value_function(v, k_grid, B, β)

    for (k, val) in v

        println("v($k) = $val")

    end

    println()

end


for (k, val) in policy

    println("k($k)= $val")

end