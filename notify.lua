local NotificationSystem = {}

-- ════════════════════════════════════════════════════════════════════════════════════════
-- SERVICES & DEPENDENCIES
-- ════════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ════════════════════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════════════

local CONFIG = {
    -- Animation settings
    FADE_IN_TIME = 0.4,
    FADE_OUT_TIME = 0.3,
    SLIDE_DISTANCE = 50,
    BOUNCE_SCALE = 1.05,
    
    -- Notification settings
    DEFAULT_DURATION = 5,
    MAX_NOTIFICATIONS = 5,
    NOTIFICATION_SPACING = 10,
    
    -- Positioning
    START_POSITION = UDim2.new(0.5, 0, 0, -100), -- Top center, off-screen
    ANCHOR_POINT = Vector2.new(0.5, 0),
    
    -- Styling
    NOTIFICATION_SIZE = UDim2.new(0, 400, 0, 80),
    CORNER_RADIUS = UDim.new(0, 12),
    STROKE_THICKNESS = 1,
    SHADOW_SIZE = UDim2.new(1, 6, 1, 6),
    
    -- Colors (RGB values)
    GRADIENT_TOP = Color3.fromRGB(45, 45, 55),
    GRADIENT_BOTTOM = Color3.fromRGB(25, 25, 35),
    STROKE_COLOR = Color3.fromRGB(70, 70, 80),
    SHADOW_COLOR = Color3.fromRGB(0, 0, 0),
    TITLE_COLOR = Color3.fromRGB(255, 255, 255),
    MESSAGE_COLOR = Color3.fromRGB(200, 200, 210),
    
    -- Fonts
    TITLE_FONT = Enum.Font.GothamBold,
    MESSAGE_FONT = Enum.Font.Gotham,
    TITLE_SIZE = 16,
    MESSAGE_SIZE = 14,
}

-- ════════════════════════════════════════════════════════════════════════════════════════
-- PRIVATE VARIABLES
-- ════════════════════════════════════════════════════════════════════════════════════════

local notificationQueue = {}
local activeNotifications = {}
local screenGui = nil
local notificationContainer = nil

-- ════════════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Create tween info for smooth animations
local function createTweenInfo(duration, easingStyle, easingDirection)
    return TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out,
        0,
        false,
        0
    )
end

-- Calculate notification position based on index
local function calculateNotificationPosition(index)
    local baseY = 20 -- Starting Y position
    local totalHeight = CONFIG.NOTIFICATION_SIZE.Y.Offset + CONFIG.NOTIFICATION_SPACING
    local finalY = baseY + (totalHeight * (index - 1))
    
    return UDim2.new(0.5, 0, 0, finalY)
end

-- Update positions of all active notifications
local function updateNotificationPositions()
    for i, notification in ipairs(activeNotifications) do
        if notification and notification.Parent then
            local targetPosition = calculateNotificationPosition(i)
            local positionTween = TweenService:Create(
                notification,
                createTweenInfo(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Position = targetPosition}
            )
            positionTween:Play()
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Initialize the notification system
local function initializeNotificationSystem()
    if screenGui then return end
    
    -- Create main ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationSystem"
    screenGui.DisplayOrder = 10
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Create notification container
    notificationContainer = Instance.new("Frame")
    notificationContainer.Name = "NotificationContainer"
    notificationContainer.Size = UDim2.new(1, 0, 1, 0)
    notificationContainer.Position = UDim2.new(0, 0, 0, 0)
    notificationContainer.BackgroundTransparency = 1
    notificationContainer.Parent = screenGui
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION CREATION FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Create shadow effect for notification
local function createNotificationShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = CONFIG.SHADOW_SIZE
    shadow.Position = UDim2.new(0, -3, 0, 3)
    shadow.BackgroundColor3 = CONFIG.SHADOW_COLOR
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    -- Shadow corner radius
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = CONFIG.CORNER_RADIUS
    shadowCorner.Parent = shadow
    
    return shadow
end

-- Create gradient background for notification
local function createNotificationGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, CONFIG.GRADIENT_TOP),
        ColorSequenceKeypoint.new(1, CONFIG.GRADIENT_BOTTOM)
    }
    gradient.Rotation = 90
    gradient.Parent = parent
    
    return gradient
end

-- Create stroke border for notification
local function createNotificationStroke(parent)
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.STROKE_COLOR
    stroke.Thickness = CONFIG.STROKE_THICKNESS
    stroke.Transparency = 0.3
    stroke.Parent = parent
    
    return stroke
end

-- Create title label
local function createTitleLabel(parent, titleText)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = titleText or "Notification"
    titleLabel.TextColor3 = CONFIG.TITLE_COLOR
    titleLabel.TextScaled = false
    titleLabel.TextSize = CONFIG.TITLE_SIZE
    titleLabel.Font = CONFIG.TITLE_FONT
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Parent = parent
    
    return titleLabel
