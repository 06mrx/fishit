-- Purple UI Library for Roblox (Compact Mobile-First + Scrollable Dropdown)
-- Updated: dropdown uses ScrollingFrame internally for long lists

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local transparency = 0.3
-- Tema warna ungu
local Theme = {
    Background = Color3.fromRGB(20, 15, 30),
    Sidebar = Color3.fromRGB(30, 20, 45),
    Primary = Color3.fromRGB(130, 80, 200),
    Secondary = Color3.fromRGB(100, 60, 170),
    Accent = Color3.fromRGB(160, 100, 230),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    Border = Color3.fromRGB(80, 60, 120),
    Input = Color3.fromRGB(40, 30, 60),
    Success = Color3.fromRGB(100, 200, 130),
    Warning = Color3.fromRGB(230, 180, 80)
}

-- Helper functions
local function Tween(obj, props, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function MakeRound(frame, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
    return corner
end

local function AddStroke(frame, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    return stroke
end

-- Safe image setting
local function SetImageSafe(imageLabel, imageId)
    local success, errorMessage = pcall(function()
        imageLabel.Image = imageId
    end)
    if not success then
        warn("Failed to set image: " .. tostring(errorMessage) .. " | Image ID: " .. tostring(imageId))
        imageLabel.Image = ""
        return false
    end
    return true
end

-- Modal konfirmasi
local function ShowConfirmationModal(screenGui, message, onConfirm)
    local Modal = Instance.new("Frame")
    Modal.BackgroundTransparency = 0.7
    Modal.BackgroundColor3 = Color3.new(0, 0, 0)
    Modal.Size = UDim2.new(1, 0, 1, 0)
    Modal.ZIndex = 1000
    Modal.Parent = screenGui

    local ModalBox = Instance.new("Frame")
    ModalBox.Size = UDim2.new(0, 280, 0, 100)
    ModalBox.Position = UDim2.new(0.5, -140, 0.5, -50)
    ModalBox.BackgroundColor3 = Theme.Input
    ModalBox.BorderSizePixel = 0
    ModalBox.ZIndex = 1001
    ModalBox.Parent = Modal
    MakeRound(ModalBox, 10)
    AddStroke(ModalBox, Theme.Border, 1)

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 0, 30)
    MessageLabel.Position = UDim2.new(0, 10, 0, 12)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Theme.Text
    MessageLabel.TextSize = 14
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextWrapped = true
    MessageLabel.ZIndex = 1002
    MessageLabel.Parent = ModalBox

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0, 80, 0, 30)
    YesBtn.Position = UDim2.new(0.5, -90, 1, -38)
    YesBtn.Text = "Yes"
    YesBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
    YesBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.ZIndex = 1002
    YesBtn.Parent = ModalBox
    MakeRound(YesBtn, 5)

    local NoBtn = Instance.new("TextButton")
    NoBtn.Size = UDim2.new(0, 80, 0, 30)
    NoBtn.Position = UDim2.new(0.5, 10, 1, -38)
    NoBtn.Text = "No"
    NoBtn.TextColor3 = Theme.Text
    NoBtn.BackgroundColor3 = Theme.Primary
    NoBtn.Font = Enum.Font.GothamBold
    NoBtn.ZIndex = 1002
    NoBtn.Parent = ModalBox
    MakeRound(NoBtn, 5)

    YesBtn.MouseButton1Click:Connect(function()
        onConfirm(true)
        Modal:Destroy()
    end)
    NoBtn.MouseButton1Click:Connect(function()
        onConfirm(false)
        Modal:Destroy()
    end)
end

local function ShowAlertModal(screenGui, message)
    local Modal = Instance.new("Frame")
    Modal.BackgroundTransparency = 0.7
    Modal.BackgroundColor3 = Color3.new(0, 0, 0)
    Modal.Size = UDim2.new(1, 0, 1, 0)
    Modal.ZIndex = 1000
    Modal.Parent = screenGui

    local ModalBox = Instance.new("Frame")
    ModalBox.Size = UDim2.new(0, 280, 0, 100)
    ModalBox.Position = UDim2.new(0.5, -140, 0.5, -50)
    ModalBox.BackgroundColor3 = Theme.Input
    ModalBox.BorderSizePixel = 0
    ModalBox.ZIndex = 1001
    ModalBox.Parent = Modal
    MakeRound(ModalBox, 10)
    AddStroke(ModalBox, Theme.Border, 1)

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 0, 30)
    MessageLabel.Position = UDim2.new(0, 10, 0, 12)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Theme.Text
    MessageLabel.TextSize = 14
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextWrapped = true
    MessageLabel.ZIndex = 1002
    MessageLabel.Parent = ModalBox

    local YesBtn = Instance.new("TextButton")
    YesBtn.Size = UDim2.new(0, 80, 0, 30)
    YesBtn.Position = UDim2.new(0.5, -40, 1, -38)
    YesBtn.Text = "Ok"
    YesBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
    YesBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
    YesBtn.Font = Enum.Font.GothamBold
    YesBtn.ZIndex = 1002
    YesBtn.Parent = ModalBox
    MakeRound(YesBtn, 5)

    -- local NoBtn = Instance.new("TextButton")
    -- NoBtn.Size = UDim2.new(0, 80, 0, 30)
    -- NoBtn.Position = UDim2.new(0.5, 10, 1, -38)
    -- NoBtn.Text = "No"
    -- NoBtn.TextColor3 = Theme.Text
    -- NoBtn.BackgroundColor3 = Theme.Primary
    -- NoBtn.Font = Enum.Font.GothamBold
    -- NoBtn.ZIndex = 1002
    -- NoBtn.Parent = ModalBox
    -- MakeRound(NoBtn, 5)

    YesBtn.MouseButton1Click:Connect(function()
        -- onConfirm(true)
        Modal:Destroy()
    end)
    -- NoBtn.MouseButton1Click:Connect(function()
    --     onConfirm(false)
    --     Modal:Destroy()
    -- end)
