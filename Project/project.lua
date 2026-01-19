

-- Get adding function
local module = require("add")

-- Get inputs
write("First number: ")
local first_input = read()

write("Second number: ") 
local second_input = read()

-- Show result
print(first_input, "+", second_input, "=", module.add(first_input, second_input))