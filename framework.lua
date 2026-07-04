local Library = {}

Library.Flags = {}
Library.Toggles = {}
Library.Options = {}
Library.SelectedTheme = "Dark"
Library.ToggleKeybind = Enum.KeyCode.RightControl
Library.ConfigFolder = "Law.cc"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ThemeObjects = {}

Library.Themes = {
    Dark = {
        Accent = Color3.fromRGB(88, 121, 255),
        Background = Color3.fromRGB(18, 18, 22),
        Foreground = Color3.fromRGB(26, 26, 31),
        ElementBackground = Color3.fromRGB(33, 33, 39),
        Outline = Color3.fromRGB(45, 45, 52),
        Text = Color3.fromRGB(235, 235, 240),
        SubText = Color3.fromRGB(148, 148, 160)
    },
    Light = {
        Accent = Color3.fromRGB(70, 110, 240),
        Background = Color3.fromRGB(240, 240, 245),
        Foreground = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(228, 228, 234),
        Outline = Color3.fromRGB(208, 208, 216),
        Text = Color3.fromRGB(20, 20, 24),
        SubText = Color3.fromRGB(100, 100, 112)
    },
    Midnight = {
        Accent = Color3.fromRGB(122, 90, 255),
        Background = Color3.fromRGB(10, 10, 16),
        Foreground = Color3.fromRGB(16, 16, 24),
        ElementBackground = Color3.fromRGB(22, 22, 32),
        Outline = Color3.fromRGB(34, 34, 46),
        Text = Color3.fromRGB(230, 230, 240),
        SubText = Color3.fromRGB(140, 140, 162)
    }
}

Library.Theme = Library.Themes.Dark

