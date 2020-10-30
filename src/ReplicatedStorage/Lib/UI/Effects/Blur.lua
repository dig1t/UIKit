local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')

local import = require(ReplicatedStorage.Bootstrap).import
local Util = import('Lib/Util')

local blurFX = Lighting:FindFirstChild('UIBlur')

if not blurFX then
	blurFX = Instance.new('BlurEffect')
	blurFX.Name = 'UIBlur'
	blurFX.Size = 0
	blurFX.Parent = Lighting
end

local id = blurFX:FindFirstChild('Id')

if not id then
	id = Instance.new('StringValue')
	id.Name = 'Id'
	id.Parent = blurFX
end

local currentTween, currentId

local tweenInfo = TweenInfo.new(
	1,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

id:GetPropertyChangedSignal('Value'):Connect(function()
	if currentTween and id.Value ~= currentId then
		warn('stopped tween')
		currentTween:Cancel()
	end
end)

return function(from, to)
	if not from or not to then
		return blurFX.Size
	end
	
	blurFX.Size = from -- Set to starting position
	
	currentId = Util.randomString(8)
	id.Value = currentId
	
	RunService.Heartbeat:Wait() -- Allow connections to fire
	
	currentTween = TweenService:Create(
		blurFX,
		tweenInfo,
		{ Size = to }
	)
	
	currentTween:Play()
	
	return currentTween
end