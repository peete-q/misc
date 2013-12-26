
local math2d = require("math2d")

local distance = math2d.distance
local distanceSq = math2d.distanceSq

local none = false

local Entity = {
	FORCE_SELF = 1,
	FORCE_ENEMY = 2,
}

local _forces = {
	[Entity.FORCE_SELF] = {},
	[Entity.FORCE_ENEMY] = {},
}

local _forceWorlds = {
}

local _defaultProps = {
	hp = 100,
	attackPower = 0,
	attackSpeed = 1,
	attackRange = 100,
	guardRange = 1000,
	bodySize = 10,
	moveSpeed = 10,
	kind = 0,
}

Entity.__index = function(self, key)
	return Entity[key] or self._props[key] or _defaultProps[key]
end

Entity.__newindex = function(self, key, value)
	if self._props[key] or _defaultProps[key] then
		self._props[key] = value
		return
	end
	error(string.format("[error] can't write entity property '%s'", key))
end

function Entity.initBg(w, h)
end

function Entity.new(force, props, sprite)
	local self = {
		_force = force,
		_children = {},
		_props = props or {},
		_sprite = sprite or none,
		_motionDriver = none,
		_target = none,
		_lastAttackTicks = 0,
		_attackPriorities = {},
	}
	_forces[self._force][self] = self
	
	setmetatable(self, Entity)
	return self
end

function Entity.updateTicks(ticks)
	for i, f in ipairs(_forces) do
		for k, v in pairs(f) do
			v:update(ticks)
		end
	end
end

function Entity:destroy()
	_forces[self._force][self] = nil
	
	for k, v in pairs(self._children) do
		v:destroy()
	end
	
	if self._motionDriver then
		self._motionDriver:destroy()
	end
	
	if self._rigid then
		self._rigid:destroy()
		self._rigid = none
	end
end

function Entity:getWorldLoc()
	return self._sprite:getLoc()
end

function Entity:moveTo(x, y)
	-- self:_cancelRigid()
	self:stop()
	self._motionDriver = self._sprite:seekLoc(x, y, self.moveSpeed, MOAIEaseType.LINEAR)
end

function Entity:isMoving()
	return self._motionDriver and self._motionDriver:isBusy()
end

function Entity:stop()
	if self:isMoving() then
		self._motionDriver:stop()
		self._motionDriver = none
	end
end

function Entity:_doRigid()
	assert(not self._rigid)
	self._rigid = _forceWorlds[self._force]:addBody(MOAIBox2DBody.DYNAMIC)
	local x, y = self:getWorldLoc()
	self._rigid:addCircle(x, y, self.bodySize)
end

function Entity:_cancelRigid()
	if self._rigid then
		self._rigid:destroy()
		self._rigid = none
	end
end

function Entity:_checkStop()
	if self._target and self:isMoving() and self:isInRange(self._target) then
		self:stop()
	end
	
	if not self._rigid and not self:isMoving() then
		-- self:_doRigid()
	end
end

function Entity:isAlive()
	return self.hp > 0
end

function Entity:isDead()
	return self.hp <= 0
end

function Entity:isInvincible()
	return self._invincible
end

function Entity:update(ticks)
	self:_checkStop()
	
	if self._target and self._target:isDead() then
		self._target = none
	end
	
	if not self._target then
		self._target = self:_searchAttackTarget()
		if self._target then
			self:chase(self._target)
		end
	end
	
	if self._target and self._lastAttackTicks + self.attackSpeed < ticks then
		if self:isInRange(self._target) then
			self:attack(self._target)
		end
	end
end

function Entity:chase(target)
	local x, y = target:getWorldLoc()
	x = math.random(x - self.attackRange, x + self.attackRange)
	self:moveTo(x, y)
end

function Entity:attack(target)
	target = target or self._target
	target:applyDamage(self.attackPower)
end

function Entity:attackPriority(target)
	return self._attackPriorities[target.kind] or 0
end

function Entity:_searchAttackTarget()
	local force = self:getHostileForce()
	local dist = self.guardRange ^ 2
	local priority = 0
	local target = none
	for k, v in pairs(force) do
		local d = self:distanceSq(v)
		local p = self:attackPriority(v)
		if p > priority or (p == priority and d < dist) then
			priority = p
			dist = d
			target = v
		end
	end
	return target
end

function Entity:getMyForce()
	if self._force == self.FORCE_SELF then
		return _forces[self.FORCE_SELF]
	end
	return _forces[self.FORCE_ENEMY]
end

function Entity:getHostileForce()
	if self._force == self.FORCE_SELF then
		return _forces[self.FORCE_ENEMY]
	end
	return _forces[self.FORCE_SELF]
end

function Entity:isInRange(target, range)
	if not target then
		return false
	end
	if target:isDead() then
		return false
	end
	range = range or self.attackRange
	local x, y = target:getWorldLoc()
	return self:isPtInRange(x, y, range)
end

function Entity:isPtInRange(x, y, range)
	range = range or self.attackRange
	local _x, _y = self:getWorldLoc()
	return distanceSq(x, y, _x, _y) < (range ^ 2)
end

function Entity:distance(other)
	local x, y = self:getWorldLoc()
	local _x, _y = other:getWorldLoc()
	return distance(x, y, _x, _y)
end

function Entity:distanceSq(other)
	local x, y = self:getWorldLoc()
	local _x, _y = other:getWorldLoc()
	return distanceSq(x, y, _x, _y)
end

function Entity:applyDamage(amount, source)
end

return Entity