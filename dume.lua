-- Script nâng cao cho Sailor Piece - Quét NPC, quái, nhiệm vụ
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Hàm tạo UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SailorPieceConsole"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 550, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Sailor Piece Console v2"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local consoleFrame = Instance.new("ScrollingFrame")
    consoleFrame.Size = UDim2.new(1, -20, 1, -70)
    consoleFrame.Position = UDim2.new(0, 10, 0, 40)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    consoleFrame.BackgroundTransparency = 0.2
    consoleFrame.BorderSizePixel = 0
    consoleFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    consoleFrame.ScrollBarThickness = 8
    consoleFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    consoleFrame.Parent = mainFrame

    local consoleText = Instance.new("TextLabel")
    consoleText.Size = UDim2.new(1, -20, 0, 0)
    consoleText.BackgroundTransparency = 1
    consoleText.Text = ""
    consoleText.TextColor3 = Color3.fromRGB(200, 200, 200)
    consoleText.TextXAlignment = Enum.TextXAlignment.Left
    consoleText.TextYAlignment = Enum.TextYAlignment.Top
    consoleText.TextWrapped = true
    consoleText.Font = Enum.Font.Code
    consoleText.TextSize = 12
    consoleText.Parent = consoleFrame

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 30)
    buttonFrame.Position = UDim2.new(0, 10, 1, -40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame

    local runBtn = Instance.new("TextButton")
    runBtn.Size = UDim2.new(0, 80, 1, 0)
    runBtn.Position = UDim2.new(0, 0, 0, 0)
    runBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    runBtn.Text = "Run"
    runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    runBtn.Font = Enum.Font.GothamBold
    runBtn.TextSize = 14
    runBtn.BorderSizePixel = 0
    runBtn.Parent = buttonFrame

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 80, 1, 0)
    copyBtn.Position = UDim2.new(0, 90, 0, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 14
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = buttonFrame

    local debugBtn = Instance.new("TextButton")
    debugBtn.Size = UDim2.new(0, 80, 1, 0)
    debugBtn.Position = UDim2.new(0, 180, 0, 0)
    debugBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    debugBtn.Text = "Debug"
    debugBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    debugBtn.Font = Enum.Font.GothamBold
    debugBtn.TextSize = 14
    debugBtn.BorderSizePixel = 0
    debugBtn.Parent = buttonFrame

    -- Hàm cập nhật nội dung console
    local function updateConsole(text)
        consoleText.Text = text
        consoleText.Size = UDim2.new(1, -20, 0, consoleText.TextBounds.Y + 10)
        consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleText.Size.Y.Offset)
    end

    -- Hàm quét dữ liệu nâng cao
    local function scan()
        local output = {}
        local debugInfo = {}

        local function addLine(str, isDebug)
            if isDebug then
                table.insert(debugInfo, str)
            else
                table.insert(output, str)
            end
        end

        addLine("=== SCAN RESULTS (Enhanced) ===")
        addLine("Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
        addLine("")

        -- 1. Thu thập tất cả Model có Humanoid trong workspace
        local allModels = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                table.insert(allModels, obj)
            end
        end
        addLine("[DEBUG] Total models with Humanoid: " .. #allModels, true)

        -- Phân loại dựa trên tên và thuộc tính
        local npcs = {}
        local mobs = {}
        local bosses = {}

        for _, model in ipairs(allModels) do
            local name = model.Name:lower()
            local isBoss = name:find("boss") or name:find("raid") or (model:FindFirstChild("Boss") ~= nil)
            local isMob = name:find("mob") or name:find("enemy") or name:find("pirate") or name:find("marine") or name:find("bandit") or name:find("skeleton")
            local isNPC = not isMob and not isBoss  -- mặc định là NPC nếu không phải mob/boss

            -- Kiểm tra tag từ CollectionService (nếu game dùng)
            local tags = game:GetService("CollectionService"):GetTags(model)
            for _, tag in ipairs(tags) do
                if tag:lower() == "npc" then isNPC = true isMob = false isBoss = false end
                if tag:lower() == "mob" or tag:lower() == "enemy" then isMob = true isNPC = false isBoss = false end
                if tag:lower() == "boss" then isBoss = true isNPC = false isMob = false end
            end

            if isBoss then
                table.insert(bosses, model)
            elseif isMob then
                table.insert(mobs, model)
            elseif isNPC then
                table.insert(npcs, model)
            else
                -- fallback: nếu không phân loại được, xem có Humanoid và không có tấn công? (có thể là NPC)
                table.insert(npcs, model)
            end
        end

        -- 2. Xuất NPC
        addLine("--- NPCs (" .. #npcs .. ") ---")
        for _, npc in ipairs(npcs) do
            local info = "- " .. npc.Name
            local level = npc:FindFirstChild("Level")
            if level and level:IsA("IntValue") then
                info = info .. " (Lv: " .. level.Value .. ")"
            end
            addLine(info)
        end
        if #npcs == 0 then addLine("  No NPCs found.") end
        addLine("")

        -- 3. Xuất Mobs
        addLine("--- Mobs (" .. #mobs .. ") ---")
        for _, mob in ipairs(mobs) do
            local info = "- " .. mob.Name
            local level = mob:FindFirstChild("Level")
            if level and level:IsA("IntValue") then
                info = info .. " (Lv: " .. level.Value .. ")"
            end
            addLine(info)
        end
        if #mobs == 0 then addLine("  No mobs found.") end
        addLine("")

        -- 4. Xuất Boss
        addLine("--- Bosses (" .. #bosses .. ") ---")
        for _, boss in ipairs(bosses) do
            local info = "- " .. boss.Name
            local level = boss:FindFirstChild("Level")
            if level and level:IsA("IntValue") then
                info = info .. " (Lv: " .. level.Value .. ")"
            end
            addLine(info)
        end
        if #bosses == 0 then addLine("  No bosses found.") end
        addLine("")

        -- 5. Quét nhiệm vụ (quest) – tìm trong workspace và các dịch vụ có thể truy cập
        addLine("--- Quests ---")
        local questItems = {}
        local questKeywords = {"quest", "mission", "task", "bounty", "objective"}
        local function scanForQuest(container)
            for _, obj in ipairs(container:GetDescendants()) do
                local name = obj.Name:lower()
                for _, kw in ipairs(questKeywords) do
                    if name:find(kw) then
                        local path = ""
                        if container == workspace then
                            path = "[Workspace] "
                        elseif container == game:GetService("ReplicatedStorage") then
                            path = "[ReplicatedStorage] "
                        elseif container == game:GetService("Players") then
                            path = "[Players] "
                        else
                            path = "[" .. container.Name .. "] "
                        end
                        table.insert(questItems, path .. obj.Name .. " (" .. obj.ClassName .. ")")
                        break
                    end
                end
            end
        end

        scanForQuest(workspace)
        pcall(function() scanForQuest(game:GetService("ReplicatedStorage")) end)
        pcall(function() scanForQuest(game:GetService("ServerScriptService")) end) -- có thể không truy cập được
        pcall(function() scanForQuest(game:GetService("ServerStorage")) end)
        -- Quét cả PlayerGui (nếu quest UI có)
        pcall(function()
            for _, plr in ipairs(game.Players:GetPlayers()) do
                local gui = plr:FindFirstChild("PlayerGui")
                if gui then scanForQuest(gui) end
            end
        end)

        for _, item in ipairs(questItems) do
            addLine(item)
        end
        if #questItems == 0 then addLine("  No quest-related objects found.") end
        addLine("")

        -- 6. Thông tin bổ sung: các folder đặc biệt
        addLine("--- Special Folders ---")
        local specialFolders = {"NPCs", "Mobs", "Quests", "Enemies", "Bosses", "Data", "Map", "Spawn"}
        for _, fname in ipairs(specialFolders) do
            local folder = workspace:FindFirstChild(fname)
            if folder then
                addLine("- Found: " .. fname)
            end
        end
        addLine("")

        -- 7. Thông tin CollectionService tags (nếu có)
        addLine("--- CollectionService Tags (samples) ---")
        local tagsSeen = {}
        for _, model in ipairs(allModels) do
            local tags = game:GetService("CollectionService"):GetTags(model)
            for _, tag in ipairs(tags) do
                if not tagsSeen[tag] then
                    tagsSeen[tag] = true
                    addLine("- Tag: " .. tag .. " (example on " .. model.Name .. ")")
                end
            end
        end
        if next(tagsSeen) == nil then addLine("  No CollectionService tags found.") end
        addLine("")

        -- 8. Tổng kết
        addLine("=== SUMMARY ===")
        addLine("NPCs: " .. #npcs)
        addLine("Mobs: " .. #mobs)
        addLine("Bosses: " .. #bosses)
        addLine("Quest objects: " .. #questItems)
        addLine("Total models with Humanoid: " .. #allModels)
        addLine("Scan completed.")

        -- Gộp debug info (nếu có) vào cuối, hoặc có thể hiển thị riêng
        if #debugInfo > 0 then
            addLine("")
            addLine("=== DEBUG INFO ===")
            for _, line in ipairs(debugInfo) do
                addLine(line)
            end
        end

        updateConsole(table.concat(output, "\n"))
    end

    -- Hàm copy
    local function copyToClipboard()
        local text = consoleText.Text
        if text == "" then return end
        local clipboard = game:GetService("Clipboard")
        clipboard:set(text)
        local notify = Instance.new("TextLabel")
        notify.Size = UDim2.new(0, 120, 0, 30)
        notify.Position = UDim2.new(0.5, -60, 0.5, -15)
        notify.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notify.BackgroundTransparency = 0.5
        notify.Text = "Copied!"
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 14
        notify.BorderSizePixel = 0
        notify.Parent = screenGui
        game:GetService("Debris"):AddItem(notify, 1.5)
    end

    -- Hàm debug: in ra console Roblox (F9) để xem log
    local function debugOutput()
        local text = consoleText.Text
        if text == "" then
            warn("Console is empty. Run scan first.")
        else
            print("=== Sailor Piece Console Output ===")
            print(text)
            print("=== End ===")
        end
    end

    runBtn.MouseButton1Click:Connect(scan)
    copyBtn.MouseButton1Click:Connect(copyToClipboard)
    debugBtn.MouseButton1Click:Connect(debugOutput)

    -- Tự động quét lần đầu
    scan()
end

-- Chờ game load và tạo UI
coroutine.wrap(function()
    wait(2)
    pcall(createUI)
end)()
