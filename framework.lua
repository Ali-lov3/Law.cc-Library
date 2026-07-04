local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library
Library.Flags = {}
Library.Options = {}
Library.Windows = {}
Library.AnimationsEnabled = true
Library.BlurEnabled = false
Library.ToggleKeybind = Enum.KeyCode.RightControl
Library.ThemeRegistry = {}
Library.ActivePopup = nil
Library.ConfigFolder = "LawCC"
Library.ConfigSubFolder = "LawCC/Configs"

local IconFinder = nil

local function LoadIconFinder()
    if IconFinder ~= nil then
        return IconFinder
    end
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/IconFinder.lua"))()
    end)
    if success then
        IconFinder = result
    else
        IconFinder = false
    end
    return IconFinder
end

local function GetIcon(name)
    if not name then
        return nil
    end
    local finder = LoadIconFinder()
    if not finder then
        return nil
    end
    local ok, icon = pcall(function()
        if type(finder) == "function" then
            return finder(name)
        elseif finder.Find then
            return finder:Find(name)
        elseif finder.GetIcon then
            return finder:GetIcon(name)
        elseif finder.Icons and finder.Icons[name] then
            return finder.Icons[name]
        end
        return nil
    end)
    if ok then
        return icon
    end
    return nil
end

local function ApplyIcon(imageLabel, name)
    local icon = GetIcon(name)
    if not icon then
        imageLabel.Image = ""
        return
    end
    if type(icon) == "string" then
        imageLabel.Image = icon
    elseif type(icon) == "table" then
        imageLabel.Image = icon.Image or icon.Id or ""
        if icon.ImageRectOffset then
            imageLabel.ImageRectOffset = icon.ImageRectOffset
        end
        if icon.ImageRectSize then
            imageLabel.ImageRectSize = icon.ImageRectSize
        end
    end
end

local function Create(class, props)
    local inst = Instance.new(class)
    for key, value in pairs(props or {}) do
        if key ~= "Parent" and key ~= "Children" then
            inst[key] = value
        end
    end
    if props and props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(inst, props, duration, style, direction)
    local time = Library.AnimationsEnabled and (duration or 0.25) or 0
    local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

local function MakeDraggable(handle, target)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

