-- ============================================================
--  NexusUI Library v1.0 — Futuristic UI for Roblox
--  by Claude | Luau | Compatible with LocalScript
-- ============================================================
--[[
  KOMPONEN TERSEDIA:
    NexusUI:CreateWindow(title, subtitle)
    NexusUI:AddSection(window, title)
    NexusUI:AddParagraph(section, title, text)
    NexusUI:AddTextBox(section, label, placeholder, callback)
    NexusUI:AddInputText(section, label, placeholder, callback)  -- alias TextBox
    NexusUI:AddButton(section, label, callback, options)
    NexusUI:AddToggle(section, label, default, callback)
    NexusUI:AddDropdown(section, label, items, default, callback)
    NexusUI:AddSlider(section, label, min, max, default, callback)
    NexusUI:AddProgressBar(section, label, value)
    NexusUI:AddBadge(section, text, color)
    NexusUI:ShowModal(title, message, buttons)
    NexusUI:Notify(title, message, duration, type)
    NexusUI:Destroy()

  OPSI WARNA BUTTON (options.Color):
    Bisa pakai string: "Cyan", "Purple", "Green", "Red", "Orange", "White", "Dark"
    Atau pakai Color3: Color3.fromRGB(r, g, b)
    Atau pakai hex string: "#FF4500"

  CONTOH PEMAKAIAN LENGKAP ADA DI BAWAH
--]]

local NexusUI = {}
NexusUI.__index = NexusUI

-- ── Palette ──────────────────────────────────────────────────
local Theme = {
	BG         = Color3.fromRGB(8, 10, 18),
	Surface    = Color3.fromRGB(14, 17, 28),
	Surface2   = Color3.fromRGB(20, 24, 40),
	Border     = Color3.fromRGB(40, 50, 80),
	BorderGlow = Color3.fromRGB(0, 200, 255),
	Accent     = Color3.fromRGB(0, 200, 255),
	AccentDim  = Color3.fromRGB(0, 120, 160),
	Text       = Color3.fromRGB(220, 235, 255),
	TextDim    = Color3.fromRGB(120, 140, 180),
	Success    = Color3.fromRGB(0, 230, 120),
	Warning    = Color3.fromRGB(255, 180, 0),
	Danger     = Color3.fromRGB(255, 60, 80),
	Purple     = Color3.fromRGB(140, 80, 255),
	Orange     = Color3.fromRGB(255, 120, 30),
	White      = Color3.fromRGB(240, 245, 255),
	Dark       = Color3.fromRGB(30, 36, 55),
}

-- ── Util ─────────────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local PlayerGui       = LocalPlayer:WaitForChild("PlayerGui")

local function tween(obj, props, t, style, dir)
	local ti = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	TweenService:Create(obj, ti, props):Play()
end

local function resolveColor(c, fallback)
	if not c then return fallback end
	if typeof(c) == "Color3" then return c end
	if type(c) == "string" then
		local map = {
			Cyan   = Theme.Accent,
			Purple = Theme.Purple,
			Green  = Theme.Success,
			Red    = Theme.Danger,
			Orange = Theme.Orange,
			White  = Theme.White,
			Dark   = Theme.Dark,
		}
		if map[c] then return map[c] end
		-- hex
		local hex = c:match("^#?(%x%x%x%x%x%x)$")
		if hex then
			local r = tonumber(hex:sub(1,2),16)/255
			local g = tonumber(hex:sub(3,4),16)/255
			local b = tonumber(hex:sub(5,6),16)/255
			return Color3.new(r,g,b)
		end
	end
	return fallback
end

local function newInst(class, props)
	local obj = Instance.new(class)
	for k,v in pairs(props) do
		if k ~= "Parent" then obj[k] = v end
	end
	if props.Parent then obj.Parent = props.Parent end
	return obj
end

