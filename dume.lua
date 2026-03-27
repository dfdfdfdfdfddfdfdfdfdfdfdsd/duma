-- ==========================================
-- ⚡ MomoHub v4.5 - Fast Attack Engine (Strongest Boss Edition)
-- ✅ Safe Bypass, Auto Summon, Auto Strongest Boss, Multi-Island Support
-- ==========================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- ==========================================
-- 🚀 [ ULTRA BOOST FPS & REDUCE LAG ]
-- ==========================================
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    -- ปิดเอฟเฟคแสงขั้นสูงสุด
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        pcall(function() Terrain:Clear() end) -- ลบก้อนน้ำและหญ้าทั้งหมด
    end

    -- ฟังก์ชั่นล้างกราฟิกให้เป็นตัวต่อพลาสติก
    local function CleanPart(v)
        pcall(function()
            if v:IsA("BasePart") or v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            end
        end)
    end

    -- ลบหมอกและท้องฟ้าออกหมด แสงจะกลายเป็นโล่งๆ ดิบๆ
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
            v:Destroy()
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        CleanPart(v)
    end

    -- ถ้ามี Object อะไรโหลดเพิ่มมาใหม่ จับลดกราฟิกให้หมดทันที
    workspace.DescendantAdded:Connect(function(v)
        CleanPart(v)
    end)
end)

-- ==========================================
-- 🌐 Global Variables
-- ==========================================
_G.TargetMob = nil 
_G.TargetPosition = nil

-- ✅ Global States
_G.BossRoundRobinIndex = 1
_G.LastBossKilledTime = 0
_G.BossNoMobAfterTeleport = {} 
_G.IslandRoundRobinIndex = 1
_G.LastIslandTeleportTime = 0 
_G.LastSummonTime = 0 -- สำหรับคูลดาวน์ระบบ Summon
_G.LastStrongestBossSummonTime = 0 -- สำหรับคูลดาวน์ระบบ Strongest Boss
_G.StrongestBossPhase = "teleport" -- phase: teleport, walkToNPC, summon, fight
_G.LastTrueAizenSummonTime = 0
_G.TrueAizenPhase = "teleport"
_G.HogyokuQuestPhase = "teleportToHueco"
_G.HogyokuSearchTarget = nil
_G.CollectedHogyokuFragments = {}
_G.LastFlyNotify = 0
_G.KaitunPhase = "checkSword"

local WeaponDatabase = {
    ["Saber"] = "Sword", ["Gojo"] = "Melee", ["Sukuna"] = "Melee", ["Jinwoo"] = "Sword",
    ["Combat"] = "Melee", ["Katana"] = "Sword", ["Dark Blade"] = "Sword", ["Ragna"] = "Sword",
    ["Aizen"] = "Sword", ["Qin Shi"] = "Melee", ["Yuji"] = "Melee", ["Shadow"] = "Sword",
    ["Alucard"] = "Melee", ["Strongest Of Today"] = "Melee", ["Strongest In History"] = "Melee",
    ["Ichigo"] = "Sword", ["Rimuru"] = "Sword", ["Madoka"] = "Melee", ["Gilgamesh"] = "Melee",
    ["Anos"] = "Melee", ["Shadow Monarch"] = "Sword", ["Escanor"] = "Sword", ["Blessed Maiden"] = "Melee",
    ["True Aizen"] = "Sword", ["Yamato"] = "Sword"
}

local BossDatabase = {
    ["YujiBoss"] = {Island = "ShibuyaStation", Prefix = "Shibuya", MobName = "Yuji"},
    ["SukunaBoss"] = {Island = "ShibuyaStation", Prefix = "Shibuya", MobName = "Sukuna"},
    ["GojoBoss"] = {Island = "ShibuyaStation", Prefix = "Shibuya", MobName = "Gojo"},
    ["JinwooBoss"] = {Island = "SailorIsland", Prefix = "Sailor", MobName = "Jinwoo"},
    ["AizenBoss"] = {Island = "HuecoMundo", Prefix = "HuecoMundo", MobName = "Aizen"},
    ["AlucardBoss"] = {Island = "SailorIsland", Prefix = "Sailor", MobName = "Alucard"},
    ["YamatoBoss"] = {Island = "JudgementIsland", Prefix = "Judgement", MobName = "Yamato", TimerName = "Yamato", SpawnerName = "TimedBossSpawn_YamatoBoss"}
}

local BossList = {"YujiBoss", "SukunaBoss", "GojoBoss", "JinwooBoss", "AizenBoss", "AlucardBoss", "YamatoBoss"}

local IslandList = {
    "Starter", "Jungle", "Desert", "Snow", "Sailor", "Shibuya", 
    "HuecoMundo", "Shinjuku", "Slime", "Academy", "Judgement", "SoulSociety"
}

local IslandMobDatabase = {
    ["Starter"] = {"Thief", "ThiefBoss"},
    ["Jungle"] = {"Monkey", "MonkeyBoss"},
    ["Desert"] = {"DesertBandit", "DesertBoss"},
    ["Snow"] = {"FrostRogue", "Winter"},
    ["Sailor"] = {"JinwooBoss", "Alucard"},
    ["Shibuya"] = {"Sorcerer", "PandaMiniBoss"},
    ["HuecoMundo"] = {"Hollow", "AizenBoss"},
    ["Shinjuku"] = {"Curse", "StrongSorcerer"},
    ["Slime"] = {"Slime"},
    ["Academy"] = {"Academy"},
    ["Judgement"] = {"Swordsman", "YamatoBoss"},
    ["SoulSociety"] = {"Quincy"}
}

-- ✅ ฐานข้อมูล Summon Boss
local AllSummonBosses = {
    "SaberBoss", "QinShiBoss", "IchigoBoss", 
    "GilgameshBoss", "BlessedMaidenBoss", "SaberAlterBoss"
}
local SummonBossDifficulties = {"Normal", "Medium", "Hard", "Extreme"}
local StrongestBossDifficulties = {"Normal", "Medium", "Hard", "Extreme"}
local StrongestBossTypes = {"StrongestToday", "StrongestHistory"}
local StrongestBossData = {
    ["StrongestToday"] = {RemoteArg = "StrongestToday", MobPrefix = "StrongestofTodayBoss_"},
    ["StrongestHistory"] = {RemoteArg = "StrongestHistory", MobPrefix = "StrongestinHistoryBoss_"}
}
local TrueAizenDifficulties = {"Normal", "Medium", "Hard", "Extreme"}

local SummonMobNames = {
    ["SaberBoss"] = "Saber",
    ["QinShiBoss"] = "QinShi",
    ["IchigoBoss"] = "Ichigo",
    ["GilgameshBoss"] = "Gilgamesh",
    ["BlessedMaidenBoss"] = "BlessedMaiden",
    ["SaberAlterBoss"] = "SaberAlter"
}

local QuestData = {
    {Level = 10000, NPC = "QuestNPC16", Target = "Swordsman"},
    {Level = 9000, NPC = "QuestNPC15", Target = "AcademyTeacher"},
    {Level = 8000, NPC = "QuestNPC14", Target = "SlimeWarrior"},
    {Level = 7000, NPC = "QuestNPC13", Target = "Curse"},
    {Level = 6250, NPC = "QuestNPC12", Target = "StrongSorcerer"},
    {Level = 5000, NPC = "QuestNPC11", Target = "Hollow"},
    {Level = 3000, NPC = "QuestNPC9", Target = "Sorcerer"},
    {Level = 1500, NPC = "QuestNPC7", Target = "FrostRogue"},
    {Level = 750, NPC = "QuestNPC5", Target = "DesertBandit"},
    {Level = 250, NPC = "QuestNPC3", Target = "Monkey"},
    {Level = 0, NPC = "QuestNPC1", Target = "Thief"} 
}


local MerchantItemsList = {
    "Race Reroll", "Trait Reroll", "Clan Reroll", "Boss Key", "Dungeon Key", 
    "Rush Key", "Boss Ticket", "Haki Color Reroll", "Common Chest", 
    "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest", "Secret Chest"
}

-- 🛡️ [ ANTI-ANTI-CHEAT ]
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return nil end
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = tostring(self):lower()
            if string.find(remoteName, "kick") or string.find(remoteName, "ban") or string.find(remoteName, "cheat") or string.find(remoteName, "exploit") or string.find(remoteName, "log") or string.find(remoteName, "flag") then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

local function getFarmInfo()
    local data = LP:WaitForChild("Data", 10)
    local level = data and data:WaitForChild("Level", 10)
    if level then
        for _, info in ipairs(QuestData) do
            if level.Value >= info.Level then return info.NPC, info.Target end
        end
    end
    return nil, nil
end

