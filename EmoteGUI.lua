-- EmoteGUI.lua
-- Data emote diambil dari URL raw text (pastebin/github raw dll)
-- Thumbnail hanya di-fetch saat emote diklik

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
	DATA_URL = "https://pastebin.com/raw/XXXXXXXX", -- ganti dengan URL raw JSON kamu
	COLUMNS  = 4,
	CELL_SIZE = 80,
	CELL_PAD  = 8,
}

-- =============================================
-- FORMAT DATA JSON di URL kamu:
-- {
--   "emotes": [
--     { "name": "Point2",  "id": 3576823880, "index": 1, "price": 0 },
--     { "name": "Shrug",   "id": 3576968026, "index": 2, "price": 0 },
--     { "name": "Hello",   "id": 3576686446, "index": 3, "price": 0 }
--   ]
-- }
-- =============================================

-- =============================================
-- FETCH DATA
-- =============================================
local emoteData = {}

local ok, result = pcall(function()
	local raw = HttpService:GetAsync(CONFIG.DATA_URL, true)
	local decoded = HttpService:JSONDecode(raw)
	return decoded.emotes
end)

if ok and result then
	emoteData = result
else
	warn("[EmoteGUI] Gagal fetch data:", result)
	-- fallback data hardcode buat testing
	emoteData = {
		{ name = "Point2", id = 3576823880, index = 1, price = 0 },
		{ name = "Shrug",  id = 3576968026, index = 2, price = 0 },
		{ name = "Hello",  id = 3576686446, index = 3, price = 0 },
	}
end

-- =============================================
-- BUILD GUI
-- =============================================
local COLS   = CONFIG.COLUMNS
local CSIZE  = CONFIG.CELL_SIZE
local CPAD   = CONFIG.CELL_PAD
local TOTAL_W = COLS * (CSIZE + CPAD) + CPAD
local ROWS   = math.ceil(#emoteData / COLS)
local TOTAL_H = ROWS * (CSIZE + CPAD) + CPAD

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Panel utama
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, TOTAL_W, 0, TOTAL_H + 40) -- 40 = header
panel.Position = UDim2.new(0.5, -TOTAL_W / 2, 1, -(TOTAL_H + 40 + 20))
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
panel.BorderSizePixel = 0
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(60, 60, 75)
panelStroke.Thickness = 1
panelStroke.Parent = panel

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
header.BorderSizePixel = 0
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

-- kotak bawah header biar corner bawah ga ikut rounded
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Emotes"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

-- Tombol minimize
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -36, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
minBtn.TextSize = 13
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = header

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 6)
minBtnCorner.Parent = minBtn

-- Grid container (yang bisa di-hide saat minimize)
local gridFrame = Instance.new("Frame")
gridFrame.Name = "Grid"
gridFrame.Size = UDim2.new(1, 0, 1, -40)
gridFrame.Position = UDim2.new(0, 0, 0, 40)
gridFrame.BackgroundTransparency = 1
gridFrame.ClipsDescendants = true
gridFrame.Parent = panel

-- =============================================
-- EMOTE CELLS
-- =============================================
local playing = nil -- emote yang sedang aktif

