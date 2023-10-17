local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local import = require(script.Parent.dLib).import
local Util = import("Util")
local Component = require(script.Component)
local Fragment = require(script.Fragment)
local Element = require(script.Element)
local Helper = require(script.Helper)
local Environment = require(script.Environment)
local PropTypes = require(script.PropTypes)

local UK, methods = {}, {}
methods.__index = methods

UK.robloxNavbarHeight = 35

UK.type = {
	billboard = "BillboardGui",
	screen = "ScreenGui",
	surface = "SurfaceGui"
}

UK.PropTypes = PropTypes
UK.Component = Component
UK.Fragment = Fragment
UK.Element = Element
UK.Helper = Helper
UK.Environment = Environment
UK.createElement = Element

local player = Players.LocalPlayer

-- Usage: local UK = require(Bootstrap.UIKit).src(Bootstrap.src)
function UK.src(location)
	assert(location, "UK.src - Source folder missing")
	assert(
		typeof(location) == "Instance" and location:IsA("Folder"),
		"UK.src - Source must be a Folder instance"
	)
	
	UK.sourceFolder = location
	
	return UK
end

function UK.setEnv(environment)
	assert(
		typeof(environment) == "table" and environment.type == "environment",
		"UK.setEnv - Missing environment states"
	)
	
	UK.env = environment
	
	return UK
end

function UK.import(path)
	assert(UK.sourceFolder, "Source folder must be set with UK.src(location) before importing")
	assert(typeof(path) == "string", "Path is not a string")
	
	local res = Util.treePath(UK.sourceFolder, path, "/")
	
	if res and res:IsA("ModuleScript") then
		local success, err = pcall(function()
			res = require(res)
		end)
		
		if not success then
			error(err)
		end
	end
	
	return res
end

function UK.loadModules(from)
	local res = {}
	
	for _, moduleScript in pairs(from) do
		if moduleScript:IsA("ModuleScript") then
			local module = moduleScript.Name
			
			--local success, err = pcall(function()
				res[module] = require(moduleScript)
				
				if typeof(res[module]) == "function" then
					res[module] = res[module](UK.env) -- Inject the environment
				end
			--[[end)
			
			if not success then
				error(err)
			end]]
		end
	end
	
	return res
end

function UK.setMouseIcon(icon)
	if UserInputService.MouseEnabled then
		local mouse = player:GetMouse()
		
		if mouse then
			mouse.Icon = icon
		end
	end
end

-- This shortcut works best when defining constants or in a one time component render
function UK.getAsset(name, scale, assetType)
	assert(name, "UK.getAsset - Missing asset name")
	
	local localAsset = typeof(name) == "string"
	
	return string.format(
		"rbx%s://%s",
		localAsset and "gameasset" or "assetid", -- Is asset local to the game or available on roblox?
		localAsset and ((assetType or "Images") .. "/" .. name .. (scale or "@1x")) or name -- asset location
	)
end

-- Begin ui methods
function methods:destroy()
	self.context:Destroy()
	self.context = nil
end
-- End ui methods

-- @desc renders to a gui screen
-- @param string screenType? - The type of gui screen to use (ScreenGui, BillboardGui, ...)
-- @param string name - Name of the screen
-- @param table child - Element to render into the screen
-- @param table parent - Instance to render child into
-- @return root table
function UK.render(...) -- screenType (optional), name, child, parent
	local args = {...}
	local screenType = "ScreenGui"
	
	if #args == 4 then
		screenType = args[1]
		Util.tableRemove(args, 1)
	end
	
	assert(args[2].ui, "Not a valid component")
	
	local name, child, parent = args[1], args[2], args[3]
	
	-- Begin class setup
	local self = setmetatable({}, methods)
	
	self.ui = true
	self.type = "root"
	
	self.context = Instance.new(screenType, parent)
	self.context.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.context.Name = name
	
	if screenType == "SurfaceGui" then
		self.context.Adornee = parent
		self.context.ClipsDescendants = true
	end
	-- End class setup
	
	child.env = UK.env -- Environment variable to pass down the render tree
	
	if child.type == "component" then
		child = Fragment(child) -- Wrap the initialized component inside a fragment
		--[[child:init() -- Initialize component before rendering it
		child = child:render() -- returns the Fragment of the initial child
		child.env = UK.env -- Inject the environment table/state]]
	end
	
	if child.type == "element" then
		child.context.Parent = self.context
	elseif child.type == "fragment" then
		Helper.renderLoop(self.context, child, UK.env)
	end
	
	return self
end

return UK