local intcode = {
	debug = false,
}

local function empty() end

local function sanitize(m)
	return (not m or m == "") and 0 or m+0
end

function intcode.run_program(program, output, input, modify)
	local p, i = {}, 0
	modify = modify or empty
	input = input or empty
	for n in string.gmatch(program, "[^,]+") do
		p[i] = n+0
		i = i + 1
	end

	i = 0
	modify(p)

	function math_op(operation)
		return function(m1,m2)
			local v1, v2 = value_m(1,m1), value_m(2, m2)
			if intcode.debug then print(" v1:"..v1.." v2:"..v2) end
			p[p[i+3]] = operation(v1,v2)
			i = i + 4
		end
	end

	function jump_op(condition)
		return function(m1,m2)
			if condition(value_m(1,m1)) then
				i = value_m(2,m2)
			else
				i = i + 3
			end
		end
	end

	function compare_op(compare)
		return function(m1,m2)
			local output = 0
			if compare(value_m(1,m1),value_m(2,m2)) then
				output = 1
			end
			p[p[i+3]] = output
			i = i + 4
		end
	end

	function value_m(index,m)
		m = (m == 1) and m or 0
		if intcode.debug then print("   i:"..i.." index:"..index.." m:"..m) end
		return m == 1 and p[i+index] or p[p[i+index]]
	end

	f = {
	--[[add]]		[1] = math_op(function(v1,v2) return v1+v2 end),
	--[[mul]]		[2] = math_op(function(v1,v2) return v1*v2 end),
	--[[input]] 	[3] = function()
						p[p[i+1]] = input()
						i = i+2
					end,
	--[[output]]	[4] = function(m1)
						output(value_m(1,m1))
						i = i+2
					end,
	--[[jmp_nz]]    [5] = jump_op(function(v) return v ~= 0 end),
	--[[jmp_z]]		[6] = jump_op(function(v) return v == 0 end),
	--[[cmp_lt]]	[7] = compare_op(function(v1,v2) return v1 < v2 end),
	--[[cmp_eq]]	[8] = compare_op(function(v1,v2) return v1 == v2 end),
	--[[exit]]		[99] = function()
			return 1
		end
	}

	while true do
		local v = tostring(p[i])
		local op = string.sub(v,-2,-1)+0
		local m1 = sanitize(string.sub(v,-3,-3))
		local m2 = sanitize(string.sub(v,-4,-4))
		local m3 = sanitize(string.sub(v,-5,-5))
		if intcode.debug then
			print("i: "..i.." v:"..v.." op:"..op.." m1:"..m1.." m2:"..m2.." m3:"..m3)
		end
		if f[op](m1,m2,m3) then break end
	end
	return p[0]
end

return intcode