-- ================================================================
-- BABFT ULTIMATE HUB v5.1 - ПОЛНАЯ ВЕРСИЯ (1000+ строк)
-- ================================================================

-- =========================================================
-- 1. ПОЛНАЯ ОСТАНОВКА СТАРОГО СКРИПТА
-- =========================================================
print("🔄 Проверка старого скрипта...")

local function ForceStopOldScript()
    if getgenv().BABFT_Unload then
        pcall(function() getgenv().BABFT_Unload() end)
    end
    if getgenv().BABFT_Running then
        getgenv().BABFT_Running = false
    end
    if getgenv().FarmConfig then
        getgenv().FarmConfig.AutoFarmGold = false
    end
    if getgenv()._BABFT_Connections then
        for _, conn in ipairs(getgenv()._BABFT_Connections) do
            pcall(function() conn:Disconnect() end)
        end
        getgenv()._BABFT_Connections = nil
    end
    
    local varsToClear = {
        "BABFT_Loaded", "BABFT_Unload", "BABFT_Running",
        "FarmConfig", "State", "Connections",
        "FarmLoopThread", "IsFarmRunning",
        "ESPEnabled", "ESPObjects", "ESPConnections",
        "BlackHoleEnabled", "BlackHoleParts"
    }
    
    for _, var in ipairs(varsToClear) do
        if getgenv()[var] then
            getgenv()[var] = nil
        end
    end
    
    pcall(function()
        game:GetService("Workspace").Gravity = 196.2
    end)
end

ForceStopOldScript()
wait(0.5)

-- =========================================================
-- 2. ЗАГРУЗКА
-- =========================================================
getgenv()._BABFT_Connections = {}
getgenv().BABFT_Loaded = true
getgenv().BABFT_Running = true

-- ВЫБОР БИБЛИОТЕКИ (можно менять)
local UI_LIBRARY = "Obsidian" -- Options: "Obsidian", "Fluent", "Aero", "DarkHub"

-- Загружаем выбранную библиотеку
local Library
local ThemeManager
local SaveManager

if UI_LIBRARY == "Obsidian" then
    local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
    Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
elseif UI_LIBRARY == "Fluent" then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Init.lua"))()
elseif UI_LIBRARY == "Aero" then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/AeroScripts/AeroUI/main/source.lua"))()
elseif UI_LIBRARY == "DarkHub" then
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Syntaqx/DarkHub/main/source.lua"))()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera

-- =========================================================
-- 3. НАСТРОЙКИ
-- =========================================================
getgenv().FarmConfig = {
    AutoFarmGold = false,
    FarmMethod = "Tween (Fly)",
    TargetMode = "All Stages (1-10)",
    FarmSpeed = 2.5,
    AutoReset = false,
    AutoClaimReward = true,
    AutoKillForReward = false,
    ChestType = "Common Chest",
    BuyAmount = 1,
    UITheme = "Dark",
    UIColor = "Blue",
    UISize = "Medium"
}

local State = {
    Fly = false, FlySpeed = 50, Noclip = false, Fullbright = false, AntiAFK = true,
    BlackHole = false, BH_Radius = 30, BH_Power = 50
}

local Connections = {}
local AntiAFKConnection = nil
local FarmLoopThread = nil
local IsFarmRunning = false

local ESPEnabled = false
local ESPObjects = {}
local ESPConnections = {}

local BlackHoleEnabled = false
local BlackHoleParts = {}
local BlackHoleCenter = nil

local function getChar() return LocalPlayer.Character end
local function getHRP() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end
local function getHumanoid() return getChar() and getChar():FindFirstChildOfClass("Humanoid") end

-- =========================================================
-- 4. CLAIM REWARD
-- =========================================================
local function ClaimGoldReward()
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return false end
        
        local function findClaimButton(gui)
            for _, btn in ipairs(gui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    local name = btn.Name:lower()
                    if name:find("claim") or name:find("get") or name:find("collect") or name:find("reward") then
                        return btn
                    end
                    
                    if btn:IsA("TextButton") and btn.Text then
                        local text = btn.Text:lower()
                        if text:find("получить") or text:find("забрать") or 
                           text:find("claim") or text:find("collect") or 
                           text:find("get") or text:find("reward") then
                            return btn
                        end
                    end
                end
            end
            return nil
        end
        
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local claimBtn = findClaimButton(gui)
                if claimBtn then
                    local connections = getconnections(claimBtn.MouseButton1Click)
                    if connections and #connections > 0 then
                        for _, conn in ipairs(connections) do
                            conn:Fire()
                        end
                    end
                    pcall(function() claimBtn:Fire() end)
                    return true
                end
            end
        end
        return false
    end)
end

