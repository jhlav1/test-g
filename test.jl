# Function to calculate the square of the sum of first n natural numbers
function square_of_sum(n::Int)
    sum = (n * (n + 1)) ÷ 2  # Sum of first n natural numbers
    return sum^2
end

# Function to calculate the sum of squares of first n natural numbers
function sum_of_squares(n::Int)
    return (n * (n + 1) * (2n + 1)) ÷ 6  # Formula for sum of squares
end

# Function to calculate the difference between square of sum and sum of squares
function difference(n::Int)
    return square_of_sum(n) - sum_of_squares(n)
end

# Example usage
function main()
    n = 5  # Changed value to 5
    println("For n = $n:")
    println("Square of sum: ", square_of_sum(n))
    println("Sum of squares: ", sum_of_squares(n))
    println("Difference: ", difference(n))
end

# Run the example
main()
