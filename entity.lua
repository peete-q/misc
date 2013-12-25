
local math2d = require("math2d")

local normalize = math2d.normalize
local dot = math2d.dot
local distance = math2d.distance
local distanceSq = math2d.distanceSq

local Entity = {
	FORCE_SELF = 1,
	FORCE_ENEMY = 2,
}

local _forces = {
	[FORCE_SELF] = {},
	[FORCE_ENEMY] = {},
}

local _defProps = {
	attack = 0,
	attackSpeed = 1,
	attackRange = 1,
	fireRange = 1,
	bodySize = 1,
	moveSpeed = 100,
}

Entity.__index = function(self, key)
	return Entity[key] or self._props[key] or _defProps[key]
end

Entity.__newindex = function(self, key, value)
	if self._props[key] or _defProps[key] then
		self._props[key] = value
	end
	error(string.format("[error] can't write entity property '%s'", key))
end

function Entity.initBg(w, h)
end

function Entity.new(force, parent, props, sprite)
	local self = {
		_force = force,
		_children = {},
		_parent = parent,
		_props = props,
		_sprite = sprite,
		_lastAttackTicks = 0,
		_targets = {},
	}
	if parent then
		parent._children[self] = self
	end
	_forces[self._force][self] = self
end

function Entity.updateTicks(ticks)
end

function Entity:moveTo(x, y)
end

function Entity:destroy()
	_forces[self._force][self] = nil
	
	for k, v in pairs(self._children) do
		v:destroy()
	end
end

function Entity:isAlive()
	return not self:isDead()
end

function Entity:isDead()
	return self.def and self.hp <= 0
end

function Entity:isInvincible()
	return self._invincible
end

function Entity:update(ticks)
	self:searchTargets()
	
	if #self._targets > 0 and self._lastAttackTicks + self.attackSpeed < ticks then
	end
end

function Entity:searchTargets(force)
	if not force then
		force = self:getHostileForce()
	end
end

function Entity:getHostileForce()
	if self._force == self.FORCE_SELF then
		return self.FORCE_ENEMY
	end
	return self.FORCE_SELF
end

function Entity:isInRange(target, range)
  if target == nil then
    return false
  end
  if target:isDead() then
    return false
  end
  if range == nil then
    range = self.def.attackRange
  end
  local x, y = target:getWorldLoc()
  return self:isPtInRange(x, y, range)
end

function Entity:isPtInRange(x, y, range)
  if range == nil then
    range = self.def.attackRange
  end
  local _x, _y = self:getWorldLoc()
  return distanceSq(x, y, _x, _y) < (range ^ 2)
end

function Entity:distance(other)
  local x, y = self:getWorldLoc()
  local _x, _y = other:getWorldLoc()
  return distance(x, y, _x, _y)
end

function Entity:applyDamage(amount, source)
end