-- ==========================================
-- ⚙️ ลอจิกจัดการ Config
-- ==========================================
local ConfigFolder = "MoMoHub_Data"
local ConfigFile = ConfigFolder .. "/Settings.json"

local DefaultConfig = {
    AutoFarm = false, WeaponType = "None", FarmHeight = 9, TweenSpeed = 150,
    AutoSkill = false, SelectedSkills = {}, 
    AutoStats = false, StatAmount = 1, SelectedStats = {}, 
    AutoMerchant = false, SelectedMerchantItems = {},
    AutoBoss = false, SelectedBosses = {},
    AutoIsland = false, SelectedIslands = {},
    AutoSummon = false, SelectedSummonBoss = "SaberBoss", SelectedSummonDiff = "Normal",
    AutoStrongestBoss = false, SelectedStrongestBoss = "StrongestToday", SelectedStrongestDiff = "Normal",
    AutoTrueAizen = false, SelectedTrueAizenDiff = "Normal",
    AutoHogyokuQuest = false, AutoKaitun = false,
    AutoDungeon = false, NoClip = false, BypassTP = true,
    SelectedDungeonType = "RuneDungeon", SelectedDungeonDiff = "Easy",
    AutoReplayDungeon = false,
    WalkSpeed = 16, JumpPower = 50, AntiAFK = false, AutoRejoin = false, AutoSave = false, AutoLoad = false,
    AutoHaki = false, AutoArmamentHaki = false
}

local MoMoConfig = {}
if isfolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(DefaultConfig) do if decoded[k] == nil then decoded[k] = v end end
            return decoded
        end
    end
    return DefaultConfig
end

local SavedData = LoadConfig()
if SavedData.AutoLoad then MoMoConfig = SavedData else
    MoMoConfig = DefaultConfig
    MoMoConfig.AutoLoad = SavedData.AutoLoad
    MoMoConfig.AutoSave = SavedData.AutoSave
end

-- 🚀 บังคับเปิด Kaitun อัตโนมัติเมื่อรันสคริปต์
MoMoConfig.AutoKaitun = true
_G.KaitunPhase = "checkSword"

-- 🚀 บังคับลดหลุด & กัน AFK เมื่อรันสคริปต์
MoMoConfig.AutoRejoin = true
MoMoConfig.AntiAFK = true

if MoMoConfig.AntiAFK then
    pcall(function()
        if getgenv().AntiAfkConnection then getgenv().AntiAfkConnection:Disconnect() end
        getgenv().AntiAfkConnection = LP.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end

if MoMoConfig.AutoRejoin then
    pcall(function()
        local CoreGui = game:GetService("CoreGui")
        CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
                local teleportService = game:GetService("TeleportService")
                teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
            end
        end)
    end)
end

local function SaveConfig()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(MoMoConfig) end)
        if success then writefile(ConfigFile, encoded) end
    end
end
local function CheckAndSave() if MoMoConfig.AutoSave then SaveConfig() end end

-- ==========================================
-- 🎨 เริ่มโหลด UI (X2ZU)
-- ==========================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Window = Library:Window({
    Title = "MoMoHub", Desc = "", Icon = "shield-check",
    Theme = "Amethyst", Color = Color3.fromRGB(170, 0, 255),
    Config = { Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0, 500, 0, 450) },
    CloseUIButton = { Enabled = false, Text = "" }
})

local targetGui = (gethui and gethui()) or game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
local CustomGui = Instance.new("ScreenGui")
CustomGui.Name = "MoMoHubToggleUI"
CustomGui.ResetOnSpawn = false
CustomGui.Parent = targetGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name = "MoMoHubToggle"
ToggleBtn.Parent = CustomGui
ToggleBtn.Position = UDim2.new(0.5, -30, 0.1, 0) 
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxthumb://type=Asset&id=121052363208302&w=150&h=150"

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local vim = game:GetService("VirtualInputManager")
local isClicking = false
ToggleBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then isClicking = true end end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then isClicking = false end end)
ToggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isClicking then
        pcall(function() vim:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(0.05); vim:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game) end)
    end
end)

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 2, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = game:GetService("CoreGui") 
local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(138, 43, 226)
Glow.Thickness = 1
Glow.Transparency = 0.2
Glow.Parent = SidebarLine

local function setToggle(toggle, value)
    pcall(function()
        if toggle.Set then toggle:Set(value)
        elseif toggle.SetValue then toggle:SetValue(value)
        elseif toggle.SetState then toggle:SetState(value)
        end
    end)
end

local ToggleAutoFarm, ToggleAutoBoss, ToggleAutoIsland, ToggleAutoSummon, ToggleAutoStrongestBoss, ToggleAutoTrueAizen, ToggleAutoHogyokuQuest, ToggleAutoKaitun

local KaitunTab = Window:Tab({Title = "Kaitun \z226\z156\z168", Icon = "sparkles"}) do
    KaitunTab:Section({Title = "Auto Kaitun (Max Level System)"})
    ToggleAutoKaitun = KaitunTab:Toggle({ 
        Title = "Enable Auto Kaitun", Value = MoMoConfig.AutoKaitun, 
        Callback = function(val) 
            MoMoConfig.AutoKaitun = val
            if val then _G.KaitunPhase = "checkSword" end
            CheckAndSave() 
        end 
    })
end


local SettingsTab = Window:Tab({Title = "Settings", Icon = "settings"}) do
    SettingsTab:Section({Title = "Local Player"})
    SettingsTab:Slider({ Title = "WalkSpeed", Min = 16, Max = 250, Rounding = 1, Value = MoMoConfig.WalkSpeed, Callback = function(val) MoMoConfig.WalkSpeed = val; CheckAndSave(); if not MoMoConfig.BypassTP and LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = val end end })
    SettingsTab:Slider({ Title = "JumpPower", Min = 50, Max = 300, Rounding = 1, Value = MoMoConfig.JumpPower, Callback = function(val) MoMoConfig.JumpPower = val; CheckAndSave(); if not MoMoConfig.BypassTP and LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower = val end end })
    local AntiAfkConnection
    SettingsTab:Toggle({ Title = "Anti-AFK", Value = MoMoConfig.AntiAFK, Callback = function(State) MoMoConfig.AntiAFK = State; CheckAndSave(); if State then AntiAfkConnection = LP.Idled:Connect(function() VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) end) else if AntiAfkConnection then AntiAfkConnection:Disconnect(); AntiAfkConnection = nil end end end })
    SettingsTab:Toggle({ Title = "Auto Rejoin", Value = MoMoConfig.AutoRejoin, Callback = function(val) MoMoConfig.AutoRejoin = val; CheckAndSave() end })
    SettingsTab:Section({Title = "Config System"})
    SettingsTab:Toggle({ Title = "Auto Save Config", Value = MoMoConfig.AutoSave, Callback = function(State) MoMoConfig.AutoSave = State; SaveConfig(); Window:Notify({Title = "Config", Desc = State and "Auto Save Enabled" or "Auto Save Disabled", Time = 3}) end })
    SettingsTab:Toggle({ Title = "Auto Load Config", Value = MoMoConfig.AutoLoad, Callback = function(State) MoMoConfig.AutoLoad = State; SaveConfig(); Window:Notify({Title = "Config", Desc = State and "Auto Load Enabled" or "Auto Load Disabled", Time = 3}) end })
end

Window:Notify({Title = "MoMoHub", Desc = "God Mode Loaded!", Time = 4})

-- ==========================================
-- 🛡️ [ วิชามาร 2 & 3: STATE 11 BYPASS & PIVOT-TO ]
-- ==========================================
local function SafeBypassWarp(targetPos, lookTarget, customSpeed)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local dist = (root.Position - targetPos).Magnitude
    
    if dist < 300 then
        if lookTarget and (targetPos - lookTarget).Magnitude > 0.01 then
            char:PivotTo(CFrame.lookAt(targetPos, lookTarget))
        else
            char:PivotTo(CFrame.new(targetPos))
        end
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
        return
    end

    -- แบ่งเป็นช่วง วาปทีละ 250 studs ต่อ 0.1 วิ (Bypass TP)
    local steps = math.ceil(dist / 250)
    local startPos = root.Position

    for i = 1, steps do
        if not root or not root.Parent then break end
        
        local farmActive = (MoMoConfig.AutoFarm or MoMoConfig.AutoBoss or MoMoConfig.AutoIsland or MoMoConfig.AutoSummon or MoMoConfig.AutoDungeon or MoMoConfig.AutoStrongestBoss or MoMoConfig.AutoTrueAizen or MoMoConfig.AutoHogyokuQuest)
        if not farmActive then break end
        
        local nextPos = startPos:Lerp(targetPos, i / steps)
        
        if lookTarget and (targetPos - lookTarget).Magnitude > 0.01 then
            char:PivotTo(CFrame.lookAt(nextPos, lookTarget))
        else
            char:PivotTo(CFrame.new(nextPos))
        end
        
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.1)
    end
