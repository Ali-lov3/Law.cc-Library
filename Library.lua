local Law = {}
Law.__index = Law

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Icons = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Orvez83/IconFinder/refs/heads/main/Icons/Lucide-Icons.lua"
))()

local C = {
    BG      = Color3.fromRGB(14, 14, 18),
    SIDEBAR = Color3.fromRGB(10, 10, 14),
    PANEL   = Color3.fromRGB(18, 18, 24),
    SECTION = Color3.fromRGB(20, 20, 28),
    ELEMENT = Color3.fromRGB(30, 30, 42),
    ACCENT  = Color3.fromRGB(215, 50, 50),
    ACCENT2 = Color3.fromRGB(170, 35, 35),
    BORDER  = Color3.fromRGB(35, 35, 50),
    TXT     = Color3.fromRGB(230, 230, 240),
    TXT2    = Color3.fromRGB(120, 120, 140),
    WHITE   = Color3.fromRGB(255, 255, 255),
}

local TF = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function Rnd(p, r)  New("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = p }) end
local function Brdr(p, c, t) New("UIStroke", { Color = c or C.BORDER, Thickness = t or 1, Parent = p }) end
local function Tw(o, t)   TweenService:Create(o, TF, t):Play() end

local function Img(parent, name, size, color)
    local asset = Icons[name]
    if asset then
        return New("ImageLabel", {
            Size = UDim2.new(0, size or 16, 0, size or 16),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image = asset,
            ImageColor3 = color or C.TXT2,
            Parent = parent,
        })
    else
        return New("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = color or C.TXT2,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            Parent = parent,
        })
    end
end

local function RadioDot(parent, active)
    local ring = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Rnd(ring, 8)
    local stroke = Brdr(ring, active and C.ACCENT or C.TXT2, 1.5)
    local dot = New("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel = 0,
        Visible = active,
        Parent = ring,
    })
    Rnd(dot, 4)
    local s = ring:FindFirstChildWhichIsA("UIStroke")
    return { Ring = ring, Dot = dot, Stroke = s }
end

local function MakeToggle(parent, default, callback)
    local state = default or false
    local track = New("Frame", {
        Size = UDim2.new(0, 36, 0, 18),
        Position = UDim2.new(1, -38, 0.5, -9),
        BackgroundColor3 = state and C.ACCENT or C.ELEMENT,
        BorderSizePixel = 0,
        Parent = parent,
    })
    Rnd(track, 9)
    local knob = New("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
        BackgroundColor3 = C.WHITE,
        BorderSizePixel = 0,
        Parent = track,
    })
    Rnd(knob, 6)
    local hb = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = parent,
    })
    hb.MouseButton1Click:Connect(function()
        state = not state
        Tw(track, { BackgroundColor3 = state and C.ACCENT or C.ELEMENT })
        Tw(knob, { Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) })
        callback(state)
    end)
    local el = {}
    function el:Get() return state end
    function el:Set(v)
        state = v
        Tw(track, { BackgroundColor3 = state and C.ACCENT or C.ELEMENT })
        Tw(knob, { Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) })
        callback(state)
    end
    return el
end

