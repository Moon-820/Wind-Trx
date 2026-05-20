local Creator = WindUI.Creator
local Themes = WindUI.Themes

local ProgressBar = {}
ProgressBar.__index = ProgressBar

function Tab:ProgressBar(options)
	options = options or {}

	local self = setmetatable({}, ProgressBar)

	self.Title = options.Title or "ProgressBar"
	self.Desc = options.Desc or nil
	self.Icon = options.Icon or nil
	self.Value = math.clamp(options.Value or 0, 0, 100)
	self.Color = options.Color or nil
	self.ShowLabel = options.ShowLabel ~= false
	self.Locked = options.Locked or false
	self.Flag = options.Flag or nil
	self.Suffix = options.Suffix or "%"

	local theme = Themes[WindUI.Theme]

	local container = Creator.new("Frame", {
		Name = "ProgressBarElement",
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme.ElementBackground,
		BackgroundTransparency = 0,
	})

	Creator.new("UICorner", { CornerRadius = UDim.new(0, 8) }, container)
	Creator.new("UIStroke", {
		Color = theme.ElementStroke,
		Thickness = 1,
		Transparency = 0.7,
	}, container)

	local padding = Creator.new("UIPadding", {
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	}, container)

	local layout = Creator.new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, container)

	local headerFrame = Creator.new("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
	}, container)

	Creator.new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
	}, headerFrame)

	if self.Icon then
		local iconLabel = Creator.new("ImageLabel", {
			Name = "Icon",
			Size = UDim2.fromOffset(16, 16),
			BackgroundTransparency = 1,
			Image = Creator:GetIcon(self.Icon),
			ImageColor3 = theme.TextColor,
			LayoutOrder = 0,
		}, headerFrame)
	end

	local titleLabel = Creator.new("TextLabel", {
		Name = "Title",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = self.Title,
		TextColor3 = theme.TextColor,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
	}, headerFrame)

	if self.Desc then
		local descLabel = Creator.new("TextLabel", {
			Name = "Desc",
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Text = self.Desc,
			TextColor3 = theme.SubTextColor,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1,
		}, container)
	end

	local barWrapper = Creator.new("Frame", {
		Name = "BarWrapper",
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = theme.ElementStroke,
		BackgroundTransparency = 0.5,
		LayoutOrder = 2,
	}, container)

	Creator.new("UICorner", { CornerRadius = UDim.new(1, 0) }, barWrapper)

	local fillColor = self.Color or theme.Accent or Color3.fromHex("#4f9eff")

	local fill = Creator.new("Frame", {
		Name = "Fill",
		Size = UDim2.new(self.Value / 100, 0, 1, 0),
		BackgroundColor3 = fillColor,
		BackgroundTransparency = 0,
	}, barWrapper)

	Creator.new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

	local gradient = Creator.new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0.15),
		}),
		Rotation = 90,
	}, fill)

	local valueLabel
	if self.ShowLabel then
		valueLabel = Creator.new("TextLabel", {
			Name = "ValueLabel",
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(1, 4, 0, 0),
			BackgroundTransparency = 1,
			Text = tostring(self.Value) .. self.Suffix,
			TextColor3 = theme.SubTextColor,
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, barWrapper)
	end

	Creator:AddToTab(container, Tab)

	if self.Locked then
		Creator:LockElement(container)
	end

	if self.Flag then
		WindUI.Flags[self.Flag] = self
	end

	function self:Set(value)
		value = math.clamp(value, 0, 100)
		self.Value = value

		Creator:Tween(fill, { Size = UDim2.new(value / 100, 0, 1, 0) }, 0.3)

		if valueLabel then
			valueLabel.Text = tostring(math.floor(value)) .. self.Suffix
		end

		if WindUI.Flags[self.Flag] then
			WindUI.Flags[self.Flag].Value = value
		end
	end

	function self:SetTitle(title)
		self.Title = title
		titleLabel.Text = title
	end

	function self:SetDesc(desc)
		self.Desc = desc
		if descLabel then
			descLabel.Text = desc
		end
	end

	function self:SetColor(color)
		self.Color = color
		fill.BackgroundColor3 = color
	end

	function self:Lock()
		self.Locked = true
		Creator:LockElement(container)
	end

	function self:Unlock()
		self.Locked = false
		Creator:UnlockElement(container)
	end

	function self:Destroy()
		container:Destroy()
		if self.Flag and WindUI.Flags[self.Flag] then
			WindUI.Flags[self.Flag] = nil
		end
	end

	return self
end

return ProgressBar
