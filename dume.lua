-- CONFIGURATION
local CONFIG = {
    API_BASE_URL = "https://shoproblox29.cfd/api",
    ADMIN_PASSWORD = "hentaixyz",
    SCRIPT_NAME = "Diever Hub",
    SCRIPT_VERSION = "v1.0",
    JOIN_SERVER_URL = "https://discord.gg/BYD77Pr9wP", -- đổi link server ở đây
}

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- HWID GENERATION (đơn giản, không dùng RbxAnalyticsService)
local function getHWID()
    local hwid = player.UserId .. "_" .. tostring(game.PlaceId)
    local today = os.date("%Y-%m-%d")
    return hwid .. "_" .. today
end

local HWID = getHWID()

-- API FUNCTIONS
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

-- UTIL
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

local function copyText(text)
    if not text or text == "" then return false end
    local copied = false
    pcall(function()
        if setclipboard then setclipboard(text); copied = true
        elseif toclipboard then toclipboard(text); copied = true
        end
    end)
    return copied
end

local function tryOpenLink(url)
    local opened = false
    pcall(function()
        if openurl then openurl(url); opened = true
        elseif OpenBrowser then OpenBrowser(url); opened = true
        elseif identifyexecutor and string.find(string.lower(identifyexecutor()), "fluxus") and open_url then
            open_url(url); opened = true
        end
    end)
    return opened
end

