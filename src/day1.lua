function get_fuel(m)
	local fuel = math.floor(m/3)-2
	if fuel <= 0 then return 0 end
	return fuel + get_fuel(fuel)
end

io.input("input/day1_input.txt")

local n, sum = nil, 0
repeat
	n = io.read()
	if not n then break end
	sum = sum + get_fuel(n)
until false

print(sum)