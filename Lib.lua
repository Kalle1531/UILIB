--[[
	Custom UI Library
	Inspired by Rayfield
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local Library = {
    WindowCount = 0,
    Windows = {},
    Flags = {},
    Theme = "Default",
    Themes = {
        Default = {
            WindowBackground = Color3.fromRGB(25, 25, 25),
            TopBar = Color3.fromRGB(35, 35, 35),
            TabBackground = Color3.fromRGB(30, 30, 30),
            TabSelected = Color3.fromRGB(45, 45, 45),
            TabUnselected = Color3.fromRGB(30, 30, 30),
            TextColor = Color3.fromRGB(240, 240, 240),
            SecondaryText = Color3.fromRGB(180, 180, 180),
            AccentColor = Color3.fromRGB(0, 120, 215),
            ComponentBackground = Color3.fromRGB(35, 35, 35),
            BorderColor = Color3.fromRGB(50, 50, 50),
        },
        Dark = {
            WindowBackground = Color3.fromRGB(15, 15, 15),
            TopBar = Color3.fromRGB(20, 20, 20),
            TabBackground = Color3.fromRGB(18, 18, 18),
            TabSelected = Color3.fromRGB(30, 30, 30),
            TabUnselected = Color3.fromRGB(18, 18, 18),
            TextColor = Color3.fromRGB(255, 255, 255),
            SecondaryText = Color3.fromRGB(160, 160, 160),
            AccentColor = Color3.fromRGB(80, 150, 255),
            ComponentBackground = Color3.fromRGB(25, 25, 25),
            BorderColor = Color3.fromRGB(40, 40, 40),
        }
    }
}

-- Utilities
local Utils = {}

function Utils.Tween(object, time, properties)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

function Utils.Drag(frame, dragHandle)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    dragHandle.InputBegan:Connect(function(input)
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

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Main Library Functions
function Library:CreateWindow(options)
    local window = setmetatable({}, {__index = Library})
    window.Name = options.Name or "Library Window"
    window.Theme = options.Theme or "Default"
    window.CurrentTheme = Library.Themes[window.Theme] or Library.Themes.Default
    window.Tabs = {}
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UI_Lib_" .. Library.WindowCount
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success, err = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Window Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.BackgroundColor3 = window.CurrentTheme.WindowBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = window.CurrentTheme.BorderColor
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = window.CurrentTheme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local TopCover = Instance.new("Frame")
    TopCover.Name = "TopCover"
    TopCover.Position = UDim2.new(0, 0, 1, -5)
    TopCover.Size = UDim2.new(1, 0, 0, 5)
    TopCover.BackgroundColor3 = window.CurrentTheme.TopBar
    TopCover.BorderSizePixel = 0
    TopCover.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = window.Name
    Title.TextColor3 = window.CurrentTheme.TextColor
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = window.CurrentTheme.TabBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 5)
    SidebarPadding.PaddingLeft = UDim.new(0, 5)
    SidebarPadding.PaddingRight = UDim.new(0, 5)
    SidebarPadding.Parent = Sidebar
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar

    -- Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -130, 1, -40)
    Container.Position = UDim2.new(0, 130, 0, 40)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    Utils.Drag(MainFrame, TopBar)

    local ToggleKey = options.ToggleUIKeybind or Enum.KeyCode.K
    if type(ToggleKey) == "string" then
        ToggleKey = Enum.KeyCode[ToggleKey]
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    Library.WindowCount = Library.WindowCount + 1
    
    function window:CreateTab(name, icon)
        local tab = {Name = name, Active = false}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_Button"
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = window.CurrentTheme.TabUnselected
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = window.CurrentTheme.SecondaryText
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Parent = Sidebar
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = name .. "_Container"
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.BackgroundTransparency = 1
        TabContainer.Visible = false
        TabContainer.ScrollBarThickness = 2
        TabContainer.Parent = Container
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingTop = UDim.new(0, 10)
        TabPadding.PaddingLeft = UDim.new(0, 10)
        TabPadding.PaddingRight = UDim.new(0, 10)
        TabPadding.Parent = TabContainer
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.Parent = TabContainer

        local function SelectTab()
            for _, t in pairs(window.Tabs) do
                t.Active = false
                t.Button.BackgroundColor3 = window.CurrentTheme.TabUnselected
                t.Button.TextColor3 = window.CurrentTheme.SecondaryText
                t.Container.Visible = false
            end
            tab.Active = true
            TabButton.BackgroundColor3 = window.CurrentTheme.TabSelected
            TabButton.TextColor3 = window.CurrentTheme.TextColor
            TabContainer.Visible = true
        end

        TabButton.MouseButton1Click:Connect(SelectTab)
        
        tab.Button = TabButton
        tab.Container = TabContainer
        table.insert(window.Tabs, tab)
        
        if #window.Tabs == 1 then SelectTab() end

        function tab:CreateButton(options)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = window.CurrentTheme.ComponentBackground
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.Parent = TabContainer
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name or "Button"
            label.TextColor3 = window.CurrentTheme.TextColor
            label.TextSize = 14
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                Utils.Tween(btn, 0.1, {BackgroundColor3 = window.CurrentTheme.TabSelected})
                task.wait(0.1)
                Utils.Tween(btn, 0.1, {BackgroundColor3 = window.CurrentTheme.ComponentBackground})
                if options.Callback then options.Callback() end
            end)
            return {Set = function(_, val) label.Text = val end}
        end

        function tab:CreateToggle(options)
            local toggle = {Value = options.CurrentValue or false}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = window.CurrentTheme.ComponentBackground
            btn.BorderSizePixel = 0
            btn.Text = ""
            btn.Parent = TabContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name or "Toggle"
            label.TextColor3 = window.CurrentTheme.TextColor
            label.TextSize = 14
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = btn
            
            local outer = Instance.new("Frame")
            outer.Size = UDim2.new(0, 40, 0, 20)
            outer.Position = UDim2.new(1, -50, 0.5, -10)
            outer.BackgroundColor3 = toggle.Value and window.CurrentTheme.AccentColor or Color3.fromRGB(60, 60, 60)
            outer.Parent = btn
            Instance.new("UICorner", outer).CornerRadius = UDim.new(1, 0)
            
            local inner = Instance.new("Frame")
            inner.Size = UDim2.new(0, 16, 0, 16)
            inner.Position = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            inner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            inner.Parent = outer
            Instance.new("UICorner", inner).CornerRadius = UDim.new(1, 0)
            
            local function update()
                Utils.Tween(outer, 0.2, {BackgroundColor3 = toggle.Value and window.CurrentTheme.AccentColor or Color3.fromRGB(60, 60, 60)})
                Utils.Tween(inner, 0.2, {Position = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                if options.Callback then options.Callback(toggle.Value) end
            end

            btn.MouseButton1Click:Connect(function()
                toggle.Value = not toggle.Value
                update()
            end)
            function toggle:Set(val) toggle.Value = val update() end
            return toggle
        end

        function tab:CreateSlider(options)
            local slider = {Value = options.CurrentValue or options.Range[1]}
            local min, max = options.Range[1], options.Range[2]
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundColor3 = window.CurrentTheme.ComponentBackground
            frame.Parent = TabContainer
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = options.Name or "Slider"
            label.TextColor3 = window.CurrentTheme.TextColor
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = frame
            
            local valLabel = Instance.new("TextLabel")
            valLabel.Size = UDim2.new(0, 50, 0, 20)
            valLabel.Position = UDim2.new(1, -60, 0, 5)
            valLabel.BackgroundTransparency = 1
            valLabel.Text = tostring(slider.Value)
            valLabel.TextColor3 = window.CurrentTheme.SecondaryText
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.Parent = frame
            
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -20, 0, 4)
            bar.Position = UDim2.new(0, 10, 0, 35)
            bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            bar.Parent = frame
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((slider.Value - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = window.CurrentTheme.AccentColor
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            
            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 12, 0, 12)
            circle.Position = UDim2.new((slider.Value - min) / (max - min), -6, 0.5, -6)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Parent = bar
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function move(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                slider.Value = val
                valLabel.Text = tostring(val)
                Utils.Tween(fill, 0.1, {Size = UDim2.new(pos, 0, 1, 0)})
                Utils.Tween(circle, 0.1, {Position = UDim2.new(pos, -6, 0.5, -6)})
                if options.Callback then options.Callback(val) end
            end

            frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true move(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then move(input) end end)
            
            function slider:Set(val)
                val = math.clamp(val, min, max)
                local pos = (val - min) / (max - min)
                slider.Value = val
                valLabel.Text = tostring(val)
                Utils.Tween(fill, 0.2, {Size = UDim2.new(pos, 0, 1, 0)})
                Utils.Tween(circle, 0.2, {Position = UDim2.new(pos, -6, 0.5, -6)})
                if options.Callback then options.Callback(val) end
            end
            return slider
        end

        function tab:CreateDropdown(options)
            local dropdown = {Value = options.CurrentOption or options.Options[1]}
            local opened = false
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = window.CurrentTheme.ComponentBackground
            btn.Text = ""
            btn.ClipsDescendants = true
            btn.Parent = TabContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 0, 40)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = (options.Name or "Dropdown") .. ": " .. tostring(dropdown.Value)
            label.TextColor3 = window.CurrentTheme.TextColor
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = btn

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -10, 0, #options.Options * 30)
            container.Position = UDim2.new(0, 5, 0, 40)
            container.BackgroundTransparency = 1
            container.Visible = false
            container.Parent = btn
            Instance.new("UIListLayout", container).Padding = UDim.new(0, 2)

            for _, opt in pairs(options.Options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.BackgroundColor3 = window.CurrentTheme.TabUnselected
                optBtn.Text = tostring(opt)
                optBtn.TextColor3 = window.CurrentTheme.SecondaryText
                optBtn.Parent = container
                Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                optBtn.MouseButton1Click:Connect(function()
                    dropdown.Value = opt
                    label.Text = (options.Name or "Dropdown") .. ": " .. tostring(opt)
                    opened = false
                    Utils.Tween(btn, 0.2, {Size = UDim2.new(1, 0, 0, 40)})
                    container.Visible = false
                    if options.Callback then options.Callback(opt) end
                end)
            end

            btn.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    Utils.Tween(btn, 0.2, {Size = UDim2.new(1, 0, 0, 45 + (#options.Options * 30))})
                    container.Visible = true
                else
                    Utils.Tween(btn, 0.2, {Size = UDim2.new(1, 0, 0, 40)})
                    container.Visible = false
                end
            end)
            return dropdown
        end

        function tab:CreateColorPicker(options)
            local cp = {Color = options.Color or Color3.fromRGB(255, 0, 0)}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 40)
            btn.BackgroundColor3 = window.CurrentTheme.ComponentBackground
            btn.Text = ""
            btn.Parent = TabContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = options.Name or "Color Picker"
            label.TextColor3 = window.CurrentTheme.TextColor
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = btn
            
            local display = Instance.new("Frame")
            display.Size = UDim2.new(0, 30, 0, 20)
            display.Position = UDim2.new(1, -40, 0.5, -10)
            display.BackgroundColor3 = cp.Color
            display.Parent = btn
            Instance.new("UICorner", display).CornerRadius = UDim.new(0, 4)

            btn.MouseButton1Click:Connect(function()
                local h, s, v = Color3.toHSV(cp.Color)
                cp.Color = Color3.fromHSV((h + 0.1) % 1, s, v)
                display.BackgroundColor3 = cp.Color
                if options.Callback then options.Callback(cp.Color) end
            end)
            return cp
        end

        function tab:CreateLabel(text)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = TabContainer
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = window.CurrentTheme.TextColor
            lbl.Font = Enum.Font.SourceSansItalic
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            return {Set = function(_, val) lbl.Text = val end}
        end

        function tab:CreateSection(name)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 25)
            frame.BackgroundTransparency = 1
            frame.Parent = TabContainer
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name:upper()
            lbl.TextColor3 = window.CurrentTheme.AccentColor
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = frame
            return {Set = function(_, val) lbl.Text = val:upper() end}
        end

        function tab:CreateDivider()
            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 2)
            div.BackgroundColor3 = window.CurrentTheme.BorderColor
            div.BorderSizePixel = 0
            div.Parent = TabContainer
            return {Set = function(_, val) div.Visible = val end}
        end

        return tab
    end

    return window
end

return Library
