local helper = require("helper")
local intcode = require("intcode")

function output_f(v)
	if intcode.debug then print("output: "..v) end
	table.insert(output,v)
end


io.input("input/day5_input.txt")
input_s = io.read("*all")

--part 1
output = {}
intcode.run_program(input_s, output_f, function() return 1 end)
print(table.tostring(output))


--part 2
output = {}
intcode.run_program(input_s, output_f, function() return 5 end)
print(table.tostring(output))
