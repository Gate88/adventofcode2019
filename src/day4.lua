local count = 0

for i=172851,675869 do
	local s = tostring(i)
	local bcount, b = 0
	local p, ok = "-1", false
	for j=1,#s do
		local c = string.sub(s,j,j)
		if p == c then
			bcount = bcount + 1
		end
		if p ~= c or j == #s then
			if bcount == 2 then
				ok = true
			end
			bcount = 1
		end
		if c < p then
			ok = false
			break
		end
		p = c
	end

	if ok then count = count + 1 end
end

print(count)