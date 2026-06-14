local Lib = {}
Lib.__index = Lib

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ============================================
-- ENHANCED THEME WITH GRADIENTS
-- ============================================
local Theme = {
    -- Base colors
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(25, 25, 35),
    SurfaceLight = Color3.fromRGB(35, 35, 48),
    
    -- Accent colors
    Primary = Color3.fromRGB(138, 43, 226), -- Purple
    PrimaryLight = Color3.fromRGB(165, 85, 246),
    Secondary = Color3.fromRGB(0, 191, 255), -- Deep Sky Blue
    
    -- Text
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    
    -- Status colors
    Success = Color3.fromRGB(16, 185, 129),
    Danger = Color3.fromRGB(239, 68, 68),
    Warning = Color3.fromRGB(245, 158, 11),
    Info = Color3.fromRGB(59, 130, 246),
    
    -- Effects
    Border = Color3.fromRGB(60, 60, 80),
    Glow = Color3.fromRGB(138, 43, 226),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function createGradient(parent, rotation, colors)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 45
    gradient.Color = ColorSequence.new(colors or {
        ColorSequenceKeypoint.new(0, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.Secondary)
    })
    gradient.Parent = parent
    return gradient
end

local function createGlow(parent, intensity)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 60, 1, 60)
    glow.Position = UDim2.new(0.5, -30, 0.5, -30)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6014261993"
    glow.ImageColor3 = Theme.Glow
    glow.ImageTransparency = intensity or 0.7
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(100, 100, 100, 100)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

local function createBlur(parent, size)
    local blur = Instance.new("ImageLabel")
    blur.Name = "Blur"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://8992230677"
    blur.ImageColor3 = Theme.Surface
    blur.ImageTransparency = 0.3
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(99, 99, 99, 99)
    blur.Parent = parent
    return blur
end

