----------------------------------------------------------------
-- Copyright (c) 2010-2011 Zipline Games, Inc. 
-- All Rights Reserved. 
-- http://getmoai.com
----------------------------------------------------------------

local function printf ( ... )
	return io.stdout:write ( string.format ( ... ))
end 

MOAISim.openWindow ( "test", 320, 240 )

W, H = 320, 240
viewport = MOAIViewport.new ()
viewport:setSize ( W, H )
viewport:setScale ( W, H )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

-- set up the world and start its simulation
world = MOAIBox2DWorld.new ()
-- world:setGravity ( 0, -10 )
world:setUnitsToMeters ( 1 )
world:start ()
layer:setBox2DWorld ( world )

local Entity = require "Entity"
local timer = require "timer"

local R = 10
local texture = MOAIGfxQuad2D.new ()
texture:setTexture ( 'bg.png' )
texture:setRect ( -R, -R, R, R )

function newspr(x, y)
	local sprite = MOAIProp2D.new ()
	sprite:setDeck ( texture )
	sprite:setParent ( body )
	layer:insertProp ( sprite )
	sprite:setLoc(x, y)
	return sprite
end

local ticks = 0
timer.new(0.1, function()
	Entity.updateTicks(ticks)
	ticks = ticks + 1
end)


function pointerCallback(x, y)
    X, Y = layer:wndToWorld(x, y)
end

function clickCallbackL(down)
	if down then
		local e = Entity.new(1, nil, newspr(X, Y))
	end
end

function clickCallbackR(down)
	if down then
		for i = 1, 10 do
			local x = math.random(-W/3, W/3)
			local e = Entity.new(2, nil, newspr(x, -H/2))
			e:moveTo(x, H / 2)
		end
	end
end

if MOAIInputMgr.device.pointer then
	-- mouse input
	MOAIInputMgr.device.pointer:setCallback(pointerCallback)
	MOAIInputMgr.device.mouseLeft:setCallback(clickCallbackL)
	MOAIInputMgr.device.mouseRight:setCallback(clickCallbackR)
else
	-- touch input
	MOAIInputMgr.device.touch:setCallback (function(eventType, idx, x, y, tapCount)
		if idx ~= 0 then
			return
		end
		pointerCallback(x, y)
		if eventType == MOAITouchSensor.TOUCH_DOWN then
			clickCallback(true)
		elseif eventType == MOAITouchSensor.TOUCH_UP then
			clickCallback(false)
		end
	end)
end