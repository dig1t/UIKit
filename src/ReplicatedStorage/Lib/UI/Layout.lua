-- Utility for creating UI elements

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local import = require(ReplicatedStorage.Bootstrap).import
local Util = import('Lib/Util')
local UK = import('Lib/UIKit')
local Effects = import('Lib/UI/Effects')
local Component, Element = UK.Component, UK.Element

local Layout = {}

Layout.inf = 999999999

function Layout.gradient(colors, deg, transparency, offset)
	assert(colors, 'Layout.gradient - No colors given')

	return Element('UIGradient', {
		Color = ColorSequence.new(unpack(colors));
		Rotation = deg;
		Offset = offset;
		Transparency = transparency;
	})
end

function Layout.centerAlign()
	return Element('UIListLayout', {
		Name = 'CenterAlign';
		HorizontalAlignment = Enum.HorizontalAlignment.Center;
		VerticalAlignment = Enum.VerticalAlignment.Center;
	})
end

function Layout.borderRadius(scale, offset)
	return Element('UICorner', {
		CornerRadius = UDim.new(scale or 0, offset or 0);
	})
end

function Layout.roundCorner(radius, color, zIndex, offset)
	local corners = {}
	local cornerPositions = {
		UDim2.new(0, 0, 0, 0),
		UDim2.new(1, -radius, 0, 0),
		UDim2.new(1, -radius, 1, -radius),
		UDim2.new(0, 0, 1, -radius)
	}
	
	for i = 1, 4 do
		corners[#corners + 1] = Element('ImageLabel', {
			Position = cornerPositions[i];
			Size = UDim2.new(0, radius, 0, radius);
			Rotation = 90 * (i - 1);
			Image = 'rbxassetid://4744823366';
			ImageColor3 = color or Color3.new(1, 1, 1);
		})
	end
	
	return Element('Frame', {
		Name = 'RoundCorner-' .. radius .. 'px';
		Position = UDim2.new(0, -offset or 0, 0, -offset or 0);
		Size = UDim2.new(1, offset and offset * 2 or 0, 1, offset and offset * 2 or 0);
		ZIndex = zIndex or 2;
	}, corners)
end

function Layout.setPadding(obj, data, useScale)
	if typeof(data) == 'number' then
		data = Util.split(tostring(data), ' ')
	elseif typeof(data) == 'string' then
		data = Util.split(data, ' ')
	end
	
	if not data then
		return UK.Fragment()
	end
	
	local top, right, bottom, left
	
	if #data == 1 then -- all 4 sides
		local dim = UDim.new(useScale and data[1] or 0, not useScale and data[1] or 0)
		top = dim
		right = dim
		bottom = dim
		left = dim
	end
	
	if #data == 2 then -- vertical | horizontal
		local dim1 = UDim.new(useScale and data[1] or 0, not useScale and data[1] or 0)
		local dim2 = UDim.new(useScale and data[2] or 0, not useScale and data[2] or 0)
		
		top = dim1
		right = dim2
		bottom = dim1
		left = dim2
	end
	
	if #data == 3 then -- top | horizontal | bottom
		top = UDim.new(useScale and data[1] or 0, not useScale and data[1] or 0)
		right = UDim.new(useScale and data[2] or 0, not useScale and data[2] or 0)
		bottom = UDim.new(useScale and data[3] or 0, not useScale and data[3] or 0)
		left = UDim.new(useScale and data[2] or 0, not useScale and data[2] or 0)
	end
	
	if #data == 4 then -- top | right | bottom | left
		top = UDim.new(useScale and data[1] or 0, not useScale and data[1] or 0)
		right = UDim.new(useScale and data[2] or 0, not useScale and data[2] or 0)
		bottom = UDim.new(useScale and data[3] or 0, not useScale and data[3] or 0)
		left = UDim.new(useScale and data[4] or 0, not useScale and data[4] or 0)
	end
	
	local objRef = obj.ui and obj.context or obj
	objRef.PaddingTop = top
	objRef.PaddingRight = right
	objRef.PaddingBottom = bottom
	objRef.PaddingLeft = left
	
	return obj
end

function Layout.padding(data, useScale)
	return Layout.setPadding(Element('UIPadding'), data, useScale)
end

function Layout.aspectRatio(ratio, dominantAxis, aspectType)
	return Element('UIAspectRatioConstraint', {
		AspectRatio = ratio;
		AspectType = aspectType or Enum.AspectType.ScaleWithParentSize;
		DominantAxis = dominantAxis or Enum.DominantAxis.Width;
	})
end

function Layout.sizeConstraint(min, max)
	return Element('UISizeConstraint', {
		MinSize = min and Vector2.new(unpack(min)) or nil;
		MaxSize = max and Vector2.new(unpack(max)) or nil;
	})
end

function Layout.textSizeConstraint(min, max)
	return Element('UITextSizeConstraint', {
		MinTextSize = min and min or 1;
		MaxTextSize = max and max or 100;
	})
end

Layout.Container = Component.new(function()
	local Container = {}
	
	Container.name = 'container'
	
	function Container:init()
		self.visible = self.props.visible
		self._containerId = Util.randomString(8) -- Unique identifier for Container:display()
		
		self.paddingEl = Layout.padding(self.props.padding)
		
		self.box = Element('Frame', {
			Name = self.props.name;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = self.visible;
			ZIndex = self.props.zIndex;
		}, {
			self.paddingEl,
			self.props.children
		})
	end
	
	function Container:padding(padding, useScale)
		return Layout.setPadding(self.paddingEl, padding, useScale)
	end
	
	function Container:display(open, noPosTween)
		if open == nil then
			open = true
		end
		
		assert(typeof(open) == 'boolean', 'Container:display() - Open argument must be a boolean')
		
		--if open == self.visible and not self.animating then
		if open == self.visible or self.animating then
			return
		end
		
		self.visible = open
		self.animating = true
		
		local blurTween
		
		-- If this is the only active(?) container then blur/unblur
		if self.env:get('activeContainers'):length() == (open and 0 or 1) then
			self.env:set({ blurred = open })
			
			blurTween = Effects.blur(open and 0 or 30, open and 30 or 0)
		end
		
		if open then
			self.env:get('activeContainers'):push(self._containerId, true) -- Prevent early unblurring from other containers
			self.box:show()
		end
		
		if not noPosTween then -- Instantly open
			Effects.tweenPos(
				self.box,
				UDim2.new(open and -1 or 0, 0, 0, 0),
				UDim2.new(open and 0 or -1, 0, 0, 0)
			).Completed:Wait()
		else
			self.box:position(UDim2.new(open and 0 or -1, 0, 0, 0))
		end
		
		if blurTween and blurTween.PlaybackState == Enum.PlaybackState.Playing then
			blurTween.Completed:Wait()
		end
		
		-- Prevent blur from being stuck when no containers are active
		if (not open or open ~= self.visible) and self.env:get('activeContainers'):length() == (open and 0 or 1) and Effects.blur() ~= 0 then
			Effects.blur(1, 0)
		end
		
		self.animating = false
		-- End tween yields
		
		if not open then
			self.env:get('activeContainers'):remove(self._containerId) -- Remove tag so other containers can blur/unblur the screen
			self.box:hide()
		end
	end
	
	function Container:toggle()
		self:display(not self.visible)
	end
	
	function Container:render()
		return self.box
	end
	
	Container.defaultProps = {
		name = 'Container';
		padding = '25';
		visible = true;
		zIndex = 1;
	}
	
	return Container
end)

return Layout