local function tween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    
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
            tween(frame, {
                Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

local function createRipple(button, x, y)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local rippleCorner = Instance.new("UICorner")
    rippleCorner.CornerRadius = UDim.new(1, 0)
    rippleCorner.Parent = ripple
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    tween(ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- ============================================
-- MAIN UI CONSTRUCTOR
-- ============================================
function Lib.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Lib)
    
    -- ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ModernDumperUI"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.DisplayOrder = 999
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Container with glassmorphism
    self.main = Instance.new("Frame")
    self.main.Name = "MainWindow"
    self.main.Size = UDim2.new(0, 520, 0, 420)
    self.main.Position = UDim2.new(0.5, -260, 0.5, -210)
    self.main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.main.BackgroundColor3 = Theme.Background
    self.main.BackgroundTransparency = 0.15
    self.main.BorderSizePixel = 0
    self.main.ClipsDescendants = false
    self.main.ZIndex = 10
    self.main.Parent = self.screenGui
    
    -- Blur background
    createBlur(self.main)
    
    -- Rounded corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = self.main
    
    -- Border with gradient
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Theme.Border
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    mainStroke.Parent = self.main
    
    createGradient(mainStroke, 45)
    
    -- Outer glow
    createGlow(self.main, 0.5)
    
    -- Animated gradient background overlay
    local gradientBg = Instance.new("Frame")
    gradientBg.Name = "GradientOverlay"
    gradientBg.Size = UDim2.new(1, 0, 1, 0)
    gradientBg.BackgroundColor3 = Theme.Primary
    gradientBg.BackgroundTransparency = 0.95
    gradientBg.BorderSizePixel = 0
    gradientBg.ZIndex = self.main.ZIndex + 1
    gradientBg.Parent = self.main
    
    local gradientBgCorner = Instance.new("UICorner")
    gradientBgCorner.CornerRadius = UDim.new(0, 16)
    gradientBgCorner.Parent = gradientBg
    
    local animatedGradient = createGradient(gradientBg, 0)
    
    -- Rotate gradient continuously
    task.spawn(function()
        while self.screenGui.Parent do
            for i = 0, 360, 2 do
                if not self.screenGui.Parent then break end
                animatedGradient.Rotation = i
                task.wait(0.05)
            end
        end
    end)
    
    -- Title Bar
    self.titlebar = Instance.new("Frame")
    self.titlebar.Name = "TitleBar"
    self.titlebar.Size = UDim2.new(1, 0, 0, 50)
    self.titlebar.BackgroundTransparency = 1
    self.titlebar.BorderSizePixel = 0
    self.titlebar.ZIndex = self.main.ZIndex + 2
    self.titlebar.Parent = self.main
    
    -- Title with icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.new(0, 32, 0, 32)
    iconLabel.Position = UDim2.new(0, 16, 0, 9)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = "⚡"
    iconLabel.TextColor3 = Theme.Primary
    iconLabel.TextSize = 24
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.ZIndex = self.titlebar.ZIndex + 1
    iconLabel.Parent = self.titlebar
    
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "Title"
    self.titleLabel.Size = UDim2.new(1, -120, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 54, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = opts.title or "Advanced Dumper"
    self.titleLabel.TextColor3 = Theme.Text
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Font = Enum.Font.GothamBold
    self.titleLabel.TextSize = 18
    self.titleLabel.ZIndex = self.titlebar.ZIndex + 1
    self.titleLabel.Parent = self.titlebar
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -120, 0, 14)
    subtitle.Position = UDim2.new(0, 54, 0, 28)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "v6.0 • Premium Edition"
    subtitle.TextColor3 = Theme.TextDim
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.ZIndex = self.titlebar.ZIndex + 1
    subtitle.Parent = self.titlebar
    
    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "Minimize"
    minimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    minimizeBtn.Position = UDim2.new(1, -82, 0, 7)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceLight
    minimizeBtn.BackgroundTransparency = 0.3
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Theme.Text
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.ZIndex = self.titlebar.ZIndex + 1
    minimizeBtn.Parent = self.titlebar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 8)
    minCorner.Parent = minimizeBtn
    
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(self.main, {
            Size = minimized and UDim2.new(0, 520, 0, 50) or UDim2.new(0, 520, 0, 420)
        }, 0.4, Enum.EasingStyle.Back)
        minimizeBtn.Text = minimized and "+" or "−"
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -40, 0, 7)
    closeBtn.BackgroundColor3 = Theme.Danger
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = self.titlebar.ZIndex + 1
    closeBtn.Parent = self.titlebar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Hover effects for buttons
    for _, btn in ipairs({minimizeBtn, closeBtn}) do
        btn.MouseEnter:Connect(function()
            createGlow(btn, 0.4)
            tween(btn, {BackgroundTransparency = 0}, 0.2)
        end)
        
        btn.MouseLeave:Connect(function()
            local glow = btn:FindFirstChild("Glow")
            if glow then glow:Destroy() end
            tween(btn, {BackgroundTransparency = btn == closeBtn and 0.2 or 0.3}, 0.2)
        end)
        
        btn.MouseButton1Down:Connect(function()
            tween(btn, {Size = UDim2.new(0, 32, 0, 32)}, 0.1)
        end)
        
        btn.MouseButton1Up:Connect(function()
            tween(btn, {Size = UDim2.new(0, 36, 0, 36)}, 0.1)
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(function()
        tween(self.main, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.3, function()
            self.screenGui:Destroy()
        end)
    end)
    
    -- Divider line
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.Position = UDim2.new(0, 16, 0, 50)
    divider.BackgroundColor3 = Theme.Border
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.ZIndex = self.main.ZIndex + 2
    divider.Parent = self.main
    
    createGradient(divider, 90)
    
    -- Make draggable
    makeDraggable(self.main, self.titlebar)
    
    -- Content ScrollingFrame
    self.content = Instance.new("ScrollingFrame")
    self.content.Name = "Content"
    self.content.Size = UDim2.new(1, -32, 1, -70)
    self.content.Position = UDim2.new(0, 16, 0, 60)
    self.content.BackgroundTransparency = 1
    self.content.BorderSizePixel = 0
    self.content.ScrollBarThickness = 6
    self.content.ScrollBarImageColor3 = Theme.Primary
    self.content.ScrollBarImageTransparency = 0.3
    self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.content.ZIndex = self.main.ZIndex + 2
    self.content.Parent = self.main
    
    -- Content layout
    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, 12)
    self.layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.layout.Parent = self.content
    
    self.elements = {}
    self.callbacks = {}
    self.toggleValues = {}
    
    -- Entrance animation
    self.main.Size = UDim2.new(0, 0, 0, 0)
    self.main.BackgroundTransparency = 1
    tween(self.main, {
        Size = UDim2.new(0, 520, 0, 420),
        BackgroundTransparency = 0.15
    }, 0.5, Enum.EasingStyle.Back)
    
    -- Toggle visibility with INSERT key
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            self.main.Visible = not self.main.Visible
        end
    end)
    
    return self
