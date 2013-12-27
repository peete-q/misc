
local Arena = {
	FORCE_SELF = 1,
	FORCE_ENEMY = 2,
}

Arena.__index = Arena

function Arena.new(w, h, seed)
	local self = {
		WIDTH = w,
		HEIGHT = h,
		
		_forces = {
			[Arena.FORCE_SELF] = {},
			[Arena.FORCE_ENEMY] = {},
		},
	}
	setmetatable(self, Arena)
	return self
end

function Arena:destroy()
end

function Arena:addUnit(force, spawn)
	local entity = spawn()
	entity._arena = self
	self._forces[force][entity] = entity
end

function Arena:getForce(nb)
	return self._forces[nb]
end

function Arena:update(ticks)
	for _, force in ipairs(self._forces) do
		for _, entity in pairs(force) do
			entity:update(ticks)
		end
	end
end

return Arena