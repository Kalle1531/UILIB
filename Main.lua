local TweenS   = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local Run      = game:GetService("RunService")
local Players  = game:GetService("Players")
local Http     = game:GetService("HttpService")

local LP        = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════
--  LIBRARY
-- ══════════════════════════════════════════════════════════════════
local Nexus       = {}
Nexus.__index     = Nexus
Nexus.Version     = "2.0"
Nexus.ConfigFolder= "NexusUI"

-- ══════════════════════════════════════════════════════════════════
--  BUILT-IN THEMES
-- ══════════════════════════════════════════════════════════════════
Nexus.Themes = {

    Dark = {
        Window      = Color3.fromRGB(14,  14,  18),
        Sidebar     = Color3.fromRGB(20,  20,  26),
        TitleBar    = Color3.fromRGB(20,  20,  26),
        ElementBG   = Color3.fromRGB(26,  26,  34),
        ElementHover= Color3.fromRGB(34,  34,  44),
        InputBG     = Color3.fromRGB(20,  20,  28),
        DropdownBG  = Color3.fromRGB(22,  22,  30),
        Accent      = Color3.fromRGB(110, 140, 255),
        AccentDark  = Color3.fromRGB(80,  105, 210),
        Border      = Color3.fromRGB(40,  40,  55),
        TextPrimary = Color3.fromRGB(235, 235, 250),
        TextSecond  = Color3.fromRGB(130, 130, 155),
        TextMuted   = Color3.fromRGB(75,  75,  100),
        SliderBG    = Color3.fromRGB(36,  36,  48),
        ToggleOff   = Color3.fromRGB(50,  50,  68),
        ScrollBar   = Color3.fromRGB(110, 140, 255),
        Success     = Color3.fromRGB(72,  199, 116),
        Warning     = Color3.fromRGB(255, 190, 55),
        Error       = Color3.fromRGB(255, 75,  75),
        Info        = Color3.fromRGB(110, 140, 255),
    },

    Midnight = {
        Window      = Color3.fromRGB(8,   10,  20),
        Sidebar     = Color3.fromRGB(12,  15,  28),
        TitleBar    = Color3.fromRGB(12,  15,  28),
        ElementBG   = Color3.fromRGB(16,  20,  36),
        ElementHover= Color3.fromRGB(22,  26,  46),
        InputBG     = Color3.fromRGB(12,  15,  28),
        DropdownBG  = Color3.fromRGB(14,  18,  32),
        Accent      = Color3.fromRGB(80,  120, 255),
        AccentDark  = Color3.fromRGB(55,  90,  210),
        Border      = Color3.fromRGB(28,  35,  60),
        TextPrimary = Color3.fromRGB(220, 225, 255),
        TextSecond  = Color3.fromRGB(100, 115, 165),
        TextMuted   = Color3.fromRGB(55,  65,  105),
        SliderBG    = Color3.fromRGB(22,  28,  50),
        ToggleOff   = Color3.fromRGB(35,  42,  75),
        ScrollBar   = Color3.fromRGB(80,  120, 255),
        Success     = Color3.fromRGB(60,  190, 110),
        Warning     = Color3.fromRGB(255, 185, 45),
        Error       = Color3.fromRGB(240, 65,  65),
        Info        = Color3.fromRGB(80,  120, 255),
    },

    Light = {
        Window      = Color3.fromRGB(245, 245, 250),
        Sidebar     = Color3.fromRGB(232, 232, 240),
        TitleBar    = Color3.fromRGB(232, 232, 240),
        ElementBG   = Color3.fromRGB(255, 255, 255),
        ElementHover= Color3.fromRGB(240, 240, 248),
        InputBG     = Color3.fromRGB(238, 238, 246),
        DropdownBG  = Color3.fromRGB(250, 250, 255),
        Accent      = Color3.fromRGB(90,  120, 240),
        AccentDark  = Color3.fromRGB(65,  95,  210),
        Border      = Color3.fromRGB(208, 208, 222),
        TextPrimary = Color3.fromRGB(28,  28,  48),
        TextSecond  = Color3.fromRGB(100, 100, 130),
        TextMuted   = Color3.fromRGB(160, 160, 185),
        SliderBG    = Color3.fromRGB(218, 218, 232),
        ToggleOff   = Color3.fromRGB(190, 190, 210),
        ScrollBar   = Color3.fromRGB(90,  120, 240),
        Success     = Color3.fromRGB(38,  172, 88),
        Warning     = Color3.fromRGB(215, 148, 18),
        Error       = Color3.fromRGB(205, 50,  50),
        Info        = Color3.fromRGB(90,  120, 240),
    },

    Rose = {
        Window      = Color3.fromRGB(16,  12,  18),
        Sidebar     = Color3.fromRGB(22,  16,  26),
        TitleBar    = Color3.fromRGB(22,  16,  26),
        ElementBG   = Color3.fromRGB(28,  20,  34),
        ElementHover= Color3.fromRGB(36,  26,  44),
        InputBG     = Color3.fromRGB(20,  14,  24),
        DropdownBG  = Color3.fromRGB(22,  16,  28),
        Accent      = Color3.fromRGB(220, 100, 160),
        AccentDark  = Color3.fromRGB(180, 70,  128),
        Border      = Color3.fromRGB(52,  35,  62),
        TextPrimary = Color3.fromRGB(245, 230, 240),
        TextSecond  = Color3.fromRGB(160, 120, 150),
        TextMuted   = Color3.fromRGB(100, 70,  95),
        SliderBG    = Color3.fromRGB(38,  26,  48),
        ToggleOff   = Color3.fromRGB(60,  40,  72),
        ScrollBar   = Color3.fromRGB(220, 100, 160),
        Success     = Color3.fromRGB(80,  200, 130),
        Warning     = Color3.fromRGB(255, 195, 60),
        Error       = Color3.fromRGB(255, 80,  80),
        Info        = Color3.fromRGB(220, 100, 160),
    },
}