end

-- Icons
local Icons = {
    Home = "rbxassetid://134112637052391",
    Settings = "rbxassetid://121005722030214",
    User = "rbxasset://textures/ui/GuiImage/Avatar.png",
    Shield = "rbxasset://textures/ui/GuiImage/Lock.png",
    Search = "rbxasset://textures/ui/GuiImage/Search.png",
    Close = "rbxassetid://94295066371757",
    Minimize = "rbxassetid://79396743523839",
    Maximize = "rbxassetid://103730626135376",
    ChevronDown = "rbxassetid://73584794924965",
    Check = "rbxasset://textures/ui/GuiImage/Checkmark.png"
}

function Library:CreateWindow(config, isFishing)
    if isFishing == nil then
        isFishing = true
    end


    config = config or {}
    local WindowTitle = config.Title or "Purple UI"
    local WindowIcon = config.Icon or Icons.Settings

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PurpleUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui

    if isFishing then ShowAlertModal(ScreenGui, "Notif Hanya Pemanis, Secret Number 1!") end

    -- Batasi tinggi di mobile
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local viewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
    local maxWidth = 600
    local maxHeight = isMobile and math.min(400, viewportSize.Y * 0.88) or 400

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, maxWidth, 0, maxHeight)
    MainFrame.Position = UDim2.new(0.5, -maxWidth/2, 0.5, -maxHeight/2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BackgroundTransparency = transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MakeRound(MainFrame, 12)
    AddStroke(MainFrame, Theme.Border, 2)

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    Shadow.ZIndex = 0

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundColor3 = Theme.Sidebar
    -- Topbar.BackgroundTransparency = transparency
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    MakeRound(Topbar, 12)

    local TopbarFix = Instance.new("Frame")
    TopbarFix.Size = UDim2.new(1, 0, 0, 10)
    TopbarFix.Position = UDim2.new(0, 0, 1, -10)
    TopbarFix.BackgroundColor3 = Theme.Sidebar
    -- TopbarFix.BackgroundTransparency = transparency
    TopbarFix.BorderSizePixel = 0
    TopbarFix.Parent = Topbar

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Size = UDim2.new(0, 22, 0, 22)
    LogoIcon.Position = UDim2.new(0, 12, 0.5, -11)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.ImageColor3 = Theme.Accent
    LogoIcon.Parent = Topbar
    SetImageSafe(LogoIcon, WindowIcon)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 40, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowTitle
    Title.TextColor3 = Theme.Text
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Topbar

    -- Minimize Button
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.Position = UDim2.new(1, -72, 0.5, -16)
    MinimizeBtn.BackgroundColor3 = Theme.Secondary
    MinimizeBtn.Text = ""
    MinimizeBtn.Parent = Topbar
    MakeRound(MinimizeBtn, 7)

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Size = UDim2.new(0, 16, 0, 16)
    MinimizeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.ImageColor3 = Theme.Text
    MinimizeIcon.Parent = MinimizeBtn
    SetImageSafe(MinimizeIcon, Icons.Minimize)

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -16)
    CloseBtn.BackgroundColor3 = Theme.Primary
    CloseBtn.Text = ""
    CloseBtn.Parent = Topbar
    MakeRound(CloseBtn, 7)

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 16, 0, 16)
    CloseIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.Parent = CloseBtn
    SetImageSafe(CloseIcon, Icons.Close)

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame")  -- ← Diubah dari Frame ke ScrollingFrame
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BackgroundTransparency = transparency
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 4  -- ← Tambahkan ini
    Sidebar.ScrollBarImageColor3 = Theme.Primary  -- ← Tambahkan ini
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)  -- ← Tambahkan ini
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 4)
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 8)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.PaddingBottom = UDim.new(0, 8)  -- ← Tambahkan padding bawah
    SidebarPadding.Parent = Sidebar

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 16)  -- +16 untuk padding atas dan bawah
    end)

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -45)
    ContentArea.Position = UDim2.new(0, 145, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        Tween(MainFrame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
    end
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Floating button
    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Size = UDim2.new(0, 50, 0, 50)
    FloatingButton.Position = UDim2.new(1, -70, 0, 15)
    FloatingButton.BackgroundColor3 = Theme.Primary
    FloatingButton.BorderSizePixel = 0
    FloatingButton.Visible = false
    FloatingButton.ImageColor3 = Theme.Text
    FloatingButton.ScaleType = Enum.ScaleType.Fit
    FloatingButton.Parent = ScreenGui
    MakeRound(FloatingButton, 25)
    AddStroke(FloatingButton, Theme.Border, 2)
    SetImageSafe(FloatingButton, WindowIcon)

    local FloatingShadow = Instance.new("ImageLabel")
    FloatingShadow.Size = UDim2.new(1, 25, 1, 25)
    FloatingShadow.Position = UDim2.new(0, -12, 0, -12)
    FloatingShadow.BackgroundTransparency = 1
    FloatingShadow.Image = "rbxassetid://5554236805"
    FloatingShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    FloatingShadow.ImageTransparency = 0.6
    FloatingShadow.ScaleType = Enum.ScaleType.Slice
    FloatingShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    FloatingShadow.Parent = FloatingButton
    FloatingShadow.ZIndex = 0

    local draggingFloat, dragInputFloat, dragStartFloat, startPosFloat
    local function updateFloat(input)
        local delta = input.Position - dragStartFloat
        Tween(FloatingButton, {Position = UDim2.new(startPosFloat.X.Scale, startPosFloat.X.Offset + delta.X, startPosFloat.Y.Scale, startPosFloat.Y.Offset + delta.Y)}, 0.1)
    end
    FloatingButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFloat = true
            dragStartFloat = input.Position
            startPosFloat = FloatingButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingFloat = false
                end
            end)
        end
    end)
    FloatingButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInputFloat = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInputFloat and draggingFloat then
            updateFloat(input)
        end
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        FloatingButton.Visible = true
    end)
    FloatingButton.MouseButton1Click:Connect(function()
        if not draggingFloat then
            FloatingButton.Visible = false
            MainFrame.Visible = true
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ShowConfirmationModal(ScreenGui, "Close this window?", function(confirmed)
            if confirmed then
                ScreenGui:Destroy()
            end
        end)
    end)

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = ScreenGui
    }

    function Window:CreateTab(config)
        config = config or {}
        local TabName = config.Name or "Tab"
        local TabIcon = config.Icon or Icons.Home

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Theme.Input
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.Parent = Sidebar
        MakeRound(TabBtn, 7)

        local TabIcon_img = Instance.new("ImageLabel")
        TabIcon_img.Size = UDim2.new(0, 18, 0, 18)
        TabIcon_img.Position = UDim2.new(0, 8, 0.5, -9)
        TabIcon_img.BackgroundTransparency = 1
        TabIcon_img.ImageColor3 = Theme.TextDim
        TabIcon_img.Parent = TabBtn
        SetImageSafe(TabIcon_img, TabIcon)

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -45, 1, 0)
        TabLabel.Position = UDim2.new(0, 40, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabName
        TabLabel.TextColor3 = Theme.TextDim
        TabLabel.TextSize = 13
        TabLabel.Font = Enum.Font.Gotham
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.Primary
        TabContent.Visible = false
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Parent = ContentArea

        local ContentList = Instance.new("UIListLayout")
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 6)
        ContentList.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 4)
        ContentPadding.PaddingLeft = UDim.new(0, 5)
        ContentPadding.PaddingRight = UDim.new(0, 5)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = TabContent

        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Icon.ImageColor3 = Theme.TextDim
                tab.Label.TextColor3 = Theme.TextDim
                tab.Content.Visible = false
            end
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Theme.Primary
            TabIcon_img.ImageColor3 = Theme.Text
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)

        local Tab = {
            Button = TabBtn,
            Icon = TabIcon_img,
            Label = TabLabel,
            Content = TabContent,
            ScreenGui = ScreenGui
        }

        -- === COMPACT FORM ELEMENTS ===
        -- Jarak deskripsi: Y = 24 (lebih lega dari 20)

        function Tab:AddButton(config)
            config = config or {}
            local ButtonText = config.Text or "Button"
            local Description = config.Description
            local Callback = config.Callback or function() end

            local height = Description and 45 or 35

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, height)
            Frame.BackgroundColor3 = Theme.Input
            Frame.BackgroundTransparency = transparency
            Frame.BorderSizePixel = 0
            Frame.Parent = TabContent
            MakeRound(Frame, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = ButtonText
            Label.TextColor3 = Theme.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Description then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -90, 0, 12)
                Desc.Position = UDim2.new(0, 10, 0, 28)  -- ⬅️ 24px = lebih lega
                Desc.BackgroundTransparency = 1
                Desc.Text = Description
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true
                Desc.Parent = Frame
            end

            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(0, 80, 1, 0)
            Button.Position = UDim2.new(1, -90, 0, 0)
            Button.BackgroundTransparency = 1
            Button.Text = "Execute"
            Button.TextColor3 = Theme.Text
            Button.TextSize = 13
            Button.Font = Enum.Font.GothamBold
            Button.Parent = Frame

            Button.MouseButton1Click:Connect(function()
                Tween(Frame, {BackgroundColor3 = Theme.Primary}, 0.1)
                task.wait(0.1)
                Tween(Frame, {BackgroundColor3 = Theme.Input}, 0.1)
                Callback()
            end)

            return Button
        end

        function Tab:AddToggle(config)
            config = config or {}
            local ToggleText = config.Text or "Toggle"
            local Description = config.Description
            local Default = config.Default or false
            local Callback = config.Callback or function() end

            local height = Description and 45 or 35

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, height)
            Frame.BackgroundColor3 = Theme.Input
            Frame.BackgroundTransparency = transparency
            Frame.BorderSizePixel = 0
            Frame.Parent = TabContent
            MakeRound(Frame, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = ToggleText
            Label.TextColor3 = Theme.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Description then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -90, 0, 12)
                Desc.Position = UDim2.new(0, 10, 0, 28)  -- ⬅️
                Desc.BackgroundTransparency = 1
                Desc.Text = Description
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true
                Desc.Parent = Frame
            end

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 36, 0, 18)
            ToggleBtn.Position = UDim2.new(1, -42, 0.5, -9)
            ToggleBtn.BackgroundColor3 = Default and Theme.Primary or Theme.Border
            ToggleBtn.Text = ""
            ToggleBtn.Parent = Frame
            MakeRound(ToggleBtn, 9)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = Default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Theme.Text
            Circle.BorderSizePixel = 0
            Circle.Parent = ToggleBtn
            MakeRound(Circle, 7)

            local toggled = Default
            ToggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(ToggleBtn, {BackgroundColor3 = toggled and Theme.Primary or Theme.Border}, 0.2)
                Tween(Circle, {Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                Callback(toggled)
            end)

            return {
                Set = function(val)
                    toggled = val
                    Tween(ToggleBtn, {BackgroundColor3 = toggled and Theme.Primary or Theme.Border}, 0.2)
                    Tween(Circle, {Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
                end
            }
        end

        function Tab:AddTextbox(config)
            config = config or {}
            local TextboxText = config.Text or "Input"
            local Description = config.Description
            local Placeholder = config.Placeholder or "..."
            local Callback = config.Callback or function() end

            -- 🔥 FLAG BARU
            local Live = config.Live or false  -- default: false (nunggu enter)

            local height = Description and 45 or 35

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, height)
            Frame.BackgroundColor3 = Theme.Input
            Frame.BackgroundTransparency = transparency
            Frame.BorderSizePixel = 0
            Frame.Parent = TabContent
            MakeRound(Frame, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = TextboxText
            Label.TextColor3 = Theme.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Description then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -90, 0, 12)
                Desc.Position = UDim2.new(0, 10, 0, 28)  -- ⬅️
                Desc.BackgroundTransparency = 1
                Desc.Text = Description
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true
                Desc.Parent = Frame
            end

            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(0, 75, 0, 24)
            Input.Position = UDim2.new(1, -80, 0.5, -12)
            Input.BackgroundColor3 = Theme.Background
            Input.Text = ""
            Input.PlaceholderText = Placeholder
            Input.PlaceholderColor3 = Theme.TextDim
            Input.TextColor3 = Theme.Text
            Input.TextSize = 13
            Input.Font = Enum.Font.Gotham
            Input.ClearTextOnFocus = false
            Input.Parent = Frame
            MakeRound(Input, 5)
            AddStroke(Input, Theme.Border, 1)

              -- 🟢 MODE LIVE (ketik / paste langsung trigger)
            if Live then
                Input:GetPropertyChangedSignal("Text"):Connect(function()
                    Callback(Input.Text)
                end)
            else
                -- 🔵 MODE DEFAULT (Enter doang)
                Input.FocusLost:Connect(function(enter)
                    if enter then
                        Callback(Input.Text)
                    end
                end)
            end

            return Input
        end

        function Tab:AddSlider(config)
            config = config or {}
            local SliderText = config.Text or "Slider"
            local Description = config.Description
            local Min = config.Min or 0
            local Max = config.Max or 100
            local Default = config.Default or 50
            local Callback = config.Callback or function() end

            local height = Description and 45 or 35

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, height)
            Frame.BackgroundColor3 = Theme.Input
            Frame.BackgroundTransparency = transparency
            Frame.BorderSizePixel = 0
            Frame.Parent = TabContent
            MakeRound(Frame, 6)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -90, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = SliderText
            Label.TextColor3 = Theme.Text
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            if Description then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(1, -90, 0, 12)
                Desc.Position = UDim2.new(0, 10, 0, 28)  -- ⬅️
                Desc.BackgroundTransparency = 1
                Desc.Text = Description
                Desc.TextColor3 = Theme.TextDim
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextWrapped = true
                Desc.Parent = Frame
            end

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 40, 1, 0)
            ValueLabel.Position = UDim2.new(1, -45, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Default)
            ValueLabel.TextColor3 = Theme.Accent
            ValueLabel.TextSize = 13
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = Frame

            local dragging = false
            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local pos = math.clamp((input.Position.X - Frame.AbsolutePosition.X - 10) / (Frame.AbsoluteSize.X - 100), 0, 1)
                    local value = math.floor(Min + (Max - Min) * pos)
                    ValueLabel.Text = tostring(value)
                    Callback(value)
                end
            end)
            Frame.InputEnded:Connect(function()
                dragging = false
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - Frame.AbsolutePosition.X - 10) / (Frame.AbsoluteSize.X - 100), 0, 1)
                    local value = math.floor(Min + (Max - Min) * pos)
                    ValueLabel.Text = tostring(value)
                    Callback(value)
                end
            end)

            return {
                Set = function(val)
                    local pos = (val - Min) / (Max - Min)
                    ValueLabel.Text = tostring(val)
                end
            }
        end

                -- 🔥 DROPDOWN DENGAN KEMAMPUAN UPDATE
        function Tab:AddDropdown(config)
    config = config or {}
    local DropdownText = config.Text or "Option"
    local Description = config.Description
    local optionsTable = config.Options or {"A", "B", "C"}
    local Default = config.Default or optionsTable[1]
    local Callback = config.Callback or function() end

    local hasDesc = Description ~= nil
    local baseHeight = hasDesc and 50 or 35

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, baseHeight)
    Frame.BackgroundColor3 = Theme.Input
    Frame.BackgroundTransparency = transparency
    Frame.BorderSizePixel = 0
    Frame.Parent = TabContent
    MakeRound(Frame, 6)

    -- === PERUBAHAN 2: LABEL DI KIRI, ISI SISA RUANG ===
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0) -- Mengisi sisa ruang selain tombol
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = DropdownText
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    if hasDesc then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -90, 0, 12) -- Sesuaikan juga deskripsi
        Desc.Position = UDim2.new(0, 10, 0, 34)
        Desc.BackgroundTransparency = 1
        Desc.Text = Description
        Desc.TextColor3 = Theme.TextDim
        Desc.TextSize = 11
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextWrapped = true
        Desc.Parent = Frame
    end

    -- === PERUBAHAN 2: TOMBOL DI KANAN DENGAN LEBAR TETAP ===
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 90, 0, 24) -- Kembali ke lebar tetap
    Button.Position = UDim2.new(1, -95, 0.5, -12) -- Posisikan di kanan
    Button.BackgroundColor3 = Theme.Background
    Button.Text = ""
    Button.Parent = Frame
    MakeRound(Button, 5)
    AddStroke(Button, Theme.Border, 1)

    local Selected = Instance.new("TextLabel")
    Selected.Size = UDim2.new(1, -20, 1, 0)
    Selected.Position = UDim2.new(0, 10, 0, 0)
    Selected.BackgroundTransparency = 1
    Selected.Text = Default
    Selected.TextColor3 = Theme.Text
    Selected.TextSize = 13
    Selected.Font = Enum.Font.Gotham
    Selected.TextXAlignment = Enum.TextXAlignment.Left
    -- Tambahkan TextTruncate agar teks panjang tidak tumpang tindih dengan chevron
    Selected.TextTruncate = Enum.TextTruncate.AtEnd
    Selected.Parent = Button

    local Chevron = Instance.new("ImageLabel")
    Chevron.Size = UDim2.new(0, 12, 0, 12)
    Chevron.Position = UDim2.new(1, -18, 0.5, -6)
    Chevron.BackgroundTransparency = 1
    Chevron.ImageColor3 = Theme.TextDim
    Chevron.Parent = Button
    SetImageSafe(Chevron, Icons.ChevronDown)

    local Container = Instance.new("ScrollingFrame")
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.ScrollBarThickness = 3
    Container.ScrollBarImageColor3 = Theme.Primary
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.Parent = TabContent

    local expanded = false
    local current = Default

    -- Fungsi untuk menutup dropdown
    local function closeDropdown()
        if expanded then
            Container.Visible = false
            expanded = false
            print('menutup dropdown')
            Tween(Chevron, {Rotation = 0}, 0.15)
        end
    end

    -- Fungsi untuk membangun ulang daftar opsi
    local function rebuildOptions()
        for _, child in ipairs(Container:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local optionHeight = 28
        local spacing = 2
        local totalHeight = #optionsTable * (optionHeight + spacing) - spacing
        Container.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        local displayHeight = math.min(totalHeight, 180)
        -- Tween untuk tinggi saja, lebar sudah diatur di openDropdown
        Tween(Container, {Size = UDim2.new(Container.Size.X.Scale, Container.Size.X.Offset, 0, displayHeight)}, 0.15)

        for i, opt in ipairs(optionsTable) do
            local yPos = (i - 1) * (optionHeight + spacing)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, optionHeight)
            btn.Position = UDim2.new(0, 5, 0, yPos)
            btn.Text = opt
            btn.TextColor3 = Theme.Text
            btn.BackgroundColor3 = opt == current and Theme.Primary or Theme.Input
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = Container
            MakeRound(btn, 4)

            btn.MouseButton1Click:Connect(function()
                current = opt
                Selected.Text = opt
                closeDropdown()
                Callback(opt)
                -- === PERUBAHAN 1: PASTIKAN INI ADA UNTUK TUTUP OTOMATIS ===
                
            end)
        end
    end

    

    local closeConn
    local function setupOutsideClose()
        if closeConn then closeConn:Disconnect() end
        closeConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local pos = input.Position
                local frameAbs = Frame.AbsolutePosition
                local frameSize = Frame.AbsoluteSize
                local contAbs = Container.AbsolutePosition
                local contSize = Container.AbsoluteSize

                local inFrame = pos.X >= frameAbs.X and pos.X <= frameAbs.X + frameSize.X and
                                pos.Y >= frameAbs.Y and pos.Y <= frameAbs.Y + frameSize.Y

                local inContainer = Container.Visible and
                                pos.X >= contAbs.X and pos.X <= contAbs.X + contSize.X and
                                pos.Y >= contAbs.Y and pos.Y <= contAbs.Y + contSize.Y

                if not (inFrame or inContainer) then
                    closeDropdown()
                    if closeConn then closeConn:Disconnect() closeConn = nil end
                end
            end
        end)
    end

    -- === PERUBAHAN 3: CONTAINER MENJADI LEBAR PENUH ===
    local function openDropdown()
        closeDropdown()
        expanded = true

        -- Gunakan posisi dan ukuran dari Frame utama untuk menentukan posisi Container
        local frameAbs = Frame.AbsolutePosition
        local frameSize = Frame.AbsoluteSize
        local tabContentAbsWidth = TabContent.AbsoluteSize.X
        
        -- Posisikan Container tepat di bawah Frame utama
        Container.Position = UDim2.new(0, frameAbs.X, 0, frameAbs.Y + frameSize.Y)
        -- Set ukuran Container agar sama dengan lebar TabContent (lebar penuh)
        Container.Size = UDim2.new(0, tabContentAbsWidth, 0, 0)
        
        rebuildOptions()

        Container.Visible = true
        Tween(Chevron, {Rotation = 180}, 0.15)
        setupOutsideClose()
    end

    Button.MouseButton1Click:Connect(function()
        if expanded then
            closeDropdown()
            if closeConn then closeConn:Disconnect() closeConn = nil end
        else
            task.defer(function()
                if Frame.Parent then
                    openDropdown()
                end
            end)
        end
    end)

    -- Inisialisasi dropdown pertama kali
    rebuildOptions()

    return {
        Set = function(val)
            current = val
            Selected.Text = val
            rebuildOptions()
        end,
        AddOption = function(newOption)
            for _, opt in ipairs(optionsTable) do
                if opt == newOption then
                    return
                end
            end
            table.insert(optionsTable, newOption)
            rebuildOptions()
        end,
        ResetOptions = function(newOptions)
            optionsTable = newOptions or {}
            if #optionsTable > 0 then
                current = optionsTable[1]
                Selected.Text = current
            else
                current = ""
                Selected.Text = "No options"
            end
            rebuildOptions()
        end
    }