end

-- ==========================================
-- 🛡️ ควบคุม Collision & Bypass TP (0 Speed)
-- ==========================================
RunService.Stepped:Connect(function()
    local char = LP.Character
    if not char then return end

    local farmActive = (MoMoConfig.AutoFarm or MoMoConfig.AutoBoss or MoMoConfig.AutoIsland or MoMoConfig.AutoSummon or MoMoConfig.AutoDungeon or MoMoConfig.AutoStrongestBoss or MoMoConfig.AutoTrueAizen)
    local hasTarget = (_G.TargetMob or _G.TargetPosition)

    if (farmActive and hasTarget) or MoMoConfig.NoClip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
    
    local hum = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        if farmActive and hasTarget and MoMoConfig.BypassTP then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
            root.Velocity = Vector3.new(0, -0.1, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        else
            hum.WalkSpeed = MoMoConfig.WalkSpeed or 16
            hum.JumpPower = MoMoConfig.JumpPower or 50
        end
    end
end)

-- ==========================================
-- 🧠 ENGINE LOGIC START
-- ==========================================
local lastQuestNPC = nil 
local lastQuestTime = 0 
local lastIslandTeleport = 0

local function HogyokuTweenFly(targetPos)
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    local dist = (root.Position - targetPos).Magnitude
    if dist < 5 then return end
    
    hum:ChangeState(11)
    
    local speed = 5 -- บินความเร็ว 5 studs ต่อเฟรม (~300 studs/sec) เนียนและไม่กระชากเกินไป
    local steps = math.ceil(dist / speed)
    local startPos = root.Position
    
    for i = 1, steps do
        if not root or not root.Parent then break end
        if not MoMoConfig.AutoHogyokuQuest then break end
        
        local nextPos = startPos:Lerp(targetPos, i / steps)
        char:PivotTo(CFrame.new(nextPos))
        
        root.Velocity = Vector3.new(0, 0, 0)
        root.RotVelocity = Vector3.new(0, 0, 0)
        RunService.Heartbeat:Wait()
    end
    
    if hum then hum:ChangeState(8) end
end

local function getSelectedIslandList()
    local list = {}
    for k, v in pairs(MoMoConfig.SelectedIslands) do
        local name = (v == true) and k or (type(v) == "string" and v or nil)
        if name and table.find(IslandList, name) then table.insert(list, name) end
    end
    table.sort(list, function(a, b) return table.find(IslandList, a) < table.find(IslandList, b) end)
    return list
end

local function getClosestTargetMobForIsland(islandName)
    local targetNames = IslandMobDatabase[islandName]
    if not targetNames then return nil end

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest = nil
    local minDist = math.huge
    local npcsFolder = workspace:FindFirstChild("NPCs")
    
    if npcsFolder then
        for _, mob in pairs(npcsFolder:GetChildren()) do
            local isTarget = false
            for _, name in ipairs(targetNames) do
                if string.find(mob.Name, name) then
                    isTarget = true
                    break
                end
            end

            if isTarget and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                local dist = (mob.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = mob
                end
            end
        end
    end
    return closest
end

local function getSelectedBossList()
    local list = {}
    for k, v in pairs(MoMoConfig.SelectedBosses) do
        local name = (v == true) and k or (type(v) == "string" and v or nil)
        if name and BossDatabase[name] then table.insert(list, name) end
    end
    table.sort(list) 
    return list
end

local function findBossMob(mobName)
    local function checkMob(mob)
        return mob
            and string.find(mob.Name, mobName)
            and mob:FindFirstChild("Humanoid")
            and mob.Humanoid.Health > 0
            and mob:FindFirstChild("HumanoidRootPart")
    end

    -- 1. เช็คใน workspace.NPCs (บอสปกติส่วนใหญ่อยู่ที่นี่)
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, mob in pairs(npcsFolder:GetChildren()) do
            if checkMob(mob) then return mob end
        end
    end

    -- 2. เช็คใน workspace.Bosses
    local bossesFolder = workspace:FindFirstChild("Bosses")
    if bossesFolder then
        for _, mob in pairs(bossesFolder:GetChildren()) do
            if checkMob(mob) then return mob end
            -- ค้นหาใน children ของ folder ย่อยด้วย
            for _, child in pairs(mob:GetChildren()) do
                if checkMob(child) then return child end
            end
        end
    end

    -- 3. เช็คใน TimedBossSpawn_<mobName>_Container (เฉพาะบอสแบบ Timed)
    local containerName = "TimedBossSpawn_" .. mobName .. "_Container"
    local container = workspace:FindFirstChild(containerName)
    if container then
        for _, child in pairs(container:GetDescendants()) do
            if checkMob(child) then return child end
        end
    end

    -- 4. เช็คใน workspace โดยตรง (fallback)
    for _, obj in pairs(workspace:GetChildren()) do
        if checkMob(obj) then return obj end
    end

    return nil
end

-- เช็คว่า Yamato Boss เกิดแล้วจริงๆ (อยู่ใน Container)
local function isYamatoSpawned()
    local container = workspace:FindFirstChild("TimedBossSpawn_Yamato_Container")
    if not container then return false end
    for _, child in pairs(container:GetDescendants()) do
        if child:IsA("Model")
            and string.find(child.Name, "Yamato")
            and child:FindFirstChild("Humanoid")
            and child.Humanoid.Health > 0
            and child:FindFirstChild("HumanoidRootPart") then
            return true
        end
    end
    return false
end

local function getDungeonMob()
    local function isValidDungeonMob(mob)
        if mob:IsA("Model") and mob:FindFirstChild("Humanoid") then
            local part = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso") or mob.PrimaryPart
            if part and mob.Humanoid.Health > 0 then
                -- ตรวจสอบว่าใช่มอนสเตอร์ (ไม่ล็อกเป้าผู้เล่นอื่น)
                if not Players:GetPlayerFromCharacter(mob) and mob.Name ~= LP.Name then
                    return true
                end
            end
        end
        return false
    end

    -- 1. ค้นหาในโฟลเดอร์หลักที่เกมมักใช้เก็บมอนสเตอร์
    local foldersToCheck = {"NPCs", "Bosses", "Mobs", "Enemies", "DungeonMobs"}
    for _, folderName in pairs(foldersToCheck) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, mob in pairs(folder:GetChildren()) do
                if isValidDungeonMob(mob) then return mob end
                
                -- เผื่อมอนสเตอร์อยู่ในโฟลเดอร์ย่อย เช่น Wave1, Wave2
                for _, subMob in pairs(mob:GetChildren()) do
                    if isValidDungeonMob(subMob) then return subMob end
                end
            end
        end
    end

    -- 2. ค้นหาแบบกวาดใน Workspace โดยตรง (ละเว้นพวกที่ชัวร์ว่าไม่ใช่มอนสเตอร์)
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name ~= "ServiceNPCs" and obj.Name ~= "Map" and not obj:IsA("Camera") then
            if isValidDungeonMob(obj) then 
                return obj 
            end
        end
    end

    return nil
end

local function isBossSpawningSoon(bossName)
    local bData = BossDatabase[bossName]
    local timerKey = (bData and bData.TimerName) or bossName
    -- SpawnerName อาจต่างจาก timerKey เช่น Yamato Container ใช้ TimedBossSpawn_YamatoBoss ไม่ใช่ TimedBossSpawn_Yamato
    local spawnerName = (bData and bData.SpawnerName) or ("TimedBossSpawn_" .. timerKey)

    -- ถ้าเป็น Yamato ให้เช็คก่อนว่าบอสเกิดแล้วจริงๆ ไหม
    if bossName == "YamatoBoss" then
        if isYamatoSpawned() then return true end
    end

    -- เช็ค path: workspace.TimedBossSpawn_<timerKey>_Container.<spawnerName>.BossTimerBillboard.Frame.Timer
    local container = workspace:FindFirstChild("TimedBossSpawn_" .. timerKey .. "_Container")
    if not container then return false end
    local spawner = container:FindFirstChild(spawnerName)
    if not spawner then return false end
    local bb = spawner:FindFirstChild("BossTimerBillboard")
    if not bb then return false end
    local frame = bb:FindFirstChild("Frame")
    if not frame then return false end
    local timer = frame:FindFirstChild("Timer")
    if not timer then return false end

    local txt = string.lower(timer.Text)
    -- ถ้า timer ว่าง หรือมีคำว่า "spawn" = บอสเกิดแล้ว/กำลังจะเกิด → วาร์ปไป
    if txt == "" then return true end
    if string.find(txt, "spawn") then return true end
    return false
end

-- 🌟 [ Fast Attack Loop ]
task.spawn(function()
    while true do
        task.wait(0.1) 
        if (MoMoConfig.AutoFarm or MoMoConfig.AutoBoss or MoMoConfig.AutoIsland or MoMoConfig.AutoSummon or MoMoConfig.AutoDungeon or MoMoConfig.AutoStrongestBoss or MoMoConfig.AutoTrueAizen or MoMoConfig.AutoHogyokuQuest) and _G.TargetMob then
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local mobRoot = _G.TargetMob and (_G.TargetMob:FindFirstChild("HumanoidRootPart") or _G.TargetMob:FindFirstChild("Torso") or _G.TargetMob.PrimaryPart)
            if root and mobRoot and _G.TargetMob:FindFirstChild("Humanoid") and _G.TargetMob.Humanoid.Health > 0 then
                local dist = (root.Position - mobRoot.Position).Magnitude
                if dist < 20 then
                    pcall(function() RS.CombatSystem.Remotes.RequestHit:FireServer() end)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if MoMoConfig.AutoSkill and MoMoConfig.SelectedSkills and _G.TargetMob then
            pcall(function()
                local remote = RS:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility")
                for k, v in pairs(MoMoConfig.SelectedSkills) do
                    if v == "Z" or (k == "Z" and v == true) then remote:FireServer(1) end
                    if v == "X" or (k == "X" and v == true) then remote:FireServer(2) end
                    if v == "C" or (k == "C" and v == true) then remote:FireServer(3) end
                    if v == "V" or (k == "V" and v == true) then remote:FireServer(4) end
                    if v == "F" or (k == "F" and v == true) then remote:FireServer(5) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if MoMoConfig.AutoStats and MoMoConfig.SelectedStats then
            pcall(function()
                for k, v in pairs(MoMoConfig.SelectedStats) do
                    if v == true then RS.RemoteEvents.AllocateStat:FireServer(k, MoMoConfig.StatAmount)
                    elseif type(v) == "string" then RS.RemoteEvents.AllocateStat:FireServer(v, MoMoConfig.StatAmount) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1) 
        if MoMoConfig.AutoMerchant and MoMoConfig.SelectedMerchantItems then
            for k, v in pairs(MoMoConfig.SelectedMerchantItems) do
                local itemName = nil
                if v == true then itemName = k
                elseif type(v) == "string" then itemName = v end
                if itemName then
                    pcall(function()
                        local remote = RS:WaitForChild("Remotes"):WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")
                        remote:InvokeServer(itemName, 1)
                    end)
                    task.wait(0.3) 
                end
            end
        end
    end
end)

-- ==========================================
-- 👁️ Auto Observation Haki (Smart Detection)
-- ==========================================
_G.HakiIsActive = false
_G.HakiOnCooldown = false
_G.HakiCooldownEnd = 0

-- เช็คสถานะจาก DodgeCounterUI.MainFrame.Visible
-- จาก decompiled: Visible = true เมื่อ Haki เปิด, false เมื่อปิด
local function isHakiCurrentlyActive()
    local ok, result = pcall(function()
        local dodgeUI = LP.PlayerGui:FindFirstChild("DodgeCounterUI")
        local mainFrame = dodgeUI and dodgeUI:FindFirstChild("MainFrame")
        return mainFrame and mainFrame.Visible == true
    end)
    return ok and result == true
end

-- ดักฟัง Cooldown จาก server (จาก decompiled client script)
pcall(function()
    RS.RemoteEvents.ObservationHakiRemote.OnClientEvent:Connect(function(action, data)
        if action == "Activated" then
            _G.HakiIsActive = true
            _G.HakiOnCooldown = false
        elseif action == "Deactivated" then
            _G.HakiIsActive = false
            if data and data.cooldown and data.cooldown > 0 then
                _G.HakiOnCooldown = true
                _G.HakiCooldownEnd = tick() + data.cooldown
            end
        elseif action == "Status" then
            _G.HakiIsActive = data and data.isActive or false
            if data and data.cooldownRemaining and data.cooldownRemaining > 0 then
                _G.HakiOnCooldown = true
                _G.HakiCooldownEnd = tick() + data.cooldownRemaining
            else
                _G.HakiOnCooldown = false
            end
        end
    end)
end)

-- Loop เช็ค + เปิด Haki อัตโนมัติ
task.spawn(function()
    while true do
        task.wait(1)
        if MoMoConfig.AutoHaki then
            -- เช็ค cooldown หมดหรือยัง
            if _G.HakiOnCooldown and tick() >= _G.HakiCooldownEnd then
                _G.HakiOnCooldown = false
            end

            -- เช็คจาก DodgeCounterUI
            local hakiActive = isHakiCurrentlyActive()
            _G.HakiIsActive = hakiActive

            -- ถ้า Haki ปิดอยู่ + ไม่ cooldown → เปิด!
            if not hakiActive and not _G.HakiOnCooldown then
                pcall(function()
                    RS.RemoteEvents.ObservationHakiRemote:FireServer("Toggle")
                end)
            end
        end
    end
end)

-- ==========================================
-- 🛡️ Auto Armament Haki (Smart Detection)
-- ==========================================
_G.ArmamentHakiIsActive = false

-- ดักฟังสถานะจาก HakiStateUpdate (จาก decompiled: arg1 = true/false หรือ Player)
pcall(function()
    RS.RemoteEvents.HakiStateUpdate.OnClientEvent:Connect(function(p1, p2)
        if p1 == true then
            _G.ArmamentHakiIsActive = true
        elseif p1 == false then
            _G.ArmamentHakiIsActive = false
        elseif typeof(p1) == "Instance" and p1:IsA("Player") and p1 == LP then
            _G.ArmamentHakiIsActive = (p2 == true)
        end
    end)
end)

-- ดักฟัง Status จาก HakiRemote
pcall(function()
    RS.RemoteEvents.HakiRemote.OnClientEvent:Connect(function(action, data)
        if action == "Status" and data then
            _G.ArmamentHakiIsActive = data.isActive or false
        end
    end)
end)

-- Loop เช็ค + เปิด Armament Haki อัตโนมัติ
task.spawn(function()
    while true do
        task.wait(1)
        if MoMoConfig.AutoArmamentHaki then
            if not _G.ArmamentHakiIsActive then
                pcall(function()
                    RS.RemoteEvents.HakiRemote:FireServer("Toggle")
                end)
            end
        end
    end
end)

-- ==========================================
-- 🔄 Auto Rejoin System
-- ==========================================
task.spawn(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if MoMoConfig.AutoRejoin then
            task.wait(5)
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end
    end)
end)



-- ==========================================
-- 👑 [ ENGINE 0: Kaitun Supervisor ]
-- ==========================================
local function getStatValue(statName)
    local ok, result = pcall(function()
        local statsUI = LP.PlayerGui:FindFirstChild("StatsPanelUI")
        local mainFrame = statsUI and statsUI:FindFirstChild("MainFrame")
        local frame = mainFrame and mainFrame:FindFirstChild("Frame")
        local content = frame and frame:FindFirstChild("Content")
        local statsFrame = content and content:FindFirstChild("StatsFrame")
        local holder = statsFrame and statsFrame:FindFirstChild("Holder")
        local statFrame = holder and holder:FindFirstChild(statName .. "StatFrame")
        local sf = statFrame and statFrame:FindFirstChild("StatFrame")
        local ash = sf and sf:FindFirstChild("AutoSizeHolder")
        local sv = ash and ash:FindFirstChild("StatValue")
        if sv and sv.Text then
            local cleanText = string.gsub(sv.Text, ",", "")
            return tonumber(cleanText) or 0
        end
        return 0
    end)
    return ok and result or 0
end

-- Auto Skill Z/X Loop (สำหรับ Kaitun)
task.spawn(function()
    while true do
        task.wait(0.5)
        if MoMoConfig.AutoKaitun and _G.KaitunPhase == "farmLevel" and _G.TargetMob then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
            end)
            task.wait(0.3)
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.X, false, game)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if MoMoConfig.AutoKaitun then
            local char = LP.Character
            local hum = char and char:FindFirstChild("Humanoid")
            -- ป้องกันบัคตอนตายแล้วกระเป๋าหาย (สคริปจะไม่คิดว่าดาบหาย)
            if not char or not hum or hum.Health <= 0 then continue end
            
            local data = LP:FindFirstChild("Data")
            local moneyValue = data and data:FindFirstChild("Money") and data.Money.Value or 0
            
            -- เช็คว่ามีดาบในกระเป๋าหรือถืออยู่ไหม
            local hasSword = false
            local validSwords = {
                ["Katana"] = true, ["Saber"] = true, ["Jinwoo"] = true, 
                ["Shadow Monarch"] = true, ["Escanor"] = true, 
                ["True Aizen"] = true, ["Yamato"] = true
            }
            if LP.Backpack then
                for _, item in pairs(LP.Backpack:GetChildren()) do
                    if item:IsA("Tool") and validSwords[item.Name] then hasSword = true; break end
                end
            end
            if not hasSword and char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") and validSwords[item.Name] then hasSword = true; break end
                end
            end
            
            if not hasSword then
                -- ===== STEP 1: ยังไม่มีดาบ → หาเงินซื้อ Katana =====
                if moneyValue < 2500 then
                    if _G.KaitunPhase ~= "farmMoney" then
                        MoMoConfig.WeaponType = "Melee"
                        MoMoConfig.FarmHeight = 6
                        MoMoConfig.AutoStats = true
                        MoMoConfig.SelectedStats = {"Melee"}
                        MoMoConfig.AutoFarm = true
                        _G.KaitunPhase = "farmMoney"
                        if ToggleAutoFarm then setToggle(ToggleAutoFarm, true) end
                        pcall(function() Window:Notify({Title = "Auto Kaitun", Desc = "⚔️ Farming Money for Katana (2500)", Time = 5}) end)
                    end
                else
                    MoMoConfig.AutoFarm = false
                    if ToggleAutoFarm then setToggle(ToggleAutoFarm, false) end
                    
                    if _G.KaitunPhase ~= "buyKatana" then
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("Starter") end)
                        task.wait(3)
                        _G.KaitunPhase = "buyKatana"
                        pcall(function() Window:Notify({Title = "Auto Kaitun", Desc = "🗡️ Buying Katana...", Time = 5}) end)
                    end
                    
                    local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("Katana")
                    if npc then
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        local npcPart = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
                        if root and npcPart then
                            local dist = (root.Position - npcPart.Position).Magnitude
                            if dist > 15 then
                                SafeBypassWarp(npcPart.Position + Vector3.new(0, 3, 0), npcPart.Position)
                                task.wait(0.5)
                            else
                                local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    pcall(function() fireproximityprompt(prompt) end)
                                    task.wait(1)
                                    pcall(function() RS:WaitForChild("Remotes"):WaitForChild("EquipWeapon"):FireServer("Equip", "Katana") end)
                                    task.wait(1)
                                end
                            end
                        end
                    end
                end
            else
                -- ===== STEP 2: มีดาบแล้ว → รีสเตตัส + ฟาร์มด้วยดาบ =====
                if _G.KaitunPhase ~= "farmLevel" then
                    -- รีสเตตัสก่อน
                    pcall(function() Window:Notify({Title = "Auto Kaitun", Desc = "🔄 Resetting stats...", Time = 3}) end)
                    pcall(function() RS:WaitForChild("RemoteEvents"):WaitForChild("ResetStats"):FireServer() end)
                    task.wait(2)
                    
                    -- ตั้งค่าฟาร์มดาบ
                    MoMoConfig.WeaponType = "Sword"
                    MoMoConfig.FarmHeight = 10
                    MoMoConfig.AutoStats = true
                    MoMoConfig.StatAmount = 40
                    MoMoConfig.SelectedStats = {"Sword"}
                    MoMoConfig.AutoFarm = true
                    _G.KaitunPhase = "farmLevel"
                    if ToggleAutoFarm then setToggle(ToggleAutoFarm, true) end
                    pcall(function() Window:Notify({Title = "Auto Kaitun", Desc = "🗡️ Sword Farm Mode! Auto Skill Z/X ON", Time = 5}) end)
                end
                
                -- จัดการ Stats อัจฉริยะ: Sword ถึง 1000 แล้วอัพ Defense ควบคู่
                local swordStat = getStatValue("Sword")
                local defenseStat = getStatValue("Defense")
                
                if swordStat >= 1000 then
                    -- Sword ถึง 1000 แล้ว → อัพ Defense ควบคู่
                    if MoMoConfig.SelectedStats[1] ~= "Sword" or not MoMoConfig.SelectedStats[2] then
                        MoMoConfig.SelectedStats = {"Sword", "Defense"}
                        pcall(function() Window:Notify({Title = "Auto Kaitun", Desc = "🛡️ Sword 1000+! Adding Defense", Time = 3}) end)
                    end
                end
            end
        end
    end