local function uiCorner(parent, radius)
	newInst("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = parent})
end

local function uiPadding(parent, px, py)
	newInst("UIPadding", {
		PaddingLeft   = UDim.new(0, px or 10),
		PaddingRight  = UDim.new(0, px or 10),
		PaddingTop    = UDim.new(0, py or 6),
		PaddingBottom = UDim.new(0, py or 6),
		Parent = parent
	})
end

local function uiStroke(parent, color, thickness)
	newInst("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
end

local function label(parent, text, size, color, font, xAlign)
	return newInst("TextLabel", {
		Text = text or "",
		TextSize = size or 13,
		TextColor3 = color or Theme.Text,
		Font = font or Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = xAlign or Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.XY,
		Parent = parent
	})
end

local function makeListLayout(parent, padding, dir)
	newInst("UIListLayout", {
		Padding = UDim.new(0, padding or 6),
		FillDirection = dir or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent
	})
end

-- ── ScreenGui ────────────────────────────────────────────────
function NexusUI.new()
	local self = setmetatable({}, NexusUI)

	self.ScreenGui = newInst("ScreenGui", {
		Name = "NexusUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
		Parent = PlayerGui
	})

	self._connections = {}
	self._windows     = {}
	self._notifCount  = 0
	return self
end

-- ── Window ───────────────────────────────────────────────────
function NexusUI:CreateWindow(title, subtitle)
	local sg = self.ScreenGui

	-- backdrop blur (decorative)
	local blurFrame = newInst("Frame", {
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = sg
	})

	-- main window
	local win = newInst("Frame", {
		Size = UDim2.new(0, 420, 0, 560),
		Position = UDim2.new(0.5, -210, 0.5, -280),
		BackgroundColor3 = Theme.BG,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = sg
	})
	uiCorner(win, 10)
	uiStroke(win, Theme.Border, 1.5)

	-- glow line top
	local glowLine = newInst("Frame", {
		Size = UDim2.new(0.7, 0, 0, 2),
		Position = UDim2.new(0.15, 0, 0, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = win
	})
	uiCorner(glowLine, 2)

	-- header
	local header = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = win
	})
	uiCorner(header, 10)
	-- mask bottom corners of header
	newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = header
	})

	-- accent dot
	newInst("Frame", {
		Size = UDim2.new(0, 8, 0, 8),
		Position = UDim2.new(0, 16, 0.5, -4),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = header
	})
	local _ = header:FindFirstChildWhichIsA("Frame")
	if _ then uiCorner(_, 4) end

	-- title
	newInst("TextLabel", {
		Text = title or "NexusUI",
		TextSize = 15,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -70, 0, 18),
		Position = UDim2.new(0, 34, 0, 10),
		ZIndex = 4,
		Parent = header
	})

	-- subtitle
	newInst("TextLabel", {
		Text = subtitle or "",
		TextSize = 11,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -70, 0, 14),
		Position = UDim2.new(0, 34, 0, 30),
		ZIndex = 4,
		Parent = header
	})

	-- close button
	local closeBtn = newInst("TextButton", {
		Text = "✕",
		TextSize = 13,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -40, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = header
	})
	uiCorner(closeBtn, 6)
	closeBtn.MouseButton1Click:Connect(function()
		tween(win, {Position = UDim2.new(0.5, -210, 0.7, 0), BackgroundTransparency = 1}, 0.3)
		tween(blurFrame, {BackgroundTransparency = 1}, 0.3)
		task.delay(0.35, function() sg:Destroy() end)
	end)
	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, {TextColor3 = Theme.Danger}, 0.15)
		tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(60,20,30)}, 0.15)
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, {TextColor3 = Theme.TextDim}, 0.15)
		tween(closeBtn, {BackgroundColor3 = Theme.Surface2}, 0.15)
	end)

	-- minimize button
	local minBtn = newInst("TextButton", {
		Text = "─",
		TextSize = 13,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -74, 0.5, -14),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = header
	})
	uiCorner(minBtn, 6)
	minBtn.MouseEnter:Connect(function()
		tween(minBtn, {TextColor3 = Theme.Accent}, 0.15)
		tween(minBtn, {BackgroundColor3 = Color3.fromRGB(10,30,50)}, 0.15)
	end)
	minBtn.MouseLeave:Connect(function()
		tween(minBtn, {TextColor3 = Theme.TextDim}, 0.15)
		tween(minBtn, {BackgroundColor3 = Theme.Surface2}, 0.15)
	end)

	-- floating pill (logo saat minimize)
	local pill = newInst("TextButton", {
		Text = "  " .. (title or "NexusUI"),
		TextSize = 11,
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		Size = UDim2.new(0, 120, 0, 32),
		Position = UDim2.new(0, 20, 0, 20),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 200,
		Parent = sg
	})
	uiCorner(pill, 16)
	uiStroke(pill, Theme.Accent, 1.5)

	-- dot di dalam pill
	local pillDot = newInst("Frame", {
		Size = UDim2.new(0, 7, 0, 7),
		Position = UDim2.new(0, 10, 0.5, -3),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 201,
		Parent = pill
	})
	uiCorner(pillDot, 4)

	-- drag pill
	local pillDragging, pillDragStart, pillStartPos = false, nil, nil
	local pillMoved = false
	pill.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			pillDragging = true
			pillMoved = false
			pillDragStart = inp.Position
			pillStartPos = pill.Position
		end
	end)
	pill.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			pillDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if pillDragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - pillDragStart
			if delta.Magnitude > 4 then pillMoved = true end
			pill.Position = UDim2.new(
				pillStartPos.X.Scale, pillStartPos.X.Offset + delta.X,
				pillStartPos.Y.Scale, pillStartPos.Y.Offset + delta.Y
			)
		end
	end)

	-- minimize / restore
	local minimized = false

	local function doMinimize()
		minimized = true
		tween(win, {Size = UDim2.new(0, 420, 0, 0), BackgroundTransparency = 1}, 0.2, Enum.EasingStyle.Quart)
		tween(blurFrame, {BackgroundTransparency = 1}, 0.2)
		task.delay(0.22, function()
			win.Visible = false
			blurFrame.Visible = false
			pill.Visible = true
		end)
	end

	local function doRestore()
		minimized = false
		win.Size = UDim2.new(0, 420, 0, 0)
		win.BackgroundTransparency = 1
		win.Visible = true
		blurFrame.Visible = true
		pill.Visible = false
		tween(win, {Size = UDim2.new(0, 420, 0, 560), BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back)
		tween(blurFrame, {BackgroundTransparency = 0.55}, 0.3)
	end

	minBtn.MouseButton1Click:Connect(function()
		if not minimized then doMinimize() end
	end)

	pill.MouseButton1Click:Connect(function()
		if not pillMoved then doRestore() end
	end)

	-- scrolling content
	local scroll = newInst("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -68),
		Position = UDim2.new(0, 0, 0, 64),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 3,
		Parent = win
	})
	uiPadding(scroll, 12, 8)
	makeListLayout(scroll, 8)

	-- draggable
	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = win.Position
		end
	end)
	header.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = inp.Position - dragStart
			win.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- entrance animation
	win.Position = UDim2.new(0.5, -210, 0.3, 0)
	win.BackgroundTransparency = 1
	blurFrame.BackgroundTransparency = 1
	tween(win, {Position = UDim2.new(0.5,-210,0.5,-280), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
	tween(blurFrame, {BackgroundTransparency = 0.55}, 0.35)

	local windowObj = {Frame = win, Scroll = scroll, ScreenGui = sg}
	table.insert(self._windows, windowObj)
	return windowObj
end

-- ── Section ──────────────────────────────────────────────────
function NexusUI:AddSection(window, title)
	local scroll = window.Scroll

	local sect = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 4,
		Parent = scroll
	})
	uiCorner(sect, 8)
	uiStroke(sect, Theme.Border)
	uiPadding(sect, 10, 10)

	-- section accent line
	newInst("Frame", {
		Size = UDim2.new(0, 3, 1, -20),
		Position = UDim2.new(0, -10, 0, 10),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = sect
	})

	local container = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = sect
	})
	makeListLayout(container, 7)

	if title and title ~= "" then
		local hdr = newInst("Frame", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			ZIndex = 5,
			Parent = container
		})
		newInst("TextLabel", {
			Text = title:upper(),
			TextSize = 10,
			TextColor3 = Theme.Accent,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			Parent = hdr
		})
		-- divider
		newInst("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.Border,
			BorderSizePixel = 0,
			ZIndex = 5,
			Parent = container
		})
	end

	return {Frame = sect, Container = container}
