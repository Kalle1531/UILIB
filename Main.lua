--[[
    NexusUI Library v1.0
    A full-featured Roblox Lua UI Library
    Inspired by Rayfield — built from scratch.

    Usage:
        local NexusUI = loadstring(game:HttpGet("..."))()
        local Window = NexusUI:CreateWindow({ Title = "My App", Subtitle = "v1.0" })
        local Tab = Window:CreateTab("Main", "rbxassetid://...")
        Tab:CreateButton({ Name = "Click Me", Callback = function() end })
--]]

-- ────────────────────────────────────────────────
--  Services
-- ────────────────────────────────────────────────
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────
--  Library Table
-- ────────────────────────────────────────────────
local NexusUI = {}
NexusUI.__index = NexusUI

-- ────────────────────────────────────────────────
--  Default Theme
-- ────────────────────────────────────────────────
NexusUI.Theme = {
    Background        = Color3.fromRGB(15,  15,  20),
    SecondaryBG       = Color3.fromRGB(22,  22,  30),
    TertiaryBG        = Color3.fromRGB(30,  30,  40),
    Accent            = Color3.fromRGB(100, 130, 255),
    AccentDark        = Color3.fromRGB(70,  95,  200),
    TextPrimary       = Color3.fromRGB(240, 240, 255),
    TextSecondary     = Color3.fromRGB(150, 150, 170),
    Border            = Color3.fromRGB(45,  45,  60),
    Shadow            = Color3.fromRGB(0,   0,   0),
    Success           = Color3.fromRGB(80,  200, 120),
    Warning           = Color3.fromRGB(255, 190, 60),
    Error             = Color3.fromRGB(255, 80,  80),
    ElementBG         = Color3.fromRGB(28,  28,  38),
    ElementHover      = Color3.fromRGB(38,  38,  52),
    ToggleOff         = Color3.fromRGB(55,  55,  75),
    SliderFill        = Color3.fromRGB(100, 130, 255),
    SliderBG          = Color3.fromRGB(40,  40,  55),
    CornerRadius      = UDim.new(0, 8),
    SmallCorner       = UDim.new(0, 5),
    Font              = Enum.Font.GothamMedium,
    FontBold          = Enum.Font.GothamBold,
    FontLight         = Enum.Font.Gotham,
}

-- ────────────────────────────────────────────────
--  Config / Save System
-- ────────────────────────────────────────────────
NexusUI.ConfigFolder = "NexusUI_Configs"
NexusUI._configs     = {}  -- { [windowKey] = { [elementKey] = value } }

local function ensureFolder(folder)
    if not isfolder(folder) then
        makefolder(folder)
    end
end

local function configPath(windowKey)
    return NexusUI.ConfigFolder .. "/" .. windowKey .. ".json"
end

function NexusUI:SaveConfig(windowKey, data)
    pcall(function()
        ensureFolder(NexusUI.ConfigFolder)
        writefile(configPath(windowKey), HttpService:JSONEncode(data))
    end)
end

function NexusUI:LoadConfig(windowKey)
    local ok, result = pcall(function()
        if isfile(configPath(windowKey)) then
            return HttpService:JSONDecode(readfile(configPath(windowKey)))
        end
    end)
    return (ok and result) or {}
end

-- ────────────────────────────────────────────────
--  Tween Helper
-- ────────────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.25, style, direction)
    local tw   = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- ────────────────────────────────────────────────
--  UI Helper — create an Instance with properties
-- ────────────────────────────────────────────────
local function New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or NexusUI.Theme.CornerRadius
    c.Parent = parent
    return c
end

local function Stroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color     = color     or NexusUI.Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Padding(top, right, bottom, left, parent)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = parent
    return p
end

local function ListLayout(parent, spacing, fillDir, halign)
    local l = Instance.new("UIListLayout")
    l.SortOrder       = Enum.SortOrder.LayoutOrder
    l.Padding         = UDim.new(0, spacing or 4)
    l.FillDirection   = fillDir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.Parent = parent
    return l
end

-- ────────────────────────────────────────────────
--  Notification System
-- ────────────────────────────────────────────────
local NotifGui = New("ScreenGui", {
    Name = "NexusUI_Notifs",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui,
})

local NotifHolder = New("Frame", {
    Name = "NotifHolder",
    AnchorPoint = Vector2.new(1, 1),
    Position    = UDim2.new(1, -16, 1, -16),
    Size        = UDim2.new(0, 280, 1, -16),
    BackgroundTransparency = 1,
    Parent = NotifGui,
})

New("UIListLayout", {
    SortOrder    = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding      = UDim.new(0, 8),
    FillDirection = Enum.FillDirection.Vertical,
    Parent = NotifHolder,
})

local notifOrder = 0