Nexus.Theme = Nexus.Themes.Dark

-- ══════════════════════════════════════════════════════════════════
--  THEME API
-- ══════════════════════════════════════════════════════════════════

--- Set a built-in theme by name ("Dark", "Midnight", "Light", "Rose")
function Nexus:SetTheme(name)
    assert(self.Themes[name], "[NexusUI] Unknown theme: " .. tostring(name))
    self.Theme = self.Themes[name]
end

--- Override specific theme keys without replacing the whole theme
function Nexus:CustomTheme(overrides)
    local base = {}
    for k, v in pairs(self.Theme) do base[k] = v end
    for k, v in pairs(overrides) do base[k] = v end
    self.Theme = base
end

-- ══════════════════════════════════════════════════════════════════
--  CONFIG / SAVE
-- ══════════════════════════════════════════════════════════════════

function Nexus:SaveConfig(key, data)
    pcall(function()
        if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
        writefile(self.ConfigFolder .. "/" .. key .. ".json", Http:JSONEncode(data))
    end)
end

function Nexus:LoadConfig(key)
    local ok, res = pcall(function()
        local path = self.ConfigFolder .. "/" .. key .. ".json"
        if isfile(path) then return Http:JSONDecode(readfile(path)) end
    end)
    return (ok and res) or {}
end

-- ══════════════════════════════════════════════════════════════════
--  PRIMITIVES
-- ══════════════════════════════════════════════════════════════════

local function Tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.22,
        style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenS:Create(obj, info, props)
    tw:Play()
    return tw
end

local function New(cls, p)
    local i = Instance.new(cls)
    for k, v in pairs(p or {}) do
        if k ~= "Parent" then i[k] = v end
    end
    if p and p.Parent then i.Parent = p.Parent end
    return i
end

local function Corner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or UDim.new(0, 7)
    c.Parent = p
end

local function Stroke(col, thick, p)
    local s = Instance.new("UIStroke")
    s.Color           = col   or Color3.new(1,1,1)
    s.Thickness       = thick or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = p
    return s
end

