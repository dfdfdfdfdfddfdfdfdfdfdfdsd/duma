-- Tạo UI Console cho Sailor Piece (Roblox)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Hàm tạo UI
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SailorPieceConsole"
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
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
    titleText.Text = "Sailor Piece Console"
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

    -- Hàm cập nhật nội dung console
    local function updateConsole(text)
        consoleText.Text = text
        -- Tự động điều chỉnh height của TextLabel
        consoleText.Size = UDim2.new(1, -20, 0, consoleText.TextBounds.Y + 10)
        consoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleText.Size.Y.Offset)
    end

    -- Hàm quét dữ liệu
    local function scan()
        local output = {}
        table.insert(output, "=== SCAN RESULTS ===")
        table.insert(output, "Time: " .. os.date("%Y-%m-%d %H:%M:%S"))
        table.insert(output, "")

        -- 1. Quét NPC
        table.insert(output, "--- NPCs ---")
        local npcCount = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                -- Bỏ qua các model có tên chứa "Mob", "Enemy", "Boss" hoặc có tag
                local name = obj.Name:lower()
                if not (name:find("mob") or name:find("enemy") or name:find("boss") or name:find("pet")) then
                    local npcInfo = "- " .. obj.Name
                    -- Thử lấy level nếu có
                    local levelPart = obj:FindFirstChild("Level")
                    if levelPart and levelPart:IsA("IntValue") then
                        npcInfo = npcInfo .. " (Level: " .. levelPart.Value .. ")"
                    end
                    table.insert(output, npcInfo)
                    npcCount = npcCount + 1
                end
            end
        end
        if npcCount == 0 then
            table.insert(output, "  No NPCs found.")
        end
        table.insert(output, "")

        -- 2. Quét quái (mobs / enemies)
        table.insert(output, "--- Mobs / Enemies ---")
        local mobCount = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                local name = obj.Name:lower()
                -- Tiêu chí nhận dạng mob: tên chứa mob, enemy, boss, hoặc không có dấu hiệu NPC (có thể tùy chỉnh)
                if name:find("mob") or name:find("enemy") or name:find("boss") then
                    local mobInfo = "- " .. obj.Name
                    local levelPart = obj:FindFirstChild("Level")
                    if levelPart and levelPart:IsA("IntValue") then
                        mobInfo = mobInfo .. " (Level: " .. levelPart.Value .. ")"
                    end
                    table.insert(output, mobInfo)
                    mobCount = mobCount + 1
                end
            end
        end
        if mobCount == 0 then
            table.insert(output, "  No mobs found.")
        end
        table.insert(output, "")

        -- 3. Quét nhiệm vụ (quest) – tìm các phần tử liên quan
        table.insert(output, "--- Quests ---")
        local questCount = 0
        local questKeywords = {"quest", "mission", "task", "bounty"}
        for _, obj in ipairs(workspace:GetDescendants()) do
            local name = obj.Name:lower()
            for _, kw in ipairs(questKeywords) do
                if name:find(kw) then
                    table.insert(output, "- " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    questCount = questCount + 1
                    break
                end
            end
        end
        -- Nếu có ReplicatedStorage, kiểm tra thêm
        if game:GetService("ReplicatedStorage") then
            for _, obj in ipairs(game.ReplicatedStorage:GetDescendants()) do
                local name = obj.Name:lower()
                for _, kw in ipairs(questKeywords) do
                    if name:find(kw) then
                        table.insert(output, "- " .. obj.Name .. " (" .. obj.ClassName .. ") [ReplicatedStorage]")
                        questCount = questCount + 1
                        break
                    end
                end
            end
        end
        if questCount == 0 then
            table.insert(output, "  No quest-related objects found.")
        end
        table.insert(output, "")

        -- 4. Thông tin bổ sung: các folder / model chứa dữ liệu quan trọng
        table.insert(output, "--- Additional Info ---")
        local importantFolders = {"NPCs", "Mobs", "Quests", "Enemies", "Bosses", "Data"}
        for _, folderName in ipairs(importantFolders) do
            local folder = workspace:FindFirstChild(folderName)
            if folder then
                table.insert(output, "- Found folder: " .. folderName)
            end
        end
        table.insert(output, "")

        -- 5. Thống kê tổng hợp
        table.insert(output, "=== SUMMARY ===")
        table.insert(output, "NPCs: " .. npcCount)
        table.insert(output, "Mobs: " .. mobCount)
        table.insert(output, "Quest objects: " .. questCount)
        table.insert(output, "Scan completed.")

        updateConsole(table.concat(output, "\n"))
    end

    -- Hàm copy nội dung
    local function copyToClipboard()
        local text = consoleText.Text
        if text == "" then
            return
        end
        local clipboard = game:GetService("Clipboard")
        clipboard:set(text)
        -- Tạo thông báo nhỏ
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

    runBtn.MouseButton1Click:Connect(scan)
    copyBtn.MouseButton1Click:Connect(copyToClipboard)

    -- Tự động quét lần đầu
    scan()
end

-- Chờ game load và tạo UI
coroutine.wrap(function()
    wait(1)
    createUI()
end)()