Library.Themes = {
    Pink = {
        Accent = Color3.fromRGB(235, 85, 155),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
    Purple = {
        Accent = Color3.fromRGB(165, 100, 235),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
    Blue = {
        Accent = Color3.fromRGB(80, 155, 235),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
    Green = {
        Accent = Color3.fromRGB(90, 210, 140),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
    Red = {
        Accent = Color3.fromRGB(235, 90, 90),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
    Orange = {
        Accent = Color3.fromRGB(235, 150, 75),
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(22, 22, 26),
        Tertiary = Color3.fromRGB(32, 32, 38),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Border = Color3.fromRGB(42, 42, 48),
    },
}

Library.CustomThemes = {}
Library.CurrentThemeName = "Pink"
Library.Theme = {}
for key, value in pairs(Library.Themes.Pink) do
    Library.Theme[key] = value
end

function Library:Themeify(inst, prop, key)
    table.insert(self.ThemeRegistry, { Instance = inst, Property = prop, Key = key })
    inst[prop] = self.Theme[key]
    return inst
end

function Library:ApplyTheme(themeTable)
    for key, value in pairs(themeTable) do
        self.Theme[key] = value
    end
    for _, entry in ipairs(self.ThemeRegistry) do
        if entry.Instance and entry.Instance.Parent then
            local ok = pcall(function()
                Tween(entry.Instance, { [entry.Property] = self.Theme[entry.Key] }, 0.2)
            end)
            if not ok then
                entry.Instance[entry.Property] = self.Theme[entry.Key]
            end
        end
    end
end

function Library:SetTheme(name)
    local theme = self.Themes[name] or self.CustomThemes[name]
    if not theme then
        return
    end
    self.CurrentThemeName = name
    self:ApplyTheme(theme)
end

function Library:CreateCustomTheme(name, themeTable)
    self.CustomThemes[name] = themeTable
end

function Library:ResetTheme()
    self:SetTheme("Pink")
end

local function EnsureFolders()
    pcall(function()
        if not isfolder(Library.ConfigFolder) then
            makefolder(Library.ConfigFolder)
        end
        if not isfolder(Library.ConfigSubFolder) then
            makefolder(Library.ConfigSubFolder)
        end
    end)
end

function Library:GetConfigList()
    local list = {}
    pcall(function()
        for _, file in ipairs(listfiles(self.ConfigSubFolder)) do
            local name = file:match("([^\\/]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end)
    return list
end

function Library:SaveConfig(name)
    EnsureFolders()
    local data = {
        Flags = self.Flags,
        Theme = self.CurrentThemeName,
        CustomThemes = self.CustomThemes,
    }
    local encoded = HttpService:JSONEncode(data)
    local ok = pcall(function()
        writefile(self.ConfigSubFolder .. "/" .. name .. ".json", encoded)
    end)
    return ok
end

function Library:LoadConfig(name)
    local ok, content = pcall(function()
        return readfile(self.ConfigSubFolder .. "/" .. name .. ".json")
    end)
    if not ok then
        return false
    end
    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not decodeOk then
        return false
    end
    if data.CustomThemes then
        for key, value in pairs(data.CustomThemes) do
            self.CustomThemes[key] = value
        end
    end
    if data.Theme then
        self:SetTheme(data.Theme)
    end
    if data.Flags then
        for flag, value in pairs(data.Flags) do
            local option = self.Options[flag]
            if option and option.Set then
                option:Set(value)
            end
        end
    end
    return true
end

function Library:DeleteConfig(name)
    return pcall(function()
        delfile(self.ConfigSubFolder .. "/" .. name .. ".json")
    end)
end

function Library:SetAutoLoad(name)
    EnsureFolders()
    pcall(function()
        writefile(self.ConfigSubFolder .. "/autoload.txt", name)
    end)
end

function Library:DisableAutoLoad()
    pcall(function()
        delfile(self.ConfigSubFolder .. "/autoload.txt")
    end)
end

function Library:GetAutoLoad()
    local ok, content = pcall(function()
        return readfile(self.ConfigSubFolder .. "/autoload.txt")
    end)
    if ok then
        return content
    end
    return nil
end

function Library:Notify(options)
    options = options or {}
    local holder = self.NotificationHolder
    if not holder then
        return
    end
    local card = Create("Frame", {
        BackgroundColor3 = self.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = card })
    Create("UIStroke", { Color = self.Theme.Border, Thickness = 1, Parent = card })
    self:Themeify(card, "BackgroundColor3", "Secondary")

    local accentBar = Create("Frame", {
        BackgroundColor3 = self.Theme.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    self:Themeify(accentBar, "BackgroundColor3", "Accent")

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = card,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = card,
    })

    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = options.Title or "Notification",
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })
    self:Themeify(title, "TextColor3", "Text")

    if options.Description then
        local desc = Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            Text = options.Description,
            TextColor3 = self.Theme.SubText,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })
        self:Themeify(desc, "TextColor3", "SubText")
    end

    card.Size = UDim2.new(1, 0, 0, 0)
    card.Position = UDim2.new(1, 40, 0, 0)
    Tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.3)

    task.delay(options.Duration or 4, function()
        if card and card.Parent then
            Tween(card, { Position = UDim2.new(1, 40, 0, 0) }, 0.3)
            task.wait(0.3)
            card:Destroy()
        end
    end)
end

function Library:CloseActivePopup()
    if self.ActivePopup then
        self.ActivePopup.Visible = false
        self.ActivePopup = nil
    end
end

function Library:OpenPopup(popup)
    self:CloseActivePopup()
    popup.Visible = true
    self.ActivePopup = popup
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local GroupBox = {}
GroupBox.__index = GroupBox

function Library:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, Window)
    self.Title = options.Title or "Law.cc"
    self.Logo = options.Logo or "rbxassetid://0"
    self.Tabs = {}
    self.Open = true

    local screenGui = Create("ScreenGui", {
        Name = "LawCC",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local parented = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not parented then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    self.ScreenGui = screenGui
    Library.NotificationHolder = Create("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 0, 20),
        Size = UDim2.new(0, 300, 1, -40),
        Parent = screenGui,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Library.NotificationHolder,
    })

    local blur = Create("BlurEffect", { Size = 0, Parent = Lighting })
    self.Blur = blur

    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 720, 0, 480),
        Position = UDim2.new(0.5, -360, 0.5, -240),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = main })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = main })
    Library:Themeify(main, "BackgroundColor3", "Background")
    self.Main = main

    local topBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = topBar })
    Library:Themeify(topBar, "BackgroundColor3", "Secondary")
    MakeDraggable(topBar, main)

    local topBarMask = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = topBar,
    })
    Library:Themeify(topBarMask, "BackgroundColor3", "Secondary")

    local logo = Create("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 14, 0.5, -12),
        BackgroundTransparency = 1,
        Image = self.Logo,
        Parent = topBar,
    })

    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 0),
        Size = UDim2.new(1, -200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Title,
        TextColor3 = Library.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    Library:Themeify(title, "TextColor3", "Text")

    local closeButton = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Library.Theme.SubText,
        Parent = topBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = closeButton })
    Library:Themeify(closeButton, "BackgroundColor3", "Tertiary")
    Library:Themeify(closeButton, "TextColor3", "SubText")
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)

    local body = Create("Frame", {
        Name = "Body",
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 1, -44 - 28),
        BackgroundTransparency = 1,
        Parent = main,
    })

    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 170, 1, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = body,
    })
    Library:Themeify(sidebar, "BackgroundColor3", "Secondary")

    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -64),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = tabList,
    })
    self.TabList = tabList

    local playerInfo = Create("Frame", {
        Name = "PlayerInfo",
        Size = UDim2.new(1, 0, 0, 64),
        Position = UDim2.new(0, 0, 1, -64),
        BackgroundColor3 = Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    Library:Themeify(playerInfo, "BackgroundColor3", "Tertiary")

    local avatar = Create("ImageLabel", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 12, 0.5, -20),
        BackgroundColor3 = Library.Theme.Border,
        Parent = playerInfo,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = avatar })
    Library:Themeify(avatar, "BackgroundColor3", "Border")
    pcall(function()
        local content, _ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        avatar.Image = content
    end)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 10),
        Size = UDim2.new(1, -68, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = playerInfo,
    })
    local nameLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 30),
        Size = UDim2.new(1, -68, 0, 16),
        Font = Enum.Font.Gotham,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = playerInfo,
    })
    Library:Themeify(nameLabel, "TextColor3", "SubText")

    local content = Create("Frame", {
        Name = "Content",
        Position = UDim2.new(0, 170, 0, 0),
        Size = UDim2.new(1, -170, 1, 0),
        BackgroundTransparency = 1,
        Parent = body,
    })
    self.Content = content

    local footer = Create("Frame", {
        Name = "Footer",
        Position = UDim2.new(0, 0, 1, -28),
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = footer })
    Library:Themeify(footer, "BackgroundColor3", "Secondary")
    local footerMask = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = footer,
    })
    Library:Themeify(footerMask, "BackgroundColor3", "Secondary")

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Law.cc",
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = footer,
    }).TextColor3 = Library.Theme.SubText
    local footerText = footer:FindFirstChildOfClass("TextLabel")
    Library:Themeify(footerText, "TextColor3", "SubText")

    local footerVersion = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -160, 0, 0),
        Size = UDim2.new(0, 146, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "v1.0.0",
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = footer,
    })
    Library:Themeify(footerVersion, "TextColor3", "SubText")

    self.Pages = {}
    self.TabButtons = {}
    self.TabOrder = 1

    local mobileToggle = Create("TextButton", {
        Name = "MobileToggle",
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0, 20, 0.5, -26),
        BackgroundColor3 = Library.Theme.Accent,
        AutoButtonColor = false,
        Text = "≡",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Visible = UserInputService.TouchEnabled,
        Parent = screenGui,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = mobileToggle })
    Library:Themeify(mobileToggle, "BackgroundColor3", "Accent")
    MakeDraggable(mobileToggle, mobileToggle)
    mobileToggle.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    self.MobileToggle = mobileToggle

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.KeyCode == Library.ToggleKeybind then
            self:Toggle()
        end
    end)

    table.insert(Library.Windows, self)
    self:CreateTab({ Name = "Main", Icon = "home", Permanent = true })
    self.UISettingsTab = self:CreateTab({ Name = "UI Settings", Icon = "settings", Permanent = true, LayoutOrder = 9999 })
    self:PopulateUISettings()

    local autoloadName = Library:GetAutoLoad()
    if autoloadName then
        task.defer(function()
            Library:LoadConfig(autoloadName)
        end)
    end

    return self