end

-- ── Paragraph ────────────────────────────────────────────────
function NexusUI:AddParagraph(section, title, text)
	local c = section.Container

	local wrap = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = c
	})
	uiCorner(wrap, 6)
	uiPadding(wrap, 10, 8)
	makeListLayout(wrap, 4)

	if title and title ~= "" then
		newInst("TextLabel", {
			Text = title,
			TextSize = 12,
			TextColor3 = Theme.Text,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 6,
			Parent = wrap
		})
	end
	newInst("TextLabel", {
		Text = text or "",
		TextSize = 11,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 6,
		Parent = wrap
	})
	return wrap
end

-- ── TextBox / InputText ───────────────────────────────────────
local function makeInput(parent_c, label_text, placeholder, callback, multiLine)
	local wrap = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = parent_c
	})
	makeListLayout(wrap, 4)

	if label_text and label_text ~= "" then
		newInst("TextLabel", {
			Text = label_text,
			TextSize = 12,
			TextColor3 = Theme.TextDim,
			Font = Enum.Font.GothamMedium,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 14),
			ZIndex = 5,
			Parent = wrap
		})
	end

	local inputFrame = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, multiLine and 70 or 32),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = wrap
	})
	uiCorner(inputFrame, 6)
	local stroke = uiStroke(inputFrame, Theme.Border, 1)

	local box = newInst("TextBox", {
		Text = "",
		PlaceholderText = placeholder or "Type here...",
		PlaceholderColor3 = Theme.TextDim,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = multiLine and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
		TextWrapped = multiLine or false,
		MultiLine = multiLine or false,
		ClearTextOnFocus = false,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = inputFrame
	})
	uiPadding(box, 10, 6)

	box.Focused:Connect(function()
		tween(inputFrame, {BackgroundColor3 = Color3.fromRGB(18,22,38)}, 0.15)
		tween(stroke, {Color = Theme.Accent}, 0.15)
	end)
	box.FocusLost:Connect(function(enter)
		tween(inputFrame, {BackgroundColor3 = Theme.Surface2}, 0.15)
		tween(stroke, {Color = Theme.Border}, 0.15)
		if callback then callback(box.Text, enter) end
	end)
	return wrap, box