-- =========================================================
-- 5. ТОЧКИ СТАДИЙ
-- =========================================================
local TargetLocations = {
    ["Stage 1"]  = CFrame.new(-51.5, 65, 1369),
    ["Stage 2"]  = CFrame.new(-51.5, 65, 2139),
    ["Stage 3"]  = CFrame.new(-51.5, 65, 2909),
    ["Stage 4"]  = CFrame.new(-51.5, 65, 3679),
    ["Stage 5"]  = CFrame.new(-51.5, 65, 4449),
    ["Stage 6"]  = CFrame.new(-51.5, 65, 5219),
    ["Stage 7"]  = CFrame.new(-51.5, 65, 5989),
    ["Stage 8"]  = CFrame.new(-51.5, 65, 6759),
    ["Stage 9"]  = CFrame.new(-51.5, 65, 7529),
    ["Stage 10"] = CFrame.new(-51.5, 65, 8299),
    ["Golden Chest"] = CFrame.new(-51.5, -350, 9490)
}

local StageSequence = {
    TargetLocations["Stage 1"], TargetLocations["Stage 2"], TargetLocations["Stage 3"],
    TargetLocations["Stage 4"], TargetLocations["Stage 5"], TargetLocations["Stage 6"],
    TargetLocations["Stage 7"], TargetLocations["Stage 8"], TargetLocations["Stage 9"],
    TargetLocations["Stage 10"], TargetLocations["Golden Chest"]
}

-- =========================================================
-- 6. ФУНКЦИИ ПЕРЕМЕЩЕНИЯ
-- =========================================================
local function MoveToCFrame(targetCF)
    local hrp = getHRP()
    if not hrp then return false end
    
    local method = getgenv().FarmConfig.FarmMethod
    
    if method == "Teleport" then
        hrp.CFrame = targetCF
        task.wait(0.1)
        hrp.CFrame = targetCF
        return true
    else
        local tweenInfo = TweenInfo.new(
            getgenv().FarmConfig.FarmSpeed, 
            Enum.EasingStyle.Linear
        )
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCF})
        tween:Play()
        tween.Completed:Wait()
        return true
    end
end

local function WaitForRespawn(oldChar, maxWaitTime)
    maxWaitTime = maxWaitTime or 10
    local startTime = tick()
    
    while tick() - startTime < maxWaitTime do
        if not getgenv().BABFT_Running then return false end
        
        local newChar = LocalPlayer.Character
        if newChar ~= oldChar and newChar then
            local hrp = newChar:FindFirstChild("HumanoidRootPart")
            local hum = newChar:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                return true
            end
        end
        task.wait(0.1)
    end
    return false
end

-- =========================================================
-- 7. ОСНОВНОЙ ЦИКЛ ФАРМА
-- =========================================================
local function StartGoldFarmLoop()
    if IsFarmRunning then return end
    IsFarmRunning = true
    
    FarmLoopThread = task.spawn(function()
        while getgenv().BABFT_Running and getgenv().FarmConfig.AutoFarmGold do
            local oldChar = getChar()
            local hrp = getHRP()
            local hum = getHumanoid()
            
            if oldChar and hrp and hum and hum.Health > 0 then
                Workspace.Gravity = 0
                local selectedMode = getgenv().FarmConfig.TargetMode
                
                local stagesToVisit = selectedMode == "All Stages (1-10)" and StageSequence or {TargetLocations[selectedMode]}
                if stagesToVisit then
                    for _, targetCF in ipairs(stagesToVisit) do
                        if not getgenv().BABFT_Running or not getgenv().FarmConfig.AutoFarmGold then 
                            break 
                        end
                        if targetCF then
                            MoveToCFrame(targetCF)
                            task.wait(0.2)
                        end
                    end
                end
                
                if getgenv().BABFT_Running and getgenv().FarmConfig.AutoFarmGold and 
                   (selectedMode == "All Stages (1-10)" or selectedMode == "Golden Chest") then
                    task.wait(0.5)
                    
                    local boatStages = Workspace:FindFirstChild("BoatStages")
                    if boatStages then
                        local normalStages = boatStages:FindFirstChild("NormalStages")
                        if normalStages then
                            local theEnd = normalStages:FindFirstChild("TheEnd")
                            if theEnd then
                                local chest = theEnd:FindFirstChild("GoldenChest")
                                if chest and chest:FindFirstChild("Trigger") and getHRP() then
                                    local hrp = getHRP()
                                    firetouchinterest(hrp, chest.Trigger, 0)
                                    task.wait(0.1)
                                    firetouchinterest(hrp, chest.Trigger, 1)
                                end
                            end
                        end
                    end
                    
                    task.wait(0.5)
                    
                    if getgenv().BABFT_Running and getgenv().FarmConfig.AutoKillForReward and getHumanoid() then
                        getHumanoid().Health = 0
                        WaitForRespawn(oldChar, 8)
                    end
                end
            end
            
            Workspace.Gravity = 196.2
            
            if getgenv().BABFT_Running and getgenv().FarmConfig.AutoFarmGold and getgenv().FarmConfig.AutoClaimReward then
                local claimAttempts = 0
                local maxAttempts = 20
                local claimed = false
                
                repeat
                    if not getgenv().BABFT_Running or not getgenv().FarmConfig.AutoFarmGold then 
                        break 
                    end
                    
                    if ClaimGoldReward() then
                        claimed = true
                        break
                    end
                    task.wait(0.5)
                    claimAttempts = claimAttempts + 1
                until claimAttempts >= maxAttempts
                
                if claimed then
                    task.wait(0.3)
                end
            end
        end
        
        Workspace.Gravity = 196.2
        IsFarmRunning = false
        FarmLoopThread = nil
    end)
