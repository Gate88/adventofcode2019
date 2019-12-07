local helper = require("helper")

CACHE = {}

function update_cache(op,delay)
	local key = key(op)
	if not CACHE[key] then CACHE[key] = delay end
end

INTERSECTIONS = {}

function record_intersection(op,delay)
	local key = key(op)
	if CACHE[key] then
		op.delay = delay + CACHE[key]
		table.insert(INTERSECTIONS,helper.copy(op))
	end
end

function key(op)
	return op[1]..","..op[2]
end

MOVE = {
	R = function(op)
		op[1] = op[1] + 1
	end,
	L = function(op)
		op[1] = op[1] - 1
	end,
	U = function(op)
		op[2] = op[2] - 1
	end,
	D = function(op)
		op[2] = op[2] + 1
	end
}

function apply_from_path(path, f)
	local p = {0,0}
	local f = f or function() end
	local delay = 0
	for instruction in string.gmatch(path, "[^,]+") do
		local dir, num = string.match(instruction,"(%a)(%d+)")
		num = num + 0
		for i=1,num do
			delay = delay + 1
			MOVE[dir](p)
			f(p,delay)
		end
	end
end

function manhattan_distance(s)
	local x,y = unpack(s)
	return math.abs(x)+math.abs(y)
end

function delay(s)
	return s.delay
end

function find_smallest(t,f)
	local smallest = nil
	local f = f or function() end
	for _,s in ipairs(t) do
		local v = f(s)
		if not smallest or v < smallest then
			smallest = v
		end
	end
	return smallest
end

io.input("input/day3_input.txt")

firstPath, secondPath = io.read(), io.read()

apply_from_path(firstPath,update_cache)
apply_from_path(secondPath,record_intersection)

print(find_smallest(INTERSECTIONS,manhattan_distance))
print(find_smallest(INTERSECTIONS,delay))