end

function NexusUI:AddTextBox(section, lbl, placeholder, callback)
	return makeInput(section.Container, lbl, placeholder, callback, true)
end

function NexusUI:AddInputText(section, lbl, placeholder, callback)
	return makeInput(section.Container, lbl, placeholder, callback, false)
end

-- ── Button ────────────────────────────────────────────────────
function NexusUI:AddButton(section, lbl, callback, options)
	options = options or {}
	local bgColor  = resolveColor(options.Color, Theme.Accent)
	local outlined = options.Outlined or false

	local btn = newInst("TextButton", {
		Text = "",
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = outlined and Theme.Surface2 or bgColor,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = section.Container
	})
	uiCorner(btn, 7)
	if outlined then
		uiStroke(btn, bgColor, 1.5)
	end

	-- shimmer gradient
	local grad = newInst("UIGradient", {
		Rotation = 90,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.85,0.85,0.85))
		},
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, outlined and 0.85 or 0.15),
			NumberSequenceKeypoint.new(1, outlined and 0.95 or 0.35)
		},
		Parent = btn
	})

	local btnLabel = newInst("TextLabel", {
		Text = lbl or "Button",
		TextSize = 13,
		TextColor3 = outlined and bgColor or Theme.BG,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,0),
		ZIndex = 6,
		Parent = btn
	})

	-- icon support
	if options.Icon then
		newInst("TextLabel", {
			Text = options.Icon .. "  " .. (lbl or ""),
			TextSize = 13,
			TextColor3 = outlined and bgColor or Theme.BG,
			Font = Enum.Font.GothamBold,
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 6,
			Parent = btn
		})
		btnLabel:Destroy()
	end

	-- hover / click
	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = outlined and bgColor or bgColor:Lerp(Color3.new(1,1,1), 0.15)}, 0.15)
		if outlined then
			tween(btnLabel, {TextColor3 = Theme.BG}, 0.15)
		end
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = outlined and Theme.Surface2 or bgColor}, 0.15)
		if outlined then
			tween(btnLabel, {TextColor3 = bgColor}, 0.15)
		end
	end)
	btn.MouseButton1Down:Connect(function()
		tween(btn, {Size = UDim2.new(0.97, 0, 0, 34)}, 0.08, Enum.EasingStyle.Quad)
	end)
	btn.MouseButton1Up:Connect(function()
		tween(btn, {Size = UDim2.new(1, 0, 0, 36)}, 0.12, Enum.EasingStyle.Back)
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return btn
end

-- ── Toggle ────────────────────────────────────────────────────
function NexusUI:AddToggle(section, lbl, default, callback)
	local state = default or false

	local row = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = section.Container
	})
	uiCorner(row, 7)

	newInst("TextLabel", {
		Text = lbl or "Toggle",
		TextSize = 12,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -56, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		ZIndex = 6,
		Parent = row
	})

	-- track
	local track = newInst("Frame", {
		Size = UDim2.new(0, 40, 0, 22),
		Position = UDim2.new(1, -50, 0.5, -11),
		BackgroundColor3 = state and Theme.Accent or Theme.Border,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = row
	})
	uiCorner(track, 11)

	-- knob
	local knob = newInst("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = state and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = track
	})
	uiCorner(knob, 8)

	local function setToggle(val)
		state = val
		tween(track, {BackgroundColor3 = state and Theme.Accent or Theme.Border}, 0.2)
		tween(knob, {Position = state and UDim2.new(0,21,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2, Enum.EasingStyle.Back)
		if callback then callback(state) end
	end

	row.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			setToggle(not state)
		end
	end)

	return {Frame = row, GetValue = function() return state end, SetValue = setToggle}
end

-- ── Dropdown ──────────────────────────────────────────────────
function NexusUI:AddDropdown(section, lbl, items, default, callback)
	local selected = default or (items and items[1]) or ""
	local open = false

	local wrap = newInst("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 10,
		Parent = section.Container
	})

	if lbl and lbl ~= "" then
		newInst("TextLabel", {
			Text = lbl,
			TextSize = 12,
			TextColor3 = Theme.TextDim,
			Font = Enum.Font.GothamMedium,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1,0,0,14),
			ZIndex = 10,
			Parent = wrap
		})
	end

	local header = newInst("TextButton", {
		Text = "",
		Size = UDim2.new(1,0,0,34),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 10,
		Parent = wrap
	})
	uiCorner(header, 7)
	uiStroke(header, Theme.Border)

	local selLabel = newInst("TextLabel", {
		Text = selected,
		TextSize = 12,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,-36,1,0),
		Position = UDim2.new(0,10,0,0),
		ZIndex = 11,
		Parent = header
	})

	local arrow = newInst("TextLabel", {
		Text = "▾",
		TextSize = 14,
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.new(0,24,1,0),
		Position = UDim2.new(1,-30,0,0),
		ZIndex = 11,
		Parent = header
	})

	-- dropdown list
	local list = newInst("Frame", {
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 20,
		Parent = wrap
	})
	uiCorner(list, 7)
	uiStroke(list, Theme.Border)
	uiPadding(list, 4, 4)
	makeListLayout(list, 3)

	local function rebuild()
		for _, ch in ipairs(list:GetChildren()) do
			if ch:IsA("TextButton") then ch:Destroy() end
		end
		for _, item in ipairs(items or {}) do
			local opt = newInst("TextButton", {
				Text = item,
				TextSize = 12,
				TextColor3 = item == selected and Theme.Accent or Theme.Text,
				Font = item == selected and Enum.Font.GothamBold or Enum.Font.Gotham,
				Size = UDim2.new(1,0,0,28),
				BackgroundColor3 = item == selected and Theme.Surface2 or Color3.fromRGB(0,0,0),
				BackgroundTransparency = item == selected and 0 or 1,
				BorderSizePixel = 0,
				ZIndex = 21,
				Parent = list
			})
			uiCorner(opt, 5)
			opt.MouseEnter:Connect(function()
				if item ~= selected then
					tween(opt, {BackgroundTransparency = 0.6, BackgroundColor3 = Theme.Surface2}, 0.1)
				end
			end)
			opt.MouseLeave:Connect(function()
				if item ~= selected then
					tween(opt, {BackgroundTransparency = 1}, 0.1)
				end
			end)
			opt.MouseButton1Click:Connect(function()
				selected = item
				selLabel.Text = selected
				open = false
				list.Visible = false
				tween(arrow, {Rotation = 0}, 0.2)
				rebuild()
				if callback then callback(selected) end
			end)
		end
	end
	rebuild()

	header.MouseButton1Click:Connect(function()
		open = not open
		list.Visible = open
		tween(arrow, {Rotation = open and 180 or 0}, 0.2)
		if open then rebuild() end
	end)

	return {Frame = wrap, GetValue = function() return selected end}
