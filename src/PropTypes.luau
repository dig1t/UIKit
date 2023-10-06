--[[
-- TypeChecks props that are passed into components

-- Example of a good and bad prop

-- Define your prop types in the propTypes table
-- inside your component
Component.propTypes = {
	optionName = PropTypes.string
}

-- optionName prop passes validation
MyComponent({
	pet = "name"
})

-- optionName prop fails validation, resulting in a thrown error
MyComponent({
	pet = 12345
})

-- A function can also be passed as a propType
Component.propTypes = {
	optionName = function(propType)
		-- This allows both a string and a number
		-- to be passed as an optionName prop
		return propType == PropTypes.string or propType == PropTypes.number
	end
}

-- optionName prop passes validation
MyComponent({
	pet = "name"
})

-- optionName prop passes validation
MyComponent({
	pet = 12345
})
]]

local propTypes = {
	["string"] = "string",
	["table"] = "table",
	["number"] = "number",
	["bool"] = "boolean",
	["func"] = "function"
}

return setmetatable({}, {
	__index = function(self, propType)
		if not propTypes[propType] then
			propTypes[propType] = propType -- Reference same string instead of creating multiple
		end
		
		return propTypes[propType]
	end
})