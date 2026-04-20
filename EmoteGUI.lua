-- StarterPlayerScripts/EmoteGUI.lua (LocalScript)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
	DATA_URL         = "https://raw.githubusercontent.com/06mrx/fishit/refs/heads/main/Fetch01.txt", -- URL raw Lua kamu
	COLUMNS          = 4,
	CELL_SIZE        = 76,
	CELL_PAD         = 8,
	MAX_ROWS_VISIBLE = 3,
}

-- =============================================
-- FORMAT FILE DI URL KAMU:
--
-- return {
--     { name = "Point2",  id = 3576823880, index = 1,  price = 0   },
--     { name = "Shrug",   id = 3576968026, index = 2,  price = 0   },
--     { name = "Stadium", id = 3576947969, index = 3,  price = 150 },
-- }
-- =============================================

-- =============================================
-- FETCH + LOADSTRING
-- =============================================
local emoteData = {}

local ok, result = pcall(function()
	local raw = game:HttpGet(CONFIG.DATA_URL)
	local fn = loadstring(raw)
	assert(fn, "loadstring gagal — cek format Lua di URL")
	return fn()
end)

if ok and type(result) == "table" then
	emoteData = result
else
	warn("[EmoteGUI] Gagal load data:", result)
	emoteData = {
		{ name = "Point2",  id = 3576823880, index = 1,  price = 0   },
		{ name = "Shrug",   id = 3576968026, index = 2,  price = 0   },
		{ name = "Hello",   id = 3576686446, index = 3,  price = 0   },
		{ name = "Tilt",    id = 3576969227, index = 4,  price = 0   },
		{ name = "Smile",   id = 3576823583, index = 5,  price = 0   },
		{ name = "Applaud", id = 3576968047, index = 6,  price = 0   },
		{ name = "Stadium", id = 3576947969, index = 7,  price = 150 },
		{ name = "Salute",  id = 3576686446, index = 8,  price = 200 },
		{ name = "Wave",    id = 3576823880, index = 9,  price = 0   },
		{ name = "Dance",   id = 3576968026, index = 10, price = 0   },
		{ name = "Spin",    id = 3576686446, index = 11, price = 100 },
		{ name = "Flex",    id = 3576969227, index = 12, price = 0   },
	}
end

-- =============================================
-- UKURAN PANEL
-- =============================================
local COLS     = CONFIG.COLUMNS
local CSIZE    = CONFIG.CELL_SIZE
local CPAD     = CONFIG.CELL_PAD
local TOTAL_W  = COLS * (CSIZE + CPAD) + CPAD
local SCROLL_H = CONFIG.MAX_ROWS_VISIBLE * (CSIZE + CPAD) + CPAD
local HEADER_H = 40
local FULL_H   = HEADER_H + SCROLL_H
local CANVAS_H = math.ceil(#emoteData / COLS) * (CSIZE + CPAD) + CPAD

-- =============================================
-- BUILD GUI
-- =============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, TOTAL_W, 0, FULL_H)
panel.Position = UDim2.new(0.5, -TOTAL_W / 2, 1, -(FULL_H + 20))
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(60, 60, 78)
panelStroke.Thickness = 1

-- Header
local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
header.BorderSizePixel = 0
header.ZIndex = 3
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)
local hFix = Instance.new("Frame", header)
hFix.Size = UDim2.new(1, 0, 0, 12)
hFix.Position = UDim2.new(0, 0, 1, -12)
hFix.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
hFix.BorderSizePixel = 0
hFix.ZIndex = 3

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -48, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Emotes  ·  " .. #emoteData
titleLabel.TextColor3 = Color3.fromRGB(210, 210, 225)
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 4

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -36, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
minBtn.TextSize = 13
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 5
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame", panel)
scrollFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
scrollFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 80, 200)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, CANVAS_H)
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
scrollFrame.ZIndex = 2

-- =============================================
-- EMOTE CELLS
-- =============================================
local playing = nil

local function setActive(cell, active)
	TweenService:Create(cell, TweenInfo.new(0.12), {
		BackgroundColor3 = active
			and Color3.fromRGB(50, 38, 85)
			or  Color3.fromRGB(36, 36, 48)
	}):Play()
	local s = cell:FindFirstChild("Stroke")
	if s then s.Color = active and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(55, 55, 72) end
end