local function Pad(t, r, b, l, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.Parent        = p
end

local function List(p, gap, dir)
    local l = Instance.new("UIListLayout")
    l.SortOrder       = Enum.SortOrder.LayoutOrder
    l.Padding         = UDim.new(0, gap or 5)
    l.FillDirection   = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Left
    l.Parent          = p
    return l
end

local FB = Enum.Font.GothamBold
local FM = Enum.Font.GothamMedium
local FL = Enum.Font.Gotham

-- ══════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════════

local NotifGui = New("ScreenGui", {
    Name           = "NexusUI_Notifs",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent         = PlayerGui,
})

local NotifStack = New("Frame", {
    AnchorPoint            = Vector2.new(1, 1),
    Position               = UDim2.new(1, -18, 1, -18),
    Size                   = UDim2.new(0, 295, 1, -18),
    BackgroundTransparency = 1,
    Parent                 = NotifGui,
})
do
    local ll = Instance.new("UIListLayout")
    ll.SortOrder         = Enum.SortOrder.LayoutOrder
    ll.VerticalAlignment = Enum.VerticalAlignment.Bottom
    ll.Padding           = UDim.new(0, 8)
    ll.FillDirection     = Enum.FillDirection.Vertical
    ll.Parent            = NotifStack
end

local _nOrder = 0

function Nexus:Notify(cfg)
    cfg = cfg or {}
    local title   = cfg.Title       or "Notification"
    local body    = cfg.Description or ""
    local ntype   = cfg.Type        or "Info"
    local dur     = cfg.Duration    or 4
    _nOrder       = _nOrder + 1

    local T   = self.Theme
    local col = T.Info
    if ntype == "Success" then col = T.Success
    elseif ntype == "Warning" then col = T.Warning
    elseif ntype == "Error"   then col = T.Error end

    local card = New("Frame", {
        Name                   = "N".. _nOrder,
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundColor3       = T.Sidebar,
        ClipsDescendants       = true,
        LayoutOrder            = -_nOrder,
        BackgroundTransparency = 1,
        Parent                 = NotifStack,
    })
    Corner(UDim.new(0, 9), card)
    Stroke(T.Border, 1, card)

    -- Accent left strip
    New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = col,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = card,
    })
    Corner(UDim.new(0, 3), card)

    local inner = New("Frame", {
        Position               = UDim2.new(0, 3, 0, 0),
        Size                   = UDim2.new(1, -3, 1, 0),
        BackgroundTransparency = 1,
        Parent                 = card,
    })
    Pad(10, 14, 10, 12, inner)
    List(inner, 4)

    -- Type dot + label row
    local badgeRow = New("Frame", {
        Size                   = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        Parent                 = inner,
    })
    local dot = New("Frame", {
        Size             = UDim2.new(0, 5, 0, 5),
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = col,
        BorderSizePixel  = 0,
        Parent           = badgeRow,
    })
    Corner(UDim.new(1, 0), dot)
    New("TextLabel", {
        Position               = UDim2.new(0, 11, 0, 0),
        Size                   = UDim2.new(1, -11, 1, 0),
        BackgroundTransparency = 1,
        Text                   = ntype:upper(),
        TextColor3             = col,
        Font                   = FB,
        TextSize               = 9,
        TextXAlignment         = Enum.TextXAlignment.Left,
        Parent                 = badgeRow,
    })

    New("TextLabel", {
        Size                   = UDim2.new(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPrimary,
        Font                   = FB,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        Parent                 = inner,
    })

    if body ~= "" then
        New("TextLabel", {
            Size                   = UDim2.new(1, 0, 0, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text                   = body,
            TextColor3             = T.TextSecond,
            Font                   = FL,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            Parent                 = inner,
        })
    end

    -- Progress bar
    local pBG = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = inner,
    })
    Corner(UDim.new(0, 1), pBG)
    local pFill = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = col,
        BorderSizePixel  = 0,
        Parent           = pBG,
    })
    Corner(UDim.new(0, 1), pFill)

    Tw(card,  {BackgroundTransparency = 0}, 0.25)
    Tw(pFill, {Size = UDim2.new(0, 0, 1, 0)}, dur, Enum.EasingStyle.Linear)
    task.delay(dur, function()
        Tw(card, {BackgroundTransparency = 1}, 0.25)
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════════

function Nexus:CreateWindow(cfg)
    cfg         = cfg or {}
    local title     = cfg.Title     or "NexusUI"
    local subtitle  = cfg.Subtitle  or ""
    local icon      = cfg.Icon      or ""
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local cfgKey    = cfg.ConfigKey or title:gsub("%s+", "_")
    local winSize   = cfg.Size      or Vector2.new(580, 400)

    local T = self.Theme

    -- Kill any existing NexusUI window (re-execute cleanup)
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if g.Name:sub(1, 8) == "NexusUI_" and g ~= NotifGui then
            pcall(function()
                local m = g:FindFirstChild("Main")
                if m then
                    TweenS:Create(m, TweenInfo.new(0.18),
                        {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}):Play()
                end
            end)
            task.delay(0.21, function() g:Destroy() end)
        end
    end

    local saved = self:LoadConfig(cfgKey)

    -- ── Root ────────────────────────────────────────────────────────
    local Gui = New("ScreenGui", {
        Name           = "NexusUI_" .. title,
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = PlayerGui,
    })

    -- ── Shadow ──────────────────────────────────────────────────────
    local Shadow = New("ImageLabel", {
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 12),
        Size              = UDim2.new(0, winSize.X + 50, 0, winSize.Y + 50),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        Parent            = Gui,
    })

    -- ── Main frame ──────────────────────────────────────────────────
    local Main = New("Frame", {
        Name                   = "Main",
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(0, 0, 0, 0),
        BackgroundColor3       = T.Window,
        ClipsDescendants       = false,
        BackgroundTransparency = 1,
        Parent                 = Gui,
    })
    Corner(UDim.new(0, 10), Main)
    Stroke(T.Border, 1, Main)

    -- ── Title bar ───────────────────────────────────────────────────
    local TitleBar = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.TitleBar,
        ZIndex           = 2,
        Parent           = Main,
    })
    Corner(UDim.new(0, 10), TitleBar)
    -- Square off bottom half of title bar
    New("Frame", {
        Position         = UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = T.TitleBar,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = TitleBar,
    })
    -- Bottom divider line
    New("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })
    -- Accent top line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = TitleBar,
    })
    Corner(UDim.new(0, 10), TitleBar:GetChildren()[4] or TitleBar)

    Pad(0, 18, 0, 18, TitleBar)

    if icon ~= "" then
        New("ImageLabel", {
            Size                   = UDim2.new(0, 20, 0, 20),
            AnchorPoint            = Vector2.new(0, 0.5),
            Position               = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image                  = icon,
            ZIndex                 = 3,
            Parent                 = TitleBar,
        })
    end

    New("TextLabel", {
        AnchorPoint            = Vector2.new(0, 0.5),
        Position               = icon ~= "" and UDim2.new(0, 26, 0.5, 0) or UDim2.new(0, 0, 0.5, 0),
        Size                   = UDim2.new(0.55, 0, 0, 18),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPrimary,
        Font                   = FB,
        TextSize               = 14,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 3,
        Parent                 = TitleBar,
    })

    if subtitle ~= "" then
        New("TextLabel", {
            AnchorPoint            = Vector2.new(1, 0.5),
            Position               = UDim2.new(1, 0, 0.5, 0),
            Size                   = UDim2.new(0.44, 0, 0, 14),
            BackgroundTransparency = 1,
            Text                   = subtitle,
            TextColor3             = T.TextMuted,
            Font                   = FL,
            TextSize               = 11,
            TextXAlignment         = Enum.TextXAlignment.Right,
            ZIndex                 = 3,
            Parent                 = TitleBar,
        })
    end

    -- ── Body ────────────────────────────────────────────────────────
    local Body = New("Frame", {
        Position               = UDim2.new(0, 0, 0, 52),
        Size                   = UDim2.new(1, 0, 1, -52),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = Main,
    })

    -- ── Sidebar ─────────────────────────────────────────────────────
    local SW = 140
    local Sidebar = New("Frame", {
        Size             = UDim2.new(0, SW, 1, 0),
        BackgroundColor3 = T.Sidebar,
        Parent           = Body,
    })
    -- Top patch (square off top corners since title bar is above)
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })
    Corner(UDim.new(0, 10), Sidebar)
    -- Right border
    New("Frame", {
        AnchorPoint      = Vector2.new(1, 0),
        Position         = UDim2.new(1, 0, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        Parent           = Sidebar,
    })

    local TabList = New("Frame", {
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = Sidebar,
    })
    Pad(14, 8, 10, 8, TabList)
    List(TabList, 3)

    -- ── Content area ────────────────────────────────────────────────
    local Content = New("Frame", {
        Position               = UDim2.new(0, SW, 0, 0),
        Size                   = UDim2.new(1, -SW, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants       = true,
        Parent                 = Body,
    })

    -- ── Drag ────────────────────────────────────────────────────────
    local dragging, dStart, dOrigin
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dStart   = inp.Position
            dOrigin  = Main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dStart
            Main.Position   = UDim2.new(dOrigin.X.Scale, dOrigin.X.Offset + d.X,
                                        dOrigin.Y.Scale, dOrigin.Y.Offset + d.Y)
            Shadow.Position = UDim2.new(dOrigin.X.Scale, dOrigin.X.Offset + d.X,
                                        dOrigin.Y.Scale, dOrigin.Y.Offset + d.Y + 12)
        end
    end)

    -- ── Open animation ──────────────────────────────────────────────
    task.defer(function()
        Tw(Main,   {Size = UDim2.new(0, winSize.X, 0, winSize.Y), BackgroundTransparency = 0},
           0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tw(Shadow, {ImageTransparency = 0.52}, 0.4)
    end)

    -- ── Toggle visibility ───────────────────────────────────────────
    local visible = true
    local function toggleVis()
        visible = not visible
        if visible then
            Main.Visible   = true
            Shadow.Visible = true
            Tw(Main,   {Size = UDim2.new(0, winSize.X, 0, winSize.Y), BackgroundTransparency = 0},
               0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tw(Shadow, {ImageTransparency = 0.52}, 0.35)
        else
            Tw(Main,   {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.28)
            Tw(Shadow, {ImageTransparency = 1}, 0.28)
            task.wait(0.32)
            if not visible then Main.Visible = false; Shadow.Visible = false end
        end
    end

    -- ── Window object ───────────────────────────────────────────────
    local Win     = setmetatable({}, {__index = Nexus})
    Win._tabs     = {}
    Win._active   = nil
    Win._cfgKey   = cfgKey
    Win._saved    = saved
    Win._elems    = {}
    Win._conns    = {}
    Win._gui      = Gui
    Win._theme    = T

    local kc = UIS.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == toggleKey then toggleVis() end
    end)
    table.insert(Win._conns, kc)

    function Win:Destroy()
        for _, c in ipairs(self._conns) do pcall(function() c:Disconnect() end) end
        Gui:Destroy()
    end

    function Win:SaveAll()
        local data = {}
        for k, e in pairs(self._elems) do
            if e.GetValue then
                local v = e:GetValue()
                data[k] = typeof(v) == "EnumItem" and v.Name or v
            end
        end
        Nexus:SaveConfig(self._cfgKey, data)
    end

    -- ════════════════════════════════════════════════════════════════
    --  CREATE TAB
    -- ════════════════════════════════════════════════════════════════

    function Win:CreateTab(name, tabIcon)
        name    = name    or "Tab"
        tabIcon = tabIcon or ""

        -- Sidebar button
        local Btn = New("TextButton", {
            Size                   = UDim2.new(1, 0, 0, 34),
            BackgroundColor3       = T.ElementBG,
            BackgroundTransparency = 1,
            Text                   = "",
            AutoButtonColor        = false,
            Parent                 = TabList,
        })
        Corner(UDim.new(0, 7), Btn)

        local BtnInner = New("Frame", {
            Size                   = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent                 = Btn,
        })
        Pad(0, 10, 0, 10, BtnInner)
        do
            local ll = Instance.new("UIListLayout")
            ll.FillDirection     = Enum.FillDirection.Horizontal
            ll.VerticalAlignment = Enum.VerticalAlignment.Center
            ll.Padding           = UDim.new(0, 7)
            ll.SortOrder         = Enum.SortOrder.LayoutOrder
            ll.Parent            = BtnInner
        end

        if tabIcon ~= "" then
            New("ImageLabel", {
                Size                   = UDim2.new(0, 15, 0, 15),
                BackgroundTransparency = 1,
                Image                  = tabIcon,
                ImageColor3            = T.TextSecond,
                LayoutOrder            = 1,
                Parent                 = BtnInner,
            })
        end

        local BtnLbl = New("TextLabel", {
            Size                   = UDim2.new(1, tabIcon ~= "" and -22 or 0, 1, 0),
            BackgroundTransparency = 1,
            Text                   = name,
            TextColor3             = T.TextSecond,
            Font                   = FM,
            TextSize               = 12,
            TextXAlignment         = Enum.TextXAlignment.Left,
            LayoutOrder            = 2,
            Parent                 = BtnInner,
        })

        -- Active left pill
        local Pill = New("Frame", {
            Size                   = UDim2.new(0, 3, 0.55, 0),
            AnchorPoint            = Vector2.new(0, 0.5),
            Position               = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3       = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ZIndex                 = 2,
            Parent                 = Btn,
        })
        Corner(UDim.new(1, 0), Pill)

        -- Scroll content frame
        local Scroll = New("ScrollingFrame", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 2,
            ScrollBarImageColor3 = T.ScrollBar,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            ClipsDescendants     = true,
            Parent               = Content,
        })
        Pad(12, 14, 12, 14, Scroll)
        List(Scroll, 7)

        local function activate(tab)
            if Win._active and Win._active ~= tab then
                local p = Win._active
                Tw(p._btn,   {BackgroundTransparency = 1}, 0.18)
                Tw(p._label, {TextColor3 = T.TextSecond}, 0.18)
                Tw(p._pill,  {BackgroundTransparency = 1}, 0.18)
                p._scroll.Visible = false
            end
            Win._active = tab
            Tw(Btn,    {BackgroundTransparency = 0}, 0.18)
            Tw(BtnLbl, {TextColor3 = T.TextPrimary}, 0.18)
            Tw(Pill,   {BackgroundTransparency = 0}, 0.18)
            Scroll.Visible = true
        end

        Btn.MouseButton1Click:Connect(function() activate(Tab) end)
        Btn.MouseEnter:Connect(function()
            if Win._active ~= Tab then Tw(Btn, {BackgroundTransparency = 0.72}, 0.15) end
        end)
        Btn.MouseLeave:Connect(function()
            if Win._active ~= Tab then Tw(Btn, {BackgroundTransparency = 1}, 0.15) end
        end)

        local Tab = { _btn = Btn, _label = BtnLbl, _pill = Pill, _scroll = Scroll }
        if #Win._tabs == 0 then activate(Tab) end
        table.insert(Win._tabs, Tab)

        -- ── Element row base ─────────────────────────────────────────
        local function ERow(txt, h)
            local f = New("Frame", {
                Size             = UDim2.new(1, 0, 0, h or 38),
                BackgroundColor3 = T.ElementBG,
                Parent           = Scroll,
            })
            Corner(UDim.new(0, 7), f)
            Stroke(T.Border, 1, f)
            Pad(0, 12, 0, 12, f)

            New("TextLabel", {
                Size                   = UDim2.new(0.58, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = txt,
                TextColor3             = T.TextPrimary,
                Font                   = FM,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                Parent                 = f,
            })

            f.MouseEnter:Connect(function() Tw(f, {BackgroundColor3 = T.ElementHover}, 0.14) end)
            f.MouseLeave:Connect(function() Tw(f, {BackgroundColor3 = T.ElementBG}, 0.14) end)
            return f
        end

        -- ════════════════════════════════════════════════════════════
        --  SECTION
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateSection(sTitle)
            local sec = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Parent                 = Scroll,
            })
            New("TextLabel", {
                Size                   = UDim2.new(1, -60, 1, 0),
                BackgroundTransparency = 1,
                Text                   = sTitle:upper(),
                TextColor3             = T.Accent,
                Font                   = FB,
                TextSize               = 9,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = sec,
            })
            New("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0.5, 0, 0, 1),
                BackgroundColor3 = T.Border,
                BorderSizePixel  = 0,
                Parent           = sec,
            })
        end

        -- ════════════════════════════════════════════════════════════
        --  LABEL
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateLabel(cfg2)
            cfg2 = cfg2 or {}
            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text                   = cfg2.Text or "",
                TextColor3             = T.TextSecond,
                Font                   = FL,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                Parent                 = Scroll,
            })
        end

        -- ════════════════════════════════════════════════════════════
        --  BUTTON
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateButton(cfg2)
            cfg2 = cfg2 or {}
            local lbl  = cfg2.Name        or "Button"
            local desc = cfg2.Description or ""
            local cb   = cfg2.Callback    or function() end

            local f = ERow(lbl, desc ~= "" and 52 or 38)

            if desc ~= "" then
                New("TextLabel", {
                    Size                   = UDim2.new(0.58, 0, 0, 14),
                    Position               = UDim2.new(0, 12, 0, 22),
                    BackgroundTransparency = 1,
                    Text                   = desc,
                    TextColor3             = T.TextMuted,
                    Font                   = FL,
                    TextSize               = 10,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    Parent                 = f,
                })
            end

            local execBtn = New("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 66, 0, 24),
                BackgroundColor3 = T.Accent,
                Text             = "Run",
                TextColor3       = Color3.new(1, 1, 1),
                Font             = FB,
                TextSize         = 11,
                AutoButtonColor  = false,
                Parent           = f,
            })
            Corner(UDim.new(0, 5), execBtn)

            execBtn.MouseEnter:Connect(function() Tw(execBtn, {BackgroundColor3 = T.AccentDark}, 0.14) end)
            execBtn.MouseLeave:Connect(function() Tw(execBtn, {BackgroundColor3 = T.Accent},     0.14) end)

            local db = false
            execBtn.MouseButton1Click:Connect(function()
                if db then return end
                db = true
                Tw(execBtn, {BackgroundColor3 = T.AccentDark, Size = UDim2.new(0, 62, 0, 22)}, 0.1)
                pcall(cb)
                task.wait(0.13)
                Tw(execBtn, {BackgroundColor3 = T.Accent,     Size = UDim2.new(0, 66, 0, 24)}, 0.14)
                task.wait(0.1); db = false
            end)

            return { _type = "Button",
                SetValue = function() end,
                GetValue = function() return nil end }
        end

        -- ════════════════════════════════════════════════════════════
        --  TOGGLE
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateToggle(cfg2)
            cfg2 = cfg2 or {}
            local lbl     = cfg2.Name     or "Toggle"
            local key     = cfg2.Key      or lbl
            local default = cfg2.Default
            local cb      = cfg2.Callback or function() end

            if Win._saved[key] ~= nil then default = Win._saved[key] end
            if default == nil then default = false end

            local f = ERow(lbl)

            local track = New("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 42, 0, 22),
                BackgroundColor3 = T.ToggleOff,
                Parent           = f,
            })
            Corner(UDim.new(1, 0), track)

            local thumb = New("Frame", {
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0, 3, 0.5, 0),
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex           = 3,
                Parent           = track,
            })
            Corner(UDim.new(1, 0), thumb)

            -- Gloss sheen on thumb
            New("Frame", {
                Size             = UDim2.new(1, 0, 0.5, 0),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.7,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = thumb,
            })
            Corner(UDim.new(1, 0), thumb:GetChildren()[2])

            local val = default
            local function apply(v, anim)
                val = v
                local d = anim and 0.2 or 0
                Tw(track, {BackgroundColor3 = v and T.Accent or T.ToggleOff}, d)
                Tw(thumb, {Position = v and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, d)
            end
            apply(val, false)

            local ca = New("TextButton", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = "",
                ZIndex                 = 5,
                Parent                 = f,
            })
            ca.MouseButton1Click:Connect(function()
                apply(not val, true); pcall(cb, val); Win:SaveAll()
            end)

            local elem = { _type = "Toggle", _key = key }
            Win._elems[key] = elem
            function elem:SetValue(v) apply(v, true); pcall(cb, val) end
            function elem:GetValue() return val end
            return elem
        end

        -- ════════════════════════════════════════════════════════════
        --  SLIDER
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateSlider(cfg2)
            cfg2 = cfg2 or {}
            local lbl     = cfg2.Name     or "Slider"
            local key     = cfg2.Key      or lbl
            local min     = cfg2.Min      or 0
            local max     = cfg2.Max      or 100
            local step    = cfg2.Step     or 1
            local suffix  = cfg2.Suffix   or ""
            local default = cfg2.Default  or min
            local cb      = cfg2.Callback or function() end

            if Win._saved[key] ~= nil then default = Win._saved[key] end
            default = math.clamp(default, min, max)

            local f = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 54),
                BackgroundColor3 = T.ElementBG,
                Parent           = Scroll,
            })
            Corner(UDim.new(0, 7), f)
            Stroke(T.Border, 1, f)
            Pad(8, 12, 8, 12, f)
            f.MouseEnter:Connect(function() Tw(f, {BackgroundColor3 = T.ElementHover}, 0.14) end)
            f.MouseLeave:Connect(function() Tw(f, {BackgroundColor3 = T.ElementBG},    0.14) end)

            local topRow = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Parent                 = f,
            })
            New("TextLabel", {
                Size                   = UDim2.new(0.62, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = lbl,
                TextColor3             = T.TextPrimary,
                Font                   = FM,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = topRow,
            })
            local valLbl = New("TextLabel", {
                AnchorPoint            = Vector2.new(1, 0),
                Position               = UDim2.new(1, 0, 0, 0),
                Size                   = UDim2.new(0.38, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = tostring(default) .. suffix,
                TextColor3             = T.Accent,
                Font                   = FB,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Right,
                Parent                 = topRow,
            })

            -- Rail
            local rail = New("Frame", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 6),
                BackgroundColor3 = T.SliderBG,
                Parent           = f,
            })
            Corner(UDim.new(1, 0), rail)

            local fill = New("Frame", {
                Size             = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = T.Accent,
                Parent           = rail,
            })
            Corner(UDim.new(1, 0), fill)

            -- Knob
            local knob = New("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(0, 0, 0.5, 0),
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex           = 3,
                Parent           = rail,
            })
            Corner(UDim.new(1, 0), knob)
            New("UIStroke", {Color = T.Accent, Thickness = 2, Parent = knob})
            local knobDot = New("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(0.5, 0, 0.5, 0),
                Size             = UDim2.new(0, 6, 0, 6),
                BackgroundColor3 = T.Accent,
                ZIndex           = 4,
                Parent           = knob,
            })
            Corner(UDim.new(1, 0), knobDot)

            local val = default
            local function applyVal(v, anim)
                v   = math.round(v / step) * step
                v   = math.clamp(v, min, max)
                val = v
                local pct = (v - min) / math.max(max - min, 1)
                local d   = anim and 0.06 or 0
                Tw(fill, {Size = UDim2.new(pct, 0, 1, 0)}, d)
                Tw(knob, {Position = UDim2.new(pct, 0, 0.5, 0)}, d)
                valLbl.Text = tostring(v) .. suffix
            end
            applyVal(val, false)

            local sliding = false
            rail.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    local pct = math.clamp((inp.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
                    applyVal(min + pct * (max - min), true)
                    pcall(cb, val)
                end
            end)

            local sc = UIS.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement
                             or inp.UserInputType == Enum.UserInputType.Touch) then
                    local pct = math.clamp((inp.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
                    applyVal(min + pct * (max - min), false)
                    pcall(cb, val)
                end
            end)
            local ec = UIS.InputEnded:Connect(function(inp)
                if (inp.UserInputType == Enum.UserInputType.MouseButton1
                 or inp.UserInputType == Enum.UserInputType.Touch) and sliding then
                    sliding = false; Win:SaveAll()
                end
            end)
            table.insert(Win._conns, sc)
            table.insert(Win._conns, ec)

            local elem = { _type = "Slider", _key = key }
            Win._elems[key] = elem
            function elem:SetValue(v) applyVal(v, true); pcall(cb, val) end
            function elem:GetValue() return val end
            return elem
        end

        -- ════════════════════════════════════════════════════════════
        --  INPUT
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateInput(cfg2)
            cfg2 = cfg2 or {}
            local lbl         = cfg2.Name        or "Input"
            local key         = cfg2.Key         or lbl
            local placeholder = cfg2.Placeholder or "Type here..."
            local cb          = cfg2.Callback    or function() end

            local f = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = T.ElementBG,
                Parent           = Scroll,
            })
            Corner(UDim.new(0, 7), f)
            Stroke(T.Border, 1, f)
            Pad(8, 12, 8, 12, f)
            f.MouseEnter:Connect(function() Tw(f, {BackgroundColor3 = T.ElementHover}, 0.14) end)
            f.MouseLeave:Connect(function() Tw(f, {BackgroundColor3 = T.ElementBG},    0.14) end)

            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text                   = lbl,
                TextColor3             = T.TextPrimary,
                Font                   = FM,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = f,
            })

            local iBG = New("Frame", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = T.InputBG,
                Parent           = f,
            })
            Corner(UDim.new(0, 5), iBG)
            local iStroke = Stroke(T.Border, 1, iBG)

            local box = New("TextBox", {
                Size              = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text              = "",
                PlaceholderText   = placeholder,
                PlaceholderColor3 = T.TextMuted,
                TextColor3        = T.TextPrimary,
                Font              = FM,
                TextSize          = 12,
                TextXAlignment    = Enum.TextXAlignment.Left,
                ClearTextOnFocus  = false,
                Parent            = iBG,
            })
            Pad(0, 10, 0, 10, box)

            box.Focused:Connect(function()
                Tw(iBG,     {BackgroundColor3 = T.ElementHover}, 0.14)
                Tw(iStroke, {Color = T.Accent}, 0.14)
            end)
            box.FocusLost:Connect(function()
                Tw(iBG,     {BackgroundColor3 = T.InputBG}, 0.14)
                Tw(iStroke, {Color = T.Border}, 0.14)
                pcall(cb, box.Text); Win:SaveAll()
            end)

            local elem = { _type = "Input", _key = key }
            Win._elems[key] = elem
            function elem:SetValue(v) box.Text = tostring(v) end
            function elem:GetValue() return box.Text end
            return elem
        end

        -- ════════════════════════════════════════════════════════════
        --  DROPDOWN
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateDropdown(cfg2)
            cfg2 = cfg2 or {}
            local lbl     = cfg2.Name     or "Dropdown"
            local key     = cfg2.Key      or lbl
            local opts    = cfg2.Options  or {}
            local default = cfg2.Default  or (opts[1] or "")
            local cb      = cfg2.Callback or function() end

            if Win._saved[key] ~= nil then default = Win._saved[key] end

            local f = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = T.ElementBG,
                Parent           = Scroll,
            })
            Corner(UDim.new(0, 7), f)
            Stroke(T.Border, 1, f)
            Pad(8, 12, 8, 12, f)
            f.MouseEnter:Connect(function() Tw(f, {BackgroundColor3 = T.ElementHover}, 0.14) end)
            f.MouseLeave:Connect(function() Tw(f, {BackgroundColor3 = T.ElementBG},    0.14) end)

            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text                   = lbl,
                TextColor3             = T.TextPrimary,
                Font                   = FM,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                Parent                 = f,
            })

            local dBtn = New("TextButton", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundColor3 = T.InputBG,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 4,
                Parent           = f,
            })
            Corner(UDim.new(0, 5), dBtn)
            Stroke(T.Border, 1, dBtn)

            local selLbl = New("TextLabel", {
                Size                   = UDim2.new(1, -28, 1, 0),
                BackgroundTransparency = 1,
                Text                   = tostring(default),
                TextColor3             = T.TextPrimary,
                Font                   = FM,
                TextSize               = 12,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 5,
                Parent                 = dBtn,
            })
            Pad(0, 0, 0, 10, selLbl)

            local arrow = New("TextLabel", {
                AnchorPoint            = Vector2.new(1, 0.5),
                Position               = UDim2.new(1, -8, 0.5, 0),
                Size                   = UDim2.new(0, 12, 0, 12),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = T.TextSecond,
                Font                   = FB,
                TextSize               = 13,
                ZIndex                 = 5,
                Parent                 = dBtn,
            })

            -- Overlay list (parented to Gui — bypasses all clipping)
            local dList = New("ScrollingFrame", {
                Position             = UDim2.new(0, 0, 0, 0),
                Size                 = UDim2.new(0, 0, 0, 0),
                BackgroundColor3     = T.DropdownBG,
                ClipsDescendants     = true,
                ZIndex               = 60,
                Visible              = false,
                BorderSizePixel      = 0,
                ScrollBarThickness   = 2,
                ScrollBarImageColor3 = T.ScrollBar,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ScrollingDirection   = Enum.ScrollingDirection.Y,
                Parent               = Gui,
            })
            Corner(UDim.new(0, 7), dList)
            Stroke(T.Border, 1, dList)
            List(dList, 0)

            -- Track button position every frame
            local trkC = Run.RenderStepped:Connect(function()
                if not dBtn.Parent then return end
                local ap = dBtn.AbsolutePosition
                local as = dBtn.AbsoluteSize
                local lH = dList.AbsoluteSize.Y
                local sH = Gui.AbsoluteSize.Y
                local posY = (sH - (ap.Y + as.Y + 4) >= math.max(lH, 60))
                    and (ap.Y + as.Y + 4) or (ap.Y - lH - 4)
                dList.Position = UDim2.new(0, ap.X, 0, posY)
                dList.Size     = UDim2.new(0, as.X, 0, dList.Size.Y.Offset)
            end)
            table.insert(Win._conns, trkC)

            local isOpen = false
            local value  = default

            local function closeDD()
                isOpen = false
                Tw(dList, {Size = UDim2.new(0, dList.Size.X.Offset, 0, 0)}, 0.18)
                Tw(arrow,  {Rotation = 0}, 0.18)
                task.delay(0.2, function() dList.Visible = false end)
            end

            local function buildOpts()
                for _, c in ipairs(dList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, opt in ipairs(opts) do
                    local sel = (opt == value)
                    local ob  = New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = sel and T.ElementHover or T.DropdownBG,
                        Text             = "",
                        AutoButtonColor  = false,
                        ZIndex           = 61,
                        Parent           = dList,
                    })

                    if sel then
                        local dot = New("Frame", {
                            Size             = UDim2.new(0, 4, 0, 4),
                            AnchorPoint      = Vector2.new(0, 0.5),
                            Position         = UDim2.new(0, 10, 0.5, 0),
                            BackgroundColor3 = T.Accent,
                            BorderSizePixel  = 0,
                            ZIndex           = 62,
                            Parent           = ob,
                        })
                        Corner(UDim.new(1, 0), dot)
                    end

                    New("TextLabel", {
                        Size                   = UDim2.new(1, -30, 1, 0),
                        Position               = UDim2.new(0, sel and 22 or 12, 0, 0),
                        BackgroundTransparency = 1,
                        Text                   = tostring(opt),
                        TextColor3             = sel and T.Accent or T.TextPrimary,
                        Font                   = sel and FB or FM,
                        TextSize               = 12,
                        TextXAlignment         = Enum.TextXAlignment.Left,
                        ZIndex                 = 62,
                        Parent                 = ob,
                    })

                    ob.MouseEnter:Connect(function()
                        if opt ~= value then Tw(ob, {BackgroundColor3 = T.ElementHover}, 0.1) end
                    end)
                    ob.MouseLeave:Connect(function()
                        if opt ~= value then Tw(ob, {BackgroundColor3 = T.DropdownBG}, 0.1) end
                    end)
                    ob.MouseButton1Click:Connect(function()
                        value = opt; selLbl.Text = tostring(opt)
                        closeDD(); buildOpts()
                        pcall(cb, value); Win:SaveAll()
                    end)
                end
            end
            buildOpts()

            dBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local as = dBtn.AbsoluteSize
                    dList.Size    = UDim2.new(0, as.X, 0, 0)
                    dList.Visible = true
                    Tw(dList,  {Size = UDim2.new(0, as.X, 0, math.min(#opts * 28, 140))}, 0.2)
                    Tw(arrow,  {Rotation = 180}, 0.2)
                else
                    closeDD()
                end
            end)

            local elem = { _type = "Dropdown", _key = key }
            Win._elems[key] = elem
            function elem:SetValue(v) value = v; selLbl.Text = tostring(v); buildOpts(); pcall(cb, v) end
            function elem:GetValue() return value end
            function elem:SetOptions(o) opts = o; buildOpts() end
            return elem
        end

        -- ════════════════════════════════════════════════════════════
        --  KEYBIND
        -- ════════════════════════════════════════════════════════════
        function Tab:CreateKeybind(cfg2)
            cfg2 = cfg2 or {}
            local lbl     = cfg2.Name     or "Keybind"
            local key     = cfg2.Key      or lbl
            local default = cfg2.Default  or Enum.KeyCode.Unknown
            local cb      = cfg2.Callback or function() end

            if Win._saved[key] then
                pcall(function() default = Enum.KeyCode[Win._saved[key]] end)
            end

            local f = ERow(lbl)

            local binding   = default
            local listening = false

            local kBtn = New("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 88, 0, 24),
                BackgroundColor3 = T.InputBG,
                Text             = binding.Name,
                TextColor3       = T.TextPrimary,
                Font             = FM,
                TextSize         = 11,
                AutoButtonColor  = false,
                Parent           = f,
            })
            Corner(UDim.new(0, 5), kBtn)
            local kStroke = Stroke(T.Border, 1, kBtn)

            kBtn.MouseButton1Click:Connect(function()
                listening  = true
                kBtn.Text  = "Press key..."
                Tw(kBtn,    {BackgroundColor3 = T.ElementHover}, 0.14)
                Tw(kStroke, {Color = T.Accent}, 0.14)
            end)

            local lc = UIS.InputBegan:Connect(function(inp, gpe)
                if not listening then
                    if inp.KeyCode == binding then pcall(cb) end
                    return
                end
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening  = false
                    binding    = inp.KeyCode
                    kBtn.Text  = binding.Name
                    Tw(kBtn,    {BackgroundColor3 = T.InputBG}, 0.14)
                    Tw(kStroke, {Color = T.Border}, 0.14)
                    Win:SaveAll()
                end
            end)
            table.insert(Win._conns, lc)

            local elem = { _type = "Keybind", _key = key }
            Win._elems[key] = elem
            function elem:SetValue(v) binding = v; kBtn.Text = v.Name end
            function elem:GetValue() return binding end
            return elem
        end

        return Tab
    end -- CreateTab

    return Win
end -- CreateWindow

-- ══════════════════════════════════════════════════════════════════
return Nexus
