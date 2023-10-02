local Fragment, methods = {}, {}
methods.__index = methods

function methods:insert(el)
	table.insert(self.children, el)
end

function methods:destroy()
	for _, el in pairs(self.children) do
		if typeof(el) == 'Instance' then
			el:Destroy()
		elseif typeof(el) == 'table' and el.ui then
			el:destroy()
		end
	end
end

Fragment.make = function(tbl)
	local self = setmetatable({}, methods)
	
	self.ui = true
	self.type = 'fragment'
	self.children = tbl or {}
	
	return self
end

-- Fragments hold all the Roblox instances for components and elements
setmetatable(Fragment, {
	__call = function(tbl, ...) -- Fragment
		return Fragment.make({...})
	end
})

return Fragment