repeat task.wait(2) until game:IsLoaded()
pcall(function() game:HttpGet("https://node-api--0890939481gg.replit.app/join") end)

-- theme
local _MDUCCDEV_THEME = "https://raw.githubusercontent.com/lnaa323sda/scki343/refs/heads/main/theme.lua"
pcall(function()
	loadstring(game:HttpGet(_MDUCCDEV_THEME))()
end)
task.wait(8)

-- Gate: main script body must NEVER run unless API validated (preset key / HWID / Check Key success)
local _dieverKeyOk = false
local _dieverMainLaunched = false

local function runSailorMainScript()
	if not _dieverKeyOk then
		return
	end

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
        print("[HAKI STATUS] ✅ Player HAS Haki!", hakiInfo)
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
                    print("[INVENTORY]", rarity, ":", name, "x" .. qty)
                end
            end
        end
    end)

    task.wait(3)
    print("[INVENTORY] Requesting inventory data...")
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

    oldPrint("\n========================================")
    oldPrint("📊 INVENTORY | ⭐Lv." .. level .. " 💰" .. money .. " 💎" .. gems)
    oldPrint("========================================")

    -- Crates
    for name, qty in pairs(cratesAndBoxes) do
        oldPrint("  📦 " .. name .. " x" .. qty)
    end

    -- Items by rarity
    local order = {"Secret","Mythical","Legendary","Epic","Rare","Uncommon","Common"}
    local emojis = {Secret="🌟",Mythical="✨",Legendary="🔥",Epic="💜",Rare="💙",Uncommon="💚",Common="⚪"}
    for _, rarity in ipairs(order) do
        local items = inventoryByRarity[rarity]
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        if count > 0 then
            oldPrint(emojis[rarity] .. " [" .. rarity:upper() .. "] " .. count .. " items:")
            for name, qty in pairs(items) do
                oldPrint("   • " .. name .. " x" .. qty)
            end
        end
    end
    oldPrint("========================================\n")
end)

-- [7] HORST DISPLAY
if _G.Config.HorstDisplay then
task.spawn(function()
    local data = player:WaitForChild("Data", 30)
    if not data then
        print("[HORST] ❌ Data not found!")
        return
    end

    task.wait(5)
    print("[HORST] Starting Horst Display...")

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
        print("[HORST]", message)

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
            print("[STATS] Lv." .. level .. " | Stat points:", points)

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
                print("[STATS] ✅ Melee +" .. melee .. ", Defense +" .. defense .. " (Lv." .. level .. ")")
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
                print("[STATS] ✅ Sword +" .. sword .. ", Defense +" .. defense .. ", Power +" .. power)
            end
        end)
    end
end)
end -- AutoStats


-- [9] STATS & WEAPON SYSTEM
local function resetStats()
    print("[STATS] Resetting all stats...")
    pcall(function()
        local r = RemoteEvents:FindFirstChild("ResetStats")
        if r then r:FireServer() end
    end)
    task.wait(2)
    print("[STATS] ✅ Stats reset!")
end

local function upgradeStats()
    print("[STATS] Upgrading stats after reset...")
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

    print("[STATS] ✅ Sword +" .. swordPts .. ", Defense +" .. defensePts .. ", Power +" .. powerPts)
end

local function buyDarkBlade()
    print("[WEAPON] ========== BUYING DARK BLADE ==========")
    isBuyingDarkBlade = true

    -- กรณีที่ 1: มีอยู่แล้ว (แบบ v3)
    if checkOwnerDarkBlade() then
        print("[WEAPON] ✅ Dark Blade already equipped!")
        isBuyingDarkBlade = false
        return true
    end
    if checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") then
        print("[WEAPON] ✅ Equipping from inventory...")
        equipDarkBladeFromInventory()
        isBuyingDarkBlade = false
        return true
    end

    -- Case 2: Still don't have → Buy
    local gem = player.Data.Gems.Value
    local money = player.Data.Money.Value
    print("[WEAPON] Gems:", gem, "Money:", money)

    if gem < _G.Config.DarkBladeGems or money < _G.Config.DarkBladeMoney then
        print("[WEAPON] ❌ Not enough resources!")
        isBuyingDarkBlade = false
        return false
    end

    -- Buy exactly v3: while loop + ResetStats + fireproximityprompt
    local npcCF = CFrame.new(-132.516449, 13.2661686, -1091.2699, 0.972926259, 0, 0.231115878, 0, 1, 0, -0.231115878, 0, 0.972926259)
    local maxAttempts = 20

    while not (checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()) and maxAttempts > 0 do
        maxAttempts = maxAttempts - 1
        print("[WEAPON] 🔄 Purchase attempt", 20 - maxAttempts)

        -- ResetStats before buy (v3)
        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)

        local npcHRP = nil
        pcall(function()
            npcHRP = workspace.ServiceNPCs.DarkBladeNPC:FindFirstChild("HumanoidRootPart")
        end)

        if not npcHRP then
            print("[WEAPON] ❌ NPC HRP not found, teleporting...")
            tweenPos(npcCF)
            task.wait(1)
        else
            local prompt = npcHRP:FindFirstChild("DarkBladeShopPrompt")
            if prompt then
                print("[WEAPON] ✅ Buying Dark Blade (fireproximityprompt)...")
                prompt.MaxActivationDistance = math.huge
                fireproximityprompt(prompt)
                pcall(function()
                    RemoteEvents:WaitForChild("ResetStats"):FireServer()
                end)
                task.wait(5)
                equipDarkBladeFromInventory()
                task.wait(1)
            else
                print("[WEAPON] ❌ Prompt not found")
                tweenPos(npcCF)
                task.wait(1)
            end
        end
    end

    local purchased = checkDarkBlade("Dark Blade") or checkDarkBlade("ดาบสีเข้ม") or checkOwnerDarkBlade()
    if purchased then
        print("[WEAPON] 🎉 Dark Blade purchased!")
        resetStats()
        upgradeStats()
        
        -- Equip Dark Blade after reset (support both English and Thai)
        print("[WEAPON] 🗡️ Equipping Dark Blade...")
        task.wait(2)
        equipDarkBladeFromInventory()
        task.wait(1)
        
        if checkOwnerDarkBlade() then
            print("[WEAPON] ✅ Dark Blade equipped!")
        else
            print("[WEAPON] ⚠️ Dark Blade not equipped yet")
        end
    else
        print("[WEAPON] ❌ Failed to purchase")
    end

    isBuyingDarkBlade = false
    print("[WEAPON] ================================")
    return purchased
end

