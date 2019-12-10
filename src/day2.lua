io.input("input/day2_input.txt")
input_s = io.read("*all") 

function run_program(program, modify)
	local p, i = {}, 0
	for n in string.gmatch(program, "[^,]+") do
		p[i] = tonumber(n)
		i = i + 1
	end

	i = 0
	modify(p)

	f = {
		[1] = function()
			p[p[i+3]] = p[p[i+1]] + p[p[i+2]]
			i = i + 4
		end,
		[2] = function()
			p[p[i+3]] = p[p[i+1]] * p[p[i+2]]
			i = i + 4
		end,
		[99] = function()
			return 1
		end
	}

	while true do
		if f[p[i]]() == 1 then break end
	end
	return p[0]
end

for i=0,99 do
	for j=0,99 do
		if run_program(input_s, function(p) p[1], p[2] = i, j end) == 19690720 then
			print(100*i+j)
			os.exit()
		end
	end
end