end

-- ── Slider ────────────────────────────────────────────────────
function NexusUI:AddSlider(section, lbl, minVal, maxVal, default, callback)
	minVal = minVal or 0
	maxVal = maxVal or 100
	local value = math.clamp(default or minVal, minVal, maxVal)

	local wrap = newInst("Frame", {
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = section.Container
	})
	makeListLayout(wrap, 6)

	local topRow = newInst("Frame", {
		Size = UDim2.new(1,0,0,16),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = wrap
	})
	newInst("TextLabel", {
		Text = lbl or "Slider",
		TextSize = 12,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.7,0,1,0),
		ZIndex = 5,
		Parent = topRow
	})
	local valLabel = newInst("TextLabel", {
		Text = tostring(value),
		TextSize = 12,
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0.3,0,1,0),
		Position = UDim2.new(0.7,0,0,0),
		ZIndex = 5,
		Parent = topRow
	})

	local track = newInst("Frame", {
		Size = UDim2.new(1,0,0,6),
		BackgroundColor3 = Theme.Border,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = wrap
	})
	uiCorner(track, 3)

	local fill = newInst("Frame", {
		Size = UDim2.new((value-minVal)/(maxVal-minVal), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = track
	})
	uiCorner(fill, 3)

	local knob = newInst("Frame", {
		Size = UDim2.new(0,14,0,14),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new((value-minVal)/(maxVal-minVal),0,0.5,0),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		ZIndex = 7,
		Parent = track
	})
	uiCorner(knob, 7)
	uiStroke(knob, Theme.Accent, 2)

	local sliding = false
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
	end)
	track.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if sliding and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local rel = (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
			rel = math.clamp(rel, 0, 1)
			value = math.floor(minVal + rel * (maxVal - minVal) + 0.5)
			local pct = (value - minVal) / (maxVal - minVal)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			knob.Position = UDim2.new(pct, 0, 0.5, 0)
			valLabel.Text = tostring(value)
			if callback then callback(value) end
		end
	end)

	return {Frame = wrap, GetValue = function() return value end}