end

local function StopGoldFarm()
    getgenv().FarmConfig.AutoFarmGold = false
    if FarmLoopThread then
        task.cancel(FarmLoopThread)
        FarmLoopThread = nil
    end
    IsFarmRunning = false
    Workspace.Gravity = 196.2
end

-- =========================================================
-- 8. ESP
-- =========================================================
local function CreateESP(part, color, text)
    if not part or not part.Parent then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 1000
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color or Color3.fromRGB(255, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "ESP"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    billboard.Parent = part
    return billboard
end

local function UpdateESP()
    for _, obj in ipairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    
    if not ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                local health = hum and hum.Health or "?"
                local esp = CreateESP(hrp, Color3.fromRGB(0, 255, 0), player.Name .. "\n❤️ " .. health)
                if esp then table.insert(ESPObjects, esp) end
            end
        end
    end
    
    local function FindChests(parent)
        if not parent then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name:find("Chest") or child.Name:find("Spawn") then
                local hrp = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("RootPart") or child:FindFirstChildOfClass("BasePart")
                if hrp then
                    local esp = CreateESP(hrp, Color3.fromRGB(255, 215, 0), "🪙 " .. child.Name)
                    if esp then table.insert(ESPObjects, esp) end
                end
            end
            FindChests(child)
        end
    end
    FindChests(Workspace)
end

-- =========================================================
-- 9. BLACK HOLE
-- =========================================================
local function CreateBlackHoleEffect(position)
    for _, part in ipairs(BlackHoleParts) do
        pcall(function() part:Destroy() end)
    end
    BlackHoleParts = {}
    
    if not BlackHoleEnabled then return end
    
    local center = Instance.new("Part")
    center.Size = Vector3.new(5, 2, 5)
    center.Position = position
    center.Anchored = true
    center.CanCollide = false
    center.Material = Enum.Material.Neon
    center.Color = Color3.fromRGB(0, 0, 0)
    center.Transparency = 0.3
    center.Parent = Workspace
    
    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 200, 0)}
    for i = 1, 3 do
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(10 + i*5, 0.5, 10 + i*5)
        ring.Position = position + Vector3.new(0, i * 0.5, 0)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Material = Enum.Material.Neon
        ring.Color = colors[i % #colors + 1]
        ring.Transparency = 0.5
        ring.Parent = Workspace
        table.insert(BlackHoleParts, ring)
    end
    
    table.insert(BlackHoleParts, center)
    BlackHoleCenter = center
end

local function BlackHoleLoop()
    while BlackHoleEnabled and getgenv().BABFT_Running do
        if getHRP() then
            local hrpPos = getHRP().Position
            local radius = State.BH_Radius or 30
            local power = State.BH_Power or 50
            
            CreateBlackHoleEffect(hrpPos)
            
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(getChar()) then
                    local distance = (part.Position - hrpPos).Magnitude
                    if distance < radius then
                        local angle = math.atan2(part.Position.Z - hrpPos.Z, part.Position.X - hrpPos.X)
                        local newAngle = angle + (power * 0.01)
                        local orbitRadius = distance * 0.8
                        
                        local targetPos = hrpPos + Vector3.new(
                            math.cos(newAngle) * orbitRadius,
                            (hrpPos.Y - part.Position.Y) * 0.1,
                            math.sin(newAngle) * orbitRadius
                        )
                        
                        local velocity = (targetPos - part.Position) * 5
                        velocity = velocity + Vector3.new(0, -5, 0)
                        part.Velocity = velocity
                    end
                end
            end
        end
        task.wait(0.05)
    end
end

-- =========================================================
-- 10. БАЗЫ ДЛЯ ТЕЛЕПОРТА
-- =========================================================
local BaseLocations = {
    ["🟢 Зеленая база"] = CFrame.new(-479, -10, 294),
    ["⚫ Черная база"] = CFrame.new(-478, -10, -69),
    ["⚪ Белая база"] = CFrame.new(-50, -10, -495),
    ["🔴 Красная база"] = CFrame.new(371, -10, -65),
    ["🟡 Желтая база"] = CFrame.new(-478, -10, 640),
    ["🔵 Синяя база"] = CFrame.new(371, -10, 300),
    ["🩷 Розовая база"] = CFrame.new(371, -10, 647)
}

local function TeleportToBase(cf)
    local hrp = getHRP()
    if not hrp then 
        Library:Notify("❌ Персонаж не найден!")
        return 
    end
    hrp.CFrame = cf
    task.wait(0.1)
    hrp.CFrame = cf
    Library:Notify("✅ Телепорт выполнен!")
end

-- =========================================================
-- 11. НАСТРОЙКИ ИНТЕРФЕЙСА
-- =========================================================
local UIThemes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 35),
        Foreground = Color3.fromRGB(40, 40, 45),
        Primary = Color3.fromRGB(70, 130, 255),
        Secondary = Color3.fromRGB(100, 100, 110),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 200, 50)
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Foreground = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(50, 100, 220),
        Secondary = Color3.fromRGB(200, 200, 210),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(255, 180, 0)
    },
    Neon = {
        Background = Color3.fromRGB(10, 0, 30),
        Foreground = Color3.fromRGB(20, 0, 50),
        Primary = Color3.fromRGB(255, 0, 255),
        Secondary = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(0, 255, 0),
        Accent = Color3.fromRGB(255, 255, 0)
    },
    Ocean = {
        Background = Color3.fromRGB(0, 20, 50),
        Foreground = Color3.fromRGB(0, 40, 80),
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(0, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(255, 200, 100)
    },
    Forest = {
        Background = Color3.fromRGB(10, 30, 10),
        Foreground = Color3.fromRGB(20, 50, 20),
        Primary = Color3.fromRGB(50, 200, 50),
        Secondary = Color3.fromRGB(100, 150, 100),
        Text = Color3.fromRGB(255, 255, 200),
        Accent = Color3.fromRGB(255, 200, 50)
    }
}