-- UI CREATION
local function createKeyUI()
    -- Xóa UI cũ nếu có
    pcall(function()
        if CoreGui:FindFirstChild("KeySystemUI") then
            CoreGui.KeySystemUI:Destroy()
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui or player:WaitForChild("PlayerGui")

    -- Màu sắc nhẹ nhàng
    local colors = {
        bg = Color3.fromRGB(30, 30, 35),
        card = Color3.fromRGB(45, 45, 55),
        accent = Color3.fromRGB(70, 130, 200),
        text = Color3.fromRGB(255, 255, 255),
        textDim = Color3.fromRGB(180, 180, 190),
        inputBg = Color3.fromRGB(60, 60, 70),
        border = Color3.fromRGB(80, 80, 90),
        buttonBg = Color3.fromRGB(55, 55, 65),
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 340, 0, 260)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = colors.card
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = colors.border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame

    -- Tiêu đề
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = CONFIG.SCRIPT_NAME .. " " .. CONFIG.SCRIPT_VERSION
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = colors.text
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MainFrame

    -- Nút đóng
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = colors.buttonBg
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextSize = 16
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = colors.textDim
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = CloseBtn

    -- Nội dung
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -60)
    Content.Position = UDim2.new(0, 10, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Ô nhập key
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, 0, 0, 40)
    InputBox.Position = UDim2.new(0, 0, 0, 0)
    InputBox.BackgroundColor3 = colors.inputBg
    InputBox.BorderSizePixel = 0
    InputBox.PlaceholderText = "Nhập key tại đây..."
    InputBox.PlaceholderColor3 = colors.textDim
    InputBox.Text = ""
    InputBox.TextColor3 = colors.text
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 14
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Content

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = InputBox

    -- Nút kiểm tra key
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Size = UDim2.new(1, 0, 0, 40)
    CheckBtn.Position = UDim2.new(0, 0, 0, 50)
    CheckBtn.BackgroundColor3 = colors.accent
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓ Kiểm tra key"
    CheckBtn.TextSize = 14
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextColor3 = colors.text
    CheckBtn.Parent = Content

    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = CheckBtn

    -- Nút lấy key
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 100)
    GetKeyBtn.BackgroundColor3 = colors.buttonBg
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "🔑 Lấy key mới"
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Font = Enum.Font.Gotham
    GetKeyBtn.TextColor3 = colors.text
    GetKeyBtn.Parent = Content

    local getCorner = Instance.new("UICorner")
    getCorner.CornerRadius = UDim.new(0, 8)
    getCorner.Parent = GetKeyBtn

    -- Nút join server
    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Size = UDim2.new(1, 0, 0, 40)
    JoinBtn.Position = UDim2.new(0, 0, 0, 150)
    JoinBtn.BackgroundColor3 = colors.buttonBg
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "💬 Tham gia Discord"
    JoinBtn.TextSize = 14
    JoinBtn.Font = Enum.Font.Gotham
    JoinBtn.TextColor3 = colors.text
    JoinBtn.Parent = Content

    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 8)
    joinCorner.Parent = JoinBtn

    -- Hover effect
    local function setHover(btn, color)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3}):Play()
        end)
    end

    setHover(CheckBtn, Color3.fromRGB(90, 150, 220))
    setHover(GetKeyBtn, Color3.fromRGB(70, 70, 85))
    setHover(JoinBtn, Color3.fromRGB(70, 70, 85))

    -- Chức năng nút
    JoinBtn.MouseButton1Click:Connect(function()
        local url = CONFIG.JOIN_SERVER_URL
        if tryOpenLink(url) then
            showNotification("Join Server", "Đã mở link Discord.", 5)
        elseif copyText(url) then
            showNotification("Join Server", "Đã copy link server.", 5)
        else
            showNotification("Join Server", "Link: " .. url, 5)
        end
    end)

    local isGettingKey = false
    GetKeyBtn.MouseButton1Click:Connect(function()
        if isGettingKey then return end
        isGettingKey = true
        GetKeyBtn.Text = "Đang tạo..."
        local data = createKeyAndLink()
        if not data or not data.success then
            GetKeyBtn.Text = "❌ Thất bại"
            showNotification("Lỗi", (data and data.message) or "Không thể kết nối server", 4)
            task.wait(2)
            GetKeyBtn.Text = "🔑 Lấy key mới"
            isGettingKey = false
            return
        end
        local link = data.link or ""
        local newKey = data.key or ""
        copyText(link ~= "" and link or newKey)
        GetKeyBtn.Text = "✅ Đã copy"
        showNotification("Thành công", "Đã tạo key/link và copy vào clipboard.", 5)
        task.wait(2)
        GetKeyBtn.Text = "🔑 Lấy key mới"
        isGettingKey = false
    end)

    local isChecking = false
    CheckBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        local key = InputBox.Text:gsub("%s+", "")
        if key == "" then
            showNotification("Lỗi", "Vui lòng nhập key.", 3)
            return
        end
        isChecking = true
        CheckBtn.Text = "Đang kiểm tra..."
        local result = checkKey(key)
        if result and result.success and result.valid then
            CheckBtn.Text = "✅ Hợp lệ"
            showNotification("Thành công", "Key hợp lệ! Đang tải script...", 4)
            ScreenGui:Destroy()
            -- Gọi main script ở đây
            -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
        else
            local msg = (result and result.message) or "Key không hợp lệ!"
            CheckBtn.Text = "Kiểm tra"
            showNotification("Lỗi", msg, 5)
            if (result and result.kick) or (result and result.reason == "wrong_device") then
                task.wait(1)
                kickPlayer("Key chỉ dùng được trên một thiết bị.")
            end
        end
        isChecking = false
    end)

    -- Animation hiện UI
    MainFrame.BackgroundTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
end

-- MAIN LOGIC
local function main()
    -- Kiểm tra key được set sẵn trong getgenv
    local presetKey = getgenv().Key
    if presetKey and presetKey ~= "" then
        local result = checkKey(presetKey)
        if result and result.success and result.valid then
            showNotification(CONFIG.SCRIPT_NAME, "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 4)
            -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
            return
        else
            if result and (result.kick or result.reason == "wrong_device") then
                kickPlayer("Key chỉ dùng được trên một thiết bị.")
                return
            end
            -- Không có key hợp lệ, tiếp tục hiển thị UI
        end
    end

    -- Kiểm tra HWID đã có key chưa
    local hwidResult = checkHWID()
    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then
        -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
        return
    end

    -- Nếu không có key hợp lệ, hiển thị UI
    createKeyUI()
end

-- Chạy script
main()
