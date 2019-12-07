local helper = require("helper")
local intcode = require("intcode")
local linkedlist = require("linkedlist")

intcode.debug = false

io.input("input/day7_input.txt")
local program = io.read("*all")

local p1highestSignal = 0
for n in helper.perm{0,1,2,3,4} do
	local previousOutput = 0
	for i=1,5 do
		local input1 = n[i]
		local output = {}
		local outputF = intcode.make_output_function(output)
		local inputF = intcode.make_input_function{input1,previousOutput}
		intcode.run_program(program, outputF, inputF)
		previousOutput = output[1]
	end
	if previousOutput > p1highestSignal then
		p1highestSignal = previousOutput
	end
end

print("part1: "..p1highestSignal)

--p1 -> A -> p2 -> B -> p3 -> C -> p4 -> D -> p5 -> E -> p1

local p2highestSignal = 0
for n in helper.perm{5,6,7,8,9} do
	local pipes = {}
	local outputll = nil
	for i=1,5 do
		local ll = linkedlist.new()
		linkedlist.pushleft(ll,n[i])
		if i == 1 then 
			linkedlist.pushleft(ll,0) 
			outputll = ll
		end
		pipes[i] = intcode.make_pipe_with_linkedlist(ll)
	end

	local programs = {}
	for i=1,5 do
		local o = i % 5 + 1
		programs[i] = intcode.iterate_program(program,pipes[o].output,pipes[i].input)
	end

	local done = false
	while not done do
		done = true
		for i=1,5 do
			local code, res = programs[i]()
			if code then done = false end
		end
	end

	local output = linkedlist.popright(outputll)

	if output > p2highestSignal then
		p2highestSignal = output
	end
end

print("part2: "..p2highestSignal)