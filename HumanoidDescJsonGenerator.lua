local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Remote Event (Pastikan namanya sama di Server)
local avatarEvent = nil

local ADMINS = {
	["inidiayangkumaoo"] = true, -- ID Admin 1
	["666ChickiWings"] = true, -- ID Admin 2
}

if not ADMINS[player.Name] then
	return
end

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JsonGeneratorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 480) -- Ukuran lebih tinggi
mainFrame.Position = UDim2.new(0.5, 30, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "NICH JSON GENERATOR"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 8)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Parent = mainFrame
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)

-- UI LIST LAYOUT (Agar rapi)
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(0.9, 0, 0.85, 0)
container.Position = UDim2.new(0.05, 0, 0.1, 0)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 2
container.Parent = mainFrame

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- 1. INPUT USER ID
local idInput = Instance.new("TextBox")
idInput.Size = UDim2.new(1, 0, 0, 35)
idInput.PlaceholderText = "Masukkan UserID Player..."
idInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
idInput.TextColor3 = Color3.new(1, 1, 1)
idInput.Font = Enum.Font.Gotham
idInput.Parent = container
Instance.new("UICorner", idInput)

-- 2. BUTTON: GENERATE FROM ID
local genBtn = Instance.new("TextButton")
genBtn.Size = UDim2.new(1, 0, 0, 35)
genBtn.Text = "GENERATE FROM ID"
genBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 127)
genBtn.Font = Enum.Font.GothamBold
genBtn.Parent = container
Instance.new("UICorner", genBtn)

-- 3. BUTTON: GRAB MY CURRENT AVATAR (NEW!)
local grabBtn = Instance.new("TextButton")
grabBtn.Size = UDim2.new(1, 0, 0, 35)
grabBtn.Text = "GRAB MY CURRENT CLOTHES"
grabBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
grabBtn.Font = Enum.Font.GothamBold
grabBtn.Parent = container
Instance.new("UICorner", grabBtn)

-- 4. TEXT AREA OUTPUT
local outputArea = Instance.new("TextBox")
outputArea.Size = UDim2.new(1, 0, 0, 120)
outputArea.MultiLine = true
outputArea.TextEditable = true
outputArea.PlaceholderText = "JSON Output akan muncul di sini..."
outputArea.Text = ""
outputArea.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
outputArea.TextColor3 = Color3.fromRGB(0, 255, 0)
outputArea.Font = Enum.Font.Code
outputArea.TextSize = 10
outputArea.Parent = container
Instance.new("UICorner", outputArea)

-- 5. INPUT NAMA OUTFIT (FOR SAVING)
local nameInput = Instance.new("TextBox")
nameInput.Size = UDim2.new(1, 0, 0, 35)
nameInput.PlaceholderText = "Nama Outfit (untuk Save)..."
nameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
nameInput.TextColor3 = Color3.new(1, 1, 1)
nameInput.Parent = container
Instance.new("UICorner", nameInput)

-- 6. BUTTON: SAVE TO CLOUD
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 35)
saveBtn.Text = "SAVE TO STATIC DATA"
saveBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Parent = container
Instance.new("UICorner", saveBtn)

-- ============================================
-- LOGIC CORE
-- ============================================

local function getJsonFromDescription(desc)
	local data = {}
	local props = {
		"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor",
		"Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", "RightArm", 
		"LeftLeg", "RightLeg", "HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
		"FrontAccessory", "BackAccessory", "WaistAccessory"
	}

	for _, prop in pairs(props) do
		local val = desc[prop]
		if typeof(val) == "Color3" then
			data[prop] = {math.floor(val.r*255), math.floor(val.g*255), math.floor(val.b*255)}
		elseif val ~= 0 and val ~= "" and val ~= "0" then
			data[prop] = val
		end
	end
	return HttpService:JSONEncode(data)
end

-- Generate dari ID
genBtn.MouseButton1Click:Connect(function()
	local userId = tonumber(idInput.Text)
	if not userId then return end

	local success, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
	if success then
		outputArea.Text = getJsonFromDescription(desc)
	end
end)

-- Grab Current Avatar (Fungsi yang kamu minta)
grabBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if char then
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			local success, desc = pcall(function() return hum:GetAppliedDescription() end)
			if success then
				outputArea.Text = getJsonFromDescription(desc)
				grabBtn.Text = "GRABBED!"
				task.wait(1)
				grabBtn.Text = "GRAB MY CURRENT CLOTHES"
			end
		end
	end
end)

-- Save to Cloud
saveBtn.MouseButton1Click:Connect(function()
	local json = outputArea.Text
	local oName = nameInput.Text
	if json ~= "" and oName ~= "" then
		avatarEvent:FireServer(json, true, "SaveStatic", oName)
		saveBtn.Text = "SAVED TO CLOUD!"
		task.wait(2)
		saveBtn.Text = "SAVE TO STATIC DATA"
	end
end)

-- Minimize
local min = false
minBtn.MouseButton1Click:Connect(function()
	min = not min
	mainFrame:TweenSize(min and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 480), "Out", "Quad", 0.3, true)
	container.Visible = not min
end)
