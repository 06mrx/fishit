--============================================================
-- NOXIUS HUB - ULTRA BLATANT EXCLUSIVE TAB (UPDATED INPUTS)
--============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- PASTIKAN WINDUI & NET LOADED
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    ))()
end)

if not WindUI or not success then
    warn("[UB UI] WindUI gagal dimuat!")
    return
end

local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- REMOTES UTAMA
local RF_Charge   = Net:WaitForChild("RF/ChargeFishingRod")
local RF_Request  = Net:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_Cancel   = Net:WaitForChild("RF/CancelFishingInputs")
local RF_Complete = Net:WaitForChild("RF/CatchFishCompleted")

-- WINDOW SETUP
local Window = WindUI:CreateWindow({
    Title = "NOXIUS HUB",
    Icon = "rbxassetid://77194008928196",
    Author = "Pahaji | Fish It",
    Folder = "NOXIUS_HUB",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Indigo",
    SideBarWidth = 170,
    HasOutline = true,
    User = {
        Enabled = true,
        Anonymous = true,
    },
})

--============================================================
-- 1. ULTRA BLATANT FISHING ENGINE
--============================================================
local UBEngine = {
    Active = false,
    CompleteDelay = 0.001,
    CancelDelay   = 0.001,
    Throttle      = 0.35, -- Kecepatan loop
    BurstCount    = 3,    -- Berapa kali cast per loop
    RecoveryEvery = 5     -- Reset input tiap berapa loop
}

local UBStats = { Loop = 0 }

local TimeProvider = { C = 0 }
function TimeProvider.now()
    UBStats.C = (UBStats.C or 0) + 1
    return UBStats.C
end

local function FishCycleUB()
    local t = TimeProvider.now()

    -- Cast (Non-blocking)
    task.spawn(function() RF_Charge:InvokeServer(t) end)
    task.spawn(function() RF_Request:InvokeServer(0, 1, t) end) -- Vector acak tidak terlalu penting untuk UB

    task.wait(UBEngine.CompleteDelay)
    
    -- Catch (Multi-fire untuk safety)
    task.spawn(function() RF_Complete:InvokeServer() end)
    
    task.wait(UBEngine.CancelDelay)
end

local function MainLoopUB()
    UBStats.Loop = 0
    while UBEngine.Active do
        -- Burst Mode (Cast cepat berulang kali)
        for i = 1, UBEngine.BurstCount do
            if not UBEngine.Active then break end
            FishCycleUB()
            task.wait() -- Yield minimal
        end

        UBStats.Loop = UBStats.Loop + 1
        
        -- Auto Recovery
        if UBStats.Loop >= UBEngine.RecoveryEvery then
            task.spawn(function() RF_Cancel:InvokeServer() end)
            UBStats.Loop = 0
        end

        task.wait(UBEngine.Throttle)
    end
end

function StartUBEngine()
    if UBEngine.Active then return end
    UBEngine.Active = true
    task.spawn(MainLoopUB)
end

function StopUBEngine()
    if not UBEngine.Active then return end
    UBEngine.Active = false
    task.spawn(function() RF_Cancel:InvokeServer() end)
end

--============================================================
-- 2. SKIN ANIMATION REPLACER (LOGIC)
--============================================================
local SkinReplacer = {
    Active = false,
    CurrentSkin = nil,
    Pool = {},
    Killed = {},
    Count = 0
}

local SkinDB = {
    ["Eclipse"] = "rbxassetid://107940819382815",
    ["HolyTrident"] = "rbxassetid://128167068291703",
    ["SoulScythe"] = "rbxassetid://82259219343456",
    ["OceanicHarpoon"] = "rbxassetid://76325124055693",
    ["BinaryEdge"] = "rbxassetid://109653945741202",
    ["Vanquisher"] = "rbxassetid://93884986836266",
    ["KrampusScythe"] = "rbxassetid://134934781977605",
    ["BanHammer"] = "rbxassetid://96285280763544",
    ["CorruptionEdge"] = "rbxassetid://126613975718573",
    ["PrincessParasol"] = "rbxassetid://99143072029495",
    ["CrescendoScythe"] = "rbxassetid://91723046661800", 
    ["Blackhole"] = "rbxassetid://110434285817259",
    ["Ethereal"] = "rbxassetid://116654265230180", 
}

local Char = Player.Character or Player.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local Anim = Hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", Hum)

