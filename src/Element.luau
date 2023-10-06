local Util = require(script.Parent.dLib.Util)
local Fragment = require(script.Parent.Fragment)
local Const = require(script.Parent.Constants)
local Helper = require(script.Parent.Helper)

local Element, methods = {}, {}
methods.__index = methods

--[[function methods.__index(self, key)
	return self[key] or (self.context and self.context[key] or nil)
end]]

function methods.__newindex(self, key, value) -- Can set the Instance property but not get
	if not self.context or not pcall(function()
		self.context[key] = value
	end) then
		rawset(self, key, value)
	end
end

-- Connects an event listener to the element and returns the connection
-- Usage: connect(string connectionType, function fn)
function methods:connect(connectionType, fn)
	assert(connectionType, "Missing connection type")
	assert(typeof(fn) == "function", "Missing callback function")
	
	if not self.connections then
		return
	end
	
	local id = Util.randomString(8)
	
	self.connections[id] = self.context[connectionType]:Connect(fn) -- Return the connection for reference
	
	return self.connections[id]
end

-- Connects an event listener to the element and returns the connection
-- Usage: connect(string connectionType, function fn)
function methods:propertyChanged(property, fn)
	assert(property, "Missing property name")
	assert(typeof(fn) == "function", "Missing callback function")
	
	if not self.connections then
		return
	end
	
	local id = Util.randomString(8)
	
	self.connections[id] = self.context:GetPropertyChangedSignal(property):Connect(fn) -- Return the connection for reference
	
	return self.connections[id]
end

function methods:disconnect(connection)
	if typeof(connection) == "RBXScriptConnection" then
		connection:Disconnect()
		
		for id, v in pairs(self.connections) do
			if v == connection then
				self.connections[id] = nil
				break
			end
		end
	elseif typeof(connection) == "string" and self.connections[connection] then
		self.connections[connection]:Disconnect()
		self.connections[connection] = nil
	end
end

-- Inserts elements/components/fragments into the element
-- Usage: appendChild(Fragment || Element || Component)
function methods:appendChild(child)
	if typeof(child) == "Instance" then
		child.Parent = self.context
	elseif typeof(child) == "table" then
		if child.ui then
			if child.type == "component" and not child.children then
				-- Process component, then wrap child in a fragment so it renders
				-- Otherwise it would render the child's children, which it
				-- does not have
				child = Fragment(Helper.processComponent(child, self, self.env))
				Helper.renderLoop(self.context, child, self.env)
			elseif child.type == "element" then
				child.context.Parent = self.context
				Helper.renderLoop(child.context, child.children, self.env)
			end
		else
			for _, v in pairs(child) do
				if typeof(v) == "Instance" then
					v.Parent = self.context
				end
			end
		end
	end
	
	return child
end

-- Destroys an element and clears all children inside self
function methods:destroy()
	if self.destroyed then
		return -- Element already destroyed
	end
	
	for id, connection in pairs(self.connections) do
		connection:Disconnect()
		--self.connections[id] = nil
	end
	
	-- Destroy all children at the end of the ancestry tree FIRST.
	-- The last child will be removed and will loop up the
	-- ancestry tree until this element is reached, ensuring
	-- there are no traces of its children to prevent memory leaks.
	if self.children.ui then
		self.children:destroy()
	else
		for _, el in pairs(self.children) do
			if typeof(el) == "table" and el.ui and el.destroy then
				el:destroy()
			elseif typeof(el) == "Instance" then
				el:Destroy()
			end
		end
	end
	
	if self.context then
		self.context:Destroy()
	end
	
	--[[for name, v in pairs(self) do
		self[name] = nil
	end]]
	
	self.ui = nil
	self.type = nil
	self.context = nil
	self.children = nil
	self.connections = nil
	self.destroyed = true
end

-- Begin shortcut functions
-- Returns the children of the element
-- Usage: getChildren()
function methods:getChildren()
	return self.context and self.context:GetChildren()
end

function methods:absPosition()
	return self.context and self.context.AbsolutePosition
