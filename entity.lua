
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

local _entityDef = {
	attack = 0,
	attackSpeed = 1,
	attackRange = 1,
	moveSpeed = 100,
}

Entity._forces = _forces
Entity.__index = Entity

function Entity.new(force, parent, def)
	local self = {
		_force = force,
		_children = {},
		_parent = parent,
	}
	if parent then
		parent._children[self] = self
	end
	_forces[self._force][self] = self
end

function Entity.update(dt)
end

function Entity.updateTicks()
end

function Entity:destroy()
	_forces[self._force][self] = nil
	if self._parent then
		self._parent[self] = nil
	end
end

function Entity:isAlive()
	return not self:isDead()
end

function Entity:isDead()
	return self.def and self.hp <= 0
end

function Entity:onUpdate(dt)
end

function Entity:onUpdateTicks()
end

function Entity:searchTarget()
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