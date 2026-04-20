-- Emote GUI for Executor
-- Target: Roblox Executor (Luau)

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
-- Menggunakan CoreGui atau gethui() agar UI tetap ada meski player mati
local targetGui = (gethui and gethui()) or CoreGui:FindFirstChild("RobloxGui") or CoreGui

-- =============================================
-- KONFIGURASI
-- =============================================
local CONFIG = {
    DATA_URL         = "https://raw.githubusercontent.com/06mrx/fishit/refs/heads/main/Fetch01.txt",
    COLUMNS          = 4,
    CELL_SIZE        = 76,
    CELL_PAD         = 8,
    MAX_ROWS_VISIBLE = 3,
}

-- =============================================
-- FETCH DATA
-- =============================================
local emoteData = {}

local function fetchData()
    local success, raw = pcall(function()
        return game:HttpGet(CONFIG.DATA_URL)
    end)
    
    if success then
        local fn, err = loadstring(raw)
        if fn then
            local result = fn()
            if type(result) == "table" then return result end
        end
    end
    
    -- Fallback data jika link mati/error
    return {
        { name = "Point2",  id = 3576823880, index = 1,  price = 0   },
        { name = "Shrug",   id = 3576968026, index = 2,  price = 0   },
        { name = "Hello",   id = 3576686446, index = 3,  price = 0   },
        { name = "Tilt",    id = 3576969227, index = 4,  price = 0   },
        { name = "Smile",   id = 3576823583, index = 5,  price = 0   },
        { name = "Applaud", id = 3576968047, index = 6,  price = 0   },
        { name = "Stadium", id = 3576947969, index = 7,  price = 150 },
    }
end

emoteData = fetchData()

-- =============================================
-- UKURAN & POSISI
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
-- BUILD UI
-- =============================================
-- Hapus UI lama jika sudah ada (cegah duplikat saat re-run script)
if targetGui:FindFirstChild("EmoteGUI_Exec") then
    targetGui.EmoteGUI_Exec:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGUI_Exec"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Agar posisi lebih akurat
screenGui.Parent = targetGui

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, TOTAL_W, 0, FULL_H)
panel.Position = UDim2.new(0.5, -TOTAL_W / 2, 0.7, -FULL_H / 2)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = false -- Kita pakai custom lerp dragging di bawah
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
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

-- Fix corner bawah header (agar tajam)
local hFix = Instance.new("Frame", header)
hFix.Size = UDim2.new(1, 0, 0, 10)
hFix.Position = UDim2.new(0, 0, 1, -10)
hFix.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
hFix.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PARTY NiCH  ·  " .. #emoteData
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -34, 0.5, -14)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Scroll
local scrollFrame = Instance.new("ScrollingFrame", panel)
scrollFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
scrollFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 255)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, CANVAS_H)

-- =============================================
-- LOGIC EMOTE
-- =============================================
local playing = nil
local currentTrack = nil

local function playEmote(emoteId)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if not animator then return end

    -- Stop track sebelumnya
    if currentTrack then currentTrack:Stop() end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Name == "EmoteTrack" then track:Stop() end
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. emoteId
    
    local success, track = pcall(function() return animator:LoadAnimation(anim) end)
    if success then
        track.Name = "EmoteTrack"
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        currentTrack = track
    end
end

local function makeCell(emote, idx)
    local col = (idx - 1) % COLS
    local row = math.floor((idx - 1) / COLS)

    local cell = Instance.new("TextButton", scrollFrame)
    cell.Size = UDim2.new(0, CSIZE, 0, CSIZE)
    cell.Position = UDim2.new(0, CPAD + col * (CSIZE + CPAD), 0, CPAD + row * (CSIZE + CPAD))
    cell.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    cell.Text = ""
    cell.AutoButtonColor = false
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", cell)
    stroke.Color = Color3.fromRGB(55, 55, 72)

    local nameLabel = Instance.new("TextLabel", cell)
    nameLabel.Size = UDim2.new(1, -4, 0, 20)
    nameLabel.Position = UDim2.new(0, 2, 1, -22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = emote.name
    nameLabel.TextColor3 = Color3.fromRGB(185, 185, 205)
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.Gotham

    cell.MouseButton1Click:Connect(function()
        playEmote(emote.id)
        
        -- Animasi Feedback Klik
        if playing then 
            TweenService:Create(playing.UIStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(55, 55, 72)}):Play()
        end
        playing = cell
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(140, 90, 255)}):Play()
    end)
end

for i, emote in ipairs(emoteData) do
    makeCell(emote, i)
end

-- =============================================
-- SYSTEM: DRAG & MINIMIZE
-- =============================================
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    minBtn.Text = isMinimized and "+" or "—"
    scrollFrame.Visible = not isMinimized
    panel:TweenSize(UDim2.new(0, TOTAL_W, 0, isMinimized and HEADER_H or FULL_H), "Out", "Quart", 0.25, true)
end)

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
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
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[PARTY NiCH] Emote GUI Loaded!")