--!strict
-- ============================================
-- MAIN EXECUTOR SCRIPT - Clean Integration
-- ============================================

-- Load the library module
local Library = require(script.lib.init)  -- Adjust path as needed

-- Optional: Customize theme BEFORE creating windows
Library.AccentColor = Color3.fromRGB(0, 170, 255)  -- Cyan accent
Library.Font = Enum.Font.GothamSemibold

-- Create your window
local Window = Library:CreateWindow({
    Title = "✨ My Premium Script",
    Center = true,           -- Spawn centered on screen
    AutoShow = true,         -- Show immediately
    Size = UDim2.fromOffset(550, 620),
    ToggleKeybind = nil,     -- Optional: assign a KeyPicker later
})

-- Add a tab
local MainTab = Window:AddTab("⚡ Features")

-- Create groupboxes for organization
local CombatBox = MainTab:AddLeftGroupbox("⚔️ Combat")
local VisualsBox = MainTab:AddRightGroupbox("👁️ Visuals")

-- ============================================
-- SIMPLE ELEMENT EXAMPLES
-- ============================================

-- Toggle with callback
CombatBox:AddToggle("Aimbot", {
    Text = "Enable Aimbot",
    Default = false,
    Tooltip = "Locks onto nearest enemy",
    Callback = function(Value: boolean)
        if Value then
            print("🎯 Aimbot enabled")
            -- Your aimbot start logic here
        else
            print("🎯 Aimbot disabled")
            -- Your aimbot stop logic here
        end
    end,
})

-- Slider with numeric input
CombatBox:AddSlider("AimbotFOV", {
    Text = "Aimbot FOV",
    Default = 30,
    Min = 1,
    Max = 180,
    Rounding = 0,
    Suffix = "°",
    Callback = function(Value: number)
        print("🎯 FOV set to:", Value)
        -- Update your aimbot FOV variable here
    end,
})

-- Dropdown with player list
CombatBox:AddDropdown("AimbotTarget", {
    Text = "Target Priority",
    Values = { "Nearest", "Lowest Health", "Highest Threat", "Closest to Crosshair" },
    Default = "Nearest",
    Callback = function(Value: string)
        print("🎯 Target priority:", Value)
    end,
})

-- Color picker for ESP
VisualsBox:AddColorPicker("ESPColor", {
    Title = "ESP Color",
    Default = Color3.fromRGB(255, 100, 100),
    Transparency = 0,
    Callback = function(Color: Color3)
        print("🎨 ESP color updated:", Color)
        -- Update your ESP drawing color here
    end,
})

-- Keybind for toggle
local AimbotKey = CombatBox:AddKeyPicker("AimbotKey", {
    Default = "Q",
    Mode = "Toggle",  -- Options: "Always", "Toggle", "Hold"
    Text = "Aimbot Key",
    Callback = function(Toggled: boolean)
        print("🔑 Aimbot key state:", Toggled)
    end,
})

-- Link keypicker to toggle (optional sync)
-- CombatBox:AddToggle("Aimbot", { ... SyncToggleState = true ... })

-- Simple button
VisualsBox:AddButton({
    Text = "Refresh ESP",
    Tooltip = "Reloads all ESP objects",
    Func = function()
        Library:Notify("🔄 ESP Refreshed!", 2)
        -- Your ESP refresh logic here
    end,
}):AddButton({  -- Add a secondary button next to it
    Text = "Reset",
    Func = function()
        Library:Notify("⚙️ Settings Reset", 2)
    end,
})

-- Input field for config
VisualsBox:AddInput("ESPMaxDistance", {
    Text = "ESP Max Distance",
    Default = "500",
    Numeric = true,
    Placeholder = "Enter studs...",
    Callback = function(Value: string)
        local Distance = tonumber(Value) or 500
        print("📏 ESP distance set to:", Distance)
    end,
})

-- Divider & Info Label
VisualsBox:AddDivider()
VisualsBox:AddLabel("💡 Tip: Press RightCtrl to toggle menu", true)

-- ============================================
-- OPTIONAL: CONFIG SAVE/LOAD SYSTEM
-- ============================================

-- Simple config helper (add to your lib/utils.lua for reusability)
local Config = {
    Save = function(filename: string, data: table)
        local success, result = pcall(function()
            writefile(filename, game:GetService("HttpService"):JSONEncode(data))
        end)
        return success
    end,
    Load = function(filename: string): table?
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(filename))
        end)
        return success and result or nil
    end,
}

-- Example: Save toggle states
local function SaveSettings()
    Config:Save("myconfig.json", {
        aimbot = Toggles.Aimbot.Value,
        fov = Options.AimbotFOV.Value,
        espColor = Options.ESPColor.Value:ToHex(),
    })
    Library:Notify("💾 Settings Saved", 2)
end

-- Example: Load toggle states
local function LoadSettings()
    local data = Config:Load("myconfig.json")
    if data then
        if Toggles.Aimbot then Toggles.Aimbot:SetValue(data.aimbot) end
        if Options.AimbotFOV then Options.AimbotFOV:SetValue(data.fov) end
        if Options.ESPColor then 
            local color = Color3.fromHex(data.espColor)
            Options.ESPColor:SetValueRGB(color)
        end
        Library:Notify("⬆️ Settings Loaded", 2)
    end
end

-- Add save/load buttons
local SettingsBox = MainTab:AddLeftGroupbox("⚙️ Settings")
SettingsBox:AddButton({ Text = "Save Config", Func = SaveSettings })
SettingsBox:AddButton({ Text = "Load Config", Func = LoadSettings })

-- ============================================
-- UTILITY: WATERMARK & NOTIFICATIONS
-- ============================================

-- Dynamic watermark
Library:SetWatermark(`My Script v1.2 | {game.Players.LocalPlayer.Name}`)

-- Show keybinds panel (optional)
Library.KeybindFrame.Visible = true

-- Custom notification style (optional override)
-- Library.NotifyOnError = true  -- Show error notifications for callbacks

-- ============================================
-- UNLOAD HANDLER (Clean exit)
-- ============================================

Library:OnUnload(function()
    print("🧹 Cleaning up...")
    -- Disconnect your feature loops here
    -- Example: if AimbotLoop then AimbotLoop:Disconnect() end
end)

-- Optional: Bind unload to script destruction
script.Destroying:Connect(function()
    Library:Unload()
end)