local UIColorPalette = {
    Blue = Color3.fromRGB(70, 130, 255),
    Red = Color3.fromRGB(255, 50, 50),
    Green = Color3.fromRGB(50, 255, 50),
    Purple = Color3.fromRGB(200, 50, 255),
    Orange = Color3.fromRGB(255, 150, 50),
    Pink = Color3.fromRGB(255, 50, 200),
    Cyan = Color3.fromRGB(50, 255, 255)
}

local function ApplyTheme(themeName, colorName)
    local theme = UIThemes[themeName] or UIThemes.Dark
    local color = UIColorPalette[colorName] or UIColorPalette.Blue
    
    if Library.SetTheme then
        Library.SetTheme(theme)
    end
    
    if ThemeManager and ThemeManager.ApplyColor then
        ThemeManager.ApplyColor(color)
    end
    
    Library:Notify("🎨 Тема: " .. themeName .. " | Цвет: " .. colorName)
end

-- =========================================================
-- 12. СОЗДАНИЕ ОКНА
-- =========================================================
local Window = Library:CreateWindow({
    Title = "BABFT | Ultimate Hub v5.1",
    Center = true, AutoShow = true, Resizable = true,
    ShowCustomCursor = true, UnlockMouseWhileOpen = true,
    NotifySide = "Right", TabPadding = 8, MenuFadeTime = 0.2
})