function NexusUI:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notification"
    local desc     = config.Description or ""
    local ntype    = config.Type     or "Info"  -- Info / Success / Warning / Error
    local duration = config.Duration or 4

    notifOrder += 1

    local accentColor = NexusUI.Theme.Accent
    if ntype == "Success" then accentColor = NexusUI.Theme.Success
    elseif ntype == "Warning" then accentColor = NexusUI.Theme.Warning
    elseif ntype == "Error"   then accentColor = NexusUI.Theme.Error
    end

    local card = New("Frame", {
        Name              = "Notif_" .. notifOrder,
        Size              = UDim2.new(1, 0, 0, 0),
        AutomaticSize     = Enum.AutomaticSize.Y,
        BackgroundColor3  = NexusUI.Theme.SecondaryBG,
        ClipsDescendants  = true,
        LayoutOrder       = -notifOrder,
        Parent = NotifHolder,
    })
    Corner(NexusUI.Theme.SmallCorner, card)
    Stroke(NexusUI.Theme.Border, 1, card)

    -- left accent bar
    New("Frame", {
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Parent = card,
    })
    Corner(UDim.new(0, 3), card)

    local inner = New("Frame", {
        Size             = UDim2.new(1, -3, 1, 0),
        Position         = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Parent = card,
    })
    Padding(10, 12, 10, 12, inner)
    ListLayout(inner, 3)

    New("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 16),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = NexusUI.Theme.TextPrimary,
        Font             = NexusUI.Theme.FontBold,
        TextSize         = 13,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        Parent = inner,
    })

    if desc ~= "" then
        New("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text             = desc,
            TextColor3       = NexusUI.Theme.TextSecondary,
            Font             = NexusUI.Theme.FontLight,
            TextSize         = 12,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            Parent = inner,
        })
    end

    -- progress bar
    local progBG = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = NexusUI.Theme.Border,
        BorderSizePixel  = 0,
        Parent = inner,
    })
    Corner(UDim.new(0, 1), progBG)

    local progFill = New("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Parent = progBG,
    })
    Corner(UDim.new(0, 1), progFill)

    -- slide in
    card.BackgroundTransparency = 1
    Tween(card, {BackgroundTransparency = 0}, 0.3)

    -- countdown
    Tween(progFill, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Tween(card, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.35)
        card:Destroy()
    end)
end