end

function Window:Toggle()
    self.Open = not self.Open
    if self.Open then
        self.Main.Visible = true
        Tween(self.Main, { Size = UDim2.new(0, 720, 0, 480) }, 0.25)
    else
        Tween(self.Main, { Size = UDim2.new(0, 720, 0, 0) }, 0.2)
    end
end

function Window:Notify(options)
    Library:Notify(options)
end

function Window:CreateTab(options)
    options = options or {}
    local self = setmetatable({}, Tab)
    self.Name = options.Name or "Tab"
    self.Icon = options.Icon
    self.Window = Window

    local order = options.LayoutOrder
    if not order then
        order = Window.TabOrder
        Window.TabOrder = Window.TabOrder + 1
    end

    local button = Create("TextButton", {
        Name = self.Name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = order,
        Parent = Window.TabList,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = button })

    local icon = Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundTransparency = 1,
        ImageColor3 = Library.Theme.SubText,
        Parent = button,
    })
    if self.Icon then
        ApplyIcon(icon, self.Icon)
    end
    Library:Themeify(icon, "ImageColor3", "SubText")

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = self.Name,
        TextColor3 = Library.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    self.Button = button
    self.Icon_ = icon
    self.Label = label

    local page = Create("ScrollingFrame", {
        Name = self.Name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = Window.Content,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 14),
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = page,
    })

    local columns = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = page,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = columns,
    })

    local leftColumn = Create("Frame", {
        Name = "Left",
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = columns,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = leftColumn,
    })

    local rightColumn = Create("Frame", {
        Name = "Right",
        Size = UDim2.new(0.5, -6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = columns,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = rightColumn,
    })

    self.Page = page
    self.Columns = columns
    self.LeftColumn = leftColumn
    self.RightColumn = rightColumn
    self.GroupBoxOrder = { Left = 1, Right = 1 }

    Window.Pages[self.Name] = self
    table.insert(Window.TabButtons, self)

    button.MouseButton1Click:Connect(function()
        Window:SelectTab(self.Name)
    end)

    if not Window.SelectedTab then
        Window:SelectTab(self.Name)
    end

    return self
end

function Window:SelectTab(name)
    self.SelectedTab = name
    for tabName, tab in pairs(self.Pages) do
        local isSelected = tabName == name
        tab.Page.Visible = isSelected
        local textColor = isSelected and Library.Theme.Text or Library.Theme.SubText
        local bgColor = isSelected and Library.Theme.Tertiary or Library.Theme.Secondary
        Tween(tab.Label, { TextColor3 = textColor }, 0.15)
        Tween(tab.Icon_, { ImageColor3 = textColor }, 0.15)
        Tween(tab.Button, { BackgroundColor3 = bgColor }, 0.15)
    end
end

function Tab:CreateGroupBox(options)
    options = options or {}
    local self = setmetatable({}, GroupBox)
    self.Name = options.Name or "Group"
    self.Side = options.Side == "Right" and "Right" or "Left"
    local column = self.Side == "Right" and Tab.RightColumn or Tab.LeftColumn
    local order = Tab.GroupBoxOrder[self.Side]
    Tab.GroupBoxOrder[self.Side] = order + 1

    local container = Create("Frame", {
        Name = self.Name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = column,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = container })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = container })
    Library:Themeify(container, "BackgroundColor3", "Secondary")

    local header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = container,
    })

    if options.Icon then
        local icon = Create("ImageLabel", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 12, 0.5, -8),
            BackgroundTransparency = 1,
            ImageColor3 = Library.Theme.Accent,
            Parent = header,
        })
        ApplyIcon(icon, options.Icon)
        Library:Themeify(icon, "ImageColor3", "Accent")
    end

    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, options.Icon and 36 or 12, 0, 0),
        Size = UDim2.new(1, -48, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = self.Name,
        TextColor3 = Library.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    Library:Themeify(title, "TextColor3", "Text")

    local body = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = container,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = body,
    })
    Create("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = body,
    })

    self.Container = container
    self.Body = body
    self.ElementOrder = 1

    return self