local Tabs = {
    Automation = Window:AddTab("Automation"),
    Player = Window:AddTab("Player Mods"),
    Funny = Window:AddTab("Funny / Fun"),
    World = Window:AddTab("World & Misc"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

-- =========================================================
-- 13. ВКЛАДКА AUTOMATION
-- =========================================================
local GoldFarmGroup = Tabs.Automation:AddLeftGroupbox("Gold Auto-Farm")
local ChestGroup = Tabs.Automation:AddRightGroupbox("Chest Auto-Buyer")

GoldFarmGroup:AddToggle("AutoFarmGoldToggle", {
    Text = "Enable Gold Auto-Farm", Default = false,
    Callback = function(v)
        if v then
            getgenv().FarmConfig.AutoFarmGold = true
            if not IsFarmRunning then
                StartGoldFarmLoop()
            end
        else
            StopGoldFarm()
        end
    end
})

GoldFarmGroup:AddDropdown("FarmMethodDropdown", {
    Values = {"Tween (Fly)", "Teleport"}, Default = 1, Multi = false, Text = "Movement Method",
    Callback = function(v) getgenv().FarmConfig.FarmMethod = v end
})

GoldFarmGroup:AddDropdown("TargetModeDropdown", {
    Values = {
        "All Stages (1-10)", "Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5",
        "Stage 6", "Stage 7", "Stage 8", "Stage 9", "Stage 10", "Golden Chest"
    }, Default = 1, Multi = false, Text = "Target Destination",
    Callback = function(v) getgenv().FarmConfig.TargetMode = v end
})

GoldFarmGroup:AddSlider("FarmSpeedSlider", {
    Text = "Fly Speed (Tween Time)", Default = 2.5, Min = 0.5, Max = 10, Rounding = 1,
    Callback = function(v) getgenv().FarmConfig.FarmSpeed = v end
})

GoldFarmGroup:AddToggle("AutoResetToggle", {
    Text = "Auto Reset Character (Kill for reward)", Default = false,
    Callback = function(v) 
        getgenv().FarmConfig.AutoReset = v 
        getgenv().FarmConfig.AutoKillForReward = v
    end
})

GoldFarmGroup:AddToggle("AutoClaimRewardToggle", {
    Text = "Auto Claim Reward (Click 'Получить')", Default = true,
    Callback = function(v) getgenv().FarmConfig.AutoClaimReward = v end
})

-- Chest
local ChestNames = { 
    ["Common Chest"] = "CommonChest", 
    ["Uncommon Chest"] = "UncommonChest", 
    ["Rare Chest"] = "RareChest", 
    ["Epic Chest"] = "EpicChest", 
    ["Legendary Chest"] = "LegendaryChest" 
}

local function BuyChest(chestName, amount)
    local internalName = ChestNames[chestName] or chestName
    local buyRemote = Workspace:FindFirstChild("ItemToBuy") and Workspace.ItemToBuy:FindFirstChild("BuyItemEvent")
    if buyRemote then
        for i = 1, amount do 
            buyRemote:InvokeServer(internalName, 1) 
            task.wait(0.1) 
        end
    end
end

ChestGroup:AddDropdown("ChestSelect", { 
    Values = {"Common Chest", "Uncommon Chest", "Rare Chest", "Epic Chest", "Legendary Chest"}, 
    Default = 1, Multi = false, Text = "Select Chest", 
    Callback = function(v) getgenv().FarmConfig.ChestType = v end 
})

ChestGroup:AddSlider("BuyAmountSlider", { 
    Text = "Amount per cycle", Default = 1, Min = 1, Max = 10, Rounding = 0, 
    Callback = function(v) getgenv().FarmConfig.BuyAmount = v end 
})

ChestGroup:AddButton({ 
    Text = "Buy Selected Chest", 
    Func = function() 
        BuyChest(getgenv().FarmConfig.ChestType, getgenv().FarmConfig.BuyAmount) 
        Library:Notify("Куплено!") 
    end 
})

-- =========================================================
-- 14. ВКЛАДКА PLAYER
-- =========================================================
local MovementGroup = Tabs.Player:AddLeftGroupbox("Movement")
local FlightGroup = Tabs.Player:AddRightGroupbox("Flight & Physics")
local CameraGroup = Tabs.Player:AddLeftGroupbox("Camera Controls")

MovementGroup:AddSlider("WalkSpeed", { 
    Text = "WalkSpeed", Default = 16, Min = 16, Max = 250, Rounding = 0, 
    Callback = function(v) if getHumanoid() then getHumanoid().WalkSpeed = v end end 
})

MovementGroup:AddSlider("JumpPower", { 
    Text = "JumpPower", Default = 50, Min = 50, Max = 250, Rounding = 0, 
    Callback = function(v) if getHumanoid() then getHumanoid().UseJumpPower = true getHumanoid().JumpPower = v end end 
})

FlightGroup:AddToggle("FlyToggle", { 
    Text = "Enable Fly", Default = false, 
    Callback = function(v) State.Fly = v end 
})

FlightGroup:AddSlider("FlySpeed", { 
    Text = "Fly Speed", Default = 50, Min = 10, Max = 200, Rounding = 0, 
    Callback = function(v) State.FlySpeed = v end 
})

Connections.Fly = RunService.RenderStepped:Connect(function()
    if State.Fly and getHRP() then
        local hrp = getHRP()
        local moveDir = Vector3.new()
        local camCF = workspace.CurrentCamera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        hrp.Velocity = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + moveDir.Unit * (State.FlySpeed / 10) end
    end
end)

FlightGroup:AddToggle("Noclip", { 
    Text = "Noclip", Default = false, 
    Callback = function(v) State.Noclip = v end 
})

Connections.Noclip = RunService.Stepped:Connect(function()
    if State.Noclip and getChar() then
        for _, part in ipairs(getChar():GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Camera
CameraGroup:AddButton({
    Text = "Zoom In (+10)", 
    Func = function() 
        Camera.FieldOfView = math.min(Camera.FieldOfView + 10, 120)
    end
})

CameraGroup:AddButton({
    Text = "Zoom Out (-10)", 
    Func = function() 
        Camera.FieldOfView = math.max(Camera.FieldOfView - 10, 1)
    end
})

CameraGroup:AddSlider("CameraZoomSlider", {
    Text = "Camera Zoom (FOV)", 
    Default = 70, 
    Min = 1, 
    Max = 120, 
    Rounding = 0,
    Callback = function(v) Camera.FieldOfView = v end
})

CameraGroup:AddButton({
    Text = "Reset Zoom (Default 70)",
    Func = function() Camera.FieldOfView = 70 end
})

-- =========================================================
-- 15. ВКЛАДКА FUNNY
-- =========================================================
local BlackHoleGroup = Tabs.Funny:AddLeftGroupbox("Black Hole (Tornado)")
local ESPGroup = Tabs.Funny:AddRightGroupbox("ESP")

BlackHoleGroup:AddToggle("BlackHoleToggle", {
    Text = "Enable Black Hole", Default = false,
    Callback = function(v)
        BlackHoleEnabled = v
        State.BlackHole = v
        
        if v then
            task.spawn(function() BlackHoleLoop() end)
            Library:Notify("🕳️ Черная дыра активирована!")
        else
            for _, part in ipairs(BlackHoleParts) do
                pcall(function() part:Destroy() end)
            end
            BlackHoleParts = {}
            BlackHoleCenter = nil
            Library:Notify("🕳️ Черная дыра деактивирована!")
        end
    end
})

BlackHoleGroup:AddSlider("BH_Radius", {
    Text = "Orbit Radius", Default = 30, Min = 5, Max = 150, Rounding = 0,
    Callback = function(v) State.BH_Radius = v end
})

BlackHoleGroup:AddSlider("BH_Power", {
    Text = "Rotation Speed", Default = 50, Min = 10, Max = 200, Rounding = 0,
    Callback = function(v) State.BH_Power = v end
})

ESPGroup:AddToggle("ESPToggle", {
    Text = "Enable ESP", Default = false,
    Callback = function(v)
        ESPEnabled = v
        if v then
            UpdateESP()
            if not ESPConnections.Update then
                ESPConnections.Update = RunService.Heartbeat:Connect(function()
                    if ESPEnabled then UpdateESP() end
                end)
            end
        else
            for _, obj in ipairs(ESPObjects) do
                pcall(function() obj:Destroy() end)
            end
            ESPObjects = {}
            if ESPConnections.Update then
                ESPConnections.Update:Disconnect()
                ESPConnections.Update = nil
            end
        end
    end
})

ESPGroup:AddButton({
    Text = "Refresh ESP",
    Func = function()
        if ESPEnabled then
            UpdateESP()
            Library:Notify("ESP обновлен!")
        end
    end
})

-- =========================================================
-- 16. ВКЛАДКА WORLD
-- =========================================================
local WorldGroup = Tabs.World:AddLeftGroupbox("World Adjustments")
local TeleportGroup = Tabs.World:AddRightGroupbox("Teleport to Bases")
local MiscGroup = Tabs.World:AddLeftGroupbox("Server Tools")

WorldGroup:AddToggle("Fullbright", {
    Text = "Fullbright / No Fog", Default = false,
    Callback = function(v)
        State.Fullbright = v
        if v then 
            Lighting.Ambient = Color3.fromRGB(255, 255, 255) 
            Lighting.FogEnd = 1e6
        else 
            Lighting.Ambient = Color3.fromRGB(128, 128, 128) 
            Lighting.FogEnd = 1000 
        end
    end
})

WorldGroup:AddButton({
    Text = "Clear Map / Remove Stages",
    Func = function()
        for _, stage in ipairs(workspace:GetChildren()) do
            if stage.Name:find("Stage") or stage.Name:find("Water") then 
                stage:Destroy() 
            end
        end
        Library:Notify("Карта очищена!")
    end
})

-- Teleport to Bases
for name, cf in pairs(BaseLocations) do
    TeleportGroup:AddButton({
        Text = name,
        Func = function() TeleportToBase(cf) end
    })
end

-- Misc
MiscGroup:AddToggle("AntiAFK", { 
    Text = "Anti-AFK Protection", 
    Default = true, 
    Callback = function(v) 
        State.AntiAFK = v 
        if not v and AntiAFKConnection then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        end
    end 
})

MiscGroup:AddButton({
    Text = "Rejoin Game",
    Func = function()
        Library:Notify("Переподключение...")
        task.wait(0.5)
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

MiscGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        Library:Notify("Поиск сервера...")
        task.wait(0.5)
        pcall(function()
            local servers = {}
            local response = game:GetService("HttpService"):JSONDecode(
                game:GetService("HttpService"):HttpGetAsync(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
                )
            )
            for _, v in ipairs(response.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
            if #servers > 0 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
            else
                Library:Notify("❌ Серверов не найдено!")
            end
        end)
    end
})

-- AntiAFK
AntiAFKConnection = LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end
end)
Connections.AntiAFK = AntiAFKConnection

-- =========================================================
-- 17. ВКЛАДКА UI SETTINGS (НАСТРОЙКА ИНТЕРФЕЙСА)
-- =========================================================
local UISettingsGroup = Tabs["UI Settings"]:AddLeftGroupbox("UI Theme & Colors")
local LibraryGroup = Tabs["UI Settings"]:AddRightGroupbox("Library Settings")
local MiscUIGroup = Tabs["UI Settings"]:AddLeftGroupbox("UI Misc Settings")

-- Переменная для хранения URL скрипта
local SCRIPT_URL = getgenv()._scriptURL or ""

-- Функция перезагрузки скрипта
local function ReloadScript()
    Library:Notify("🔄 Перезагрузка скрипта...")
    task.wait(0.5)
    
    local selectedLib = UI_LIBRARY
    getgenv()._selectedLibrary = selectedLib
    
    -- Выгружаем старый скрипт
    if getgenv().BABFT_Unload then
        getgenv().BABFT_Unload()
    end
    
    task.wait(1)
    
    -- Загружаем новый
    if SCRIPT_URL and SCRIPT_URL ~= "" then
        pcall(function()
            local script = game:HttpGet(SCRIPT_URL)
            loadstring(script)()
        end)
    else
        -- Если нет URL, пробуем загрузить из глобальной переменной
        local savedScript = getgenv()._savedScript
        if savedScript then
            loadstring(savedScript)()
        else
            Library:Notify("❌ Нет URL для перезагрузки!")
        end
    end
end

-- Сохраняем текущий скрипт при загрузке
if not getgenv()._savedScript then
    pcall(function()
        local scriptSource = debug.getinfo(1).source
        if scriptSource then
            getgenv()._savedScript = scriptSource
        end
    end)
end

-- Выбор темы
UISettingsGroup:AddDropdown("ThemeSelector", {
    Text = "Select Theme",
    Values = {"Dark", "Light", "Neon", "Ocean", "Forest"},
    Default = 1,
    Multi = false,
    Callback = function(v)
        getgenv().FarmConfig.UITheme = v
        ApplyTheme(v, getgenv().FarmConfig.UIColor or "Blue")
    end
})

-- Выбор цвета
UISettingsGroup:AddDropdown("ColorSelector", {
    Text = "Select Accent Color",
    Values = {"Blue", "Red", "Green", "Purple", "Orange", "Pink", "Cyan"},
    Default = 1,
    Multi = false,
    Callback = function(v)
        getgenv().FarmConfig.UIColor = v
        ApplyTheme(getgenv().FarmConfig.UITheme or "Dark", v)
    end
})

-- Размер интерфейса
UISettingsGroup:AddSlider("UISizeSlider", {
    Text = "UI Size Scale",
    Default = 1,
    Min = 0.5,
    Max = 1.5,
    Rounding = 1,
    Callback = function(v)
        getgenv().FarmConfig.UISize = v
        if Window.SetScale then
            Window.SetScale(v)
        end
        Library:Notify("Размер UI: " .. v)
    end
})

-- Прозрачность
UISettingsGroup:AddSlider("UITransparency", {
    Text = "UI Transparency",
    Default = 0,
    Min = 0,
    Max = 0.8,
    Rounding = 1,
    Callback = function(v)
        if Window.SetTransparency then
            Window.SetTransparency(v)
        end
    end
})

-- =========================================================
-- ВЫБОР БИБЛИОТЕКИ
-- =========================================================
LibraryGroup:AddDropdown("LibrarySelector", {
    Text = "Select UI Library",
    Values = {"Obsidian", "Fluent", "Aero", "DarkHub"},
    Default = 1,
    Multi = false,
    Callback = function(v)
        UI_LIBRARY = v
        getgenv()._selectedLibrary = v
        Library:Notify("📚 Выбрана: " .. v .. ". Нажмите Apply для применения")
    end
})

-- Кнопка применения
LibraryGroup:AddButton({
    Text = "🔄 Apply Library & Restart Script",
    Func = function()
        ReloadScript()
    end
})

-- Настройка URL
LibraryGroup:AddButton({
    Text = "⚙️ Set Script URL (for reload)",
    Func = function()
        local url = Library:InputBox("Введите URL вашего скрипта:", "https://raw.githubusercontent.com/...")
        if url and url ~= "" then
            SCRIPT_URL = url
            getgenv()._scriptURL = url
            Library:Notify("✅ URL сохранен!")
        else
            Library:Notify("❌ URL не введен!")
        end
    end
})

-- Показать URL
LibraryGroup:AddButton({
    Text = "📋 Show Current Script URL",
    Func = function()
        if SCRIPT_URL and SCRIPT_URL ~= "" then
            Library:Notify("📋 Текущий URL: " .. SCRIPT_URL)
        else
            Library:Notify("❌ URL не установлен!")
        end
    end
})

-- Дополнительные настройки UI
MiscUIGroup:AddToggle("ShowNotifications", {
    Text = "Show Notifications",
    Default = true,
    Callback = function(v)
        if Library.SetNotifications then
            Library.SetNotifications(v)
        end
    end
})

MiscUIGroup:AddToggle("ShowFooter", {
    Text = "Show Footer",
    Default = true,
    Callback = function(v)
        if Window.SetFooter then
            Window.SetFooter(v)
        end
    end
})

MiscUIGroup:AddToggle("CompactMode", {
    Text = "Compact Mode",
    Default = false,
    Callback = function(v)
        if Window.SetCompact then
            Window.SetCompact(v)
        end
    end
})

MiscUIGroup:AddButton({
    Text = "🔄 Quick Reload Script",
    Func = function()
        ReloadScript()
    end
})

MiscUIGroup:AddButton({
    Text = "🎨 Reset UI to Default",
    Func = function()
        ApplyTheme("Dark", "Blue")
        getgenv().FarmConfig.UITheme = "Dark"
        getgenv().FarmConfig.UIColor = "Blue"
        getgenv().FarmConfig.UISize = 1
        Library:Notify("🎨 UI сброшен к стандартным настройкам!")
    end
})

-- =========================================================
-- 18. UI SETTINGS (Управление скриптом)
-- =========================================================
local SettingsGroup = Tabs["UI Settings"]:AddRightGroupbox("Script Control")

local function UnloadScript()
    print("🔄 Выгрузка скрипта...")
    
    getgenv().BABFT_Running = false
    getgenv().FarmConfig.AutoFarmGold = false
    
    if FarmLoopThread then
        pcall(function() task.cancel(FarmLoopThread) end)
        FarmLoopThread = nil
    end
    IsFarmRunning = false
    
    State.Fly = false
    State.BlackHole = false
    State.AntiAFK = false
    
    ESPEnabled = false
    for _, obj in ipairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    if ESPConnections.Update then
        pcall(function() ESPConnections.Update:Disconnect() end)
        ESPConnections.Update = nil
    end
    
    BlackHoleEnabled = false
    for _, part in ipairs(BlackHoleParts) do
        pcall(function() part:Destroy() end)
    end
    BlackHoleParts = {}
    BlackHoleCenter = nil
    
    for name, conn in pairs(Connections) do 
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
        Connections[name] = nil
    end
    
    if AntiAFKConnection then
        pcall(function() AntiAFKConnection:Disconnect() end)
        AntiAFKConnection = nil
    end
    
    -- Сохраняем настройки
    getgenv()._selectedLibrary = UI_LIBRARY
    getgenv()._scriptURL = SCRIPT_URL
    
    getgenv().BABFT_Loaded = nil
    getgenv().BABFT_Unload = nil
    getgenv().BABFT_Running = nil
    getgenv()._BABFT_Connections = nil
    
    Workspace.Gravity = 196.2
    
    pcall(function() 
        if Library and Library.Unload then
            Library:Unload() 
        end
    end)
    print("✅ Скрипт выгружен!")
end

getgenv().BABFT_Unload = UnloadScript

SettingsGroup:AddButton({
    Text = "🧹 Выгрузить скрипт",
    Func = function() UnloadScript() end
})

SettingsGroup:AddButton({
    Text = "💾 Сохранить настройки",
    Func = function()
        if SaveManager and SaveManager.Save then
            SaveManager.Save()
            Library:Notify("💾 Настройки сохранены!")
        else
            Library:Notify("❌ Функция сохранения недоступна")
        end
    end
})

SettingsGroup:AddButton({
    Text = "📂 Загрузить настройки",
    Func = function()
        if SaveManager and SaveManager.Load then
            SaveManager.Load()
            Library:Notify("📂 Настройки загружены!")
        else
            Library:Notify("❌ Функция загрузки недоступна")
        end
    end
})

-- =========================================================
-- 19. ГОРЯЧИЕ КЛАВИШИ
-- =========================================================
local function SetupHotkeys()
    if getgenv()._xenoHotkeys then
        for _, conn in ipairs(getgenv()._xenoHotkeys) do
            pcall(function() conn:Disconnect() end)
        end
    end
    getgenv()._xenoHotkeys = {}
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
                        UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        
        if (input.KeyCode == Enum.KeyCode.Equals or input.KeyCode == Enum.KeyCode.Plus) and ctrlDown then
            if input.UserInputState == Enum.UserInputState.Begin then
                Camera.FieldOfView = math.min(Camera.FieldOfView + 5, 120)
            end
        end
        
        if input.KeyCode == Enum.KeyCode.Minus and ctrlDown then
            if input.UserInputState == Enum.UserInputState.Begin then
                Camera.FieldOfView = math.max(Camera.FieldOfView - 5, 1)
            end
        end
        
        if input.KeyCode == Enum.KeyCode.P and ctrlDown then
            if input.UserInputState == Enum.UserInputState.Begin then
                Camera.FieldOfView = math.min(Camera.FieldOfView + 10, 120)
            end
        end
        
        if input.KeyCode == Enum.KeyCode.O and ctrlDown then
            if input.UserInputState == Enum.UserInputState.Begin then
                Camera.FieldOfView = math.max(Camera.FieldOfView - 10, 1)
            end
        end
        
        -- Ctrl + H - показать/скрыть UI
        if input.KeyCode == Enum.KeyCode.H and ctrlDown then
            if input.UserInputState == Enum.UserInputState.Begin then
                if Window.Visible then
                    Window.Hide()
                    Library:Notify("👻 UI скрыт (Ctrl+H)")
                else
                    Window.Show()
                    Library:Notify("👻 UI показан (Ctrl+H)")
                end
            end
        end
    end)
end

SetupHotkeys()

-- =========================================================
-- 20. ПРИМЕНЯЕМ НАЧАЛЬНУЮ ТЕМУ
-- =========================================================
ApplyTheme("Dark", "Blue")

-- =========================================================
-- 21. ФИНАЛ
-- =========================================================
print("═══════════════════════════════════════")
print("   🚀 BABFT ULTIMATE HUB v5.1")
print("   ✅ Все функции загружены!")
print("   🎨 UI настройки добавлены!")
print("   📚 Выберите библиотеку в UI Settings")
print("   🔑 Ctrl+P/O = Zoom")
print("   🔑 Ctrl+H = Hide/Show UI")
print("═══════════════════════════════════════")

Library:Notify("🚀 BABFT Ultimate Hub v5.1 загружен!")
task.wait(0.5)
Library:Notify("📚 Чтобы сменить библиотеку, вставьте URL скрипта!")
task.wait(0.5)
Library:Notify("⚙️ Нажмите 'Set Script URL' и введите ссылку на скрипт")
task.wait(0.5)
Library:Notify("🔄 Затем нажмите 'Apply Library & Restart Script'")

getgenv()._BABFT_Connections = Connections