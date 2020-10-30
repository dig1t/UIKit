--[[
This library was made for the UIKit framework to help design responsive UI
]]
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local UserInput = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')
local Players = game:GetService('Players')

local import = require(ReplicatedStorage.Bootstrap).import
local Util = import('Lib/Util')

local Device = {}

-- Defined breakpoints (Mobile, Tablet, Laptop, Desktop, 4k)
-- Breakpoints are thresholds that trigger responsive elements to resize/reshape
-- To adjust for different devices

local breakpoints = {
	['phone-small'] = 320,
	['phone'] = 375,
	['phone-large'] = 425,
	
	['tablet-small'] = 580,
	['tablet-medium'] = 700,
	['tablet'] = 768,
	['tablet-large'] = 860,
	
	['laptop'] = 1024,
	['laptop-medium'] = 1200,
	['laptop-large'] = 1440,
	
	['desktop-small'] = 1600,
	['desktop'] = 1920,
	
	['4k'] = 2560
}

local breakpointsFlipped = Util.flip(breakpoints)
local breakpointsMapped = Util.map(breakpoints, function(px)
	return px
end)

table.sort(
	breakpointsMapped,
	function(a, b)
		return a > b
	end
)

-- Begin screen class
local methods = {}
methods.__index = methods

function methods:getSize()
	return self._obj.AbsoluteSize
end

function methods:getWidth()
	return self._obj.AbsoluteSize.X
end

function methods:hasTouchControls()
	return UserInput.TouchEnabled and not UserInput.MouseEnabled and not GuiService:IsTenFootInterface()
end

function methods:isMobile() -- deprecated
	return self:inBreakpoint('phone-large')
end

function methods:getBreakpoint()
	local width = self:getWidth()
	local pointPx
	
	for _, threshold in ipairs(breakpointsMapped) do
		pointPx = threshold
		
		if width > threshold then
			break
		end
	end
	
	return breakpointsFlipped[pointPx]
end

function methods:inBreakpoint(target)
	return breakpoints[target] and breakpoints[self.lastBreakpoint] <= breakpoints[target]
end

function methods:watchBreakpointChange(fn)
	if not self._connections.sizeListener then
		self.lastBreakpoint = self:getBreakpoint()
		
		self._connections.sizeListener = self._obj:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
			local breakpoint = self:getBreakpoint()
			
			-- Avoid calling all listeners for the same breakpoint
			if self.lastBreakpoint ~= breakpoint then
				self.lastBreakpoint = breakpoint
				
				for _, callback in pairs(self._listeners) do
					callback()
				end
			end
		end)
	end
	
	local connectionId = Util.randomString(8)
	
	self._listeners[connectionId] = fn
	self._listeners[connectionId](self.lastBreakpoint)
	
	return connectionId
end

function methods:unwatchBreakpointChange(id)
	self._listeners[id] = nil
	
	-- Disconnect the size listener since changes are no longer being watched
	if #self._listeners == 0 and self._connections.sizeListener then
		self._connections.sizeListener:Disconnect()
		self._connections.sizeListener = nil
	end
end
-- End screen class

do -- Construct screen
	local screen = setmetatable({}, methods)
	
	screen._connections = {}
	screen._listeners = {}
	screen._obj = Players.LocalPlayer:WaitForChild('PlayerGui') and Players.LocalPlayer:FindFirstChild('DeviceScreen')
	
	screen.breakpoints = breakpointsFlipped
	
	if not screen._obj then -- If no ScreenGui was created yet, create one
		screen._obj = Instance.new('ScreenGui')
		screen._obj.Name = 'DeviceScreen'
		screen._obj.ResetOnSpawn = false
		screen._obj.Parent = Players.LocalPlayer.PlayerGui
	end
	
	screen.lastBreakpoint = screen:getBreakpoint()
	
	Device.screen = screen
end

function Device.isConsole()
	return GuiService:IsTenFootInterface()
end

function Device.isMobile()
	local lastInputType = UserInput:GetLastInputType()
	
	return UserInput.TouchEnabled and not UserInput.KeyboardEnabled and not UserInput.MouseEnabled
end

return Device