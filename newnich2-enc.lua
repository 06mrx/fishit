--DETAILED DOCS https://github.com/AsuraXowner/Sentinel-Open-Source/blob/main/SentinelKeySystem/README.md
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "new1"
Junkie.identifier = "1024966"
Junkie.provider = "new1"

local SentinelUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/GamerFoxy0/Keysystem/refs/heads/main/Loader/Keysystem.lua"))()
local AuthorizeToken = crypt.hash(tick()..tostring(math.random()), "sha256")-- This generates a unique key to prevent key bypassing. Do not modify.

-- Configuration
SentinelUI.Keys.MainTitle    = "Junkie"-- The title
SentinelUI.Keys.MainDesc     = "Please enter your key to continue"-- The subtitle
SentinelUI.Keys.Directory    = "KeyData" -- file name where the key saves (Change this)
SentinelUI.Keys.Assets.Logo  = {ID='rbxassetid://86119635566201', Size=UDim2.new(0, 95, 0, 95)}-- Your logo Image ID and Image Size
--SentinelUI.Keys.DiscordLink    = "discord server link here" -- discord server link only works if premium is true

local function OnKeyVerified()
    return
end

SentinelUI.Initialize({
    KeyLink = Junkie.get_key_link(),
    Token = AuthorizeToken,
    MainLoader = OnKeyVerified,
    Keyless = true, --keyless mode
    --Premium true, --remvoes get key button and puts discord link
    Function = function(userInput)
        getgenv().SCRIPT_KEY = userInput
        local result = Junkie.check_key(userInput)
        print(result)
        if result and (result.valid or result.message == "KEY_VALID" or result.message == "KEYLESS") then
            SentinelUI.Authorize(AuthorizeToken)
        else
            SentinelUI.Fail()
        end
    end
})

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
    print("no key")
end

-- This file was protected using Luraph Obfuscator v14.7 [https://lura.ph/]

loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/9dae9adfea8f3660c4278eb29df19933890bfd8abde23ada2f172911a31a0485/download"))()