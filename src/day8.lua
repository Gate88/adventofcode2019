local helper = require("helper")

local input = io.input("input/day8_input.txt")

local width = 25
local height = 6

local counts = {}
local layers = {}

--read input
local index = 0
while true do
	local p = io.read(1)
	if not p then break end
	p = p + 0

	local layer = math.floor(index / (width*height)) + 1
	local i = index % (width*height)

	if not counts[layer] then counts[layer] = {} end
	local count = counts[layer]
	if not count[p] then count[p] = 0 end

	count[p] = count[p] + 1

	if not layers[layer] then layers[layer] = {} end
	local l = layers[layer]
	table.insert(l,p)

	index = index + 1
end

--find layer with fewest 0s
local fewest = nil
local fewestLayer = nil
for i,l in ipairs(counts) do
	local zeros = l[0] or 0
	if not fewest or zeros < fewest then
		fewest = zeros
		fewestLayer = i
	end
end

print("part 1: "..counts[fewestLayer][1]*counts[fewestLayer][2])

--build picture
local picture = {}
for i=1,width*height do
	local p = 2
	local j = 1
	while p == 2 and j <= #layers do
		p = layers[j][i]
		j = j + 1
	end
	picture[i] = p
end

function toprint(p)
	if p == 0 then return " " end
	if p == 1 then return "#" end
	return " "
end

print("part 2: ")
local offset = 0
for h=1,height do
	local output = ""
	for i=1,width do
		output = output..toprint(picture[i+offset])
	end
	print(output)
	offset = offset + width
end