end)



-- [ ENGINE 1: Logic & Target ]
task.spawn(function()
    while true do
        task.wait(0.1)
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")

        if (MoMoConfig.AutoFarm or MoMoConfig.AutoBoss or MoMoConfig.AutoIsland or MoMoConfig.AutoSummon or MoMoConfig.AutoDungeon or MoMoConfig.AutoStrongestBoss or MoMoConfig.AutoTrueAizen or MoMoConfig.AutoHogyokuQuest) and root then
            
            _G.TargetMob = nil
            _G.TargetPosition = nil

            local data = LP:FindFirstChild("Data")
            local levelData = data and data:FindFirstChild("Level")
            local currentLvl = levelData and levelData.Value or 0

            local activeBoss = nil
            local foundBossMob = nil

            -- 🌟 0. ระบบ Auto Dungeon (Priority 1)
            if MoMoConfig.AutoDungeon then
                local isInDungeon = workspace:FindFirstChild("DungeonModel") or workspace:FindFirstChild("DungeonSpawns")
                if not isInDungeon then
                    if not workspace:FindFirstChild("ActiveDungeonPortal") then
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("Dungeon") end)
                        task.wait(1)
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("RequestDungeonPortal"):FireServer(MoMoConfig.SelectedDungeonType) end)
                        task.wait(1)
                    end
                else
                    local dungeonMob = getDungeonMob()
                    if dungeonMob then
                        _G.TargetMob = dungeonMob
                    else
                        -- Vote for next wave + Replay dungeon
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("DungeonWaveVote"):FireServer(MoMoConfig.SelectedDungeonDiff) end)
                        if MoMoConfig.AutoReplayDungeon then
                            pcall(function() RS:WaitForChild("Remotes"):WaitForChild("DungeonWaveReplayVote"):FireServer("sponsor") end)
                        end
                    end
                end

            -- 🌟 0.5 ระบบ Auto Strongest Boss (แยกจาก Summon Boss)
            elseif MoMoConfig.AutoStrongestBoss then
                local diff = MoMoConfig.SelectedStrongestDiff or "Normal"
                local bossType = MoMoConfig.SelectedStrongestBoss or "StrongestToday"
                local bossData = StrongestBossData[bossType] or StrongestBossData["StrongestToday"]
                local strongestMobName = bossData.MobPrefix .. diff
                local remoteArg = bossData.RemoteArg
                local foundMob = findBossMob(strongestMobName)
                
                if foundMob then
                    -- พบบอสแล้ว ตีเลย!
                    _G.TargetMob = foundMob
                    _G.StrongestBossPhase = "fight"
                else
                    -- ไม่เจอบอส → ทำตามขั้นตอน
                    if _G.StrongestBossPhase == "teleport" then
                        -- Phase 1: วาปไป Shinjuku
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("Shinjuku") end)
                        pcall(function() Window:Notify({Title = "Strongest Boss", Desc = "🌀 Teleporting to Shinjuku...", Time = 3}) end)
                        task.wait(3)
                        _G.StrongestBossPhase = "walkToNPC"
                        
                    elseif _G.StrongestBossPhase == "walkToNPC" then
                        -- Phase 2: วาปไปหา NPC StrongestBossSummonerNPC โดยตรง
                        local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
                        local npc = serviceNPCs and serviceNPCs:FindFirstChild("StrongestBossSummonerNPC")
                        
                        if npc then
                            -- หา Part ของ NPC (ลองหลายแบบ)
                            local npcPart = npc:FindFirstChild("HumanoidRootPart") 
                                or npc:FindFirstChild("Torso") 
                                or npc:FindFirstChild("Head") 
                                or npc.PrimaryPart 
                                or npc:FindFirstChildWhichIsA("BasePart", true)
                            
                            if npcPart then
                                local npcPos = npcPart.Position
                                local dist = (root.Position - npcPos).Magnitude
                                
                                if dist > 10 then
                                    -- ✅ เรียก SafeBypassWarp ตรงๆ เพื่อวาปไปหา NPC
                                    pcall(function() Window:Notify({Title = "Strongest Boss", Desc = "🚶 Walking to NPC...", Time = 3}) end)
                                    SafeBypassWarp(npcPos + Vector3.new(0, 3, 0), npcPos)
                                    task.wait(0.5)
                                end
                                
                                -- ถึง NPC แล้ว → ไป Phase Summon
                                _G.StrongestBossPhase = "summon"
                            else
                                -- ไม่เจอ Part ของ NPC → ลอง warp ไปตำแหน่ง NPC model เลย
                                pcall(function()
                                    local cf = npc:GetPivot()
                                    if cf then
                                        SafeBypassWarp(cf.Position + Vector3.new(0, 3, 0), cf.Position)
                                        task.wait(0.5)
                                    end
                                end)
                                _G.StrongestBossPhase = "summon"
                            end
                        else
                            -- ไม่เจอ NPC อาจยังโหลดไม่เสร็จ → รอแล้วลองใหม่
                            task.wait(1)
                            local retryNPCs = workspace:FindFirstChild("ServiceNPCs")
                            local retryNPC = retryNPCs and retryNPCs:FindFirstChild("StrongestBossSummonerNPC")
                            if not retryNPC then
                                -- ยังไม่เจอจริงๆ → กลับไป teleport
                                pcall(function() Window:Notify({Title = "Strongest Boss", Desc = "⚠️ NPC not found, retrying...", Time = 3}) end)
                                _G.StrongestBossPhase = "teleport"
                            end
                        end
                        
                    elseif _G.StrongestBossPhase == "summon" then
                        -- Phase 3: ใช้รีโมท Summon Boss
                        if tick() - _G.LastStrongestBossSummonTime > 6 then
                            pcall(function()
                                RS:WaitForChild("Remotes"):WaitForChild("RequestSpawnStrongestBoss"):FireServer(remoteArg, diff)
                            end)
                            _G.LastStrongestBossSummonTime = tick()
                            pcall(function() Window:Notify({Title = "Strongest Boss", Desc = "🔥 Summoning " .. bossType .. " (" .. diff .. ")", Time = 3}) end)
                            task.wait(2)
                            
                            -- เช็คอีกครั้งว่าบอสเกิดหรือยัง
                            local checkMob = findBossMob(strongestMobName)
                            if checkMob then
                                _G.TargetMob = checkMob
                                _G.StrongestBossPhase = "fight"
                            else
                                -- ยังไม่เกิด → วนกลับไปเดินหา NPC แล้ว summon ใหม่
                                _G.StrongestBossPhase = "walkToNPC"
                            end
                        end
                        
                    elseif _G.StrongestBossPhase == "fight" then
                        -- Phase 4: บอสตายแล้ว → วนกลับไปเดินหา NPC แล้ว summon ใหม่
                        _G.StrongestBossPhase = "walkToNPC"
                    end
                end

            -- 🌟 0.6 ระบบ Auto True Aizen
            elseif MoMoConfig.AutoTrueAizen then
                local diff = MoMoConfig.SelectedTrueAizenDiff or "Normal"
                local mobName = "TrueAizenBoss_" .. diff
                local foundMob = findBossMob(mobName)
                
                if foundMob then
                    -- พบบอสแล้ว ตีเลย!
                    _G.TargetMob = foundMob
                    _G.TrueAizenPhase = "fight"
                else
                    -- ไม่เจอบอส → ทำตามขั้นตอน
                    if _G.TrueAizenPhase == "teleport" then
                        -- Phase 1: วาปไป SoulSociety
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("SoulSociety") end)
                        pcall(function() Window:Notify({Title = "True Aizen", Desc = "🌀 Teleporting to Soul Society...", Time = 3}) end)
                        task.wait(3)
                        _G.TrueAizenPhase = "walkToNPC"
                        
                    elseif _G.TrueAizenPhase == "walkToNPC" then
                        -- Phase 2: วาปไปหา NPC TrueAizenBossSummonerNPC โดยตรง
                        local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
                        local npc = serviceNPCs and serviceNPCs:FindFirstChild("TrueAizenBossSummonerNPC")
                        
                        if npc then
                            -- หา Part ของ NPC (ลองหลายแบบ)
                            local npcPart = npc:FindFirstChild("HumanoidRootPart") 
                                or npc:FindFirstChild("Torso") 
                                or npc:FindFirstChild("Head") 
                                or npc.PrimaryPart 
                                or npc:FindFirstChildWhichIsA("BasePart", true)
                            
                            if npcPart then
                                local npcPos = npcPart.Position
                                local dist = (root.Position - npcPos).Magnitude
                                
                                if dist > 10 then
                                    pcall(function() Window:Notify({Title = "True Aizen", Desc = "🚶 Walking to NPC...", Time = 3}) end)
                                    SafeBypassWarp(npcPos + Vector3.new(0, 3, 0), npcPos)
                                    task.wait(0.5)
                                end
                                
                                -- ถึง NPC แล้ว → ไป Phase Summon
                                _G.TrueAizenPhase = "summon"
                            else
                                pcall(function()
                                    local cf = npc:GetPivot()
                                    if cf then
                                        SafeBypassWarp(cf.Position + Vector3.new(0, 3, 0), cf.Position)
                                        task.wait(0.5)
                                    end
                                end)
                                _G.TrueAizenPhase = "summon"
                            end
                        else
                            task.wait(1)
                            local retryNPCs = workspace:FindFirstChild("ServiceNPCs")
                            local retryNPC = retryNPCs and retryNPCs:FindFirstChild("TrueAizenBossSummonerNPC")
                            if not retryNPC then
                                pcall(function() Window:Notify({Title = "True Aizen", Desc = "⚠️ NPC not found, retrying...", Time = 3}) end)
                                _G.TrueAizenPhase = "teleport"
                            end
                        end
                        
                    elseif _G.TrueAizenPhase == "summon" then
                        -- Phase 3: ใช้รีโมท Summon Boss
                        if tick() - _G.LastTrueAizenSummonTime > 6 then
                            pcall(function()
                                RS:WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnTrueAizen"):FireServer(diff)
                            end)
                            _G.LastTrueAizenSummonTime = tick()
                            pcall(function() Window:Notify({Title = "True Aizen", Desc = "🔥 Summoning True Aizen (" .. diff .. ")", Time = 3}) end)
                            task.wait(2)
                            
                            -- เช็คอีกครั้งว่าบอสเกิดหรือยัง
                            local checkMob = findBossMob(mobName)
                            if checkMob then
                                _G.TargetMob = checkMob
                                _G.TrueAizenPhase = "fight"
                            else
                                _G.TrueAizenPhase = "walkToNPC"
                            end
                        end
                        
                    elseif _G.TrueAizenPhase == "fight" then
                        -- Phase 4: บอสตายแล้ว → วนกลับไปเดินหา NPC แล้ว summon ใหม่
                        _G.TrueAizenPhase = "walkToNPC"
                    end
                end

            -- 🌟 0.7 ระบบ Auto Hogyoku Quest
            elseif MoMoConfig.AutoHogyokuQuest then
                if currentLvl < 8500 then
                    pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "⚠️ Level 8500+ Required!", Time = 3}) end)
                    task.wait(3)
                else
                    if _G.HogyokuQuestPhase == "teleportToHueco" then
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("HuecoMundo") end)
                        pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "🌀 Teleporting to Hueco Mundo...", Time = 3}) end)
                        task.wait(3)
                        _G.HogyokuQuestPhase = "walkToNPC"
                        
                    elseif _G.HogyokuQuestPhase == "walkToNPC" then
                        local serviceNPCs = workspace:FindFirstChild("ServiceNPCs")
                        local npc = serviceNPCs and serviceNPCs:FindFirstChild("HogyokuQuestNPC")
                        
                        if npc then
                            local npcPart = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChild("Head") or npc.PrimaryPart or npc:FindFirstChildWhichIsA("BasePart", true)
                            if npcPart then
                                local npcPos = npcPart.Position
                                local dist = (root.Position - npcPos).Magnitude
                                if dist > 10 then
                                    if tick() - _G.LastFlyNotify > 3 then
                                        pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "🚶 Flying to NPC...", Time = 3}) end)
                                        _G.LastFlyNotify = tick()
                                    end
                                    HogyokuTweenFly(npcPos + Vector3.new(0, 3, 0))
                                    task.wait(0.5)
                                else
                                    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        pcall(function() fireproximityprompt(prompt) end)
                                        pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "📜 Quested Accepted!", Time = 3}) end)
                                        task.wait(1)
                                    end
                                    _G.HogyokuQuestPhase = "searchIslands"
                                    _G.IslandRoundRobinIndex = 1
                                end
                            else
                                pcall(function()
                                    local cf = npc:GetPivot()
                                    if cf then
                                        if tick() - _G.LastFlyNotify > 3 then
                                            pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "🚶 Flying to NPC...", Time = 3}) end)
                                            _G.LastFlyNotify = tick()
                                        end
                                        HogyokuTweenFly(cf.Position + Vector3.new(0, 3, 0))
                                        task.wait(0.5)
                                        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then
                                            pcall(function() fireproximityprompt(prompt) end)
                                            task.wait(1)
                                        end
                                        _G.HogyokuQuestPhase = "searchIslands"
                                        _G.IslandRoundRobinIndex = 1
                                    end
                                end)
                            end
                        else
                            task.wait(1)
                        end
                        
                    elseif _G.HogyokuQuestPhase == "searchIslands" then
                        local fragment = nil
                        for i = 1, 6 do
                            local f = workspace:FindFirstChild("HogyokuFragment" .. i)
                            if f and not _G.CollectedHogyokuFragments[f.Name] then
                                fragment = f
                                break
                            end
                        end
                        -- Fallback for unnumbered fragments
                        if not fragment then
                            for _, child in pairs(workspace:GetChildren()) do
                                if string.find(child.Name, "HogyokuFragment") and not _G.CollectedHogyokuFragments[child.Name] then
                                    fragment = child
                                    break
                                end
                            end
                        end
                        
                        if fragment then
                            local fragPart = fragment:IsA("BasePart") and fragment or fragment:FindFirstChildWhichIsA("BasePart", true)
                            if fragPart then
                                local fragPos = fragPart.Position
                                local dist = (root.Position - fragPos).Magnitude
                                if dist > 10 then
                                    if tick() - _G.LastFlyNotify > 3 then
                                        pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "✈️ Flying to Fragment...", Time = 3}) end)
                                        _G.LastFlyNotify = tick()
                                    end
                                    HogyokuTweenFly(fragPos)
                                    task.wait(0.5)
                                else
                                    local prompt = fragment:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    if prompt then
                                        pcall(function() fireproximityprompt(prompt) end)
                                        _G.CollectedHogyokuFragments[fragment.Name] = true
                                        local count = 0
                                        for _, _ in pairs(_G.CollectedHogyokuFragments) do count = count + 1 end
                                        if count >= 6 then
                                            MoMoConfig.AutoHogyokuQuest = false
                                            if ToggleAutoHogyokuQuest then ToggleAutoHogyokuQuest:Set(false) end
                                            pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "🎉 You have collected all 6 Fragments!", Time = 5}) end)
                                        else
                                            pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "✨ Fragment Collected! (" .. count .. "/6)", Time = 3}) end)
                                        end
                                        task.wait(2)
                                    end
                                end
                            end
                        else
                            _G.HogyokuSearchTarget = nil
                            if tick() - _G.LastIslandTeleportTime > 3 then
                                _G.IslandRoundRobinIndex = (_G.IslandRoundRobinIndex % #IslandList) + 1
                                local nextIsland = IslandList[_G.IslandRoundRobinIndex]
                                
                                pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(nextIsland) end)
                                pcall(function() Window:Notify({Title = "Hogyoku Quest", Desc = "🏝️ Searching " .. nextIsland .. "...", Time = 3}) end)
                                
                                _G.LastIslandTeleportTime = tick()
                                task.wait(3) 
                            end
                        end
                    end
                end

            -- 🌟 1. ระบบ Auto Summon Boss
            elseif MoMoConfig.AutoSummon and MoMoConfig.SelectedSummonBoss then
                local bossName = MoMoConfig.SelectedSummonBoss
                local diff = MoMoConfig.SelectedSummonDiff
                
                -- หาชื่อมอนเพื่อล็อกเป้า
                local mobNamePrefix = SummonMobNames[bossName] or string.gsub(bossName, "Boss", "")
                local foundMob = findBossMob(mobNamePrefix)
                
                if foundMob then
                    _G.TargetMob = foundMob
                else
                    -- ถ้าไม่เจอมอนสเตอร์ ให้ไปรอที่ห้องบอสและลั่นรีโมท Summon
                    if tick() - _G.LastSummonTime > 6 then
                        -- เช็คว่าอยู่ห้อง Boss แล้วหรือยัง
                        local bossIsland = workspace:FindFirstChild("Boss")
                        local needTeleport = true
                        
                        if bossIsland and root then
                            local anyPart = bossIsland:FindFirstChildWhichIsA("BasePart", true)
                            if anyPart and (root.Position - anyPart.Position).Magnitude < 3000 then
                                needTeleport = false
                            end
                        end
                        
                        if needTeleport then
                            pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer("Boss") end)
                            task.wait(1.5) -- รอโหลดแมพห้องบอส
                        end
                        
                        -- ทำการ Summon
                        if bossName == "GilgameshBoss" or bossName == "BlessedMaidenBoss" or bossName == "SaberAlterBoss" then
                            pcall(function() RS:WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(bossName, diff) end)
                        else
                            pcall(function() RS:WaitForChild("Remotes"):WaitForChild("RequestSummonBoss"):FireServer(bossName) end)
                        end
                        
                        _G.LastSummonTime = tick()
                        pcall(function() Window:Notify({Title = "Auto Summon", Desc = "🔥 Summoning " .. bossName, Time = 3}) end)
                    end
                end

            -- 🌟 2. เช็ค Auto Boss ก่อน (Priority)
            elseif MoMoConfig.AutoBoss and MoMoConfig.SelectedBosses then
                local selectedList = getSelectedBossList()

                if #selectedList > 0 then
                    if _G.BossRoundRobinIndex > #selectedList then
                        _G.BossRoundRobinIndex = 1
                    end

                    local maxTry = #selectedList
                    local tried = 0

                    while tried < maxTry do
                        tried = tried + 1
                        local currentBossName = selectedList[_G.BossRoundRobinIndex]
                        local bData = BossDatabase[currentBossName]

                        local foundMob = nil
                        local isReady = false

                        if currentBossName == "GojoBoss" then
                            foundMob = findBossMob(bData.MobName)
                            local gojoSpawning = isBossSpawningSoon("GojoBoss")
                            isReady = foundMob ~= nil or gojoSpawning

                        elseif currentBossName == "JinwooBoss" or currentBossName == "AlucardBoss" then
                            foundMob = findBossMob(bData.MobName)
                            local spawning = isBossSpawningSoon(currentBossName)

                            if _G.BossNoMobAfterTeleport[currentBossName] then
                                if foundMob then
                                    _G.BossNoMobAfterTeleport[currentBossName] = false
                                    isReady = true
                                else
                                    isReady = false 
                                end
                            else
                                isReady = foundMob ~= nil or spawning
                            end
                        else
                            foundMob = findBossMob(bData.MobName)
                            isReady = foundMob ~= nil or isBossSpawningSoon(currentBossName)
                        end

                        if isReady then
                            activeBoss = currentBossName
                            foundBossMob = foundMob
                            break
                        else
                            _G.BossRoundRobinIndex = (_G.BossRoundRobinIndex % #selectedList) + 1
                            _G.CurrentActiveBoss = nil
                        end
                    end

                    if activeBoss and _G.CurrentActiveBoss ~= activeBoss then
                        _G.CurrentActiveBoss = activeBoss
                        pcall(function()
                            Window:Notify({Title = "Auto Boss", Desc = "🎯 Targeting: " .. activeBoss, Time = 3})
                        end)
                    end
                end
            end

            -- จัดการ Teleport และ Target ของบอส (Auto Boss)
            if activeBoss and not MoMoConfig.AutoSummon and not MoMoConfig.AutoStrongestBoss and not MoMoConfig.AutoTrueAizen then
                local bData = BossDatabase[activeBoss]

                local function doTeleport(prefix)
                    pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(prefix) end)
                    task.wait(3)
                end

                if activeBoss == "GojoBoss" then
                    local gojo = findBossMob(bData.MobName)
                    if gojo then
                        _G.TargetMob = gojo
                    elseif isBossSpawningSoon("GojoBoss") then
                        local shibuya = workspace:FindFirstChild("ShibuyaStation")
                        local needTeleport = true
                        
                        if shibuya and root then
                            local anyPart = shibuya:FindFirstChildWhichIsA("BasePart", true)
                            if anyPart and (root.Position - anyPart.Position).Magnitude < 3000 then
                                needTeleport = false
                            end
                        end
                        
                        if needTeleport then
                            doTeleport(bData.Prefix)
                        end
                        
                        pcall(function()
                            if shibuya and shibuya:FindFirstChild("Model") then
                                local targetGroup = shibuya.Model:GetChildren()[245]
                                if targetGroup then
                                    local targetPart = targetGroup:IsA("BasePart") and targetGroup or targetGroup:FindFirstChildWhichIsA("BasePart", true)
                                    if targetPart then _G.TargetPosition = targetPart.Position end
                                end
                            end
                        end)
                    end

                elseif activeBoss == "JinwooBoss" or activeBoss == "AlucardBoss" then
                    local thisMob = findBossMob(bData.MobName)
                    if thisMob then
                        _G.BossNoMobAfterTeleport[activeBoss] = false
                        _G.TargetMob = thisMob
                    elseif isBossSpawningSoon(activeBoss) then
                        -- บอสบอกว่าใกล้เกิด ลองวาร์ปไปดู
                        doTeleport(bData.Prefix)
                        local mobAfterTeleport = findBossMob(bData.MobName)
                        if mobAfterTeleport then
                            _G.BossNoMobAfterTeleport[activeBoss] = false
                            _G.TargetMob = mobAfterTeleport
                        else
                            -- วาร์ปมาแล้วแต่ไม่เจอ (อาจจะบักหรือคนอื่นฆ่าไปแล้ว) → ข้าม
                            _G.BossNoMobAfterTeleport[activeBoss] = true
                            local selectedList = getSelectedBossList()
                            _G.BossRoundRobinIndex = (_G.BossRoundRobinIndex % #selectedList) + 1
                            _G.CurrentActiveBoss = nil
                        end
                    end

                else
                    local mob = findBossMob(bData.MobName)
                    if mob then
                        _G.TargetMob = mob
                    elseif isBossSpawningSoon(activeBoss) then
                        -- ถ้าใกล้เกิด ให้วาร์ปไปรอ
                        doTeleport(bData.Prefix)
                    end
                end

            -- 🌟 3. ถ้าระบบ Boss/Summon ว่าง ให้มาระบบ Auto Island Farm
            elseif MoMoConfig.AutoIsland and not MoMoConfig.AutoSummon and not MoMoConfig.AutoStrongestBoss and not MoMoConfig.AutoTrueAizen then
                local selectedList = getSelectedIslandList()
                
                if #selectedList > 0 then
                    if _G.IslandRoundRobinIndex > #selectedList then
                        _G.IslandRoundRobinIndex = 1
                    end
                    
                    local currentIsland = selectedList[_G.IslandRoundRobinIndex]
                    local closestTargetMob = getClosestTargetMobForIsland(currentIsland)
                    
                    if closestTargetMob then
                        _G.TargetMob = closestTargetMob
                    else
                        if tick() - _G.LastIslandTeleportTime > 3 then
                            _G.IslandRoundRobinIndex = (_G.IslandRoundRobinIndex % #selectedList) + 1
                            local nextIsland = selectedList[_G.IslandRoundRobinIndex]
                            
                            pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(nextIsland) end)
                            pcall(function() Window:Notify({Title = "Auto Island", Desc = "🏝️ Clear! Next: " .. nextIsland, Time = 3}) end)
                            
                            _G.LastIslandTeleportTime = tick()
                            task.wait(0.5) 
                        end
                    end
                end

            -- 🌟 4. ระบบ Auto Level Farm ปกติ
            elseif MoMoConfig.AutoFarm then
                local npc, targetType = getFarmInfo()

                if npc ~= lastQuestNPC then
                    pcall(function() RS.RemoteEvents.QuestAbandon:FireServer("repeatable") end)
                    lastQuestNPC = npc
                    lastQuestTime = 0
                    task.wait(0.3)
                end
                if npc and (tick() - lastQuestTime > 5) then
                    pcall(function() RS.RemoteEvents.QuestAccept:FireServer(npc) end)
                    lastQuestTime = tick()
                end

                local npcsFolder = workspace:FindFirstChild("NPCs")
                if npcsFolder and targetType then
                    for _, mob in pairs(npcsFolder:GetChildren()) do
                        if string.find(mob.Name, targetType)
                            and mob:FindFirstChild("Humanoid")
                            and mob.Humanoid.Health > 0
                            and mob:FindFirstChild("HumanoidRootPart") then
                            local isCorrectMob = true
                            if not string.find(targetType, "Boss") and string.find(mob.Name, "Boss") then isCorrectMob = false end
                            if not string.find(targetType, "Strong") and string.find(mob.Name, "Strong") then isCorrectMob = false end
                            if isCorrectMob then _G.TargetMob = mob; break end
                        end
                    end
                end

                if not _G.TargetMob then
                    local prefix = ""
                    if currentLvl >= 10750 then prefix = "SoulSociety"
                    elseif currentLvl >= 10000 then prefix = "Judgement"
                    elseif currentLvl >= 9000 then prefix = "Academy"
                    elseif currentLvl >= 8000 then prefix = "Slime"
                    elseif currentLvl >= 6250 then prefix = "Shinjuku"
                    elseif currentLvl >= 5000 then prefix = "HuecoMundo"
                    elseif currentLvl >= 3000 then prefix = "Shibuya"
                    elseif currentLvl >= 1500 then prefix = "Snow"
                    elseif currentLvl >= 750 then prefix = "Desert"
                    elseif currentLvl >= 250 then prefix = "Jungle"
                    else prefix = "Starter" end

                    if tick() - lastIslandTeleport > 5 then
                        pcall(function() RS:WaitForChild("Remotes"):WaitForChild("TeleportToPortal"):FireServer(prefix) end)
                        lastIslandTeleport = tick()
                        task.wait(3)
                    end
                end
            end

            local selectedWeaponType = MoMoConfig.WeaponType
            if selectedWeaponType ~= "None" then
                local function getToolType(tName) return WeaponDatabase[tName] or "Melee" end
                local isEquipped = false
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and getToolType(tool.Name) == selectedWeaponType then isEquipped = true; break end
                end
                if not isEquipped then
                    for _, tool in pairs(LP.Backpack:GetChildren()) do
                        if tool:IsA("Tool") and getToolType(tool.Name) == selectedWeaponType then
                            if char:FindFirstChild("Humanoid") then char.Humanoid:EquipTool(tool) end
                            break
                        end
                    end
                end
            end

        else
            _G.TargetMob = nil
            _G.TargetPosition = nil
        end
    end
end)

