local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')

local Blur = require(script.Blur)

local defaultDuration = 1

local Effects = {}

Effects.blur = Blur

Effects.tweenPos = function(obj, from, to)
	if typeof(obj) == 'table' and obj.type == 'element' then
		obj = obj.context
	end
	
	assert(obj, 'fx.tweenPos - Missing object')
	
	obj.Position = from
	
	local tween = TweenService:Create(
		obj,
		TweenInfo.new(
			defaultDuration,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.InOut
		),
		{ Position = to }
	)
	
	tween:Play()
	
	return tween
end

return Effects