end

-- ── Progress Bar ─────────────────────────────────────────────
function NexusUI:AddProgressBar(section, lbl, value)
	value = math.clamp(value or 0, 0, 100)

	local wrap = newInst("Frame", {
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = section.Container
	})
	makeListLayout(wrap, 4)

	local topRow = newInst("Frame", {
		Size = UDim2.new(1,0,0,14),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = wrap
	})
	newInst("TextLabel", {
		Text = lbl or "Progress",
		TextSize = 11,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.GothamMedium,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.7,0,1,0),
		ZIndex = 5,
		Parent = topRow
	})
	local pctLabel = newInst("TextLabel", {
		Text = value .. "%",
		TextSize = 11,
		TextColor3 = Theme.Accent,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0.3,0,1,0),
		Position = UDim2.new(0.7,0,0,0),
		ZIndex = 5,
		Parent = topRow
	})

	local track = newInst("Frame", {
		Size = UDim2.new(1,0,0,8),
		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = wrap
	})
	uiCorner(track, 4)

	local fill = newInst("Frame", {
		Size = UDim2.new(value/100, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = track
	})
	uiCorner(fill, 4)
	newInst("UIGradient", {
		Rotation = 0,
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Theme.Accent),
			ColorSequenceKeypoint.new(1, Theme.Purple)
		},
		Parent = fill
	})

	return {
		Frame = wrap,
		SetValue = function(v)
			v = math.clamp(v, 0, 100)
			value = v
			tween(fill, {Size = UDim2.new(v/100,0,1,0)}, 0.4)
			pctLabel.Text = v .. "%"
		end
	}
end

