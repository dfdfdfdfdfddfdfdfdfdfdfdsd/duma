--  CONFIGURATION
local CONFIG = {
    API_BASE_URL = "https://shoproblox29.cfd/api",  -- https://yourdomain.com/api
    ADMIN_PASSWORD = "hentaixyz",  -- Same as in api/config.php
    SCRIPT_NAME = "Diever Hub",
    SCRIPT_VERSION = "v1.0",
    KEY_PREFIX = "DVH",
}

--  SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

--  HWID GENERATION
local function getHWID()
    local hwid = ""
    pcall(function()
        hwid = RbxAnalyticsService:GetClientId()
    end)
    if hwid == "" or hwid == nil then
        hwid = game:GetService("Players").LocalPlayer.UserId .. "_" .. tostring(game.PlaceId)
    end
    local today = os.date("%Y-%m-%d")
    hwid = hwid .. "_" .. today
    return hwid
end

local HWID = getHWID()

--  API FUNCTIONS
local function httpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(result)
        end)
        if ok then return data end
    end
    return nil
end

local function checkKey(key)
    local url = CONFIG.API_BASE_URL .. "/check_key.php?key=" .. HttpService:UrlEncode(key) .. "&hwid=" .. HttpService:UrlEncode(HWID)
    return httpGet(url)
end

local function checkHWID()
    local url = CONFIG.API_BASE_URL .. "/check_hwid.php?hwid=" .. HttpService:UrlEncode(HWID)
    return httpGet(url)
end

local function createKeyAndLink()
    local url = CONFIG.API_BASE_URL .. "/create_key.php?password=" .. HttpService:UrlEncode(CONFIG.ADMIN_PASSWORD or "")
    return httpGet(url)
end

--  KICK FUNCTION
local function kickPlayer(reason)
    player:Kick("\n\nKey System\n\n" .. reason .. "\n\nVui lòng lấy key mới và thử lại.")
end

local function showNotification(title, text, duration)
    duration = duration or 5
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration
        })
    end)
end

