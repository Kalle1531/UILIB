local Lib = {}
Lib.__index = Lib

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ============================================
-- UTILITY
-- ============================================
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
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
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ============================================
-- THEME
-- ============================================
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Surface = Color3.fromRGB(30, 30, 38),
    Primary = Color3.fromRGB(0, 150, 255),
    PrimaryDark = Color3.fromRGB(0, 110, 200),
    Text = Color3.fromRGB(220, 220, 230),
    TextDim = Color3.fromRGB(140, 140, 150),
    Success = Color3.fromRGB(0, 200, 100),
    Danger = Color3.fromRGB(220, 50, 50),
    Warning = Color3.fromRGB(255, 180, 0),
    Border = Color3.fromRGB(45, 45, 55),
}

-- ============================================
-- UI BUILDERS
-- ============================================
function Lib.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Lib)
    
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "DumperUI"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.DisplayOrder = 999
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    self.main = Instance.new("Frame")
    self.main.Name = "MainWindow"
    self.main.Size = UDim2.new(0, 480, 0, 360)
    self.main.Position = UDim2.new(0.5, -240, 0.5, -180)
    self.main.BackgroundColor3 = Theme.Background
    self.main.BorderSizePixel = 0
    self.main.ClipsDescendants = true
    self.main.Parent = self.screenGui
    
    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014262763"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(20, 20, 20, 20)
    shadow.Parent = self.main
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.main
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Border
    stroke.Thickness = 1.5
    stroke.Parent = self.main
    
    -- Titlebar
    self.titlebar = Instance.new("Frame")
    self.titlebar.Name = "TitleBar"
    self.titlebar.Size = UDim2.new(1, 0, 0, 38)
    self.titlebar.BackgroundColor3 = Theme.Surface
    self.titlebar.BorderSizePixel = 0
    self.titlebar.Parent = self.main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.titlebar
    
    local titleBarStroke = Instance.new("UIStroke")
    titleBarStroke.Color = Theme.Border
    titleBarStroke.Thickness = 1
    titleBarStroke.Parent = self.titlebar
    
    -- Cover top corners only
    local topCover = Instance.new("Frame")
    topCover.Size = UDim2.new(1, 0, 0, 8)
    topCover.Position = UDim2.new(0, 0, 0, 30)
    topCover.BackgroundColor3 = Theme.Surface
    topCover.BorderSizePixel = 0
    topCover.Parent = self.titlebar
    
    -- Title text
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "Title"
    self.titleLabel.Size = UDim2.new(1, -40, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 12, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Text = opts.title or "Dumper v5.1"
    self.titleLabel.TextColor3 = Theme.Text
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Font = Enum.Font.GothamSemibold
    self.titleLabel.TextSize = 15
    self.titleLabel.Parent = self.titlebar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 5)
    closeBtn.BackgroundColor3 = Theme.Danger
    closeBtn.BackgroundTransparency = 0.7
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = self.titlebar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        self.screenGui:Destroy()
    end)
    
    -- Make draggable
    makeDraggable(self.main)
    
    -- Content container
    self.content = Instance.new("ScrollingFrame")
    self.content.Name = "Content"
    self.content.Size = UDim2.new(1, -16, 1, -50)
    self.content.Position = UDim2.new(0, 8, 0, 42)
    self.content.BackgroundTransparency = 1
    self.content.BorderSizePixel = 0
    self.content.ScrollBarThickness = 4
    self.content.ScrollBarImageColor3 = Theme.Primary
    self.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.content.Parent = self.main
    
    -- UIListLayout for content
    self.layout = Instance.new("UIListLayout")
    self.layout.Padding = UDim.new(0, 8)
    self.layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.layout.Parent = self.content
    
    self.elements = {}
    self.callbacks = {}
    self.toggleValues = {}
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.K and not input:IsModifierKeyDown() then
            self.main.Visible = not self.main.Visible
        end
    end)
    
    return self
end

