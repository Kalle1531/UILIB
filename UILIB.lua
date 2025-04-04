--[[
    RobloxUI - A Modern UI Library for Roblox
    
    A comprehensive, flexible, and easy-to-use UI framework for Roblox games
    with support for windows, tabs, containers, buttons, sliders, and more.
    
    Features:
    - Draggable and resizable windows
    - Tab system for organizing UI components
    - Scrollable containers
    - Interactive UI components (buttons, sliders, checkboxes, etc.)
    - Custom styling and theming
    - Animations and transitions
    - Responsive layouts
    - Event handling system
    - Accessibility features
    - Optimized for performance
]]

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

local RobloxUI = {}
RobloxUI.__index = RobloxUI

-- Constants
local TWEEN_TIME = 0.2
local DRAG_SPEED = 0.07
local RESIZE_HANDLE_SIZE = 10
local DEFAULT_FONT = Enum.Font.SourceSans
local DEFAULT_TEXT_SIZE = 14
local DEFAULT_CORNER_RADIUS = UDim.new(0, 4)

-- Default theme
RobloxUI.Themes = {
    Default = {
        Primary = Color3.fromRGB(41, 128, 185),    -- Blue
        Secondary = Color3.fromRGB(52, 152, 219),  -- Light Blue
        Background = Color3.fromRGB(44, 62, 80),   -- Dark Blue
        BackgroundSecondary = Color3.fromRGB(52, 73, 94), -- Lighter Dark Blue
        Text = Color3.fromRGB(236, 240, 241),      -- White
        TextDisabled = Color3.fromRGB(189, 195, 199), -- Light Gray
        Border = Color3.fromRGB(52, 73, 94),       -- Lighter Dark Blue
        Success = Color3.fromRGB(46, 204, 113),    -- Green
        Warning = Color3.fromRGB(241, 196, 15),    -- Yellow
        Error = Color3.fromRGB(231, 76, 60),       -- Red
        Highlight = Color3.fromRGB(155, 89, 182),  -- Purple
    },
    Dark = {
        Primary = Color3.fromRGB(52, 152, 219),    -- Blue
        Secondary = Color3.fromRGB(41, 128, 185),  -- Darker Blue
        Background = Color3.fromRGB(22, 24, 29),   -- Very Dark
        BackgroundSecondary = Color3.fromRGB(30, 32, 36), -- Dark Gray
        Text = Color3.fromRGB(236, 240, 241),      -- White
        TextDisabled = Color3.fromRGB(149, 165, 166), -- Gray
        Border = Color3.fromRGB(44, 47, 51),       -- Dark Gray
        Success = Color3.fromRGB(46, 204, 113),    -- Green
        Warning = Color3.fromRGB(241, 196, 15),    -- Yellow
        Error = Color3.fromRGB(231, 76, 60),       -- Red
        Highlight = Color3.fromRGB(155, 89, 182),  -- Purple
    },
    Light = {
        Primary = Color3.fromRGB(52, 152, 219),    -- Blue
        Secondary = Color3.fromRGB(41, 128, 185),  -- Darker Blue
        Background = Color3.fromRGB(236, 240, 241), -- White
        BackgroundSecondary = Color3.fromRGB(245, 246, 247), -- Light Gray
        Text = Color3.fromRGB(44, 62, 80),         -- Dark Blue
        TextDisabled = Color3.fromRGB(127, 140, 141), -- Gray
        Border = Color3.fromRGB(189, 195, 199),    -- Light Gray
        Success = Color3.fromRGB(46, 204, 113),    -- Green
        Warning = Color3.fromRGB(241, 196, 15),    -- Yellow
        Error = Color3.fromRGB(231, 76, 60),       -- Red
        Highlight = Color3.fromRGB(155, 89, 182),  -- Purple
    }
}

-- Current theme
RobloxUI.CurrentTheme = RobloxUI.Themes.Default

-- Utility functions
local Util = {}

-- Create a new instance with properties
function Util.Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    return instance
end

-- Create a rounded frame
function Util.CreateRoundedFrame(properties)
    local frame = Util.Create("Frame", properties)
    local corner = Util.Create("UICorner", {
        CornerRadius = DEFAULT_CORNER_RADIUS,
        Parent = frame
    })
    return frame
end

