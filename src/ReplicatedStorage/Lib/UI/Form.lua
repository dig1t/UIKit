local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInput = game:GetService('UserInputService')

local import = require(ReplicatedStorage.Bootstrap).import
local Util = import('Lib/Util')
local UK = import('Lib/UIKit')
local PropTypes = import('Lib/UIKit/PropTypes')
local Palette = import('Lib/Palette')
local Layout = import('Lib/UI/Layout')
local Component, Fragment, Element = UK.Component, UK.Fragment, UK.Element

return Component.new(function()
	local Form = {}
	
	Form.name = 'form'
	
	function Form:init()
		
	end
	
	function Form:render()
		return self.wrap
	end
	
	Form.propTypes = {
		style = PropTypes.table,
	}
	
	Box.defaultProps = {
		
	}
	
	return Form
end)