-- ============================================
-- ELEMENTS
-- ============================================
function Lib:Section(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 24)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Parent = self.content
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0.65, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Theme.Primary
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, -10, 1, 0)
    label.Position = UDim2.new(0.65, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Primary
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Button(text, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. text
    btn.Size = UDim2.new(1, -8, 0, 34)
    btn.BackgroundColor3 = Theme.Primary
    btn.BackgroundTransparency = 0.8
    btn.Text = text
    btn.TextColor3 = Theme.Text
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.Parent = self.content
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Theme.Primary
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    -- Hover
    btn.MouseEnter:Connect(function()
        btn:TweenBackgroundColor(Theme.Primary, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        btn:TweenBackgroundColor(Theme.Primary:lerp(Theme.Background, 0.8), 0.3)
    end)
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Theme.PrimaryDark
        task.delay(0.1, function()
            btn.BackgroundColor3 = Theme.Primary:lerp(Theme.Background, 0.8)
        end)
        if callback then callback() end
    end)
    
    table.insert(self.elements, btn)
    return btn
end

function Lib:Toggle(text, defaultValue, callback)
    defaultValue = defaultValue or false
    
    local frame = Instance.new("Frame")
    frame.Name = "Toggle_" .. text
    frame.Size = UDim2.new(1, -8, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 40, 0, 20)
    toggleBg.Position = UDim2.new(1, -44, 0.5, -10)
    toggleBg.BackgroundColor3 = defaultValue and Theme.Primary or Color3.fromRGB(60, 60, 70)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Name = "Knob"
    toggleKnob.Size = UDim2.new(0, 16, 0, 16)
    toggleKnob.Position = UDim2.new(0, defaultValue and 21 or 2, 0.5, -8)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    local knobShadow = Instance.new("ImageLabel")
    knobShadow.Size = UDim2.new(1, 6, 1, 6)
    knobShadow.Position = UDim2.new(0, -3, 0, -3)
    knobShadow.BackgroundTransparency = 1
    knobShadow.Image = "rbxassetid://6014262763"
    knobShadow.ImageColor3 = Color3.new(0, 0, 0)
    knobShadow.ImageTransparency = 0.8
    knobShadow.ScaleType = Enum.ScaleType.Slice
    knobShadow.SliceCenter = Rect.new(20, 20, 20, 20)
    knobShadow.Parent = toggleKnob
    
    local toggled = defaultValue
    self.toggleValues[text] = toggled
    
    local function updateVisual()
        toggleBg.BackgroundColor3 = toggled and Theme.Primary or Color3.fromRGB(60, 60, 70)
        toggleKnob:TweenPosition(UDim2.new(0, toggled and 21 or 2, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end
    
    -- Click on frame
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            self.toggleValues[text] = toggled
            updateVisual()
            if callback then callback(toggled) end
        end
    end)
    
    -- Click on toggle directly
    toggleBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggled = not toggled
            self.toggleValues[text] = toggled
            updateVisual()
            if callback then callback(toggled) end
        end
    end)
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Slider(text, min, max, default, callback)
    default = default or min
    
    local frame = Instance.new("Frame")
    frame.Name = "Slider_" .. text
    frame.Size = UDim2.new(1, -8, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = self.content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Theme.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Theme.Primary
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 3)
    sliderBg.Position = UDim2.new(0, 0, 1, -6)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0, -5.5)
    knob.BackgroundColor3 = Theme.Primary
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
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
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -7, 0, -5.5)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            if callback then callback(currentValue) end
        end
    end])
    
    table.insert(self.elements, frame)
    return frame
end

function Lib:Label(text, color)
    color = color or Theme.Text
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -8, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = self.content
    
    table.insert(self.elements, label)
    return label
end

function Lib:Status(text)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 36)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = self.content
    
    local frCorner = Instance.new("UICorner")
    frCorner.CornerRadius = UDim.new(0, 6)
    frCorner.Parent = frame
    
    local frStroke = Instance.new("UIStroke")
    frStroke.Color = Theme.Border
    frStroke.Thickness = 1
    frStroke.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -12, 1, 0)
    statusLabel.Position = UDim2.new(0, 6, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = text
    statusLabel.TextColor3 = Theme.TextDim
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = frame
    
    local function setStatus(newText, newColor)
        statusLabel.Text = newText
        if newColor then statusLabel.TextColor3 = newColor end
    end
    
    table.insert(self.elements, frame)
    return setStatus
end

function Lib:Notify(text, duration)
    duration = duration or 4
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 380, 0, 40)
    notif.Position = UDim2.new(0.5, -190, 0, -50)
    notif.BackgroundColor3 = Theme.Surface
    notif.BorderSizePixel = 0
    notif.Parent = self.screenGui
    
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 8)
    nCorner.Parent = notif
    
    local nStroke = Instance.new("UIStroke")
    nStroke.Color = Theme.Primary
    nStroke.Thickness = 1
    nStroke.Parent = notif
    
    local nLabel = Instance.new("TextLabel")
    nLabel.Size = UDim2.new(1, -16, 1, 0)
    nLabel.Position = UDim2.new(0, 8, 0, 0)
    nLabel.BackgroundTransparency = 1
    nLabel.Text = text
    nLabel.TextColor3 = Theme.Text
    nLabel.TextSize = 13
    nLabel.Font = Enum.Font.Gotham
    nLabel.Parent = notif
    
    -- Animate in
    notif:TweenPosition(UDim2.new(0.5, -190, 0, 16), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    task.delay(duration, function()
        notif:TweenPosition(UDim2.new(0.5, -190, 0, -50), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true)
        task.delay(0.3, function() notif:Destroy() end)
    end)
end

return Lib
