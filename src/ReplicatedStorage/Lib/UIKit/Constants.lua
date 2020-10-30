-- src/UIKit/Modules/Constants.lua

return {
	isUIObject = {
		Frame = true;
		ScrollingFrame = true;
		ImageButton = true;
		ImageLabel = true;
		TextBox = true;
		TextButton = true;
		TextLabel = true;
		ViewportFrame = true;
	};
	
	isTextObject = {
		TextBox = true;
		TextButton = true;
		TextLabel = true;
	};
	
	isFrameObject = {
		Frame = true;
		ScrollingFrame = true;
		TextBox = true;
		TextButton = true;
		ViewportFrame = true;
	};
	
	isImageObject = {
		ImageButton = true;
		ImageLabel = true;
	};
	
	resets = {
		default = {
			BackgroundColor3 = Color3.new(1, 1, 1);
			BackgroundTransparency = 1;
			BorderColor3 = Color3.new(0, 0, 0);
			BorderSizePixel = 0;
		};
		
		Frame = {};
		
		ImageButton = {};
		
		ImageLabel = {};
		
		ScrollingFrame = {};
		
		TextBox = {
			PlaceholderColor3 = Color3.new(161, 161, 161); -- #a1a1a1
			ClearTextOnFocus = false;
			Font = Enum.Font.SourceSans;
			Text = '';
			TextSize = 16;
		};
		
		TextButton = {
			Font = Enum.Font.SourceSans;
			Text = '';
			TextSize = 16;
		};
		
		TextLabel = {
			Font = Enum.Font.SourceSans;
			Text = '';
			TextSize = 16;
		};
		
		ViewportFrame = {};
		
		UIListLayout = {
			SortOrder = Enum.SortOrder.LayoutOrder;
		};
	};
};