-- ────────────────────────────────────────────────
--  WINDOW
-- ────────────────────────────────────────────────
function NexusUI:CreateWindow(config)
    config = config or {}
    local title     = config.Title     or "NexusUI"
    local subtitle  = config.Subtitle  or ""
    local icon      = config.Icon      or ""
    local keybind   = config.ToggleKey or Enum.KeyCode.RightShift
    local configKey = config.ConfigKey or (title:gsub("%s", "_"))

    -- ── Destroy any previous NexusUI windows ────
    -- Cleans up old instances so re-executing the script replaces the UI
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name:sub(1, 8) == "NexusUI_" and gui ~= NotifGui then
            -- Disconnect signal: fire a fake "closing" tween then destroy
            pcall(function()
                local m = gui:FindFirstChild("Main")
                if m then
                    TweenService:Create(m, TweenInfo.new(0.2), {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):Play()
                end
            end)
            task.delay(0.22, function() gui:Destroy() end)
        end
    end

    local savedConfig = self:LoadConfig(configKey)

    -- ── Root ScreenGui ──────────────────────────
    local ScreenGui = New("ScreenGui", {
        Name             = "NexusUI_" .. title,
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        Parent           = PlayerGui,
    })

    -- ── Shadow (imitation) ──────────────────────
    local Shadow = New("ImageLabel", {
        Name             = "Shadow",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 8),
        Size             = UDim2.new(0, 580, 0, 400),
        BackgroundTransparency = 1,
        Image            = "rbxassetid://6014261993",
        ImageColor3      = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType        = Enum.ScaleType.Slice,
        SliceCenter      = Rect.new(49, 49, 450, 450),
        Parent           = ScreenGui,
    })

    -- ── Main Frame ──────────────────────────────
    local Main = New("Frame", {
        Name             = "Main",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 560, 0, 380),
        BackgroundColor3 = NexusUI.Theme.Background,
        ClipsDescendants = false,
        Parent           = ScreenGui,
    })
    Corner(NexusUI.Theme.CornerRadius, Main)
    Stroke(NexusUI.Theme.Border, 1, Main)

    -- ── Title Bar ───────────────────────────────
    local TitleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = NexusUI.Theme.SecondaryBG,
        ZIndex           = 2,
        Parent           = Main,
    })
    Corner(NexusUI.Theme.CornerRadius, TitleBar)
    -- Patch bottom of titlebar (so only top corners are rounded)
    New("Frame", {
        Size             = UDim2.new(1, 0, 0.5, 0),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = NexusUI.Theme.SecondaryBG,
        BorderSizePixel  = 0,
        Parent           = TitleBar,
    })

    Padding(0, 16, 0, 16, TitleBar)

    if icon ~= "" then
        New("ImageLabel", {
            Size             = UDim2.new(0, 22, 0, 22),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Image            = icon,
            Parent           = TitleBar,
        })
    end

    New("TextLabel", {
        Name             = "Title",
        AnchorPoint      = Vector2.new(0, 0.5),
        Position         = icon ~= "" and UDim2.new(0, 28, 0.5, 0) or UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(0.5, 0, 0, 20),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = NexusUI.Theme.TextPrimary,
        Font             = NexusUI.Theme.FontBold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    if subtitle ~= "" then
        New("TextLabel", {
            Name             = "Subtitle",
            AnchorPoint      = Vector2.new(1, 0.5),
            Position         = UDim2.new(1, 0, 0.5, 0),
            Size             = UDim2.new(0.45, 0, 0, 16),
            BackgroundTransparency = 1,
            Text             = subtitle,
            TextColor3       = NexusUI.Theme.TextSecondary,
            Font             = NexusUI.Theme.FontLight,
            TextSize         = 12,
            TextXAlignment   = Enum.TextXAlignment.Right,
            ZIndex           = 3,
            Parent           = TitleBar,
        })
    end

    -- ── Body ────────────────────────────────────
    local Body = New("Frame", {
        Name             = "Body",
        Position         = UDim2.new(0, 0, 0, 50),
        Size             = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Main,
    })

    -- ── Sidebar ─────────────────────────────────
    local Sidebar = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 130, 1, 0),
        BackgroundColor3 = NexusUI.Theme.SecondaryBG,
        Parent           = Body,
    })
    -- patch top of sidebar
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 4),
        BackgroundColor3 = NexusUI.Theme.SecondaryBG,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = Sidebar,
    })
    Corner(UDim.new(0, 8), Sidebar)

    local TabList = New("Frame", {
        Name             = "TabList",
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Sidebar,
    })
    Padding(10, 8, 10, 8, TabList)
    ListLayout(TabList, 4)

    -- ── Content Area ────────────────────────────
    local ContentArea = New("Frame", {
        Name             = "ContentArea",
        Position         = UDim2.new(0, 130, 0, 0),
        Size             = UDim2.new(1, -130, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = Body,
    })

    -- ── Separator line ──────────────────────────
    New("Frame", {
        Position         = UDim2.new(0, 130, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = NexusUI.Theme.Border,
        BorderSizePixel  = 0,
        Parent           = Body,
    })

    -- ────────────────────────────────────────────
    --  Dragging
    -- ────────────────────────────────────────────
    local dragging, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        Shadow.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y + 8
        )
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)

    -- ────────────────────────────────────────────
    --  Open / Close Animation
    -- ────────────────────────────────────────────
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.BackgroundTransparency = 1
    Shadow.ImageTransparency = 1

    task.defer(function()
        Tween(Main,   {Size = UDim2.new(0, 560, 0, 380), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(Shadow, {ImageTransparency = 0.5}, 0.4)
    end)

    local visible = true
    local function toggleVisibility()
        visible = not visible
        if visible then
            Main.Visible  = true
            Shadow.Visible = true
            Tween(Main,   {Size = UDim2.new(0, 560, 0, 380), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            Tween(Shadow, {ImageTransparency = 0.5}, 0.35)
        else
            Tween(Main,   {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(Shadow, {ImageTransparency = 1}, 0.3)
            task.wait(0.35)
            if not visible then
                Main.Visible   = false
                Shadow.Visible = false
            end
        end
    end

    local keybindConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == keybind then
            toggleVisibility()
        end
    end)

    -- ────────────────────────────────────────────
    --  Window Object
    -- ────────────────────────────────────────────
    local Window = setmetatable({}, {__index = NexusUI})
    Window._tabs        = {}
    Window._activeTab   = nil
    Window._configKey   = configKey
    Window._savedConfig = savedConfig
    Window._connections = { keybindConn }
    Window._elements    = {}

    function Window:Destroy()
        for _, conn in ipairs(self._connections) do
            conn:Disconnect()
        end
        ScreenGui:Destroy()
    end

    function Window:SaveAllConfigs()
        local data = {}
        for k, elem in pairs(self._elements) do
            if elem.GetValue then
                data[k] = elem:GetValue()
            end
        end
        NexusUI:SaveConfig(self._configKey, data)
    end

    -- ────────────────────────────────────────────
    --  CreateTab
    -- ────────────────────────────────────────────
    function Window:CreateTab(name, tabIcon)
        name    = name    or "Tab"
        tabIcon = tabIcon or ""

        -- Sidebar button
        local TabBtn = New("TextButton", {
            Name             = "Tab_" .. name,
            Size             = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = NexusUI.Theme.TertiaryBG,
            BackgroundTransparency = 1,
            Text             = "",
            AutoButtonColor  = false,
            Parent           = TabList,
        })
        Corner(NexusUI.Theme.SmallCorner, TabBtn)
        Padding(0, 8, 0, 8, TabBtn)

        local tabInner = New("Frame", {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent           = TabBtn,
        })
        New("UIListLayout", {
            FillDirection    = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding          = UDim.new(0, 6),
            SortOrder        = Enum.SortOrder.LayoutOrder,
            Parent           = tabInner,
        })

        if tabIcon ~= "" then
            New("ImageLabel", {
                Size             = UDim2.new(0, 16, 0, 16),
                BackgroundTransparency = 1,
                Image            = tabIcon,
                ImageColor3      = NexusUI.Theme.TextSecondary,
                LayoutOrder      = 1,
                Parent           = tabInner,
            })
        end

        local TabLabel = New("TextLabel", {
            Size             = UDim2.new(1, tabIcon ~= "" and -22 or 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = NexusUI.Theme.TextSecondary,
            Font             = NexusUI.Theme.Font,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = 2,
            Parent           = tabInner,
        })

        -- Active indicator
        local Indicator = New("Frame", {
            Size             = UDim2.new(0, 3, 0.7, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            Position         = UDim2.new(0, -8, 0.5, 0),
            BackgroundColor3 = NexusUI.Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            Parent           = TabBtn,
        })
        Corner(UDim.new(0, 2), Indicator)

        -- Scroll + content frame
        local ScrollFrame = New("ScrollingFrame", {
            Name             = "Content_" .. name,
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = NexusUI.Theme.Accent,
            CanvasSize       = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible          = false,
            ClipsDescendants = true,
            Parent           = ContentArea,
        })
        Padding(10, 12, 10, 12, ScrollFrame)
        ListLayout(ScrollFrame, 8)

        local function activateTab(tab)
            -- Deactivate current
            if Window._activeTab and Window._activeTab ~= tab then
                local prev = Window._activeTab
                Tween(prev._btn,   {BackgroundTransparency = 1}, 0.2)
                Tween(prev._label, {TextColor3 = NexusUI.Theme.TextSecondary}, 0.2)
                Tween(prev._indicator, {BackgroundTransparency = 1}, 0.2)
                prev._scroll.Visible = false
            end
            Window._activeTab = tab
            Tween(TabBtn,    {BackgroundTransparency = 0}, 0.2)
            Tween(TabLabel,  {TextColor3 = NexusUI.Theme.TextPrimary}, 0.2)
            Tween(Indicator, {BackgroundTransparency = 0}, 0.2)
            ScrollFrame.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            activateTab(Tab)
        end)
        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 0.6}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        -- ────────────────────────────────────────
        --  Tab Object
        -- ────────────────────────────────────────
        local Tab = {}
        Tab._btn       = TabBtn
        Tab._label     = TabLabel
        Tab._indicator = Indicator
        Tab._scroll    = ScrollFrame
        Tab._window    = Window

        -- Auto-activate first tab
        if #Window._tabs == 0 then
            activateTab(Tab)
        end
        table.insert(Window._tabs, Tab)

        -- ── Shared element creation helpers ──────

        local function makeElementBase(labelText)
            local frame = New("Frame", {
                Name             = labelText,
                Size             = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = NexusUI.Theme.ElementBG,
                Parent           = ScrollFrame,
            })
            Corner(NexusUI.Theme.SmallCorner, frame)
            Stroke(NexusUI.Theme.Border, 1, frame)
            Padding(0, 10, 0, 10, frame)

            local label = New("TextLabel", {
                Size             = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = labelText,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = frame,
            })

            -- hover
            frame.MouseEnter:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.15)
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementBG}, 0.15)
            end)

            return frame, label
        end

        -- ── CreateSection ─────────────────────────
        function Tab:CreateSection(sectionTitle)
            local sec = New("Frame", {
                Name             = "Section_" .. sectionTitle,
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                LayoutOrder      = 0,
                Parent           = ScrollFrame,
            })

            New("TextLabel", {
                Size             = UDim2.new(1, -50, 1, 0),
                BackgroundTransparency = 1,
                Text             = sectionTitle:upper(),
                TextColor3       = NexusUI.Theme.Accent,
                Font             = NexusUI.Theme.FontBold,
                TextSize         = 10,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = sec,
            })

            New("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0.5, 0, 0, 1),
                BackgroundColor3 = NexusUI.Theme.Border,
                BorderSizePixel  = 0,
                Parent           = sec,
            })
        end

        -- ── CreateButton ──────────────────────────
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local elemName = cfg.Name     or "Button"
            local cb       = cfg.Callback or function() end

            local frame, _ = makeElementBase(elemName)
            frame.Size = UDim2.new(1, 0, 0, 36)

            local btn = New("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 70, 0, 22),
                BackgroundColor3 = NexusUI.Theme.Accent,
                Text             = "Execute",
                TextColor3       = Color3.new(1, 1, 1),
                Font             = NexusUI.Theme.FontBold,
                TextSize         = 11,
                AutoButtonColor  = false,
                Parent           = frame,
            })
            Corner(UDim.new(0, 4), btn)

            local debounce = false
            btn.MouseButton1Click:Connect(function()
                if debounce then return end
                debounce = true
                Tween(btn, {BackgroundColor3 = NexusUI.Theme.AccentDark}, 0.1)
                pcall(cb)
                task.wait(0.15)
                Tween(btn, {BackgroundColor3 = NexusUI.Theme.Accent}, 0.1)
                task.wait(0.1)
                debounce = false
            end)
            btn.MouseEnter:Connect(function()
                Tween(btn, {BackgroundColor3 = NexusUI.Theme.AccentDark}, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, {BackgroundColor3 = NexusUI.Theme.Accent}, 0.15)
            end)

            local elem = { _type = "Button" }
            function elem:SetValue() end
            function elem:GetValue() return nil end
            return elem
        end

        -- ── CreateToggle ──────────────────────────
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local elemName  = cfg.Name     or "Toggle"
            local default   = cfg.Default
            local cb        = cfg.Callback or function() end
            local elemKey   = cfg.Key      or elemName

            if Window._savedConfig[elemKey] ~= nil then
                default = Window._savedConfig[elemKey]
            end
            if default == nil then default = false end

            local frame, _ = makeElementBase(elemName)
            frame.Size = UDim2.new(1, 0, 0, 36)

            -- Track
            local track = New("Frame", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 40, 0, 20),
                BackgroundColor3 = NexusUI.Theme.ToggleOff,
                Parent           = frame,
            })
            Corner(UDim.new(1, 0), track)

            -- Thumb
            local thumb = New("Frame", {
                AnchorPoint      = Vector2.new(0, 0.5),
                Position         = UDim2.new(0, 3, 0.5, 0),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent           = track,
            })
            Corner(UDim.new(1, 0), thumb)

            local value = default
            local function apply(v, animate)
                value = v
                local dur = animate and 0.2 or 0
                if v then
                    Tween(track, {BackgroundColor3 = NexusUI.Theme.Accent}, dur)
                    Tween(thumb, {Position = UDim2.new(0, 23, 0.5, 0)}, dur)
                else
                    Tween(track, {BackgroundColor3 = NexusUI.Theme.ToggleOff}, dur)
                    Tween(thumb, {Position = UDim2.new(0, 3, 0.5, 0)}, dur)
                end
            end
            apply(value, false)

            -- Click area
            local clickBtn = New("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                Parent           = frame,
            })
            clickBtn.MouseButton1Click:Connect(function()
                apply(not value, true)
                pcall(cb, value)
                if Window._elements[elemKey] then
                    Window:SaveAllConfigs()
                end
            end)

            local elem = { _type = "Toggle", _value = value, _key = elemKey }
            Window._elements[elemKey] = elem

            function elem:SetValue(v)
                apply(v, true)
                pcall(cb, value)
            end
            function elem:GetValue() return value end
            return elem
        end

        -- ── CreateSlider ──────────────────────────
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local elemName = cfg.Name    or "Slider"
            local minVal   = cfg.Min     or 0
            local maxVal   = cfg.Max     or 100
            local default  = cfg.Default or minVal
            local suffix   = cfg.Suffix  or ""
            local cb       = cfg.Callback or function() end
            local elemKey  = cfg.Key     or elemName
            local step     = cfg.Step    or 1

            if Window._savedConfig[elemKey] ~= nil then
                default = Window._savedConfig[elemKey]
            end
            default = math.clamp(default, minVal, maxVal)

            local frame = New("Frame", {
                Name             = elemName,
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = NexusUI.Theme.ElementBG,
                Parent           = ScrollFrame,
            })
            Corner(NexusUI.Theme.SmallCorner, frame)
            Stroke(NexusUI.Theme.Border, 1, frame)
            Padding(6, 10, 6, 10, frame)

            frame.MouseEnter:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.15)
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementBG}, 0.15)
            end)

            local topRow = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Parent           = frame,
            })
            New("TextLabel", {
                Size             = UDim2.new(0.7, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = elemName,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = topRow,
            })
            local valLabel = New("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0),
                Position         = UDim2.new(1, 0, 0, 0),
                Size             = UDim2.new(0.3, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = tostring(default) .. suffix,
                TextColor3       = NexusUI.Theme.Accent,
                Font             = NexusUI.Theme.FontBold,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = topRow,
            })

            -- Track BG
            local trackBG = New("Frame", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 6),
                BackgroundColor3 = NexusUI.Theme.SliderBG,
                Parent           = frame,
            })
            Corner(UDim.new(1, 0), trackBG)

            local trackFill = New("Frame", {
                Size             = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = NexusUI.Theme.SliderFill,
                Parent           = trackBG,
            })
            Corner(UDim.new(1, 0), trackFill)

            -- Thumb dot
            local thumbDot = New("Frame", {
                AnchorPoint      = Vector2.new(0.5, 0.5),
                Position         = UDim2.new(0, 0, 0.5, 0),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundColor3 = NexusUI.Theme.Accent,
                ZIndex           = 2,
                Parent           = trackBG,
            })
            Corner(UDim.new(1, 0), thumbDot)
            New("UIStroke", { Color = Color3.new(1,1,1), Thickness = 2, Parent = thumbDot })

            local value = default
            local function applyValue(v, animate)
                -- snap to step
                v = math.round(v / step) * step
                v = math.clamp(v, minVal, maxVal)
                value = v
                local pct = (v - minVal) / math.max(maxVal - minVal, 1)
                local dur = animate and 0.05 or 0
                Tween(trackFill, {Size = UDim2.new(pct, 0, 1, 0)}, dur)
                Tween(thumbDot,  {Position = UDim2.new(pct, 0, 0.5, 0)}, dur)
                valLabel.Text = tostring(v) .. suffix
            end
            applyValue(value, false)

            -- Drag logic
            local sliding = false
            local function getValueFromMouse(mx)
                local absPos  = trackBG.AbsolutePosition
                local absSize = trackBG.AbsoluteSize
                local pct = math.clamp((mx - absPos.X) / absSize.X, 0, 1)
                return minVal + pct * (maxVal - minVal)
            end

            trackBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    applyValue(getValueFromMouse(input.Position.X), true)
                    pcall(cb, value)
                end
            end)

            local slideConn = UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                input.UserInputType == Enum.UserInputType.Touch) then
                    applyValue(getValueFromMouse(input.Position.X), false)
                    pcall(cb, value)
                end
            end)
            local releaseConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            table.insert(Window._connections, slideConn)
            table.insert(Window._connections, releaseConn)

            local elem = { _type = "Slider", _key = elemKey }
            Window._elements[elemKey] = elem
            function elem:SetValue(v) applyValue(v, true); pcall(cb, value) end
            function elem:GetValue() return value end
            return elem
        end

        -- ── CreateInput ───────────────────────────
        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local elemName   = cfg.Name        or "Input"
            local placeholder = cfg.Placeholder or "Enter text..."
            local cb         = cfg.Callback    or function() end
            local elemKey    = cfg.Key         or elemName

            local frame = New("Frame", {
                Name             = elemName,
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = NexusUI.Theme.ElementBG,
                Parent           = ScrollFrame,
            })
            Corner(NexusUI.Theme.SmallCorner, frame)
            Stroke(NexusUI.Theme.Border, 1, frame)
            Padding(6, 10, 6, 10, frame)

            frame.MouseEnter:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.15)
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementBG}, 0.15)
            end)

            New("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text             = elemName,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = frame,
            })

            local inputBG = New("Frame", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = NexusUI.Theme.TertiaryBG,
                Parent           = frame,
            })
            Corner(UDim.new(0, 4), inputBG)
            Stroke(NexusUI.Theme.Border, 1, inputBG)

            local textBox = New("TextBox", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                PlaceholderText  = placeholder,
                PlaceholderColor3 = NexusUI.Theme.TextSecondary,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent           = inputBG,
            })
            Padding(0, 8, 0, 8, textBox)

            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed or true then
                    pcall(cb, textBox.Text)
                    if Window._elements[elemKey] then
                        Window:SaveAllConfigs()
                    end
                end
            end)
            textBox.Focused:Connect(function()
                Tween(inputBG, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.15)
            end)
            textBox.FocusLost:Connect(function()
                Tween(inputBG, {BackgroundColor3 = NexusUI.Theme.TertiaryBG}, 0.15)
            end)

            local elem = { _type = "Input", _key = elemKey }
            Window._elements[elemKey] = elem
            function elem:SetValue(v) textBox.Text = tostring(v) end
            function elem:GetValue() return textBox.Text end
            return elem
        end

        -- ── CreateDropdown ────────────────────────
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local elemName = cfg.Name     or "Dropdown"
            local options  = cfg.Options  or {}
            local default  = cfg.Default  or (options[1] or "")
            local cb       = cfg.Callback or function() end
            local elemKey  = cfg.Key      or elemName

            if Window._savedConfig[elemKey] ~= nil then
                default = Window._savedConfig[elemKey]
            end

            local frame = New("Frame", {
                Name             = elemName,
                Size             = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = NexusUI.Theme.ElementBG,
                ClipsDescendants = false,
                ZIndex           = 5,
                Parent           = ScrollFrame,
            })
            Corner(NexusUI.Theme.SmallCorner, frame)
            Stroke(NexusUI.Theme.Border, 1, frame)
            Padding(6, 10, 6, 10, frame)

            frame.MouseEnter:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.15)
            end)
            frame.MouseLeave:Connect(function()
                Tween(frame, {BackgroundColor3 = NexusUI.Theme.ElementBG}, 0.15)
            end)

            New("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Text             = elemName,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 13,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = frame,
            })

            local dropBtn = New("TextButton", {
                AnchorPoint      = Vector2.new(0, 1),
                Position         = UDim2.new(0, 0, 1, 0),
                Size             = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = NexusUI.Theme.TertiaryBG,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 5,
                Parent           = frame,
            })
            Corner(UDim.new(0, 4), dropBtn)
            Stroke(NexusUI.Theme.Border, 1, dropBtn)

            local selectedLabel = New("TextLabel", {
                Size             = UDim2.new(0.85, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = tostring(default),
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = dropBtn,
            })
            Padding(0, 0, 0, 8, selectedLabel)

            -- Arrow
            local arrow = New("TextLabel", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, -6, 0.5, 0),
                Size             = UDim2.new(0, 14, 0, 14),
                BackgroundTransparency = 1,
                Text             = "▼",
                TextColor3       = NexusUI.Theme.TextSecondary,
                Font             = NexusUI.Theme.FontBold,
                TextSize         = 9,
                ZIndex           = 6,
                Parent           = dropBtn,
            })

            -- ── Dropdown list ─────────────────────────────────────────────────
            -- Parented directly to ScreenGui so it is never clipped by any
            -- ancestor frame. Position is updated every frame to track dropBtn.
            local totalH    = math.min(#options * 26, 120)
            local dropList  = New("ScrollingFrame", {
                Position             = UDim2.new(0, 0, 0, 0),  -- set dynamically below
                Size                 = UDim2.new(0, 0, 0, 0),
                BackgroundColor3     = NexusUI.Theme.SecondaryBG,
                ClipsDescendants     = true,
                ZIndex               = 50,
                Visible              = false,
                BorderSizePixel      = 0,
                ScrollBarThickness   = 3,
                ScrollBarImageColor3 = NexusUI.Theme.Accent,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ScrollingDirection   = Enum.ScrollingDirection.Y,
                Parent               = ScreenGui,    -- top-level: never clipped
            })
            Corner(NexusUI.Theme.SmallCorner, dropList)
            Stroke(NexusUI.Theme.Border, 1, dropList)
            ListLayout(dropList, 0)

            -- Keep list width & position in sync with dropBtn every frame
            local trackConn = RunService.RenderStepped:Connect(function()
                if not dropBtn.Parent then return end
                local absPos  = dropBtn.AbsolutePosition
                local absSize = dropBtn.AbsoluteSize
                -- prefer opening downward; if too close to bottom flip upward
                local screenH   = ScreenGui.AbsoluteSize.Y
                local listH     = dropList.AbsoluteSize.Y
                local spaceBelow = screenH - (absPos.Y + absSize.Y + 4)
                local posY
                if spaceBelow >= listH or spaceBelow >= 60 then
                    posY = absPos.Y + absSize.Y + 4          -- below
                else
                    posY = absPos.Y - listH - 4              -- above
                end
                dropList.Position = UDim2.new(0, absPos.X, 0, posY)
                dropList.Size     = UDim2.new(0, absSize.X, 0, dropList.Size.Y.Offset)
            end)
            table.insert(Window._connections, trackConn)

            local isOpen = false
            local value  = default

            local function closeDropdown()
                isOpen = false
                Tween(dropList, {Size = UDim2.new(0, dropList.Size.X.Offset, 0, 0)}, 0.2)
                Tween(arrow, {Rotation = 0}, 0.2)
                task.delay(0.21, function() dropList.Visible = false end)
            end

            local function buildList()
                for _, child in ipairs(dropList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local optBtn = New("TextButton", {
                        Size             = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = NexusUI.Theme.SecondaryBG,
                        Text             = tostring(opt),
                        TextColor3       = (opt == value) and NexusUI.Theme.Accent or NexusUI.Theme.TextPrimary,
                        Font             = NexusUI.Theme.Font,
                        TextSize         = 12,
                        AutoButtonColor  = false,
                        ZIndex           = 51,
                        Parent           = dropList,
                    })
                    Padding(0, 8, 0, 8, optBtn)
                    optBtn.MouseEnter:Connect(function()
                        Tween(optBtn, {BackgroundColor3 = NexusUI.Theme.TertiaryBG}, 0.1)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Tween(optBtn, {BackgroundColor3 = NexusUI.Theme.SecondaryBG}, 0.1)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        value = opt
                        selectedLabel.Text = tostring(opt)
                        closeDropdown()
                        buildList()
                        pcall(cb, value)
                        Window:SaveAllConfigs()
                    end)
                end
            end
            buildList()

            dropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    -- sync width immediately before animating open
                    local absSize = dropBtn.AbsoluteSize
                    dropList.Size    = UDim2.new(0, absSize.X, 0, 0)
                    dropList.Visible = true
                    totalH = math.min(#options * 26, 120)
                    Tween(dropList, {Size = UDim2.new(0, absSize.X, 0, totalH)}, 0.2)
                    Tween(arrow, {Rotation = 180}, 0.2)
                else
                    closeDropdown()
                end
            end)

            local elem = { _type = "Dropdown", _key = elemKey }
            Window._elements[elemKey] = elem
            function elem:SetValue(v)
                value = v
                selectedLabel.Text = tostring(v)
                buildList()
                pcall(cb, v)
            end
            function elem:GetValue() return value end
            function elem:SetOptions(newOpts)
                options = newOpts
                buildList()
            end
            return elem
        end

        -- ── CreateKeybind ─────────────────────────
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local elemName = cfg.Name     or "Keybind"
            local default  = cfg.Default  or Enum.KeyCode.Unknown
            local cb       = cfg.Callback or function() end
            local elemKey  = cfg.Key      or elemName

            if Window._savedConfig[elemKey] ~= nil then
                local savedKey = Window._savedConfig[elemKey]
                pcall(function() default = Enum.KeyCode[savedKey] end)
            end

            local frame, _ = makeElementBase(elemName)
            frame.Size = UDim2.new(1, 0, 0, 36)

            local binding = default
            local listening = false

            local bindBtn = New("TextButton", {
                AnchorPoint      = Vector2.new(1, 0.5),
                Position         = UDim2.new(1, 0, 0.5, 0),
                Size             = UDim2.new(0, 80, 0, 22),
                BackgroundColor3 = NexusUI.Theme.TertiaryBG,
                Text             = binding.Name,
                TextColor3       = NexusUI.Theme.TextPrimary,
                Font             = NexusUI.Theme.Font,
                TextSize         = 11,
                AutoButtonColor  = false,
                Parent           = frame,
            })
            Corner(UDim.new(0, 4), bindBtn)
            Stroke(NexusUI.Theme.Border, 1, bindBtn)

            bindBtn.MouseButton1Click:Connect(function()
                listening = true
                bindBtn.Text = "..."
                Tween(bindBtn, {BackgroundColor3 = NexusUI.Theme.Accent}, 0.15)
            end)

            local listenConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if not listening then
                    -- Global trigger for the keybind
                    if input.KeyCode == binding then
                        pcall(cb)
                    end
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    binding = input.KeyCode
                    bindBtn.Text = binding.Name
                    Tween(bindBtn, {BackgroundColor3 = NexusUI.Theme.TertiaryBG}, 0.15)
                    Window:SaveAllConfigs()
                end
            end)
            table.insert(Window._connections, listenConn)

            local elem = { _type = "Keybind", _key = elemKey }
            Window._elements[elemKey] = elem
            function elem:SetValue(v)
                binding = v
                bindBtn.Text = v.Name
            end
            function elem:GetValue() return binding end
            return elem
        end

        -- ── CreateColorpicker (bonus) ─────────────
        function Tab:CreateLabel(cfg)
            cfg = cfg or {}
            local text = cfg.Text or ""

            New("TextLabel", {
                Name             = "Label",
                Size             = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text             = text,
                TextColor3       = NexusUI.Theme.TextSecondary,
                Font             = NexusUI.Theme.FontLight,
                TextSize         = 12,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                Parent           = ScrollFrame,
            })
        end

        return Tab
    end -- CreateTab

    return Window
end -- CreateWindow

-- ────────────────────────────────────────────────
--  ApplyTheme (dynamic re-theming)
-- ────────────────────────────────────────────────
function NexusUI:ApplyTheme(newTheme)
    for k, v in pairs(newTheme) do
        NexusUI.Theme[k] = v
    end
end

-- ────────────────────────────────────────────────
--  Return
-- ────────────────────────────────────────────────
return NexusUI