local function makeCell(emote, idx)
	local row = math.floor((idx - 1) / COLS)
	local col = (idx - 1) % COLS

	local x = CPAD + col * (CSIZE + CPAD)
	local y = CPAD + row * (CSIZE + CPAD)

	local cell = Instance.new("TextButton")
	cell.Name = "Cell_" .. idx
	cell.Size = UDim2.new(0, CSIZE, 0, CSIZE)
	cell.Position = UDim2.new(0, x, 0, y)
	cell.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
	cell.BorderSizePixel = 0
	cell.Text = ""
	cell.AutoButtonColor = false
	cell.Parent = gridFrame

	local cellCorner = Instance.new("UICorner")
	cellCorner.CornerRadius = UDim.new(0, 8)
	cellCorner.Parent = cell

	local cellStroke = Instance.new("UIStroke")
	cellStroke.Color = Color3.fromRGB(55, 55, 70)
	cellStroke.Thickness = 1
	cellStroke.Name = "Stroke"
	cellStroke.Parent = cell

	-- Thumbnail image
	local thumb = Instance.new("ImageLabel")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(1, -16, 0, CSIZE - 30)
	thumb.Position = UDim2.new(0, 8, 0, 6)
	thumb.BackgroundTransparency = 1
	thumb.Image = "" -- kosong dulu, fetch saat klik
	thumb.ImageTransparency = 0.5
	thumb.Parent = cell

	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(0, 5)
	thumbCorner.Parent = thumb

	-- Placeholder icon saat belum di-fetch
	local placeholder = Instance.new("TextLabel")
	placeholder.Name = "Placeholder"
	placeholder.Size = UDim2.new(1, 0, 1, 0)
	placeholder.BackgroundTransparency = 1
	placeholder.Text = "▶"
	placeholder.TextColor3 = Color3.fromRGB(100, 100, 120)
	placeholder.TextSize = 22
	placeholder.Font = Enum.Font.Gotham
	placeholder.Parent = thumb

	-- Nama emote
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -4, 0, 18)
	nameLabel.Position = UDim2.new(0, 2, 1, -20)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = emote.name
	nameLabel.TextColor3 = Color3.fromRGB(200, 200, 215)
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = cell

	-- Badge harga
	if emote.price and emote.price > 0 then
		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(0, 36, 0, 14)
		badge.Position = UDim2.new(1, -38, 0, 4)
		badge.BackgroundColor3 = Color3.fromRGB(255, 185, 0)
		badge.Text = emote.price .. "R$"
		badge.TextColor3 = Color3.fromRGB(60, 40, 0)
		badge.TextSize = 9
		badge.Font = Enum.Font.GothamBold
		badge.BorderSizePixel = 0
		badge.Parent = cell
		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 4)
		bc.Parent = badge
	end

	-- =============================================
	-- KLIK: lazy fetch thumbnail + play emote
	-- =============================================
	cell.MouseButton1Click:Connect(function()
		-- Jika ini sudah playing, stop
		if playing == cell then
			playing = nil
			cell.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
			cell:FindFirstChild("Stroke").Color = Color3.fromRGB(55, 55, 70)
			placeholder.Text = "▶"
			placeholder.TextColor3 = Color3.fromRGB(100, 100, 120)
			-- TODO: stop emote di character
			-- humanoid:GetPlayingAnimationTracks() → stop
			return
		end

		-- Reset sel sebelumnya
		if playing then
			playing.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
			local prevStroke = playing:FindFirstChild("Stroke")
			if prevStroke then prevStroke.Color = Color3.fromRGB(55, 55, 70) end
			local prevThumb = playing:FindFirstChild("Thumb")
			if prevThumb then
				local prevPH = prevThumb:FindFirstChild("Placeholder")
				if prevPH then
					prevPH.Text = "▶"
					prevPH.TextColor3 = Color3.fromRGB(100, 100, 120)
				end
			end
		end

		playing = cell
		cell.BackgroundColor3 = Color3.fromRGB(50, 40, 80)
		cell:FindFirstChild("Stroke").Color = Color3.fromRGB(140, 100, 255)

		-- Lazy fetch thumbnail
		if thumb.Image == "" then
			placeholder.Text = "..."
			placeholder.TextColor3 = Color3.fromRGB(140, 100, 255)
			thumb.Image = "rbxthumb://type=Asset&id=" .. emote.id .. "&w=150&h=150"
			thumb.ImageTransparency = 0
			task.defer(function()
				placeholder.Visible = false
			end)
		end

		-- =============================================
		-- MAINKAN EMOTE
		-- Ganti bagian ini sesuai sistem animasi kamu
		-- Contoh pakai AnimationId langsung:
		-- =============================================
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
			if animator then
				-- Stop semua animasi emote sebelumnya
				for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
					if track.Name == "EmoteTrack" then
						track:Stop()
					end
				end

				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://" .. emote.id
				local track = animator:LoadAnimation(anim)
				track.Name = "EmoteTrack"
				track.Priority = Enum.AnimationPriority.Action
				track:Play()

				-- Auto reset setelah selesai
				track.Stopped:Connect(function()
					if playing == cell then
						playing = nil
						cell.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
						cell:FindFirstChild("Stroke").Color = Color3.fromRGB(55, 55, 70)
					end
				end)
			end
		end
	end)

	-- Hover effect
	cell.MouseEnter:Connect(function()
		if playing ~= cell then
			TweenService:Create(cell, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 65)
			}):Play()
		end
	end)
	cell.MouseLeave:Connect(function()
		if playing ~= cell then
			TweenService:Create(cell, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromRGB(38, 38, 50)
			}):Play()
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
local fullHeight = TOTAL_H + 40
local miniHeight = 40

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	local targetH = isMinimized and miniHeight or fullHeight
	minBtn.Text = isMinimized and "+" or "—"

	TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, TOTAL_W, 0, targetH)
	}):Play()

	gridFrame.Visible = not isMinimized
end)

-- =============================================
-- DRAGGABLE HEADER
-- =============================================
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)