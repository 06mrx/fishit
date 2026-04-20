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

-- =============================================
-- FETCH & DECODE JSON (Perbaikan Baris 40)
-- =============================================
local emoteData = {}

local function loadEmoteData()
    local success, raw = pcall(function()
        return game:HttpGet(CONFIG.DATA_URL)
    end)

    if success and raw then
        -- Gunakan JSONDecode, bukan loadstring karena datanya format JSON
        local decodeOk, result = pcall(function()
            return HttpService:JSONDecode(raw)
        end)

        if decodeOk and result and result.emotes then
            return result.emotes
        end
    end

    -- Fallback jika URL gagal/format salah
    warn("[PARTY NiCH] Gagal fetch JSON, menggunakan data cadangan.")
    return {
        { name = "Point2",  id = 3576823880, index = 1,  price = 0 },
        { name = "Shrug",   id = 3576968026, index = 2,  price = 0 }
    }
end

emoteData = loadEmoteData()

-- =============================================
-- HITUNG UKURAN PANEL
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
-- UI CONSTRUCTION
-- =============================================
if targetGui:FindFirstChild("EmoteGUI_Fixed") then
    targetGui.EmoteGUI_Fixed:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmoteGUI_Fixed"
screenGui.ResetOnSpawn = false
screenGui.Parent = targetGui

local panel = Instance.new("Frame", screenGui)
panel.Name = "Panel"
panel.Size = UDim2.new(0, TOTAL_W, 0, FULL_H)
panel.Position = UDim2.new(0.5, -TOTAL_W / 2, 1, -(FULL_H + 50))
panel.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(60, 60, 78)

-- Header
local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1, 0, 0, HEADER_H)
header.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
header.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "PARTY NiCH  ·  " .. #emoteData
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Scrolling Content
local scrollFrame = Instance.new("ScrollingFrame", panel)
scrollFrame.Size = UDim2.new(1, 0, 1, -HEADER_H)
scrollFrame.Position = UDim2.new(0, 0, 0, HEADER_H)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 2
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, CANVAS_H)

-- =============================================
-- EMOTE LOGIC
-- =============================================
local function makeCell(emote, idx)
    local col = (idx - 1) % COLS
    local row = math.floor((idx - 1) / COLS)

    local cell = Instance.new("TextButton", scrollFrame)
    cell.Size = UDim2.new(0, CSIZE, 0, CSIZE)
    cell.Position = UDim2.new(0, CPAD + col * (CSIZE + CPAD), 0, CPAD + row * (CSIZE + CPAD))
    cell.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
    cell.Text = ""
    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 8)

    local img = Instance.new("ImageLabel", cell)
    img.Size = UDim2.new(1, -10, 1, -25)
    img.Position = UDim2.new(0, 5, 0, 5)
    img.BackgroundTransparency = 1
    -- Gunakan icon dari JSON jika ada
    img.Image = emote.icon or "rbxthumb://type=Asset&id=" .. emote.id .. "&w=150&h=150"

    local name = Instance.new("TextLabel", cell)
    name.Size = UDim2.new(1, 0, 0, 15)
    name.Position = UDim2.new(0, 0, 1, -18)
    name.BackgroundTransparency = 1
    name.Text = emote.name
    name.TextColor3 = Color3.fromRGB(200, 200, 200)
    name.TextSize = 9
    name.Font = Enum.Font.Gotham

    cell.MouseButton1Click:Connect(function()
        local char = player.Character
        local animator = char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid:FindFirstChildOfClass("Animator")
        
        if animator then
            -- Stop emote sebelumnya
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Name == "EmoteTrack" then track:Stop() end
            end

            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. emote.id
            local track = animator:LoadAnimation(anim)
            track.Name = "EmoteTrack"
            track:Play()
        end
    end)
end

for i, emote in ipairs(emoteData) do
    makeCell(emote, i)
end

-- Simple Dragging
local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)