-- ── Badge ────────────────────────────────────────────────────
function NexusUI:AddBadge(section, text, color)
	local c = resolveColor(color, Theme.Accent)

	local badge = newInst("Frame", {
		Size = UDim2.new(0,0,0,22),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = c,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = section.Container
	})
	uiCorner(badge, 4)
	uiStroke(badge, c, 1)
	uiPadding(badge, 8, 4)

	newInst("TextLabel", {
		Text = text or "Badge",
		TextSize = 11,
		TextColor3 = c,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = 6,
		Parent = badge
	})

	return badge
end

-- ── Modal ────────────────────────────────────────────────────
function NexusUI:ShowModal(title, message, buttons)
	local sg = self.ScreenGui

	local overlay = newInst("Frame", {
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.6,
		ZIndex = 50,
		Parent = sg
	})

	local modal = newInst("Frame", {
		Size = UDim2.new(0,360,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0.5,-180,0.5,0),
		AnchorPoint = Vector2.new(0,0.5),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 51,
		Parent = sg
	})
	uiCorner(modal, 10)
	uiStroke(modal, Theme.Accent, 1.5)
	uiPadding(modal, 20, 20)
	makeListLayout(modal, 12)

	-- glow top
	newInst("Frame", {
		Size = UDim2.new(0.5,0,0,2),
		Position = UDim2.new(0.25,0,0,0),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		ZIndex = 52,
		Parent = modal
	})

	newInst("TextLabel", {
		Text = title or "Modal",
		TextSize = 15,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 52,
		Parent = modal
	})

	newInst("TextLabel", {
		Text = message or "",
		TextSize = 12,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 52,
		Parent = modal
	})

	-- button row
	local btnRow = newInst("Frame", {
		Size = UDim2.new(1,0,0,36),
		BackgroundTransparency = 1,
		ZIndex = 52,
		Parent = modal
	})
	local btnLayout = newInst("UIListLayout", {
		Padding = UDim.new(0,8),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = btnRow
	})

	local function closeModal()
		tween(overlay, {BackgroundTransparency = 1}, 0.2)
		tween(modal, {Position = UDim2.new(0.5,-180,0.6,0), BackgroundTransparency = 1}, 0.2)
		task.delay(0.25, function()
			overlay:Destroy()
			modal:Destroy()
		end)
	end

	for _, btnDef in ipairs(buttons or {{Text="OK"}}) do
		local color = resolveColor(btnDef.Color, Theme.Accent)
		local b = newInst("TextButton", {
			Text = btnDef.Text or "OK",
			TextSize = 12,
			TextColor3 = Theme.BG,
			Font = Enum.Font.GothamBold,
			Size = UDim2.new(0,90,1,0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			ZIndex = 53,
			Parent = btnRow
		})
		uiCorner(b, 7)
		b.MouseButton1Click:Connect(function()
			if btnDef.Callback then btnDef.Callback() end
			closeModal()
		end)
	end

	-- entrance
	modal.Position = UDim2.new(0.5,-180,0.4,0)
	overlay.BackgroundTransparency = 1
	tween(overlay, {BackgroundTransparency = 0.6}, 0.2)
	tween(modal, {Position = UDim2.new(0.5,-180,0.5,0)}, 0.3, Enum.EasingStyle.Back)

	return {Close = closeModal}
end

-- ── Notification / Toast ──────────────────────────────────────
function NexusUI:Notify(title, message, duration, notifType)
	duration = duration or 4
	notifType = notifType or "info"
	self._notifCount = (self._notifCount or 0) + 1

	local typeColors = {
		info    = Theme.Accent,
		success = Theme.Success,
		warning = Theme.Warning,
		error   = Theme.Danger,
	}
	local color = typeColors[notifType] or Theme.Accent

	local icons = {info="ℹ", success="✓", warning="⚠", error="✕"}
	local icon  = icons[notifType] or "ℹ"

	local notif = newInst("Frame", {
		Size = UDim2.new(0, 280, 0, 64),
		Position = UDim2.new(1, 20, 1, -(70 * self._notifCount)),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 100,
		Parent = self.ScreenGui
	})
	uiCorner(notif, 8)
	uiStroke(notif, color, 1)

	-- accent left bar
	newInst("Frame", {
		Size = UDim2.new(0,3,1,0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		ZIndex = 101,
		Parent = notif
	})
	uiCorner(notif:FindFirstChildWhichIsA("Frame"), 3)

	-- icon circle
	local iconBg = newInst("Frame", {
		Size = UDim2.new(0,30,0,30),
		Position = UDim2.new(0,14,0.5,-15),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ZIndex = 101,
		Parent = notif
	})
	uiCorner(iconBg, 15)
	newInst("TextLabel", {
		Text = icon,
		TextSize = 14,
		TextColor3 = color,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ZIndex = 102,
		Parent = iconBg
	})

	newInst("TextLabel", {
		Text = title or "Notification",
		TextSize = 12,
		TextColor3 = Theme.Text,
		Font = Enum.Font.GothamBold,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,-60,0,18),
		Position = UDim2.new(0,52,0,12),
		ZIndex = 101,
		Parent = notif
	})
	newInst("TextLabel", {
		Text = message or "",
		TextSize = 11,
		TextColor3 = Theme.TextDim,
		Font = Enum.Font.Gotham,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1,-60,0,16),
		Position = UDim2.new(0,52,0,32),
		ZIndex = 101,
		Parent = notif
	})

	-- slide in
	tween(notif, {Position = UDim2.new(1,-295,1,-(70 * self._notifCount))}, 0.3, Enum.EasingStyle.Back)

	task.delay(duration, function()
		tween(notif, {Position = UDim2.new(1, 20, 1, -(70 * self._notifCount))}, 0.3)
		task.delay(0.35, function()
			notif:Destroy()
			self._notifCount = math.max(0, self._notifCount - 1)
		end)
	end)
