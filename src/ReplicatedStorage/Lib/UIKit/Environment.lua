-- src/UIKit/Modules/Environment.lua

local red = require(script.Parent.Parent.red)

return function(tbl)
	local self = red.State.new(tbl)
	
	self.ui = true
	self.type = 'environment'
	
	return self
end