end

-- ============================================
-- UI ELEMENTS
-- ============================================

function Lib:Section(text)
    local frame = Instance.new("Frame")
    frame.Name = "Section_" .. text
    frame.Size = UDim2.new(1, -8, 0, 32)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ZIndex = self.content.ZIndex + 1
    frame.Parent = self.content
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 4, 1, -8)
    line.Position = UDim2.new(0, 0, 0, 4)
    line.BackgroundColor3 = Theme.Primary
    line.BorderSizePixel = 0
    line.ZIndex = frame.ZIndex + 1
    line.Parent = frame
    
    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(1, 0)
    lineCorner.Parent = line
    
    createGradient(line, 90)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.ZIndex = frame.ZIndex + 1
    label.Parent = frame
    
    -- Animated gradient text (optional enhancement)
    createGradient(label, 45)
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. text
    btn.Size = UDim2.new(1, -8, 0, 44)
    btn.BackgroundColor3 = Theme.Surface
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = self.content.ZIndex + 1
    btn.Parent = self.content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Theme.Border
    btnStroke.Thickness = 1.5
    btnStroke.Transparency = 0.5
    btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    btnStroke.Parent = btn
    
    createGradient(btnStroke, 45)
    
    -- Button text
    local btnText = Instance.new("TextLabel")
    btnText.Size = UDim2.new(1, -20, 1, 0)
    btnText.Position = UDim2.new(0, 10, 0, 0)
    btnText.BackgroundTransparency = 1
    btnText.Text = text
    btnText.TextColor3 = Theme.Text
    btnText.TextSize = 14
    btnText.Font = Enum.Font.GothamSemibold
    btnText.TextXAlignment = Enum.TextXAlignment.Left
    btnText.ZIndex = btn.ZIndex + 1
    btnText.Parent = btn
    
    -- Hover gradient overlay
    local hoverOverlay = Instance.new("Frame")
    hoverOverlay.Name = "HoverOverlay"
    hoverOverlay.Size = UDim2.new(1, 0, 1, 0)
    hoverOverlay.BackgroundColor3 = Theme.Primary
    hoverOverlay.BackgroundTransparency = 1
    hoverOverlay.BorderSizePixel = 0
    hoverOverlay.ZIndex = btn.ZIndex + 1
    hoverOverlay.Parent = btn
    
    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 10)
    hoverCorner.Parent = hoverOverlay
    
    createGradient(hoverOverlay, 45)
    
    -- Interactions
    btn.MouseEnter:Connect(function()
        tween(hoverOverlay, {BackgroundTransparency = 0.85}, 0.2)
        tween(btn, {BackgroundTransparency = 0.1}, 0.2)
        createGlow(btn, 0.6)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(hoverOverlay, {BackgroundTransparency = 1}, 0.2)
        tween(btn, {BackgroundTransparency = 0.3}, 0.2)
        local glow = btn:FindFirstChild("Glow")
        if glow then glow:Destroy() end
    end)
    
    btn.MouseButton1Down:Connect(function()
        tween(btn, {Size = UDim2.new(1, -8, 0, 40)}, 0.1)
    end)
    
    btn.MouseButton1Up:Connect(function()
        tween(btn, {Size = UDim2.new(1, -8, 0, 44)}, 0.1)
    end)
    
    btn.MouseButton1Click:Connect(function()
        local abs = btn.AbsolutePosition
        local mouse = UserInputService:GetMouseLocation()
        createRipple(btn, mouse.X - abs.X, mouse.Y - abs.Y)
        
        if callback then 
            task.spawn(callback) 
        end
    end)
    
    table.insert(self.elements, btn)
    return btn
end