local function LoadSkinPool(skinName)
    local id = SkinDB[skinName]
    if not id then return false end
    
    -- Clear old
    for _, t in pairs(SkinReplacer.Pool) do pcall(function() t:Stop() t:Destroy() end) end
    SkinReplacer.Pool = {}

    local AnimObj = Instance.new("Animation")
    AnimObj.AnimationId = id
    
    for i = 1, 3 do -- Pool size 3
        local track = Anim:LoadAnimation(AnimObj)
        track.Priority = Enum.AnimationPriority.Action4
        table.insert(SkinReplacer.Pool, track)
    end
    return true
end

local function IsFishAnim(track)
    if not track or not track.Animation then return false end
    local name = string.lower(track.Animation.Name or "")
    return string.find(name, "fishcaught") or string.find(name, "caught")
end

local function ReplaceTrack(orig)
    local newTrack = SkinReplacer.Pool[1]
    if not newTrack then return end
    
    SkinReplacer.Killed[orig] = tick()
    SkinReplacer.Count = SkinReplacer.Count + 1

    task.spawn(function()
        pcall(function() orig:Stop() end)
    end)

    pcall(function()
        if newTrack.IsPlaying then newTrack:Stop() end
        newTrack:Play(0, 1, 1)
    end)
end

-- Hooks
Hum.AnimationPlayed:Connect(function(track)
    if SkinReplacer.Active and IsFishAnim(track) then
        task.spawn(function() ReplaceTrack(track) end)
    end
end)

RunService.RenderStepped:Connect(function()
    if SkinReplacer.Active then
        for _, track in pairs(Hum:GetPlayingAnimationTracks()) do
            if SkinReplacer.Killed[track] then
                pcall(function() track:Stop() end)
            elseif IsFishAnim(track) then
                task.spawn(function() ReplaceTrack(track) end)
            end
        end
    end
end)

function EnableSkinReplacer()
    if not SkinReplacer.CurrentSkin then return false end
    if LoadSkinPool(SkinReplacer.CurrentSkin) then
        SkinReplacer.Active = true
        return true
    end
    return false
end

function DisableSkinReplacer()
    SkinReplacer.Active = false
    for _, t in pairs(SkinReplacer.Pool) do pcall(function() t:Stop() end) end
end

--============================================================
-- 3. CREATE UI TAB
--============================================================
local TabUB = Window:Tab({
    Title = "ULTRA BLATANT",
    Icon = "skull"
})

-- SECTION: ENGINE (UPDATED DENGAN SEMUA INPUT)
TabUB:Section({
    Title = "Core Fishing Engine",
    Icon = "zap",
    TextXAlignment = "Left",
    TextSize = 18,
})
TabUB:Divider()

TabUB:Toggle({
    Title = "Start UB Engine",
    Desc = "Mode Auto Fish Super Cepat (Risk)",
    Default = false,
    Callback = function(v)
        if v then StartUBEngine() else StopUBEngine() end
    end
})

-- 1. BURST COUNT
TabUB:Input({
    Title = "Burst Count",
    Desc = "Berapa kali cast dalam satu loop (Default: 3)",
    Placeholder = "3",
    Default = tostring(UBEngine.BurstCount),
    Callback = function(v)
        local n = tonumber(v)
        if n then UBEngine.BurstCount = math.floor(n) end
    end
})

-- 2. RECOVERY EVERY
TabUB:Input({
    Title = "Recovery Every",
    Desc = "Reset input setelah berapa loop (Default: 5)",
    Placeholder = "5",
    Default = tostring(UBEngine.RecoveryEvery),
    Callback = function(v)
        local n = tonumber(v)
        if n then UBEngine.RecoveryEvery = math.floor(n) end
    end
})

-- 3. THROTTLE (LOOP DELAY)
TabUB:Input({
    Title = "Loop Throttle",
    Desc = "Jeda antar Burst (Default: 0.35)",
    Placeholder = "0.35",
    Default = tostring(UBEngine.Throttle),
    Callback = function(v)
        local n = tonumber(v)
        if n then UBEngine.Throttle = n end
    end
})