-- ==========================================
-- 🚀 [ ENGINE 2: Movement Execution ]
-- ==========================================
task.spawn(function()
    while true do
        task.wait() 
        
        local farmActive = (MoMoConfig.AutoFarm or MoMoConfig.AutoBoss or MoMoConfig.AutoIsland or MoMoConfig.AutoSummon or MoMoConfig.AutoDungeon or MoMoConfig.AutoStrongestBoss or MoMoConfig.AutoTrueAizen or MoMoConfig.AutoHogyokuQuest)
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if farmActive and root and hum then
            
            local bv = root:FindFirstChild("MomoFloatBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "MomoFloatBV"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = root
            end

            local hasTarget = (_G.TargetMob ~= nil) or (_G.TargetPosition ~= nil)
            
            if hasTarget and (
                (_G.TargetMob and _G.TargetMob:FindFirstChild("HumanoidRootPart") and _G.TargetMob.Humanoid.Health > 0) or
                (_G.TargetPosition ~= nil)
            ) then
                
                root.Anchored = false 
                if hum then hum.PlatformStand = false end
                
                local targetPos = nil
                local lookAtTarget = nil
                
                local mobRoot = _G.TargetMob and (_G.TargetMob:FindFirstChild("HumanoidRootPart") or _G.TargetMob:FindFirstChild("Torso") or _G.TargetMob.PrimaryPart)
                if mobRoot and _G.TargetMob:FindFirstChild("Humanoid") and _G.TargetMob.Humanoid.Health > 0 then
                    targetPos = mobRoot.Position + Vector3.new(0, MoMoConfig.FarmHeight, 0)
                    lookAtTarget = mobRoot.Position
                elseif _G.TargetHogyoku then
                    -- Hogyoku loop handles its own SafeBypassWarp, but we must not anchor here.
                    -- We can just set a dummy targetPos so SafeBypassWarp isn't called again here if we don't want to.
                    -- Actually, it's better to let ENGINE 2 just skip movement if a quest loop is doing it.
                elseif _G.TargetDungeon then
                    -- Same for Dungeon Unlock
                elseif _G.TargetPosition then
                    targetPos = _G.TargetPosition
                end
                
                if targetPos then
                    lookAtTarget = lookAtTarget or targetPos
                    SafeBypassWarp(targetPos, lookAtTarget)
                end
            else
                root.Anchored = true
                root.Velocity = Vector3.new(0,0,0)
            end
        else
            if root then
                for _, oldBv in pairs(root:GetChildren()) do
                    if oldBv:IsA("BodyVelocity") and string.find(oldBv.Name, "Momo") then
                        oldBv:Destroy()
                    end
                end
                root.Anchored = false
                if hum then 
                    hum.PlatformStand = false
                    hum:ChangeState(8)
                end
            end
        end
    end
end)
