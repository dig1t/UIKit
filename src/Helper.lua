-- src/UIKit/Modules/Helper.lua

local Util = require(script.Parent.dLib.Util)
local Const = require(script.Parent.Constants)

local Helper = {}

function Helper.instance(className, ...)
	local props = {}
	local extraProps = {...}
	
	if Const.isUIObject[className] then
		extraProps[#extraProps + 1] = Const.resets.default
	end
	
	if Const.resets[className] then
		extraProps[#extraProps + 1] = Const.resets[className]
	end
	
	for i = 1, #extraProps do
		if typeof(extraProps[i]) == 'table' then
			for name, value in pairs(extraProps[i]) do
				props[name] = value
			end
		end
	end
	
	return function(data)
		local obj = Instance.new(className)
		
		if data then
			Util.extend(props, data)
			
			for k, v in pairs(props) do
				if type(k) == 'number' then
					-- Check if child is an uncalled Helper.instance() variable
					if type(v) == 'function' then
						v = v() -- Call to convert into a roblox instance
					end
					
					-- Set the parent
					v.Parent = obj
				elseif k ~= 'Parent' then -- Always set parent last
					obj[k] = v
				end
			end
			
			-- Default transparency prop is 1, if a color is given then set to 0
			if data.BackgroundColor3 and not data.BackgroundTransparency then
				obj.BackgroundTransparency = 0
				obj.BorderSizePixel = 0
			end
			
			-- If background transparency prop exists, remove the default border
			if data.BackgroundTransparency and not data.BorderSizePixel then
				obj.BorderSizePixel = 0
			end
			
			if props.Parent then
				obj.Parent = props.Parent
			end
		end
		
		return obj
	end
end

function Helper.processComponent(el, child, env)
	el.env = el.env or env -- Pass environment
	el.context = el:render() -- Children Fragment of above element
	el.rendered = true -- remove?
	el = el.context
	el.env = el.env or env -- Pass environment into rendered element
	
	if not el.children and el.type == 'component' then
		el = Helper.processComponent(el, child, env) -- Keep processing down the tree until it returns children or nil
	end
	
	return el
end

function Helper.processComponent2(el, child, env)
	el.env = el.env or env -- Pass environment
	el = el:render() -- Children Fragment of above element
	el.env = el.env or env -- Pass environment into rendered element
	
	if not el.children and el.type == 'component' then
		el = Helper.processComponent(el, child, env) -- Keep processing down the tree until it returns children or nil
	end
	
	return el
end

function Helper.renderLoop(parent, child, env)
	if child.type == 'component' and not child.children then
		child.children = child:render()
		Helper.renderLoop(parent, Helper.processComponent(child), env)
	end
	
	for i, el in ipairs(child.children) do
		-- If not a fragment/component then convert to a fragment/component
		if typeof(el) == 'function' then -- Component function
			el = el() -- Get returned component
		elseif el.type == 'component' and not el.context then
			el = Helper.processComponent(el, child, env)
		end
		
		if el.type == 'component' and not el.context then
			-- Loop through components until there is context
			Helper.renderLoop(parent, el, env)
		elseif (el.type == 'component' and el.context) or el.type == 'element' then
			if el.type == 'component' then
				el.env = el.env or env
			end
			
			el.context.Parent = parent
			
			if el.children then
				Helper.renderLoop(el.context, el.children, env)
			end
		elseif el.type == 'fragment' then
			if child.type == 'fragment' then
				Helper.renderLoop(parent, el, env)
			else
				Helper.renderLoop(el, el.children, env)
			end
		end
	end
end

return Helper