--  UI CREATION
local function createKeyUI()
    pcall(function()
        if CoreGui:FindFirstChild("KeySystemUI") then
            CoreGui.KeySystemUI:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
    end

    -- Colors
    local colors = {
        card = Color3.fromRGB(15, 15, 35),
        cardBorder = Color3.fromRGB(55, 50, 100),
        primary = Color3.fromRGB(108, 92, 231),
        accent = Color3.fromRGB(0, 206, 201),
        text = Color3.fromRGB(255, 255, 255),
        textSec = Color3.fromRGB(160, 160, 200),
        textMuted = Color3.fromRGB(90, 90, 130),
        success = Color3.fromRGB(0, 184, 148),
        error = Color3.fromRGB(255, 107, 107),
        inputBg = Color3.fromRGB(8, 8, 22),
        inputBorder = Color3.fromRGB(50, 45, 85),
        btnHover = Color3.fromRGB(60, 55, 100),
        closeBg = Color3.fromRGB(255, 70, 70),
    }

    -- ===== MAIN CARD (compact, transparent) =====
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 310, 0, 240)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = colors.card
    MainFrame.BackgroundTransparency = 0.35
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = colors.cardBorder
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame

    -- Top accent line
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 0)
    TopLine.BorderSizePixel = 0
    TopLine.Parent = MainFrame
    local TopLineCorner = Instance.new("UICorner")
    TopLineCorner.CornerRadius = UDim.new(0, 12)
    TopLineCorner.Parent = TopLine
    local TopGrad = Instance.new("UIGradient")
    TopGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(1, colors.accent),
    })
    TopGrad.Parent = TopLine

    -- ===== TITLE BAR =====
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.Position = UDim2.new(0, 0, 0, 4)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = " " .. CONFIG.SCRIPT_NAME
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = colors.text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Minimize button (—)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 24, 0, 24)
    MinBtn.Position = UDim2.new(1, -52, 0.5, 0)
    MinBtn.AnchorPoint = Vector2.new(0, 0.5)
    MinBtn.BackgroundColor3 = colors.cardBorder
    MinBtn.BackgroundTransparency = 0.5
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "—"
    MinBtn.TextSize = 14
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = colors.textSec
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TitleBar
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    -- Close button (×)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -24, 0.5, 0)
    CloseBtn.AnchorPoint = Vector2.new(0, 0.5)
    CloseBtn.BackgroundColor3 = colors.closeBg
    CloseBtn.BackgroundTransparency = 0.5
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = colors.text
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    -- Hover effects for title bar buttons
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)

    -- ===== CONTENT AREA =====
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -28, 1, -44)
    Content.Position = UDim2.new(0, 14, 0, 38)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Key input box
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, 0, 0, 38)
    InputFrame.Position = UDim2.new(0, 0, 0, 0)
    InputFrame.BackgroundColor3 = colors.inputBg
    InputFrame.BackgroundTransparency = 0.2
    InputFrame.BorderSizePixel = 0
    InputFrame.Parent = Content

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputFrame

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = colors.inputBorder
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.3
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
    KeyInput.TextColor3 = colors.accent
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = InputFrame

    -- Focus glow
    KeyInput.Focused:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.25), {Color = colors.primary, Transparency = 0}):Play()
    end)
    KeyInput.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.25), {Color = colors.inputBorder, Transparency = 0.3}):Play()
    end)

    -- Check Key button
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Name = "CheckBtn"
    CheckBtn.Size = UDim2.new(1, 0, 0, 36)
    CheckBtn.Position = UDim2.new(0, 0, 0, 46)
    CheckBtn.BackgroundColor3 = colors.primary
    CheckBtn.BackgroundTransparency = 0.1
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓  Check Key"
    CheckBtn.TextSize = 13
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextColor3 = colors.text
    CheckBtn.AutoButtonColor = false
    CheckBtn.Parent = Content

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 8)
    CheckCorner.Parent = CheckBtn

    local CheckGrad = Instance.new("UIGradient")
    CheckGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(1, colors.accent),
    })
    CheckGrad.Rotation = 90
    CheckGrad.Parent = CheckBtn

    -- Get Key button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 36)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 90)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 45)
    GetKeyBtn.BackgroundTransparency = 0.2
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextSize = 13
    GetKeyBtn.Font = Enum.Font.GothamSemibold
    GetKeyBtn.TextColor3 = colors.accent
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Parent = Content

    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn

    local GetKeyStroke = Instance.new("UIStroke")
    GetKeyStroke.Color = colors.accent
    GetKeyStroke.Thickness = 1
    GetKeyStroke.Transparency = 0.5
    GetKeyStroke.Parent = GetKeyBtn

    -- Status message
    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Name = "StatusMsg"
    StatusMsg.Size = UDim2.new(1, 0, 0, 40)
    StatusMsg.Position = UDim2.new(0, 0, 0, 134)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = ""
    StatusMsg.TextSize = 11
    StatusMsg.Font = Enum.Font.Gotham
    StatusMsg.TextColor3 = colors.textMuted
    StatusMsg.TextWrapped = true
    StatusMsg.Parent = Content

    -- ===== HOVER EFFECTS =====
    CheckBtn.MouseEnter:Connect(function()
        TweenService:Create(CheckBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    CheckBtn.MouseLeave:Connect(function()
        TweenService:Create(CheckBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    GetKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(GetKeyStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
    end)
    GetKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(GetKeyStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
    end)

    -- ===== ENTRANCE ANIMATION =====
    MainFrame.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.35
    }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.5), {Transparency = 0.3}):Play()

    -- ===== MINIMIZE / CLOSE LOGIC =====
    local isMinimized = false
    local expandedSize = UDim2.new(0, 310, 0, 240)
    local minimizedSize = UDim2.new(0, 310, 0, 36)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = minimizedSize
            }):Play()
            Content.Visible = false
            MinBtn.Text = "+"
        else
            Content.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = expandedSize
            }):Play()
            MinBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)

    -- ===== GET KEY BUTTON =====
    local isGettingKey = false
    GetKeyBtn.MouseButton1Click:Connect(function()
        if isGettingKey then return end
        isGettingKey = true
        GetKeyBtn.Text = "⏳  Đang tạo..."
        StatusMsg.Text = ""

        local data = createKeyAndLink()

        if not data or not data.success then
            local errMsg = (data and data.message) or "Lỗi kết nối server!"
            StatusMsg.Text = "❌ " .. errMsg
            StatusMsg.TextColor3 = colors.error
            GetKeyBtn.Text = "🔑  Get Key"
            isGettingKey = false
            return
        end

        local link = data.link or ""
        local newKey = data.key or ""

        -- Auto copy link (or key as fallback)
        local copied = link ~= "" and link or newKey
        pcall(function() setclipboard(copied) end)

        -- Show in status
        if link ~= "" then
            StatusMsg.Text = "🔗 " .. link
        else
            StatusMsg.Text = "🔑 " .. newKey
        end
        StatusMsg.TextColor3 = colors.accent

        -- Button feedback
        GetKeyBtn.Text = "✅  Đã copy!"
        GetKeyBtn.TextColor3 = colors.success
        GetKeyStroke.Color = colors.success

        -- Send notification
        showNotification(
            "🔑 Key System",
            "Link nhận key đã được tự động copy!",
            8
        )

        wait(4)
        GetKeyBtn.Text = "🔑  Get Key"
        GetKeyBtn.TextColor3 = colors.accent
        GetKeyStroke.Color = colors.accent
        isGettingKey = false
    end)

    -- ===== CHECK KEY BUTTON =====
    local isProcessing = false

    CheckBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true

        local key = KeyInput.Text:gsub("%s+", "")

        if key == "" then
            StatusMsg.Text = "❌ Vui lòng nhập key!"
            StatusMsg.TextColor3 = colors.error
            isProcessing = false
            return
        end

        -- Loading state
        CheckBtn.Text = "⏳  Checking..."
        StatusMsg.Text = ""

        local result = checkKey(key)

        if result and result.success and result.valid then
            -- Valid
            StatusMsg.Text = "✅ Key hợp lệ! Loading..."
            StatusMsg.TextColor3 = colors.success
            CheckBtn.Text = "✅  Valid!"

            showNotification("✅ Key System", "Key xác nhận thành công! Đang tải script...", 5)

            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            wait(0.5)
            ScreenGui:Destroy()

            -- LOAD YOUR MAIN SCRIPT HERE
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()

        else
            -- Invalid
            local errorMsg = (result and result.message) or "Key không hợp lệ!"
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false

            StatusMsg.Text = "❌ " .. errorMsg
            StatusMsg.TextColor3 = colors.error
            CheckBtn.Text = "✓  Check Key"

            -- Shake
            local origPos = InputFrame.Position
            for i = 1, 4 do
                TweenService:Create(InputFrame, TweenInfo.new(0.04), {
                    Position = origPos + UDim2.new(0, (i % 2 == 0 and 6 or -6), 0, 0)
                }):Play()
                wait(0.04)
            end
            TweenService:Create(InputFrame, TweenInfo.new(0.04), {Position = origPos}):Play()

            TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = colors.error}):Play()
            wait(1)
            TweenService:Create(InputStroke, TweenInfo.new(0.3), {Color = colors.inputBorder}):Play()

            -- Kick (immediate for wrong device, delayed for other errors)
            if shouldKick or reason == "wrong_device" then
                wait(1)
                kickPlayer("Key đang được sử dụng trên thiết bị khác!\nMỗi key chỉ dùng được trên 1 thiết bị.")
            else
                wait(2)
                kickPlayer("Key không hợp lệ hoặc đã hết hạn!\n\nLỗi: " .. errorMsg)
            end
        end

        isProcessing = false
    end)

    return ScreenGui
end

-- ============================================
--  MAIN LOGIC
-- ============================================
local function main()


    -- Step 1: Check if key is pre-set via getgenv().Key
    local presetKey = ""
    pcall(function()
        if getgenv().Key and getgenv().Key ~= "" then
            presetKey = getgenv().Key
        end
    end)

    if presetKey ~= "" then

        local result = checkKey(presetKey)
        
        if result and result.success and result.valid then

            showNotification("✅ Key System", "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 5)
            -- LOAD YOUR MAIN SCRIPT HERE
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
            return
        else
            -- Kick if wrong device
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false
            if shouldKick or reason == "wrong_device" then
                kickPlayer("Key đang được sử dụng trên thiết bị khác!\nMỗi key chỉ dùng được trên 1 thiết bị.")
                return
            end

        end
    end

    -- Step 2: Check if HWID has a saved key

    local hwidResult = checkHWID()
    
    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then

        -- LOAD YOUR MAIN SCRIPT HERE
        -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        return
    end

    -- Step 3: No valid key found, show UI

    createKeyUI()
end

-- Run
main()