-- Create a tween
function Util.Tween(instance, properties, time, easingStyle, easingDirection)
    time = time or TWEEN_TIME
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(time, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Calculate text size
function Util.GetTextSize(text, textSize, font, frameSize)
    return TextService:GetTextSize(text, textSize, font, frameSize)
end

-- Event system
local Event = {}
Event.__index = Event

function Event.new()
    local self = setmetatable({}, Event)
    self.Connections = {}
    return self
end

function Event:Connect(func)
    table.insert(self.Connections, func)
    local connection = {}
    
    function connection:Disconnect()
        for i, f in ipairs(self.Connections) do
            if f == func then
                table.remove(self.Connections, i)
                break
            end
        end
    end
    
    return connection
end

function Event:Fire(...)
    for _, func in ipairs(self.Connections) do
        task.spawn(func, ...)
    end
end

-- Initialize the UI library
function RobloxUI.new(parent)
    local self = setmetatable({}, RobloxUI)
    
    -- Create the main ScreenGui
    self.ScreenGui = Util.Create("ScreenGui", {
        Name = "RobloxUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    })
    
    -- Store all UI elements
    self.Windows = {}
    self.ActiveWindow = nil
    self.ZIndexCounter = 1
    
    -- Events
    self.WindowCreated = Event.new()
    self.WindowClosed = Event.new()
    self.ThemeChanged = Event.new()
    
    -- Input handling
    self:SetupInputHandling()
    
    return self
end

-- Set up input handling
function RobloxUI:SetupInputHandling()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Handle keyboard shortcuts
        if input.KeyCode == Enum.KeyCode.Escape then
            if self.ActiveWindow then
                self.ActiveWindow:Focus(false)
                self.ActiveWindow = nil
            end
        end
    end)
end

-- Set the active theme
function RobloxUI:SetTheme(themeName)
    if RobloxUI.Themes[themeName] then
        RobloxUI.CurrentTheme = RobloxUI.Themes[themeName]
        self.ThemeChanged:Fire(RobloxUI.CurrentTheme)
        
        -- Update all windows with the new theme
        for _, window in pairs(self.Windows) do
            window:ApplyTheme(RobloxUI.CurrentTheme)
        end
    else
        warn("Theme not found:", themeName)
    end
end

-- Create a custom theme
function RobloxUI:CreateTheme(name, themeColors)
    RobloxUI.Themes[name] = themeColors
    return themeColors
end

-- Create a window
function RobloxUI:CreateWindow(options)
    options = options or {}
    
    local window = {}
    window.__index = window
    
    -- Window properties
    window.Title = options.Title or "Window"
    window.Size = options.Size or UDim2.new(0, 300, 0, 200)
    window.Position = options.Position or UDim2.new(0.5, -150, 0.5, -100)
    window.MinSize = options.MinSize or Vector2.new(200, 150)
    window.Resizable = options.Resizable ~= false
    window.Draggable = options.Draggable ~= false
    window.ShowClose = options.ShowClose ~= false
    window.ShowMinimize = options.ShowMinimize ~= false
    window.Theme = options.Theme or RobloxUI.CurrentTheme
    window.Visible = options.Visible ~= false
    window.Parent = self
    
    -- Create window frame
    window.Frame = Util.CreateRoundedFrame({
        Name = "Window_" .. window.Title,
        Size = window.Size,
        Position = window.Position,
        BackgroundColor3 = window.Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        Visible = window.Visible,
        ZIndex = self.ZIndexCounter
    })
    
    -- Create title bar
    window.TitleBar = Util.CreateRoundedFrame({
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = window.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = self.ZIndexCounter + 1,
        Parent = window.Frame
    })
    
    -- Create title text
    window.TitleText = Util.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = window.Title,
        TextColor3 = window.Theme.Text,
        TextSize = DEFAULT_TEXT_SIZE,
        Font = DEFAULT_FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = self.ZIndexCounter + 2,
        Parent = window.TitleBar
    })
    
    -- Create close button
    if window.ShowClose then
        window.CloseButton = Util.Create("TextButton", {
            Name = "CloseButton",
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -28, 0, 3),
            BackgroundTransparency = 1,
            Text = "✕",
            TextColor3 = window.Theme.Text,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            ZIndex = self.ZIndexCounter + 2,
            Parent = window.TitleBar
        })
        
        window.CloseButton.MouseButton1Click:Connect(function()
            window:Close()
        end)
        
        window.CloseButton.MouseEnter:Connect(function()
            Util.Tween(window.CloseButton, {TextColor3 = window.Theme.Error})
        end)
        
        window.CloseButton.MouseLeave:Connect(function()
            Util.Tween(window.CloseButton, {TextColor3 = window.Theme.Text})
        end)
    end
    
    -- Create minimize button
    if window.ShowMinimize then
        window.MinimizeButton = Util.Create("TextButton", {
            Name = "MinimizeButton",
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(1, -56, 0, 3),
            BackgroundTransparency = 1,
            Text = "−",
            TextColor3 = window.Theme.Text,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            ZIndex = self.ZIndexCounter + 2,
            Parent = window.TitleBar
        })
        
        window.MinimizeButton.MouseButton1Click:Connect(function()
            window:Minimize()
        end)
        
        window.MinimizeButton.MouseEnter:Connect(function()
            Util.Tween(window.MinimizeButton, {TextColor3 = window.Theme.Warning})
        end)
        
        window.MinimizeButton.MouseLeave:Connect(function()
            Util.Tween(window.MinimizeButton, {TextColor3 = window.Theme.Text})
        end)
    end
    
    -- Create content container
    window.ContentFrame = Util.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = window.Theme.Background,
        BorderSizePixel = 0,
        ZIndex = self.ZIndexCounter + 1,
        Parent = window.Frame
    })
    
    -- Create resize handle if resizable
    if window.Resizable then
        window.ResizeHandle = Util.Create("TextButton", {
            Name = "ResizeHandle",
            Size = UDim2.new(0, RESIZE_HANDLE_SIZE, 0, RESIZE_HANDLE_SIZE),
            Position = UDim2.new(1, -RESIZE_HANDLE_SIZE, 1, -RESIZE_HANDLE_SIZE),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = self.ZIndexCounter + 3,
            Parent = window.Frame
        })
        
        -- Resize functionality
        local resizing = false
        local resizeStart = Vector2.new()
        local initialSize = Vector2.new()
        
        window.ResizeHandle.MouseButton1Down:Connect(function(x, y)
            resizing = true
            resizeStart = Vector2.new(x, y)
            initialSize = window.Frame.AbsoluteSize
            window:Focus(true)
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = Vector2.new(input.Position.X, input.Position.Y) - resizeStart
                local newSize = initialSize + delta
                
                -- Enforce minimum size
                newSize = Vector2.new(
                    math.max(newSize.X, window.MinSize.X),
                    math.max(newSize.Y, window.MinSize.Y)
                )
                
                window.Frame.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end
    
    -- Make window draggable
    if window.Draggable then
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        window.TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = window.Frame.Position
                window:Focus(true)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                window.Frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    -- Tab system
    window.Tabs = {}
    window.TabButtons = {}
    window.ActiveTab = nil
    
    -- Tab container
    window.TabContainer = Util.Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = window.Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Visible = false, -- Only show when tabs are added
        ZIndex = self.ZIndexCounter + 2,
        Parent = window.ContentFrame
    })
    
    -- Tab content container
    window.TabContentContainer = Util.Create("Frame", {
        Name = "TabContentContainer",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = self.ZIndexCounter + 1,
        Parent = window.ContentFrame
    })
    
    -- Events
    window.OnClose = Event.new()
    window.OnMinimize = Event.new()
    window.OnResize = Event.new()
    window.OnFocus = Event.new()
    
    -- Window methods
    function window:Close()
        Util.Tween(self.Frame, {Size = UDim2.new(0, self.Frame.AbsoluteSize.X, 0, 0)}, TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
            self.Frame.Visible = false
            self.OnClose:Fire()
            self.Parent.WindowClosed:Fire(self)
        end)
    end
    
    function window:Minimize()
        if self.Minimized then
            -- Restore
            Util.Tween(self.Frame, {Size = self.OriginalSize}, TWEEN_TIME)
            self.ContentFrame.Visible = true
            self.Minimized = false
        else
            -- Minimize
            self.OriginalSize = self.Frame.Size
            Util.Tween(self.Frame, {Size = UDim2.new(0, self.Frame.AbsoluteSize.X, 0, 30)}, TWEEN_TIME)
            self.ContentFrame.Visible = false
            self.Minimized = true
        end
        
        self.OnMinimize:Fire(self.Minimized)
    end
    
    function window:Focus(focus)
        if focus then
            self.Parent.ZIndexCounter = self.Parent.ZIndexCounter + 3
            self.Frame.ZIndex = self.Parent.ZIndexCounter
            self.TitleBar.ZIndex = self.Parent.ZIndexCounter + 1
            self.ContentFrame.ZIndex = self.Parent.ZIndexCounter + 1
            
            -- Update all child elements
            for _, descendant in pairs(self.Frame:GetDescendants()) do
                if descendant:IsA("GuiObject") then
                    descendant.ZIndex = descendant.ZIndex + 3
                end
            end
            
            self.Parent.ActiveWindow = self
            self.OnFocus:Fire(true)
        else
            self.OnFocus:Fire(false)
        end
    end
    
    function window:SetVisible(visible)
        if visible then
            self.Frame.Visible = true
            if not self.Minimized then
                Util.Tween(self.Frame, {Size = self.OriginalSize or self.Size}, TWEEN_TIME)
            end
        else
            Util.Tween(self.Frame, {Size = UDim2.new(0, self.Frame.AbsoluteSize.X, 0, 0)}, TWEEN_TIME).Completed:Connect(function()
                self.Frame.Visible = false
            end)
        end
    end
    
    function window:SetTitle(title)
        self.Title = title
        self.TitleText.Text = title
    end
    
    function window:ApplyTheme(theme)
        self.Theme = theme
        self.Frame.BackgroundColor3 = theme.Background
        self.TitleBar.BackgroundColor3 = theme.Primary
        self.TitleText.TextColor3 = theme.Text
        self.ContentFrame.BackgroundColor3 = theme.Background
        self.TabContainer.BackgroundColor3 = theme.BackgroundSecondary
        
        if self.CloseButton then
            self.CloseButton.TextColor3 = theme.Text
        end
        
        if self.MinimizeButton then
            self.MinimizeButton.TextColor3 = theme.Text
        end
        
        -- Update tabs
        for _, tab in pairs(self.Tabs) do
            tab:ApplyTheme(theme)
        end
        
        -- Update tab buttons
        for _, button in pairs(self.TabButtons) do
            if button.Active then
                button.BackgroundColor3 = theme.Primary
                button.TextColor3 = theme.Text
            else
                button.BackgroundColor3 = theme.BackgroundSecondary
                button.TextColor3 = theme.TextDisabled
            end
        end
    end
    
    -- Tab management
    function window:AddTab(name)
        -- Create tab button
        local tabButtonWidth = 100
        local tabButtonPosition = #self.Tabs * tabButtonWidth
        
        local tabButton = Util.Create("TextButton", {
            Name = "TabButton_" .. name,
            Size = UDim2.new(0, tabButtonWidth, 1, 0),
            Position = UDim2.new(0, tabButtonPosition, 0, 0),
            BackgroundColor3 = self.Theme.BackgroundSecondary,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = self.Theme.TextDisabled,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            ZIndex = self.Parent.ZIndexCounter + 3,
            Parent = self.TabContainer
        })
        
        -- Create tab content frame
        local tabContent = Util.Create("ScrollingFrame", {
            Name = "TabContent_" .. name,
            Size = UDim2.new(1, 0, 1, self.TabContainer.Visible and -30 or 0),
            Position = UDim2.new(0, 0, 0, self.TabContainer.Visible and 30 or 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ZIndex = self.Parent.ZIndexCounter + 2,
            Visible = false,
            Parent = self.TabContentContainer
        })
        
        -- Auto layout for tab content
        local uiListLayout = Util.Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })
        
        local uiPadding = Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent
        })
        
        -- Update canvas size when children change
        uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab object
        local tab = {
            Name = name,
            Button = tabButton,
            Content = tabContent,
            Window = self,
            Elements = {},
            OnSelect = Event.new()
        }
        
        -- Tab methods
        function tab:Select()
            -- Hide all tabs
            for _, t in pairs(self.Window.Tabs) do
                t.Content.Visible = false
                self.Window.TabButtons[t.Name].BackgroundColor3 = self.Window.Theme.BackgroundSecondary
                self.Window.TabButtons[t.Name].TextColor3 = self.Window.Theme.TextDisabled
                self.Window.TabButtons[t.Name].Active = false
            end
            
            -- Show this tab
            self.Content.Visible = true
            self.Window.TabButtons[self.Name].BackgroundColor3 = self.Window.Theme.Primary
            self.Window.TabButtons[self.Name].TextColor3 = self.Window.Theme.Text
            self.Window.TabButtons[self.Name].Active = true
            
            self.Window.ActiveTab = self
            self.OnSelect:Fire()
        end
        
        function tab:AddElement(element)
            table.insert(self.Elements, element)
            element.Parent = self
            return element
        end
        
        function tab:ApplyTheme(theme)
            for _, element in pairs(self.Elements) do
                if element.ApplyTheme then
                    element:ApplyTheme(theme)
                end
            end
        end
        
        -- UI Component creation methods
        function tab:CreateLabel(options)
            options = options or {}
            
            local label = {
                Text = options.Text or "Label",
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                Font = options.Font or DEFAULT_FONT,
                Parent = self
            }
            
            label.Frame = Util.Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = label.Text,
                TextColor3 = label.TextColor,
                TextSize = label.TextSize,
                Font = label.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            function label:SetText(text)
                self.Text = text
                self.Frame.Text = text
            end
            
            function label:ApplyTheme(theme)
                self.TextColor = theme.Text
                self.Frame.TextColor3 = theme.Text
            end
            
            return self:AddElement(label)
        end
        
        function tab:CreateButton(options)
            options = options or {}
            
            local button = {
                Text = options.Text or "Button",
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.Primary,
                HoverColor = options.HoverColor or self.Window.Theme.Secondary,
                PressedColor = options.PressedColor or self.Window.Theme.BackgroundSecondary,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnClick = Event.new()
            }
            
            button.Frame = Util.CreateRoundedFrame({
                Name = "Button",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = button.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            button.TextLabel = Util.Create("TextLabel", {
                Name = "ButtonText",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = button.Text,
                TextColor3 = button.TextColor,
                TextSize = button.TextSize,
                Font = button.Font,
                Parent = button.Frame
            })
            
            -- Make the button clickable
            button.ClickDetector = Util.Create("TextButton", {
                Name = "ClickDetector",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = button.Frame
            })
            
            -- Button events
            button.ClickDetector.MouseButton1Click:Connect(function()
                if button.Callback then
                    button.Callback()
                end
                button.OnClick:Fire()
            end)
            
            button.ClickDetector.MouseEnter:Connect(function()
                Util.Tween(button.Frame, {BackgroundColor3 = button.HoverColor})
            end)
            
            button.ClickDetector.MouseLeave:Connect(function()
                Util.Tween(button.Frame, {BackgroundColor3 = button.BackgroundColor})
            end)
            
            button.ClickDetector.MouseButton1Down:Connect(function()
                Util.Tween(button.Frame, {BackgroundColor3 = button.PressedColor})
            end)
            
            button.ClickDetector.MouseButton1Up:Connect(function()
                Util.Tween(button.Frame, {BackgroundColor3 = button.HoverColor})
            end)
            
            function button:SetText(text)
                self.Text = text
                self.TextLabel.Text = text
            end
            
            function button:SetCallback(callback)
                self.Callback = callback
            end
            
            function button:ApplyTheme(theme)
                self.BackgroundColor = theme.Primary
                self.HoverColor = theme.Secondary
                self.PressedColor = theme.BackgroundSecondary
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
            end
            
            return self:AddElement(button)
        end
        
        function tab:CreateSlider(options)
            options = options or {}
            
            local slider = {
                Text = options.Text or "Slider",
                Min = options.Min or 0,
                Max = options.Max or 100,
                Value = options.Value or 50,
                Increment = options.Increment or 1,
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                SliderColor = options.SliderColor or self.Window.Theme.Primary,
                SliderBackgroundColor = options.SliderBackgroundColor or self.Window.Theme.Border,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnValueChanged = Event.new()
            }
            
            -- Calculate initial value percentage
            local valueRange = slider.Max - slider.Min
            local initialPercent = (slider.Value - slider.Min) / valueRange
            
            -- Create slider container
            slider.Frame = Util.CreateRoundedFrame({
                Name = "Slider",
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = slider.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create slider label
            slider.TextLabel = Util.Create("TextLabel", {
                Name = "SliderText",
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = slider.Text,
                TextColor3 = slider.TextColor,
                TextSize = slider.TextSize,
                Font = slider.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = slider.Frame
            })
            
            -- Create value label
            slider.ValueLabel = Util.Create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(slider.Value),
                TextColor3 = slider.TextColor,
                TextSize = slider.TextSize,
                Font = slider.Font,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = slider.Frame
            })
            
            -- Create slider background
            slider.SliderBackground = Util.CreateRoundedFrame({
                Name = "SliderBackground",
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = slider.SliderBackgroundColor,
                BorderSizePixel = 0,
                Parent = slider.Frame
            })
            
            -- Create slider fill
            slider.SliderFill = Util.CreateRoundedFrame({
                Name = "SliderFill",
                Size = UDim2.new(initialPercent, 0, 1, 0),
                BackgroundColor3 = slider.SliderColor,
                BorderSizePixel = 0,
                Parent = slider.SliderBackground
            })
            
            -- Create slider knob
            slider.SliderKnob = Util.CreateRoundedFrame({
                Name = "SliderKnob",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(initialPercent, -8, 0, -5),
                BackgroundColor3 = slider.SliderColor,
                BorderSizePixel = 0,
                Parent = slider.SliderBackground
            })
            
            -- Create slider interaction area
            slider.SliderInteraction = Util.Create("TextButton", {
                Name = "SliderInteraction",
                Size = UDim2.new(1, 0, 1, 10),
                Position = UDim2.new(0, 0, 0, -5),
                BackgroundTransparency = 1,
                Text = "",
                Parent = slider.SliderBackground
            })
            
            -- Slider functionality
            local isDragging = false
            
            slider.SliderInteraction.MouseButton1Down:Connect(function(x)
                isDragging = true
                local relativeX = x - slider.SliderBackground.AbsolutePosition.X
                local sliderWidth = slider.SliderBackground.AbsoluteSize.X
                local percent = math.clamp(relativeX / sliderWidth, 0, 1)
                
                -- Update slider visuals
                slider.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                slider.SliderKnob.Position = UDim2.new(percent, -8, 0, -5)
                
                -- Calculate and update value
                local rawValue = slider.Min + (percent * valueRange)
                local incrementedValue = math.floor(rawValue / slider.Increment + 0.5) * slider.Increment
                slider.Value = math.clamp(incrementedValue, slider.Min, slider.Max)
                slider.ValueLabel.Text = tostring(slider.Value)
                
                -- Fire callback
                if slider.Callback then
                    slider.Callback(slider.Value)
                end
                slider.OnValueChanged:Fire(slider.Value)
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = input.Position.X - slider.SliderBackground.AbsolutePosition.X
                    local sliderWidth = slider.SliderBackground.AbsoluteSize.X
                    local percent = math.clamp(relativeX / sliderWidth, 0, 1)
                    
                    -- Update slider visuals
                    slider.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    slider.SliderKnob.Position = UDim2.new(percent, -8, 0, -5)
                    
                    -- Calculate and update value
                    local rawValue = slider.Min + (percent * valueRange)
                    local incrementedValue = math.floor(rawValue / slider.Increment + 0.5) * slider.Increment
                    slider.Value = math.clamp(incrementedValue, slider.Min, slider.Max)
                    slider.ValueLabel.Text = tostring(slider.Value)
                    
                    -- Fire callback
                    if slider.Callback then
                        slider.Callback(slider.Value)
                    end
                    slider.OnValueChanged:Fire(slider.Value)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            function slider:SetValue(value)
                value = math.clamp(value, self.Min, self.Max)
                self.Value = value
                
                -- Update slider visuals
                local percent = (value - self.Min) / (self.Max - self.Min)
                self.SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                self.SliderKnob.Position = UDim2.new(percent, -8, 0, -5)
                self.ValueLabel.Text = tostring(value)
                
                -- Fire callback
                if self.Callback then
                    self.Callback(value)
                end
                self.OnValueChanged:Fire(value)
            end
            
            function slider:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.SliderColor = theme.Primary
                self.SliderBackgroundColor = theme.Border
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.ValueLabel.TextColor3 = self.TextColor
                self.SliderBackground.BackgroundColor3 = self.SliderBackgroundColor
                self.SliderFill.BackgroundColor3 = self.SliderColor
                self.SliderKnob.BackgroundColor3 = self.SliderColor
            end
            
            return self:AddElement(slider)
        end
        
        function tab:CreateCheckbox(options)
            options = options or {}
            
            local checkbox = {
                Text = options.Text or "Checkbox",
                Checked = options.Checked or false,
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                CheckColor = options.CheckColor or self.Window.Theme.Primary,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnChanged = Event.new()
            }
            
            -- Create checkbox container
            checkbox.Frame = Util.CreateRoundedFrame({
                Name = "Checkbox",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = checkbox.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create checkbox label
            checkbox.TextLabel = Util.Create("TextLabel", {
                Name = "CheckboxText",
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 50, 0, 0),
                BackgroundTransparency = 1,
                Text = checkbox.Text,
                TextColor3 = checkbox.TextColor,
                TextSize = checkbox.TextSize,
                Font = checkbox.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = checkbox.Frame
            })
            
            -- Create checkbox box
            checkbox.Box = Util.CreateRoundedFrame({
                Name = "CheckboxBox",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 15, 0.5, -10),
                BackgroundColor3 = checkbox.BackgroundColor,
                BorderSizePixel = 1,
                BorderColor3 = checkbox.CheckColor,
                Parent = checkbox.Frame
            })
            
            -- Create checkbox indicator
            checkbox.Indicator = Util.CreateRoundedFrame({
                Name = "CheckboxIndicator",
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = checkbox.CheckColor,
                BorderSizePixel = 0,
                Visible = checkbox.Checked,
                Parent = checkbox.Box
            })
            
            -- Create checkbox interaction area
            checkbox.Interaction = Util.Create("TextButton", {
                Name = "CheckboxInteraction",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = checkbox.Frame
            })
            
            -- Checkbox functionality
            checkbox.Interaction.MouseButton1Click:Connect(function()
                checkbox:Toggle()
            end)
            
            function checkbox:Toggle()
                self.Checked = not self.Checked
                self.Indicator.Visible = self.Checked
                
                if self.Callback then
                    self.Callback(self.Checked)
                end
                self.OnChanged:Fire(self.Checked)
            end
            
            function checkbox:SetChecked(checked)
                self.Checked = checked
                self.Indicator.Visible = checked
                
                if self.Callback then
                    self.Callback(checked)
                end
                self.OnChanged:Fire(checked)
            end
            
            function checkbox:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.CheckColor = theme.Primary
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.Box.BackgroundColor3 = self.BackgroundColor
                self.Box.BorderColor3 = self.CheckColor
                self.Indicator.BackgroundColor3 = self.CheckColor
            end
            
            return self:AddElement(checkbox)
        end
        
        function tab:CreateDropdown(options)
            options = options or {}
            
            local dropdown = {
                Text = options.Text or "Dropdown",
                Options = options.Options or {},
                Selected = options.Selected or (options.Options and options.Options[1] or nil),
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                DropdownColor = options.DropdownColor or self.Window.Theme.Background,
                HighlightColor = options.HighlightColor or self.Window.Theme.Primary,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnSelectionChanged = Event.new(),
                IsOpen = false
            }
            
            -- Create dropdown container
            dropdown.Frame = Util.CreateRoundedFrame({
                Name = "Dropdown",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = dropdown.BackgroundColor,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create dropdown label
            dropdown.TextLabel = Util.Create("TextLabel", {
                Name = "DropdownText",
                Size = UDim2.new(1, -30, 0, 32),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdown.Text,
                TextColor3 = dropdown.TextColor,
                TextSize = dropdown.TextSize,
                Font = dropdown.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdown.Frame
            })
            
            -- Create dropdown selected value
            dropdown.SelectedLabel = Util.Create("TextLabel", {
                Name = "SelectedValue",
                Size = UDim2.new(0, 100, 0, 32),
                Position = UDim2.new(1, -110, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdown.Selected or "",
                TextColor3 = dropdown.TextColor,
                TextSize = dropdown.TextSize,
                Font = dropdown.Font,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = dropdown.Frame
            })
            
            -- Create dropdown arrow
            dropdown.Arrow = Util.Create("TextLabel", {
                Name = "Arrow",
                Size = UDim2.new(0, 20, 0, 32),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = dropdown.TextColor,
                TextSize = dropdown.TextSize,
                Font = dropdown.Font,
                Parent = dropdown.Frame
            })
            
            -- Create dropdown options container
            dropdown.OptionsContainer = Util.Create("Frame", {
                Name = "OptionsContainer",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 32),
                BackgroundColor3 = dropdown.DropdownColor,
                BorderSizePixel = 0,
                Parent = dropdown.Frame
            })
            
            -- Create dropdown interaction area
            dropdown.Interaction = Util.Create("TextButton", {
                Name = "DropdownInteraction",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Text = "",
                Parent = dropdown.Frame
            })
            
            -- Populate options
            local optionHeight = 28
            for i, option in ipairs(dropdown.Options) do
                local optionButton = Util.Create("TextButton", {
                    Name = "Option_" .. option,
                    Size = UDim2.new(1, 0, 0, optionHeight),
                    Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = dropdown.TextColor,
                    TextSize = dropdown.TextSize,
                    Font = dropdown.Font,
                    Parent = dropdown.OptionsContainer
                })
                
                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundTransparency = 0.8
                    optionButton.BackgroundColor3 = dropdown.HighlightColor
                end)
                
                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundTransparency = 1
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdown:Select(option)
                    dropdown:Toggle(false)
                end)
            end
            
            -- Dropdown functionality
            dropdown.Interaction.MouseButton1Click:Connect(function()
                dropdown:Toggle(not dropdown.IsOpen)
            end)
            
            function dropdown:Toggle(open)
                self.IsOpen = open
                
                local optionsHeight = #self.Options * optionHeight
                
                if open then
                    self.Arrow.Text = "▲"
                    Util.Tween(self.Frame, {Size = UDim2.new(1, 0, 0, 32 + optionsHeight)})
                else
                    self.Arrow.Text = "▼"
                    Util.Tween(self.Frame, {Size = UDim2.new(1, 0, 0, 32)})
                end
            end
            
            function dropdown:Select(option)
                self.Selected = option
                self.SelectedLabel.Text = option
                
                if self.Callback then
                    self.Callback(option)
                end
                self.OnSelectionChanged:Fire(option)
            end
            
            function dropdown:SetOptions(options)
                self.Options = options
                
                -- Clear existing options
                for _, child in pairs(self.OptionsContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add new options
                for i, option in ipairs(options) do
                    local optionButton = Util.Create("TextButton", {
                        Name = "Option_" .. option,
                        Size = UDim2.new(1, 0, 0, optionHeight),
                        Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
                        BackgroundTransparency = 1,
                        Text = option,
                        TextColor3 = self.TextColor,
                        TextSize = self.TextSize,
                        Font = self.Font,
                        Parent = self.OptionsContainer
                    })
                    
                    optionButton.MouseEnter:Connect(function()
                        optionButton.BackgroundTransparency = 0.8
                        optionButton.BackgroundColor3 = self.HighlightColor
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        optionButton.BackgroundTransparency = 1
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        self:Select(option)
                        self:Toggle(false)
                    end)
                end
                
                -- Select first option if none selected
                if not table.find(options, self.Selected) and #options > 0 then
                    self:Select(options[1])
                end
            end
            
            function dropdown:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.DropdownColor = theme.Background
                self.HighlightColor = theme.Primary
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.SelectedLabel.TextColor3 = self.TextColor
                self.Arrow.TextColor3 = self.TextColor
                self.OptionsContainer.BackgroundColor3 = self.DropdownColor
                
                for _, child in pairs(self.OptionsContainer:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = self.TextColor
                    end
                end
            end
            
            return self:AddElement(dropdown)
        end
        
        function tab:CreateColorPicker(options)
            options = options or {}
            
            local colorPicker = {
                Text = options.Text or "Color Picker",
                Color = options.Color or Color3.fromRGB(255, 255, 255),
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnColorChanged = Event.new(),
                IsOpen = false
            }
            
            -- Create color picker container
            colorPicker.Frame = Util.CreateRoundedFrame({
                Name = "ColorPicker",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = colorPicker.BackgroundColor,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create color picker label
            colorPicker.TextLabel = Util.Create("TextLabel", {
                Name = "ColorPickerText",
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = colorPicker.Text,
                TextColor3 = colorPicker.TextColor,
                TextSize = colorPicker.TextSize,
                Font = colorPicker.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker.Frame
            })
            
            -- Create color display
            colorPicker.ColorDisplay = Util.CreateRoundedFrame({
                Name = "ColorDisplay",
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(1, -34, 0.5, -12),
                BackgroundColor3 = colorPicker.Color,
                BorderSizePixel = 0,
                Parent = colorPicker.Frame
            })
            
            -- Create color picker interaction area
            colorPicker.Interaction = Util.Create("TextButton", {
                Name = "ColorPickerInteraction",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Text = "",
                Parent = colorPicker.Frame
            })
            
            -- Create color picker panel
            colorPicker.Panel = Util.CreateRoundedFrame({
                Name = "ColorPickerPanel",
                Size = UDim2.new(1, 0, 0, 200),
                Position = UDim2.new(0, 0, 0, 32),
                BackgroundColor3 = colorPicker.BackgroundColor,
                BorderSizePixel = 0,
                Parent = colorPicker.Frame
            })
            
            -- Create RGB sliders
            local function createColorSlider(name, color, value, yPos)
                local slider = Util.CreateRoundedFrame({
                    Name = name .. "Slider",
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, yPos),
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    BorderSizePixel = 0,
                    Parent = colorPicker.Panel
                })
                
                local sliderFill = Util.CreateRoundedFrame({
                    Name = name .. "SliderFill",
                    Size = UDim2.new(value/255, 0, 1, 0),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = slider
                })
                
                local sliderInteraction = Util.Create("TextButton", {
                    Name = name .. "SliderInteraction",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = slider
                })
                
                local sliderLabel = Util.Create("TextLabel", {
                    Name = name .. "Label",
                    Size = UDim2.new(0, 30, 0, 20),
                    Position = UDim2.new(0, -40, 0, 0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = colorPicker.TextColor,
                    TextSize = colorPicker.TextSize,
                    Font = colorPicker.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider
                })
                
                local sliderValue = Util.Create("TextLabel", {
                    Name = name .. "Value",
                    Size = UDim2.new(0, 30, 0, 20),
                    Position = UDim2.new(1, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = colorPicker.TextColor,
                    TextSize = colorPicker.TextSize,
                    Font = colorPicker.Font,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = slider
                })
                
                return {
                    Slider = slider,
                    Fill = sliderFill,
                    Interaction = sliderInteraction,
                    Label = sliderLabel,
                    Value = sliderValue
                }
            end
            
            local r, g, b = colorPicker.Color.R * 255, colorPicker.Color.G * 255, colorPicker.Color.B * 255
            
            colorPicker.RedSlider = createColorSlider("R", Color3.fromRGB(255, 0, 0), r, 20)
            colorPicker.GreenSlider = createColorSlider("G", Color3.fromRGB(0, 255, 0), g, 50)
            colorPicker.BlueSlider = createColorSlider("B", Color3.fromRGB(0, 0, 255), b, 80)
            
            -- Create hex input
            colorPicker.HexLabel = Util.Create("TextLabel", {
                Name = "HexLabel",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(0, 10, 0, 120),
                BackgroundTransparency = 1,
                Text = "Hex:",
                TextColor3 = colorPicker.TextColor,
                TextSize = colorPicker.TextSize,
                Font = colorPicker.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPicker.Panel
            })
            
            colorPicker.HexInput = Util.CreateRoundedFrame({
                Name = "HexInput",
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 60, 0, 120),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Parent = colorPicker.Panel
            })
            
            colorPicker.HexText = Util.Create("TextBox", {
                Name = "HexText",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = string.format("#%02X%02X%02X", r, g, b),
                TextColor3 = colorPicker.TextColor,
                TextSize = colorPicker.TextSize,
                Font = colorPicker.Font,
                ClearTextOnFocus = false,
                Parent = colorPicker.HexInput
            })
            
            -- Create apply button
            colorPicker.ApplyButton = Util.CreateRoundedFrame({
                Name = "ApplyButton",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 160),
                BackgroundColor3 = self.Window.Theme.Primary,
                BorderSizePixel = 0,
                Parent = colorPicker.Panel
            })
            
            colorPicker.ApplyText = Util.Create("TextLabel", {
                Name = "ApplyText",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "Apply",
                TextColor3 = colorPicker.TextColor,
                TextSize = colorPicker.TextSize,
                Font = colorPicker.Font,
                Parent = colorPicker.ApplyButton
            })
            
            colorPicker.ApplyInteraction = Util.Create("TextButton", {
                Name = "ApplyInteraction",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = colorPicker.ApplyButton
            })
            
            -- Color picker functionality
            local function updateColor()
                local newColor = Color3.fromRGB(r, g, b)
                colorPicker.Color = newColor
                colorPicker.ColorDisplay.BackgroundColor3 = newColor
                colorPicker.HexText.Text = string.format("#%02X%02X%02X", r, g, b)
            end
            
            local function updateFromHex(hex)
                if hex:sub(1, 1) == "#" then
                    hex = hex:sub(2)
                end
                
                if #hex == 6 then
                    local rHex, gHex, bHex = hex:sub(1, 2), hex:sub(3, 4), hex:sub(5, 6)
                    r = tonumber(rHex, 16) or 255
                    g = tonumber(gHex, 16) or 255
                    b = tonumber(bHex, 16) or 255
                    
                    colorPicker.RedSlider.Fill.Size = UDim2.new(r/255, 0, 1, 0)
                    colorPicker.GreenSlider.Value.Text = tostring(g)
                    
                    colorPicker.BlueSlider.Fill.Size = UDim2.new(b/255, 0, 1, 0)
                    colorPicker.BlueSlider.Value.Text = tostring(b)
                    
                    updateColor()
                end
            end
            
            -- Slider interactions
            local function setupSliderInteraction(slider, colorComponent, updateFunc)
                local isDragging = false
                
                slider.Interaction.MouseButton1Down:Connect(function(x)
                    isDragging = true
                    local relativeX = x - slider.Slider.AbsolutePosition.X
                    local sliderWidth = slider.Slider.AbsoluteSize.X
                    local percent = math.clamp(relativeX / sliderWidth, 0, 1)
                    
                    -- Update slider visuals
                    slider.Fill.Size = UDim2.new(percent, 0, 1, 0)
                    
                    -- Update color value
                    local value = math.floor(percent * 255)
                    slider.Value.Text = tostring(value)
                    
                    -- Update color component
                    colorComponent = value
                    updateFunc()
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = input.Position.X - slider.Slider.AbsolutePosition.X
                        local sliderWidth = slider.Slider.AbsoluteSize.X
                        local percent = math.clamp(relativeX / sliderWidth, 0, 1)
                        
                        -- Update slider visuals
                        slider.Fill.Size = UDim2.new(percent, 0, 1, 0)
                        
                        -- Update color value
                        local value = math.floor(percent * 255)
                        slider.Value.Text = tostring(value)
                        
                        -- Update color component
                        colorComponent = value
                        updateFunc()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                    end
                end)
                
                return function(value)
                    colorComponent = value
                    slider.Fill.Size = UDim2.new(value/255, 0, 1, 0)
                    slider.Value.Text = tostring(value)
                    updateFunc()
                end
            end
            
            local setR = setupSliderInteraction(colorPicker.RedSlider, r, function()
                r = tonumber(colorPicker.RedSlider.Value.Text)
                updateColor()
            end)
            
            local setG = setupSliderInteraction(colorPicker.GreenSlider, g, function()
                g = tonumber(colorPicker.GreenSlider.Value.Text)
                updateColor()
            end)
            
            local setB = setupSliderInteraction(colorPicker.BlueSlider, b, function()
                b = tonumber(colorPicker.BlueSlider.Value.Text)
                updateColor()
            end)
            
            -- Hex input handling
            colorPicker.HexText.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    updateFromHex(colorPicker.HexText.Text)
                end
            end)
            
            -- Apply button
            colorPicker.ApplyInteraction.MouseButton1Click:Connect(function()
                colorPicker:SetColor(colorPicker.Color)
                colorPicker:Toggle(false)
            end)
            
            -- Toggle functionality
            colorPicker.Interaction.MouseButton1Click:Connect(function()
                colorPicker:Toggle(not colorPicker.IsOpen)
            end)
            
            function colorPicker:Toggle(open)
                self.IsOpen = open
                
                if open then
                    Util.Tween(self.Frame, {Size = UDim2.new(1, 0, 0, 242)})
                else
                    Util.Tween(self.Frame, {Size = UDim2.new(1, 0, 0, 32)})
                end
            end
            
            function colorPicker:SetColor(color)
                self.Color = color
                self.ColorDisplay.BackgroundColor3 = color
                
                -- Update RGB values
                local rValue, gValue, bValue = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                setR(rValue)
                setG(gValue)
                setB(bValue)
                
                -- Update hex
                self.HexText.Text = string.format("#%02X%02X%02X", rValue, gValue, bValue)
                
                if self.Callback then
                    self.Callback(color)
                end
                self.OnColorChanged:Fire(color)
            end
            
            function colorPicker:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.Panel.BackgroundColor3 = self.BackgroundColor
                self.ApplyButton.BackgroundColor3 = theme.Primary
                self.ApplyText.TextColor3 = self.TextColor
                self.HexLabel.TextColor3 = self.TextColor
                self.HexText.TextColor3 = self.TextColor
                
                self.RedSlider.Label.TextColor3 = self.TextColor
                self.RedSlider.Value.TextColor3 = self.TextColor
                self.GreenSlider.Label.TextColor3 = self.TextColor
                self.GreenSlider.Value.TextColor3 = self.TextColor
                self.BlueSlider.Label.TextColor3 = self.TextColor
                self.BlueSlider.Value.TextColor3 = self.TextColor
            end
            
            return self:AddElement(colorPicker)
        end
        
        function tab:CreateInputField(options)
            options = options or {}
            
            local inputField = {
                Text = options.Text or "Input Field",
                Placeholder = options.Placeholder or "Enter text...",
                Value = options.Value or "",
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                PlaceholderColor = options.PlaceholderColor or self.Window.Theme.TextDisabled,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                InputBackgroundColor = options.InputBackgroundColor or self.Window.Theme.Background,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnTextChanged = Event.new(),
                OnFocusLost = Event.new()
            }
            
            -- Create input field container
            inputField.Frame = Util.CreateRoundedFrame({
                Name = "InputField",
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = inputField.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create input field label
            inputField.TextLabel = Util.Create("TextLabel", {
                Name = "InputFieldText",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = inputField.Text,
                TextColor3 = inputField.TextColor,
                TextSize = inputField.TextSize,
                Font = inputField.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputField.Frame
            })
            
            -- Create input field box
            inputField.InputBox = Util.CreateRoundedFrame({
                Name = "InputBox",
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 25),
                BackgroundColor3 = inputField.InputBackgroundColor,
                BorderSizePixel = 0,
                Parent = inputField.Frame
            })
            
            -- Create input field text box
            inputField.TextBox = Util.Create("TextBox", {
                Name = "TextBox",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = inputField.Value,
                PlaceholderText = inputField.Placeholder,
                PlaceholderColor3 = inputField.PlaceholderColor,
                TextColor3 = inputField.TextColor,
                TextSize = inputField.TextSize,
                Font = inputField.Font,
                ClearTextOnFocus = false,
                Parent = inputField.InputBox
            })
            
            -- Input field functionality
            inputField.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                inputField.Value = inputField.TextBox.Text
                
                if inputField.Callback then
                    inputField.Callback(inputField.Value)
                end
                inputField.OnTextChanged:Fire(inputField.Value)
            end)
            
            inputField.TextBox.FocusLost:Connect(function(enterPressed)
                inputField.OnFocusLost:Fire(inputField.Value, enterPressed)
            end)
            
            function inputField:SetValue(value)
                self.Value = value
                self.TextBox.Text = value
                
                if self.Callback then
                    self.Callback(value)
                end
                self.OnTextChanged:Fire(value)
            end
            
            function inputField:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.InputBackgroundColor = theme.Background
                self.TextColor = theme.Text
                self.PlaceholderColor = theme.TextDisabled
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.InputBox.BackgroundColor3 = self.InputBackgroundColor
                self.TextBox.TextColor3 = self.TextColor
                self.TextBox.PlaceholderColor3 = self.PlaceholderColor
            end
            
            return self:AddElement(inputField)
        end
        
        function tab:CreateToggle(options)
            options = options or {}
            
            local toggle = {
                Text = options.Text or "Toggle",
                Enabled = options.Enabled or false,
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                ToggleBackgroundColor = options.ToggleBackgroundColor or self.Window.Theme.Border,
                ToggleEnabledColor = options.ToggleEnabledColor or self.Window.Theme.Primary,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnToggle = Event.new()
            }
            
            -- Create toggle container
            toggle.Frame = Util.CreateRoundedFrame({
                Name = "Toggle",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = toggle.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create toggle label
            toggle.TextLabel = Util.Create("TextLabel", {
                Name = "ToggleText",
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = toggle.Text,
                TextColor3 = toggle.TextColor,
                TextSize = toggle.TextSize,
                Font = toggle.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggle.Frame
            })
            
            -- Create toggle background
            toggle.ToggleBackground = Util.CreateRoundedFrame({
                Name = "ToggleBackground",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = toggle.ToggleBackgroundColor,
                BorderSizePixel = 0,
                Parent = toggle.Frame
            })
            
            -- Create toggle knob
            toggle.ToggleKnob = Util.CreateRoundedFrame({
                Name = "ToggleKnob",
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Parent = toggle.ToggleBackground
            })
            
            -- Create toggle interaction area
            toggle.Interaction = Util.Create("TextButton", {
                Name = "ToggleInteraction",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = toggle.Frame
            })
            
            -- Toggle functionality
            toggle.Interaction.MouseButton1Click:Connect(function()
                toggle:SetEnabled(not toggle.Enabled)
            end)
            
            function toggle:SetEnabled(enabled)
                self.Enabled = enabled
                
                if enabled then
                    Util.Tween(self.ToggleBackground, {BackgroundColor3 = self.ToggleEnabledColor})
                    Util.Tween(self.ToggleKnob, {Position = UDim2.new(0, 22, 0.5, -8)})
                else
                    Util.Tween(self.ToggleBackground, {BackgroundColor3 = self.ToggleBackgroundColor})
                    Util.Tween(self.ToggleKnob, {Position = UDim2.new(0, 2, 0.5, -8)})
                end
                
                if self.Callback then
                    self.Callback(enabled)
                end
                self.OnToggle:Fire(enabled)
            end
            
            -- Initialize toggle state
            toggle:SetEnabled(toggle.Enabled)
            
            function toggle:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.TextColor = theme.Text
                self.ToggleBackgroundColor = theme.Border
                self.ToggleEnabledColor = theme.Primary
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                
                if self.Enabled then
                    self.ToggleBackground.BackgroundColor3 = self.ToggleEnabledColor
                else
                    self.ToggleBackground.BackgroundColor3 = self.ToggleBackgroundColor
                end
            end
            
            return self:AddElement(toggle)
        end
        
        function tab:CreateProgressBar(options)
            options = options or {}
            
            local progressBar = {
                Text = options.Text or "Progress",
                Value = options.Value or 0, -- 0 to 100
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                BarBackgroundColor = options.BarBackgroundColor or self.Window.Theme.Border,
                BarColor = options.BarColor or self.Window.Theme.Primary,
                Font = options.Font or DEFAULT_FONT,
                Parent = self,
                OnValueChanged = Event.new()
            }
            
            -- Create progress bar container
            progressBar.Frame = Util.CreateRoundedFrame({
                Name = "ProgressBar",
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = progressBar.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create progress bar label
            progressBar.TextLabel = Util.Create("TextLabel", {
                Name = "ProgressBarText",
                Size = UDim2.new(1, -20, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = progressBar.Text,
                TextColor3 = progressBar.TextColor,
                TextSize = progressBar.TextSize,
                Font = progressBar.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = progressBar.Frame
            })
            
            -- Create progress bar background
            progressBar.BarBackground = Util.CreateRoundedFrame({
                Name = "BarBackground",
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 0, 30),
                BackgroundColor3 = progressBar.BarBackgroundColor,
                BorderSizePixel = 0,
                Parent = progressBar.Frame
            })
            
            -- Create progress bar fill
            progressBar.BarFill = Util.CreateRoundedFrame({
                Name = "BarFill",
                Size = UDim2.new(progressBar.Value / 100, 0, 1, 0),
                BackgroundColor3 = progressBar.BarColor,
                BorderSizePixel = 0,
                Parent = progressBar.BarBackground
            })
            
            -- Create progress value label
            progressBar.ValueLabel = Util.Create("TextLabel", {
                Name = "ValueLabel",
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(progressBar.Value) .. "%",
                TextColor3 = progressBar.TextColor,
                TextSize = progressBar.TextSize,
                Font = progressBar.Font,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = progressBar.Frame
            })
            
            -- Progress bar functionality
            function progressBar:SetValue(value)
                value = math.clamp(value, 0, 100)
                self.Value = value
                
                Util.Tween(self.BarFill, {Size = UDim2.new(value / 100, 0, 1, 0)})
                self.ValueLabel.Text = tostring(value) .. "%"
                
                self.OnValueChanged:Fire(value)
            end
            
            function progressBar:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.TextColor = theme.Text
                self.BarBackgroundColor = theme.Border
                self.BarColor = theme.Primary
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.ValueLabel.TextColor3 = self.TextColor
                self.BarBackground.BackgroundColor3 = self.BarBackgroundColor
                self.BarFill.BackgroundColor3 = self.BarColor
            end
            
            return self:AddElement(progressBar)
        end
        
        function tab:CreateDivider(options)
            options = options or {}
            
            local divider = {
                Text = options.Text,
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.TextDisabled,
                LineColor = options.LineColor or self.Window.Theme.Border,
                Font = options.Font or DEFAULT_FONT,
                Parent = self
            }
            
            -- Create divider container
            divider.Frame = Util.Create("Frame", {
                Name = "Divider",
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create divider lines
            divider.LeftLine = Util.Create("Frame", {
                Name = "LeftLine",
                Size = UDim2.new(0.5, -10, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = divider.LineColor,
                BorderSizePixel = 0,
                Parent = divider.Frame
            })
            
            divider.RightLine = Util.Create("Frame", {
                Name = "RightLine",
                Size = UDim2.new(0.5, -10, 0, 1),
                Position = UDim2.new(0.5, 10, 0.5, 0),
                BackgroundColor3 = divider.LineColor,
                BorderSizePixel = 0,
                Parent = divider.Frame
            })
            
            -- Create divider text (if provided)
            if divider.Text then
                divider.TextLabel = Util.Create("TextLabel", {
                    Name = "DividerText",
                    Size = UDim2.new(0, 0, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Text = divider.Text,
                    TextColor3 = divider.TextColor,
                    TextSize = divider.TextSize,
                    Font = divider.Font,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Parent = divider.Frame
                })
            end
            
            function divider:SetText(text)
                if not self.TextLabel and text then
                    self.Text = text
                    self.TextLabel = Util.Create("TextLabel", {
                        Name = "DividerText",
                        Size = UDim2.new(0, 0, 1, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        BackgroundTransparency = 1,
                        Text = self.Text,
                        TextColor3 = self.TextColor,
                        TextSize = self.TextSize,
                        Font = self.Font,
                        AutomaticSize = Enum.AutomaticSize.X,
                        Parent = self.Frame
                    })
                elseif self.TextLabel and text then
                    self.Text = text
                    self.TextLabel.Text = text
                elseif self.TextLabel and not text then
                    self.Text = nil
                    self.TextLabel:Destroy()
                    self.TextLabel = nil
                end
            end
            
            function divider:ApplyTheme(theme)
                self.TextColor = theme.TextDisabled
                self.LineColor = theme.Border
                
                self.LeftLine.BackgroundColor3 = self.LineColor
                self.RightLine.BackgroundColor3 = self.LineColor
                
                if self.TextLabel then
                    self.TextLabel.TextColor3 = self.TextColor
                end
            end
            
            return self:AddElement(divider)
        end
        
        function tab:CreateImageLabel(options)
            options = options or {}
            
            local imageLabel = {
                Image = options.Image,
                Size = options.Size or UDim2.new(0, 100, 0, 100),
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                BackgroundTransparency = options.BackgroundTransparency or 0,
                ImageColor = options.ImageColor or Color3.fromRGB(255, 255, 255),
                ImageTransparency = options.ImageTransparency or 0,
                ScaleType = options.ScaleType or Enum.ScaleType.Stretch,
                Parent = self
            }
            
            -- Create image label container
            imageLabel.Frame = Util.CreateRoundedFrame({
                Name = "ImageLabel",
                Size = UDim2.new(1, 0, 0, imageLabel.Size.Y.Offset + 20),
                BackgroundColor3 = imageLabel.BackgroundColor,
                BackgroundTransparency = imageLabel.BackgroundTransparency,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create image
            imageLabel.Image = Util.Create("ImageLabel", {
                Name = "Image",
                Size = imageLabel.Size,
                Position = UDim2.new(0.5, 0, 0, 10),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundTransparency = 1,
                Image = imageLabel.Image,
                ImageColor3 = imageLabel.ImageColor,
                ImageTransparency = imageLabel.ImageTransparency,
                ScaleType = imageLabel.ScaleType,
                Parent = imageLabel.Frame
            })
            
            function imageLabel:SetImage(image)
                self.Image.Image = image
            end
            
            function imageLabel:SetImageColor(color)
                self.ImageColor = color
                self.Image.ImageColor3 = color
            end
            
            function imageLabel:SetImageTransparency(transparency)
                self.ImageTransparency = transparency
                self.Image.ImageTransparency = transparency
            end
            
            function imageLabel:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.Frame.BackgroundColor3 = self.BackgroundColor
            end
            
            return self:AddElement(imageLabel)
        end
        
        function tab:CreateKeybind(options)
            options = options or {}
            
            local keybind = {
                Text = options.Text or "Keybind",
                Key = options.Key or Enum.KeyCode.Unknown,
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                KeyBackgroundColor = options.KeyBackgroundColor or self.Window.Theme.Background,
                Font = options.Font or DEFAULT_FONT,
                Callback = options.Callback,
                Parent = self,
                OnKeyChanged = Event.new(),
                Listening = false
            }
            
            -- Create keybind container
            keybind.Frame = Util.CreateRoundedFrame({
                Name = "Keybind",
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = keybind.BackgroundColor,
                BorderSizePixel = 0,
                LayoutOrder = #self.Elements,
                Parent = self.Content
            })
            
            -- Create keybind label
            keybind.TextLabel = Util.Create("TextLabel", {
                Name = "KeybindText",
                Size = UDim2.new(1, -110, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = keybind.Text,
                TextColor3 = keybind.TextColor,
                TextSize = keybind.TextSize,
                Font = keybind.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = keybind.Frame
            })
            
            -- Create keybind button
            keybind.KeyButton = Util.CreateRoundedFrame({
                Name = "KeyButton",
                Size = UDim2.new(0, 90, 0, 24),
                Position = UDim2.new(1, -100, 0.5, -12),
                BackgroundColor3 = keybind.KeyBackgroundColor,
                BorderSizePixel = 0,
                Parent = keybind.Frame
            })
            
            -- Create keybind text
            keybind.KeyText = Util.Create("TextLabel", {
                Name = "KeyText",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = keybind.Key == Enum.KeyCode.Unknown and "None" or keybind.Key.Name,
                TextColor3 = keybind.TextColor,
                TextSize = keybind.TextSize,
                Font = keybind.Font,
                Parent = keybind.KeyButton
            })
            
            -- Create keybind interaction
            keybind.Interaction = Util.Create("TextButton", {
                Name = "KeybindInteraction",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = keybind.KeyButton
            })
            
            -- Keybind functionality
            keybind.Interaction.MouseButton1Click:Connect(function()
                keybind:StartListening()
            end)
            
            -- Global input handling for keybind
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                -- Check if we're listening for a new key
                if keybind.Listening then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        keybind:SetKey(input.KeyCode)
                        keybind:StopListening()
                    end
                    return
                end
                
                -- Check if the pressed key matches our keybind
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keybind.Key and keybind.Key ~= Enum.KeyCode.Unknown then
                    if keybind.Callback then
                        keybind.Callback()
                    end
                end
            end)
            
            function keybind:StartListening()
                self.Listening = true
                self.KeyText.Text = "..."
            end
            
            function keybind:StopListening()
                self.Listening = false
            end
            
            function keybind:SetKey(key)
                self.Key = key
                self.KeyText.Text = key == Enum.KeyCode.Unknown and "None" or key.Name
                
                self.OnKeyChanged:Fire(key)
            end
            
            function keybind:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.KeyBackgroundColor = theme.Background
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
                self.KeyButton.BackgroundColor3 = self.KeyBackgroundColor
                self.KeyText.TextColor3 = self.TextColor
            end
            
            return self:AddElement(keybind)
        end
        
        function tab:CreateTooltip(options)
            options = options or {}
            
            local tooltip = {
                Text = options.Text or "Tooltip",
                TextSize = options.TextSize or DEFAULT_TEXT_SIZE - 2,
                TextColor = options.TextColor or self.Window.Theme.Text,
                BackgroundColor = options.BackgroundColor or self.Window.Theme.BackgroundSecondary,
                Font = options.Font or DEFAULT_FONT,
                Parent = self
            }
            
            -- Create tooltip container
            tooltip.Frame = Util.CreateRoundedFrame({
                Name = "Tooltip",
                Size = UDim2.new(0, 200, 0, 30),
                BackgroundColor3 = tooltip.BackgroundColor,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 1000,
                Parent = self.Window.Parent.ScreenGui
            })
            
            -- Create tooltip text
            tooltip.TextLabel = Util.Create("TextLabel", {
                Name = "TooltipText",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = tooltip.Text,
                TextColor3 = tooltip.TextColor,
                TextSize = tooltip.TextSize,
                Font = tooltip.Font,
                TextWrapped = true,
                ZIndex = 1001,
                Parent = tooltip.Frame
            })
            
            -- Tooltip functionality
            function tooltip:Show(position)
                -- Calculate text size and adjust tooltip size
                local textSize = Util.GetTextSize(self.Text, self.TextSize, self.Font, Vector2.new(190, 1000))
                self.Frame.Size = UDim2.new(0, 200, 0, textSize.Y + 10)
                
                -- Position tooltip
                self.Frame.Position = UDim2.new(0, position.X + 10, 0, position.Y + 10)
                
                -- Make sure tooltip is within screen bounds
                local screenSize = self.Window.Parent.ScreenGui.AbsoluteSize
                local tooltipSize = self.Frame.AbsoluteSize
                local tooltipPosition = self.Frame.AbsolutePosition
                
                if tooltipPosition.X + tooltipSize.X > screenSize.X then
                    self.Frame.Position = UDim2.new(0, position.X - tooltipSize.X - 10, 0, tooltipPosition.Y)
                end
                
                if tooltipPosition.Y + tooltipSize.Y > screenSize.Y then
                    self.Frame.Position = UDim2.new(0, self.Frame.Position.X.Offset, 0, position.Y - tooltipSize.Y - 10)
                end
                
                self.Frame.Visible = true
            end
            
            function tooltip:Hide()
                self.Frame.Visible = false
            end
            
            function tooltip:SetText(text)
                self.Text = text
                self.TextLabel.Text = text
            end
            
            function tooltip:ApplyTheme(theme)
                self.BackgroundColor = theme.BackgroundSecondary
                self.TextColor = theme.Text
                
                self.Frame.BackgroundColor3 = self.BackgroundColor
                self.TextLabel.TextColor3 = self.TextColor
            end
            
            -- Attach tooltip to an element
            function tooltip:AttachToElement(element)
                if element.Frame then
                    -- Mouse enter
                    if element.Interaction then
                        element.Interaction.MouseEnter:Connect(function()
                            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                            self:Show(Vector2.new(mouse.X, mouse.Y))
                        end)
                        
                        element.Interaction.MouseLeave:Connect(function()
                            self:Hide()
                        end)
                        
                        element.Interaction.MouseMoved:Connect(function(x, y)
                            if self.Frame.Visible then
                                self:Show(Vector2.new(x, y))
                            end
                        end)
                    else
                        element.Frame.MouseEnter:Connect(function()
                            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                            self:Show(Vector2.new(mouse.X, mouse.Y))
                        end)
                        
                        element.Frame.MouseLeave:Connect(function()
                            self:Hide()
                        end)
                        
                        element.Frame.MouseMoved:Connect(function(x, y)
                            if self.Frame.Visible then
                                self:Show(Vector2.new(x, y))
                            end
                        end)
                    end
                end
            end
            
            return tooltip
        end
        
        -- Tab button click handler
        tabButton.MouseButton1Click:Connect(function()
            tab:Select()
        end)
        
        -- Store tab and button
        self.Tabs[name] = tab
        self.TabButtons[name] = tabButton
        
        -- Show tab container if this is the first tab
        if #self.Tabs == 1 then
            self.TabContainer.Visible = true
            self.TabContentContainer.Size = UDim2.new(1, 0, 1, -30)
            self.TabContentContainer.Position = UDim2.new(0, 0, 0, 30)
            tab:Select()
        end
        
        return tab
    end
    
    -- Add window to parent's windows table
    table.insert(self.Parent.Windows, self)
    
    -- Fire window created event
    self.Parent.WindowCreated:Fire(self)
    
    -- Increment Z-index counter
    self.Parent.ZIndexCounter = self.Parent.ZIndexCounter + 3
    
    return self
end

-- Create notification system
function RobloxUI:CreateNotification(options)
    options = options or {}
    
    local notification = {
        Title = options.Title or "Notification",
        Text = options.Text or "",
        Duration = options.Duration or 5,
        Type = options.Type or "Info", -- Info, Success, Warning, Error
        Parent = self
    }
    
    -- Determine notification color based on type
    local notificationColor
    if notification.Type == "Success" then
        notificationColor = self.CurrentTheme.Success
    elseif notification.Type == "Warning" then
        notificationColor = self.CurrentTheme.Warning
    elseif notification.Type == "Error" then
        notificationColor = self.CurrentTheme.Error
    else
        notificationColor = self.CurrentTheme.Primary
    end
    
    -- Create notification container
    notification.Frame = Util.CreateRoundedFrame({
        Name = "Notification",
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 10, 1, -90),
        BackgroundColor3 = self.CurrentTheme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui
    })
    
    -- Create notification header
    notification.Header = Util.CreateRoundedFrame({
        Name = "NotificationHeader",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = notificationColor,
        BorderSizePixel = 0,
        Parent = notification.Frame
    })
    
    -- Create notification title
    notification.TitleLabel = Util.Create("TextLabel", {
        Name = "NotificationTitle",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = notification.Title,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE,
        Font = DEFAULT_FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification.Header
    })
    
    -- Create close button
    notification.CloseButton = Util.Create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE,
        Font = DEFAULT_FONT,
        Parent = notification.Header
    })
    
    -- Create notification text
    notification.TextLabel = Util.Create("TextLabel", {
        Name = "NotificationText",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = notification.Text,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE - 2,
        Font = DEFAULT_FONT,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification.Frame
    })
    
    -- Create progress bar
    notification.ProgressBar = Util.Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = notificationColor,
        BorderSizePixel = 0,
        Parent = notification.Frame
    })
    
    -- Close button functionality
    notification.CloseButton.MouseButton1Click:Connect(function()
        notification:Close()
    end)
    
    -- Notification methods
    function notification:Show()
        -- Animate in
        self.Frame.Position = UDim2.new(1, 10, 1, -90)
        Util.Tween(self.Frame, {Position = UDim2.new(1, -310, 1, -90)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Start progress bar
        Util.Tween(self.ProgressBar, {Size = UDim2.new(0, 0, 0, 2)}, self.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In).Completed:Connect(function()
            self:Close()
        end)
    end
    
    function notification:Close()
        Util.Tween(self.Frame, {Position = UDim2.new(1, 10, 1, -90)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
            self.Frame:Destroy()
        end)
    end
    
    -- Show notification
    notification:Show()
    
    return notification
end

-- Create tooltip system
function RobloxUI:CreateTooltip(options)
    options = options or {}
    
    local tooltip = {
        Text = options.Text or "Tooltip",
        TextSize = options.TextSize or DEFAULT_TEXT_SIZE - 2,
        TextColor = options.TextColor or self.CurrentTheme.Text,
        BackgroundColor = options.BackgroundColor or self.CurrentTheme.BackgroundSecondary,
        Font = options.Font or DEFAULT_FONT,
        Parent = self
    }
    
    -- Create tooltip container
    tooltip.Frame = Util.CreateRoundedFrame({
        Name = "Tooltip",
        Size = UDim2.new(0, 200, 0, 30),
        BackgroundColor3 = tooltip.BackgroundColor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000,
        Parent = self.ScreenGui
    })
    
    -- Create tooltip text
    tooltip.TextLabel = Util.Create("TextLabel", {
        Name = "TooltipText",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = tooltip.Text,
        TextColor3 = tooltip.TextColor,
        TextSize = tooltip.TextSize,
        Font = tooltip.Font,
        TextWrapped = true,
        ZIndex = 1001,
        Parent = tooltip.Frame
    })
    
    -- Tooltip functionality
    function tooltip:Show(position)
        -- Calculate text size and adjust tooltip size
        local textSize = Util.GetTextSize(self.Text, self.TextSize, self.Font, Vector2.new(190, 1000))
        self.Frame.Size = UDim2.new(0, 200, 0, textSize.Y + 10)
        
        -- Position tooltip
        self.Frame.Position = UDim2.new(0, position.X + 10, 0, position.Y + 10)
        
        -- Make sure tooltip is within screen bounds
        local screenSize = self.Parent.ScreenGui.AbsoluteSize
        local tooltipSize = self.Frame.AbsoluteSize
        local tooltipPosition = self.Frame.AbsolutePosition
        
        if tooltipPosition.X + tooltipSize.X > screenSize.X then
            self.Frame.Position = UDim2.new(0, position.X - tooltipSize.X - 10, 0, tooltipPosition.Y)
        end
        
        if tooltipPosition.Y + tooltipSize.Y > screenSize.Y then
            self.Frame.Position = UDim2.new(0, self.Frame.Position.X.Offset, 0, position.Y - tooltipSize.Y - 10)
        end
        
        self.Frame.Visible = true
    end
    
    function tooltip:Hide()
        self.Frame.Visible = false
    end
    
    function tooltip:SetText(text)
        self.Text = text
        self.TextLabel.Text = text
    end
    
    function tooltip:ApplyTheme(theme)
        self.BackgroundColor = theme.BackgroundSecondary
        self.TextColor = theme.Text
        
        self.Frame.BackgroundColor3 = self.BackgroundColor
        self.TextLabel.TextColor3 = self.TextColor
    end
    
    -- Attach tooltip to an element
    function tooltip:AttachToElement(element)
        if element.Frame then
            -- Mouse enter
            if element.Interaction then
                element.Interaction.MouseEnter:Connect(function()
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    self:Show(Vector2.new(mouse.X, mouse.Y))
                end)
                
                element.Interaction.MouseLeave:Connect(function()
                    self:Hide()
                end)
                
                element.Interaction.MouseMoved:Connect(function(x, y)
                    if self.Frame.Visible then
                        self:Show(Vector2.new(x, y))
                    end
                end)
            else
                element.Frame.MouseEnter:Connect(function()
                    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    self:Show(Vector2.new(mouse.X, mouse.Y))
                end)
                
                element.Frame.MouseLeave:Connect(function()
                    self:Hide()
                end)
                
                element.Frame.MouseMoved:Connect(function(x, y)
                    if self.Frame.Visible then
                        self:Show(Vector2.new(x, y))
                    end
                end)
            end
        end
    end
    
    return tooltip
end

-- Create modal dialog
function RobloxUI:CreateModal(options)
    options = options or {}
    
    local modal = {
        Title = options.Title or "Modal Dialog",
        Text = options.Text or "",
        ButtonText = options.ButtonText or "OK",
        ShowCancel = options.ShowCancel ~= false,
        CancelText = options.CancelText or "Cancel",
        Callback = options.Callback,
        CancelCallback = options.CancelCallback,
        Parent = self
    }
    
    -- Create modal background (overlay)
    modal.Background = Util.Create("Frame", {
        Name = "ModalBackground",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 1000,
        Parent = self.ScreenGui
    })
    
    -- Create modal container
    modal.Frame = Util.CreateRoundedFrame({
        Name = "Modal",
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundColor3 = self.CurrentTheme.Background,
        BorderSizePixel = 0,
        ZIndex = 1001,
        Parent = modal.Background
    })
    
    -- Create modal title
    modal.TitleLabel = Util.Create("TextLabel", {
        Name = "ModalTitle",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = modal.Title,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE + 4,
        Font = DEFAULT_FONT,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 1002,
        Parent = modal.Frame
    })
    
    -- Create modal text
    modal.TextLabel = Util.Create("TextLabel", {
        Name = "ModalText",
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 60),
        BackgroundTransparency = 1,
        Text = modal.Text,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE,
        Font = DEFAULT_FONT,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1002,
        Parent = modal.Frame
    })
    
    -- Create OK button
    modal.OkButton = Util.CreateRoundedFrame({
        Name = "OkButton",
        Size = UDim2.new(0, 100, 0, 30),
        Position = modal.ShowCancel and UDim2.new(0.75, -50, 0, 150) or UDim2.new(0.5, -50, 0, 150),
        BackgroundColor3 = self.CurrentTheme.Primary,
        BorderSizePixel = 0,
        ZIndex = 1002,
        Parent = modal.Frame
    })
    
    modal.OkText = Util.Create("TextLabel", {
        Name = "OkText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = modal.ButtonText,
        TextColor3 = self.CurrentTheme.Text,
        TextSize = DEFAULT_TEXT_SIZE,
        Font = DEFAULT_FONT,
        ZIndex = 1003,
        Parent = modal.OkButton
    })
    
    modal.OkInteraction = Util.Create("TextButton", {
        Name = "OkInteraction",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 1003,
        Parent = modal.OkButton
    })
    
    -- Create Cancel button if needed
    if modal.ShowCancel then
        modal.CancelButton = Util.CreateRoundedFrame({
            Name = "CancelButton",
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(0.25, -50, 0, 150),
            BackgroundColor3 = self.CurrentTheme.BackgroundSecondary,
            BorderSizePixel = 0,
            ZIndex = 1002,
            Parent = modal.Frame
        })
        
        modal.CancelText = Util.Create("TextLabel", {
            Name = "CancelText",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = modal.CancelText,
            TextColor3 = self.CurrentTheme.Text,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            ZIndex = 1003,
            Parent = modal.CancelButton
        })
        
        modal.CancelInteraction = Util.Create("TextButton", {
            Name = "CancelInteraction",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 1003,
            Parent = modal.CancelButton
        })
        
        modal.CancelInteraction.MouseButton1Click:Connect(function()
            if modal.CancelCallback then
                modal.CancelCallback()
            end
            modal:Close()
        end)
    end
    
    -- Button functionality
    modal.OkInteraction.MouseButton1Click:Connect(function()
        if modal.Callback then
            modal.Callback()
        end
        modal:Close()
    end)
    
    -- Modal methods
    function modal:Close()
        modal.Background:Destroy()
    end
    
    return modal
end

-- Create context menu
function RobloxUI:CreateContextMenu(options)
    options = options or {}
    
    local contextMenu = {
        Items = options.Items or {},
        Parent = self,
        Visible = false
    }
    
    -- Create context menu container
    contextMenu.Frame = Util.CreateRoundedFrame({
        Name = "ContextMenu",
        Size = UDim2.new(0, 150, 0, #contextMenu.Items * 30),
        BackgroundColor3 = self.CurrentTheme.Background,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000,
        Parent = self.ScreenGui
    })
    
    -- Create menu items
    for i, item in ipairs(contextMenu.Items) do
        local menuItem = Util.Create("TextButton", {
            Name = "MenuItem_" .. item.Text,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, (i-1) * 30),
            BackgroundTransparency = 1,
            Text = item.Text,
            TextColor3 = self.CurrentTheme.Text,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 1001,
            Parent = contextMenu.Frame
        })
        
        -- Add padding to text
        local padding = Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = menuItem
        })
        
        -- Hover effect
        menuItem.MouseEnter:Connect(function()
            menuItem.BackgroundTransparency = 0.8
            menuItem.BackgroundColor3 = self.CurrentTheme.Primary
        end)
        
        menuItem.MouseLeave:Connect(function()
            menuItem.BackgroundTransparency = 1
        end)
        
        -- Click handler
        menuItem.MouseButton1Click:Connect(function()
            if item.Callback then
                item.Callback()
            end
            contextMenu:Hide()
        end)
    end
    
    -- Context menu methods
    function contextMenu:Show(position)
        self.Frame.Position = UDim2.new(0, position.X, 0, position.Y)
        self.Frame.Visible = true
        self.Visible = true
        
        -- Make sure menu is within screen bounds
        local screenSize = self.Parent.ScreenGui.AbsoluteSize
        local menuSize = self.Frame.AbsoluteSize
        local menuPosition = self.Frame.AbsolutePosition
        
        if menuPosition.X + menuSize.X > screenSize.X then
            self.Frame.Position = UDim2.new(0, position.X - menuSize.X, 0, menuPosition.Y)
        end
        
        if menuPosition.Y + menuSize.Y > screenSize.Y then
            self.Frame.Position = UDim2.new(0, self.Frame.Position.X.Offset, 0, position.Y - menuSize.Y)
        end
    end
    
    function contextMenu:Hide()
        self.Frame.Visible = false
        self.Visible = false
    end
    
    function contextMenu:AddItem(item)
        table.insert(self.Items, item)
        
        -- Update menu size
        self.Frame.Size = UDim2.new(0, 150, 0, #self.Items * 30)
        
        -- Create menu item
        local menuItem = Util.Create("TextButton", {
            Name = "MenuItem_" .. item.Text,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, (#self.Items-1) * 30),
            BackgroundTransparency = 1,
            Text = item.Text,
            TextColor3 = self.Parent.CurrentTheme.Text,
            TextSize = DEFAULT_TEXT_SIZE,
            Font = DEFAULT_FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 1001,
            Parent = self.Frame
        })
        
        -- Add padding to text
        local padding = Util.Create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            Parent = menuItem
        })
        
        -- Hover effect
        menuItem.MouseEnter:Connect(function()
            menuItem.BackgroundTransparency = 0.8
            menuItem.BackgroundColor3 = self.Parent.CurrentTheme.Primary
        end)
        
        menuItem.MouseLeave:Connect(function()
            menuItem.BackgroundTransparency = 1
        end)
        
        -- Click handler
        menuItem.MouseButton1Click:Connect(function()
            if item.Callback then
                item.Callback()
            end
            self:Hide()
        end)
    end
    
    -- Hide menu when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and contextMenu.Visible then
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local menuPos = contextMenu.Frame.AbsolutePosition
            local menuSize = contextMenu.Frame.AbsoluteSize
            
            if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
               mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                contextMenu:Hide()
            end
        end
    end)
    
    return contextMenu
end

-- Return the library
return RobloxUI
