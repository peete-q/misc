

function calc1(P, R, N)
	local r = R / 12
	local n = N * 12
	local m = P * ((r * ((1 + r) ^ n)) / (((1 + r) ^ n) - 1))
	io.output():write(string.format('A+,%d %.4f\t', N, m))
	local i = 5
	while i <= N do
		io.output():write(string.format('%.2f\t', m * i * 12))
		i = i + 5
	end
	io.output():write('\n')
end

function calc1_r(P, R, N)
	local r = R / 12
	local n = N * 12
	local m = P * ((r * ((1 + r) ^ n)) / (((1 + r) ^ n) - 1))
	local function year(n)
		local p = P
		local v = 0
		for i = 1, n * 12 do
			v = v + p * r
			p = p - (m - p * r)
		end
		return v
	end
	io.output():write(string.format('A-,%d %.4f\t', N, P * r))
	local i = 5
	while i <= N do
		io.output():write(string.format('%.2f\t', year(i)))
		i = i + 5
	end
	io.output():write('\n')
end

function calc2(P, R, N)
	local r = R / 12
	local q = P / (N * 4)
	local function nth_quarter(n)
		return (P - q * (n - 1)) * (R / 4) + q
	end
	local function year(n)
		local v = 0
		for i = 1, n * 4 do
			v = v + nth_quarter(i)
		end
		return v
	end
	io.output():write(string.format('B+,%d %.4f\t', N, nth_quarter(1) / 3))
	local i = 5
	while i <= N do
		io.output():write(string.format('%.2f\t', year(i)))
		i = i + 5
	end
	io.output():write('\n')
end

function calc2_r(P, R, N)
	local r = R / 12
	local q = P / (N * 4)
	
	local function r_nth_quarter(n)
		return (P - q * (n - 1)) * (R / 4)
	end
	local function r_year(n)
		local v = 0
		for i = 1, n * 4 do
			v = v + r_nth_quarter(i)
		end
		return v
	end
	io.output():write(string.format('B-,%d %.4f\t', N, P * r))
	local i = 5
	while i <= N do
		io.output():write(string.format('%.2f\t', r_year(i)))
		i = i + 5
	end
	io.output():write('\n')
end

function calc(P, R, N)
	calc1(P, R, N)
	calc2(P, R, N)
end

-- calc(P, R, 10)
-- calc(P, R, 15)
-- calc(P, R, 20)
-- calc(P, R, 25)
-- calc(P, R, 30)

local P, R = 70, 0.0655 * 0.85
calc1(P, R, 5)
calc1(P, R, 10)
calc1(P, R, 15)
calc1(P, R, 20)
calc1(P, R, 25)
calc1(P, R, 30)
calc2(P, R, 5)
calc2(P, R, 10)
calc2(P, R, 15)
calc2(P, R, 20)
calc2(P, R, 25)
calc2(P, R, 30)

calc1_r(P, R, 5)
calc1_r(P, R, 10)
calc1_r(P, R, 15)
calc1_r(P, R, 20)
calc1_r(P, R, 25)
calc1_r(P, R, 30)
calc2_r(P, R, 5)
calc2_r(P, R, 10)
calc2_r(P, R, 15)
calc2_r(P, R, 20)
calc2_r(P, R, 25)
calc2_r(P, R, 30)
