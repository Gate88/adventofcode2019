local helper = require("helper")
local linkedlist = require("linkedlist")

io.input("input/day6_input.txt")
local map = {}

function orbits(root,depth)
	local total = 0
	depth = depth or 1
	local children = map[root].children
	total = total + #children*depth
	for _,c in ipairs(children) do
		total = total + orbits(c,depth+1)
	end
	return total
end

function find(from,to)
	local queue, i = linkedlist.new()

	linkedlist.pushleft(queue,{location = from, distance = 0})

	while queue.first <= queue.last do
		local item = linkedlist.popright(queue)
		local node = map[item.location]

		if item.location == to then
			return item.distance-2
		end

		for _,c in ipairs(node.children) do
			if c ~= item.back then
				linkedlist.pushleft(queue,{
					location = c,
					distance = item.distance + 1,
					back = item.location
				})
			end
		end

		if node.parent and node.parent ~= item.back then
			linkedlist.pushleft(queue,{
				location = node.parent,
				distance = item.distance + 1,
				back = item.location
			})
		end
	end
end

while true do
	local s = io.read()
	if not s then break end
	local big, small = string.match(s,"(.*)%)(.*)")
	if not map[big] then
		map[big] = {}
		map[big].children = {}
	end
	if not map[small] then
		map[small] = {}
		map[small].children = {}
	end
	table.tostring(map[big])
	table.insert(map[big].children,small)
	map[small].parent = big
end

local roots = {}
for k,v in pairs(map) do
	if not v.parent then table.insert(roots,k) end
end

for _,v in ipairs(roots) do
	print("part 1: "..orbits(v))
end

print("part 2: "..find("YOU","SAN"))