end

-- ── Destroy ───────────────────────────────────────────────────
function NexusUI:Destroy()
	if self.ScreenGui then self.ScreenGui:Destroy() end
end

-- ============================================================
--  CONTOH PEMAKAIAN LENGKAP
-- ============================================================
--[[

local NexusUI = require(path.to.NexusUI)  -- atau paste langsung

local ui = NexusUI.new()

local win = ui:CreateWindow("Nexus Panel", "Futuristic Admin Hub")

-- Section 1: Info
local secInfo = ui:AddSection(win, "Informasi")
ui:AddParagraph(secInfo, "Selamat Datang", "Ini adalah NexusUI, library UI futuristik untuk Roblox.")
ui:AddBadge(secInfo, "v1.0 STABLE", "Green")
ui:AddBadge(secInfo, "BETA FEATURE", "Orange")

-- Section 2: Input
local secInput = ui:AddSection(win, "Input")
ui:AddInputText(secInput, "Username", "Masukkan username...", function(text)
    print("Username:", text)
end)
ui:AddTextBox(secInput, "Bio", "Tulis bio kamu...", function(text)
    print("Bio:", text)
end)

-- Section 3: Control
local secCtrl = ui:AddSection(win, "Kontrol")
ui:AddToggle(secCtrl, "God Mode", false, function(val)
    print("God Mode:", val)
end)
ui:AddSlider(secCtrl, "Walk Speed", 0, 100, 16, function(val)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
end)
ui:AddDropdown(secCtrl, "Pilih Tim", {"Red", "Blue", "Green"}, "Red", function(val)
    print("Tim:", val)
end)

-- Section 4: Buttons (custom color)
local secBtn = ui:AddSection(win, "Aksi")
ui:AddButton(secBtn, "▶  Mulai Game", function()
    ui:Notify("Success", "Game dimulai!", 3, "success")
end, {Color = "Green"})

ui:AddButton(secBtn, "⚡  Teleport", function()
    ui:Notify("Info", "Teleporting...", 2, "info")
end, {Color = Color3.fromRGB(140, 80, 255)})

ui:AddButton(secBtn, "💀  Reset Karakter", function()
    ui:ShowModal("Konfirmasi", "Yakin ingin reset karakter?", {
        {Text = "Ya", Color = "Red",  Callback = function() print("Reset!") end},
        {Text = "Tidak", Color = "Dark"},
    })
end, {Color = "Red", Outlined = true})

-- Progress bar
local prog = ui:AddProgressBar(secBtn, "Loading Assets", 65)
task.delay(2, function() prog.SetValue(100) end)

--]]

return NexusUI