end

        function Tab:AddLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, -10, 0, 25)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Parent = TabContent

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.TextDim
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = LabelFrame

            return {
                Set = function(newText)
                    Label.Text = newText
                end
            }
        end

        function Tab:AddParagraph(title, content)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 60)
            Frame.BackgroundColor3 = Theme.Input
            Frame.BorderSizePixel = 0
            Frame.Parent = TabContent
            MakeRound(Frame, 6)

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 18)
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.BackgroundTransparency = 1
            Title.Text = title
            Title.TextColor3 = Theme.Text
            Title.TextSize = 14
            Title.Font = Enum.Font.GothamBold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local Content = Instance.new("TextLabel")
            Content.Size = UDim2.new(1, -20, 1, -30)
            Content.Position = UDim2.new(0, 10, 0, 28)
            Content.BackgroundTransparency = 1
            Content.Text = content
            Content.TextColor3 = Theme.TextDim
            Content.TextSize = 12
            Content.Font = Enum.Font.Gotham
            Content.TextXAlignment = Enum.TextXAlignment.Left
            Content.TextYAlignment = Enum.TextYAlignment.Top
            Content.TextWrapped = true
            Content.Parent = Frame

            return {
                Set = function(t, c)
                    Title.Text = t
                    Content.Text = c
                end
            }
        end

        function Tab:AddSection(title)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -10, 0, 22)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = TabContent

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -10, 1, 0)
            SectionLabel.Position = UDim2.new(0, 5, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = title
            SectionLabel.TextColor3 = Theme.Text
            SectionLabel.TextSize = 14
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionFrame

            return {
                Set = function(newTitle)
                    SectionLabel.Text = newTitle
                end
            }
        end

        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Theme.Primary
            TabIcon_img.ImageColor3 = Theme.Text
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end

        return Tab
    end

    return Window
end
return Library