end

-- Create message label
local function createMessageLabel(parent, messageText)
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0.6, -8)
    messageLabel.Position = UDim2.new(0, 10, 0.4, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = messageText or "This is a notification message."
    messageLabel.TextColor3 = CONFIG.MESSAGE_COLOR
    messageLabel.TextScaled = false
    messageLabel.TextSize = CONFIG.MESSAGE_SIZE
    messageLabel.Font = CONFIG.MESSAGE_FONT
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = parent
    
    return messageLabel
end

-- Create close button
local function createCloseButton(parent, onClickCallback)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = CONFIG.MESSAGE_COLOR
    closeButton.TextScaled = false
    closeButton.TextSize = 14
    closeButton.Font = CONFIG.MESSAGE_FONT
    closeButton.Parent = parent
    
    -- Hover effects
    closeButton.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            closeButton,
            createTweenInfo(0.1),
            {TextColor3 = CONFIG.TITLE_COLOR}
        )
        hoverTween:Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        local hoverTween = TweenService:Create(
            closeButton,
            createTweenInfo(0.1),
            {TextColor3 = CONFIG.MESSAGE_COLOR}
        )
        hoverTween:Play()
    end)
    
    closeButton.MouseButton1Click:Connect(onClickCallback)
    
    return closeButton
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION ANIMATION FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Animate notification entrance
local function animateNotificationIn(notification, targetPosition)
    -- Set initial properties
    notification.Position = CONFIG.START_POSITION
    notification.Size = UDim2.new(0, 0, 0, CONFIG.NOTIFICATION_SIZE.Y.Offset)
    notification.BackgroundTransparency = 1
    
    -- Create entrance animation sequence
    local sizeUpTween = TweenService:Create(
        notification,
        createTweenInfo(CONFIG.FADE_IN_TIME * 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, CONFIG.NOTIFICATION_SIZE.X.Offset, 0, CONFIG.NOTIFICATION_SIZE.Y.Offset),
            Position = targetPosition
        }
    )
    
    local fadeInTween = TweenService:Create(
        notification,
        createTweenInfo(CONFIG.FADE_IN_TIME * 0.8),
        {BackgroundTransparency = 0}
    )
    
    -- Start animations
    sizeUpTween:Play()
    fadeInTween:Play()
    
    -- Bounce effect
    sizeUpTween.Completed:Connect(function()
        local bounceTween = TweenService:Create(
            notification,
            createTweenInfo(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, CONFIG.NOTIFICATION_SIZE.X.Offset * CONFIG.BOUNCE_SCALE, 0, CONFIG.NOTIFICATION_SIZE.Y.Offset * CONFIG.BOUNCE_SCALE)}
        )
        bounceTween:Play()
        
        bounceTween.Completed:Connect(function()
            local normalTween = TweenService:Create(
                notification,
                createTweenInfo(0.1),
                {Size = CONFIG.NOTIFICATION_SIZE}
            )
            normalTween:Play()
        end)
    end)
end

