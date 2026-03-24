-- Example usage of UILibrary
local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/yourrepository/main/UILibrary.lua"))()

-- Create a new window
local window = UILibrary:CreateWindow({
    Title = "Example UI",
    SubTitle = "v1.0.0",
    Theme = "Teal"
})

-- Create tabs
local mainTab = window:CreateTab("Main")
local combatTab = window:CreateTab("Combat")
local visualsTab = window:CreateTab("Visuals")
local settingsTab = window:CreateTab("Settings")

-- Add elements to Main tab
local mainSection = mainTab:AddSection("Main Features")

mainSection:AddButton({
    Text = "Print Hello",
    Callback = function()
        print("Hello from UILibrary!")
    end
})

mainSection:AddToggle({
    Text = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Feature enabled:", value)
    end
})

mainSection:AddSlider({
    Text = "Speed Multiplier",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        print("Speed set to:", value)
    end
})

-- Add elements to Combat tab
local combatSection = combatTab:AddSection("Combat Settings")

combatSection:AddToggle({
    Text = "Aimbot",
    Default = false,
    Callback = function(value)
        print("Aimbot:", value)
    end
})

combatSection:AddDropdown({
    Text = "Aim Part",
    Options = {"Head", "Torso", "Random"},
    Default = "Head",
    Callback = function(value)
        print("Aim part set to:", value)
    end
})

-- Add elements to Visuals tab
local visualsSection = visualsTab:AddSection("Visual Settings")

visualsSection:AddColorPicker({
    Text = "ESP Color",
    Default = Color3.fromRGB(0, 255, 200),
    Callback = function(color)
        print("ESP color set to:", color)
    end
})

-- Add elements to Settings tab
local settingsSection = settingsTab:AddSection("Configuration")

settingsSection:AddButton({
    Text = "Save Settings",
    Callback = function()
        print("Settings saved!")
    end
})

settingsSection:AddButton({
    Text = "Load Settings",
    Callback = function()
        print("Settings loaded!")
    end
})