end

function methods:absSize()
	return self.context and self.context.AbsoluteSize
end

function methods:absRotation()
	return self.context and self.context.AbsoluteRotation
end

function methods:textBounds()
	return self.context and Const.isTextObject[self.context.ClassName] and self.context.TextBounds
end

function methods:textFits()
	return self.context and Const.isTextObject[self.context.ClassName] and self.context.TextFits
end

function methods:isVisible()
	return self.context and self.context.Visible
end
-- End shortcut functions

-- Clears the element's children
-- Usage: clear()
function methods:clear()
	if self.context then
		self.context:ClearAllChildren()
	end
end

-- Toggles the element from visible to invisible or invisible to visible
-- Usage: toggle()
function methods:toggle()
	if self.context then
		self.context.Visible = not self.context.Visible
	end
end

-- Displays/hides the element
-- Usage: display(boolean visible = true)
function methods:display(visible)
	if self.context then
		if visible == nil then
			visible = true
		end
		
		self.context.Visible = visible
	end
end

-- Shows the element
-- Usage: show()
function methods:show()
	self:display()
end

-- Hides the element
-- Usage: hide()
function methods:hide()
	self:display(false)
end

-- Sets the text of a text element, if empty then the element text will be returned
-- Usage: text(string text = nil)
function methods:text(value)
	if self.context and Const.isTextObject[self.context.ClassName] then
		if value then
			self.context.Text = value
		else
			return self.context.Text
		end
	end
end

-- Sets the image of an element
-- Usage: image(number id)
function methods:image(id)
	if self.context and Const.isImageObject[self.context.ClassName] then
		if id == "" then
			self.context.Image = ""
		elseif id then
			-- set
			self.context.Image = typeof(id) == "number" and "rbxassetid://" .. id or id
		else
			return self.context.Image
		end
	end
end

-- Sets the size of an element
-- Usage: size(UDim2)
function methods:size(value)
	if self.context then
		if value then
			self.context.Size = value
		else
			return self.context.Size
		end
	end
end

-- Sets the position of an element
-- Usage: position(UDim2)
function methods:position(value)
	if self.context then
		if value then
			self.context.Position = value
		else
			return self.context.Position
		end
	end
end

-- Sets the color of an element, if flag is true and the
-- element is a text/image frame then the text/image color will be changed
-- Usage: color(Color3, boolean flag = false)
function methods:color(value, flag)
	if self.context then
		if not value and not flag then
			return self.context.BackgroundColor3
		elseif not flag then
			self.context.BackgroundColor3 = value
		end
		
		if Const.isImageObject[self.context.ClassName] then
			if not value then
				return self.context.ImageColor3
			end
			
			self.context.ImageColor3 = value
		elseif Const.isTextObject[self.context.ClassName] then
			if not value then
				return self.context.TextColor3
			end
			
			self.context.TextColor3 = value
		end
	end
end

-- Merges multiple props into one table
-- Usage: mergeProps(style.box, { Name = "Container" }, ...)
function Element.mergeProps(...)
	local res = {}
	local list = {...}
	
	for i = #list, 1, -1 do
		if typeof(list[i]) == "table" then
			Util.extend(res, list[i])
		end
	end
	
	return res
end

setmetatable(Element, {
	__call = function(tbl, el, config, children)
		local self = setmetatable({}, methods)
		
		self.ui = true
		self.type = "element"
		self.connections = {}
		
		if not config then
			config = {}
		end
		
		if typeof(el) == "string" then
			local connections = config.connections
			config.connections = nil
			
			self.context = Helper.instance(el)(config)
			self.children = typeof(children) == "table" and Fragment.make(
				children.type == "element" and { children } or children
			) or Fragment.make()
			
			if connections then
				for connectionType, fn in pairs(connections) do
					self:connect(connectionType, fn)
				end
			end
			
			if Const.isTextObject[el] and typeof(children) == "string" then
				self.context.Text = children
			end
		end
		
		return self
	end
})

return Element