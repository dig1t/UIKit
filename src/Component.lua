-- src/UIKit/Modules/Component.lua

local Fragment = require(script.Parent.Fragment)

local Component = {}
Component.__index = Component

-- Default functions to prevent thrown errors when rendering
function Component:init()
	
end

-- Destroys an element and clears all children inside self
function Component:destroy()
	if self.context then
		if typeof(self.context) == 'Instance' then
			self.context:Destroy()
		elseif typeof(self.context) == 'table' and self.context.ui then
			self.context:destroy()
		end
	end
	
	self.ui = nil
	self.type = nil
	self.context = nil
	self.children = nil
	self.connections = nil
end

function Component:render()
	return {}
end

-- Wrap to create new components each time its called
function Component.new(ref)
	return function(...)
		local self = setmetatable(ref(), Component) -- calling ref() returns a new component
		
		self.ui = true
		self.type = 'component'
		
		local args = {...}
		local props, children, env = args[1], args[2], args[3]
		
		self.env = (typeof(props) == 'table' and props.type == 'environment') and props or args[3]
		self.props = props or {}
		
		if self.defaultProps then
			for k, v in pairs(self.props) do
				self.defaultProps[k] = v -- Overwrite default prop
			end
			
			-- Then replace the given props with
			-- any missing props filled in with defaults
			self.props = self.defaultProps
		end
		
		self.props.children = typeof(children) == 'table' and Fragment.make(
			children.type == 'element' and { children } or children
		) or Fragment.make()
		
		self:init()
		
		return self
	end
end

setmetatable(Component, {
	__call = Component.new
})

return Component