local CheatUI = {}
CheatUI.__index = CheatUI

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Constants
local TWEEN_SPEED = 0.3
local DEFAULT_THEME = {
    Background = Color3.fromRGB(30, 30, 30),
    Foreground = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(0, 120, 215),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 180, 180),
    Success = Color3.fromRGB(0, 180, 0),
    Warning = Color3.fromRGB(255, 180, 0),
    Error = Color3.fromRGB(255, 0, 0),
    BorderRadius = UDim.new(0, 6),
    Font = Enum.Font.SourceSansSemibold,
    TextSize = 14,
    Transparency = 0.95,
    isDarkMode = true
}

-- Utility functions
local function createTween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or TWEEN_SPEED, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    return tween
end

local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Initialize the UI
function CheatUI.new(title, theme)
    local self = setmetatable({}, CheatUI)
    
    self.theme = theme and deepCopy(theme) or deepCopy(DEFAULT_THEME)
    self.components = {}
    self.hotkeys = {}
    self.visible = true
    self.settings = {}
    
    -- Create the main UI
    self:_createMainUI(title or "Cheat Menu")
    self:_setupHotkeySystem()
    self:_loadSettings()
    
    return self
end

function CheatUI:_createMainUI(title)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "CheatUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = playerGui
    
    -- Create main frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 300, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    self.mainFrame.BackgroundColor3 = self.theme.Background
    self.mainFrame.BackgroundTransparency = 1 - self.theme.Transparency
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Active = true
    self.mainFrame.Draggable = true
    self.mainFrame.Parent = self.screenGui
    
    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.theme.BorderRadius
    corner.Parent = self.mainFrame
    
    -- Create title bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.BackgroundColor3 = self.theme.Accent
    self.titleBar.BackgroundTransparency = 1 - self.theme.Transparency
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    -- Apply corner radius to title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = self.theme.BorderRadius
    titleCorner.Parent = self.titleBar
    
    -- Create title text
    self.titleText = Instance.new("TextLabel")
    self.titleText.Name = "TitleText"
    self.titleText.Size = UDim2.new(1, -60, 1, 0)
    self.titleText.Position = UDim2.new(0, 10, 0, 0)
    self.titleText.BackgroundTransparency = 1
    self.titleText.Text = title
    self.titleText.TextColor3 = self.theme.Text
    self.titleText.Font = self.theme.Font
    self.titleText.TextSize = self.theme.TextSize + 2
    self.titleText.TextXAlignment = Enum.TextXAlignment.Left
    self.titleText.Parent = self.titleBar
    
    -- Create close button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 20, 0, 20)
    self.closeButton.Position = UDim2.new(1, -25, 0, 5)
    self.closeButton.BackgroundColor3 = self.theme.Error
    self.closeButton.BackgroundTransparency = 0.2
    self.closeButton.BorderSizePixel = 0
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = self.theme.Text
    self.closeButton.Font = self.theme.Font
    self.closeButton.TextSize = self.theme.TextSize
    self.closeButton.Parent = self.titleBar
    
    -- Apply corner radius to close button
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = self.closeButton
    
    -- Create minimize button
    self.minimizeButton = Instance.new("TextButton")
    self.minimizeButton.Name = "MinimizeButton"
    self.minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    self.minimizeButton.Position = UDim2.new(1, -50, 0, 5)
    self.minimizeButton.BackgroundColor3 = self.theme.Warning
    self.minimizeButton.BackgroundTransparency = 0.2
    self.minimizeButton.BorderSizePixel = 0
    self.minimizeButton.Text = "-"
    self.minimizeButton.TextColor3 = self.theme.Text
    self.minimizeButton.Font = self.theme.Font
    self.minimizeButton.TextSize = self.theme.TextSize
    self.minimizeButton.Parent = self.titleBar
    
    -- Apply corner radius to minimize button
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 4)
    minimizeCorner.Parent = self.minimizeButton
    
    -- Create content frame
    self.contentFrame = Instance.new("ScrollingFrame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, -20, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 10, 0, 35)
    self.contentFrame.BackgroundTransparency = 1
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.ScrollBarThickness = 4
    self.contentFrame.ScrollBarImageColor3 = self.theme.Accent
    self.contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.contentFrame.Parent = self.mainFrame
    
    -- Create UI list layout for content
    self.contentLayout = Instance.new("UIListLayout")
    self.contentLayout.Padding = UDim.new(0, 8)
    self.contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.contentLayout.Parent = self.contentFrame
    
    -- Setup event handlers
    self.closeButton.MouseButton1Click:Connect(function()
        self:toggle(false)
    end)
    
    self.minimizeButton.MouseButton1Click:Connect(function()
        self:minimize()
    end)
    
    -- Initialize minimized state
    self.isMinimized = false
    self.originalSize = self.mainFrame.Size
end

function CheatUI:_setupHotkeySystem()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.RightControl then
            -- Default toggle hotkey
            self:toggle()
        end
        
        -- Check custom hotkeys
        for action, hotkey in pairs(self.hotkeys) do
            if input.KeyCode == hotkey.keyCode then
                if hotkey.callback then
                    hotkey.callback()
                end
            end
        end
    end)
end

function CheatUI:_loadSettings()
    -- Try to load settings from player data store
    local success, result = pcall(function()
        -- This would typically use DataStoreService, but for simplicity we'll use a placeholder
        return self.settings
    end)
    
    if not success or not result then
        self.settings = {
            position = UDim2.new(0.5, -150, 0.5, -200),
            theme = deepCopy(self.theme),
            minimized = false
        }
    else
        self.settings = result
        self.mainFrame.Position = self.settings.position
        self.theme = deepCopy(self.settings.theme)
        if self.settings.minimized then
            self:minimize()
        end
    end
end

function CheatUI:_saveSettings()
    self.settings.position = self.mainFrame.Position
    self.settings.theme = deepCopy(self.theme)
    self.settings.minimized = self.isMinimized
    
    -- This would typically use DataStoreService, but for simplicity we'll just store in memory
    -- In a real implementation, you would save to a data store
end

-- UI Visibility Methods
function CheatUI:toggle(state)
    if state ~= nil then
        self.visible = state
    else
        self.visible = not self.visible
    end
    
    local transparency = self.visible and (1 - self.theme.Transparency) or 1
    local tween = createTween(self.mainFrame, {BackgroundTransparency = transparency})
    tween:Play()
    
    -- Also tween children
    for _, child in pairs(self.mainFrame:GetDescendants()) do
        if child:IsA("GuiObject") and child.Name ~= "ContentFrame" then
            local props = {}
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextBox") then
                props.BackgroundTransparency = transparency
            end
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                props.TextTransparency = transparency
            end
            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                props.ImageTransparency = transparency
            end
            
            if next(props) then
                createTween(child, props):Play()
            end
        end
    end
    
    self.screenGui.Enabled = self.visible
    self:_saveSettings()
    
    return self
end

function CheatUI:minimize()
    self.isMinimized = not self.isMinimized
    
    local targetSize
    if self.isMinimized then
        self.originalSize = self.mainFrame.Size
        targetSize = UDim2.new(0, 300, 0, 30)
    else
        targetSize = self.originalSize
    end
    
    local tween = createTween(self.mainFrame, {Size = targetSize})
    tween:Play()
    
    self.contentFrame.Visible = not self.isMinimized
    self:_saveSettings()
    
    return self
