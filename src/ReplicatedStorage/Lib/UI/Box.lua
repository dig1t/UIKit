local ReplicatedStorage = game:GetService('ReplicatedStorage')
local UserInput = game:GetService('UserInputService')

local import = require(ReplicatedStorage.Bootstrap).import
local Util = import('Lib/Util')
local UK = import('Lib/UIKit')
local PropTypes = import('Lib/UIKit/PropTypes')
local Palette = import('Lib/Palette')
local Layout = import('Lib/UI/Layout')
local Component, Fragment, Element = UK.Component, UK.Fragment, UK.Element

local assets = {
	circle = 'rbxassetid://4749586409',
	circleHalf = 'rbxassetid://4749591292',
	circleLeftHalf = 'rbxassetid://5160664998',
	
	circleOutline = 'rbxassetid://5167155027',
	circleOutlineLight = 'rbxassetid://5167159228'
}

return Component.new(function()
	local Box = {}
	
	Box.name = 'box'
	
	function Box:init()
		self.content = self.props.padding and Element(
			self.props.contentType or 'Frame',
			
			Element.mergeProps({
				Name = 'Content';
				Size = UDim2.new(1, 0, 1, 0);
				Rotation = self.props.flipVertical and -180 or 0;
			}, self.props.contentStyle or {}),
			
			{ self.props.children }
		)
		
		--[[do
			if self.props.half == true then -- rounded top side
				image = assets.circleHalf
			elseif self.half == 'left' then -- rounded left side
				image = assets.circleLeftHalf
			else -- all sides rounded
				image = assets.circle
			end
		end]]
		
		self.wrap = Element(
			self.props.boxType,
			
			Element.mergeProps({
				Name = self.props.name;
				Position = self.props.position;
				Size = self.props.size or UDim2.new(1, 0, 1, 0);
				Rotation = self.props.flipVertical and 180 or self.props.rotation;
				Visible = self.props.visible;
				Image = (
					self.props.half == true and assets.circleHalf
				) or (
					self.props.half == 'left' and assets.circleLeftHalf
				) or assets.circle, -- fallback to default circle
				ImageColor3 = self.props.color;
				ImageTransparency = self.props.transparency;
				ScaleType = Enum.ScaleType.Slice;
				SliceCenter = Rect.new(100, 100, 100, 100);
				ZIndex = self.props.zIndex;
			}, self.props.style or {}),
			
			self.content and {
				self.content,
				Layout.padding(self.props.padding)
			} or { self.props.children }
		)
		
		if self.props.outline then
			self.outline = self.wrap:appendChild(Element(
				self.props.outlineType,
				
				Element.mergeProps(self.props.outlineStyle or {}, {
					Name = 'Outline';
					Position = UDim2.new(0, -1, 0, -1);
					Size = UDim2.new(1, 2, 1, 2);
					Image = self.props.outlineSize == 'normal' and assets.circleOutline or assets.circleOutlineLight;
					ImageColor3 = Palette('grey', 500);
					ScaleType = Enum.ScaleType.Slice;
					SliceCenter = Rect.new(100, 100, 100, 100);
					SliceScale = self.props.borderRadius / 100;
					ZIndex = 2;
				})
			))
		end
		
		if not self.content then
			self.content = self.wrap
		end
		
		self:setBorderRadius()
	end
	
	function Box:setBorderRadius(rad)
		self.wrap.SliceScale = (rad or self.props.borderRadius) / 100
	end
	
	function Box:color(newColor)
		self.wrap:color(newColor, true)
	end
	
	function Box:connect(event, fn)
		self.wrap:connect(event, fn)
	end
	
	function Box:transparency(val)
		self.wrap.context.ImageTransparency = val
	end
	
	function Box:appendChild(child)
		return self.content:appendChild(child)
	end
	
	function Box:getChildren()
		return self.content:getChildren()
	end
	
	function Box:clear()
		return self.content:clear()
	end
	
	function Box:toggle()
		self.wrap:toggle()
	end
	
	function Box:isVisible()
		return self.wrap.context.Visible
	end
	
	function Box:show()
		self.wrap:show()
	end
	
	function Box:hide()
		self.wrap:hide()
	end
	
	function Box:size(value)
		return self.wrap:size(value)
	end
	
	function Box:position(value)
		return self.wrap:position(value)
	end
	
	function Box:render()
		return self.wrap
	end
	
	Box.propTypes = {
		name = PropTypes.string,
		boxType = PropTypes.string,
		color = PropTypes.Color3,
		transparency = PropTypes.number;
		size = PropTypes.UDim2;
		borderRadius = PropTypes.number;
		zIndex = PropTypes.number;
		padding = function(propType)
			return propType == PropTypes.number or propType == PropTypes.string or propType == PropTypes.table
		end;
		
		half = PropTypes.bool;
		flipVertical = PropTypes.bool;
		
		rotation = PropTypes.number;
		visible = PropTypes.bool;
		
		outline = PropTypes.bool;
		outlineType = PropTypes.string,
		outlineSize = PropTypes.string;
		
		style = PropTypes.table,
		contentStyle = PropTypes.table,
		outlineStyle = PropTypes.table
	}
	
	Box.defaultProps = {
		name = 'Box';
		boxType = 'ImageLabel';
		color = Color3.new(1, 1, 1);
		transparency = 0;
		size = UDim2.new(1, 0, 1, 0);
		borderRadius = 25;
		zIndex = 1;
		
		half = false;
		flipVertical = false;
		
		rotation = 0;
		visible = true;
		
		outline = false;
		outlineType = 'ImageLabel';
		outlineSize = 'normal';
	}
	
	return Box
end)