end

local function NextOrder(box)
    local order = box.ElementOrder
    box.ElementOrder = order + 1
    return order
end

local function RegisterFlag(flag, object)
    if flag then
        Library.Options[flag] = object
        Library.Flags[flag] = object.Value
    end
end

function GroupBox:AddLabel(text)
    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = Library.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })
    Library:Themeify(label, "TextColor3", "SubText")
    return label
end

function GroupBox:AddParagraph(options)
    options = options or {}
    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })
    local title = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = options.Title or "",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(title, "TextColor3", "Text")
    local content = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Font = Enum.Font.Gotham,
        Text = options.Content or "",
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(content, "TextColor3", "SubText")
    return holder
end

function GroupBox:AddDivider()
    local divider = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Library.Theme.Border,
        BorderSizePixel = 0,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })
    Library:Themeify(divider, "BackgroundColor3", "Border")
    return divider
end

function GroupBox:AddButton(options)
    options = options or {}
    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Text = options.Text or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = button })
    Library:Themeify(button, "BackgroundColor3", "Tertiary")
    Library:Themeify(button, "TextColor3", "Text")

    button.MouseEnter:Connect(function()
        Tween(button, { BackgroundColor3 = Library.Theme.Accent }, 0.15)
    end)
    button.MouseLeave:Connect(function()
        Tween(button, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
    end)
    button.MouseButton1Click:Connect(function()
        if options.Callback then
            options.Callback()
        end
    end)

    return { Instance = button }
end

function GroupBox:AddToggle(flag, options)
    options = options or {}
    local self_ = { Value = options.Default or false }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -46, 1, 0),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Toggle",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local switch = Create("Frame", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -38, 0.5, -10),
        BackgroundColor3 = Library.Theme.Tertiary,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switch })
    Library:Themeify(switch, "BackgroundColor3", "Tertiary")

    local knob = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = switch,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local hitbox = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = holder,
    })

    function self_:Set(value)
        self_.Value = value
        Library.Flags[flag] = value
        if value then
            Tween(switch, { BackgroundColor3 = Library.Theme.Accent }, 0.15)
            Tween(knob, { Position = UDim2.new(1, -18, 0.5, -8) }, 0.15)
        else
            Tween(switch, { BackgroundColor3 = Library.Theme.Tertiary }, 0.15)
            Tween(knob, { Position = UDim2.new(0, 2, 0.5, -8) }, 0.15)
        end
        if options.Callback then
            options.Callback(value)
        end
    end

    hitbox.MouseButton1Click:Connect(function()
        self_:Set(not self_.Value)
    end)

    RegisterFlag(flag, self_)
    self_:Set(self_.Value)
    return self_