-- 4. COMPLETE DELAY
TabUB:Input({
    Title = "Complete Delay",
    Desc = "Delay sebelum call Catch (Default: 0.001)",
    Placeholder = "0.001",
    Default = tostring(UBEngine.CompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then UBEngine.CompleteDelay = n end
    end
})

-- 5. CANCEL DELAY
TabUB:Input({
    Title = "Cancel Delay",
    Desc = "Delay sebelum cancel input (Default: 0.001)",
    Placeholder = "0.001",
    Default = tostring(UBEngine.CancelDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n then UBEngine.CancelDelay = n end
    end
})

TabUB:Button({
    Title = "Force Recovery",
    Desc = "Jika engine stuck, tekan ini",
    Callback = function()
        RF_Cancel:InvokeServer()
        WindUI:Notify({ Title = "Engine", Content = "Recovery Triggered", Duration = 2 })
    end
})

-- SECTION: SKINS
TabUB:Divider()
TabUB:Section({
    Title = "Skin Animation Replacer",
    Icon = "sparkles",
    TextXAlignment = "Left",
    TextSize = 18,
})

local SkinList = {}
for name, _ in pairs(SkinDB) do table.insert(SkinList, name) end
table.sort(SkinList)

TabUB:Dropdown({
    Title = "Select Custom Skin",
    Values = SkinList,
    Default = "Eclipse",
    Callback = function(v)
        SkinReplacer.CurrentSkin = v
        if SkinReplacer.Active then
            EnableSkinReplacer() -- Reload immediately if active
        end
    end
})

TabUB:Toggle({
    Title = "Enable Skin Replacer",
    Default = false,
    Callback = function(v)
        if v then 
            if EnableSkinReplacer() then
                WindUI:Notify({ Title = "Skin", Content = "Active: "..SkinReplacer.CurrentSkin, Duration = 3 })
            else
                WindUI:Notify({ Title = "Error", Content = "Select skin first!", Duration = 3 })
            end
        else 
            DisableSkinReplacer() 
        end
    end
})

-- SECTION: UTILITY
TabUB:Divider()
TabUB:Section({
    Title = "Blatant Utility",
    Icon = "tool",
    TextXAlignment = "Left",
    TextSize = 18,
})

TabUB:Toggle({
    Title = "Noclip [WALL]",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        task.spawn(function()
            while _G.Noclip do
                task.wait()
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end
})

TabUB:Slider({
    Title = "WalkSpeed",
    Value = { Min = 18, Max = 200, Default = 18 },
    Callback = function(v)
        if Hum then Hum.WalkSpeed = v end
    end
})

TabUB:Toggle({
    Title = "Remove Skin VFX",
    Desc = "Lag Fix / Clear Effects",
    Default = false,
    Callback = function(state)
        local VFX = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("VFXController"))
        if state then
            VFX.Handle = function() end
            VFX.RenderAtPoint = function() end
            VFX.RenderInstance = function() end
            local f = workspace:FindFirstChild("CosmeticFolder")
            if f then pcall(f.ClearAllChildren, f) end
        else
            -- Restore logic would go here, simplistic for UB
            WindUI:Notify({ Title = "VFX", Content = "Rejoin to restore VFX fully", Duration = 4 })
        end
    end
})

-- SECTION: WEBHOOK SIMPLE
TabUB:Divider()
TabUB:Section({
    Title = "Notification",
    Icon = "bell",
    TextXAlignment = "Left",
    TextSize = 18,
})

_G.UBWebhookURL = ""
_G.UBWebhookEnabled = false

TabUB:Input({
    Title = "Discord Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(v) _G.UBWebhookURL = v end
})

TabUB:Toggle({
    Title = "Enable Webhook Logger",
    Default = false,
    Callback = function(v) _G.UBWebhookEnabled = v end
})

-- Hook simple webhook logic (Optional)
spawn(function()
    -- Logic sederhana untuk mendeteksi ikan baru di inventory
    -- Menggunakan Replion dari script utama jika tersedia
    local Replion = require(ReplicatedStorage.Packages.Replion).Client:WaitReplion("Data")
    local KnownUUIDs = {}
    
    while task.wait(2) do
        if _G.UBWebhookEnabled and _G.UBWebhookURL ~= "" then
            local inv = Replion:GetExpect({"Inventory", "Items"})
            for _, item in pairs(inv) do
                if item.UUID and not KnownUUIDs[item.UUID] then
                    -- Cek apakah ikan (simplified check)
                    if item.Id and string.find(item.Id, "Fish") then -- Logic check disesuaikan
                        KnownUUIDs[item.UUID] = true
                        -- Kirim Webhook (Logic sederhana)
                        -- ... (Kode request HTTP disini jika diperlukan)
                    end
                end
            end
        end
    end
end)

WindUI:Notify({
    Title = "Noxius UB Loaded",
    Content = "Ultra Blatant UI Ready.",
    Duration = 3,
    Icon = "check"
})