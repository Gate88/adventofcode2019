local linkedlist = require("linkedlist")

local intcode = {
	debug = false,
}

local ID = 1

local function empty() end

local function sanitize(m)
	return (not m or m == "") and 0 or tonumber(m)
end

function intcode.make_program_iterator(program, output, input, modify, delay_run)
	return intcode.run_program(program, output, input, modify, true)
end

function intcode.run_program(program, output, input, modify, delay_run)
	local p, i, id, relative_base = {}, 0, ID, 0
	ID = ID + 1
	modify = modify or empty
	input = input or empty

	--parse program into memory
	for n in string.gmatch(program, "[^,]+") do
		p[i] = tonumber(n)
		i = i + 1
	end

	i = 0
	modify(p)

	local value_from_memory = function(memory_location)
		local v = p[memory_location]
		if not v or v == "" then v = 0 end
		return v
	end

	local store_m = function(index, m, value)
		if m == 2 then
			p[p[index+i]+relative_base] = value
		else
			p[p[index+i]] = value
		end
	end

	local value_m = function(index,m)
		m = m or 0
		if intcode.debug then print("   i:"..i.." index:"..index.." m:"..m) end
		if m == 1 then
			return value_from_memory(i+index)
		elseif m == 2 then
			return value_from_memory(value_from_memory(i+index)+relative_base)
		else
			return value_from_memory(value_from_memory(i+index))
		end
	end

	local math_op = function(operation)
		return function(m1,m2,m3)
			local v1, v2 = value_m(1,m1), value_m(2, m2)
			if intcode.debug then print(" v1:"..v1.." v2:"..v2) end
			store_m(3,m3,operation(v1,v2))
			i = i + 4
		end
	end

	local jump_op = function(condition)
		return function(m1,m2)
			if condition(value_m(1,m1)) then
				i = value_m(2,m2)
			else
				i = i + 3
			end
		end
	end

	local compare_op = function(compare)
		return function(m1,m2,m3)
			local output = 0
			if compare(value_m(1,m1),value_m(2,m2)) then
				output = 1
			end
			store_m(3,m3,output)
			i = i + 4
		end
	end

	local f = {
	--[[add]]		[1] = math_op(function(v1,v2) return v1+v2 end),
	--[[mul]]		[2] = math_op(function(v1,v2) return v1*v2 end),
	--[[input]] 	[3] = function(m1)
						local value = input()
						while value == nil and delay_run do
							coroutine.yield()
							value = input()
						end
						store_m(1,m1,value)
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
	--[[rel_base]]  [9] = function(m1)
						relative_base = relative_base + value_m(1,m1)
						i = i+2
					end,
	--[[exit]]		[99] = function() return 1 end
	}

	local run = function()
		while true do
			local v = tostring(p[i])
			local op = sanitize(string.sub(v,-2,-1))
			local m1 = sanitize(string.sub(v,-3,-3))
			local m2 = sanitize(string.sub(v,-4,-4))
			local m3 = sanitize(string.sub(v,-5,-5))
			if intcode.debug then
				print(table.tostring(p))
				print("ID: "..id.." i: "..i.." v:"..v.." op:"..op.." m1:"..m1.." m2:"..m2.." m3:"..m3.." rb:"..relative_base)
			end
			if f[op](m1,m2,m3) == 1 then break end
		end
		return p0
	end

	if delay_run then
		local co = coroutine.create(function() run() end)
		return function()
			local status, e = coroutine.resume(co)
			if e then print(e) error("coroutine error") end
			return coroutine.status(co) ~= 'dead'
		end
	else
		return run()
	end
end

function intcode.run_program_iterator_list(pl)
	local done = false
	while not done do
		done = true
		for _,p in ipairs(pl) do
			local code, res = p()
			if code then done = false end
		end
	end
end

function intcode.make_pipe_with_linkedlist(ll)
	return {
		input = function()
			if linkedlist.empty(ll) then return nil end
			return linkedlist.popright(ll)
		end,
		output = function(v)
			linkedlist.pushleft(ll,v)
		end,
		ll = ll
	}
end

function intcode.make_input_function(values)
	local i = 1
	return function()
		local return_value = values[i]
		i = i + 1
		i = (i-1) % #values + 1
		return return_value
	end
end

function intcode.make_output_function(output_table)
	return function(v)
		if intcode.debug then print("output: "..v) end
		table.insert(output_table,v)
	end
end

return intcode