local function MakeSlider(parent, name, min, max, default, callback)
    local val = math.clamp(default or min, min, max)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local nameLbl = New("TextLabel", {
        Size = UDim2.new(0.52, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.TXT2,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local bar = New("Frame", {
        Size = UDim2.new(0.35, 0, 0, 3),
        Position = UDim2.new(0.52, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.ELEMENT,
        BorderSizePixel = 0,
        Parent = row,
    })
    Rnd(bar, 2)
    local fill = New("Frame", {
        Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel = 0,
        Parent = bar,
    })
    Rnd(fill, 2)
    local dot = New("Frame", {
        Size = UDim2.new(0, 10, 0, 10),
        Position = UDim2.new((val - min) / (max - min), -5, 0.5, -5),
        BackgroundColor3 = C.WHITE,
        BorderSizePixel = 0,
        Parent = bar,
    })
    Rnd(dot, 5)
    local valLbl = New("TextLabel", {
        Size = UDim2.new(0.1, 0, 1, 0),
        Position = UDim2.new(0.89, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(val),
        TextColor3 = C.TXT,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    local sliding = false
    local function upd(x)
        local frac = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        val = math.floor(min + frac * (max - min) + 0.5)
        local f = (val - min) / (max - min)
        fill.Size = UDim2.new(f, 0, 1, 0)
        dot.Position = UDim2.new(f, -5, 0.5, -5)
        valLbl.Text = tostring(val)
        callback(val)
    end
    local hb = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 10),
        Position = UDim2.new(0, 0, 0, -5),
        BackgroundTransparency = 1,
        Text = "",
        Parent = bar,
    })
    hb.MouseButton1Down:Connect(function(x) sliding = true; upd(x) end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    local el = {}
    function el:Get() return val end
    function el:Set(v)
        val = math.clamp(v, min, max)
        local f = (val - min) / (max - min)
        fill.Size = UDim2.new(f, 0, 1, 0)
        dot.Position = UDim2.new(f, -5, 0.5, -5)
        valLbl.Text = tostring(val)
        callback(val)
    end
    return el
end

local function MakeDropdown(parent, name, opts, default, callback)
    local sel = default or opts[1] or ""
    local isOpen = false
    local wrap = New("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = parent,
    })
    local nameLbl = New("TextLabel", {
        Size = UDim2.new(0.42, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.TXT2,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap,
    })
    local dropBtn = New("TextButton", {
        Size = UDim2.new(0.56, 0, 0, 20),
        Position = UDim2.new(0.43, 0, 0.5, -10),
        BackgroundColor3 = C.ELEMENT,
        BorderSizePixel = 0,
        Text = "",
        Parent = wrap,
    })
    Rnd(dropBtn, 4)
    Brdr(dropBtn)
    local selLbl = New("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = sel,
        TextColor3 = C.TXT,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dropBtn,
    })
    local arrowBox = New("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -16, 0.5, -6),
        BackgroundTransparency = 1,
        Parent = dropBtn,
    })
    Img(arrowBox, "chevron-down", 11, C.TXT2)
    local listFrame = New("Frame", {
        Size = UDim2.new(1, 0, 0, #opts * 22),
        Position = UDim2.new(0, 0, 1, 2),
        BackgroundColor3 = C.ELEMENT,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 30,
        Visible = false,
        Parent = dropBtn,
    })
    Rnd(listFrame, 4)
    Brdr(listFrame)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })
    for _, opt in ipairs(opts) do
        local ob = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = C.TXT2,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 30,
            Parent = listFrame,
        })
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = ob })
        ob.MouseEnter:Connect(function() ob.TextColor3 = C.TXT end)
        ob.MouseLeave:Connect(function() ob.TextColor3 = C.TXT2 end)
        ob.MouseButton1Click:Connect(function()
            sel = opt; selLbl.Text = opt
            isOpen = false; listFrame.Visible = false
            callback(sel)
        end)
    end
    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
    end)
    local el = {}
    function el:Get() return sel end
    function el:Set(v) sel = v; selLbl.Text = v; callback(v) end
    return el
end