end

function GroupBox:AddSlider(flag, options)
    options = options or {}
    local min = options.Min or 0
    local max = options.Max or 100
    local rounding = options.Rounding or 0
    local suffix = options.Suffix or ""
    local self_ = { Value = options.Default or min }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Slider",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local valueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 60, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = tostring(self_.Value) .. suffix,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = holder,
    })
    Library:Themeify(valueLabel, "TextColor3", "SubText")

    local track = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 24),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Library.Theme.Tertiary,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
    Library:Themeify(track, "BackgroundColor3", "Tertiary")

    local fill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Library.Theme.Accent,
        Parent = track,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    Library:Themeify(fill, "BackgroundColor3", "Accent")

    local knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = fill,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local dragging = false

    local function UpdateFromAlpha(alpha)
        alpha = math.clamp(alpha, 0, 1)
        local value = min + (max - min) * alpha
        if rounding <= 0 then
            value = math.floor(value + 0.5)
        else
            local mult = 10 ^ rounding
            value = math.floor(value * mult + 0.5) / mult
        end
        self_:Set(value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local alpha = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            UpdateFromAlpha(alpha)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local alpha = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            UpdateFromAlpha(alpha)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    function self_:Set(value)
        value = math.clamp(value, min, max)
        self_.Value = value
        Library.Flags[flag] = value
        local alpha = (value - min) / (max - min)
        Tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, 0.1)
        valueLabel.Text = tostring(value) .. suffix
        if options.Callback then
            options.Callback(value)
        end
    end

    RegisterFlag(flag, self_)
    self_:Set(self_.Value)
    return self_
end

local function CreatePopup(parent)
    local popup = Create("Frame", {
        BackgroundColor3 = Library.Theme.Tertiary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        Parent = parent,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = popup })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = popup })
    Library:Themeify(popup, "BackgroundColor3", "Tertiary")
    return popup
end

function GroupBox:AddDropdown(flag, options)
    options = options or {}
    local values = options.Values or {}
    local self_ = { Value = options.Default or values[1] }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
        ZIndex = 2,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Dropdown",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local box = Create("TextButton", {
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 2,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
    Library:Themeify(box, "BackgroundColor3", "Tertiary")

    local selectedLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = tostring(self_.Value or ""),
        TextColor3 = Library.Theme.SubText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = box,
    })
    Library:Themeify(selectedLabel, "TextColor3", "SubText")

    local popup = CreatePopup(holder)
    popup.Position = UDim2.new(0, 0, 0, 52)
    popup.Size = UDim2.new(1, 0, 0, math.min(#values, 5) * 28 + 8)
    popup.ClipsDescendants = true

    local list = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 51,
        Parent = popup,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = list,
    })

    function self_:Refresh(newValues)
        values = newValues
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        for _, value in ipairs(values) do
            local option = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = Library.Theme.Secondary,
                AutoButtonColor = false,
                Text = tostring(value),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Library.Theme.Text,
                ZIndex = 52,
                Parent = list,
            })
            Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option })
            option.MouseButton1Click:Connect(function()
                self_:Set(value)
                Library:CloseActivePopup()
            end)
        end
    end

    function self_:Set(value)
        self_.Value = value
        Library.Flags[flag] = value
        selectedLabel.Text = tostring(value)
        if options.Callback then
            options.Callback(value)
        end
    end

    box.MouseButton1Click:Connect(function()
        if popup.Visible then
            Library:CloseActivePopup()
        else
            Library:OpenPopup(popup)
        end
    end)

    self_:Refresh(values)
    RegisterFlag(flag, self_)
    if self_.Value then
        self_:Set(self_.Value)
    end
    return self_