local function makeCell(emote, idx)
	local col = (idx - 1) % COLS
	local row = math.floor((idx - 1) / COLS)

	local cell = Instance.new("TextButton", scrollFrame)
	cell.Name = "Cell_" .. idx
	cell.Size = UDim2.new(0, CSIZE, 0, CSIZE)
	cell.Position = UDim2.new(0, CPAD + col * (CSIZE + CPAD), 0, CPAD + row * (CSIZE + CPAD))
	cell.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
	cell.BorderSizePixel = 0
	cell.Text = ""
	cell.AutoButtonColor = false
	cell.ZIndex = 2
	Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", cell)
	stroke.Name = "Stroke"
	stroke.Color = Color3.fromRGB(55, 55, 72)
	stroke.Thickness = 1

	local thumb = Instance.new("ImageLabel", cell)
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(1, -10, 0, CSIZE - 26)
	thumb.Position = UDim2.new(0, 5, 0, 4)
	thumb.BackgroundTransparency = 1
	thumb.Image = ""
	thumb.ZIndex = 3

	local ph = Instance.new("TextLabel", thumb)
	ph.Name = "PH"
	ph.Size = UDim2.new(1, 0, 1, 0)
	ph.BackgroundTransparency = 1
	ph.Text = "▶"
	ph.TextColor3 = Color3.fromRGB(90, 90, 110)
	ph.TextSize = 20
	ph.Font = Enum.Font.Gotham
	ph.ZIndex = 4

	local nameLabel = Instance.new("TextLabel", cell)
	nameLabel.Size = UDim2.new(1, -4, 0, 17)
	nameLabel.Position = UDim2.new(0, 2, 1, -19)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = emote.name
	nameLabel.TextColor3 = Color3.fromRGB(185, 185, 205)
	nameLabel.TextSize = 10
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.ZIndex = 3

	if emote.price and emote.price > 0 then
		local badge = Instance.new("TextLabel", cell)
		badge.Size = UDim2.new(0, 34, 0, 13)
		badge.Position = UDim2.new(1, -36, 0, 3)
		badge.BackgroundColor3 = Color3.fromRGB(240, 175, 0)
		badge.Text = emote.price .. "R$"
		badge.TextColor3 = Color3.fromRGB(60, 40, 0)
		badge.TextSize = 8
		badge.Font = Enum.Font.GothamBold
		badge.BorderSizePixel = 0
		badge.ZIndex = 4
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 4)
	end

	cell.MouseButton1Click:Connect(function()
		if playing == cell then
			playing = nil
			setActive(cell, false)
			ph.Text = "▶" ; ph.Visible = true
			return
		end
		if playing then
			local op  = playing:FindFirstChild("Thumb")
			local oph = op and op:FindFirstChild("PH")
			if oph then oph.Text = "▶" ; oph.Visible = true end
			setActive(playing, false)
		end
		playing = cell
		setActive(cell, true)

		-- lazy fetch thumbnail
		if thumb.Image == "" then
			ph.Text = "·  ·  ·"
			ph.TextColor3 = Color3.fromRGB(140, 100, 255)
			thumb.Image = "rbxthumb://type=Asset&id=" .. emote.id .. "&w=150&h=150"
			task.delay(0.6, function() if ph then ph.Visible = false end end)
		else
			ph.Visible = false
		end

		-- play animasi
		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
		if not animator then return end

		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			if track.Name == "EmoteTrack" then track:Stop() end
		end

		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. emote.id
		local track = animator:LoadAnimation(anim)
		track.Name = "EmoteTrack"
		track.Priority = Enum.AnimationPriority.Action
		track:Play()

		track.Stopped:Connect(function()
			if playing == cell then
				playing = nil
				setActive(cell, false)
				ph.Text = "▶" ; ph.Visible = true
			end
		end)
	end)

	cell.MouseEnter:Connect(function()
		if playing ~= cell then
			TweenService:Create(cell, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(46, 46, 60) }):Play()
		end
	end)
	cell.MouseLeave:Connect(function()
		if playing ~= cell then
			TweenService:Create(cell, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(36, 36, 48) }):Play()
		end
	end)
end

for i, emote in ipairs(emoteData) do
	makeCell(emote, i)
end

-- =============================================
-- MINIMIZE / MAXIMIZE
-- =============================================
local isMinimized = false

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	minBtn.Text = isMinimized and "+" or "—"
	scrollFrame.Visible = not isMinimized
	TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, TOTAL_W, 0, isMinimized and HEADER_H or FULL_H)
	}):Play()
end)

-- =============================================
-- DRAGGABLE
-- =============================================
local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging  = true
		dragStart = input.Position
		startPos  = panel.Position
	end
end)
header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local d = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end
end)