local function BuildSectionAPI(items)
    local sec = {}

    function sec:AddToggle(cfg)
        cfg = cfg or {}
        local row = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = items,
        })
        local lbl = New("TextLabel", {
            Size = UDim2.new(0.6, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = cfg.Name or "Toggle",
            TextColor3 = C.TXT2,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        if cfg.Gear then
            local gh = New("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.6, 2, 0.5, -7),
                BackgroundTransparency = 1,
                Parent = row,
            })
            Img(gh, "settings", 13, C.TXT2)
        end
        return MakeToggle(row, cfg.Default or false, cfg.Callback or function() end)
    end

    function sec:AddSlider(cfg)
        cfg = cfg or {}
        return MakeSlider(items, cfg.Name or "Slider", cfg.Min or 0, cfg.Max or 100, cfg.Default or 0, cfg.Callback or function() end)
    end

    function sec:AddDropdown(cfg)
        cfg = cfg or {}
        return MakeDropdown(items, cfg.Name or "Dropdown", cfg.Options or {}, cfg.Default, cfg.Callback or function() end)
    end

    function sec:AddButton(cfg)
        cfg = cfg or {}
        local btn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel = 0,
            Text = cfg.Name or "Button",
            TextColor3 = C.WHITE,
            TextSize = 11,
            Font = Enum.Font.GothamSemibold,
            Parent = items,
        })
        Rnd(btn, 5)
        btn.MouseEnter:Connect(function() Tw(btn, { BackgroundColor3 = Color3.fromRGB(235, 65, 65) }) end)
        btn.MouseLeave:Connect(function() Tw(btn, { BackgroundColor3 = C.ACCENT }) end)
        btn.MouseButton1Down:Connect(function() Tw(btn, { BackgroundColor3 = C.ACCENT2 }) end)
        btn.MouseButton1Up:Connect(function() Tw(btn, { BackgroundColor3 = C.ACCENT }) end)
        btn.MouseButton1Click:Connect(cfg.Callback or function() end)
    end

    function sec:AddLabel(cfg)
        cfg = type(cfg) == "string" and { Text = cfg } or (cfg or {})
        New("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = cfg.Text or "",
            TextColor3 = cfg.Color or C.TXT2,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = items,
        })
    end

    return sec
end

local function BuildSection(col, cfg)
    cfg = cfg or {}
    local sName   = cfg.Name or "Section"
    local subTabs = cfg.Tabs

    local box = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.SECTION,
        BorderSizePixel = 0,
        Parent = col,
    })
    Rnd(box, 6)
    Brdr(box)

    if subTabs and #subTabs > 0 then
        local headRow = New("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Parent = box,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0),
            Parent = headRow,
        })

        local div = New("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 31),
            BackgroundColor3 = C.BORDER,
            BorderSizePixel = 0,
            Parent = box,
        })

        local stContainer = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 33),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = box,
        })

        local stBtns   = {}
        local stFrames = {}

        for i, stName in ipairs(subTabs) do
            local stBtn = New("TextButton", {
                Size = UDim2.new(0, 0, 0, 28),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = stName,
                TextColor3 = i == 1 and C.TXT or C.TXT2,
                TextSize = 11,
                Font = Enum.Font.GothamSemibold,
                Parent = headRow,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 4),
                Parent = stBtn,
            })
            local underline = New("Frame", {
                Size = UDim2.new(1, -24, 0, 2),
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 1, 0),
                BackgroundColor3 = C.ACCENT,
                BorderSizePixel = 0,
                Visible = i == 1,
                Parent = stBtn,
            })
            Rnd(underline, 1)

            local stItems = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Visible = i == 1,
                Parent = stContainer,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = stItems,
            })
            New("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = stItems,
            })

            table.insert(stBtns,   { Btn = stBtn, Under = underline })
            table.insert(stFrames, stItems)

            local idx = i
            stBtn.MouseButton1Click:Connect(function()
                for j, d in ipairs(stBtns) do
                    d.Btn.TextColor3  = C.TXT2
                    d.Under.Visible   = false
                    stFrames[j].Visible = false
                end
                stBtn.TextColor3      = C.TXT
                underline.Visible     = true
                stItems.Visible       = true
            end)
        end

        local sec = {}
        for i, stName in ipairs(subTabs) do
            sec[stName] = BuildSectionAPI(stFrames[i])
        end
        return sec

    else
        local headRow = New("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = box,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6),
            Parent = headRow,
        })
        New("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = headRow })

        if cfg.Icon and Icons[cfg.Icon] then
            local ih = New("Frame", {
                Size = UDim2.new(0, 13, 0, 13),
                BackgroundTransparency = 1,
                Parent = headRow,
            })
            Img(ih, cfg.Icon, 13, C.ACCENT)
        end

        New("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = sName,
            TextColor3 = C.TXT,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = headRow,
        })

        New("Frame", {
            Size = UDim2.new(1, -20, 0, 1),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundColor3 = C.BORDER,
            BorderSizePixel = 0,
            Parent = box,
        })

        local items = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 31),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = box,
        })
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = items })
        New("UIPadding", {
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = items,
        })

        return BuildSectionAPI(items)
    end