function Lib:Toggle(text, defaultValue, callback)
    defaultValue = defaultValue or false
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. text
    frame.Size = UDim2.new(1, -8, 0, 44)
    frame.BackgroundColor3 = Theme.Surface
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.ZIndex = self.content.ZIndex + 1
    frame.Parent = self.content
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Theme.Border
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.5
    frameStroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.ZIndex = frame.ZIndex + 1
    label.Parent = frame
    
    -- Toggle switch container
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 56, 0, 28)
    toggleBg.Position = UDim2.new(1, -68, 0.5, -14)
    toggleBg.BackgroundColor3 = defaultValue and Theme.Success or Color3.fromRGB(50, 50, 65)
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = frame.ZIndex + 1
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    -- Inner glow when active
    if defaultValue then
        createGlow(toggleBg, 0.6)
    end
    
    -- Toggle knob
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = defaultValue and UDim2.new(0, 31, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = toggleBg.ZIndex + 1
    toggleKnob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Theme.Border
    knobStroke.Thickness = 1
    knobStroke.Transparency = 0.3
    knobStroke.Parent = toggleKnob
    
    createGlow(toggleKnob, 0.8)
    
    local toggled = defaultValue
    self.toggleValues[text] = toggled
    
    local function updateToggle()
        toggled = not toggled
        self.toggleValues[text] = toggled
        
        -- Animate background
        tween(toggleBg, {
            BackgroundColor3 = toggled and Theme.Success or Color3.fromRGB(50, 50, 65)
        }, 0.3)
        
        -- Animate knob
        tween(toggleKnob, {
            Position = toggled and UDim2.new(0, 31, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        }, 0.3, Enum.EasingStyle.Back)
        
        -- Add/remove glow
        local existingGlow = toggleBg:FindFirstChild("Glow")
        if toggled and not existingGlow then
            createGlow(toggleBg, 0.6)
        elseif not toggled and existingGlow then
            existingGlow:Destroy()
        end
        
        if callback then 
            task.spawn(callback, toggled) 
        end
    end
    
    -- Click handler
    local clickButton = Instance.new("TextButton")
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.ZIndex = frame.ZIndex + 2
    clickButton.Parent = frame
    
    clickButton.MouseButton1Click:Connect(updateToggle)
    
    -- Hover effect
    clickButton.MouseEnter:Connect(function()
        tween(frame, {BackgroundTransparency = 0.1}, 0.2)
    end)
    
    clickButton.MouseLeave:Connect(function()
        tween(frame, {BackgroundTransparency = 0.3}, 0.2)
    end)
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Slider(text, min, max, default, callback)
    default = math.clamp(default or min, min, max)
    
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. text
    frame.Size = UDim2.new(1, -8, 0, 60)
    frame.BackgroundColor3 = Theme.Surface
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.ZIndex = self.content.ZIndex + 1
    frame.Parent = self.content
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Theme.Border
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.5
    frameStroke.Parent = frame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 16, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.ZIndex = frame.ZIndex + 1
    label.Parent = frame
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 10)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextSize = 15
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.ZIndex = frame.ZIndex + 1
    valueLabel.Parent = frame
    
    -- Slider track background
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, -32, 0, 6)
    sliderBg.Position = UDim2.new(0, 16, 1, -20)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = frame.ZIndex + 1
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    -- Filled portion
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.BorderSizePixel = 0
    fill.ZIndex = sliderBg.ZIndex + 1
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    createGradient(fill, 90)
    createGlow(fill, 0.5)
    
    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = fill.ZIndex + 1
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Theme.Primary
    knobStroke.Thickness = 2
    knobStroke.Parent = knob
    
    createGlow(knob, 0.4)
    
    local currentValue = default
    local dragging = false
    
    local function updateSlider(inputPos)
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize.X
        local relX = math.clamp(inputPos.X - absPos.X, 0, absSize)
        local pct = relX / absSize
        local val = math.floor(min + (max - min) * pct)
        
        currentValue = val
        valueLabel.Text = tostring(val)
        
        tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
        tween(knob, {Position = UDim2.new(pct, -9, 0.5, -9)}, 0.1, Enum.EasingStyle.Linear)
    end
    
    -- Dragging logic
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            tween(knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position)
            dragging = true
            tween(knob, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            tween(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
            if callback then 
                task.spawn(callback, currentValue) 
            end
        end
    end)
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Label(text, color)
    color = color or Theme.Text
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -8, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.ZIndex = self.content.ZIndex + 1
    label.Parent = self.content
    
    table.insert(self.elements, label)
    return label
end

function Lib:Status(text)
    local frame = Instance.new("Frame")
    frame.Name = "Status"
    frame.Size = UDim2.new(1, -8, 0, 50)
    frame.BackgroundColor3 = Theme.Surface
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.ZIndex = self.content.ZIndex + 1
    frame.Parent = self.content
    
    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame
    
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = Theme.Border
    frameStroke.Thickness = 1.5
    frameStroke.Transparency = 0.5
    frameStroke.Parent = frame
    
    -- Status icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, 12, 0.5, -16)
    icon.BackgroundTransparency = 1
    icon.Text = "ℹ"
    icon.TextColor3 = Theme.Info
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = frame.ZIndex + 1
    icon.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -56, 1, 0)
    statusLabel.Position = UDim2.new(0, 48, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = text
    statusLabel.TextColor3 = Theme.TextDim
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextWrapped = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.ZIndex = frame.ZIndex + 1
    statusLabel.Parent = frame
    
    local function setStatus(newText, statusType)
        statusLabel.Text = newText
        
        local iconMap = {
            info = {icon = "ℹ", color = Theme.Info},
            success = {icon = "✓", color = Theme.Success},
            warning = {icon = "⚠", color = Theme.Warning},
            error = {icon = "✕", color = Theme.Danger}
        }
        
        local status = iconMap[statusType] or iconMap.info
        icon.Text = status.icon
        tween(icon, {TextColor3 = status.color}, 0.2)
    end
    
    table.insert(self.elements, frame)
    return setStatus
end

function Lib:Notify(text, duration, notifType)
    duration = duration or 4
    notifType = notifType or "info"
    
    local iconMap = {
        info = {icon = "ℹ", color = Theme.Info},
        success = {icon = "✓", color = Theme.Success},
        warning = {icon = "⚠", color = Theme.Warning},
        error = {icon = "✕", color = Theme.Danger}
    }
    
    local notifData = iconMap[notifType] or iconMap.info
    
    -- Container
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 420, 0, 70)
    notif.Position = UDim2.new(1, 20, 1, -90)
    notif.AnchorPoint = Vector2.new(0, 1)
    notif.BackgroundColor3 = Theme.Surface
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = false
    notif.ZIndex = 1000
    notif.Parent = self.screenGui
    
    createBlur(notif)
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 12)
    notifCorner.Parent = notif
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = notifData.color
    notifStroke.Thickness = 2
    notifStroke.Transparency = 0.3
    notifStroke.Parent = notif
    
    createGlow(notif, 0.5)
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, -16)
    accentBar.Position = UDim2.new(0, 8, 0, 8)
    accentBar.BackgroundColor3 = notifData.color
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = notif.ZIndex + 1
    accentBar.Parent = notif
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accentBar
    
    createGradient(accentBar, 90)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 20, 0.5, -20)
    icon.BackgroundTransparency = 1
    icon.Text = notifData.icon
    icon.TextColor3 = notifData.color
    icon.TextSize = 28
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = notif.ZIndex + 1
    icon.Parent = notif
    
    -- Message
    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, -75, 1, 0)
    message.Position = UDim2.new(0, 68, 0, 0)
    message.BackgroundTransparency = 1
    message.Text = text
    message.TextColor3 = Theme.Text
    message.TextSize = 14
    message.TextXAlignment = Enum.TextXAlignment.Left
    message.TextYAlignment = Enum.TextYAlignment.Center
    message.TextWrapped = true
    message.Font = Enum.Font.Gotham
    message.ZIndex = notif.ZIndex + 1
    message.Parent = notif
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -16, 0, 3)
    progressBg.Position = UDim2.new(0, 8, 1, -6)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBg.BorderSizePixel = 0
    progressBg.ZIndex = notif.ZIndex + 1
    progressBg.Parent = notif
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBg
    
    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 1, 0)
    progress.BackgroundColor3 = notifData.color
    progress.BorderSizePixel = 0
    progress.ZIndex = progressBg.ZIndex + 1
    progress.Parent = progressBg
    
    local progressFillCorner = Instance.new("UICorner")
    progressFillCorner.CornerRadius = UDim.new(1, 0)
    progressFillCorner.Parent = progress
    
    -- Slide in
    tween(notif, {
        Position = UDim2.new(1, -430, 1, -90)
    }, 0.5, Enum.EasingStyle.Back)
    
    -- Deplete progress
    tween(progress, {
        Size = UDim2.new(0, 0, 1, 0)
    }, duration, Enum.EasingStyle.Linear)
    
    -- Slide out and destroy
    task.delay(duration, function()
        tween(notif, {
            Position = UDim2.new(1, 20, 1, -90)
        }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.delay(0.4, function()
            notif:Destroy()
        end)
    end)
    
    return notif
end

return Lib