local function Create(class, props, children)
    local inst = Instance.new(class)
    for prop, value in pairs(props or {}) do
        if prop ~= "Parent" then
            inst[prop] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(inst, props, time, style, dir)
    return TweenService:Create(inst, TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function RegisterThemeObject(inst, property, role)
    table.insert(ThemeObjects, { Instance = inst, Property = property, Role = role })
    inst[property] = Library.Theme[role]
end

function Library:ApplyTheme()
    for _, obj in ipairs(ThemeObjects) do
        if obj.Instance and obj.Instance.Parent then
            obj.Instance[obj.Property] = Library.Theme[obj.Role]
        end
    end
end

function Library:SetTheme(name)
    local theme = Library.Themes[name]
    if not theme then
        return
    end
    Library.SelectedTheme = name
    Library.Theme = theme
    Library:ApplyTheme()
end

function Library:CreateCustomTheme(name, colors)
    Library.Themes[name] = colors
    Library:SetTheme(name)
end

local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then
        return nil
    end
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    if not (r and g and b) then
        return nil
    end
    return Color3.fromRGB(r, g, b)
end

local function MakeDraggable(handle, frame)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function GetParentGui()
    local ok, hidden = pcall(function()
        return gethui()
    end)
    if ok and hidden then
        return hidden
    end
    local ok2, protected = pcall(function()
        return CoreGui
    end)
    if ok2 and protected then
        return protected
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

function Library:SaveConfig(name)
    local data = {}
    for flag, value in pairs(Library.Flags) do
        data[flag] = value
    end
    local encoded = HttpService:JSONEncode(data)
    if writefile and makefolder and isfolder then
        if not isfolder(Library.ConfigFolder) then
            makefolder(Library.ConfigFolder)
        end
        if not isfolder(Library.ConfigFolder .. "/configs") then
            makefolder(Library.ConfigFolder .. "/configs")
        end
        writefile(Library.ConfigFolder .. "/configs/" .. name .. ".json", encoded)
    end
end

function Library:LoadConfig(name)
    if not (readfile and isfile) then
        return false
    end
    local path = Library.ConfigFolder .. "/configs/" .. name .. ".json"
    if not isfile(path) then
        return false
    end
    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not success then
        return false
    end
    for flag, value in pairs(decoded) do
        Library.Flags[flag] = value
        if Library.Toggles[flag] then
            Library.Toggles[flag]:SetValue(value)
        elseif Library.Options[flag] then
            Library.Options[flag]:SetValue(value)
        end
    end
    return true
end

function Library:DeleteConfig(name)
    if delfile and isfile then
        local path = Library.ConfigFolder .. "/configs/" .. name .. ".json"
        if isfile(path) then
            delfile(path)
        end
    end
end

function Library:ListConfigs()
    local list = {}
    if listfiles and isfolder and isfolder(Library.ConfigFolder .. "/configs") then
        for _, file in ipairs(listfiles(Library.ConfigFolder .. "/configs")) do
            local name = file:match("([^\\/]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end
    return list
end

function Library:SetAutoload(name)
    if writefile and makefolder and isfolder then
        if not isfolder(Library.ConfigFolder) then
            makefolder(Library.ConfigFolder)
        end
        writefile(Library.ConfigFolder .. "/autoload.txt", name)
    end
end

function Library:GetAutoload()
    if readfile and isfile and isfile(Library.ConfigFolder .. "/autoload.txt") then
        return readfile(Library.ConfigFolder .. "/autoload.txt")
    end
    return nil
end

function Library:RemoveAutoload()
    if delfile and isfile and isfile(Library.ConfigFolder .. "/autoload.txt") then
        delfile(Library.ConfigFolder .. "/autoload.txt")
    end
end

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Law.cc"
    local logoId = config.LogoId or "rbxassetid://0"
    local footerText = config.Footer or ("Law.cc  •  " .. windowTitle)

    local ScreenGui = Create("ScreenGui", {
        Name = "LawCC",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GetParentGui()
    })

    local Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(680, 440),
        Position = UDim2.new(0.5, -340, 0.5, -220),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = Library.Theme.Outline, Thickness = 1 })
    })
    RegisterThemeObject(Main, "BackgroundColor3", "Background")

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Library.Theme.Foreground,
        BorderSizePixel = 0,
        Parent = Main
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) })
    })
    RegisterThemeObject(TopBar, "BackgroundColor3", "Foreground")

    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BackgroundColor3 = Library.Theme.Foreground,
        BorderSizePixel = 0,
        Parent = TopBar
    })

    local Logo = Create("ImageLabel", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(0, 12, 0.5, -12),
        BackgroundTransparency = 1,
        Image = logoId,
        Parent = TopBar
    })

    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        BackgroundTransparency = 1,
        Text = windowTitle,
        TextColor3 = Library.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    RegisterThemeObject(TitleLabel, "TextColor3", "Text")

    local CloseButton = Create("TextButton", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -36, 0.5, -13),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Text = "X",
        TextColor3 = Library.Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = TopBar
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })
    RegisterThemeObject(CloseButton, "BackgroundColor3", "ElementBackground")
    RegisterThemeObject(CloseButton, "TextColor3", "SubText")

    local MinimizeButton = Create("TextButton", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -68, 0.5, -13),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Text = "_",
        TextColor3 = Library.Theme.SubText,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = TopBar
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) })
    })
    RegisterThemeObject(MinimizeButton, "BackgroundColor3", "ElementBackground")
    RegisterThemeObject(MinimizeButton, "TextColor3", "SubText")

    MakeDraggable(TopBar, Main)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    local minimized = false
    local Body = Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -72),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local Footer = Create("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundColor3 = Library.Theme.Foreground,
        BorderSizePixel = 0,
        Parent = Main
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) })
    })
    RegisterThemeObject(Footer, "BackgroundColor3", "Foreground")

    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Library.Theme.Foreground,
        BorderSizePixel = 0,
        Parent = Footer
    })

    local FooterLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = footerText,
        TextColor3 = Library.Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })
    RegisterThemeObject(FooterLabel, "TextColor3", "SubText")

    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        Body.Visible = not minimized
        Footer.Visible = not minimized
        Tween(Main, { Size = minimized and UDim2.fromOffset(680, 42) or UDim2.fromOffset(680, 440) }, 0.2):Play()
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end
        if input.KeyCode == Library.ToggleKeybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Library.Theme.Foreground,
        BorderSizePixel = 0,
        Parent = Body
    })
    RegisterThemeObject(Sidebar, "BackgroundColor3", "Foreground")

    local PlayerInfo = Create("Frame", {
        Name = "PlayerInfo",
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundTransparency = 1,
        Parent = Sidebar
    })

    local DisplayNameLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        Text = LocalPlayer.DisplayName,
        TextColor3 = Library.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = PlayerInfo
    })
    RegisterThemeObject(DisplayNameLabel, "TextColor3", "Text")

    local AvatarFrame = Create("Frame", {
        Size = UDim2.fromOffset(56, 56),
        Position = UDim2.new(0.5, -28, 0, 34),
        BackgroundColor3 = Library.Theme.ElementBackground,
        Parent = PlayerInfo
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    RegisterThemeObject(AvatarFrame, "BackgroundColor3", "ElementBackground")

    local AvatarImage = Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "",
        Parent = AvatarFrame
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })

    task.spawn(function()
        local ok, content = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
        end)
        if ok and content then
            AvatarImage.Image = content
        end
    end)

    local UsernameLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 96),
        BackgroundTransparency = 1,
        Text = "@" .. LocalPlayer.Name,
        TextColor3 = Library.Theme.SubText,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Parent = PlayerInfo
    })
    RegisterThemeObject(UsernameLabel, "TextColor3", "SubText")

    local TabListHolder = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, 0, 1, -140),
        Position = UDim2.new(0, 0, 0, 140),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    }, {
        Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        }),
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8)
        })
    })

    local ContentHolder = Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundTransparency = 1,
        Parent = Body
    })

    local Window = {}
    Window.Tabs = {}
    Window.ScreenGui = ScreenGui
    local tabOrder = 0
    local activeTab = nil

    local function SelectTab(tab)
        if activeTab then
            activeTab.Page.Visible = false
            activeTab.Button.BackgroundColor3 = Library.Theme.Foreground
            activeTab.Button.TextColor3 = Library.Theme.SubText
        end
        tab.Page.Visible = true
        tab.Button.BackgroundColor3 = Library.Theme.ElementBackground
        tab.Button.TextColor3 = Library.Theme.Text
        activeTab = tab
    end

    local function BuildGroupboxMethods(Groupbox)
        function Groupbox:AddLabel(text)
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Library.Theme.SubText,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Groupbox.Container
            })
            RegisterThemeObject(Label, "TextColor3", "SubText")
            return Label
        end

        function Groupbox:AddDivider()
            local Divider = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Library.Theme.Outline,
                BorderSizePixel = 0,
                Parent = Groupbox.Container
            })
            RegisterThemeObject(Divider, "BackgroundColor3", "Outline")
            return Divider
        end

        function Groupbox:AddButton(text, callback)
            callback = callback or function() end
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Text = text,
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                AutoButtonColor = false,
                Parent = Groupbox.Container
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            RegisterThemeObject(Button, "BackgroundColor3", "ElementBackground")
            RegisterThemeObject(Button, "TextColor3", "Text")
            Button.MouseButton1Click:Connect(function()
                callback()
            end)
            return Button
        end

        function Groupbox:AddToggle(flag, config)
            config = config or {}
            local Toggle = { Value = config.Default or false, Flag = flag, Callback = config.Callback or function() end }

            local Holder = Create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = Groupbox.Container })
            local Box = Create("Frame", {
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                Create("UIStroke", { Color = Library.Theme.Outline })
            })
            local Fill = Create("Frame", {
                Size = UDim2.new(1, -6, 1, -6),
                Position = UDim2.new(0, 3, 0, 3),
                BackgroundColor3 = Library.Theme.Accent,
                BackgroundTransparency = 1,
                Parent = Box
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 3) })
            })
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 24, 0, 0),
                BackgroundTransparency = 1,
                Text = config.Text or "Toggle",
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder
            })
            local ClickArea = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Holder })

            RegisterThemeObject(Box, "BackgroundColor3", "ElementBackground")
            RegisterThemeObject(Fill, "BackgroundColor3", "Accent")
            RegisterThemeObject(Label, "TextColor3", "Text")

            function Toggle:SetValue(value)
                Toggle.Value = value
                Library.Flags[flag] = value
                Tween(Fill, { BackgroundTransparency = value and 0 or 1 }, 0.15):Play()
                Toggle.Callback(value)
            end

            ClickArea.MouseButton1Click:Connect(function()
                Toggle:SetValue(not Toggle.Value)
            end)

            Toggle:SetValue(Toggle.Value)
            Library.Toggles[flag] = Toggle
            Library.Flags[flag] = Toggle.Value
            return Toggle
        end

        function Groupbox:AddSlider(flag, config)
            config = config or {}
            local min = config.Min or 0
            local max = config.Max or 100
            local rounding = config.Rounding or 0
            local suffix = config.Suffix or ""
            local Slider = { Value = config.Default or min, Flag = flag, Callback = config.Callback or function() end }

            local Holder = Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = Groupbox.Container })
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 0, 16),
                BackgroundTransparency = 1,
                Text = config.Text or "Slider",
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder
            })
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 16),
                Position = UDim2.new(1, -50, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(Slider.Value) .. suffix,
                TextColor3 = Library.Theme.SubText,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Holder
            })
            local Bar = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            local Fill = Create("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Library.Theme.Accent,
                Parent = Bar
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })

            RegisterThemeObject(Label, "TextColor3", "Text")
            RegisterThemeObject(ValueLabel, "TextColor3", "SubText")
            RegisterThemeObject(Bar, "BackgroundColor3", "ElementBackground")
            RegisterThemeObject(Fill, "BackgroundColor3", "Accent")

            local function Update(value)
                value = math.clamp(value, min, max)
                local mult = math.pow(10, rounding)
                value = math.floor(value * mult + 0.5) / mult
                Slider.Value = value
                Library.Flags[flag] = value
                ValueLabel.Text = tostring(value) .. suffix
                local pct = (value - min) / (max - min)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                Slider.Callback(value)
            end

            function Slider:SetValue(value)
                Update(value)
            end

            local dragging = false
            local function DragTo(input)
                local pct = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Update(min + (max - min) * pct)
            end

            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    DragTo(input)
                end
            end)
            Bar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    DragTo(input)
                end
            end)

            Update(Slider.Value)
            Library.Options[flag] = Slider
            return Slider
        end

        function Groupbox:AddDropdown(flag, config)
            config = config or {}
            local values = config.Values or {}
            local Dropdown = { Value = config.Default or values[1], Flag = flag, Callback = config.Callback or function() end, Open = false }

            local Holder = Create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = Groupbox.Container, ClipsDescendants = false, ZIndex = 2 })
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = config.Text or "Dropdown",
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder
            })
            local SelectBox = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 3,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            local SelectedLabel = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(Dropdown.Value or "None"),
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 3,
                Parent = SelectBox
            })

            local ListFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, math.min(#values, 5) * 26),
                Position = UDim2.new(0, 0, 0, 48),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Visible = false,
                ZIndex = 5,
                ClipsDescendants = true,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Library.Theme.Outline })
            })
            local ListLayout = Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = ListFrame })
            local ScrollFrame = Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 5,
                Parent = ListFrame
            })
            ListLayout.Parent = ScrollFrame

            RegisterThemeObject(Label, "TextColor3", "Text")
            RegisterThemeObject(SelectBox, "BackgroundColor3", "ElementBackground")
            RegisterThemeObject(SelectedLabel, "TextColor3", "Text")
            RegisterThemeObject(ListFrame, "BackgroundColor3", "ElementBackground")

            local function RebuildOptions()
                for _, child in ipairs(ScrollFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                for _, value in ipairs(values) do
                    local Option = Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = Library.Theme.ElementBackground,
                        BackgroundTransparency = 1,
                        Text = tostring(value),
                        TextColor3 = Library.Theme.Text,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        ZIndex = 5,
                        Parent = ScrollFrame
                    })
                    RegisterThemeObject(Option, "TextColor3", "Text")
                    Option.MouseButton1Click:Connect(function()
                        Dropdown:SetValue(value)
                        Dropdown:Close()
                    end)
                end
            end

            function Dropdown:SetValues(newValues)
                values = newValues
                ListFrame.Size = UDim2.new(1, 0, 0, math.min(#values, 5) * 26)
                RebuildOptions()
            end

            function Dropdown:SetValue(value)
                Dropdown.Value = value
                Library.Flags[flag] = value
                SelectedLabel.Text = tostring(value)
                Dropdown.Callback(value)
            end

            function Dropdown:Open_()
                Dropdown.Open = true
                ListFrame.Visible = true
            end

            function Dropdown:Close()
                Dropdown.Open = false
                ListFrame.Visible = false
            end

            SelectBox.MouseButton1Click:Connect(function()
                if Dropdown.Open then
                    Dropdown:Close()
                else
                    Dropdown:Open_()
                end
            end)

            RebuildOptions()
            Dropdown:SetValue(Dropdown.Value)
            Library.Options[flag] = Dropdown
            return Dropdown
        end

        function Groupbox:AddInput(flag, config)
            config = config or {}
            local Input = { Value = config.Default or "", Flag = flag, Callback = config.Callback or function() end }

            local Holder = Create("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = Groupbox.Container })
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text = config.Text or "Input",
                TextColor3 = Library.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder
            })
            local Box = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                Position = UDim2.new(0, 0, 0, 20),
                BackgroundColor3 = Library.Theme.ElementBackground,
                Parent = Holder
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            local TextBox = Create("TextBox", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = Input.Value,
                PlaceholderText = config.Placeholder or "",
                TextColor3 = Library.Theme.Text,
                PlaceholderColor3 = Library.Theme.SubText,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Box
            })

            RegisterThemeObject(Label, "TextColor3", "Text")
            RegisterThemeObject(Box, "BackgroundColor3", "ElementBackground")
            RegisterThemeObject(TextBox, "TextColor3", "Text")

            function Input:SetValue(value)
                Input.Value = value
                TextBox.Text = value
                Library.Flags[flag] = value
                Input.Callback(value)
            end

            TextBox.FocusLost:Connect(function()
                Input:SetValue(TextBox.Text)
            end)

            Library.Options[flag] = Input
            return Input
        end
    end

    local function CreateGroupbox(page, name, side)
        local Groupbox = {}
        Groupbox.Column = side

        local Container = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Library.Theme.Foreground,
            Parent = side == "Left" and page.LeftColumn or page.RightColumn
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", { Color = Library.Theme.Outline })
        })
        RegisterThemeObject(Container, "BackgroundColor3", "Foreground")

        Create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 24),
            Position = UDim2.new(0, 8, 0, 4),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.Theme.Accent,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Container
        })
        RegisterThemeObject(Container, "BackgroundColor3", "Foreground")

        local Inner = Create("Frame", {
            Size = UDim2.new(1, -16, 0, 0),
            Position = UDim2.new(0, 8, 0, 30),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = Container
        }, {
            Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
            Create("UIPadding", { PaddingBottom = UDim.new(0, 10) })
        })

        Groupbox.Container = Inner
        BuildGroupboxMethods(Groupbox)
        return Groupbox
    end

    local function CreatePage()
        local Page = Create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentHolder
        })
        local ScrollFrame = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = Page
        }, {
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })
        })
        local Layout = Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ScrollFrame
        })
        Page.LeftColumn = Create("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = ScrollFrame
        }, {
            Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
        })
        Page.RightColumn = Create("Frame", {
            Size = UDim2.new(0.5, -5, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = ScrollFrame
        }, {
            Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder })
        })
        Page.Frame = Page
        return Page
    end

    local function InternalCreateTab(name, layoutOrder)
        local Page = CreatePage()

        local Button = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = layoutOrder,
            BackgroundColor3 = Library.Theme.Foreground,
            Text = name,
            TextColor3 = Library.Theme.SubText,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            AutoButtonColor = false,
            Parent = TabListHolder
        }, {
            Create("UICorner", { CornerRadius = UDim.new(0, 6) })
        })
        RegisterThemeObject(Button, "BackgroundColor3", "Foreground")

        local Tab = { Page = Page, Button = Button, Name = name }

        function Tab:AddLeftGroupbox(groupboxName)
            return CreateGroupbox(Page, groupboxName, "Left")
        end

        function Tab:AddRightGroupbox(groupboxName)
            return CreateGroupbox(Page, groupboxName, "Right")
        end

        Button.MouseButton1Click:Connect(function()
            SelectTab(Tab)
        end)

        table.insert(Window.Tabs, Tab)
        if not activeTab then
            SelectTab(Tab)
        end
        return Tab
    end

    function Window:CreateTab(name)
        tabOrder = tabOrder + 1
        return InternalCreateTab(name, tabOrder)
    end

    local function BuildSettingsTab()
        local Tab = InternalCreateTab("UI Settings", math.huge)

        local ConfigBox = Tab:AddLeftGroupbox("Configuration")
        local configNameInput = ConfigBox:AddInput("Law_ConfigName", { Text = "Config Name", Default = "default", Placeholder = "my config" })
        local configListDropdown = ConfigBox:AddDropdown("Law_ConfigList", { Text = "Saved Configs", Values = Library:ListConfigs(), Default = nil })

        ConfigBox:AddButton("Refresh List", function()
            configListDropdown:SetValues(Library:ListConfigs())
        end)

        ConfigBox:AddButton("Save Config", function()
            local name = Library.Flags["Law_ConfigName"]
            if name and name ~= "" then
                Library:SaveConfig(name)
                configListDropdown:SetValues(Library:ListConfigs())
            end
        end)

        ConfigBox:AddButton("Load Config", function()
            local name = Library.Flags["Law_ConfigList"] or Library.Flags["Law_ConfigName"]
            if name and name ~= "" then
                Library:LoadConfig(name)
            end
        end)

        ConfigBox:AddButton("Delete Config", function()
            local name = Library.Flags["Law_ConfigList"]
            if name and name ~= "" then
                Library:DeleteConfig(name)
                configListDropdown:SetValues(Library:ListConfigs())
            end
        end)

        ConfigBox:AddDivider()

        local autoloadToggle = ConfigBox:AddToggle("Law_AutoloadEnabled", {
            Text = "Enable Autoload",
            Default = Library:GetAutoload() ~= nil,
            Callback = function(value)
                if value then
                    local name = Library.Flags["Law_ConfigList"] or Library.Flags["Law_ConfigName"]
                    if name and name ~= "" then
                        Library:SetAutoload(name)
                    end
                else
                    Library:RemoveAutoload()
                end
            end
        })

        ConfigBox:AddButton("Set Current Config As Autoload", function()
            local name = Library.Flags["Law_ConfigList"] or Library.Flags["Law_ConfigName"]
            if name and name ~= "" then
                Library:SetAutoload(name)
                Library.Toggles["Law_AutoloadEnabled"]:SetValue(true)
            end
        end)

        ConfigBox:AddButton("Remove Autoload", function()
            Library:RemoveAutoload()
            Library.Toggles["Law_AutoloadEnabled"]:SetValue(false)
        end)

        local ThemeBox = Tab:AddRightGroupbox("Theme")
        local themeNames = {}
        for themeName in pairs(Library.Themes) do
            table.insert(themeNames, themeName)
        end

        local themeDropdown = ThemeBox:AddDropdown("Law_Theme", {
            Text = "Selected Theme",
            Values = themeNames,
            Default = Library.SelectedTheme,
            Callback = function(value)
                Library:SetTheme(value)
            end
        })

        ThemeBox:AddDivider()
        ThemeBox:AddLabel("Create Custom Theme")

        local customName = ThemeBox:AddInput("Law_CustomThemeName", { Text = "Theme Name", Default = "Custom", Placeholder = "My Theme" })
        local accentInput = ThemeBox:AddInput("Law_CustomAccent", { Text = "Accent (hex)", Default = "5879FF", Placeholder = "5879FF" })
        local backgroundInput = ThemeBox:AddInput("Law_CustomBackground", { Text = "Background (hex)", Default = "121216", Placeholder = "121216" })
        local foregroundInput = ThemeBox:AddInput("Law_CustomForeground", { Text = "Foreground (hex)", Default = "1A1A1F", Placeholder = "1A1A1F" })
        local elementInput = ThemeBox:AddInput("Law_CustomElement", { Text = "Element (hex)", Default = "212127", Placeholder = "212127" })
        local outlineInput = ThemeBox:AddInput("Law_CustomOutline", { Text = "Outline (hex)", Default = "2D2D34", Placeholder = "2D2D34" })
        local textInput = ThemeBox:AddInput("Law_CustomText", { Text = "Text (hex)", Default = "EBEBF0", Placeholder = "EBEBF0" })

        ThemeBox:AddButton("Create And Apply Custom Theme", function()
            local name = Library.Flags["Law_CustomThemeName"]
            if not name or name == "" then
                return
            end
            local colors = {
                Accent = HexToColor3(Library.Flags["Law_CustomAccent"]) or Library.Theme.Accent,
                Background = HexToColor3(Library.Flags["Law_CustomBackground"]) or Library.Theme.Background,
                Foreground = HexToColor3(Library.Flags["Law_CustomForeground"]) or Library.Theme.Foreground,
                ElementBackground = HexToColor3(Library.Flags["Law_CustomElement"]) or Library.Theme.ElementBackground,
                Outline = HexToColor3(Library.Flags["Law_CustomOutline"]) or Library.Theme.Outline,
                Text = HexToColor3(Library.Flags["Law_CustomText"]) or Library.Theme.Text,
                SubText = Library.Theme.SubText
            }
            Library:CreateCustomTheme(name, colors)
            local names = {}
            for themeName in pairs(Library.Themes) do
                table.insert(names, themeName)
            end
            themeDropdown:SetValues(names)
            themeDropdown:SetValue(name)
        end)

        return Tab
    end

    Window.SettingsTab = BuildSettingsTab()

    local autoloadName = Library:GetAutoload()
    if autoloadName then
        Library:LoadConfig(autoloadName)
    end

    return Window
end

return Library