end

-- Theme Methods
function CheatUI:setTheme(theme)
    self.theme = theme and deepCopy(theme) or deepCopy(DEFAULT_THEME)
    
    -- Update UI with new theme
    self.mainFrame.BackgroundColor3 = self.theme.Background
    self.mainFrame.BackgroundTransparency = 1 - self.theme.Transparency
    self.titleBar.BackgroundColor3 = self.theme.Accent
    self.titleBar.BackgroundTransparency = 1 - self.theme.Transparency
    self.titleText.TextColor3 = self.theme.Text
    self.titleText.Font = self.theme.Font
    self.titleText.TextSize = self.theme.TextSize + 2
    
    -- Update all components with new theme
    for _, component in pairs(self.components) do
        if component.updateTheme then
            component:updateTheme(self.theme)
        end
    end
    
    self:_saveSettings()
    
    return self
end

function CheatUI:toggleDarkMode()
    local newTheme = deepCopy(self.theme)
    newTheme.isDarkMode = not newTheme.isDarkMode
    
    if newTheme.isDarkMode then
        newTheme.Background = Color3.fromRGB(30, 30, 30)
        newTheme.Foreground = Color3.fromRGB(45, 45, 45)
        newTheme.Text = Color3.fromRGB(255, 255, 255)
        newTheme.SubText = Color3.fromRGB(180, 180, 180)
    else
        newTheme.Background = Color3.fromRGB(240, 240, 240)
        newTheme.Foreground = Color3.fromRGB(220, 220, 220)
        newTheme.Text = Color3.fromRGB(30, 30, 30)
        newTheme.SubText = Color3.fromRGB(80, 80, 80)
    end
    
    self:setTheme(newTheme)
    return self
end

-- Hotkey Methods
function CheatUI:registerHotkey(action, keyCode, callback)
    self.hotkeys[action] = {
        keyCode = keyCode,
        callback = callback
    }
    return self
end

function CheatUI:unregisterHotkey(action)
    self.hotkeys[action] = nil
    return self
end

-- Notification System
function CheatUI:notify(message, type, duration)
    type = type or "info"
    duration = duration or 3
    
    local notifColors = {
        info = self.theme.Accent,
        success = self.theme.Success,
        warning = self.theme.Warning,
        error = self.theme.Error
    }
    
    -- Create notification container if it doesn't exist
    if not self.notificationContainer then
        self.notificationContainer = Instance.new("Frame")
        self.notificationContainer.Name = "NotificationContainer"
        self.notificationContainer.Size = UDim2.new(0, 250, 1, 0)
        self.notificationContainer.Position = UDim2.new(1, -260, 0, 0)
        self.notificationContainer.BackgroundTransparency = 1
        self.notificationContainer.Parent = self.screenGui
        
        local notifLayout = Instance.new("UIListLayout")
        notifLayout.Padding = UDim.new(0, 5)
        notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        notifLayout.Parent = self.notificationContainer
    end
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, -10, 0, 0)
    notification.BackgroundColor3 = notifColors[type]
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.Parent = self.notificationContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = notification
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.theme.Text
    messageLabel.Font = self.theme.Font
    messageLabel.TextSize = self.theme.TextSize
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Parent = notification
    
    -- Animate notification
    notification.Position = UDim2.new(1, 0, 0, 0)
    local appearTween = createTween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    appearTween:Play()
    
    -- Schedule removal
    task.delay(duration, function()
        local disappearTween = createTween(notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad)
        disappearTween:Play()
        disappearTween.Completed:Wait()
        notification:Destroy()
    end)
    
    return self
end