-- [10] FRUIT FARM SYSTEM
local function checkHasFruit(fruitName)
    oldPrint("[FRUIT] 🔍 Checking for", fruitName, "...")
    
    -- Check if fruit is in hand or Backpack (use string.find because real name is "Quake Fruit")
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    -- Check in Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                oldPrint("[FRUIT] ✅ Found", tool.Name, "in Character")
                return true  -- return immediately!
            end
        end
    end
    
    -- Check in Backpack
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                oldPrint("[FRUIT] ✅ Found", tool.Name, "in Backpack")
                return true  -- return immediately!
            end
        end
    end
    
    -- If not found in Character/Backpack → Check via Inventory Remote
    oldPrint("[FRUIT] 🔍 Not in Character/Backpack, checking Inventory Remote...")
    local hasFruit = false
    local connection = nil
    
    connection = RS.Remotes.UpdateInventory.OnClientEvent:Connect(function(tab, data)
        for _, item in pairs(data) do
            if item.name and item.name:find(fruitName) then
                hasFruit = true
                oldPrint("[FRUIT] ✅ Found", item.name, "in Inventory!")
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
        oldPrint("[FRUIT] ✅ Has", fruitName)
    else
        oldPrint("[FRUIT] ❌ No", fruitName)
    end
    
    return hasFruit
end

local function equipFruit(fruitName)
    print("[FRUIT] 🍎 Equipping fruit:", fruitName)
    
    -- Try Equip from Backpack (use string.find)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find(fruitName) then
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    print("[FRUIT] 🎯 Equipping:", tool.Name)
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
    oldPrint("[FRUIT] 🎲 Buying random fruit...")
    
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
        oldPrint("[FRUIT] ❌ Prompt not found!")
        return false
    end
    
    -- 4. Click to buy
    oldPrint("[FRUIT] 💰 Firing prompt...")
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
                oldPrint("[FRUIT] 📦 Found fruit in Backpack:", tool.Name)
                return tool
            end
        end
    end
    
    -- Check in Character (only fruits that haven't been eaten)
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("FruitData") then
                oldPrint("[FRUIT] 📦 Found fruit in Character:", tool.Name)
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
    oldPrint("[FRUIT] 🍽️ Eating fruit:", fruitName)
    
    local char = player.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    
    -- 1. Equip fruit
    if humanoid and fruitTool.Parent == backpack then
        oldPrint("[FRUIT] 📦 Equipping fruit...")
        humanoid:EquipTool(fruitTool)
        task.wait(0.5)
    end
    
    -- 2. Activate fruit → Open ConfirmUI
    oldPrint("[FRUIT] 🔨 Activating fruit to open ConfirmUI...")
    pcall(function()
        fruitTool:Activate()
    end)
    task.wait(1)
    
    -- 3. Find ConfirmUI and click Yes
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        oldPrint("[FRUIT] ✅ ConfirmUI found, clicking Yes...")
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
            oldPrint("[FRUIT] 🖱️ Clicked Yes button")
        end
    else
        -- If no UI → Fire remote directly
        oldPrint("[FRUIT] ⚠️ No ConfirmUI, firing FruitAction remote directly...")
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
        oldPrint("[FRUIT] ⚠️ Fruit still has FruitData - trying to destroy...")
        pcall(function()
            fruitTool:Destroy()
        end)
    else
        oldPrint("[FRUIT] ✅ Ate fruit successfully:", fruitName)
    end
end

local function allocateStatsPowerFirst()
    print("[FRUIT] 📊 Allocating stats: Power first (11500), then Sword")
    
    local points = 0
    pcall(function()
        points = player.Data.StatPoints.Value or 0
    end)
    
    if points <= 0 then
        print("[FRUIT] ✅ No stat points to allocate")
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
        
        print("[FRUIT] 🔥 Allocating", toAllocate, "points to Power (batch)")
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
        print("[FRUIT] ⚔️ Allocating", points, "points to Sword (batch)")
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
    
    print("[FRUIT] ✅ Stats allocated!")
end

local function fruitFarmLoop()
    print("[FRUIT FARM] 🍎 Starting AFK Fruit Farm Loop...")
    
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
    
    print("[FRUIT FARM] ❌ Fruit Farm Loop ended")
end

-- [11] ARTIFACTS UNLOCK SYSTEM
local function checkArtifactsUnlocked()
    -- Check if Artifacts are opened (use data.Unlocked from GetArtifactData)
    local unlocked = false
    pcall(function()
        local data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
        if data and type(data) == "table" and data.Unlocked == true then
            unlocked = true
            print("[ARTIFACTS] ✅ Already unlocked")
        else
            print("[ARTIFACTS] ❌ Not unlocked yet")
        end
    end)
    return unlocked
end

local function unlockArtifacts()
    print("[ARTIFACTS] ========== UNLOCK ARTIFACTS START ==========")
    
    -- 1. Check if Artifacts are opened
    if checkArtifactsUnlocked() then
        print("[ARTIFACTS] ⏭️ Already unlocked, skipping...")
        return true
    end
    
    -- 2. Teleport to ArtifactsUnlocker NPC
    print("[ARTIFACTS] 📍 Teleporting to ArtifactsUnlocker NPC...")
    local npcCFrame = CFrame.new(-440.516388, 1.77979147, -1095.86072, -0.289305925, -0, -0.957236767, 0, 1, -0, 0.957236767, 0, -0.289305925)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    -- 3. Find Prompt and fire
    print("[ARTIFACTS] 🔍 Finding ArtifactPrompt...")
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
        print("[ARTIFACTS] ❌ ArtifactPrompt not found!")
        return false
    end
    
    print("[ARTIFACTS] 💰 Firing ArtifactPrompt...")
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    -- 4. Wait for ConfirmUI and click Yes
    print("[ARTIFACTS] ⏳ Waiting for ConfirmUI...")
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        print("[ARTIFACTS] ✅ ConfirmUI found, clicking Yes...")
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
            print("[ARTIFACTS] 🖱️ Clicked Yes button")
        end
    else
        -- If no UI → Fire remote directly
        print("[ARTIFACTS] ⚠️ No ConfirmUI, firing ArtifactUnlockSystem remote...")
        pcall(function()
            RemoteEvents:WaitForChild("ArtifactUnlockSystem"):FireServer()
        end)
    end
    
    task.wait(3)
    
    -- 5. Check if Artifacts are opened successfully
    if checkArtifactsUnlocked() then
        print("[ARTIFACTS] ✅ Artifacts unlocked successfully!")
        return true
    else
        print("[ARTIFACTS] ❌ Failed to unlock Artifacts")
        return false
    end
end

local function equipArtifacts()
    oldPrint("[ARTIFACTS] 🎯 Equipping Artifacts...")
    
    -- 1. Open UI first
    pcall(function()
        RemoteEvents:WaitForChild("ArtifactUIOpened"):FireServer()
    end)
    oldPrint("[ARTIFACTS] 📂 Opened Artifact UI")
    task.wait(2)
    
    -- 2. Get all artifact data
    local data = nil
    local ok, err = pcall(function()
        data = RS:WaitForChild("RemoteFunctions"):WaitForChild("GetArtifactData"):InvokeServer()
    end)
    oldPrint("[ARTIFACTS] 📡 GetArtifactData ok:", tostring(ok), "err:", tostring(err))
    
    if data and type(data) == "table" then
        -- Deep debug: show all fields
        local allIds = {}
        local function deepScan(tbl, prefix)
            for k, v in pairs(tbl) do
                local key = prefix .. tostring(k)
                if type(v) == "table" then
                    oldPrint("[ARTIFACTS] 📊 " .. key .. " = {table}")
                    deepScan(v, key .. ".")
                else
                    oldPrint("[ARTIFACTS] 📊 " .. key .. " = " .. tostring(v))
                    -- Save all string UUID values
                    if type(v) == "string" and v:match("%x%x%x%x%x%x%x%x%-%x%x%x%x") then
                        table.insert(allIds, v)
                        oldPrint("[ARTIFACTS] 🔑 Found UUID: " .. v)
                    end
                end
            end
        end
        deepScan(data, "")
        
        -- Equip all found UUIDs
        oldPrint("[ARTIFACTS] 🔑 Total UUIDs found: " .. #allIds)
        for i, uuid in ipairs(allIds) do
            pcall(function()
                RemoteEvents:WaitForChild("ArtifactEquip"):FireServer(uuid)
            end)
            oldPrint("[ARTIFACTS] ✅ Equipped #" .. i .. ": " .. uuid)
            task.wait(0.5)
        end
    else
        oldPrint("[ARTIFACTS] ⚠️ No artifact data, type:", type(data))
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
                            oldPrint("[ARTIFACTS] 🔒 Clicking close button:", btn.Name)
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
            oldPrint("[ARTIFACTS] 🔒 Force disabled ArtifactsUI")
        end
    end)
    
    oldPrint("[ARTIFACTS] ✅ Closed Artifact UI")
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
    
    oldPrint("[OBS HAKI] Check hasObservationHaki:", tostring(hasObs))
    return hasObs
end

local function buyObservationHaki()
    oldPrint("[OBS HAKI] ========== BUY OBSERVATION HAKI START ==========")
    
    -- 1. Check if already have
    if checkHasObservationHaki() then
        oldPrint("[OBS HAKI] ⏭️ Already have Observation Haki, skipping...")
        return true
    end
    
    -- 2. Teleport to ObservationBuyer NPC
    oldPrint("[OBS HAKI] 📍 Teleporting to ObservationBuyer NPC...")
    local npcCFrame = CFrame.new(-713.182922, 12.1339779, -527.289795, -0.763382077, 0, 0.645947695, 0, 1, 0, -0.645947695, 0, -0.763382077)
    
    tweenPos(npcCFrame)
    task.wait(3)
    
    -- 3. Find Prompt and fire
    oldPrint("[OBS HAKI] 🔍 Finding ObservationHakiPrompt...")
    local npc = workspace:FindFirstChild("ServiceNPCs")
    if npc then npc = npc:FindFirstChild("ObservationBuyer") end
    if npc then npc = npc:FindFirstChild("HumanoidRootPart") end
    
    local prompt = nil
    if npc then
        prompt = npc:FindFirstChild("ObservationHakiPrompt")
    end
    
    if not prompt then
        oldPrint("[OBS HAKI] ❌ ObservationHakiPrompt not found!")
        return false
    end
    
    oldPrint("[OBS HAKI] 💰 Firing ObservationHakiPrompt...")
    prompt.MaxActivationDistance = math.huge
    fireproximityprompt(prompt)
    task.wait(2)
    
    -- 4. Wait for ConfirmUI and click Yes
    oldPrint("[OBS HAKI] ⏳ Waiting for ConfirmUI...")
    task.wait(1)
    
    local confirmUI = player.PlayerGui:FindFirstChild("ConfirmUI")
    if confirmUI and confirmUI.Enabled then
        oldPrint("[OBS HAKI] ✅ ConfirmUI found, clicking Yes...")
        local yesButton = confirmUI:FindFirstChild("MainFrame")
        if yesButton then yesButton = yesButton:FindFirstChild("ButtonsHolder") end
        if yesButton then yesButton = yesButton:FindFirstChild("Yes") end
        
        if yesButton then
            pcall(function()
                for _, connection in pairs(getconnections(yesButton.MouseButton1Click)) do
                    connection:Fire()
                end
            end)
            oldPrint("[OBS HAKI] ✅ Clicked Yes button")
        end
    else
        oldPrint("[OBS HAKI] ❌ No ConfirmUI found")
    end
    
    task.wait(3)
    
    -- 5. Check if purchase is successful
    oldPrint("[OBS HAKI] ✅ Observation Haki purchase attempted!")
    return true
end

-- [11] BOSS KEY AUTO BUY SYSTEM (Real-time Stock Update)
local lastBossKeyBuyTime = 0
local isBuyingBossKey = false

local function buyBossKeysFromStock(bossKeyStock)
    if isBuyingBossKey then
        oldPrint("[BOSS KEY] ⏰ Already buying, skipping...")
        return false
    end
    
    local currentTime = tick()
    
    -- Prevent buying too fast (wait 5 seconds from last purchase)
    if currentTime - lastBossKeyBuyTime < 5 then
        return false
    end
    
    isBuyingBossKey = true
    oldPrint("[BOSS KEY] ========== AUTO BUY BOSS KEY START ==========")
    oldPrint(string.format("[BOSS KEY] 🔑 Boss Key in stock: %d", bossKeyStock))
    
    -- Teleport to MerchantNPC
    local merchantCF = CFrame.new(368.817719, 2.79983521, 783.589844, -0.0566431284, 0, 0.998394549, 0, 1, 0, -0.998394549, 0, -0.0566431284)
    oldPrint("[BOSS KEY] 📍 Teleporting to MerchantNPC...")
    tweenPos(merchantCF)
    task.wait(3)
    
    -- Buy all
    oldPrint(string.format("[BOSS KEY] 💰 Buying %d Boss Keys...", bossKeyStock))
    for i = 1, bossKeyStock do
        pcall(function()
            RS.Remotes.MerchantRemotes.PurchaseMerchantItem:InvokeServer("Boss Key", 1)
        end)
        task.wait(0.5)
    end
    
    lastBossKeyBuyTime = currentTime
    isBuyingBossKey = false
    oldPrint("[BOSS KEY] ✅ Boss Key purchase complete!")
    oldPrint("[BOSS KEY] ========== AUTO BUY BOSS KEY END ==========")
    return true
end

-- Listen to MerchantStockUpdate event in real-time
local function setupBossKeyAutoListener()
    oldPrint("[BOSS KEY] 🎧 Setting up real-time stock listener...")
    
    -- Check stock initially at startup
    task.spawn(function()
        task.wait(2)
        oldPrint("[BOSS KEY] 📦 Checking initial stock...")
        local success, stock = pcall(function()
            return RS.Remotes.MerchantRemotes.GetMerchantStock:InvokeServer()
        end)
        
        if success then
            oldPrint(string.format("[BOSS KEY] 📋 Stock type: %s", type(stock)))
            
            if type(stock) == "table" then
                -- Information about items is in stock.stock
                local items = stock.stock or stock
                oldPrint(string.format("[BOSS KEY] 📦 Items type: %s", type(items)))
                
                if type(items) == "table" then
                    -- Count number of items
                    local itemCount = 0
                    for _ in pairs(items) do itemCount = itemCount + 1 end
                    oldPrint(string.format("[BOSS KEY] 📊 Total items: %d", itemCount))
                    
                    -- Show information about all items
                    local foundBossKey = false
                    for key, item in pairs(items) do
                        if type(item) == "table" then
                            -- Show all fields of item
                            oldPrint(string.format("[BOSS KEY] 🔍 Item[%s] fields:", tostring(key)))
                            for k, v in pairs(item) do
                                oldPrint(string.format("[BOSS KEY]   - %s = %s (%s)", tostring(k), tostring(v), type(v)))
                            end
                            
                            local itemName = item.name or item.itemId or item.Name or item.ItemId or item.itemName or tostring(key)
                            local itemStock = item.stock or item.quantity or item.Stock or item.Quantity or 0
                            
                            if itemName == "Boss Key" or (type(itemName) == "string" and string.find(itemName, "Boss Key")) then
                                foundBossKey = true
                                oldPrint(string.format("[BOSS KEY] 🔑 Boss Key found! Stock: %d", itemStock))
                                if itemStock > 0 then
                                    buyBossKeysFromStock(itemStock)
                                end
                                break
                            end
                        end
                    end
                    
                    if not foundBossKey then
                        oldPrint("[BOSS KEY] ❌ Boss Key not found in stock")
                    end
                else
                    oldPrint("[BOSS KEY] ⚠️ Items is not a table")
                end
            else
                oldPrint("[BOSS KEY] ⚠️ Stock is not a table")
            end
        else
            oldPrint("[BOSS KEY] ❌ Failed to get initial stock")
        end
    end)
    
    -- Listen to event for stock update
    pcall(function()
        RS.Remotes.MerchantRemotes.MerchantStockUpdate.OnClientEvent:Connect(function(...)
            if not _G.Config.AutoBuyBossKey then return end
            
            local args = {...}
            oldPrint("[BOSS KEY] 🔔 Stock update event received!")
            oldPrint(string.format("[BOSS KEY] 📊 Event args count: %d", #args))
            
            -- Try to find information from all arguments
            for i, arg in ipairs(args) do
                if type(arg) == "table" then
                    oldPrint(string.format("[BOSS KEY] 📦 Arg[%d] is table", i))
                    for _, item in pairs(arg) do
                        if type(item) == "table" and (item.name == "Boss Key" or item.itemId == "Boss Key") then
                            local stock = item.stock or item.quantity or 0
                            oldPrint(string.format("[BOSS KEY] � Boss Key found! Stock: %d", stock))
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
    
    oldPrint("[BOSS KEY] ✅ Real-time stock listener ready!")
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
    oldPrint("[ICHIGO] ========== EXCHANGE ICHIGO START ==========")
    
    -- 1. Check if already have Ichigo
    if checkDarkBlade("Ichigo") then
        oldPrint("[ICHIGO] ⏭️ Already have Ichigo, skipping...")
        return true
    end
    
    -- 2. Check if have Boss Ticket 500
    local hasAll, missing = checkIchigoRequirements()
    
    if not hasAll then
        oldPrint("[ICHIGO] ❌ Missing requirements:")
        for _, item in pairs(missing) do
            oldPrint("[ICHIGO]   - " .. item)
        end
        oldPrint("[ICHIGO] 🎯 Farm Saber Boss to get Boss Tickets!")
        return false
    end
    
    oldPrint("[ICHIGO] ✅ All requirements met (Boss Ticket: 500)! Exchanging...")
    
    -- 3. Call ExchangeItem remote directly
    oldPrint("[ICHIGO] 💰 Calling ExchangeItem remote...")
    local success = pcall(function()
        RS.Remotes.ExchangeItem:InvokeServer("Ichigo")
    end)
    
    if not success then
        oldPrint("[ICHIGO] ❌ Failed to call ExchangeItem remote")
        return false
    end
    
    task.wait(3)
    
    -- 4. Check if got Ichigo
    if checkDarkBlade("Ichigo") then
        oldPrint("[ICHIGO] ✅ Ichigo exchange successful!")
        return true
    else
        oldPrint("[ICHIGO] ⚠️ Ichigo not found in inventory after exchange")
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
    
    oldPrint(string.format("[SABER BOSS] 🔑 Boss Key: %d", count))
    return count
end

local function farmSaberBoss()
    oldPrint("[SABER BOSS] ========== FARM SABER BOSS START ==========")
    isFarmingIchigoBoss = true
    
    -- Loop until Boss Key is depleted
    while isFarmingIchigoBoss do
        -- Check Boss Key
        local bossKeyCount = checkBossKeyCount()
        oldPrint(string.format("[SABER BOSS] 🎫 Boss Key: %d", bossKeyCount))
        
        if bossKeyCount < 1 then
            oldPrint("[SABER BOSS] ❌ Not enough Boss Keys! Need 1 to summon.")
            break
        end
        
        -- 1. Teleport to SummonBossNPC
        local summonNPCCFrame = CFrame.new(651.810181, -3.67419362, -1021.13123, 0.999550879, 0, 0.0299676117, 0, 1, 0, -0.0299676117, 0, 0.999550879)
        oldPrint("[SABER BOSS] 📍 Teleporting to SummonBossNPC...")
        tweenPos(summonNPCCFrame)
        task.wait(3)
    
    -- 2. Call SaberBoss
    oldPrint("[SABER BOSS] 🔔 Summoning SaberBoss...")
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
    oldPrint("[SABER BOSS] 🔍 Finding SaberBoss...")
    local boss = workspace:FindFirstChild("NPCs")
    if boss then boss = boss:FindFirstChild("SaberBoss") end
    
    if not boss then
        oldPrint("[SABER BOSS] ❌ SaberBoss not found! Waiting...")
        task.wait(10)
        boss = workspace:FindFirstChild("NPCs")
        if boss then boss = boss:FindFirstChild("SaberBoss") end
    end
    
    if boss and boss:FindFirstChild("HumanoidRootPart") and boss:FindFirstChild("Humanoid") then
        oldPrint("[SABER BOSS] ✅ SaberBoss found! Starting combat...")
        
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            oldPrint("[SABER BOSS] ❌ Character not found!")
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
            oldPrint("[SABER BOSS] ⚠️ Player died! Waiting for respawn...")
            task.wait(5)
            
            -- Check if SaberBoss is still alive (may have died during respawn)
            if boss and boss.Parent and boss:FindFirstChild("HumanoidRootPart") and bossHumanoid.Health > 0 then
                -- Find new character
                local newChar = player.Character or player.CharacterAdded:Wait()
                if newChar and newChar:FindFirstChild("HumanoidRootPart") then
                    oldPrint("[SABER BOSS] 🔄 Respawned! Returning to boss...")
                    
                    -- Teleport back to SaberBoss
                    local bossPos = boss.HumanoidRootPart.Position
                    tweenPos(CFrame.new(bossPos + Vector3.new(0, 15, 0)))
                    task.wait(3)
                end
            else
                oldPrint("[SABER BOSS] ⚠️ Boss died while waiting for respawn!")
            end
        else
            -- SaberBoss is really dead
            oldPrint("[SABER BOSS] ✅ SaberBoss defeated!")
            
            -- Check drops
            oldPrint("[SABER BOSS] 📦 Checking drops...")
            task.wait(2)
            
            oldPrint("[SABER BOSS] 🔄 Checking Boss Keys for next round...")
        end
    else
        oldPrint("[SABER BOSS] ❌ SaberBoss not spawned or already dead!")
        task.wait(5)
    end
    
    end -- end while loop
    
    isFarmingIchigoBoss = false
    oldPrint("[SABER BOSS] ========== FARM SABER BOSS END ==========")
end

-- [13] FRUIT FARM SYSTEM
local function startFruitFarm()
    oldPrint("[FRUIT] ========== FRUIT FARM START ==========")
    isFruitFarming = true
    
    local targetFruit = _G.Config.TargetFruit
    
    -- 1. Check if already have fruit
    oldPrint("[FRUIT] STEP 1: checkHasFruit...")
    local hasFruitAlready = checkHasFruit(targetFruit)
    oldPrint("[FRUIT] STEP 1 result:", tostring(hasFruitAlready))
    
    if hasFruitAlready then
        oldPrint("[FRUIT] ✅ Already have", targetFruit)
        
        -- Eat fruit before farming (every time!)
        local fruitTool = getAnyFruitFromBackpack()
        if fruitTool then
            oldPrint("[FRUIT] 🍽️ Eating target fruit before farming:", fruitTool.Name)
            eatFruit(fruitTool)
            task.wait(2)
        else
            oldPrint("[FRUIT] ⚠️ No fruit tool found in Backpack/Character!")
        end
        
        equipFruit(targetFruit)
        
        -- Go to farm (no reset!)
        oldPrint("[FRUIT] STEP 6: Teleporting to farm position...")
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
        
        oldPrint("[FRUIT] ✅ Fruit farm setup complete!")
        task.spawn(fruitFarmLoop)
        return true
    end
    
    -- 2. Check if reset (check from Power stat)
    local currentPower = 0
    pcall(function()
        currentPower = player.Data.Power.Value or 0
    end)
    
    if currentPower < 11500 then
        oldPrint("[FRUIT] STEP 2: Reset Stats (Power < 11500)...")
        pcall(function()
            RemoteEvents:WaitForChild("ResetStats"):FireServer()
        end)
        task.wait(3)
        oldPrint("[FRUIT] STEP 2: Reset Stats done")
        
        -- 3. Allocate Stats: Power 11500 → Sword
        oldPrint("[FRUIT] STEP 3: Allocate Stats...")
        local ok3, err3 = pcall(allocateStatsPowerFirst)
        if not ok3 then
            oldPrint("[FRUIT] STEP 3 ERROR:", tostring(err3))
        else
            oldPrint("[FRUIT] STEP 3: Stats allocated OK")
        end
        task.wait(2)
    else
        oldPrint("[FRUIT] ⏭️ STEP 2-3: Power already >= 11500, skipping reset...")
    end
    
    -- 4. Buy random fruit until get target fruit
    oldPrint("[FRUIT] STEP 4: Starting buy loop...")
    local maxAttempts = 100
    local attemptNum = 0
    local gotTarget = false
    
    while maxAttempts > 0 and not gotTarget do
        maxAttempts = maxAttempts - 1
        attemptNum = attemptNum + 1
        oldPrint("[FRUIT] ══════════════════════════════════")
        oldPrint("[FRUIT] 🎲 Attempt " .. attemptNum .. " / 100")
        
        -- 4a. Buy random fruit
        local ok4, err4 = pcall(buyRandomFruit)
        if not ok4 then
            oldPrint("[FRUIT] ❌ buyRandomFruit ERROR:", tostring(err4))
            task.wait(2)
        else
            -- 4b. Wait for fruit to load into Backpack (add wait time)
            oldPrint("[FRUIT] ⏳ Waiting for fruit to load into Backpack...")
            task.wait(3)
            local fruitTool = getAnyFruitFromBackpack()
            
            if fruitTool then
                oldPrint("[FRUIT] 🍎 Got: " .. fruitTool.Name)
                
                -- Check if fruit name contains targetFruit (e.g. "Quake Fruit" contains "Quake")
                local isTargetFruit = fruitTool.Name:find(targetFruit) ~= nil
                
                if isTargetFruit then
                    -- Got target fruit! → eat fruit before farming
                    oldPrint("[FRUIT] 🎉🎉🎉 GOT TARGET FRUIT: " .. fruitTool.Name .. " !!! 🎉🎉🎉")
                    oldPrint("[FRUIT] 🍽️ Eating target fruit...")
                    eatFruit(fruitTool)
                    task.wait(2)
                    gotTarget = true
                else
                    -- Not target fruit → eat and discard
                    oldPrint("[FRUIT] ❌ Not " .. targetFruit .. " → Eating " .. fruitTool.Name .. "...")
                    eatFruit(fruitTool)
                    task.wait(2)
                end
            else
                oldPrint("[FRUIT] ⚠️ No fruit found in Backpack after buying!")
                task.wait(2)
            end
        end
    end
    
    -- 5. Equip target fruit
    oldPrint("[FRUIT] STEP 5: Check final result...")
    if checkHasFruit(targetFruit) then
        oldPrint("[FRUIT] ✅ Got " .. targetFruit .. "! Equipping...")
        equipFruit(targetFruit)
        
        -- 6. Teleport to farm position
        oldPrint("[FRUIT] STEP 6: Teleporting to farm position...")
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
        
        oldPrint("[FRUIT] ✅ Fruit farm setup complete!")
        task.spawn(fruitFarmLoop)
        return true
    else
        oldPrint("[FRUIT] ❌ Failed to get " .. targetFruit)
        isFruitFarming = false
        return false
    end
end

-- [11] HAKI QUEST SYSTEM
local function acceptHakiQuest()
    print("[HAKI QUEST] Accepting quest...")
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
        print("[HAKI QUEST] Press E attempt", i)
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
            print("[HAKI QUEST] 🎉 Haki obtained via E key!")
            return true
        end
    end

    print("[HAKI QUEST] ❌ Failed to get Haki after E key attempts")

    return false
end

local function farmThiefForHaki()
    print("[HAKI QUEST] Starting Haki farm...")
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
            print("[HAKI QUEST] ⚠️ Timeout!")
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
            print("[HAKI QUEST] 🔄 Going to NPC...")
            lastCheckKills = killCount

            if goToHakiNPC() then
                print("[HAKI QUEST] 🎉🎉 HAKI OBTAINED!")

                if _G.Config.BuyDarkBlade then
                    print("[HAKI QUEST] 🛒 Buying Dark Blade...")
                    isHakiQuestActive = false
                    pcall(buyDarkBlade)
                end

                print("[HAKI QUEST] ✅ Complete!")
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
    print("[HAKI QUEST] Starting...")
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
        print("[FARM] Equipping:", tool.Name)
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
                        print("[FARM] NPC:", npcType, "| Weapon:", toolName)
                        tweenPos(CFrame.new(questInfo.position))
                        task.wait(3)
                    end
                    task.wait(1)
                    firstMob = false
                    continue
                end
                firstMob = false

                print("[FARM] Found:", closest.Name)

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
                print("[FARM] Killed:", closest.Name, "→ Finding next mob...")
                task.wait(0.3) -- Wait a bit and find next NPC
            end

            print("[FARM] Exit Farm Loop")
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
        print("[SYSTEM] 🔍 Level check:", level)

        -- ===== PRIORITY -1: Check if account completion (Level 11500 + both Haki) =====
        if level >= 11500 then
            print("[SYSTEM] 🎯 Level >= 11500 → Checking account completion...")
            
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
                print("[SYSTEM] ✅ Level 11500+ with both Haki types!")
                print("[SYSTEM] 🔄 Calling Horst_AccountChangeDone...")
                
                if _G.Horst_AccountChangeDone then
                    local ok, err = _G.Horst_AccountChangeDone()
                    if ok then
                        print("[SYSTEM] ✅ Account change done sent successfully!")
                        print("[SYSTEM] 🔄 Waiting for account switch...")
                        task.wait(999999) -- Wait for account switch
                    else
                        print("[SYSTEM] ❌ Failed to send DONE:", err)
                    end
                else
                    print("[SYSTEM] ⚠️ _G.Horst_AccountChangeDone not found!")
                end
            else
                print(string.format("[SYSTEM] ⏳ Haki status: Armament=%s, Observation=%s", 
                    tostring(hasArmamentHaki), tostring(hasObservationHaki)))
            end
        end

        -- ===== Level < HakiMinLevel → normal farm =====
        if level < _G.Config.HakiMinLevel then
            print("[SYSTEM] 📈 Level " .. level .. " - Normal Farm (Melee)")
            task.wait(60) -- Check every 60 seconds
            continue
        end

        -- ===== PRIORITY 0: Check Artifacts at Level 4000 =====
        if level >= 4000 then
            print("[SYSTEM] 💎 Level >= 4000 → Checking Artifacts...")
            if not checkArtifactsUnlocked() then
                print("[SYSTEM] 🔓 Unlocking Artifacts...")
                local unlocked = unlockArtifacts()
                if unlocked then
                    print("[SYSTEM] ✅ Artifacts unlocked! Equipping...")
                    equipArtifacts()
                end
            else
                print("[SYSTEM] ✅ Artifacts already unlocked")
            end
        end

        -- ===== PRIORITY 0.5: Check Observation Haki at Level 6000 =====
        if level >= 6000 then
            print("[SYSTEM] 👁️ Level >= 6000 → Checking Observation Haki...")
            if not checkHasObservationHaki() then
                print("[SYSTEM] 🔓 Buying Observation Haki...")
                buyObservationHaki()
            else
                print("[SYSTEM] ✅ Observation Haki already owned")
            end
        end

        -- ===== PRIORITY 0.6: Check Saber Boss Farm (independent from Ichigo) =====
        if _G.Config.FarmSaberBoss then
            -- Check if at least 1 Boss Key exists
            local bossKeyCount = checkBossKeyCount()
            if bossKeyCount >= 1 then
                print("[SYSTEM] 🎯 Starting Saber Boss farm...")
                farmSaberBoss()
                task.wait(5)
            else
                print("[SYSTEM] ⚠️ Not enough Boss Keys for Saber Boss (need 1)")
            end
        end

        -- ===== PRIORITY 0.7: Check Ichigo Exchange =====
        if _G.Config.ExchangeIchigo and level >= _G.Config.IchigoMinLevel then
            print("[SYSTEM] ⚔️ Checking Ichigo Exchange...")
            if not checkDarkBlade("Ichigo") then
                local hasAll, missing = checkIchigoRequirements()
                
                if hasAll then
                    print("[SYSTEM] ✅ All Ichigo requirements met! Exchanging...")
                    exchangeIchigo()
                else
                    print("[SYSTEM] ❌ Missing Ichigo requirements:")
                    for _, item in pairs(missing) do
                        print("[SYSTEM]   - " .. item)
                    end
                end
            else
                print("[SYSTEM] ✅ Ichigo already owned")
            end
        end

        -- ===== PRIORITY 1: Check Dark Blade before everything =====
        print("[SYSTEM] 🗡️ Checking Dark Blade...")
        local hasBlade = findDarkBladeInHand() ~= nil
        if not hasBlade then
            hasBlade = equipDarkBladeFromInventory()
        end

        if hasBlade then
            print("[SYSTEM] ✅ Dark Blade found!")
            
            -- If Dark Blade exists + Level >= FruitMinLevel → check Fruit Farm
            if _G.Config.FruitFarm and level >= _G.Config.FruitMinLevel then
                print("[SYSTEM] 🍎 Level " .. level .. " >= " .. _G.Config.FruitMinLevel .. " → Checking Fruit Farm...")
                
                local hasFruit = checkHasFruit(_G.Config.TargetFruit)
                if hasFruit then
                    print("[SYSTEM] ✅ Already have " .. _G.Config.TargetFruit .. " → Fruit Farm Mode!")
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
                    print("[SYSTEM] ❌ No " .. _G.Config.TargetFruit .. " → Starting Fruit Farm process...")
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
                print("[SYSTEM] ✅ Dark Blade found! Normal Farm...")
                break
            end
        end

        -- STEP 2: No Dark Blade → check Haki
        print("[SYSTEM] ❌ No Dark Blade | Checking Haki...")
        local hasHaki = checkHakiStatus()

        if hasHaki then
            -- STEP 3: Has Haki but no Dark Blade → buy Dark Blade
            print("[SYSTEM] ✅ Has Haki but no Dark Blade → Buying...")
            if _G.Config.BuyDarkBlade then
                pcall(buyDarkBlade)
            end
            print("[SYSTEM] 🗡️ Dark Blade process done! Normal Farm...")
            break
        end

        -- STEP 4: No Haki + No Dark Blade → start Haki Quest
        if _G.Config.HakiQuest and not isHakiQuestActive then
            print("[SYSTEM] 🔥 No Haki + No Dark Blade → Starting Haki Quest...")
            isHakiQuestActive = true
            pcall(startHakiQuest)
            -- After Haki Quest (Dark Blade bought in farmThiefForHaki)
            isHakiQuestActive = false
            print("[SYSTEM] ✅ Haki Quest done! Normal Farm...")
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

end -- runSailorMainScript

-- Only this sets _dieverKeyOk; only call from verified API responses below
local function authorizeAndStartMain()
	if _dieverMainLaunched then
		return
	end
	_dieverKeyOk = true
	_dieverMainLaunched = true
	task.spawn(runSailorMainScript)
end

-- ═══════════════════════════════════════════════════════════════
-- KEY SYSTEM (Diever Hub) — runs after theme; main script only if key OK
-- ═══════════════════════════════════════════════════════════════

local KEY_CONFIG = {
    API_BASE_URL = "https://shoproblox29.cfd/api",
    ADMIN_PASSWORD = "hentaixyz",
    SCRIPT_NAME = "Diever Hub",
    SCRIPT_VERSION = "v2.0",
    KEY_PREFIX = "DVH",
    JOIN_SERVER_URL = "https://discord.gg/BYD77Pr9wP",
}

local KeyPlayers = game:GetService("Players")
local KeyHttpService = game:GetService("HttpService")
local KeyRbxAnalyticsService = game:GetService("RbxAnalyticsService")
local KeyTweenService = game:GetService("TweenService")
local KeyCoreGui = game:GetService("CoreGui")

local keyPlayer = KeyPlayers.LocalPlayer

local function keyGetHWID()
    local hwid = ""
    pcall(function()
        hwid = KeyRbxAnalyticsService:GetClientId()
    end)
    if hwid == "" or hwid == nil then
        hwid = tostring(keyPlayer.UserId) .. "_" .. tostring(game.PlaceId)
    end
    local today = os.date("%Y-%m-%d")
    hwid = hwid .. "_" .. today
    return hwid
end

local KEY_HWID = keyGetHWID()

local function keyHttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local ok, data = pcall(function()
            return KeyHttpService:JSONDecode(result)
        end)
        if ok then return data end
    end
    return nil
end

local function keyCheckKey(key)
    local url = KEY_CONFIG.API_BASE_URL .. "/check_key.php?key=" .. KeyHttpService:UrlEncode(key) .. "&hwid=" .. KeyHttpService:UrlEncode(KEY_HWID)
    return keyHttpGet(url)
end

local function keyCheckHWID()
    local url = KEY_CONFIG.API_BASE_URL .. "/check_hwid.php?hwid=" .. KeyHttpService:UrlEncode(KEY_HWID)
    return keyHttpGet(url)
end

local function keyCreateKeyAndLink()
    local url = KEY_CONFIG.API_BASE_URL .. "/create_key.php?password=" .. KeyHttpService:UrlEncode(KEY_CONFIG.ADMIN_PASSWORD or "")
    return keyHttpGet(url)
end

local function keyKickPlayer(reason)
    keyPlayer:Kick("\n\nDiever Hub\n\n" .. reason .. "\n\nVui lòng lấy key mới và thử lại.")
end

local function keyShowNotification(title, text, duration)
    duration = duration or 5
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

local function keyCopyText(text)
    if not text or text == "" then return false end
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            copied = true
        elseif toclipboard then
            toclipboard(text)
            copied = true
        end
    end)
    return copied
end

local function keyTryOpenLink(url)
    local opened = false
    pcall(function()
        if openurl then
            openurl(url)
            opened = true
        elseif OpenBrowser then
            OpenBrowser(url)
            opened = true
        elseif identifyexecutor and string.find(string.lower(identifyexecutor()), "fluxus") and open_url then
            open_url(url)
            opened = true
        end
    end)
    return opened
end

local function createKeyUI()
    pcall(function()
        if KeyCoreGui:FindFirstChild("KeySystemUI") then
            KeyCoreGui.KeySystemUI:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 1000

    pcall(function()
        ScreenGui.Parent = KeyCoreGui
    end)
    if not ScreenGui.Parent then
        pcall(function()
            if type(gethui) == "function" then
                ScreenGui.Parent = gethui()
            end
        end)
    end
    if not ScreenGui.Parent then
        ScreenGui.Parent = keyPlayer:WaitForChild("PlayerGui")
    end

    local colors = {
        card = Color3.fromRGB(185, 190, 198),
        card2 = Color3.fromRGB(210, 214, 220),
        cardBorder = Color3.fromRGB(235, 238, 242),
        primary = Color3.fromRGB(215, 219, 224),
        primary2 = Color3.fromRGB(165, 172, 181),
        accent = Color3.fromRGB(245, 247, 250),
        text = Color3.fromRGB(255, 255, 255),
        textDark = Color3.fromRGB(38, 42, 48),
        textSec = Color3.fromRGB(225, 228, 232),
        textMuted = Color3.fromRGB(205, 210, 216),
        success = Color3.fromRGB(220, 226, 233),
        error = Color3.fromRGB(235, 235, 235),
        inputBg = Color3.fromRGB(205, 210, 217),
        inputBorder = Color3.fromRGB(240, 242, 245),
        buttonBg = Color3.fromRGB(210, 214, 220),
        hover = Color3.fromRGB(235, 238, 242),
        darkLine = Color3.fromRGB(150, 156, 165),
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 245)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = colors.card
    MainFrame.BackgroundTransparency = 0.28
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = colors.cardBorder
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.18
    MainStroke.Parent = MainFrame

    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.card2),
        ColorSequenceKeypoint.new(1, colors.primary2)
    })
    MainGradient.Rotation = 90
    MainGradient.Parent = MainFrame

    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 0)
    TopLine.BorderSizePixel = 0
    TopLine.BackgroundColor3 = colors.accent
    TopLine.BackgroundTransparency = 0.1
    TopLine.Parent = MainFrame

    local TopLineCorner = Instance.new("UICorner")
    TopLineCorner.CornerRadius = UDim.new(0, 14)
    TopLineCorner.Parent = TopLine

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 34)
    TitleBar.Position = UDim2.new(0, 0, 0, 5)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = " " .. KEY_CONFIG.SCRIPT_NAME
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = colors.text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.Position = UDim2.new(1, -52, 0.5, 0)
    MinBtn.AnchorPoint = Vector2.new(0, 0.5)
    MinBtn.BackgroundColor3 = colors.buttonBg
    MinBtn.BackgroundTransparency = 0.25
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "—"
    MinBtn.TextSize = 14
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = colors.text
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TitleBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Color = colors.cardBorder
    MinStroke.Thickness = 1
    MinStroke.Transparency = 0.25
    MinStroke.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -24, 0.5, 0)
    CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
    CloseBtn.BackgroundColor3 = colors.buttonBg
    CloseBtn.BackgroundTransparency = 0.25
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextSize = 15
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = colors.text
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = colors.cardBorder
    CloseStroke.Thickness = 1
    CloseStroke.Transparency = 0.25
    CloseStroke.Parent = CloseBtn

    local function hoverBtn(btn)
        btn.MouseEnter:Connect(function()
            KeyTweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.08 }):Play()
        end)
        btn.MouseLeave:Connect(function()
            KeyTweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.25 }):Play()
        end)
    end

    hoverBtn(MinBtn)
    hoverBtn(CloseBtn)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -28, 1, -48)
    Content.Position = UDim2.new(0, 14, 0, 42)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, 0, 0, 40)
    InputFrame.Position = UDim2.new(0, 0, 0, 0)
    InputFrame.BackgroundColor3 = colors.inputBg
    InputFrame.BackgroundTransparency = 0.35
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Content

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 9)
    InputCorner.Parent = InputFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = colors.inputBorder
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.2
    InputStroke.Parent = InputFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(1, -16, 1, 0)
    KeyInput.Position = UDim2.new(0, 8, 0, 0)
    KeyInput.BackgroundTransparency = 1
    KeyInput.Text = ""
    KeyInput.PlaceholderText = "DVH-XXXX-XXXX-XXXX-XXXX"
    KeyInput.PlaceholderColor3 = colors.textMuted
    KeyInput.TextSize = 13
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextColor3 = colors.text
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = InputFrame

    KeyInput.Focused:Connect(function()
        KeyTweenService:Create(InputStroke, TweenInfo.new(0.22), { Color = colors.accent, Transparency = 0 }):Play()
    end)

    KeyInput.FocusLost:Connect(function()
        KeyTweenService:Create(InputStroke, TweenInfo.new(0.22), { Color = colors.inputBorder, Transparency = 0.2 }):Play()
    end)

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Name = "CheckBtn"
    CheckBtn.Size = UDim2.new(1, 0, 0, 38)
    CheckBtn.Position = UDim2.new(0, 0, 0, 48)
    CheckBtn.BackgroundColor3 = colors.primary
    CheckBtn.BackgroundTransparency = 0.08
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "Check Key"
    CheckBtn.TextSize = 13
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextColor3 = colors.textDark
    CheckBtn.AutoButtonColor = false
    CheckBtn.Parent = Content

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 9)
    CheckCorner.Parent = CheckBtn

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = colors.cardBorder
    CheckStroke.Thickness = 1
    CheckStroke.Transparency = 0.15
    CheckStroke.Parent = CheckBtn

    local CheckGrad = Instance.new("UIGradient")
    CheckGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.accent),
        ColorSequenceKeypoint.new(1, colors.primary2)
    })
    CheckGrad.Rotation = 90
    CheckGrad.Parent = CheckBtn

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 38)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 94)
    GetKeyBtn.BackgroundColor3 = colors.buttonBg
    GetKeyBtn.BackgroundTransparency = 0.18
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextSize = 13
    GetKeyBtn.Font = Enum.Font.GothamSemibold
    GetKeyBtn.TextColor3 = colors.textDark
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Parent = Content

    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 9)
    GetKeyCorner.Parent = GetKeyBtn

    local GetKeyStroke = Instance.new("UIStroke")
    GetKeyStroke.Color = colors.cardBorder
    GetKeyStroke.Thickness = 1
    GetKeyStroke.Transparency = 0.18
    GetKeyStroke.Parent = GetKeyBtn

    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Name = "JoinBtn"
    JoinBtn.Size = UDim2.new(1, 0, 0, 38)
    JoinBtn.Position = UDim2.new(0, 0, 0, 140)
    JoinBtn.BackgroundColor3 = colors.buttonBg
    JoinBtn.BackgroundTransparency = 0.18
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "Discord"
    JoinBtn.TextSize = 13
    JoinBtn.Font = Enum.Font.GothamSemibold
    JoinBtn.TextColor3 = colors.textDark
    JoinBtn.AutoButtonColor = false
    JoinBtn.Parent = Content

    local JoinCorner = Instance.new("UICorner")
    JoinCorner.CornerRadius = UDim.new(0, 9)
    JoinCorner.Parent = JoinBtn

    local JoinStroke = Instance.new("UIStroke")
    JoinStroke.Color = colors.cardBorder
    JoinStroke.Thickness = 1
    JoinStroke.Transparency = 0.18
    JoinStroke.Parent = JoinBtn

    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, 0, 0, 24)
    FooterText.Position = UDim2.new(0, 0, 1, -24)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = KEY_CONFIG.SCRIPT_VERSION .. "  •  Theme White"
    FooterText.TextSize = 11
    FooterText.Font = Enum.Font.Gotham
    FooterText.TextColor3 = colors.textSec
    FooterText.Parent = Content

    local function setupHover(btn, stroke)
        btn.MouseEnter:Connect(function()
            KeyTweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.05 }):Play()
            if stroke then
                KeyTweenService:Create(stroke, TweenInfo.new(0.18), { Transparency = 0.02 }):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            KeyTweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = 0.18 }):Play()
            if stroke then
                KeyTweenService:Create(stroke, TweenInfo.new(0.18), { Transparency = 0.18 }):Play()
            end
        end)
    end

    setupHover(CheckBtn, CheckStroke)
    setupHover(GetKeyBtn, GetKeyStroke)
    setupHover(JoinBtn, JoinStroke)

    MainFrame.BackgroundTransparency = 1
    MainStroke.Transparency = 1

    KeyTweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.28
    }):Play()

    KeyTweenService:Create(MainStroke, TweenInfo.new(0.45), {
        Transparency = 0.18
    }):Play()

    local isMinimized = false
    local expandedSize = UDim2.new(0, 320, 0, 245)
    local minimizedSize = UDim2.new(0, 320, 0, 38)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Content.Visible = false
            KeyTweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = minimizedSize
            }):Play()
            MinBtn.Text = "+"
        else
            Content.Visible = true
            KeyTweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = expandedSize
            }):Play()
            MinBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        KeyTweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.26)
        ScreenGui:Destroy()
    end)

    JoinBtn.MouseButton1Click:Connect(function()
        local url = KEY_CONFIG.JOIN_SERVER_URL
        local opened = keyTryOpenLink(url)
        local copied = keyCopyText(url)

        if opened then
            keyShowNotification("Join Server", "Đã mở link server.", 5)
        elseif copied then
            keyShowNotification("Join Server", "Không mở trực tiếp được, đã copy link server.", 6)
        else
            keyShowNotification("Join Server", "Link server: " .. url, 6)
        end
    end)

    local isGettingKey = false
    GetKeyBtn.MouseButton1Click:Connect(function()
        if isGettingKey then return end
        isGettingKey = true

        GetKeyBtn.Text = "⏳  Creating..."
        GetKeyBtn.TextColor3 = colors.textDark

        local data = keyCreateKeyAndLink()

        if not data or not data.success then
            local errMsg = (data and data.message) or "Lỗi!"
            GetKeyBtn.Text = "❌  Failed"
            keyShowNotification("Get Key", errMsg, 6)

            task.wait(2)
            GetKeyBtn.Text = "Get Key"
            isGettingKey = false
            return
        end

        local link = data.link or ""
        local newKey = data.key or ""
        local copiedText = (link ~= "" and link) or newKey

        local copied = keyCopyText(copiedText)

        GetKeyBtn.Text = copied and "✅  Copied" or "✅  Created"
        keyShowNotification(
            "Get Key",
            copied and "Đã code link thành công." or "Đã lấy link getkey.",
            6
        )

        task.wait(2.5)
        GetKeyBtn.Text = "Get Key"
        isGettingKey = false
    end)

    local isProcessing = false

    CheckBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true

        local key = KeyInput.Text:gsub("%s+", "")

        if key == "" then
            keyShowNotification("Check Key", "Vui lòng nhập key.", 4)
            KeyTweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()
            task.wait(0.45)
            KeyTweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = colors.inputBorder
            }):Play()
            isProcessing = false
            return
        end

        CheckBtn.Text = "⏳  Checking..."

        local result = keyCheckKey(key)

        if result and result.success and result.valid then
            CheckBtn.Text = "✅  Valid"
            keyShowNotification("Diever Hub", "Key thành công! Đang tải script...", 5)

            KeyTweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            task.wait(0.45)
            ScreenGui:Destroy()

            authorizeAndStartMain()
        else
            local errorMsg = (result and result.message) or "Key không hợp lệ!"
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false

            CheckBtn.Text = "Check Key"

            local origPos = InputFrame.Position
            for i = 1, 4 do
                KeyTweenService:Create(InputFrame, TweenInfo.new(0.04), {
                    Position = origPos + UDim2.new(0, (i % 2 == 0 and 6 or -6), 0, 0)
                }):Play()
                task.wait(0.04)
            end
            KeyTweenService:Create(InputFrame, TweenInfo.new(0.04), {
                Position = origPos
            }):Play()

            KeyTweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()

            keyShowNotification("Check Key", errorMsg, 5)

            task.wait(0.8)
            KeyTweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = colors.inputBorder
            }):Play()

            if shouldKick or reason == "wrong_device" then
                task.wait(1)
                keyKickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
            else
                task.wait(1.6)
                keyKickPlayer("Key không hợp lệ hoặc đã hết hạn!\n\nIb Admin")
            end
        end

        isProcessing = false
    end)

    return ScreenGui
end

local function keyMain()
    local presetKey = ""
    pcall(function()
        if getgenv and getgenv().Key and getgenv().Key ~= "" then
            presetKey = getgenv().Key
        end
    end)

    if presetKey ~= "" then
        local result = keyCheckKey(presetKey)

        if result and result.success and result.valid then
            keyShowNotification("Diever Hub", "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 5)
            authorizeAndStartMain()
            return
        else
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false
            if shouldKick or reason == "wrong_device" then
                keyKickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
                return
            end
        end
    end

    local hwidResult = keyCheckHWID()

    -- Server must confirm this HWID already has a valid linked key (same as successful check)
    if hwidResult and hwidResult.success == true and hwidResult.has_key == true and hwidResult.valid == true then
        authorizeAndStartMain()
        return
    end

    createKeyUI()
end

keyMain()
