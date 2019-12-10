local helper = require("helper")
local intcode = require("intcode")

intcode.debug = false

io.input("input/day9_input.txt")
local program = io.read("*all")

local output = {}
local inputF = intcode.make_input_function{1}
local outputF = intcode.make_output_function(output)

intcode.run_program(program, outputF, inputF)

print("part 1: "..table.tostring(output))

output = {}
inputF = intcode.make_input_function{2}
outputF = intcode.make_output_function(output)

intcode.run_program(program, outputF, inputF)

print("part 2: "..table.tostring(output))