-- Loader Animation
function CheatUI:showLoader(message, callback)
    -- Create loader overlay
    local loaderOverlay = Instance.new("Frame")
    loaderOverlay.Name = "LoaderOverlay"
    loaderOverlay.Size = UDim2.new(1, 0, 1, 0)
    loaderOverlay.BackgroundColor3 = self.theme.Background
    loaderOverlay.BackgroundTransparency = 0.3
    loaderOverlay.BorderSizePixel = 0
    loaderOverlay.ZIndex = 10
    loaderOverlay.Parent = self.screenGui
    
    -- Create loader container
    local loaderContainer = Instance.new("Frame")
    loaderContainer.Name = "LoaderContainer"
    loaderContainer.Size = UDim2.new(0, 200, 0, 100)
    loaderContainer.Position = UDim2.new(0.5, -100, 0.5, -50)
    loaderContainer.BackgroundColor3 = self.theme.Foreground
    loaderContainer.BackgroundTransparency = 0.1
    loaderContainer.BorderSizePixel = 0
    loaderContainer.ZIndex = 11
    loaderContainer.Parent = loaderOverlay
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = loaderContainer
    
    -- Create spinner
    local spinner = Instance.new("Frame")
    spinner.Name = "Spinner"
    spinner.Size = UDim2.new(0, 40, 0, 40)
    spinner.Position = UDim2.new(0.5, -20, 0, 15)
    spinner.BackgroundTransparency = 1
    spinner.ZIndex = 12
    spinner.Parent = loaderContainer
    
    local spinnerImage = Instance.new("ImageLabel")
    spinnerImage.Name = "SpinnerImage"
    spinnerImage.Size = UDim2.new(1, 0, 1, 0)
    spinnerImage.BackgroundTransparency = 1
    spinnerImage.Image = "rbxassetid://4560909609" -- Loading circle asset
    spinnerImage.ImageColor3 = self.theme.Accent
    spinnerImage.ZIndex = 12
    spinnerImage.Parent = spinner
    
    -- Create message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 20)
    messageLabel.Position = UDim2.new(0, 10, 1, -30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message or "Loading..."
    messageLabel.TextColor3 = self.theme.Text
    messageLabel.Font = self.theme.Font
    messageLabel.TextSize = self.theme.TextSize
    messageLabel.ZIndex = 12
    messageLabel.Parent = loaderContainer
    
    -- Animate spinner
    local spinConnection
    spinConnection = RunService.RenderStepped:Connect(function()
        spinnerImage.Rotation = (spinnerImage.Rotation + 2) % 360
    end)
    
    -- Return a function to hide the loader
    return function(success)
        spinConnection:Disconnect()
        
        if success ~= false then
            -- Show success animation
            spinnerImage.Image = "rbxassetid://6031094670" -- Checkmark asset
            spinnerImage.ImageColor3 = self.theme.Success
            task.wait(0.5)
        end
        
        -- Fade out loader
        local fadeTween = createTween(loaderOverlay, {BackgroundTransparency = 1}, 0.3)
        fadeTween:Play()
        createTween(loaderContainer, {BackgroundTransparency = 1}, 0.3):Play()
        createTween(spinnerImage, {ImageTransparency = 1}, 0.3):Play()
        createTween(messageLabel, {TextTransparency = 1}, 0.3):Play()
        
        fadeTween.Completed:Wait()
        loaderOverlay:Destroy()
        
        if callback then
            callback(success)
        end
    end
end

-- Component Creation Methods
function CheatUI:addLabel(text, options)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = "LabelContainer"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.color or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = options.alignment or Enum.TextXAlignment.Left
    label.TextWrapped = options.wrap or false
    label.Parent = container
    
    if options.wrap then
        label.AutomaticSize = Enum.AutomaticSize.Y
        container.AutomaticSize = Enum.AutomaticSize.Y
    end
    
    local component = {
        instance = container,
        label = label,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setColor = function(self, color)
            label.TextColor3 = color
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.color or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addButton(text, callback, options)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = "ButtonContainer"
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundColor3 = options.backgroundColor or self.theme.Accent
    button.BackgroundTransparency = options.transparency or 0.1
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = options.textColor or self.theme.Text
    button.Font = options.font or self.theme.Font
    button.TextSize = options.textSize or self.theme.TextSize
    button.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = options.cornerRadius or UDim.new(0, 4)
    corner.Parent = button
    
    -- Button effects
    local originalColor = button.BackgroundColor3
    local hoverColor = options.hoverColor or originalColor:Lerp(Color3.new(1, 1, 1), 0.2)
    local pressedColor = options.pressedColor or originalColor:Lerp(Color3.new(0, 0, 0), 0.2)
    
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}, 0.1):Play()
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = originalColor}, 0.1):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        createTween(button, {BackgroundColor3 = pressedColor}, 0.1):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {BackgroundColor3 = hoverColor}, 0.1):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    
    local component = {
        instance = container,
        button = button,
        
        setText = function(self, newText)
            button.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            originalColor = options.backgroundColor or theme.Accent
            hoverColor = options.hoverColor or originalColor:Lerp(Color3.new(1, 1, 1), 0.2)
            pressedColor = options.pressedColor or originalColor:Lerp(Color3.new(0, 0, 0), 0.2)
            
            button.BackgroundColor3 = originalColor
            button.TextColor3 = options.textColor or theme.Text
            button.Font = options.font or theme.Font
            button.TextSize = options.textSize or theme.TextSize
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addToggle(text, initialState, callback, options)
    options = options or {}
    initialState = initialState or false
    
    local container = Instance.new("Frame")
    container.Name = "ToggleContainer"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "ToggleBackground"
    toggleBackground.Size = UDim2.new(0, 40, 0, 20)
    toggleBackground.Position = UDim2.new(1, -45, 0.5, -10)
    toggleBackground.BackgroundColor3 = initialState and (options.activeColor or self.theme.Success) or (options.inactiveColor or self.theme.SubText)
    toggleBackground.BorderSizePixel = 0
    toggleBackground.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggleBackground
    
    local toggleHandle = Instance.new("Frame")
    toggleHandle.Name = "ToggleHandle"
    toggleHandle.Size = UDim2.new(0, 16, 0, 16)
    toggleHandle.Position = initialState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleHandle.BackgroundColor3 = self.theme.Text
        toggleHandle.BorderSizePixel = 0
    toggleHandle.Parent = toggleBackground
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = toggleHandle
    
    -- Toggle state and interaction
    local isOn = initialState
    
    local function updateToggleVisual()
        local targetPosition = isOn and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local targetColor = isOn and (options.activeColor or self.theme.Success) or (options.inactiveColor or self.theme.SubText)
        
        createTween(toggleHandle, {Position = targetPosition}, 0.2):Play()
        createTween(toggleBackground, {BackgroundColor3 = targetColor}, 0.2):Play()
    end
    
    local function toggle()
        isOn = not isOn
        updateToggleVisual()
        
        if callback then
            callback(isOn)
        end
    end
    
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    local component = {
        instance = container,
        label = label,
        background = toggleBackground,
        handle = toggleHandle,
        
        toggle = function(self)
            toggle()
            return self
        end,
        
        setState = function(self, state)
            if isOn ~= state then
                isOn = state
                updateToggleVisual()
                
                if callback then
                    callback(isOn)
                end
            end
            return self
        end,
        
        getState = function(self)
            return isOn
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            toggleHandle.BackgroundColor3 = theme.Text
            
            local targetColor = isOn and (options.activeColor or theme.Success) or (options.inactiveColor or theme.SubText)
            toggleBackground.BackgroundColor3 = targetColor
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addSlider(text, min, max, initial, callback, options)
    options = options or {}
    min = min or 0
    max = max or 100
    initial = initial or min
    
    -- Clamp initial value
    initial = math.max(min, math.min(max, initial))
    
    local container = Instance.new("Frame")
    container.Name = "SliderContainer"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(initial)
    valueLabel.TextColor3 = options.valueColor or self.theme.SubText
    valueLabel.Font = options.font or self.theme.Font
    valueLabel.TextSize = options.textSize or self.theme.TextSize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    local sliderBackground = Instance.new("Frame")
    sliderBackground.Name = "SliderBackground"
    sliderBackground.Size = UDim2.new(1, 0, 0, 6)
    sliderBackground.Position = UDim2.new(0, 0, 0, 30)
    sliderBackground.BackgroundColor3 = options.backgroundColor or self.theme.Foreground
    sliderBackground.BorderSizePixel = 0
    sliderBackground.Parent = container
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(1, 0)
    backgroundCorner.Parent = sliderBackground
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = options.fillColor or self.theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.new(0, 14, 0, 14)
    sliderHandle.Position = UDim2.new((initial - min) / (max - min), -7, 0.5, -7)
    sliderHandle.BackgroundColor3 = options.handleColor or self.theme.Text
    sliderHandle.BorderSizePixel = 0
    sliderHandle.ZIndex = 2
    sliderHandle.Parent = sliderBackground
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    
    -- Slider functionality
    local isDragging = false
    local currentValue = initial
    
    local function updateSlider(value)
        -- Clamp value
        value = math.max(min, math.min(max, value))
        currentValue = value
        
        -- Update visuals
        local percent = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderHandle.Position = UDim2.new(percent, -7, 0.5, -7)
        
        -- Update value label
        if options.roundValues then
            valueLabel.Text = tostring(math.floor(value))
        else
            valueLabel.Text = string.format("%.1f", value)
        end
        
        -- Call callback
        if callback then
            callback(value)
        end
    end
    
    local function calculateValueFromPosition(position)
        local sliderPosition = sliderBackground.AbsolutePosition.X
        local sliderWidth = sliderBackground.AbsoluteSize.X
        local relativeX = math.clamp(position - sliderPosition, 0, sliderWidth)
        local percent = relativeX / sliderWidth
        
        return min + (max - min) * percent
    end
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(calculateValueFromPosition(input.Position.X))
        end
    end)
    
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(calculateValueFromPosition(input.Position.X))
        end
    end)
    
    local component = {
        instance = container,
        label = label,
        valueLabel = valueLabel,
        background = sliderBackground,
        fill = sliderFill,
        handle = sliderHandle,
        
        setValue = function(self, value)
            updateSlider(value)
            return self
        end,
        
        getValue = function(self)
            return currentValue
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        setRange = function(self, newMin, newMax)
            min = newMin
            max = newMax
            updateSlider(math.max(min, math.min(max, currentValue)))
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            valueLabel.TextColor3 = options.valueColor or theme.SubText
            valueLabel.Font = options.font or theme.Font
            valueLabel.TextSize = options.textSize or theme.TextSize
            
            sliderBackground.BackgroundColor3 = options.backgroundColor or theme.Foreground
            sliderFill.BackgroundColor3 = options.fillColor or theme.Accent
            sliderHandle.BackgroundColor3 = options.handleColor or theme.Text
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addCheckbox(text, initialState, callback, options)
    options = options or {}
    initialState = initialState or false
    
    local container = Instance.new("Frame")
    container.Name = "CheckboxContainer"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local checkbox = Instance.new("Frame")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = self.theme.Foreground
    checkbox.BorderSizePixel = 0
    checkbox.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkbox
    
    local checkmark = Instance.new("ImageLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
    checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://6031094670" -- Checkmark asset
    checkmark.ImageColor3 = options.checkColor or self.theme.Text
    checkmark.ImageTransparency = initialState and 0 or 1
    checkmark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Checkbox state and interaction
    local isChecked = initialState
    
    local function updateCheckbox()
        createTween(checkmark, {ImageTransparency = isChecked and 0 or 1}, 0.2):Play()
        
        if isChecked then
            createTween(checkbox, {BackgroundColor3 = options.activeColor or self.theme.Accent}, 0.2):Play()
        else
            createTween(checkbox, {BackgroundColor3 = self.theme.Foreground}, 0.2):Play()
        end
    end
    
    local function toggle()
        isChecked = not isChecked
        updateCheckbox()
        
        if callback then
            callback(isChecked)
        end
    end
    
    checkbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    label.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    local component = {
        instance = container,
        checkbox = checkbox,
        checkmark = checkmark,
        label = label,
        
        toggle = function(self)
            toggle()
            return self
        end,
        
        setState = function(self, state)
            if isChecked ~= state then
                isChecked = state
                updateCheckbox()
                
                if callback then
                    callback(isChecked)
                end
            end
            return self
        end,
        
        getState = function(self)
            return isChecked
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            checkmark.ImageColor3 = options.checkColor or theme.Text
            
            if isChecked then
                checkbox.BackgroundColor3 = options.activeColor or theme.Accent
            else
                checkbox.BackgroundColor3 = theme.Foreground
            end
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addRadioButton(text, options, initialOption, callback, uiOptions)
        uiOptions = uiOptions or {}
    
    local container = Instance.new("Frame")
    container.Name = "RadioButtonContainer"
    container.Size = UDim2.new(1, 0, 0, 30 + (#options * 25))
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = uiOptions.textColor or self.theme.Text
    label.Font = uiOptions.font or self.theme.Font
    label.TextSize = uiOptions.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(1, 0, 0, #options * 25)
    optionsContainer.Position = UDim2.new(0, 0, 0, 25)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Parent = container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = optionsContainer
    
    -- Create radio buttons
    local radioButtons = {}
    local selectedOption = initialOption or options[1]
    
    for i, option in ipairs(options) do
        local optionContainer = Instance.new("Frame")
        optionContainer.Name = "Option_" .. option
        optionContainer.Size = UDim2.new(1, 0, 0, 20)
        optionContainer.BackgroundTransparency = 1
        optionContainer.LayoutOrder = i
        optionContainer.Parent = optionsContainer
        
        local radioCircle = Instance.new("Frame")
        radioCircle.Name = "RadioCircle"
        radioCircle.Size = UDim2.new(0, 16, 0, 16)
        radioCircle.Position = UDim2.new(0, 5, 0.5, -8)
        radioCircle.BackgroundColor3 = self.theme.Foreground
        radioCircle.BorderSizePixel = 0
        radioCircle.Parent = optionContainer
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = radioCircle
        
        local innerCircle = Instance.new("Frame")
        innerCircle.Name = "InnerCircle"
        innerCircle.Size = UDim2.new(0, 8, 0, 8)
        innerCircle.Position = UDim2.new(0.5, -4, 0.5, -4)
        innerCircle.BackgroundColor3 = uiOptions.activeColor or self.theme.Accent
        innerCircle.BorderSizePixel = 0
        innerCircle.Visible = (option == selectedOption)
        innerCircle.Parent = radioCircle
        
        local innerCircleCorner = Instance.new("UICorner")
        innerCircleCorner.CornerRadius = UDim.new(1, 0)
        innerCircleCorner.Parent = innerCircle
        
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Name = "OptionLabel"
        optionLabel.Size = UDim2.new(1, -30, 1, 0)
        optionLabel.Position = UDim2.new(0, 30, 0, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Text = option
        optionLabel.TextColor3 = uiOptions.optionColor or self.theme.Text
        optionLabel.Font = uiOptions.font or self.theme.Font
        optionLabel.TextSize = (uiOptions.textSize or self.theme.TextSize) - 1
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.Parent = optionContainer
        
        -- Add to radio buttons table
        radioButtons[option] = {
            container = optionContainer,
            circle = radioCircle,
            innerCircle = innerCircle,
            label = optionLabel
        }
        
        -- Handle selection
        optionContainer.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self:_selectRadioOption(radioButtons, option, callback)
            end
        end)
    end
    
    local component = {
        instance = container,
        label = label,
        options = radioButtons,
        
        getSelected = function(self)
            return selectedOption
        end,
        
        setSelected = function(self, option)
            if radioButtons[option] then
                self:_selectRadioOption(radioButtons, option, callback)
            end
            return self
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = uiOptions.textColor or theme.Text
            label.Font = uiOptions.font or theme.Font
            label.TextSize = uiOptions.textSize or theme.TextSize
            
            for _, rb in pairs(radioButtons) do
                rb.circle.BackgroundColor3 = theme.Foreground
                rb.innerCircle.BackgroundColor3 = uiOptions.activeColor or theme.Accent
                rb.label.TextColor3 = uiOptions.optionColor or theme.Text
                rb.label.Font = uiOptions.font or theme.Font
                rb.label.TextSize = (uiOptions.textSize or theme.TextSize) - 1
            end
            return self
        end
    }
    
    -- Add method to select radio option
    function component:_selectRadioOption(radioButtons, option, callback)
        selectedOption = option
        
        for opt, rb in pairs(radioButtons) do
            rb.innerCircle.Visible = (opt == option)
        end
        
        if callback then
            callback(option)
        end
    end
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addProgressBar(text, initialValue, options)
    options = options or {}
    initialValue = math.clamp(initialValue or 0, 0, 100)
    
    local container = Instance.new("Frame")
    container.Name = "ProgressBarContainer"
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local percentLabel = Instance.new("TextLabel")
    percentLabel.Name = "PercentLabel"
    percentLabel.Size = UDim2.new(0, 50, 0, 20)
    percentLabel.Position = UDim2.new(1, -50, 0, 0)
    percentLabel.BackgroundTransparency = 1
    percentLabel.Text = initialValue .. "%"
    percentLabel.TextColor3 = options.percentColor or self.theme.SubText
    percentLabel.Font = options.font or self.theme.Font
    percentLabel.TextSize = options.textSize or self.theme.TextSize
    percentLabel.TextXAlignment = Enum.TextXAlignment.Right
    percentLabel.Parent = container
    
    local progressBackground = Instance.new("Frame")
    progressBackground.Name = "ProgressBackground"
    progressBackground.Size = UDim2.new(1, 0, 0, 10)
    progressBackground.Position = UDim2.new(0, 0, 0, 25)
    progressBackground.BackgroundColor3 = options.backgroundColor or self.theme.Foreground
    progressBackground.BorderSizePixel = 0
    progressBackground.Parent = container
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 5)
    backgroundCorner.Parent = progressBackground
    
    local progressFill = Instance.new("Frame")
    progressFill.Name = "ProgressFill"
    progressFill.Size = UDim2.new(initialValue / 100, 0, 1, 0)
    progressFill.BackgroundColor3 = options.fillColor or self.theme.Accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBackground
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 5)
    fillCorner.Parent = progressFill
    
    local component = {
        instance = container,
        label = label,
        percentLabel = percentLabel,
        background = progressBackground,
        fill = progressFill,
        value = initialValue,
        
        setValue = function(self, value, animate)
            value = math.clamp(value, 0, 100)
            self.value = value
            percentLabel.Text = math.floor(value) .. "%"
            
            if animate then
                createTween(progressFill, {Size = UDim2.new(value / 100, 0, 1, 0)}, 0.3):Play()
            else
                progressFill.Size = UDim2.new(value / 100, 0, 1, 0)
            end
            return self
        end,
        
        getValue = function(self)
            return self.value
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            percentLabel.TextColor3 = options.percentColor or theme.SubText
            percentLabel.Font = options.font or theme.Font
            percentLabel.TextSize = options.textSize or theme.TextSize
            
            progressBackground.BackgroundColor3 = options.backgroundColor or theme.Foreground
            progressFill.BackgroundColor3 = options.fillColor or theme.Accent
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addTextInput(text, placeholder, initialValue, callback, options)
    options = options or {}
    initialValue = initialValue or ""
    
    local container = Instance.new("Frame")
    container.Name = "TextInputContainer"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local inputBackground = Instance.new("Frame")
    inputBackground.Name = "InputBackground"
    inputBackground.Size = UDim2.new(1, 0, 0, 30)
    inputBackground.Position = UDim2.new(0, 0, 0, 25)
    inputBackground.BackgroundColor3 = options.backgroundColor or self.theme.Foreground
    inputBackground.BorderSizePixel = 0
    inputBackground.Parent = container
    
    local backgroundCorner = Instance.new("UICorner")
    backgroundCorner.CornerRadius = UDim.new(0, 4)
    backgroundCorner.Parent = inputBackground
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = inputBackground
    
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.Size = UDim2.new(1, 0, 1, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text = initialValue
    textBox.PlaceholderText = placeholder or ""
    textBox.TextColor3 = options.inputTextColor or self.theme.Text
    textBox.PlaceholderColor3 = options.placeholderColor or self.theme.SubText
    textBox.Font = options.font or self.theme.Font
    textBox.TextSize = options.textSize or self.theme.TextSize
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = options.clearOnFocus or false
    textBox.Parent = inputBackground
    
    -- Handle input events
    textBox.FocusLost:Connect(function(enterPressed)
        if callback then
            callback(textBox.Text, enterPressed)
        end
    end)
    
    local component = {
        instance = container,
        label = label,
        background = inputBackground,
        textBox = textBox,
        
        getText = function(self)
            return textBox.Text
        end,
        
        setText = function(self, newText)
            textBox.Text = newText
            return self
        end,
        
        setPlaceholder = function(self, newPlaceholder)
            textBox.PlaceholderText = newPlaceholder
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            inputBackground.BackgroundColor3 = options.backgroundColor or theme.Foreground
            
                        textBox.TextColor3 = options.inputTextColor or theme.Text
            textBox.PlaceholderColor3 = options.placeholderColor or theme.SubText
            textBox.Font = options.font or theme.Font
            textBox.TextSize = options.textSize or theme.TextSize
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addKeyInput(text, initialKey, callback, options)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = "KeyInputContainer"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.Size = UDim2.new(1, 0, 0, 30)
    keyButton.Position = UDim2.new(0, 0, 0, 25)
    keyButton.BackgroundColor3 = options.backgroundColor or self.theme.Foreground
    keyButton.BorderSizePixel = 0
    keyButton.Text = initialKey and tostring(initialKey) or "Click to bind key"
    keyButton.TextColor3 = options.keyTextColor or self.theme.Text
    keyButton.Font = options.font or self.theme.Font
    keyButton.TextSize = options.textSize or self.theme.TextSize
    keyButton.Parent = container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = keyButton
    
    -- Key binding functionality
    local currentKey = initialKey
    local isBinding = false
    
    keyButton.MouseButton1Click:Connect(function()
        if isBinding then return end
        
        isBinding = true
        keyButton.Text = "Press any key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyButton.Text = tostring(currentKey)
                isBinding = false
                connection:Disconnect()
                
                if callback then
                    callback(currentKey)
                end
            end
        end)
    end)
    
    local component = {
        instance = container,
        label = label,
        button = keyButton,
        
        getKey = function(self)
            return currentKey
        end,
        
        setKey = function(self, keyCode)
            currentKey = keyCode
            keyButton.Text = tostring(keyCode)
            return self
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            keyButton.BackgroundColor3 = options.backgroundColor or theme.Foreground
            keyButton.TextColor3 = options.keyTextColor or theme.Text
            keyButton.Font = options.font or theme.Font
            keyButton.TextSize = options.textSize or theme.TextSize
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addSeparator(options)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = "SeparatorContainer"
    container.Size = UDim2.new(1, 0, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.Position = UDim2.new(0, 0, 0.5, 0)
    separator.BackgroundColor3 = options.color or self.theme.SubText
    separator.BackgroundTransparency = options.transparency or 0.7
    separator.BorderSizePixel = 0
    separator.Parent = container
    
    local component = {
        instance = container,
        separator = separator,
        
        setColor = function(self, color)
            separator.BackgroundColor3 = color
            return self
        end,
        
        setTransparency = function(self, transparency)
            separator.BackgroundTransparency = transparency
            return self
        end,
        
        updateTheme = function(self, theme)
            separator.BackgroundColor3 = options.color or theme.SubText
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addSection(title, options)
    options = options or {}
    
    local container = Instance.new("Frame")
    container.Name = "SectionContainer"
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Size = UDim2.new(1, 0, 1, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = title
    sectionTitle.TextColor3 = options.textColor or self.theme.Accent
    sectionTitle.Font = options.font or self.theme.Font
    sectionTitle.TextSize = (options.textSize or self.theme.TextSize) + 2
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = container
    
    local component = {
        instance = container,
        title = sectionTitle,
        
        setText = function(self, newText)
            sectionTitle.Text = newText
            return self
        end,
        
        updateTheme = function(self, theme)
            sectionTitle.TextColor3 = options.textColor or theme.Accent
            sectionTitle.Font = options.font or theme.Font
            sectionTitle.TextSize = (options.textSize or theme.TextSize) + 2
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addDropdown(text, options, initialOption, callback, uiOptions)
    uiOptions = uiOptions or {}
    initialOption = initialOption or options[1]
    
    local container = Instance.new("Frame")
    container.Name = "DropdownContainer"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = uiOptions.textColor or self.theme.Text
    label.Font = uiOptions.font or self.theme.Font
    label.TextSize = uiOptions.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(1, 0, 0, 30)
    dropdownButton.Position = UDim2.new(0, 0, 0, 25)
    dropdownButton.BackgroundColor3 = uiOptions.backgroundColor or self.theme.Foreground
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = initialOption
    dropdownButton.TextColor3 = uiOptions.optionColor or self.theme.Text
    dropdownButton.Font = uiOptions.font or self.theme.Font
    dropdownButton.TextSize = uiOptions.textSize or self.theme.TextSize
    dropdownButton.Parent = container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = dropdownButton
    
    local arrowIcon = Instance.new("ImageLabel")
    arrowIcon.Name = "ArrowIcon"
    arrowIcon.Size = UDim2.new(0, 16, 0, 16)
    arrowIcon.Position = UDim2.new(1, -20, 0.5, -8)
    arrowIcon.BackgroundTransparency = 1
    arrowIcon.Image = "rbxassetid://6031091004" -- Down arrow asset
    arrowIcon.ImageColor3 = uiOptions.arrowColor or self.theme.Text
    arrowIcon.Parent = dropdownButton
    
    -- Create dropdown menu (initially hidden)
    local dropdownMenu = Instance.new("Frame")
    dropdownMenu.Name = "DropdownMenu"
    dropdownMenu.Size = UDim2.new(1, 0, 0, 0)
    dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
    dropdownMenu.BackgroundColor3 = uiOptions.menuBackgroundColor or self.theme.Foreground
    dropdownMenu.BorderSizePixel = 0
    dropdownMenu.Visible = false
    dropdownMenu.ZIndex = 10
    dropdownMenu.ClipsDescendants = true
    dropdownMenu.Parent = dropdownButton
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 4)
    menuCorner.Parent = dropdownMenu
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.Padding = UDim.new(0, 2)
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Parent = dropdownMenu
    
    -- Add options to dropdown menu
    local optionButtons = {}
    local selectedOption = initialOption
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. option
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.BackgroundTransparency = 1
        optionButton.Text = option
        optionButton.TextColor3 = uiOptions.optionColor or self.theme.Text
        optionButton.Font = uiOptions.font or self.theme.Font
        optionButton.TextSize = uiOptions.textSize or self.theme.TextSize
        optionButton.ZIndex = 11
        optionButton.LayoutOrder = i
        optionButton.Parent = dropdownMenu
        
        optionButton.MouseButton1Click:Connect(function()
            selectedOption = option
            dropdownButton.Text = option
            
            -- Close dropdown
            toggleDropdown(false)
            
            if callback then
                callback(option)
            end
        end)
        
        table.insert(optionButtons, optionButton)
    end
    
    -- Dropdown toggle functionality
    local isOpen = false
    
    local function toggleDropdown(state)
        if state ~= nil then
            isOpen = state
        else
            isOpen = not isOpen
        end
        
        dropdownMenu.Visible = isOpen
        
        if isOpen then
            -- Calculate menu size
            local menuHeight = #options * 27
            dropdownMenu.Size = UDim2.new(1, 0, 0, menuHeight)
            
            -- Rotate arrow
            createTween(arrowIcon, {Rotation = 180}, 0.2):Play()
        else
            -- Rotate arrow back
            createTween(arrowIcon, {Rotation = 0}, 0.2):Play()
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        toggleDropdown()
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isOpen then
            local mousePosition = UserInputService:GetMouseLocation()
            local buttonPosition = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            local menuSize = dropdownMenu.AbsoluteSize
            
            -- Check if click is outside dropdown area
            if mousePosition.X < buttonPosition.X or 
               mousePosition.X > buttonPosition.X + buttonSize.X or
               mousePosition.Y < buttonPosition.Y or
               mousePosition.Y > buttonPosition.Y + buttonSize.Y + menuSize.Y then
                toggleDropdown(false)
            end
        end
    end)
    
    local component = {
        instance = container,
        label = label,
        button = dropdownButton,
        menu = dropdownMenu,
        options = optionButtons,
        
        getSelected = function(self)
            return selectedOption
        end,
        
        setSelected = function(self, option)
            if table.find(options, option) then
                selectedOption = option
                dropdownButton.Text = option
                
                if callback then
                    callback(option)
                end
            end
            return self
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setOptions = function(self, newOptions, keepSelection)
            options = newOptions
            
            -- Clear existing options
            for _, button in ipairs(optionButtons) do
                button:Destroy()
            end
            optionButtons = {}
            
            -- Add new options
            for i, option in ipairs(newOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "Option_" .. option
                optionButton.Size = UDim2.new(1, 0, 0, 25)
                optionButton.BackgroundTransparency = 1
                optionButton.Text = option
                optionButton.TextColor3 = uiOptions.optionColor or self.theme.Text
                optionButton.Font = uiOptions.font or self.theme.Font
                                optionButton.TextSize = uiOptions.textSize or self.theme.TextSize
                optionButton.ZIndex = 11
                optionButton.LayoutOrder = i
                optionButton.Parent = dropdownMenu
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownButton.Text = option
                    
                    -- Close dropdown
                    toggleDropdown(false)
                    
                    if callback then
                        callback(option)
                    end
                end)
                
                table.insert(optionButtons, optionButton)
            end
            
            -- Update selection
            if not keepSelection or not table.find(newOptions, selectedOption) then
                selectedOption = newOptions[1]
                dropdownButton.Text = selectedOption
            end
            
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = uiOptions.textColor or theme.Text
            label.Font = uiOptions.font or theme.Font
            label.TextSize = uiOptions.textSize or theme.TextSize
            
            dropdownButton.BackgroundColor3 = uiOptions.backgroundColor or theme.Foreground
            dropdownButton.TextColor3 = uiOptions.optionColor or theme.Text
            dropdownButton.Font = uiOptions.font or theme.Font
            dropdownButton.TextSize = uiOptions.textSize or theme.TextSize
            
            arrowIcon.ImageColor3 = uiOptions.arrowColor or theme.Text
            
            dropdownMenu.BackgroundColor3 = uiOptions.menuBackgroundColor or theme.Foreground
            
            for _, button in ipairs(optionButtons) do
                button.TextColor3 = uiOptions.optionColor or theme.Text
                button.Font = uiOptions.font or theme.Font
                button.TextSize = uiOptions.textSize or theme.TextSize
            end
            
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addColorPicker(text, initialColor, callback, options)
    options = options or {}
    initialColor = initialColor or Color3.new(1, 1, 1)
    
    local container = Instance.new("Frame")
    container.Name = "ColorPickerContainer"
    container.Size = UDim2.new(1, 0, 0, 55)
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = options.textColor or self.theme.Text
    label.Font = options.font or self.theme.Font
    label.TextSize = options.textSize or self.theme.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Name = "ColorDisplay"
    colorDisplay.Size = UDim2.new(0, 40, 0, 20)
    colorDisplay.Position = UDim2.new(1, -45, 0, 0)
    colorDisplay.BackgroundColor3 = initialColor
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Parent = container
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "ColorButton"
    colorButton.Size = UDim2.new(1, 0, 0, 30)
    colorButton.Position = UDim2.new(0, 0, 0, 25)
    colorButton.BackgroundColor3 = options.backgroundColor or self.theme.Foreground
    colorButton.BorderSizePixel = 0
    colorButton.Text = "Select Color"
    colorButton.TextColor3 = options.buttonTextColor or self.theme.Text
    colorButton.Font = options.font or self.theme.Font
    colorButton.TextSize = options.textSize or self.theme.TextSize
    colorButton.Parent = container
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = colorButton
    
    -- Create color picker popup (initially hidden)
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "PickerFrame"
    pickerFrame.Size = UDim2.new(0, 200, 0, 220)
    pickerFrame.Position = UDim2.new(0.5, -100, 0, 60)
    pickerFrame.BackgroundColor3 = self.theme.Background
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 100
    pickerFrame.Parent = container
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = pickerFrame
    
    -- Color gradient
    local colorGradient = Instance.new("Frame")
    colorGradient.Name = "ColorGradient"
    colorGradient.Size = UDim2.new(1, -20, 0, 150)
    colorGradient.Position = UDim2.new(0, 10, 0, 10)
    colorGradient.BackgroundColor3 = Color3.new(1, 0, 0)
    colorGradient.BorderSizePixel = 0
    colorGradient.ZIndex = 101
    colorGradient.Parent = pickerFrame
    
    local gradientCorner = Instance.new("UICorner")
    gradientCorner.CornerRadius = UDim.new(0, 4)
    gradientCorner.Parent = colorGradient
    
    local whiteGradient = Instance.new("UIGradient")
    whiteGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    })
    whiteGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    whiteGradient.Rotation = 90
    whiteGradient.Parent = colorGradient
    
    local blackGradient = Instance.new("UIGradient")
    blackGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    })
    blackGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    blackGradient.Rotation = 0
    blackGradient.Parent = colorGradient
    
    local gradientSelector = Instance.new("Frame")
    gradientSelector.Name = "GradientSelector"
    gradientSelector.Size = UDim2.new(0, 10, 0, 10)
    gradientSelector.Position = UDim2.new(1, -5, 0, -5)
    gradientSelector.BackgroundColor3 = Color3.new(1, 1, 1)
    gradientSelector.BorderSizePixel = 0
    gradientSelector.ZIndex = 102
    gradientSelector.Parent = colorGradient
    
    local selectorCorner = Instance.new("UICorner")
    selectorCorner.CornerRadius = UDim.new(1, 0)
    selectorCorner.Parent = gradientSelector
    
    -- Hue slider
    local hueSlider = Instance.new("Frame")
    hueSlider.Name = "HueSlider"
    hueSlider.Size = UDim2.new(1, -20, 0, 20)
    hueSlider.Position = UDim2.new(0, 10, 0, 170)
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.BorderSizePixel = 0
    hueSlider.ZIndex = 101
    hueSlider.Parent = pickerFrame
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueSlider
    
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
    })
    hueGradient.Parent = hueSlider
    
    local hueSelector = Instance.new("Frame")
    hueSelector.Name = "HueSelector"
    hueSelector.Size = UDim2.new(0, 5, 1, 0)
    hueSelector.Position = UDim2.new(0, 0, 0, 0)
    hueSelector.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSelector.BorderSizePixel = 0
    hueSelector.ZIndex = 102
    hueSelector.Parent = hueSlider
    
    -- Apply button
    local applyButton = Instance.new("TextButton")
    applyButton.Name = "ApplyButton"
    applyButton.Size = UDim2.new(1, -20, 0, 25)
    applyButton.Position = UDim2.new(0, 10, 1, -35)
    applyButton.BackgroundColor3 = self.theme.Accent
    applyButton.BorderSizePixel = 0
    applyButton.Text = "Apply"
    applyButton.TextColor3 = self.theme.Text
    applyButton.Font = self.theme.Font
    applyButton.TextSize = self.theme.TextSize
    applyButton.ZIndex = 101
    applyButton.Parent = pickerFrame
    
    local applyCorner = Instance.new("UICorner")
    applyCorner.CornerRadius = UDim.new(0, 4)
    applyCorner.Parent = applyButton
    
    -- Color picker functionality
    local selectedColor = initialColor
    local hue, saturation, value = 0, 0, 1
    
    -- Convert RGB to HSV
    local function rgbToHsv(color)
        local r, g, b = color.R, color.G, color.B
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, v
        
        v = max
        
        local delta = max - min
        if max ~= 0 then
            s = delta / max
        else
            s = 0
            h = -1
            return h, s, v
        end
        
        if r == max then
            h = (g - b) / delta
        elseif g == max then
            h = 2 + (b - r) / delta
        else
            h = 4 + (r - g) / delta
        end
        
        h = h * 60
        if h < 0 then
            h = h + 360
        end
        
        return h / 360, s, v
    end
    
    -- Convert HSV to RGB
    local function hsvToRgb(h, s, v)
        local r, g, b
        
        if s == 0 then
            r, g, b = v, v, v
        else
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)
            
            i = i % 6
            
            if i == 0 then
                r, g, b = v, t, p
            elseif i == 1 then
                r, g, b = q, v, p
            elseif i == 2 then
                r, g, b = p, v, t
            elseif i == 3 then
                r, g, b = p, q, v
            elseif i == 4 then
                r, g, b = t, p, v
            elseif i == 5 then
                r, g, b = v, p, q
            end
        end
        
        return Color3.new(r, g, b)
    end
    
    -- Update color based on HSV values
    local function updateColor()
        selectedColor = hsvToRgb(hue, saturation, value)
        colorDisplay.BackgroundColor3 = selectedColor
        colorGradient.BackgroundColor3 = hsvToRgb(hue, 1, 1)
    end
    
    -- Initialize from initial color
    hue, saturation, value = rgbToHsv(initialColor)
    hueSelector.Position = UDim2.new(hue, -2.5, 0, 0)
    gradientSelector.Position = UDim2.new(saturation, -5, 1 - value, -5)
    updateColor()
    
    -- Handle hue slider interaction
    local isDraggingHue = false
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = true
            
            local relativeX = math.clamp(input.Position.X - hueSlider.AbsolutePosition.X, 0, hueSlider.AbsoluteSize.X)
            local huePercent = relativeX / hueSlider.AbsoluteSize.X
            
            hue = huePercent
            hueSelector.Position = UDim2.new(huePercent, -2.5, 0, 0)
            updateColor()
                end
    end)
    
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingHue = false
        end
    end)
    
    -- Handle color gradient interaction
    local isDraggingGradient = false
    
    colorGradient.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingGradient = true
            
            local relativeX = math.clamp(input.Position.X - colorGradient.AbsolutePosition.X, 0, colorGradient.AbsoluteSize.X)
            local relativeY = math.clamp(input.Position.Y - colorGradient.AbsolutePosition.Y, 0, colorGradient.AbsoluteSize.Y)
            
            saturation = relativeX / colorGradient.AbsoluteSize.X
            value = 1 - (relativeY / colorGradient.AbsoluteSize.Y)
            
            gradientSelector.Position = UDim2.new(saturation, -5, 1 - value, -5)
            updateColor()
        end
    end)
    
    colorGradient.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingGradient = false
        end
    end)
    
    -- Handle mouse movement for both sliders
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if isDraggingHue then
                local relativeX = math.clamp(input.Position.X - hueSlider.AbsolutePosition.X, 0, hueSlider.AbsoluteSize.X)
                local huePercent = relativeX / hueSlider.AbsoluteSize.X
                
                hue = huePercent
                hueSelector.Position = UDim2.new(huePercent, -2.5, 0, 0)
                updateColor()
            elseif isDraggingGradient then
                local relativeX = math.clamp(input.Position.X - colorGradient.AbsolutePosition.X, 0, colorGradient.AbsoluteSize.X)
                local relativeY = math.clamp(input.Position.Y - colorGradient.AbsolutePosition.Y, 0, colorGradient.AbsoluteSize.Y)
                
                saturation = relativeX / colorGradient.AbsoluteSize.X
                value = 1 - (relativeY / colorGradient.AbsoluteSize.Y)
                
                gradientSelector.Position = UDim2.new(saturation, -5, 1 - value, -5)
                updateColor()
            end
        end
    end)
    
    -- Toggle color picker visibility
    local isPickerOpen = false
    
    local function togglePicker(state)
        if state ~= nil then
            isPickerOpen = state
        else
            isPickerOpen = not isPickerOpen
        end
        
        pickerFrame.Visible = isPickerOpen
    end
    
    colorButton.MouseButton1Click:Connect(function()
        togglePicker()
    end)
    
    -- Apply button
    applyButton.MouseButton1Click:Connect(function()
        togglePicker(false)
        
        if callback then
            callback(selectedColor)
        end
    end)
    
    -- Close picker when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isPickerOpen then
            local mousePosition = UserInputService:GetMouseLocation()
            local pickerPosition = pickerFrame.AbsolutePosition
            local pickerSize = pickerFrame.AbsoluteSize
            
            -- Check if click is outside picker area
            if mousePosition.X < pickerPosition.X or 
               mousePosition.X > pickerPosition.X + pickerSize.X or
               mousePosition.Y < pickerPosition.Y or
               mousePosition.Y > pickerPosition.Y + pickerSize.Y then
                togglePicker(false)
            end
        end
    end)
    
    local component = {
        instance = container,
        label = label,
        display = colorDisplay,
        button = colorButton,
        pickerFrame = pickerFrame,
        
        getColor = function(self)
            return selectedColor
        end,
        
        setColor = function(self, color)
            selectedColor = color
            colorDisplay.BackgroundColor3 = color
            
            -- Update HSV values and selectors
            hue, saturation, value = rgbToHsv(color)
            hueSelector.Position = UDim2.new(hue, -2.5, 0, 0)
            gradientSelector.Position = UDim2.new(saturation, -5, 1 - value, -5)
            colorGradient.BackgroundColor3 = hsvToRgb(hue, 1, 1)
            
            if callback then
                callback(color)
            end
            
            return self
        end,
        
        setText = function(self, newText)
            label.Text = newText
            return self
        end,
        
        setCallback = function(self, newCallback)
            callback = newCallback
            return self
        end,
        
        updateTheme = function(self, theme)
            label.TextColor3 = options.textColor or theme.Text
            label.Font = options.font or theme.Font
            label.TextSize = options.textSize or theme.TextSize
            
            colorButton.BackgroundColor3 = options.backgroundColor or theme.Foreground
            colorButton.TextColor3 = options.buttonTextColor or theme.Text
            colorButton.Font = options.font or theme.Font
            colorButton.TextSize = options.textSize or theme.TextSize
            
            pickerFrame.BackgroundColor3 = theme.Background
            applyButton.BackgroundColor3 = theme.Accent
            applyButton.TextColor3 = theme.Text
            applyButton.Font = theme.Font
            applyButton.TextSize = theme.TextSize
            
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addImage(imageId, size, options)
    options = options or {}
    size = size or UDim2.new(1, 0, 0, 100)
    
    local container = Instance.new("Frame")
    container.Name = "ImageContainer"
    container.Size = size
    container.BackgroundTransparency = 1
    container.Parent = self.contentFrame
    
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 1
    image.Image = imageId
    image.ScaleType = options.scaleType or Enum.ScaleType.Fit
    image.ImageTransparency = options.transparency or 0
    image.Parent = container
    
    local component = {
        instance = container,
        image = image,
        
        setImage = function(self, newImageId)
            image.Image = newImageId
            return self
        end,
        
        setSize = function(self, newSize)
            container.Size = newSize
            return self
        end,
        
        setScaleType = function(self, scaleType)
            image.ScaleType = scaleType
            return self
        end,
        
        setTransparency = function(self, transparency)
            image.ImageTransparency = transparency
            return self
        end,
        
        updateTheme = function(self, theme)
            return self
        end
    }
    
    table.insert(self.components, component)
    return component
end

function CheatUI:addNotification(title, message, duration, options)
    options = options or {}
    duration = duration or 3
    
    -- Create notification container
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 250, 0, 80)
    notification.Position = UDim2.new(1, 20, 0.5, 0)
    notification.AnchorPoint = Vector2.new(0, 0.5)
    notification.BackgroundColor3 = options.backgroundColor or self.theme.Background
    notification.BorderSizePixel = 0
    notification.Parent = self.gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notification
    
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = options.borderColor or self.theme.Accent
    notifStroke.Thickness = 1
    notifStroke.Parent = notification
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = options.titleColor or self.theme.Accent
    titleLabel.Font = options.font or self.theme.Font
    titleLabel.TextSize = (options.textSize or self.theme.TextSize) + 2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = options.messageColor or self.theme.Text
    messageLabel.Font = options.font or self.theme.Font
    messageLabel.TextSize = options.textSize or self.theme.TextSize
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notification
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = options.closeColor or self.theme.SubText
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 20
    closeButton.Parent = notification
    
    -- Animation
    createTween(notification, {Position = UDim2.new(1, -20, 0.5, 0)}, 0.3, Enum.EasingStyle.Quint):Play()
    
    -- Close notification
    local function closeNotification()
        local closeTween = createTween(notification, {Position = UDim2.new(1, 300, 0.5, 0)}, 0.3, Enum.EasingStyle.Quint)
        closeTween:Play()
        closeTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close after duration
    if duration > 0 then
        task.delay(duration, closeNotification)
    end
    
    return {
        instance = notification,
        title = titleLabel,
        message = messageLabel,
        close = closeNotification
    }
end

function CheatUI:updateTheme(newTheme)
    -- Merge new theme with current theme
    for key, value in pairs(newTheme) do
        self.theme[key] = value
    end
    
    -- Update main UI elements
    self.mainFrame.BackgroundColor3 = self.theme.Background
    self.titleBar.BackgroundColor3 = self.theme.Accent
    self.titleLabel.TextColor3 = self.theme.AccentText
    self.titleLabel.Font = self.theme.Font
    self.contentFrame.BackgroundColor3 = self.theme.Background
    
    -- Update all components
    for _, component in ipairs(self.components) do
        if component.updateTheme then
            component:updateTheme(self.theme)
        end
    end
    
    return self
end

function CheatUI:setTitle(title)
    self.titleLabel.Text = title
    return self
end

function CheatUI:setPosition(position)
    self.mainFrame.Position = position
    return self
end

function CheatUI:setSize(size)
    self.mainFrame.Size = size
    return self
end

function CheatUI:setVisible(visible)
    self.gui.Enabled = visible
    return self
end

function CheatUI:toggle()
    self.gui.Enabled = not self.gui.Enabled
    return self
end

function CheatUI:destroy()
    self.gui:Destroy()
end

return CheatUI