end

function GroupBox:AddMultiDropdown(flag, options)
    options = options or {}
    local values = options.Values or {}
    local self_ = { Value = options.Default or {} }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
        ZIndex = 2,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Multi Dropdown",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local box = Create("TextButton", {
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 2,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
    Library:Themeify(box, "BackgroundColor3", "Tertiary")

    local selectedLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = Library.Theme.SubText,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = box,
    })
    Library:Themeify(selectedLabel, "TextColor3", "SubText")

    local popup = CreatePopup(holder)
    popup.Position = UDim2.new(0, 0, 0, 52)
    popup.Size = UDim2.new(1, 0, 0, math.min(#values, 5) * 28 + 8)
    popup.ClipsDescendants = true

    local list = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 51,
        Parent = popup,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = list,
    })

    local function RefreshLabel()
        selectedLabel.Text = table.concat(self_.Value, ", ")
    end

    function self_:Set(value)
        self_.Value = value
        Library.Flags[flag] = value
        RefreshLabel()
        if options.Callback then
            options.Callback(value)
        end
    end

    local function Contains(list_, item)
        for _, v in ipairs(list_) do
            if v == item then
                return true
            end
        end
        return false
    end

    for _, value in ipairs(values) do
        local isSelected = Contains(self_.Value, value)
        local option = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = isSelected and Library.Theme.Accent or Library.Theme.Secondary,
            AutoButtonColor = false,
            Text = tostring(value),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Library.Theme.Text,
            ZIndex = 52,
            Parent = list,
        })
        Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = option })
        option.MouseButton1Click:Connect(function()
            local newValues = {}
            local removed = false
            for _, v in ipairs(self_.Value) do
                if v == value then
                    removed = true
                else
                    table.insert(newValues, v)
                end
            end
            if not removed then
                table.insert(newValues, value)
                option.BackgroundColor3 = Library.Theme.Accent
            else
                option.BackgroundColor3 = Library.Theme.Secondary
            end
            self_:Set(newValues)
        end)
    end

    box.MouseButton1Click:Connect(function()
        if popup.Visible then
            Library:CloseActivePopup()
        else
            Library:OpenPopup(popup)
        end
    end)

    RefreshLabel()
    RegisterFlag(flag, self_)
    return self_
end

function GroupBox:AddTextbox(flag, options)
    options = options or {}
    local self_ = { Value = options.Default or "" }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Textbox",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local box = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 20),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Library.Theme.Tertiary,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = box })
    Library:Themeify(box, "BackgroundColor3", "Tertiary")

    local input = Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Gotham,
        Text = self_.Value,
        PlaceholderText = options.Placeholder or "",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = box,
    })
    Library:Themeify(input, "TextColor3", "Text")

    function self_:Set(value)
        self_.Value = value
        Library.Flags[flag] = value
        input.Text = value
        if options.Callback then
            options.Callback(value)
        end
    end

    input.FocusLost:Connect(function()
        self_:Set(input.Text)
    end)

    RegisterFlag(flag, self_)
    return self_
end

function GroupBox:AddKeybind(flag, options)
    options = options or {}
    local self_ = { Value = options.Default or Enum.KeyCode.Unknown }
    local listening = false

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -90, 1, 0),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Keybind",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local button = Create("TextButton", {
        Position = UDim2.new(1, -84, 0.5, -12),
        Size = UDim2.new(0, 84, 0, 24),
        BackgroundColor3 = Library.Theme.Tertiary,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = self_.Value.Name,
        TextColor3 = Library.Theme.SubText,
        TextSize = 12,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = button })
    Library:Themeify(button, "BackgroundColor3", "Tertiary")
    Library:Themeify(button, "TextColor3", "SubText")

    function self_:Set(keyCode)
        self_.Value = keyCode
        Library.Flags[flag] = keyCode
        button.Text = keyCode.Name
        if options.Callback then
            options.Callback(keyCode)
        end
    end

    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            self_:Set(input.KeyCode)
        elseif not gameProcessed and self_.Value and input.KeyCode == self_.Value and options.OnPress then
            options.OnPress()
        end
    end)

    RegisterFlag(flag, self_)
    return self_
end

local function HSVFromColor(color)
    local h, s, v = Color3.toHSV(color)
    return h, s, v
end

