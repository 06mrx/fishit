local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
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

-- Fetch & Decode
local function loadEmoteData()
    local success, raw = pcall(function() return game:HttpGet(CONFIG.DATA_URL) end)
    if success and raw then
        local decodeOk, result = pcall(function() return HttpService:JSONDecode(raw) end)
        if decodeOk and result and result.emotes then return result.emotes end
    end
    return {}
end

local emoteData = loadEmoteData()

-- Ukuran Panel
local COLS     = CONFIG.COLUMNS
local CSIZE    = CONFIG.CELL_SIZE
local CPAD     = CONFIG.CELL_PAD
local TOTAL_W  = COLS * (CSIZE + CPAD) + CPAD
local FULL_H   = (CONFIG.MAX_ROWS_VISIBLE * (CSIZE + CPAD)) + CPAD + 40
local HEADER_H = 40

-- Build UI
if targetGui:FindFirstChild("EmoteGUI_Final") then targetGui.EmoteGUI_Final:Destroy() end

local screenGui = Instance.new("ScreenGui", targetGui)
screenGui.Name = "EmoteGUI_Final"
screenGui.ResetOnSpawn = false

local panel = Instance.new("Frame", screenGui)
panel.Size = UDim2.new(0, TOTAL_W, 0, FULL_H)
panel.Position = UDim2.new(0.5, -TOTAL_W/2, 0.5, -FULL_H/2)
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

-- Header (Drag Area)
local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PARTY NiCH"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0.5, -15)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

-- Scroll
local scroll = Instance.new("ScrollingFrame", panel)
scroll.Size = UDim2.new(1, 0, 1, -HEADER_H)
scroll.Position = UDim2.new(0, 0, 0, HEADER_H)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#emoteData / COLS) * (CSIZE + CPAD))

-- Cell
for i, emote in ipairs(emoteData) do
    local col, row = (i-1)%COLS, math.floor((i-1)/COLS)
    local cell = Instance.new("TextButton", scroll)
    cell.Size = UDim2.new(0, CSIZE, 0, CSIZE)
    cell.Position = UDim2.new(0, CPAD + col*(CSIZE+CPAD), 0, CPAD + row*(CSIZE+CPAD))
    cell.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    cell.Text = ""
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)
    
    local img = Instance.new("ImageLabel", cell)
    img.Size = UDim2.new(0.8, 0, 0.6, 0)
    img.Position = UDim2.new(0.1, 0, 0.1, 0)
    img.BackgroundTransparency = 1
    img.Image = emote.icon or ""
    
    -- Tambahkan servis ini di bagian atas script
local ContentProvider = game:GetService("ContentProvider")

-- Ganti bagian cell.MouseButton1Click menjadi ini:
cell.MouseButton1Click:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    
    if animator then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. emote.id
        
        -- Preload animasi agar tidak gagal saat dimainkan
        pcall(function()
            ContentProvider:PreloadAsync({anim})
        end)

        -- Stop animasi sebelumnya
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Name == "EmoteTrack" then track:Stop() end
        end

        local success, track = pcall(function()
            return animator:LoadAnimation(anim)
        end)

        if success and track then
            track.Name = "EmoteTrack"
            track.Priority = Enum.AnimationPriority.Action
            track:Play()
        else
            warn("Gagal memuat animasi ID: " .. emote.id)
        end
    end
end)
end

-- Logic Minimize
local isMin = false
minBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    minBtn.Text = isMin and "+" or "-"
    local targetY = isMin and HEADER_H or FULL_H
    TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, TOTAL_W, 0, targetY)}):Play()
end)

-- Logic Drag
local drag, startPos, inputPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        startPos = panel.Position
        inputPos = input.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - inputPos
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
header.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)