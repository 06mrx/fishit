loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ UI failed to load!")
    return
else
    print("✓ UI loaded successfully!")
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isMobile = game:GetService("UserInputService").TouchEnabled
local net = ReplicatedStorage:WaitForChild("Packages", 10):WaitForChild("_Index", 10):WaitForChild("sleitnick_net@0.2.0",
    10):WaitForChild("net", 10)
local remotes = net:GetChildren()

function GetServerRemote(targetName)
    local allRemotes = net:GetChildren()
    for i, remote in ipairs(allRemotes) do
        if remote.Name == targetName then
            local actualRemote = allRemotes[i + 1]
            return actualRemote
        end
    end
    return nil
end

function GetServerRemoteReverse(targetName)
    local allRemotes = net:GetChildren()
    for i, remote in ipairs(allRemotes) do
        if remote.Name == targetName then
            local actualRemote = allRemotes[i - 1]
            return actualRemote
        end
    end
    return nil
end

print("remotes leng :" .. #remotes)
local Connections = {}
local Events = {}
local AnimationsFolder = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations")
local Override = {}
local g_selectedSkin = "Holy Trident - "
local skinPrefix = ""
local mutationTarget = {}
local Tasks = {}
local lastTimeFishCaught
local isCaught = false
local magix = -2
if #remotes ~= 323 then
    magix = 0
end

local g_character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local g_humanoid = g_character:WaitForChild("Humanoid")
local g_animator = g_humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", g_humanoid)

_G.SavedData = _G.SavedData or {
    FishCaught = {},
    CaughtVisual = {},
    FishNotif = {}
}

function FireLocalEvent(remote, ...)
    local args = {...}
    local signal = remote.OnClientEvent
    for _, connection in pairs(getconnections(signal)) do
        if connection.Function then
            task.spawn(function()
                connection.Function(unpack(args))
            end)
        end
    end
end

function printTable(tbl, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            print(spacing .. tostring(key) .. " = {")
            printTable(value, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. tostring(key) .. " = " .. tostring(value))
        end
    end
end

local saveCount = 0
function HookRemote(humanName, storageKey)
    local remote = GetServerRemote(humanName)
    if remote then
        remote.OnClientEvent:Connect(function(...)
          if saveCount < 7 then
            _G.SavedData[storageKey] = {...}
            local args = {...}
            if storageKey == "CaughtVisual" and tostring(args[1]) == tostring(LocalPlayer.Name)  then
                saveCount = saveCount + 5
            end
          end
        end)
        return true
    end
    return false
end

local Controllers, NotificationController, GiftingController, TextNotificationController, VFXController, CutsceneController, ControlModule, FishingController, AFKController, PromptController, BackpackController
local Replion, PlayerData, ItemUtility, TierUtility

local origCharge, origCast
if isMobile then
    Controllers = ReplicatedStorage:WaitForChild("Controllers")
    NotificationController = require(Controllers:WaitForChild("NotificationController"))
    GiftingController = require(Controllers:WaitForChild("GiftingController"))
    TextNotificationController = require(Controllers:WaitForChild("TextNotificationController"))
    VFXController = require(Controllers:WaitForChild("VFXController"))
    FishingController = require(Controllers:WaitForChild("FishingController"))
    AFKController = require(Controllers:WaitForChild("AFKController"))
    PromptController = require(Controllers:WaitForChild("PromptController"))
    BackpackController = require(Controllers:WaitForChild("BackpackController"))
    CutsceneController = require(Controllers:WaitForChild("CutsceneController"))
    Replion = require(ReplicatedStorage.Packages.Replion)
    PlayerData = Replion.Client:WaitReplion("Data")
    ControlModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    Promise = require(ReplicatedStorage:WaitForChild("Packages").Promise)
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    TierUtility = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("TierUtility"))

    origCharge = FishingController.RequestChargeFishingRod
    origCast = FishingController.SendFishingRequestToServer
end

local needCast = true
local Config = {
    MainLoop = true,
    InstantFishing = false,
    AutoCatch = false,
    Perfection = false,
    isFarming = false,
    isMinig = false,
    AutoFarm = false,
    AutoFarmMegalodon = false,
    AutoFarmChristmas = false,
    AutoFavorite = false,
    CatchDelay = 0.7,
    CastDelay = 1.12,
    ChargeDelay = 0,
    CancelDelay = 0.78,
    DisableAnimations = false,
    PerfectionValue = 0.28,
    onlyMythicAndSecret = false,
    onlyRareAndEpic = false,
    onlySecret = false,
    autoWeather = false,
    removePopUp = false,
    antiFall = false,
    gpuSaver = false,
    customEffect = false,
    AutoSell = true,
    SellDelay = 15,
    SpeedHack = false,
    SpeedHackValue = 60,
    WalkOnWater = false,
    HookNotif = false,
    BackupPerfection = false,
    FavRubyGemstone = false,
    isFreeze = false,
    backupIsFreeze = false,
    autoFishing = false,
    DisablePopUp = false,
    DisableVfx = false,
    DisableCutscene = false,
    CustomWebhook = false,
    WebhookUrl = "https://discord.com/api/webhooks/1477575323561230377/0idg285QzIxWTIbABB4Ha8u_MVaLhoxLiR3cAQUQN7FBqnWwneV1q8TRTsaV0YJlLVI3",
    CustomWebhookUrl = "",
    HideUsn = false,
    AutoMining = false,
    axeUuid = "",
    autoConsumeCaveCrystal = false,
    savePosition = false,
    position = "",
    antiOKOK = false,
    SpinPlayer = false,
    Auto1Totem = false,
    UB = {
        Active = false,
        Settings = {
            CompleteDelay = 2.1,
            CancelDelay = 0.1
        },
        Remotes = {},
        Stats = {
            castCount = 0,
            startTime = 0
        }
    },
    amblatant = false,
    DcUsername = "",
    autoClaimPirateChest = false
}

local needCast, skip = false, false 

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local IntervalWaktu = 60 * 18 

for i, v in pairs(getconnections(LocalPlayer.Idled)) do
    if v.Disable then v:Disable() elseif v.Disconnect then v:Disconnect() end
end

function FireUIAtLocation()
    local x, y = 0, 0
    local guiObjects = LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(x, y)
    
    for _, obj in pairs(guiObjects) do
        if obj:IsA("GuiButton") then
            for _, connection in pairs(getconnections(obj.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(obj.Activated)) do
                connection:Fire()
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(IntervalWaktu)
        FireUIAtLocation()
    end
end)

local whitelistedName = {
    "666chickiwings",
    "inidiayangkumaoo",
    "akunwangi666x",
    "donutsschocoo",
    "xcztalon2",
    "xnmzxc28"
}

function isWhitelisted(displayName)
    displayName = string.lower(displayName)
    for _, name in ipairs(whitelistedName) do
        if string.find(displayName, name, 1, true) then
            return true
        end
    end
    return false
end

function safeFire(func)
    task.spawn(function()
        pcall(func)
    end)
end

-- RF/* di sleitnick_net sering berupa RemoteEvent → pakai FireServer, bukan InvokeServer.
function CallRemoteServer(remote, ...)
    if not remote then return false end
    local ok
    if remote:IsA("RemoteFunction") then
        ok = select(1, pcall(function(...)
            remote:InvokeServer(...)
        end, ...))
    elseif remote:IsA("RemoteEvent") then
        ok = select(1, pcall(function(...)
            remote:FireServer(...)
        end, ...))
    else
        ok = select(1, pcall(function(...)
            remote:InvokeServer(...)
        end, ...))
        if not ok then
            ok = select(1, pcall(function(...)
                remote:FireServer(...)
            end, ...))
        end
    end
    return ok
end

local function safeCall(func)
    pcall(func)
end

local origDeliverNotification = (isMobile) and TextNotificationController.DeliverNotification
local function hookNotification()
    if isMobile then
        TextNotificationController.DeliverNotification = function(self, data, ...)
            if Config.HookNotif then
                data.CustomDuration = 5.8
            end

            if Config.autoFishing and isMobile then
                if (string.find(tostring(data.Text), "stopped") or string.find(tostring(data.Text), "Auto Fishing: Disabled")) then
                    print('stopped')
                    for i = 1,3 do
                        task.wait(0.5)
                        CallRemoteServer(Events.UpdateAutoFishingState, true)
                    end
                end
            end
            return origDeliverNotification(self, data, ...)
        end
    end
end

hookNotification()
Events.equip = GetServerRemote("RF/EquipToolFromHotbar")
Events.unequip = GetServerRemote("RE/UnequipToolFromHotbar")
Events.equipItem = GetServerRemote("RE/EquipItem")
Events.CancelFishingInputs = GetServerRemote("RF/CancelFishingInputs")
Events.charge = GetServerRemote("RF/ChargeFishingRod")
Events.minigame = GetServerRemote("RF/RequestFishingMinigameStarted")
Events.UpdateAutoFishingState = GetServerRemote("RF/UpdateAutoFishingState")

local function castRod()
    pcall(function()
        print('cancel')
        CallRemoteServer(Events.CancelFishingInputs)
        task.wait(0.7)
        CallRemoteServer(Events.charge)
        CallRemoteServer(Events.minigame, -911.1024780273438, 0.9, os.clock())
    end)
end

local function getAxeUUID()
    local inv = PlayerData:GetExpect("Inventory")
    local items = inv.Items
    print('ok item')
    for _, item in ipairs(items) do
        if item.Id == 20220 then
            Config.axeUuid = item.UUID
            print(Config.axeUuid)
        end
    end
end

local function pickAxe()
    getAxeUUID()
    print("pick axe")
    CallRemoteServer(Events.CancelFishingInputs)
    task.wait(0.7)
    Events.unequip:FireServer()
    print("pick axe unequip")
    task.wait(1)
    BackpackController.ToggleHotbarItem(self, Config.axeUuid)
    print(Config.axeUuid)
end

local isNoFallActive = false
local platform = nil
local function createPlatform(position)
    if platform then return end
    platform = Instance.new("Part")
    platform.Name = "AirPlatform"
    platform.Size = Vector3.new(7, 1, 7)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.9
    platform.Position = position - Vector3.new(0, 3, 0)
    platform.Parent = workspace
end

local function equipRod()
    CallRemoteServer(Events.equip, 1)
    if Config.autoFishing or Config.AutoCatch then
        CallRemoteServer(Events.UpdateAutoFishingState, true)
    end
end

local blatantFishCycleCount = 0
local rainbow = 0
local golden = 0
local inventoryFish = 0

function UB_init()
    local success, netFolder = pcall(function()
        return ReplicatedStorage:WaitForChild("Packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("sleitnick_net@0.2.0", 10)
            :WaitForChild("net", 10)
    end)
    if not success or not netFolder then
        warn("Gagal menemukan folder jaringan (net).")
        return false
    end
    
    Config.UB.Remotes.ChargeFishingRod = GetServerRemote("RF/ChargeFishingRod")
    Config.UB.Remotes.RequestMinigame = GetServerRemote("RF/RequestFishingMinigameStarted")
    Config.UB.Remotes.CancelFishingInputs = GetServerRemote("RF/CancelFishingInputs")
    Config.UB.Remotes.UpdateAutoFishingState = GetServerRemote("RF/UpdateAutoFishingState")
    Config.UB.Remotes.FishingCompleted = GetServerRemote("RF/CatchFishCompleted")
    Config.UB.Remotes.FishingCompletedRE = GetServerRemote("RE/CatchFishCompleted")
    Config.UB.Remotes.MinigameChanged = GetServerRemote("RE/FishingMinigameChanged")
    Config.UB.Remotes.equip = GetServerRemote("RF/EquipToolFromHotbar")
    return true
end

function ub_loop()
    while Config.UB.Active do
        if Config.isMinig then
            task.wait(3)
        else
            local currentTime = tick()

            safeFire(function()
            end)

            if Config.autoFishing then CallRemoteServer(Events.UpdateAutoFishingState, true) end

            task.wait(needCast and 0.7 or Config.UB.Settings.CancelDelay)
            needCast = false

            safeFire(function()
                CallRemoteServer(Config.UB.Remotes.ChargeFishingRod, { [1] = currentTime })
                if Config.antiOKOK and not Config.autoFishing then
                    local delay = 17 / 100
                    task.wait(delay)
                end
                CallRemoteServer(Config.UB.Remotes.RequestMinigame, 1, 0, currentTime)
            end)

            task.wait(Config.UB.Settings.CompleteDelay)
            
            if not skip then
                safeFire(function()
                    safeFire(function()
                        CallRemoteServer(Config.UB.Remotes.FishingCompleted)
                    end)
                    
                    Config.UB.Remotes.FishingCompletedRE:FireServer()
                    if Config.amblatant and isCaught then
                        task.spawn(function ()
                            task.wait(0.01)
                            local xremote = GetServerRemote("RE/FishCaught")
                            if xremote then
                                FireLocalEvent(xremote, unpack(_G.SavedData.FishCaught))
                            end
                            xremote = GetServerRemote("RE/CaughtFishVisual")
                            if xremote then
                                FireLocalEvent(xremote, unpack(_G.SavedData.CaughtVisual))
                            end
                            xremote = GetServerRemote("RE/ObtainedNewFishNotification")
                            if xremote then
                                FireLocalEvent(xremote, unpack(_G.SavedData.FishNotif))
                            end
                        end)
                        isCaught = false
                    end
                end)
            end
            blatantFishCycleCount = blatantFishCycleCount + 1
        end
    end
end

function UB_start()
    print("UB_start")
    if Config.UB.Active then
        print("UB sudah aktif.")
        return
    end

    if not UB_init() then
        print("Gagal menginisialisasi UB.")
        return
    end

    Config.UB.Active = true
    needCast = true
    Config.UB.Stats.castCount = 0
    Config.UB.Stats.startTime = tick()
    Config.UB.Settings.CompleteDelay = Config.UB.Settings.CompleteDelay
    Config.UB.Settings.CancelDelay = Config.UB.Settings.CancelDelay
    Tasks.ubtask = task.spawn(ub_loop)
end

function UB_stop()
    if not Config.UB.Active then
        print("UB sudah tidak aktif.")
        return
    end

    Config.UB.Active = false

    safeFire(function()
        if Config.UB.Remotes.CancelFishingInputs then
            CallRemoteServer(Config.UB.Remotes.CancelFishingInputs)
        end
    end)
    
    task.wait(0.2)
    if Tasks.ubtask then
        pcall(function()
            task.cancel(Tasks.ubtask)
        end)
        Tasks.ubtask = nil
    end
    local runtime = tick() - Config.UB.Stats.startTime
    print("UB dihentikan. Waktu berjalan: " .. string.format("%.2f", runtime) .. " detik.")
end

local function onToggleUB(value)
    if value then
        Config.HookNotif = true
        equipRod()
        castRod()
        print("start ub")
        UB_start()
    else
        UB_stop()
        Config.HookNotif = false
    end
end

UB_init()

local HttpService = game:GetService("HttpService")

local targetRarities = {
    mythic = false,
    legendary = false,
    epic = false,
    rare = false,
    uncommon = false
}

local targetWebhookRarities = {
    mythic = false,
    legendary = false,
    epic = false,
    rare = false,
    uncommon = false
}

local CONFIG_FILE = "config_nich4.json"
local MUTATION_CONFIG = "mutation_config_nich4.json"
local RARITY_CONFIG = "rarity_config_nich4.json"
local RARITY_WH_CONFIG = "rarity_wh_config_nich4.json"
local skins = {
    "Holy Trident - ",
    "1x1x1x1 Ban Hammer - ",
    "Corruption Edge - ",
    "Eclipse Katana - ",
}

local function LoadConfig()
    task.spawn(function()
        if isfile(CONFIG_FILE) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(CONFIG_FILE))
            end)
            if ok and typeof(data) == "table" then
                for k, v in pairs(data) do
                    if Config[k] ~= nil then
                        Config[k] = v
                    end
                end
            end
        end
    end)

    task.spawn(function()
        if isfile(MUTATION_CONFIG) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(MUTATION_CONFIG))
            end)
            if ok and typeof(data) == "table" then
                table.clear(mutationTarget)
                for i, v in ipairs(data) do
                    mutationTarget[i] = v
                end
            end
        end
    end)

    task.spawn(function()
        if isfile(RARITY_CONFIG) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(RARITY_CONFIG))
            end)
            if ok and typeof(data) == "table" then
                for k, v in pairs(data) do
                    if targetRarities[k] ~= nil then
                        targetRarities[k] = v
                    end
                end
            end
        end
    end)

    task.spawn(function()
        if isfile(RARITY_WH_CONFIG) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(RARITY_WH_CONFIG))
            end)
            if ok and typeof(data) == "table" then
                for k, v in pairs(data) do
                    if targetWebhookRarities[k] ~= nil then
                        targetWebhookRarities[k] = v
                    end
                end
            end
        end
    end)
end

local function SaveConfig(type)
    if type == 1 then
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    elseif type == 2 then
        writefile(MUTATION_CONFIG, HttpService:JSONEncode(mutationTarget))
    elseif type == 3 then
        writefile(RARITY_CONFIG, HttpService:JSONEncode(targetRarities))
    elseif type == 4 then
        writefile(RARITY_WH_CONFIG, HttpService:JSONEncode(targetWebhookRarities))
    end
end

local function SaveAllConfig()
    SaveConfig(1)
    SaveConfig(2)
    SaveConfig(3)
    SaveConfig(4)
end

local function ResetAllConfig()
    writefile(CONFIG_FILE, "")
    writefile(MUTATION_CONFIG, "")
    writefile(RARITY_CONFIG, "")
    writefile(RARITY_WH_CONFIG, "")
end

LoadConfig()

Config.InstantFishing = false
Config.BlatantFishing = false
Config.Auto1Totem = false
Config.AutoCatch = false
Config.UB.Active = false
Config.WebhookUrl = "https://discord.com/api/webhooks/1477575323561230377/0idg285QzIxWTIbABB4Ha8u_MVaLhoxLiR3cAQUQN7FBqnWwneV1q8TRTsaV0YJlLVI3"

Events.systemMessageEvent = GetServerRemote("RE/DisplaySystemMessage")
Events.fishNotif = GetServerRemote("RE/ObtainedNewFishNotification")

Events.systemMessageEvent.OnClientEvent:Connect(function(...)
    local args = {...}
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    if args[1] then args[1] = args[1]:lower() end
    
    if args[1] then
        if (not string.find(args[1], "global") or string.find(args[1], "server") ) and string.find(args[1], "staff") then
            game.Players.LocalPlayer:Kick("Awas ada sule, eh staff maksudnya")
        end
    end
end)

local LOCATIONS = {
    ["Fisherman"] = CFrame.new(-18.065, 9.532, 2734.000, -0.113811, 0.000000, -0.993502, -0.000000, 1.000000, 0.000000, 0.993502, 0.000000, -0.113811),
    ["Sisyphus Statue"] = CFrame.new(-3754.441, -135.074, -895.376, 0.943844, 0, -0.330393, 0, 1, 0, 0.330393, 0, 0.943844),
    ["Coral Reefs"] = CFrame.new(-3030.043, 2.509, 2271.429, 0.304264, -0.000000, 0.952588, -0.000000, 1.000000, 0.000000, -0.952588, -0.000000, 0.304264),
    ["Esoteric Depths"] = CFrame.new(3271.979, -1301.530, 1402.762, -0.981542, -0.000000, -0.191249, -0.000000, 1.000000, 0.000000, 0.191249, 0.000000, -0.981542),
    ["Crater Island 1"] = CFrame.new(990.610, 21.142, 5060.255, 0.998865, 0.000000, -0.047632, -0.000000, 1.000000, -0.000000, 0.047632, 0.000000, 0.998865),
    ["Crater Island 2"] = CFrame.new(1040.036, 55.714, 5131.443, 0.551438, -0.000000, 0.834216, 0.000000, 1.000000, 0.000000, -0.834216, 0.000000, 0.551438),
    ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
    ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["Tropical Grove"] = CFrame.new(-2132.597, 53.488, 3631.235, -0.664326, -0.000000, 0.747443, -0.000000, 1.000000, 0.000000, -0.747443, -0.000000, -0.664326),
    ["Treasure Room"] = CFrame.new(-3630, -279.074, -1599.287, 0.721647, 0, -0.692261, 0, 1, 0, 0.692261, 0, 0.721647),
    ["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875),
    ["Kohana2"] = CFrame.new(-530.529, 8.750, -72.149, -0.910784, 0, -0.412883, 0, 1, 0, 0.412883, 0, -0.910784),
    ["Underground Cellar"] = CFrame.new(2110.109, -91.199, -699.790, 0.744219, -0.000000, -0.667935, -0.000000, 1.000000, -0.000000, 0.667935, 0.000000, 0.744219),
    ["Ancient Jungle"] = CFrame.new(1837.352, 5.894, -297.224, 0.388620, 0.000000, -0.921398, 0.000000, 1.000000, 0.000000, 0.921398, -0.000000, 0.388620),
    ["Ancient Jungle 2"] = CFrame.new(1468.971, 6.512, -326.397, -0.458676, 0.000000, -0.888603, 0.000000, 1.000000, 0.000000, 0.888603, -0.000000, -0.458676),
    ["Sacred Temple"] = CFrame.new(1459.217, -22.375, -637.787, 0.924266, 0, 0.381750, 0, 1, 0, -0.381750, 0, 0.924266),
    ["Ancient Ruins"] = CFrame.new(6097.176, -585.924, 4644.443, -0.514758, 0, 0.857336, 0, 1, 0, -0.857336, 0, -0.514758),
    ["Megalodon"] = CFrame.new(-1172.987, 7.924, 3620.589, 0.706693, 0, 0.707521, 0, 1, 0, -0.707521, 0, 0.706693),
    ["Pirate Cove"] = CFrame.new(3396.730, 4.192, 3469.213) * CFrame.Angles(-0.000, -1.447, -0.000),
    ["Pirate Treasure Room"] = CFrame.new(3324.07397, -306.475647, 3087.99927, 0.999340534, -1.78439805e-08, 0.0363113917, 2.01013268e-08, 1, -6.18013019e-08, -0.0363113917, 6.24904501e-08, 0.999340534),
    ["Secret Passage"] = CFrame.new(3436.101, -289.845, 3382.640, -0.920254, 0.000000, -0.391321, 0.000000, 1.000000, 0.000000, 0.391321, -0.000000, -0.920254),
    ["Kohana Volcano"] = CFrame.new(-549.192, 20.019, 125.802, 0.955081, 0.000000, -0.296344, -0.000000, 1.000000, 0.000000, 0.296344, -0.000000, 0.955081),
    ["Crystal Depth"] = CFrame.new(5752.219, -907.148, 15343.468, -0.628654, 0.000000, 0.777685, -0.000000, 1.000000, -0.000000, -0.777685, -0.000000, -0.628654),
    ["Lava Basin"] = CFrame.new(950.876, 85.282, -10199.427, 0.105691, -0.000000, 0.994399, -0.000000, 1.000000, 0.000000, -0.994399, -0.000000, 0.105691),
    ["Planetary Observatory"] = CFrame.new(420.372925, 3.673104, 2183.674561, -0.219190, 0.000000, -0.975682, 0.000000, 1.000000, 0.000000, 0.975682, -0.000000, -0.219190),
    ["Underwater City"] = CFrame.new(-3142.405518, -643.484253, -10409.403320, 0.120181, -0.000000, -0.992752, -0.000000, 1.000000, -0.000000, 0.992752, 0.000000, 0.120181),
    ["Swers Area"] = CFrame.new(-1445.962, -1041.589, -10469.594),
}

local function teleport(cf)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = cf + Vector3.new(0, 3, 0)
end

local function teleportToMegalodon()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(obj.Name:lower(), "megalodon") then
            task.wait(0.1)
            if obj:IsA("BasePart") then
                teleport(CFrame.new(obj.Position))
                walkOnWater()
                atMegalodon = true
                Config.isFarming = true
                local rootpart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                oldLocation = rootpart.CFrame
                return
            end
        end
    end
end

local function teleportTo(locationName)
    local cframe = LOCATIONS[locationName]
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if string.find(locationName, "Megalodon") then
        teleportToMegalodon()
    elseif string.find(locationName, "Shark Hunt") then 
        teleportToSharkHunt()
    else
        rootPart.CFrame = cframe
        if string.find(locationName, "Ruins") or string.find(locationName, "Christmas") then 
            createPlatform(rootPart.Position) 
        end
    end
    saveCount = 0
    HookRemote("RE/FishCaught", "FishCaught")
    HookRemote("RE/CaughtFishVisual", "CaughtVisual")
    HookRemote("RE/ObtainedNewFishNotification", "FishNotif")
    currentFishingLocation = cframe
end

Events.sell = GetServerRemote("RF/SellAllItems")
local function sellAll()
    pcall(function()
        return Events.sell:InvokeServer()
    end)
end

if isMobile then
    if Config.Autominings then sellAll() end
    getAxeUUID()
    pickAxe()
end

local function setOverride(selectedSkin)
    g_selectedSkin = selectedSkin
    Override.FishCaught = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "FishCaught"))
    Override.ReelStart = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "ReelStart"))
    Override.RodThrow = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "RodThrow"))
    Override.ReelingIdle = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "ReelingIdle"))
    Override.ReelIntermission = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "ReelIntermission"))
end

local function getBaseName(name)
    local prefix, base = name:match("^(.-)%s*%-%s*(.+)$")
    return base or name
end

local function getPrefix(name)
    local prefix = name:match("^(.-)%s*%-%s*(.+)$")
    return prefix and prefix .. " - " or ""
end

local lastBaseName = nil
local playCount = 0
local lastPlayTime = 0

local function onAnimationPlayed(char)
    if animationConnection then animationConnection:Disconnect() animationConnection = nil end
    
    local humanoid = char:WaitForChild("Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    g_animator = animator
    
    if g_selectedSkin ~= "Default" and Config.customEffect then
        setOverride(g_selectedSkin)
    end

    animationConnection = g_animator.AnimationPlayed:Connect(function(track)
        local l_anim = track.Animation
        
        if Config.customEffect and l_anim then
            local baseName, safePrefix
            if string.find(l_anim.Name, "-") and skinPrefix == "" then
                skinPrefix = getPrefix(l_anim.Name)
                safePrefix = skinPrefix:gsub("%-", "%%-")
                baseName = l_anim.Name:gsub("^" .. safePrefix, "")
            elseif skinprefix ~= "" and string.find(l_anim.Name, "-") then
                safePrefix = skinPrefix:gsub("%-", "%%-")
                baseName = l_anim.Name:gsub("^" .. safePrefix, "")
            else
                baseName = l_anim.Name:gsub(g_selectedSkin, "")
            end

            if Override[baseName] and g_selectedSkin ~= "Default" then
                local currentTime = tick()
                if baseName == lastBaseName then
                    if currentTime - lastPlayTime > 1 then
                        playCount = 0
                    end
                    playCount += 1
                    lastPlayTime = currentTime
                    if playCount > 2 then
                        return
                    end
                else
                    lastBaseName = baseName
                    playCount = 1
                    lastPlayTime = currentTime
                end

                track:Stop(0)
                if not string.find(baseName, "ReelStart")
                and not string.find(baseName, "ReelingIdle")
                and not string.find(baseName, "ReelIntermission") then
                    Override[baseName]:Play()
                end
            end
        elseif Config.DisableAnimations then 
            track:Stop(0)
        end
    end)
end

local function onCharacterAdded(character)
    task.wait(0.5)
    local humanoid = character:WaitForChild("Humanoid")
    g_character = character
    task.wait(0.5)

    if Config.customEffect then
        task.wait(1)
        setOverride(g_selectedSkin)
        task.wait(1)
        onAnimationPlayed(character)
    end
end

onAnimationPlayed(g_character)

local function isExtractPrompt(prompt)
    if not prompt.Enabled then return false end
    if not prompt.ActionText then return false end
    if not prompt.ActionText:lower():find("extract") then return false end
    local parent = prompt.Parent
    if not parent then return false end
    if not parent.Name:lower():find("crystal") then return false end
    return true
end

local function fixPrimaryPart(model)
    if model:IsA("Model") and not model.PrimaryPart then
        local part = model:FindFirstChildWhichIsA("BasePart")
        if part then
            model.PrimaryPart = part
        end
    end
end

local TELEPORT_OFFSET = -4
local function getHrp()
    local character = LocalPlayer.Character             
    local hrp = character:FindFirstChild("HumanoidRootPart")
    return hrp
end

local function moveToPrompt(prompt)
    local hrp = getHrp()
    local target = prompt.Parent
    if target:IsA("Model") then
        fixPrimaryPart(target)
        target = target.PrimaryPart
    end
    if target and target:IsA("BasePart") then
        hrp.CFrame = target.CFrame * CFrame.new(0, 0, TELEPORT_OFFSET)
        createPlatform(hrp.Position)
    end
end

local function miningCrystal()
    teleportTo("Crystal Depth")
    task.wait(3.5)
   
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and isExtractPrompt(prompt) then
            moveToPrompt(prompt)
            task.wait(11)
            fireproximityprompt(prompt)
            task.wait(0.5)
        end
    end
end

local function setMining()
    CallRemoteServer(Events.CancelFishingInputs)
    task.wait(0.7)
    Events.unequip:FireServer()
    task.wait(1)
    pickAxe()
    task.wait(2)
    Config.isFarming = true
    
    local args = {
        Config.axeUuid, "Gears"
    }
    
    miningCrystal()
end

local rainbowCount = 0
local goldenCount = 0
local fishCount = 0

local Event = game:GetService("ReplicatedStorage").Packages._Index["ytrev_replion@2.0.0-rc.3"].replion.Remotes.Set

for _, Connection in getconnections(Event.OnClientEvent) do
    local old; old = hookfunction(Connection.Function, function(...)
        local Args = {...}

        if type(Args[2]) == "table" then
            local category = Args[2][1]
            local subCategory = Args[2][2]

            local function RunNaturalUpdate(type)
                local lastRainbowCount = rainbowCount
                task.spawn(function()
                    for i = 1, 2 do
                        if type == "Rainbow" then
                            rainbowCount = rainbowCount + 1
                            if rainbowCount > 40 then rainbowCount = 0 end
                            old(Args[1], Args[2], rainbowCount)
                        elseif type == "Golden" then
                            goldenCount = goldenCount + 1
                            if goldenCount > 10 then goldenCount = 0 end
                            old(Args[1], Args[2], goldenCount)
                        elseif type == "Fish" then
                            fishCount = fishCount + 1
                            old(Args[1], Args[2], fishCount)
                        end
                        task.wait(0.3) 
                    end
                end)
                if rainbow == lastRainbowCount then isCaught = false else isCaught = true end
            end

            if Config.amblatant then
                if category == "Modifiers" and subCategory == "Rainbow" then
                    RunNaturalUpdate("Rainbow")
                    return 
                elseif category == "Modifiers" and subCategory == "Golden" then
                    RunNaturalUpdate("Golden")
                    return
                elseif category == "InventoryNotifications" and subCategory == "Fish" then
                    RunNaturalUpdate("Fish")
                    return
                end
            end
        end

        return old(...)
    end)
end

Events.SpawnTotem = GetServerRemote("RE/SpawnTotem")
local isNotified = false
local function getTotemUUID()
    totemUUIDs = {}
    isNotified = false
    pcall(function()
        local inv = PlayerData:GetExpect("Inventory")
        if inv and inv.Totems and #inv.Totems > 0 then
            for _, item in ipairs(inv.Totems) do
                if selectedTotemID ~= 0 and selectedTotemID == item.Id then
                    table.insert(totemUUIDs, item.UUID)
                elseif selectedTotemID == 0 and isNotified == false then
                    isNotified = true
                end
            end
        end
    end)
end

local function spawnTotem()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    getTotemUUID()
    local args = { totemUUIDs[1] }
    task.wait(1)
    Events.SpawnTotem:FireServer(unpack(args))
    task.wait(3)
    safeFire(function()
        CallRemoteServer(Events.fishing)
    end)
    if Events.fishing and Events.fishing:IsA("RemoteEvent") then
        pcall(function() Events.fishing:FireServer() end)
    end
    CallRemoteServer(Events.equip, 1)
    task.wait(1)
    equipRod()
end

Events.TextNotification = GetServerRemote("RE/TextNotification")
Events.TextNotification.OnClientEvent:Connect(function(...)
    local args = {...}
    if args[1].Text and string.find(args[1].Text, "vanished!") and Config.Auto1Totem and isMobile then
        task.wait(2)
        spawnTotem()
    end
end)

local function isTargetVariant(variant)
    for _, v in ipairs(mutationTarget) do if v == variant then return true end end
    return false
end

local function getRootPart()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    return rootPart
end

local PlayerDataReplion = nil
local function GetPlayerDataReplion()
    if PlayerDataReplion then return PlayerDataReplion end
    local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then return nil end
    local ReplionClient = require(ReplionModule).Client
    PlayerDataReplion = ReplionClient:WaitReplion("Data", 5)
    return PlayerDataReplion
end

local MerchantReplion = nil
local function GetReplions()
    if MerchantReplion then return true end
    local ReplionModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Replion", 10)
    if not ReplionModule then return false end
    local ReplionClient = require(ReplionModule).Client
    MerchantReplion = ReplionClient:WaitReplion("Merchant", 5)
    return MerchantReplion
end

local function GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
end

local function GetFishNameAndRarity(item)
    local name = item.Identifier or "Unknown"
    local rarity = item.Metadata and item.Metadata.Rarity or "COMMON"
    local itemID = item.Id
    local itemData = nil

    if ItemUtility and itemID then
        pcall(function()
            itemData = ItemUtility:GetItemData(itemID)
            if not itemData then
                local numericID = tonumber(item.Id) or tonumber(item.Identifier)
                if numericID then
                    itemData = ItemUtility:GetItemData(numericID)
                end
            end
        end)
    end

    if itemData and itemData.Data and itemData.Data.Name then
        name = itemData.Data.Name
    end

    if item.Metadata and item.Metadata.Rarity then
        rarity = item.Metadata.Rarity
    elseif itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
        local tierObj = nil
        pcall(function()
            tierObj = TierUtility:GetTierFromRarity(itemData.Probability.Chance)
        end)
        if tierObj and tierObj.Name then
            rarity = tierObj.Name
        end
    end

    return name, rarity
end

local ImageURLCache = {} 
local function GetRobloxAssetImage(assetId)
    if not assetId or assetId == 0 then return nil end
    if ImageURLCache[assetId] then
        return ImageURLCache[assetId]
    end
    
    local url = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%d&size=420x420&format=Png&isCircular=false", assetId)
    local success, response = pcall(game.HttpGet, game, url)
    
    if success then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, response)
        if ok and data and data.data and data.data[1] and data.data[1].imageUrl then
            local finalUrl = data.data[1].imageUrl
            ImageURLCache[assetId] = finalUrl
            return finalUrl
        end
    end
    return nil
end

local function CensorName(name)
    if not name or type(name) ~= "string" or #name < 1 then
        return "N/A" 
    end
    if #name <= 3 then
        return name
    end
    local prefix = name:sub(1, 3)
    local censureLength = #name - 3
    local censorString = string.rep("*", censureLength)
    return prefix .. censorString
end

local function FormatNumber(n)
    if n >= 1000000000 then return string.format("%.1fB", n / 1000000000)
    elseif n >= 1000000 then return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then return string.format("%.1fK", n / 1000)
    else return tostring(n) end
end

local function sendExploitWebhook(url, username, embed_data)
    local payload = {
        username = username,
        embeds = {embed_data},
        allowed_mentions = {
            parse = { "users", "roles" }
        } 
    }
    
    local json_data = HttpService:JSONEncode(payload)
    
    if typeof(request) == "function" then
        local success, response = pcall(function()
            return request({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = json_data
            })
        end)
        
        if success and (response.StatusCode == 200 or response.StatusCode == 204) then
            return true, "Sent"
        elseif success and response.StatusCode then
            return false, "Failed: " .. response.StatusCode
        elseif not success then
            return false, "Error: " .. tostring(response)
        end
    end
    return false, "No Request Func"
end

local function getRarityColor(rarity)
    local r = rarity:upper()
    if r == "SECRET" then return 0x00d3a9 end
    if r == "MYTHIC" then return 0xe22b2e end
    if r == "LEGENDARY" then return 0xFF4500 end
    if r == "EPIC" then return 0x8A2BE2 end
    if r == "RARE" then return 0x0000FF end
    if r == "UNCOMMON" then return 0x00FF00 end
    return 0x00BFFF
end

Events.favorite = GetServerRemote("RE/FavoriteItem")

Connections.fishNotifConnection = Events.fishNotif.OnClientEvent:Connect(function(...)
    local args = {...}
    local arg3 = args[3]
    lastTimeFishCaught = os.clock()
    
    local dummyItem = {Id = args[1], Metadata = args[2]}
    local fishName, fishRarity = GetFishNameAndRarity(dummyItem)
    local fishRarityUpper = fishRarity:upper()
    
    local isUserFilterMatch = false
    isUserFilterMatch = (fishRarityUpper == "SECRET" or (fishName == "Ruby" and arg3.InventoryItem.Metadata.VariantId == "Gemstone"))

    if Config.CustomWebhook then
        if targetWebhookRarities.mythic and fishRarityUpper == "MYTHIC" then isUserFilterMatch = true end
        if targetWebhookRarities.legendary and fishRarityUpper == "LEGENDARY" then isUserFilterMatch = true end
        if targetWebhookRarities.epic and fishRarityUpper == "EPIC" then isUserFilterMatch = true end
        if (fishName == "Ruby" and arg3.InventoryItem.Metadata.VariantId == "Gemstone") then isUserFilterMatch = true end
        if (fishRarityUpper == "LEGENDARY" and mutationDisplay == "Crystalized") then isUserFilterMatch = true end
    end

    if typeof(arg3) == "table" and arg3.InventoryItem and arg3.InventoryItem.UUID then
        if Config.InstantPerfectFishing then
            task.wait(0.2)
            CallRemoteServer(Events.CancelFishingInputs)
            task.wait(0.1)
            CallRemoteServer(Events.charge, 1755848498.4834)
            task.wait(Config.PerfectionValue)
            
            if g_selectedSkin ~= "Default" and Config.customEffect then
                Override.RodThrow = g_animator:LoadAnimation(AnimationsFolder:WaitForChild(g_selectedSkin .. "RodThrow"))
                Override.RodThrow:Play()
            end
            
            CallRemoteServer(Events.minigame, 1.2854545116425, 1)
            task.wait(Config.CatchDelay)
            safeFire(function()
                CallRemoteServer(Events.fishing)
            end)
            if Events.fishing and Events.fishing:IsA("RemoteEvent") then
                pcall(function() Events.fishing:FireServer() end)
            end
        end

        if isTargetVariant(arg3.InventoryItem.Metadata.VariantId) then
            Events.favorite:FireServer(arg3.InventoryItem.UUID)
        end

        if Config.FavRubyGemstone then
            if fishName == "Ruby" and arg3.InventoryItem.Metadata.VariantId == "Gemstone" then
                Events.favorite:FireServer(arg3.InventoryItem.UUID)
            end
        end
        lastTimeFishCaught = os.clock()
    end

    if isMobile or fullExecutor then
        if isUserFilterMatch then
            local fishWeight = string.format("%.2fkg", args[2].Weight or 0)
            local mutationString = GetItemMutationString(dummyItem)
            local mutationDisplay = mutationString ~= "" and mutationString or "N/A"
            local itemData = ItemUtility:GetItemData(args[1])

            local assetId = nil
            if itemData and itemData.Data then
                local iconRaw = itemData.Data.Icon or itemData.Data.ImageId
                if iconRaw then
                    assetId = tonumber(string.match(tostring(iconRaw), "%d+"))
                end
            end
            
            local imageUrl = assetId and GetRobloxAssetImage(assetId) or "https://tr.rbxcdn.com/53eb9b170bea9855c45c9356fb33c070/420/420/Image/Png"
            
            task.wait(0.5)

            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local currentCoins = 0
            local replion = GetPlayerDataReplion()
            
            if replion then
                local success_curr, CurrencyConfig = pcall(function()
                    return require(game:GetService("ReplicatedStorage").Modules.CurrencyUtility.Currency)
                end)

                if success_curr and CurrencyConfig and CurrencyConfig["Coins"] then
                    currentCoins = replion:Get(CurrencyConfig["Coins"].Path) or 0
                else
                    currentCoins = replion:Get("Coins") or replion:Get({"Coins"}) or 0
                end
            else
                if leaderstats then
                    local coinStat = leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("C$")
                    currentCoins = coinStat and coinStat.Value or 0
                end
            end

            local formattedCoins = FormatNumber(currentCoins)
            local playerName = LocalPlayer.DisplayName or LocalPlayer.Name
            local censoredPlayerName = CensorName(playerName)
            
            local globalEmbed = {
                title = ":tropical_fish: Ada Notification NiCH!!! :tropical_fish:",
                description = string.format("Si **%s** baru aja nangkap **%s** dengan mutasi **%s**!!!", censoredPlayerName, fishName, mutationDisplay),
                color = getRarityColor(fishRarityUpper),
                fields = {
                    { name = "<a:ARROW:1438758883203223605> Rarity", value = string.format("`%s`", fishRarityUpper), inline = true },
                    { name = "<a:ARROW:1438758883203223605> Weight", value = string.format("`%s`", fishWeight), inline = true },
                    { name = "<a:ARROW:1438758883203223605> Mutation", value = string.format("`%s`", mutationDisplay), inline = true },
                    { name = "<a:ARROW:1438758883203223605> Date", value = string.format("`%s`", os.date("%Y-%m-%d %H:%M:%S")), inline = true },
                },
                thumbnail = { url = imageUrl },
                footer = { text = "NiCH HUB | Freemium" }
            }
            
            local WEBHOOK_USER = "NiCH HUB - Fishing Notifier"
            if Config.CustomWebhook then
                sendExploitWebhook(Config.CustomWebhookUrl, WEBHOOK_USER, globalEmbed)
            else
                sendExploitWebhook(Config.WebhookUrl, WEBHOOK_USER, globalEmbed)
            end
        end
    end
end)

-- ANTI STUCK / MAINTAINER
task.spawn(function()
    while true do
        task.wait(3)
        if not Config.isFarming or not Config.isMinig then
            if Config.UB.Active and lastTimeFishCaught ~= nil and os.clock() - lastTimeFishCaught >= 5 and blatantFishCycleCount > 1 then
                needCast = true
                saveCount = 0
                blatantFishCycleCount = 0
                lastTimeFishCaught = os.clock()
                onToggleUB(false)
                task.wait(0.5)
                onToggleUB(true)
            end
        end
    end
end)

local Window = WindUI:CreateWindow({
    Title = "NiCH HUB",
    Icon = "rbxassetid://78088064846187",
    Author = "Community",
    Folder = "ASSETS_HUB_NiCH",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Violet",
    SideBarWidth = 170,
    HasOutline = true, 
})

Window:EditOpenButton({Enabled = false})

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local G2L = {}

G2L["ScreenGui_1"] = Instance.new("ScreenGui")
G2L["ScreenGui_1"].Parent = game:GetService("CoreGui")
G2L["ScreenGui_1"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
G2L["ScreenGui_1"].ResetOnSpawn = false
CollectionService:AddTag(G2L["ScreenGui_1"], "main")

G2L["ButtonRezise_2"] = Instance.new("ImageButton")
G2L["ButtonRezise_2"].Parent = G2L["ScreenGui_1"]
G2L["ButtonRezise_2"].BorderSizePixel = 0
G2L["ButtonRezise_2"].Draggable = true
G2L["ButtonRezise_2"].BackgroundColor3 = Color3.fromRGB(200, 0, 255)   -- ← Ubah ke ungu
G2L["ButtonRezise_2"].Image = "rbxassetid://78088064846187"
G2L["ButtonRezise_2"].Size = UDim2.new(0, 47, 0, 47)
G2L["ButtonRezise_2"].Position = UDim2.new(0.13, 0, 0.03, 0)
G2L["ButtonRezise_2"].Visible = true

local corner = Instance.new("UICorner", G2L["ButtonRezise_2"])
corner.CornerRadius = UDim.new(0, 8)

local neon = Instance.new("UIStroke", G2L["ButtonRezise_2"])
neon.Thickness = 2
neon.Color = Color3.fromRGB(200, 0, 255)          -- ← Stroke juga jadi ungu
neon.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local windowVisible = true

G2L["ButtonRezise_2"].MouseButton1Click:Connect(function()
	if windowVisible then
		Window:Close()
	else
		Window:Open()
	end
	windowVisible = not windowVisible
end)

Window:Tag({
    Title = "V.2.1",
    Color = Color3.fromRGB(212, 175, 55),   -- ← Ubah ke ungu cerah
    Radius = 17,
})

Window:Tag({
    Title = "Free",
    Color = Color3.fromRGB(212, 175, 55),   -- ← Ubah ke ungu cerah (sama supaya konsisten)
    Radius = 17,
})

WindUI:Notify({
    Title = "All Fitur Loaded",
    Content = "UI loaded successfully!",
    Duration = 3,
    Icon = "bell",
})

local Tab1 = Window:Tab({ 
    Title = "Info",
    Icon = "rbxassetid://7733964719",
})

Tab1:Section({
    Title = "Community Support",
    Icon = "chevrons-left-right-ellipsis",
    TextXAlignment = "Left",
    TextSize = 17,
})

Tab1:Divider()

Tab1:Button({
    Title = "Discord",
    Desc = "click to copy link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/noxius")
        end
    end
})

Tab1:Divider()

Tab1:Paragraph({
    Title = "Support",
    Desc = "Gabung Discord Untuk Mendapatkan Support",
})

Tab1:Divider()

Tab1:Keybind({
    Title = "Close/Open UI",
    Desc = "Keybind to Close/Open UI",
    Value = "G",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local Tab2 = Window:Tab({
    Title = "Players",
    Icon = "rbxassetid://7743875962",
})

Tab2:Slider({
    Title = "Speed",
    Desc = false,
    Step = 1,
    Value = {
        Min = 18,
        Max = 100,
        Default = 18,
    },
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end
})

Tab2:Slider({
    Title = "Jump",
    Desc = false,
    Step = 1,
    Value = {
        Min = 50,
        Max = 500,
        Default = 50,
    },
    Callback = function(Value)
        _G.CustomJumpPower = Value
        if game.Players.LocalPlayer.Character then
            local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Value
            end
        end
    end
})

Tab2:Divider()

Tab2:Button({
    Title = "Reset Jump Power",
    Desc = "Return Jump Power to normal (50)",
    Callback = function()
        _G.CustomJumpPower = 50
        local humanoid = game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 50
        end
    end
})

Player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.UseJumpPower = true
    humanoid.JumpPower = _G.CustomJumpPower or 50
end)

Tab2:Button({
    Title = "Reset Speed",
    Desc = "Return speed to normal (18)",
    Callback = function()
        if Humanoid then
            Humanoid.WalkSpeed = 18
        end
    end
})

Tab2:Divider()

local UserInputService = game:GetService("UserInputService")

Tab2:Toggle({
    Title = "Infinite Jump",
    Desc = "activate to use infinite jump",
    Icon = false,
    Type = false,
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local character = Player.Character or Player.CharacterAdded:Wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

Tab2:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Icon = false,
    Type = false,
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        task.spawn(function()
            local Player = game:GetService("Players").LocalPlayer
            while _G.Noclip do
                task.wait(0.1)
                if Player.Character then
                    for _, part in pairs(Player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide == true then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
})

local player = game:GetService("Players").LocalPlayer
local freezeConnection
local originalCFrame

Tab2:Toggle({
    Title = "Freeze Character",
    Default = false,
    Callback = function(state)
        _G.FreezeCharacter = state
        if state then
            local character = game.Players.LocalPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    originalCFrame = root.CFrame
                    freezeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        if _G.FreezeCharacter and root then
                            root.CFrame = originalCFrame
                        end
                    end)
                end
            end
        else
            if freezeConnection then
                freezeConnection:Disconnect()
                freezeConnection = nil
            end
        end
    end
})

player.CharacterAdded:Connect(function(char)
    if _G.FreezeCharacter then
        task.wait(0.5)
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = originalCFrame
        end
    end
end)

Tab2:Divider()

local Tab3 = Window:Tab({
    Title = "Main",
    Icon = "rbxassetid://7734053495",
})

Tab3:Section({
    Title = "Auto Enchant & Double Enchant",
    Icon = "sparkles",
})

Events.activateAltarRemote   = GetServerRemote("RE/ActivateEnchantingAltar")
Events.activateAltarRemote2  = GetServerRemote("RE/ActivateEnchantingAltar2")
Events.equipItemRemote       = GetServerRemote("RE/EquipItem")
Events.equipToolRemote       = GetServerRemote("RE/EquipToolFromHotbar")

local STONE_IDS = {
    ["Enchant Stones"]        = 10,
    ["Evolved Enchant Stone"] = 558
}

_G.SelectedStoneType     = _G.SelectedStoneType or "Enchant Stones"
_G.TargetEnchantBasic    = _G.TargetEnchantBasic or "Big Hunter 1"
_G.TargetEnchantEvolved  = _G.TargetEnchantEvolved or "Prismatic 1"
_G.AutoEnchant           = _G.AutoEnchant or false

local basicEnchantNames = {
    "Big Hunter 1", "Cursed 1", "Empowered 1", "Glistening 1",
    "Gold Digger 1", "Leprechaun 1", "Leprechaun 2",
    "Mutation Hunter 1", "Mutation Hunter 2", "Prismatic 1",
    "Reeler 1", "Stargazer 1", "Stormhunter 1", "XPerienced 1"
}

local evolvedEnchantNames = {
    "Prismatic 1", "Cursed 1", "Gold Digger 1", "Empowered 1",
    "SECRET Hunter", "Shark Hunter", "Stargazer II", "Stormhunter II",
    "Mutation Hunter II", "Leprechaun II", "Reeler II", "Mutation Hunter III",
    "Fairy Hunter 1"
}

local enchantIdMap = {
    ["Big Hunter 1"] = 3, ["Cursed 1"] = 12, ["Empowered 1"] = 9,
    ["Glistening 1"] = 1, ["Gold Digger 1"] = 4, ["Leprechaun 1"] = 5,
    ["Leprechaun 2"] = 6, ["Mutation Hunter 1"] = 7, ["Mutation Hunter 2"] = 14,
    ["Prismatic 1"] = 13, ["Reeler 1"] = 2, ["Stargazer 1"] = 8,
    ["Stormhunter 1"] = 11, ["XPerienced 1"] = 10,
    ["SECRET Hunter"] = 16, ["Shark Hunter"] = 20, ["Stargazer II"] = 17,
    ["Stormhunter II"] = 19, ["Mutation Hunter II"] = 14, ["Leprechaun II"] = 6,
    ["Reeler II"] = 21, ["Mutation Hunter III"] = 22, ["Fairy Hunter 1"] = 15
}

local function gStone()
    local it = PlayerData:GetExpect("Inventory")
    if not it or not it.Items then return 0 end
    local targetId = STONE_IDS[_G.SelectedStoneType]
    local total = 0
    for _, v in ipairs(it.Items) do
        if v.Id == targetId then
            total = total + (v.Quantity or 1)
        end
    end
    return total
end

local function countDisplayImageButtons()
    local backpackGui = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
    if not backpackGui then return 0 end
    local display = backpackGui:FindFirstChild("Display")
    if not display then return 0 end
    local count = 0
    for _, child in ipairs(display:GetChildren()) do
        if child:IsA("ImageButton") then 
            count += 1 
        end
    end
    return count
end

local function findEnchantStones()
    local inv = PlayerData:GetExpect("Inventory")
    if not inv or not inv.Items then return {} end
    local targetId = STONE_IDS[_G.SelectedStoneType]
    local stones = {}
    for _, item in ipairs(inv.Items) do
        if item.Id == targetId then
            table.insert(stones, {
                UUID = item.UUID,
                Quantity = item.Quantity or 1,
                Id = item.Id
            })
        end
    end
    return stones
end

local function getEquippedRodName()
    local equipped = PlayerData:Get("EquippedItems")
    if not equipped then return "None" end
    local rods = PlayerData:GetExpect("Inventory")
    if not rods or not rods["Fishing Rods"] then return "None" end
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods["Fishing Rods"]) do
            if rod.UUID == uuid then
                local itemData = ItemUtility:GetItemData(rod.Id)
                return (itemData and itemData.Data and itemData.Data.Name) or rod.ItemName or "None"
            end
        end
    end
    return "None"
end

local function getCurrentRodEnchant()
    local equipped = PlayerData:Get("EquippedItems")
    if not equipped then return nil end
    local rods = PlayerData:GetExpect("Inventory")
    if not rods or not rods["Fishing Rods"] then return nil end
    for _, uuid in pairs(equipped) do
        for _, rod in ipairs(rods["Fishing Rods"]) do
            if rod.UUID == uuid and rod.Metadata and rod.Metadata.EnchantId then
                return rod.Metadata.EnchantId
            end
        end
    end
    return nil
end

local enchantParagraph = Tab3:Paragraph({
    Title = "Enchant Status",
    Content = "Rod Active = <font color='#00aaff'>None</font>\nEnchant Now = <font color='#ff00ff'>None</font>\nStone Left = <font color='#ffff00'>0</font>\nStone Type = <font color='#00ff00'>" .. _G.SelectedStoneType .. "</font>"
})

task.spawn(function()
    local lastRod, lastEnchant, lastStones, lastType = "", "", -1, ""
    while task.wait(2) do
        pcall(function()
            local stones = gStone()
            local rod = getEquippedRodName()
            local enchantId = getCurrentRodEnchant()
            local enchantName = "None"
            
            if enchantId then
                for name, id in pairs(enchantIdMap) do
                    if id == enchantId then
                        enchantName = name
                        break
                    end
                end
            end

            if rod ~= lastRod or enchantName ~= lastEnchant or stones ~= lastStones or _G.SelectedStoneType ~= lastType then
                enchantParagraph:SetDesc(string.format(
                    "Rod Active = <font color='#00aaff'>%s</font>\n" ..
                    "Enchant Now = <font color='#ff00ff'>%s</font>\n" ..
                    "Stone Left = <font color='#ffff00'>%d</font>\n" ..
                    "Stone Type = <font color='#00ff00'>%s</font>",
                    rod, enchantName, stones, _G.SelectedStoneType
                ))
                lastRod, lastEnchant, lastStones, lastType = rod, enchantName, stones, _G.SelectedStoneType
            end
        end)
    end
end)

Tab3:Dropdown({
    Title = "Enchant Stone Type",
    Values = {"Enchant Stones", "Evolved Enchant Stone"},
    Value = _G.SelectedStoneType,
    Callback = function(selected)
        _G.SelectedStoneType = selected
    end
})

Tab3:Dropdown({
    Title = "Target Enchant (Basic Stones)",
    Values = basicEnchantNames,
    Value = _G.TargetEnchantBasic,
    Callback = function(selected)
        _G.TargetEnchantBasic = selected
    end
})

Tab3:Dropdown({
    Title = "Target Enchant (Evolved Stones)",
    Values = evolvedEnchantNames,
    Value = _G.TargetEnchantEvolved,
    Callback = function(selected)
        _G.TargetEnchantEvolved = selected
    end
})

Tab3:Toggle({
    Title = "Auto Enchant (Auto Apply Stone)",
    Value = _G.AutoEnchant,
    Callback = function(value)
        _G.AutoEnchant = value
    end
})

Tab3:Button({
    Title = "Teleport to Altar (Main)",
    Callback = function()
        local cf = CFrame.new(3234.83667, -1302.85486, 1398.39087)
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.CFrame = cf 
        end
    end
})

Tab3:Button({
    Title = "Start Double Enchant",
    Callback = function()
        task.spawn(function()
            if not Events.activateAltarRemote then return end
            local stones = findEnchantStones()
            if #stones == 0 then return end

            Events.equipItemRemote:FireServer(stones[1].UUID, "Enchant Stones")
            task.wait(1.2)

            local slot = countDisplayImageButtons() - 1
            if slot < 1 then slot = 1 end

            Events.equipToolRemote:FireServer(slot)
            task.wait(0.8)
            Events.activateAltarRemote:FireServer()
        end)
    end
})

task.spawn(function()
    while task.wait(1.5) do
        if _G.AutoEnchant then
            pcall(function()
                local targetEnchant = (_G.SelectedStoneType == "Evolved Enchant Stone") 
                    and _G.TargetEnchantEvolved 
                    or _G.TargetEnchantBasic
                
                local currentId = getCurrentRodEnchant()
                local targetId = enchantIdMap[targetEnchant]

                if currentId == targetId then
                    _G.AutoEnchant = false
                    WindUI:Notify({
                        Title = "Auto Enchant",
                        Content = "Target Tercapai: " .. targetEnchant,
                        Duration = 5
                    })
                    return
                end

                local stones = findEnchantStones()
                if #stones > 0 then
                    Events.equipItemRemote:FireServer(stones[1].UUID, "Enchant Stones")
                    task.wait(1.2)

                    local slot = countDisplayImageButtons() - 2
                    if slot < 1 then slot = 1 end

                    Events.equipToolRemote:FireServer(slot)
                    task.wait(1.2)
                    Events.activateAltarRemote:FireServer()
                end
            end)
        end
    end
end)

Tab3:Divider()

Events.searchItemPickedUp = GetServerRemote("RE/SearchItemPickedUp")
Events.gainAccessToMaze   = GetServerRemote("RE/GainAccessToMaze")
Events.claimPirateChest   = GetServerRemote("RE/ClaimPirateChest")

Tab3:Section({
    Title = "Cave & Pirate Events",
    Icon = "map"
})

Tab3:Toggle({
    Title = "Auto Open Mysterious Cave Wall",
    Description = "Otomatis meledakkan dinding gua rahasia",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                if not Events.searchItemPickedUp or not Events.gainAccessToMaze then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Remote Cave tidak ditemukan!",
                        Duration = 5
                    })
                    return
                end

                for i = 1, 4 do
                    pcall(function()
                        Events.searchItemPickedUp:FireServer("TNT")
                    end)
                    task.wait(0.6)
                end
                
                task.wait(1.5)
                pcall(function()
                    Events.gainAccessToMaze:FireServer()
                end)
                
                WindUI:Notify({
                    Title = "Cave Wall",
                    Content = "Mysterious Cave Wall dibuka!",
                    Duration = 5,
                    Icon = "bomb"
                })
            end)
        end
    end
})

Tab3:Toggle({
    Title = "Auto Open Pirate Chest",
    Description = "Auto claim peti bajak laut di sekitar map",
    Default = false,
    Callback = function(state)
        _G.AutoOpenPirateChest = state
        
        if state then
            task.spawn(function()
                while _G.AutoOpenPirateChest do
                    pcall(function()
                        if not Events.claimPirateChest then return end
                        
                        local pirateChestStorage = workspace:FindFirstChild("PirateChestStorage")
                        if not pirateChestStorage then return end
                        
                        local chestsFound = 0
                        for _, chest in ipairs(pirateChestStorage:GetChildren()) do
                            local chestId = chest.Name
                            if chestId:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
                                pcall(function()
                                    Events.claimPirateChest:FireServer(chestId)
                                end)
                                chestsFound = chestsFound + 1
                                task.wait(0.4)
                            end
                        end
                        
                        if chestsFound > 0 then
                            WindUI:Notify({
                                Title = "Pirate Chest",
                                Content = "Claim " .. chestsFound .. " chest berhasil!",
                                Duration = 4,
                                Icon = "package"
                            })
                        end
                    end)
                    task.wait(3)
                end
            end)
            
            WindUI:Notify({
                Title = "Auto Pirate Chest",
                Content = "Aktif - Menunggu peti muncul...",
                Duration = 4,
                Icon = "check-circle"
            })
        else
            WindUI:Notify({
                Title = "Auto Pirate Chest",
                Content = "Dimatikan",
                Duration = 3,
                Icon = "x-circle"
            })
        end
    end
})

Tab3:Divider()

Tab3:Section({
    Title = "Crystal Mining",
    Icon = "gem"
})

local function getAxeUUID()
    local inv = PlayerData:GetExpect("Inventory")
    if inv and inv.Items then
        for _, item in pairs(inv.Items) do
            local itemData = ItemUtility:GetItemData(item.Id)
            if itemData and itemData.Data and (itemData.Data.Name:match("Axe") or itemData.Data.Name:match("Pickaxe")) then
                _G.axeUuid = item.UUID
                return item.UUID
            end
        end
    end
    return nil
end

Tab3:Button({
    Title = "Manual Mining Crystal",
    Description = "Teleport ke Crystal Depth & mining (Balik otomatis)",
    Callback = function()
        if not _G.axeUuid or _G.axeUuid == "" then
            getAxeUUID()
            task.wait(0.5)
            if not _G.axeUuid or _G.axeUuid == "" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Axe/Pickaxe tidak ditemukan di Inventory!",
                    Duration = 4
                })
                return
            end
        end

        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local savedCFrame = rootPart.CFrame

        _G.isMining = true
        
        WindUI:Notify({Title = "Mining", Content = "Otw Crystal Depth...", Duration = 2})
        
        rootPart.CFrame = CFrame.new(1645.5, -214, -2630)
        task.wait(2)

        for i = 1, 2 do
            pcall(function()
                Events.equipItemRemote:FireServer(_G.axeUuid, "Gears")
                task.wait(0.5)
            end)
            task.wait(3)
        end

        _G.isMining = false
        rootPart.CFrame = savedCFrame
        
        WindUI:Notify({
            Title = "Manual Mining",
            Content = "Selesai mining! Kembali ke posisi semula.",
            Duration = 3,
            Icon = "check-circle"
        })
    end
})

Tab3:Toggle({
    Title = "Auto Mining Crystal",
    Description = "Otomatis siapkan Axe saat event muncul",
    Default = _G.AutoMining or false,
    Callback = function(state)
        _G.AutoMining = state
        
        if state then
            local foundAxe = getAxeUUID()
            task.wait(0.3)
            
            if not foundAxe then
                WindUI:Notify({
                    Title = "Warning",
                    Content = "Axe tidak ditemukan, silakan beli Axe dulu.",
                    Duration = 4
                })
            else
                pcall(function()
                    Events.equipItemRemote:FireServer(_G.axeUuid, "Gears")
                end)
                WindUI:Notify({
                    Title = "Auto Mining",
                    Content = "Siap! Axe sudah di-equip otomatis.",
                    Duration = 3,
                    Icon = "zap"
                })
            end
        else
            WindUI:Notify({
                Title = "Auto Mining",
                Content = "Dimatikan",
                Duration = 2.5,
                Icon = "x-circle"
            })
        end
    end
})

Tab3:Divider()

Tab3:Section({
    Title = "Position & Crystal",
    Icon = "save"
})

Events.ConsumeCaveCrystal = GetServerRemote("RF/ConsumeCaveCrystal")

Tab3:Button({
    Title = "Consume Cave Crystal Now",
    Description = "Gunakan cave crystal sekali & equip rod kembali",
    Callback = function()
        if Events.ConsumeCaveCrystal then
            Events.ConsumeCaveCrystal:InvokeServer()
            task.wait(1.5)
            if equipRod then equipRod() end
            WindUI:Notify({
                Title = "Cave Crystal",
                Content = "Crystal dikonsumsi & rod kembali di-equip",
                Duration = 3,
                Icon = "check"
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Remote ConsumeCaveCrystal tidak ditemukan",
                Duration = 4,
                Icon = "alert-circle"
            })
        end
    end
})

Tab3:Toggle({
    Title = "Auto Consume Cave Crystal",
    Description = "Konsumsi cave crystal otomatis setiap 30 menit",
    Default = _G.autoConsumeCaveCrystal or false,
    Callback = function(state)
        _G.autoConsumeCaveCrystal = state
        
        if state then
            if not Events.ConsumeCaveCrystal then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Remote ConsumeCaveCrystal tidak ditemukan!",
                    Duration = 4,
                    Icon = "alert-circle"
                })
                return
            end

            _G.caveCrystalTask = task.spawn(function()
                while _G.autoConsumeCaveCrystal do
                    pcall(function()
                        Events.ConsumeCaveCrystal:InvokeServer()
                        task.wait(1.5)
                        if equipRod then equipRod() end
                    end)
                    task.wait(1800)
                end
            end)

            WindUI:Notify({
                Title = "Auto Consume",
                Content = "Diaktifkan - setiap 30 menit",
                Duration = 3,
                Icon = "timer"
            })
        else
            if _G.caveCrystalTask then
                task.cancel(_G.caveCrystalTask)
                _G.caveCrystalTask = nil
            end
            WindUI:Notify({
                Title = "Auto Consume",
                Content = "Dimatikan",
                Duration = 2.5,
                Icon = "pause-circle"
            })
        end
    end
})

Tab3:Divider()

local Tab4 = Window:Tab({
    Title = "Exclusive",
    Icon = "rbxassetid://7733765398",
})

local rodSettings = {
    ["0. 3 NOTIF KEDIP"] = { CompleteDelay = 2.998 },
    ["1. Diamond / Element"] = { CompleteDelay = 3.7 },
    ["2. 3 NOTIF"] = { CompleteDelay = 2.890 },
    ["3. GF / Bambu"] = { CompleteDelay = 3.7 },
    ["4. Ares/Angler/Astral/Hamzat"] = { CompleteDelay = 4.8 },
}

local settingsList = {}
for name, _ in pairs(rodSettings) do
    table.insert(settingsList, name)
end
table.sort(settingsList)

Tab4:Dropdown({
    Title = "Choose Settings Template",
    Desc = "Pilih settingan untuk Blatant / Fast Fishing",
    Values = settingsList,
    Default = "0. 3 NOTIF KEDIP",
    Callback = function(selectedSetting)
        local chosenTemplate = rodSettings[selectedSetting]
        if chosenTemplate then
            Config.UB.Settings.CompleteDelay = chosenTemplate.CompleteDelay
        end
    end
})

Tab4:Divider()

Tab4:Toggle({
    Title = "AMBLATANT for FUN",
    Desc = "2N Real 2 Visual!!",
    Default = false,
    Callback = function(state)
        Config.amblatant = state
        saveCount = 0
        
        HookRemote("RE/FishCaught", "FishCaught")
        HookRemote("RE/CaughtFishVisual", "CaughtVisual")
        HookRemote("RE/ObtainedNewFishNotification", "FishNotif")
        
        needCast = true
        onToggleUB(state)
        
        if isMobile then
            if state then
                Config.HookNotif = true
                FishingController.RequestChargeFishingRod = function(self, ...) return end
                FishingController.SendFishingRequestToServer = function(self, ...) return end
            else
                Config.HookNotif = false
                FishingController.RequestChargeFishingRod = function(self, ...) return origCharge(self, ...) end
                FishingController.SendFishingRequestToServer = function(self, ...) return origCast(self, ...) end
            end
        end
    end
})

Tab4:Divider()

Tab4:Section({
    Title = "Blatant Fishing",
    Icon = "settings-2"
})

Tab4:Toggle({
    Title = "Blatant Mode",
    Desc = "Kecepatan memancing instan",
    Default = false,
    Callback = function(state)
        needCast = true
        onToggleUB(state)
        
        if isMobile then
            if state then
                Config.HookNotif = true
                FishingController.RequestChargeFishingRod = function(self, ...) return end
                FishingController.SendFishingRequestToServer = function(self, ...) return end
            else
                Config.HookNotif = false
                FishingController.RequestChargeFishingRod = function(self, ...) return origCharge(self, ...) end
                FishingController.SendFishingRequestToServer = function(self, ...) return origCast(self, ...) end
            end
        end
    end
})

Tab4:Input({
    Title = "Compleate Delay",
    Desc = "Input delay untuk Fast Fishing",
    Placeholder = tostring(Config.UB.Settings.CompleteDelay),
    Callback = function(Text)
        Config.UB.Settings.CompleteDelay = tonumber(Text)
    end
})

-- Tab4:Section({
--     Title = "Fast Blatant Fishing",
--     Icon = "settings-2"
-- })

-- Tab4:Toggle({
--     Title = "Fast Blatant (Beta)",
--     Desc = "Lebih Cepat Dan Belum Beres",
--     --Locked = true,
--     Default = false,
--     Callback = function(state)
--         needCast = true
--         onToggleUB(state)
        
--         if isMobile then
--             if state then
--                 Config.HookNotif = true
--                 FishingController.RequestChargeFishingRod = function(self, ...) return end
--                 FishingController.SendFishingRequestToServer = function(self, ...) return end
--             else
--                 Config.HookNotif = false
--                 FishingController.RequestChargeFishingRod = function(self, ...) return origCharge(self, ...) end
--                 FishingController.SendFishingRequestToServer = function(self, ...) return origCast(self, ...) end
--             end
--         end
--     end
-- })

-- Tab4:Input({
--     Title = "Bait Delay",
--     Desc = "Input delay untuk Fast Fishing",
--     Placeholder = tostring(Config.UB.Settings.CompleteDelay),
--     Callback = function(Text)
--         Config.UB.Settings.CompleteDelay = tonumber(Text)
--     end
-- })

Tab4:Toggle({
    Title = "Random Cast",
    Desc = "Menghindari deteksi dengan cast acak",
    Default = Config.antiOKOK,
    Callback = function(state)
        Config.antiOKOK = state
    end
})

local InstantBobberState = {
    instantOverrideActive = false,
    instantOverrideSetupDone = false,
    activeBaitsByUserId = nil,
    cosmeticFolder = nil,
    baitCastConn = nil,
    baitDestroyedConn = nil,
    renderConn = nil,
}

local function patchInstantBaitOverrideToCastPosition(enabled)
    if not enabled then
        InstantBobberState.instantOverrideActive = false
        if InstantBobberState.activeBaitsByUserId then
            table.clear(InstantBobberState.activeBaitsByUserId)
        end
        return
    end

    InstantBobberState.instantOverrideActive = true
    InstantBobberState.activeBaitsByUserId = InstantBobberState.activeBaitsByUserId or {}
    table.clear(InstantBobberState.activeBaitsByUserId)

    if InstantBobberState.instantOverrideSetupDone then
        return
    end
    InstantBobberState.instantOverrideSetupDone = true

    local okCosmetic, cosmeticFolder = pcall(function()
        return workspace:WaitForChild("CosmeticFolder", 5)
    end)
    if not okCosmetic or not cosmeticFolder then
        InstantBobberState.instantOverrideSetupDone = false
        InstantBobberState.instantOverrideActive = false
        return
    end
    InstantBobberState.cosmeticFolder = cosmeticFolder

    local baitCastVisual = GetServerRemote("RE/BaitCastVisual") or GetServerRemote("BaitCastVisual")
    local baitDestroyed = GetServerRemote("RE/BaitDestroyed") or GetServerRemote("BaitDestroyed")

    if not baitCastVisual or not baitCastVisual:IsA("RemoteEvent") then
        InstantBobberState.instantOverrideSetupDone = false
        InstantBobberState.instantOverrideActive = false
        return
    end
    if not baitDestroyed or not baitDestroyed:IsA("RemoteEvent") then
        InstantBobberState.instantOverrideSetupDone = false
        InstantBobberState.instantOverrideActive = false
        return
    end

    local function safeConnect(signal, callback, label)
        if not signal then return nil end
        local ok, conn = pcall(function()
            return signal:Connect(callback)
        end)
        if not ok then
            return nil
        end
        return conn
    end

    InstantBobberState.baitCastConn = safeConnect(baitCastVisual.OnClientEvent, function(player, data)
        if not InstantBobberState.instantOverrideActive then return end
        if not player or not player.UserId then return end
        if not data or not data.CastPosition or typeof(data.CastPosition) ~= "Vector3" then return end

        InstantBobberState.activeBaitsByUserId[player.UserId] = {
            pivot = CFrame.new(data.CastPosition),
            expiresAt = tick() + 1.5,
        }
    end, "BaitCastVisual")

    InstantBobberState.baitDestroyedConn = safeConnect(baitDestroyed.OnClientEvent, function(player)
        if not InstantBobberState.instantOverrideActive then return end
        if not player or not player.UserId then return end
        InstantBobberState.activeBaitsByUserId[player.UserId] = nil
    end, "BaitDestroyed")

    InstantBobberState.renderConn = RunService.RenderStepped:Connect(function()
        if not InstantBobberState.instantOverrideActive then return end

        local now = tick()
        local cosmeticFolder = InstantBobberState.cosmeticFolder
        if not cosmeticFolder then return end

        for userId, entry in pairs(InstantBobberState.activeBaitsByUserId) do
            if now > entry.expiresAt then
                InstantBobberState.activeBaitsByUserId[userId] = nil
                continue
            end

            local model = cosmeticFolder:FindFirstChild(tostring(userId))
            if model and model.PivotTo then
                model:PivotTo(entry.pivot)
            end
        end
    end)
end

Tab4:Toggle({
    Title = "Instant Bobber",
    Desc = "Instan Boober Fhising",
    Default = false,
    Callback = function(state)
        patchInstantBaitOverrideToCastPosition(state)
        WindUI:Notify({
            Title = "Instant Bobber",
            Content = state and "ON (instant cast visual)" or "OFF",
            Duration = 2.5,
            Icon = state and "zap" or "x-circle"
        })
    end
})

if isMobile or fullExecutor then
    Tab4:Toggle({
        Title = "Perfection Enchant",
        Desc = "Spam Perfection secara otomatis",
        Default = false,
        Callback = function(Value) 
            Config.autoFishing = Value
            if Value then
                Config.HookNotif = true
                CallRemoteServer(Events.UpdateAutoFishingState, true)
            else
                CallRemoteServer(Events.UpdateAutoFishingState, false)
                Config.HookNotif = false
            end
        end
    })
end

Tab4:Divider()

local legitSettings = {
    ["0. DEFAULT"] = { CompleteDelay = 0.7 },
    ["1. DM/ELE/GF/BAMBU - 0.78"] = { CompleteDelay = 0.6 },
    ["2. Ares/Angler/Astral/Hamzat - 1.2"] = { CompleteDelay = 1.2 },
}

local weakRodSettingNames = {}
for name, _ in pairs(legitSettings) do
    table.insert(weakRodSettingNames, name)
end
table.sort(weakRodSettingNames)

Events.exclaimEvent = GetServerRemote("RE/ReplicateTextEffect")
Events.fishing = GetServerRemote("RF/CatchFishCompleted")
Events.fishingRE = GetServerRemote("RE/CatchFishCompleted")

Tab4:Section({
    Title = "Legit Fishing",
    Icon = "shield-check"
})

Tab4:Toggle({
    Title = "Legit Fishing",
    Desc = "Memancing otomatis dengan metode yang lebih aman",
    Default = Config.AutoCatch,
    Callback = function(state)
        Config.AutoCatch = state
        if state then
            equipRod()
            if Connections.exclaim then Connections.exclaim:Disconnect() end
            Connections.exclaim = Events.exclaimEvent.OnClientEvent:Connect(function(data)
                if not data or not data.TextData or data.TextData.EffectType ~= "Exclaim" then return end
                local container = data.Container
                if not container or typeof(container) ~= "Instance" then return end
                if tostring(container.Parent) ~= tostring(LocalPlayer.Name) then return end

                if Config.AutoCatch then
                    task.wait(Config.CatchDelay - 0.1)
                    safeFire(function()
                        CallRemoteServer(Events.fishing)
                    end)
                    if Events.fishing and Events.fishing:IsA("RemoteEvent") then
                        pcall(function() Events.fishing:FireServer() end)
                    end
                end
            end)
            CallRemoteServer(Events.UpdateAutoFishingState, true)
        else
            if Connections.exclaim then Connections.exclaim:Disconnect() end
            CallRemoteServer(Events.UpdateAutoFishingState, false)
        end
    end
})

Tab4:Dropdown({
    Title = "Legit Settings Template",
    Desc = "Pilih settingan sesuai rod untuk Legit Fishing",
    Values = weakRodSettingNames,
    Default = "0. CHOOSE SETTINGS",
    Callback = function(selectedSetting)
        local chosenTemplate = legitSettings[selectedSetting]
        if chosenTemplate then
            Config.CatchDelay = chosenTemplate.CompleteDelay
        end
    end
})

Tab4:Input({
    Title = "Legit Catch Delay",
    Desc = "Rekomendasi: 0.7 - 1.5",
    Placeholder = tostring(Config.CatchDelay),
    Callback = function(Text)
        Config.CatchDelay = tonumber(Text)
    end
})

Tab4:Button({
    Title = "Fix Rod",
    Desc = "Gunakan jika rod bug atau tidak bisa ganti skin",
    Callback = function()
        if Config.UB.Remotes.CancelFishingInputs then
            CallRemoteServer(Config.UB.Remotes.CancelFishingInputs)
        elseif Events.CancelFishingInputs then
            CallRemoteServer(Events.CancelFishingInputs)
        end
    end
})

Tab4:Divider()

Tab4:Section({
    Title = "Auto Sell Fish",
    Icon = "shopping-cart"
})

Events.sell = GetServerRemote("RF/SellAllItems")

Config.AutoSellState = Config.AutoSellState or false
Config.AutoSellMethod = Config.AutoSellMethod or "Delay"
Config.AutoSellValue = Config.AutoSellValue or 50

local function GetFishCount()
    local count = 0
    pcall(function()
        if DataService and ItemUtility then
            local inv = DataService:GetExpect({ "Inventory", "Items" })
            if inv then
                for _, item in ipairs(inv) do
                    local info = ItemUtility:GetItemDataFromItemType("Items", item.Id)
                    if info and info.Data and info.Data.Type == "Fish" then
                        count = count + (item.Quantity or 1)
                    end
                end
            end
        end
    end)
    return count
end

local function RunAutoSellLoop()
    if Tasks.AutoSellThread then task.cancel(Tasks.AutoSellThread) end
    
    Tasks.AutoSellThread = task.spawn(function()
        while Config.AutoSellState do
            if not Events.sell then
                WindUI:Notify({ 
                    Title = "Error", 
                    Content = "Remote SellAllItems tidak ditemukan!", 
                    Duration = 5 
                })
                Config.AutoSellState = false
                break
            end
            
            if Config.AutoSellMethod == "Delay" then
                task.wait(math.max(Config.AutoSellValue, 1))
                if Config.AutoSellState then
                    pcall(function() Events.sell:InvokeServer({}) end)
                end
            elseif Config.AutoSellMethod == "Count" then
                local currentCount = GetFishCount()
                if currentCount >= Config.AutoSellValue then
                    pcall(function() Events.sell:InvokeServer({}) end)
                    WindUI:Notify({
                        Title = "Auto Sell",
                        Content = "Inventory penuh! Menjual " .. currentCount .. " ikan.",
                        Duration = 3
                    })
                    task.wait(5)
                end
                task.wait(2)
            end
        end
    end)
end

local countDisplay = Tab4:Paragraph({
    Title = "Current Fish Count: 0",
    Desc = "Menghitung ikan di inventory..."
})

task.spawn(function()
    while true do
        task.wait(2)
        if countDisplay then
            local count = GetFishCount()
            countDisplay:SetTitle("Current Fish Count: " .. tostring(count))
        end
    end
end)

Tab4:Dropdown({
    Title = "Select Selling Method",
    Values = {"Delay", "Count"},
    Default = Config.AutoSellMethod,
    Callback = function(val)
        Config.AutoSellMethod = val
        if Config.AutoSellState then RunAutoSellLoop() end
    end
})

Tab4:Input({
    Title = "Sell Value (Sec/Count)",
    Placeholder = "Masukkan angka...",
    Value = tostring(Config.AutoSellValue),
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            Config.AutoSellValue = num
            WindUI:Notify({
                Title = "Value Updated",
                Content = "Auto Sell set ke: " .. num .. " (" .. Config.AutoSellMethod .. ")",
                Duration = 3
            })
        end
    end
})

Tab4:Toggle({
    Title = "Enable Auto Sell",
    Default = Config.AutoSellState,
    Callback = function(state)
        Config.AutoSellState = state
        if state then
            RunAutoSellLoop()
            local modeMsg = (Config.AutoSellMethod == "Delay") and "Berdasarkan Waktu" or "Berdasarkan Kapasitas"
            WindUI:Notify({ 
                Title = "Auto Sell Aktif", 
                Content = "Mode: " .. modeMsg, 
                Duration = 3 
            })
        else
            if Tasks.AutoSellThread then task.cancel(Tasks.AutoSellThread) end
            WindUI:Notify({ Title = "Auto Sell Mati", Duration = 3 })
        end
    end
})

Tab4:Divider()

local SkinAnimation = (function()
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    local Animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

    local SkinDatabase = {
        ["Eclipse"] = "rbxassetid://107940819382815",
        ["HolyTrident"] = "rbxassetid://128167068291703",
        ["SoulScythe"] = "rbxassetid://82259219343456",
        ["OceanicHarpoon"] = "rbxassetid://76325124055693",
        ["BinaryEdge"] = "rbxassetid://109653945741202",
        ["Vanquisher"] = "rbxassetid://93884986836266",
        ["KrampusScythe"] = "rbxassetid://134934781977605",
        ["BanHammer"] = "rbxassetid://96285280763544",
        ["CorruptionEdge"] = "rbxassetid://126613975718573",
        ["PrincessParasol"] = "rbxassetid://99143072029495"
    }

    local CurrentSkin, AnimationPool, IsEnabled = nil, {}, false
    local killedTracks = {}

    local function LoadAnimationPool(skinId)
        local animId = SkinDatabase[skinId]
        if not animId then return false end
        for _, track in ipairs(AnimationPool) do 
            pcall(function() track:Destroy() end) 
        end
        AnimationPool = {}
        local anim = Instance.new("Animation")
        anim.AnimationId = animId
        for i = 1, 3 do
            local track = Animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action4
            track.Name = "SKIN_POOL_" .. i
            table.insert(AnimationPool, track)
        end
        return true
    end

    local function IsFishCaughtAnimation(track)
        local name = string.lower(track.Name or "")
        return name:find("fishcaught") or name:find("caught")
    end

    local function InstantReplace(originalTrack)
        killedTracks[originalTrack] = tick()
        local nextTrack = AnimationPool[math.random(1, #AnimationPool)]
        if nextTrack then
            pcall(function()
                originalTrack:Stop(0)
                nextTrack:Play(0, 1, 1)
            end)
        end
    end

    humanoid.AnimationPlayed:Connect(function(track)
        if IsEnabled and IsFishCaughtAnimation(track) then 
            InstantReplace(track) 
        end
    end)

    local API = {}
    function API.SwitchSkin(id) 
        CurrentSkin = id
        return IsEnabled and LoadAnimationPool(id) or true 
    end
    function API.Enable() 
        if not CurrentSkin then return false end 
        IsEnabled = LoadAnimationPool(CurrentSkin)
        return IsEnabled 
    end
    function API.Disable() 
        IsEnabled = false
        return true 
    end
    return API
end)()

Tab4:Section({
    Title = "Custom Skin Animation",
    Icon = "sparkles"
})

Tab4:Dropdown({
    Title = "Pilih Custom Skin",
    Values = {"Eclipse", "HolyTrident", "SoulScythe", "OceanicHarpoon", "BinaryEdge", "Vanquisher", "KrampusScythe", "BanHammer", "CorruptionEdge", "PrincessParasol"},
    Default = "Eclipse",
    Callback = function(selected)
        SkinAnimation.SwitchSkin(selected)
    end
})

Tab4:Toggle({
    Title = "Enable Custom Skin Animation",
    Default = false,
    Callback = function(state)
        if state then 
            SkinAnimation.Enable() 
        else 
            SkinAnimation.Disable() 
        end
    end
})

Tab4:Divider()

Tab4:Section({ 
    Title = "Auto Favorite System", 
    Icon = "lock" 
})

local RepStorage = game:GetService("ReplicatedStorage")
local ItemUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("ItemUtility", 10))
local TierUtility = require(RepStorage:WaitForChild("Shared"):WaitForChild("TierUtility", 10))

local function GetPlayerDataReplion()
    local ReplionModule = RepStorage:WaitForChild("Packages"):WaitForChild("Replion", 5)
    if not ReplionModule then return nil end
    return require(ReplionModule).Client:WaitReplion("Data", 5)
end

local function GetFishNameAndRarity(item)
    local name = item.Identifier or "Unknown"
    local rarity = item.Metadata and item.Metadata.Rarity or "COMMON"
    local itemID = item.Id
    local itemData = nil
    
    pcall(function()
        itemData = ItemUtility:GetItemData(itemID)
        if not itemData then
            local numericID = tonumber(item.Id) or tonumber(item.Identifier)
            if numericID then itemData = ItemUtility:GetItemData(numericID) end
        end
    end)
    
    if itemData and itemData.Data and itemData.Data.Name then 
        name = itemData.Data.Name 
    end

    if item.Metadata and item.Metadata.Rarity then
        rarity = item.Metadata.Rarity
    elseif itemData and itemData.Probability and itemData.Probability.Chance and TierUtility then
        local tierObj = nil
        pcall(function() tierObj = TierUtility:GetTierFromRarity(itemData.Probability.Chance) end)
        if tierObj and tierObj.Name then rarity = tierObj.Name end
    end
    return name, rarity
end

local function GetItemMutationString(item)
    if item.Metadata and item.Metadata.Shiny == true then return "Shiny" end
    return item.Metadata and item.Metadata.VariantId or ""
end

Config.AutoFavoriteState = Config.AutoFavoriteState or false
Config.AutoUnfavoriteState = Config.AutoUnfavoriteState or false
Config.SelectedRarities = Config.SelectedRarities or {}
Config.SelectedMutations = Config.SelectedMutations or {}

local RE_FavoriteItem = GetServerRemote("RE/FavoriteItem")

local function RunAutoFavLoop(isUnfavorite)
    local replion = GetPlayerDataReplion()
    if not replion or not RE_FavoriteItem then return end
    
    local success, inventoryData = pcall(function() return replion:GetExpect("Inventory") end)
    if not success or not inventoryData or not inventoryData.Items then return end

    local targets = {}
    for _, item in ipairs(inventoryData.Items) do
        local isAlreadyFav = (item.IsFavorite or item.Favorited)
        if isUnfavorite then
            if not isAlreadyFav then continue end
        else
            if isAlreadyFav then continue end
        end

        local _, rarity = GetFishNameAndRarity(item)
        local mutation = GetItemMutationString(item)
        
        local match = false
        if #Config.SelectedRarities > 0 then
            for _, r in ipairs(Config.SelectedRarities) do
                if string.lower(rarity) == string.lower(r) then match = true; break end
            end
        end
        
        if not match and #Config.SelectedMutations > 0 then
            if table.find(Config.SelectedMutations, mutation) then match = true end
        end

        if match and item.UUID then table.insert(targets, item.UUID) end
    end

    if #targets > 0 then
        WindUI:Notify({ 
            Title = isUnfavorite and "Unlocking Items" or "Locking Items", 
            Content = "Memproses " .. #targets .. " ikan...", 
            Duration = 2 
        })
        for _, uuid in ipairs(targets) do
            if (isUnfavorite and not Config.AutoUnfavoriteState) or (not isUnfavorite and not Config.AutoFavoriteState) then break end
            RE_FavoriteItem:FireServer(uuid)
            task.wait(0.3)
        end
    end
end

Tab4:Dropdown({
    Title = "Filter Rarity",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" },
    Default = Config.SelectedRarities,
    Multi = true,
    Callback = function(v) 
        Config.SelectedRarities = v or {} 
    end
})

Tab4:Dropdown({
    Title = "Filter Mutation",
    Values = {"Galaxy", "Corrupt", "Gemstone", "Fairy Dust", "Midnight", "Color Burn", "Holographic", "Lightning", "Radioactive", "Ghost", "Gold", "Frozen", "1x1x1x1", "Stone", "Sandy", "Noob", "Moon Fragment", "Festive", "Albino", "Arctic Frost", "Disco", "Big", "Giant", "Sparkling", "Crystalized", "Shiny"},
    Default = Config.SelectedMutations,
    Multi = true,
    Callback = function(v) 
        Config.SelectedMutations = v or {} 
    end
})

Tab4:Toggle({
    Title = "Enable Auto Favorite",
    Desc = "Kunci ikan otomatis agar tidak terjual",
    Default = Config.AutoFavoriteState,
    Callback = function(state)
        Config.AutoFavoriteState = state
        if state then
            Tasks.AutoFavoriteThread = task.spawn(function()
                while Config.AutoFavoriteState do 
                    RunAutoFavLoop(false) 
                    task.wait(5) 
                end
            end)
        else
            if Tasks.AutoFavoriteThread then task.cancel(Tasks.AutoFavoriteThread) end
        end
    end
})

Tab4:Toggle({
    Title = "Enable Auto Unfavorite",
    Desc = "Buka kunci semua ikan yang masuk filter",
    Default = Config.AutoUnfavoriteState,
    Callback = function(state)
        Config.AutoUnfavoriteState = state
        if state then
            Tasks.AutoUnfavoriteThread = task.spawn(function()
                while Config.AutoUnfavoriteState do 
                    RunAutoFavLoop(true) 
                    task.wait(5) 
                end
            end)
        else
            if Tasks.AutoUnfavoriteThread then task.cancel(Tasks.AutoUnfavoriteThread) end
        end
    end
})

Tab4:Divider()

Tab4:Section({ 
    Title = "Totem Controls", 
    Icon = "shrub" 
})

local totemData = { 
    ["Pilih Totem"] = 0, 
    ["Luck Totem"] = 1, 
    ["Mutation Totem"] = 2, 
    ["Shiny Totem"] = 3, 
    ["Love Totem"] = 5 
}

Config.SelectedTotemID = Config.SelectedTotemID or 0
Config.AutoTotem = Config.AutoTotem or false
Events.SpawnTotem = GetServerRemote("RE/SpawnTotem")

Tab4:Dropdown({
    Title = "Choose Totem",
    Values = {"Pilih Totem", "Luck Totem", "Mutation Totem", "Shiny Totem", "Love Totem"},
    Default = "Pilih Totem",
    Callback = function(selected)
        Config.SelectedTotemID = totemData[selected] or 0
        WindUI:Notify({ Title = "Totem Dipilih", Content = "Sekarang: " .. selected, Duration = 2.5 })
    end
})

Tab4:Toggle({
    Title = "Auto Spawn Totem",
    Desc = "Spawn otomatis dengan cooldown 1 jam",
    Default = Config.AutoTotem,
    Callback = function(Value)
        Config.AutoTotem = Value
        if Value then
            Tasks.totemTask = task.spawn(function()
                while Config.AutoTotem do
                    local success = false
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local totemUUID = nil
                        pcall(function()
                            local replion = GetPlayerDataReplion()
                            local inv = replion:GetExpect("Inventory")
                            if inv and inv.Totems then
                                for _, item in ipairs(inv.Totems) do
                                    if Config.SelectedTotemID == 0 or item.Id == Config.SelectedTotemID then
                                        totemUUID = item.UUID; break
                                    end
                                end
                            end
                        end)
                        if totemUUID then
                            Events.SpawnTotem:FireServer(totemUUID)
                            task.wait(3)
                            pcall(function()
                                if Events.fishing then CallRemoteServer(Events.fishing) end
                                if Events.equip then CallRemoteServer(Events.equip, 1) end
                            end)
                            task.wait(1)
                            if equipRod then equipRod() end
                            success = true
                            WindUI:Notify({ Title = "Totem Spawn", Content = "Berhasil! Cooldown 1 jam dimulai.", Duration = 4 })
                        end
                    end
                    task.wait(success and 3600 or 30)
                end
            end)
        else
            if Tasks.totemTask then task.cancel(Tasks.totemTask); Tasks.totemTask = nil end
        end
    end
})

Tab4:Section({ 
    Title = "Mix Totem Ritual", 
    Icon = "wand-2" 
})

local function TweenTo(targetCFrame, duration)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Anchored = true
    local t = game:GetService("TweenService"):Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    t:Play(); t.Completed:Wait()
    task.wait(0.2)
end

Tab4:Toggle({
    Title = "Auto Spawn 3 Totem Mix",
    Desc = "Bypass Mode (Shiny -> Luck -> Mutation)",
    --Locked = true,
    Default = Config.AutoMixTotem,
    Callback = function(v)
        Config.AutoMixTotem = v
        if v then
            Tasks.mixTotemThread = task.spawn(function()
                local REF_CENTER = Vector3.new(93.932, 9.532, 2684.134)
                local REF_SPOTS = { Vector3.new(45.046, 13.5, 2730.19), Vector3.new(145.64, 13.5, 2721.9), Vector3.new(84.64, 14.2, 2636.05) }
                local MIX_CONFIG = {{ name = "Shiny Totem", id = 3 }, { name = "Luck Totem", id = 1 }, { name = "Mutation Totem", id = 2 }}
                
                while Config.AutoMixTotem do
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then task.wait(5); continue end
                    local startCFrame = hrp.CFrame
                    
                    for i, config in ipairs(MIX_CONFIG) do
                        if not Config.AutoMixTotem then break end
                        local targetCFrame = CFrame.new(startCFrame.Position + (REF_SPOTS[i] - REF_CENTER))
                        TweenTo(targetCFrame, 2)
                        
                        local p = Instance.new("Part", workspace)
                        p.Size, p.Anchored, p.CFrame, p.Transparency = Vector3.new(12, 1, 12), true, targetCFrame * CFrame.new(0, -3.5, 0), 0.5
                        hrp.Anchored = false; task.wait(0.8)

                        local uuid = nil
                        pcall(function()
                            local inv = GetPlayerDataReplion():GetExpect("Inventory")
                            for _, item in ipairs(inv.Totems) do if item.Id == config.id then uuid = item.UUID; break end end
                        end)
                        
                        if uuid and Events.SpawnTotem then
                            Events.SpawnTotem:FireServer(uuid)
                            task.spawn(function() for _=1,3 do Events.equip:FireServer(1) task.wait(0.3) end end)
                        end
                        task.wait(4); p:Destroy(); hrp.Anchored = true
                    end
                    if Config.AutoMixTotem then
                        TweenTo(startCFrame, 2); hrp.Anchored = false
                        WindUI:Notify({ Title = "Ritual Selesai", Content = "Cooldown 1 jam dimulai", Duration = 5 })
                        task.wait(3600)
                    end
                end
            end)
        else
            if Tasks.mixTotemThread then task.cancel(Tasks.mixTotemThread) end
            if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then 
                LocalPlayer.Character.HumanoidRootPart.Anchored = false 
            end
        end
    end
})

Tab4:Section({ 
    Title = "Merchant Controls", 
    Icon = "store" 
})

Tab4:Toggle({
    Title = "Toggle Market / Merchant",
    Desc = "Buka/tutup GUI Merchant dari mana saja",
    Default = false,
    Callback = function(Value)
        local merchantGui = LocalPlayer.PlayerGui:FindFirstChild("Merchant")
        if merchantGui then 
            merchantGui.Enabled = Value
        else 
            WindUI:Notify({ Title = "Error", Content = "GUI Merchant tidak ditemukan!", Duration = 3 }) 
        end
    end
})

Tab4:Divider()

local Tab5 = Window:Tab({ 
    Title = "Teleport", 
    Icon = "rbxassetid://128755575520135" 
})

Tab5:Section({
    Title = "Map Locations",
    Icon = "navigation",
})

local locationNames = {}
if LOCATIONS then
    for name in pairs(LOCATIONS) do 
        table.insert(locationNames, name)
    end
    table.sort(locationNames)
end

local locationDropdown = Tab5:Dropdown({
    Title = "Select Location",
    Description = "Pilih tempat untuk teleport instan",
    Values = #locationNames > 0 and locationNames or {"-- No Locations Found --"}, 
    Value = "--",
    Callback = function(selectedName)
        if selectedName == "--" or selectedName == "-- No Locations Found --" then return end
        
        if LOCATIONS and LOCATIONS[selectedName] then
            teleportTo(selectedName)
            WindUI:Notify({
                Title = "Teleport Success",
                Content = "Berpindah ke: " .. selectedName,
                Duration = 2.5,
                Icon = "map-pin"
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Lokasi tidak valid atau belum terdaftar.",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})

task.delay(4, function()
    if locationDropdown and locationDropdown.SetValues then
        local newList = {}
        for name in pairs(LOCATIONS or {}) do 
            table.insert(newList, name) 
        end
        table.sort(newList)
        if #newList > 0 then
            locationDropdown:SetValues(newList)
        end
    end
end)

Tab5:Button({
    Title = "Refresh Location List",
    Description = "Update daftar lokasi jika ada perubahan",
    Callback = function()
        local newList = {}
        for name in pairs(LOCATIONS or {}) do
            table.insert(newList, name)
        end
        table.sort(newList)

        if locationDropdown and locationDropdown.SetValues then
            locationDropdown:SetValues(#newList > 0 and newList or {"-- No Locations Found --"})
            WindUI:Notify({
                Title = "Lokasi Diperbarui",
                Content = "Daftar sekarang berisi " .. #newList .. " tempat",
                Duration = 2.5,
                Icon = "refresh-cw"
            })
        end
    end
})

Tab5:Divider()

local SelectedPlayer = nil

Tab5:Section({
    Title = "Player Teleport",
    Icon = "users"
})

local function GetPlayerList()
    local players = {}
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then
            table.insert(players, plr.Name)
        end
    end
    table.sort(players)
    if #players == 0 then return {"Tidak ada player lain"} end
    return players
end

local PlayerDropdown = Tab5:Dropdown({
    Title = "Select Player",
    Description = "Pilih player untuk didatangi",
    Values = GetPlayerList(),
    Value = "--",
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

local function RefreshPlayerList()
    local list = GetPlayerList()
    if PlayerDropdown and PlayerDropdown.SetValues then
        PlayerDropdown:SetValues(list)
    end
end

game.Players.PlayerAdded:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(1)
    RefreshPlayerList()
end)

Tab5:Button({
    Title = "Teleport to Player",
    Description = "Teleport langsung ke posisi player terpilih",
    Callback = function()
        if SelectedPlayer and SelectedPlayer ~= "--" and SelectedPlayer ~= "Tidak ada player lain" then
            local target = game.Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local character = game.Players.LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    WindUI:Notify({
                        Title = "Teleport",
                        Content = "Berhasil ke " .. SelectedPlayer,
                        Duration = 2,
                        Icon = "user"
                    })
                end
            end
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Pilih player dulu!",
                Duration = 3,
                Icon = "alert-circle"
            })
        end
    end
})

Tab5:Divider()

Tab5:Section({
    Title = "Event Teleport",
    Icon = "zap"
})

local Workspace = game:GetService("Workspace")
local megCheckRadius = 150
local autoEventTPEnabled = false
local autoEventThread = nil
local selectedEvents = {}
local createdEventPlatform = nil

local eventData = {
    ["Worm Hunt"] = {
        TargetName = "Model",
        Locations = {
            Vector3.new(2190.85, -1.4, 97.575), 
            Vector3.new(-2450.679, -1.4, 139.731), 
            Vector3.new(-267.479, -1.4, 5188.531),
            Vector3.new(-327, -1.4, 2422)
        },
        PlatformY = 107,
        Priority = 1
    },
    ["Megalodon Hunt"] = {
        TargetName = "Megalodon Hunt",
        Locations = {
            Vector3.new(-1076.3, -1.4, 1676.2),
            Vector3.new(-1191.8, -1.4, 3597.3),
            Vector3.new(412.7, -1.4, 4134.4),
        },
        PlatformY = 107,
        Priority = 2
    },
    ["Ghost Shark Hunt"] = {
        TargetName = "Ghost Shark Hunt",
        Locations = {
            Vector3.new(489.559, -1.35, 25.406), 
            Vector3.new(-1358.216, -1.35, 4100.556), 
            Vector3.new(627.859, -1.35, 3798.081)
        },
        PlatformY = 107,
        Priority = 3
    },
    ["Shark Hunt"] = {
        TargetName = "Shark Hunt",
        Locations = {
            Vector3.new(1.65, -1.35, 2095.725),
            Vector3.new(1369.95, -1.35, 930.125),
            Vector3.new(-1585.5, -1.35, 1242.875),
            Vector3.new(-1896.8, -1.35, 2634.375)
        },
        PlatformY = 107,
        Priority = 4
    },
    ["Thunderzilla Hunt"] = {
        TargetName = "Shocked",
        Locations = {
            Vector3.new(2071.847, -2.673, 15.144),
        },
        PlatformY = 107,
        Priority = 5
    },
}

local eventNames = {}
for name in pairs(eventData) do
    table.insert(eventNames, name)
end

local function destroyEventPlatform()
    if createdEventPlatform then
        createdEventPlatform:Destroy()
        createdEventPlatform = nil
    end
end

local function createAndTeleportToPlatform(targetPos, y)
    local character = game.Players.LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local desiredPos = Vector3.new(targetPos.X, y, targetPos.Z)

    if createdEventPlatform and createdEventPlatform.Parent then
        createdEventPlatform.Position = desiredPos
    else
        destroyEventPlatform()

        local platform = Instance.new("Part")
        platform.Size = Vector3.new(5, 1, 5)
        platform.Position = desiredPos
        platform.Anchored = true
        platform.Transparency = 1
        platform.CanCollide = true
        platform.Color = Color3.fromRGB(0, 170, 255)
        platform.Name = "EventPlatform"
        platform.Parent = Workspace
        createdEventPlatform = platform
    end

    hrp.CFrame = CFrame.new(createdEventPlatform.Position + Vector3.new(0, 3, 0))
end

local function runMultiEventTP()
    while autoEventTPEnabled do
        local sorted = {}
        for _, e in ipairs(selectedEvents) do
            if eventData[e] then table.insert(sorted, eventData[e]) end
        end
        table.sort(sorted, function(a, b) return a.Priority < b.Priority end)

        for _, config in ipairs(sorted) do
            if not autoEventTPEnabled then break end
            
            local foundTarget, foundPos = nil, nil

            if config.TargetName == "Model" then
                local menuRings = Workspace:FindFirstChild("!!! MENU RINGS")
                if menuRings then
                    for _, props in ipairs(menuRings:GetChildren()) do
                        if props.Name == "Props" then
                            local model = props:FindFirstChild("Model")
                            if model and model.PrimaryPart then
                                local modelPos = model.PrimaryPart.Position
                                for _, loc in ipairs(config.Locations) do
                                    if (modelPos - loc).Magnitude <= megCheckRadius then
                                        foundTarget, foundPos = model, modelPos
                                        break
                                    end
                                end
                            end
                        end
                        if foundTarget then break end
                    end
                end
            else
                local searchTargets = Workspace:GetDescendants()
                for _, d in ipairs(searchTargets) do
                    if d.Name == config.TargetName then
                        local pos = nil
                        if d:IsA("BasePart") then
                            pos = d.Position
                        elseif d.PrimaryPart then
                            pos = d.PrimaryPart.Position
                        end

                        if pos then
                            for _, loc in ipairs(config.Locations) do
                                if (pos - loc).Magnitude <= megCheckRadius then
                                    foundTarget, foundPos = d, pos
                                    break
                                end
                            end
                        end
                    end
                    if foundTarget then break end
                end
            end

            if foundTarget and foundPos then
                createAndTeleportToPlatform(foundPos, config.PlatformY)
                break
            end
        end

        task.wait(0.1)
    end
    destroyEventPlatform()
end

Tab5:Dropdown({
    Title = "Select Events",
    Description = "Pilih event yang ingin di-auto-teleport",
    Values = eventNames,
    Multi = true,
    Callback = function(values)
        selectedEvents = values or {}
    end
})

Tab5:Toggle({
    Title = "Auto Event Teleport",
    Description = "Teleport otomatis ke event aktif (Platform Melayang)",
    Default = false,
    Callback = function(state)
        autoEventTPEnabled = state
        if state then
            if #selectedEvents == 0 then
                WindUI:Notify({Title = "Peringatan", Content = "Pilih minimal 1 event!", Duration = 3})
                return
            end
            if autoEventThread then
                task.cancel(autoEventThread)
                autoEventThread = nil
            end
            autoEventThread = task.spawn(runMultiEventTP)
            WindUI:Notify({Title = "Event TP Aktif", Content = "Mencari event di map...", Duration = 3, Icon = "search"})
        else
            destroyEventPlatform()
            if autoEventThread then
                task.cancel(autoEventThread)
                autoEventThread = nil
            end
            WindUI:Notify({Title = "Event TP", Content = "Dimatikan", Duration = 2, Icon = "x-circle"})
        end
    end
})

Tab5:Divider()

Tab5:Section({
    Title = "Leviathan Hunt",
    Icon = "skull"
})

_G.AutoLeviathanHunt = _G.AutoLeviathanHunt or false
local LeviathanThread = nil
local hasTeleportedLeviathan = false

Tab5:Toggle({
    Title = "Auto Leviathan Hunt",
    Description = "Auto teleport ke Leviathan's Den saat zone muncul",
    --Locked = true,
    Default = _G.AutoLeviathanHunt,
    Callback = function(state)
        _G.AutoLeviathanHunt = state
        
        if state then
            hasTeleportedLeviathan = false
            LeviathanThread = task.spawn(function()
                while _G.AutoLeviathanHunt do
                    pcall(function()
                        local zones = workspace:FindFirstChild("Zones")
                        if zones then
                            local leviathanDen = zones:FindFirstChild("Leviathan's Den")
                            if leviathanDen and not hasTeleportedLeviathan then
                                local character = game.Players.LocalPlayer.Character
                                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local targetCFrame = CFrame.new(3474.05298, -287.774719, 3472.63403, -0.915228605, 0.097325258, -0.391004264, 3.60608101e-06, 0.970392585, 0.241532952, 0.402934879, 0.221056461, -0.88813144)
                                    hrp.CFrame = targetCFrame
                                    hasTeleportedLeviathan = true
                                    
                                    WindUI:Notify({
                                        Title = "Leviathan Hunt",
                                        Content = "Berhasil Teleport ke Leviathan's Den!",
                                        Duration = 5,
                                        Icon = "check-circle"
                                    })
                                end
                            elseif not leviathanDen then
                                hasTeleportedLeviathan = false 
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
            
            WindUI:Notify({
                Title = "Leviathan Hunt",
                Content = "Auto Leviathan Hunt Aktif! Mencari zona...",
                Duration = 3,
                Icon = "search"
            })
        else
            if LeviathanThread then
                task.cancel(LeviathanThread)
                LeviathanThread = nil
            end
            hasTeleportedLeviathan = false
            
            WindUI:Notify({
                Title = "Leviathan Hunt",
                Content = "Auto Leviathan Hunt Dimatikan",
                Duration = 3,
                Icon = "x-circle"
            })
        end
    end
})

Tab5:Divider()

local Tab6 = Window:Tab({
    Title = "Shop",
    Icon = "rbxassetid://7733793319"
})

Events.BuyWeather = GetServerRemote("RF/PurchaseWeatherEvent")

Tab6:Section({ 
    Title = "Buy Cuaca (Weather Event)", 
    Icon = "cloud-rain" 
})

local weathers = {
    ["Wind"] = "Wind",
    ["Cloudy"] = "Cloudy",
    ["Snow"] = "Snow",
    ["Storm"] = "Storm",
    ["Radiant"] = "Radiant",
    ["Shark Hunt"] = "Shark Hunt"
}

local weatherNames = {
    "Windy (10k Coins)",
    "Cloudy (20k Coins)",
    "Snow (15k Coins)",
    "Stormy (35k Coins)",
    "Radiant (50k Coins)",
    "Shark Hunt (300k Coins)"
}

local weatherKeyMap = {
    ["Windy (10k Coins)"] = "Wind",
    ["Cloudy (20k Coins)"] = "Cloudy",
    ["Snow (15k Coins)"] = "Snow",
    ["Stormy (35k Coins)"] = "Storm",
    ["Radiant (50k Coins)"] = "Radiant",
    ["Shark Hunt (300k Coins)"] = "Shark Hunt"
}

local selectedWeathers = {}
local autoBuyWeatherRunning = false

Tab6:Dropdown({
    Title = "Select Weather Events",
    Description = "Pilih cuaca yang ingin dibeli",
    Values = weatherNames,
    Multi = true,
    Callback = function(values) 
        selectedWeathers = values or {} 
    end
})

Tab6:Button({
    Title = "Buy Selected Weather",
    Description = "Beli cuaca yang dipilih sekali",
    Callback = function()
        if not Events.BuyWeather then return end
        for _, displayName in ipairs(selectedWeathers) do
            local key = weatherKeyMap[displayName]
            if key and weathers[key] then
                local ok, err = pcall(function()
                    Events.BuyWeather:InvokeServer(weathers[key])
                end)
                if ok then
                    WindUI:Notify({ 
                        Title = "Cuaca", 
                        Content = "Purchased " .. displayName, 
                        Duration = 3 
                    })
                else
                    WindUI:Notify({ 
                        Title = "Error", 
                        Content = tostring(err), 
                        Duration = 5 
                    })
                end
                task.wait(0.5)
            end
        end
        if #selectedWeathers == 0 then
            WindUI:Notify({ 
                Title = "No Selection", 
                Content = "Pilih minimal satu cuaca dulu.", 
                Duration = 3 
            })
        end
    end
})

Tab6:Toggle({
    Title = "Auto Buy Selected Weathers",
    Description = "Terus beli cuaca yang dipilih sampai dimatikan",
    Value = false,
    Callback = function(state)
        autoBuyWeatherRunning = state
        if state then
            if #selectedWeathers == 0 then
                WindUI:Notify({ 
                    Title = "No Selection", 
                    Content = "Pilih minimal satu cuaca sebelum nyalakan.", 
                    Duration = 3 
                })
                autoBuyWeatherRunning = false
                return
            end
            WindUI:Notify({ 
                Title = "Auto Buy Cuaca", 
                Content = "Auto-purchase started.", 
                Duration = 3 
            })
            task.spawn(function()
                while autoBuyWeatherRunning do
                    for _, displayName in ipairs(selectedWeathers) do
                        local key = weatherKeyMap[displayName]
                        if key and weathers[key] then
                            pcall(function()
                                Events.BuyWeather:InvokeServer(weathers[key])
                            end)
                        end
                        task.wait(0.5)
                    end
                    task.wait(5)
                end
            end)
        else
            WindUI:Notify({ 
                Title = "Auto Buy Cuaca", 
                Content = "Stopped.", 
                Duration = 2 
            })
        end
    end
})

Tab6:Section({ 
    Title = "Rod Skin", 
    Icon = "fish" 
})

local rodSkins = {
    "Frozen Krampus Scythe",
    "Gingerbread Katana",
    "Christmas Parasol",
    "Corruption Edge",
    "Eclipse Katana",
    "The Vanquisher",
    "Black Hole Sword",
    "Ban Hammer",
    "Holy Trident",
    "Soul Scythe",
    "Aurelian Bow",
    "Cupid's Harp"
}
local selectedRodSkin = rodSkins[1]

Tab6:Dropdown({
    Title = "Select Rod Skin",
    Description = "Pilih skin rod yang ingin dibeli",
    --Locked = true,
    Values = rodSkins,
    Value = selectedRodSkin,
    Callback = function(v) 
        selectedRodSkin = v 
    end
})

Tab6:Button({
    Title = "Buy Rod Skin",
    Description = "Buka UI beli rod skin",
    --Locked = true,
    Callback = function()
        local ok, err = pcall(function()
            local GiftingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("GiftingController"))
            GiftingController:Open(selectedRodSkin)
        end)
        if ok then
            WindUI:Notify({ 
                Title = "Rod Skin", 
                Content = "Purchased " .. selectedRodSkin .. "!", 
                Duration = 3 
            })
        else
            WindUI:Notify({ 
                Title = "Purchase Error", 
                Content = tostring(err), 
                Duration = 5 
            })
        end
    end
})

Tab6:Section({ 
    Title = "Booster Luck", 
    Icon = "clover" 
})

local luckBoosters = { "x2 Luck", "x4 Luck", "x8 Luck" }
local selectedLuckBooster = luckBoosters[1]

Tab6:Dropdown({
    Title = "Select Luck Booster",
    Description = "Pilih booster luck",
    --Locked = true,
    Values = luckBoosters,
    Value = selectedLuckBooster,
    Callback = function(v) 
        selectedLuckBooster = v 
    end
})

Tab6:Button({
    Title = "Buy Luck Booster",
    Description = "Buka UI beli luck booster",
    --Locked = true,
    Callback = function()
        local ok, err = pcall(function()
            local GiftingController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("GiftingController"))
            GiftingController:Open(selectedLuckBooster)
        end)
        if ok then
            WindUI:Notify({ 
                Title = "Luck Booster", 
                Content = "Purchased " .. selectedLuckBooster .. "!", 
                Duration = 3 
            })
        else
            WindUI:Notify({ 
                Title = "Purchase Error", 
                Content = tostring(err), 
                Duration = 5 
            })
        end
    end
})

Tab6:Divider()

local Tab7 = Window:Tab({
    Title = "Misc",
    Icon = "rbxassetid://7733954611"
})

Tab7:Section({
    Title = "Visual & Notification",
    Icon = "eye-off"
})

if not isMobile then
    Tab7:Paragraph({
        Title = "Info",
        Content = "Fitur ini hanya tersedia di mobile."
    })
else
    local origPlaySmallItemObtained = NotificationController.PlaySmallItemObtained

    local function DisablePlaySmallItemObtained()
        NotificationController.PlaySmallItemObtained = function() end
    end

    local function EnablePlaySmallItemObtained()
        NotificationController.PlaySmallItemObtained = origPlaySmallItemObtained
    end

    Tab7:Toggle({
        Title = "Disable Pop Up Fish Notif",
        Description = "Hapus pop up ketika menangkap ikan",
        Default = Config.DisablePopUp,
        Callback = function(Value)
            Config.DisablePopUp = Value
            if Value then
                DisablePlaySmallItemObtained()
            else
                EnablePlaySmallItemObtained()
            end
        end
    })

    if Config.DisablePopUp then
        DisablePlaySmallItemObtained()
    end

    local _backup = setmetatable({}, { __mode = "k" })

    local function DisableController(controller)
        if _backup[controller] then
            return
        end

        local data = {
            functions = {},
            metatable = getmetatable(controller),
        }

        for k, v in pairs(controller) do
            if type(v) == "function" then
                data.functions[k] = v
                controller[k] = function() end
            end
        end

        local mt = data.metatable or {}
        mt.__index = function(_, key)
            if data.functions[key] then
                return function() end
            end
            return nil
        end
        mt.__newindex = function() end

        setmetatable(controller, mt)
        _backup[controller] = data
    end

    local function EnableController(controller)
        local data = _backup[controller]
        if not data then
            return
        end

        for k, v in pairs(data.functions) do
            controller[k] = v
        end

        setmetatable(controller, data.metatable)
        _backup[controller] = nil
    end

    Tab7:Toggle({
        Title = "Disable VFX",
        Description = "Hapus efek dan suara skin",
        Default = Config.DisableVfx,
        Callback = function(Value)
            Config.DisableVfx = Value
            if Value then
                DisableController(VFXController)
            else
                EnableController(VFXController)
            end
        end
    })

    if Config.DisableVfx then
        DisableController(VFXController)
    end

    Tab7:Toggle({
        Title = "Disable Cutscene",
        Description = "Hapus animasi tangkapan ikan",
        Default = Config.DisableCutscene,
        Callback = function(Value)
            Config.DisableCutscene = Value
            if Value then
                DisableController(CutsceneController)
            else
                EnableController(CutsceneController)
            end
        end
    })

    if Config.DisableCutscene then
        DisableController(CutsceneController)
    end
end

local stopAnimConnections = {}

local function setGameAnimationsEnabled(enabled)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    
    for _, conn in ipairs(stopAnimConnections) do
        conn:Disconnect()
    end
    stopAnimConnections = {}
    
    if enabled then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end
        
        local playConn = animator.AnimationPlayed:Connect(function(track)
            task.defer(function()
                track:Stop(0)
            end)
        end)
        
        table.insert(stopAnimConnections, playConn)
        
        WindUI:Notify({
            Title = "No Animation",
            Content = "Semua animasi game dimatikan",
            Duration = 4,
            Icon = "pause-circle"
        })
    else
        for _, conn in ipairs(stopAnimConnections) do
            conn:Disconnect()
        end
        stopAnimConnections = {}
        
        WindUI:Notify({
            Title = "Animation Back",
            Content = "Animasi game kembali normal",
            Duration = 4,
            Icon = "play-circle"
        })
    end
end

Tab7:Toggle({
    Title = "No Animation",
    Description = "Matikan semua animasi game untuk FPS lebih tinggi",
    Default = false,
    Callback = function(value)
        setGameAnimationsEnabled(value)
    end
})

if Config.DisableAnimations then
    setGameAnimationsEnabled(true)
end

local FPSBooster = {}
FPSBooster.Enabled = false

local originalStates = {
    reflectance = {},
    transparency = {},
    lighting = {},
    effects = {},
    waterProperties = {}
}

local newObjectConnection = nil

local function optimizeObject(obj)
    if not FPSBooster.Enabled then return end
    
    pcall(function()
        if obj:IsA("BasePart") then
            if not originalStates.reflectance[obj] then
                originalStates.reflectance[obj] = obj.Reflectance
            end
            obj.Reflectance = 0
            obj.CastShadow = false
        end
        
        if obj:IsA("Decal") or obj:IsA("Texture") then
            if not originalStates.transparency[obj] then
                originalStates.transparency[obj] = obj.Transparency
            end
            obj.Transparency = 1
        end
        
        if obj:IsA("SurfaceAppearance") then
            obj:Destroy()
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
        
        if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end)
end

local function restoreObject(obj)
    pcall(function()
        if obj:IsA("BasePart") and originalStates.reflectance[obj] then
            obj.Reflectance = originalStates.reflectance[obj]
            obj.CastShadow = true
        end
        
        if (obj:IsA("Decal") or obj:IsA("Texture")) and originalStates.transparency[obj] then
            obj.Transparency = originalStates.transparency[obj]
        end
        
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = true
        end
    end)
end

function FPSBooster.Enable()
    if FPSBooster.Enabled then return end
    
    FPSBooster.Enabled = true
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        optimizeObject(obj)
    end
    
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        pcall(function()
            originalStates.waterProperties = {
                WaterReflectance = Terrain.WaterReflectance,
                WaterWaveSize = Terrain.WaterWaveSize,
                WaterWaveSpeed = Terrain.WaterWaveSpeed
            }
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
        end)
    end
    
    originalStates.lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart
    }
    
    Lighting.GlobalShadows = false
    Lighting.FogStart = 0
    Lighting.FogEnd = 1000000
    
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            originalStates.effects[effect] = effect.Enabled
            effect.Enabled = false
        end
    end
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    newObjectConnection = workspace.DescendantAdded:Connect(function(obj)
        if FPSBooster.Enabled then
            task.wait(0.1)
            optimizeObject(obj)
        end
    end)
    
    WindUI:Notify({
        Title = "FPS Booster",
        Content = "Aktif - Shadows, reflections, particles, fog & effects dimatikan",
        Duration = 4,
        Icon = "zap"
    })
end

function FPSBooster.Disable()
    if not FPSBooster.Enabled then return end
    
    FPSBooster.Enabled = false
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        restoreObject(obj)
    end
    
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain and originalStates.waterProperties then
        pcall(function()
            Terrain.WaterReflectance = originalStates.waterProperties.WaterReflectance
            Terrain.WaterWaveSize = originalStates.waterProperties.WaterWaveSize
            Terrain.WaterWaveSpeed = originalStates.waterProperties.WaterWaveSpeed
        end)
    end
    
    if originalStates.lighting.GlobalShadows ~= nil then
        Lighting.GlobalShadows = originalStates.lighting.GlobalShadows
        Lighting.FogEnd = originalStates.lighting.FogEnd
        Lighting.FogStart = originalStates.lighting.FogStart
    end
    
    for effect, state in pairs(originalStates.effects) do
        if effect and effect.Parent then
            effect.Enabled = state
        end
    end
    
    settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
    
    if newObjectConnection then
        newObjectConnection:Disconnect()
        newObjectConnection = nil
    end
    
    originalStates = {
        reflectance = {},
        transparency = {},
        lighting = {},
        effects = {},
        waterProperties = {}
    }
    
    WindUI:Notify({
        Title = "FPS Booster",
        Content = "Dimatikan - Grafik kembali normal",
        Duration = 4,
        Icon = "refresh-cw"
    })
end

Tab7:Toggle({
    Title = "FPS Booster",
    Description = "Boost FPS: hilangkan shadows, reflections, particles, fog, water waves & post effects",
    Default = false,
    Callback = function(value)
        if value then
            FPSBooster.Enable()
        else
            FPSBooster.Disable()
        end
    end
})

if Config.FPSBoosterEnabled then
    FPSBooster.Enable()
end

Tab7:Divider()

Tab7:Section({
    Title = "Realtime Stats Panel",
    Icon = "activity"
})

local function CreateStreePanel()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    local player = Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "StreeMiniPanel"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = CoreGui

    -- Frame utama (ukuran responsif)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 245, 0, 92)
    main.Position = UDim2.new(0.5, -122.5, 1, -130)
    main.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
    main.BackgroundTransparency = 0.25
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(140, 0, 255)
    stroke.Thickness = 2

    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
    header.BackgroundTransparency = 0.85
    header.BorderSizePixel = 0

    local logo = Instance.new("ImageLabel", header)
    logo.Image = "rbxassetid://78088064846187"
    logo.Size = UDim2.new(0, 20, 0, 20)
    logo.Position = UDim2.new(0, 8, 0.5, -10)
    logo.BackgroundTransparency = 1
    logo.ImageColor3 = Color3.fromRGB(140, 0, 255)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 34, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "REALTIME STATS"
    title.TextColor3 = Color3.fromRGB(140, 0, 255)

    -- Stats Container
    local statsFrame = Instance.new("Frame", main)
    statsFrame.Position = UDim2.new(0, 8, 0, 32)
    statsFrame.Size = UDim2.new(1, -16, 1, -38)
    statsFrame.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", statsFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8)

    local function makeStat()
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 52, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(30, 0, 60)
        box.BackgroundTransparency = 0.15
        box.BorderSizePixel = 0
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

        local stroke = Instance.new("UIStroke", box)
        stroke.Color = Color3.fromRGB(140, 0, 255)
        stroke.Thickness = 1.5

        local label = Instance.new("TextLabel", box)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11.5
        label.TextWrapped = true
        label.TextColor3 = Color3.fromRGB(220, 200, 255)

        box.Parent = statsFrame
        return label
    end

    local pingLabel  = makeStat()
    local fpsLabel   = makeStat()
    local notifLabel = makeStat()
    local timeLabel  = makeStat()

    -- Draggable
    local dragging = false
    local dragStart, startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- FPS Counter
    local frames = 0
    local fps = 0
    local last = tick()

    RunService.RenderStepped:Connect(function()
        frames += 1
        if tick() - last >= 1 then
            fps = frames
            frames = 0
            last = tick()
        end
    end)

    local function getPing()
        local net = Stats:FindFirstChild("Network")
        if net and net:FindFirstChild("ServerStatsItem") then
            local item = net.ServerStatsItem:FindFirstChild("Data Ping")
            if item then return math.floor(item:GetValue()) end
        end
        return 0
    end

    local function getTotalNotifications()
        local success, count = pcall(function()
            local textNotifications = playerGui:FindFirstChild("Text Notifications")
            if textNotifications then
                local frame = textNotifications:FindFirstChild("Frame")
                if frame then
                    local notifCount = 0
                    for _, child in ipairs(frame:GetChildren()) do
                        if child.Name == "Tile" then notifCount += 1 end
                    end
                    return notifCount
                end
            end
            return 0
        end)
        return success and count or 0
    end

    local sessionStartTime = tick()

    local function formatTime(seconds)
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        if hours > 0 then
            return string.format("%02d:%02d:%02d", hours, mins, secs)
        else
            return string.format("%02d:%02d", mins, secs)
        end
    end

    local function color(label, v, y, r)
        if v >= r then
            label.TextColor3 = Color3.fromRGB(255, 80, 80)
        elseif v >= y then
            label.TextColor3 = Color3.fromRGB(255, 220, 0)
        else
            label.TextColor3 = Color3.fromRGB(0, 255, 120)
        end
    end

    -- Update Loop
    task.spawn(function()
        while gui.Parent do
            local ping = getPing()
            local notifCount = getTotalNotifications()
            local elapsed = tick() - sessionStartTime
            local timerText = formatTime(elapsed)

            pingLabel.Text  = "PING\n" .. ping .. "ms"
            fpsLabel.Text   = "FPS\n" .. fps
            notifLabel.Text = "NOTIF\n" .. notifCount
            timeLabel.Text  = "TIME\n" .. timerText

            color(pingLabel, ping, 120, 200)
            color(fpsLabel, fps, 40, 90)
            color(notifLabel, notifCount, 8, 20)

            task.wait(1)
        end
    end)

    return gui
end

local StreePanel = CreateStreePanel()

Tab7:Toggle({
    Title = "Realtime Panel",
    Description = "Panel mini draggable: Ping, FPS, Notif & Session Timer",
    Default = false,
    Callback = function(value)
        StreePanel.Enabled = value
        if value then
            WindUI:Notify({
                Title = "Realtime Panel",
                Content = "Panel aktif - drag header untuk pindah posisi",
                Duration = 4,
                Icon = "activity"
            })
        else
            WindUI:Notify({
                Title = "Realtime Panel",
                Content = "Panel dimatikan",
                Duration = 3,
                Icon = "x-circle"
            })
        end
    end
})

Tab7:Divider()