function GroupBox:AddColorPicker(flag, options)
    options = options or {}
    local self_ = { Value = options.Default or Color3.fromRGB(255, 255, 255) }

    local holder = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(self),
        Parent = self.Body,
        ZIndex = 2,
    })

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -34, 1, 0),
        Font = Enum.Font.Gotham,
        Text = options.Text or "Color",
        TextColor3 = Library.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Library:Themeify(label, "TextColor3", "Text")

    local swatch = Create("TextButton", {
        Position = UDim2.new(1, -28, 0.5, -10),
        Size = UDim2.new(0, 28, 0, 20),
        BackgroundColor3 = self_.Value,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 2,
        Parent = holder,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 5), Parent = swatch })
    Create("UIStroke", { Color = Library.Theme.Border, Thickness = 1, Parent = swatch })

    local popup = CreatePopup(holder)
    popup.Position = UDim2.new(1, -180, 0, 30)
    popup.Size = UDim2.new(0, 180, 0, 170)
    popup.ZIndex = 60

    local sv = Create("ImageButton", {
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 100),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        AutoButtonColor = false,
        ZIndex = 61,
        Parent = popup,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sv })
    local svWhite = Create("UIGradient", {
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
        Transparency = NumberSequence.new(0, 1),
        Parent = sv,
    })
    local svBlack = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 62,
        Parent = sv,
    })
    Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)),
        Transparency = NumberSequence.new(1, 0),
        Parent = svBlack,
    })

    local svCursor = Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 63,
        Parent = sv,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })
    Create("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Parent = svCursor })

    local hueBar = Create("ImageButton", {
        Position = UDim2.new(0, 10, 0, 120),
        Size = UDim2.new(1, -20, 0, 16),
        AutoButtonColor = false,
        ZIndex = 61,
        Parent = popup,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hueBar })
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })

    local hueCursor = Create("Frame", {
        Size = UDim2.new(0, 4, 1, 4),
        Position = UDim2.new(0, 0, 0, -2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 62,
        Parent = hueBar,
    })

    local hexInput = Create("TextBox", {
        Position = UDim2.new(0, 10, 0, 142),
        Size = UDim2.new(1, -20, 0, 22),
        BackgroundColor3 = Library.Theme.Secondary,
        Font = Enum.Font.Gotham,
        Text = self_.Value:ToHex(),
        TextColor3 = Library.Theme.Text,
        TextSize = 12,
        ClearTextOnFocus = false,
        ZIndex = 61,
        Parent = popup,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 4), Parent = hexInput })
    Library:Themeify(hexInput, "BackgroundColor3", "Secondary")
    Library:Themeify(hexInput, "TextColor3", "Text")

    local hue, sat, val = HSVFromColor(self_.Value)

    local function UpdateVisuals()
        sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        svCursor.Position = UDim2.new(sat, -4, 1 - val, -4)
        hueCursor.Position = UDim2.new(hue, 0, 0, -2)
        hexInput.Text = self_.Value:ToHex()
    end

    function self_:Set(color)
        self_.Value = color
        Library.Flags[flag] = color
        swatch.BackgroundColor3 = color
        hue, sat, val = HSVFromColor(color)
        UpdateVisuals()
        if options.Callback then
            options.Callback(color)
        end
    end

    local function SetFromHSV()
        self_:Set(Color3.fromHSV(hue, sat, val))
    end

    local draggingSV = false
    local draggingHue = false

    sv.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if draggingSV then
            sat = math.clamp((input.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
            val = 1 - math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
            SetFromHSV()
        elseif draggingHue then
            hue = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            SetFromHSV()
        end
    end)

    hexInput.FocusLost:Connect(function()
        local ok, color = pcall(function()
            return Color3.fromHex(hexInput.Text)
        end)
        if ok then
            self_:Set(color)
        else
            hexInput.Text = self_.Value:ToHex()
        end
    end)

    swatch.MouseButton1Click:Connect(function()
        if popup.Visible then
            Library:CloseActivePopup()
        else
            Library:OpenPopup(popup)
        end
    end)

    UpdateVisuals()
    RegisterFlag(flag, self_)
    return self_
end

function Window:PopulateUISettings()
    local tab = self.UISettingsTab

    local configBox = tab:CreateGroupBox({ Name = "Configuration", Side = "Left", Icon = "save" })
    local configDropdown = configBox:AddDropdown("LawCC_ConfigSelector", {
        Text = "Config Selector",
        Values = Library:GetConfigList(),
        Callback = function() end,
    })

    local nameBox = configBox:AddTextbox("LawCC_ConfigName", {
        Text = "Config Name",
        Placeholder = "MyConfig",
        Default = "Default",
    })

    configBox:AddButton({
        Text = "Save Config",
        Callback = function()
            local name = Library.Flags.LawCC_ConfigName
            if name and name ~= "" then
                Library:SaveConfig(name)
                configDropdown:Refresh(Library:GetConfigList())
                Library:Notify({ Title = "Config Saved", Description = name, Duration = 3 })
            end
        end,
    })

    configBox:AddButton({
        Text = "Load Config",
        Callback = function()
            local name = configDropdown.Value
            if name then
                Library:LoadConfig(name)
                Library:Notify({ Title = "Config Loaded", Description = name, Duration = 3 })
            end
        end,
    })

    configBox:AddButton({
        Text = "Delete Config",
        Callback = function()
            local name = configDropdown.Value
            if name then
                Library:DeleteConfig(name)
                configDropdown:Refresh(Library:GetConfigList())
                Library:Notify({ Title = "Config Deleted", Description = name, Duration = 3 })
            end
        end,
    })

    configBox:AddDivider()

    configBox:AddButton({
        Text = "Auto Load",
        Callback = function()
            local name = configDropdown.Value
            if name then
                Library:SetAutoLoad(name)
                Library:Notify({ Title = "Auto Load Set", Description = name, Duration = 3 })
            end
        end,
    })

    configBox:AddButton({
        Text = "Disable Auto Load",
        Callback = function()
            Library:DisableAutoLoad()
            Library:Notify({ Title = "Auto Load Disabled", Duration = 3 })
        end,
    })

    local themeBox = tab:CreateGroupBox({ Name = "Customization", Side = "Right", Icon = "palette" })

    local themeNames = { "Pink", "Purple", "Blue", "Green", "Red", "Orange" }
    local themeDropdown = themeBox:AddDropdown("LawCC_ThemeSelector", {
        Text = "Theme Selector",
        Values = themeNames,
        Default = "Pink",
        Callback = function(value)
            Library:SetTheme(value)
        end,
    })

    themeBox:AddDivider()

    local accentPicker = themeBox:AddColorPicker("LawCC_AccentColor", {
        Text = "Change Accent Color",
        Default = Library.Theme.Accent,
        Callback = function(color)
            Library:ApplyTheme({ Accent = color })
        end,
    })

    themeBox:AddButton({
        Text = "Edit Theme Colors",
        Callback = function()
            Library:Notify({ Title = "Edit Theme Colors", Description = "Use the color pickers below to customize", Duration = 3 })
        end,
    })

    themeBox:AddColorPicker("LawCC_BackgroundColor", {
        Text = "Background Color",
        Default = Library.Theme.Background,
        Callback = function(color)
            Library:ApplyTheme({ Background = color })
        end,
    })

    themeBox:AddColorPicker("LawCC_SecondaryColor", {
        Text = "Secondary Color",
        Default = Library.Theme.Secondary,
        Callback = function(color)
            Library:ApplyTheme({ Secondary = color })
        end,
    })

    local customThemeName = themeBox:AddTextbox("LawCC_CustomThemeName", {
        Text = "Custom Theme Name",
        Placeholder = "MyTheme",
        Default = "MyTheme",
    })

    themeBox:AddButton({
        Text = "Create Custom Theme",
        Callback = function()
            local name = Library.Flags.LawCC_CustomThemeName
            if name and name ~= "" then
                local snapshot = {}
                for key, value in pairs(Library.Theme) do
                    snapshot[key] = value
                end
                Library:CreateCustomTheme(name, snapshot)
                Library:Notify({ Title = "Custom Theme Created", Description = name, Duration = 3 })
            end
        end,
    })

    themeBox:AddButton({
        Text = "Reset Theme",
        Callback = function()
            Library:ResetTheme()
            themeDropdown:Set("Pink")
            accentPicker:Set(Library.Theme.Accent)
        end,
    })

    themeBox:AddDivider()

    themeBox:AddKeybind("LawCC_MenuKeybind", {
        Text = "Menu Keybind",
        Default = Library.ToggleKeybind,
        Callback = function(keyCode)
            Library.ToggleKeybind = keyCode
        end,
    })

    themeBox:AddToggle("LawCC_ToggleBlur", {
        Text = "Toggle Blur",
        Default = false,
        Callback = function(value)
            Library.BlurEnabled = value
            Tween(self.Blur, { Size = value and 24 or 0 }, 0.25)
        end,
    })

    themeBox:AddToggle("LawCC_ToggleAnimations", {
        Text = "Toggle Animations",
        Default = true,
        Callback = function(value)
            Library.AnimationsEnabled = value
        end,
    })
end

return Library