-- Animate notification exit
local function animateNotificationOut(notification, onComplete)
    local fadeOutTween = TweenService:Create(
        notification,
        createTweenInfo(CONFIG.FADE_OUT_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0, -CONFIG.NOTIFICATION_SIZE.Y.Offset - 20),
            Size = UDim2.new(0, CONFIG.NOTIFICATION_SIZE.X.Offset * 0.8, 0, CONFIG.NOTIFICATION_SIZE.Y.Offset * 0.8)
        }
    )
    
    fadeOutTween:Play()
    fadeOutTween.Completed:Connect(function()
        if onComplete then
            onComplete()
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION MANAGEMENT FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Remove notification from active list
local function removeNotificationFromActive(notification)
    for i, activeNotif in ipairs(activeNotifications) do
        if activeNotif == notification then
            table.remove(activeNotifications, i)
            break
        end
    end
    updateNotificationPositions()
end

-- Dismiss notification
local function dismissNotification(notification)
    animateNotificationOut(notification, function()
        removeNotificationFromActive(notification)
        if notification and notification.Parent then
            notification:Destroy()
        end
    end)
end

-- Create a single notification
local function createNotification(message, title, duration)
    -- Limit maximum notifications
    if #activeNotifications >= CONFIG.MAX_NOTIFICATIONS then
        dismissNotification(activeNotifications[1])
    end
    
    -- Create main notification frame
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = CONFIG.NOTIFICATION_SIZE
    notification.Position = CONFIG.START_POSITION
    notification.AnchorPoint = CONFIG.ANCHOR_POINT
    notification.BackgroundColor3 = CONFIG.GRADIENT_TOP
    notification.BorderSizePixel = 0
    notification.ZIndex = 5
    notification.Parent = notificationContainer
    
    -- Add visual components
    local shadow = createNotificationShadow(notification)
    local gradient = createNotificationGradient(notification)
    local stroke = createNotificationStroke(notification)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = notification
    
    -- Add text components
    local titleLabel = createTitleLabel(notification, title)
    local messageLabel = createMessageLabel(notification, message)
    
    -- Add close button
    local closeButton = createCloseButton(notification, function()
        dismissNotification(notification)
    end)
    
    -- Add to active notifications and calculate position
    table.insert(activeNotifications, notification)
    local targetPosition = calculateNotificationPosition(#activeNotifications)
    
    -- Animate notification in
    animateNotificationIn(notification, targetPosition)
    
    -- Auto-dismiss after duration
    local dismissDuration = duration or CONFIG.DEFAULT_DURATION
    task.spawn(function()
        task.wait(dismissDuration)
        
        -- Check if notification still exists before dismissing
        if notification and notification.Parent then
            dismissNotification(notification)
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- PUBLIC API FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Main notification function
function NotificationSystem.notify(message, title, duration)
    -- Input validation
    if not message or type(message) ~= "string" then
        warn("NotificationSystem: Message must be a string")
        return
    end
    
    if title and type(title) ~= "string" then
        warn("NotificationSystem: Title must be a string or nil")
        return
    end
    
    if duration and type(duration) ~= "number" then
        warn("NotificationSystem: Duration must be a number or nil")
        return
    end
    
    -- Initialize system if needed
    initializeNotificationSystem()
    
    -- Create notification in a separate thread to avoid blocking
    task.spawn(function()
        createNotification(message, title, duration)
    end)
end

-- Clear all notifications
function NotificationSystem.clearAll()
    for _, notification in ipairs(activeNotifications) do
        if notification and notification.Parent then
            dismissNotification(notification)
        end
    end
    activeNotifications = {}
end

-- Get active notification count
function NotificationSystem.getActiveCount()
    return #activeNotifications
end

-- Update configuration (for customization)
function NotificationSystem.updateConfig(newConfig)
    if type(newConfig) == "table" then
        for key, value in pairs(newConfig) do
            if CONFIG[key] ~= nil then
                CONFIG[key] = value
            end
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════════════

-- Auto-initialize when required
initializeNotificationSystem()

-- ════════════════════════════════════════════════════════════════════════════════════════
-- EXPORT MODULE
-- ════════════════════════════════════════════════════════════════════════════════════════

return NotificationSystem

--[[
    ╔════════════════════════════════════════════════════════════════════════════════════════╗
    ║                                SETUP INSTRUCTIONS                                      ║
    ╚════════════════════════════════════════════════════════════════════════════════════════╝
    
    STEP 1: Create the Module
    1. In Studio, go to ReplicatedStorage
    2. Insert a ModuleScript
    3. Rename it to "NotificationSystem" 
    4. Paste this entire code into the ModuleScript
    
    STEP 2: Create a Test Script
    1. In StarterPlayerScripts, insert a LocalScript
    2. Name it "NotificationTest"
    3. Use this code in the LocalScript:
    
    ```lua
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
    
    -- Wait for player to load
    game.Players.LocalPlayer.CharacterAdded:Wait()
    wait(2) -- Give GUI time to load
    
    -- Test notifications
    NotificationSystem.notify("Welcome to the game!", "Hello Player")
    
    wait(3)
    NotificationSystem.notify("This is a longer message to test text wrapping and see how it looks!", "Long Message Test", 6)
    
    wait(2)  
    NotificationSystem.notify("Quick message", "Short", 2)
    ```
    
    STEP 3: Test in Game
    1. Click "Play" in Studio
    2. You should see notifications appear at the top of your screen
    
    If still not working, check:
    - Make sure the ModuleScript is named exactly "NotificationSystem"
    - Make sure it's in ReplicatedStorage 
    - Check the Output window for any error messages
    - Make sure you're using a LocalScript, not a regular Script
]]

--[[
    ╔════════════════════════════════════════════════════════════════════════════════════════╗
    ║                                   USAGE EXAMPLES                                       ║
    ╚════════════════════════════════════════════════════════════════════════════════════════╝
    
    -- Basic notification
    NotificationSystem.notify("Hello World!")
    
    -- Notification with title
    NotificationSystem.notify("Successfully saved your progress!", "Save Complete")
    
    -- Notification with custom duration (10 seconds)
    NotificationSystem.notify("This message will stay longer", "Extended Notice", 10)
    
    -- Clear all notifications
    NotificationSystem.clearAll()
    
    -- Get active notification count
    print("Active notifications:", NotificationSystem.getActiveCount())
    
    -- Customize configuration
    NotificationSystem.updateConfig({
        DEFAULT_DURATION = 8,
        GRADIENT_TOP = Color3.fromRGB(50, 150, 250),
        GRADIENT_BOTTOM = Color3.fromRGB(30, 100, 200)
    })
]]