end

function Law:CreateWindow(cfg)
    cfg = cfg or {}
    local title    = cfg.Title     or "Law.cc"
    local subtitle = cfg.Subtitle  or ""
    local logo     = cfg.Logo      or string.sub(title, 1, 2):upper()
    local logoIcon = cfg.LogoIcon
    local wSize    = cfg.Size      or UDim2.new(0, 650, 0, 460)

    local gui = New("ScreenGui", {
        Name = "LawCC", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = game:GetService("CoreGui"),
    })

    local openBtn = New("TextButton", {
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 12, 0.5, -21),
        BackgroundColor3 = C.ACCENT, BorderSizePixel = 0,
        Text = "", ZIndex = 20, Visible = false, Parent = gui,
    })
    Rnd(openBtn, 8)
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = logo, TextColor3 = C.WHITE, TextSize = 13,
        Font = Enum.Font.GothamBold, ZIndex = 21, Parent = openBtn,
    })

    local root = New("Frame", {
        Name = "Root", Size = wSize,
        Position = UDim2.new(0.5, -wSize.X.Offset / 2, 0.5, -wSize.Y.Offset / 2),
        BackgroundColor3 = C.BG, BorderSizePixel = 0,
        ClipsDescendants = true, Parent = gui,
    })
    Rnd(root, 8)
    Brdr(root)

    local drag, dragS, posS
    root.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; dragS = i.Position; posS = root.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragS
            root.Position = UDim2.new(posS.X.Scale, posS.X.Offset + d.X, posS.Y.Scale, posS.Y.Offset + d.Y)
        end
    end)

    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel = 0,
        Parent = root,
    })
    New("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel = 0,
        Parent = sidebar,
    })

    local logoBox = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = logo,
        TextColor3 = C.WHITE,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        Parent = logoBox,
    })

    local navList = New("Frame", {
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = navList,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = navList,
    })

    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundColor3 = C.PANEL,
        BorderSizePixel = 0,
        Parent = root,
    })

    local topBar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel = 0,
        Parent = content,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel = 0,
        Parent = topBar,
    })

    local titleLbl = New("TextLabel", {
        Size = UDim2.new(1, -48, 0, 18),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.TXT,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })
    local subLbl = New("TextLabel", {
        Size = UDim2.new(1, -48, 0, 13),
        Position = UDim2.new(0, 12, 0, 28),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = C.TXT2,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar,
    })

    local xBtn = New("TextButton", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -30, 0, 14),
        BackgroundColor3 = C.ELEMENT,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = C.TXT2,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = topBar,
    })
    Rnd(xBtn, 4)
    xBtn.MouseButton1Click:Connect(function() root.Visible = false; openBtn.Visible = true end)
    openBtn.MouseButton1Click:Connect(function() root.Visible = true; openBtn.Visible = false end)

    local tabRow = New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel = 0,
        Parent = content,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = C.BORDER,
        BorderSizePixel = 0,
        Parent = tabRow,
    })

    local tabHolder = New("Frame", {
        Size = UDim2.new(1, 0, 1, -86),
        Position = UDim2.new(0, 0, 0, 86),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = content,
    })

    local win = {
        Gui = gui, Root = root,
        NavList = navList, TabRow = tabRow, TabHolder = tabHolder,
        TitleLbl = titleLbl, SubLbl = subLbl,
        Pages = {},
    }

    function win:CreatePage(pc)
        pc = pc or {}
        local pName = pc.Name     or "Page"
        local pSub  = pc.Subtitle or ""
        local pIcon = pc.Icon

        local navBtn = New("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            Parent = navList,
        })

        local indicator = New("Frame", {
            Size = UDim2.new(0, 3, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel = 0,
            Visible = false,
            Parent = navBtn,
        })
        Rnd(indicator, 2)

        local iconHolder = New("Frame", {
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = navBtn,
        })
        local navImg = Img(iconHolder, pIcon or "square", 18, C.TXT2)

        local innerTabScroll = New("ScrollingFrame", {
            Size = UDim2.new(1, -14, 1, 0),
            Position = UDim2.new(0, 7, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            Visible = false,
            Parent = tabRow,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2),
            Parent = innerTabScroll,
        })

        local pageFrame = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = tabHolder,
        })

        local page = {
            NavBtn = navBtn, Indicator = indicator,
            Frame = pageFrame, TabScrollFrame = innerTabScroll,
            Name = pName, Subtitle = pSub, Tabs = {},
        }

        function page:CreateTab(tc)
            tc = tc or {}
            local tName = tc.Name or "Tab"

            local tBtn = New("TextButton", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = "",
                Parent = innerTabScroll,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 12),
                Parent = tBtn,
            })

            local tInner = New("Frame", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Parent = tBtn,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 7),
                Parent = tInner,
            })

            local rdHolder = New("Frame", {
                Size = UDim2.new(0, 11, 0, 11),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Parent = tInner,
            })
            local rdData = RadioDot(rdHolder, false)

            local tLbl = New("TextLabel", {
                Size = UDim2.new(0, 0, 1, 0),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = tName,
                TextColor3 = C.TXT2,
                TextSize = 11,
                Font = Enum.Font.GothamSemibold,
                Parent = tInner,
            })

            local tContent = New("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = C.ACCENT,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false,
                Parent = pageFrame,
            })
            New("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                Parent = tContent,
            })

            local cols = New("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = tContent,
            })

            local leftCol = New("Frame", {
                Size = UDim2.new(0.5, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = cols,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = leftCol,
            })

            local rightCol = New("Frame", {
                Size = UDim2.new(0.5, -5, 0, 0),
                Position = UDim2.new(0.5, 5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = cols,
            })
            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                Parent = rightCol,
            })

            local tab = { Btn = tBtn, Content = tContent, L = leftCol, R = rightCol, Lbl = tLbl, Rd = rdData }

            function tab:CreateSection(sc)
                sc = sc or {}
                local col = (sc.Side == "Right") and rightCol or leftCol
                return BuildSection(col, sc)
            end

            table.insert(page.Tabs, tab)

            local function activateTab(t)
                for _, tt in pairs(page.Tabs) do
                    tt.Content.Visible = false
                    tt.Lbl.TextColor3  = C.TXT2
                    if tt.Rd then
                        tt.Rd.Dot.Visible = false
                        if tt.Rd.Stroke then tt.Rd.Stroke.Color = C.TXT2 end
                    end
                end
                t.Content.Visible = true
                t.Lbl.TextColor3  = C.TXT
                if t.Rd then
                    t.Rd.Dot.Visible = true
                    if t.Rd.Stroke then t.Rd.Stroke.Color = C.ACCENT end
                end
            end

            tBtn.MouseButton1Click:Connect(function() activateTab(tab) end)

            if #page.Tabs == 1 then activateTab(tab) end

            return tab
        end

        table.insert(win.Pages, page)

        local function activatePage(p)
            for _, pp in pairs(win.Pages) do
                pp.Frame.Visible          = false
                pp.Indicator.Visible      = false
                pp.TabScrollFrame.Visible = false
            end
            p.Frame.Visible          = true
            p.Indicator.Visible      = true
            p.TabScrollFrame.Visible = true
            titleLbl.Text = p.Name
            subLbl.Text   = p.Subtitle
            win.ActivePage = p
        end

        navBtn.MouseButton1Click:Connect(function() activatePage(page) end)

        if #win.Pages == 1 then activatePage(page) end

        return page
    end

    return win
end

return Law
