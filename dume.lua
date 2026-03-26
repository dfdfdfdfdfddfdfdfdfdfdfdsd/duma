-- CONFIGURATION
local CONFIG = {
    API_BASE_URL = "https://shoproblox29.cfd/api",
    ADMIN_PASSWORD = "hentaixyz",
    SCRIPT_NAME = "Diever Hub",
    SCRIPT_VERSION = "v1.0",
    JOIN_SERVER_URL = "https://discord.gg/BYD77Pr9wP",
}

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local player = Players.LocalPlayer

-- HWID GENERATION (CỐ ĐỊNH)
local function getHWID()
    local hwid = ""
    pcall(function()
        hwid = RbxAnalytics:GetClientId()
    end)
    if hwid == "" then
        hwid = player.UserId .. "_" .. game.PlaceId
    end
    return hwid
end
local HWID = getHWID()

-- API FUNCTIONS
local function httpGet(url)
    local success, result = pcall(game.HttpGet, game, url)
    if success then
        local ok, data = pcall(HttpService.JSONDecode, HttpService, result)
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
    local url = CONFIG.API_BASE_URL .. "/create_key.php?password=" .. HttpService:UrlEncode(CONFIG.ADMIN_PASSWORD)
    return httpGet(url)
end

-- FILE CACHE (lưu trạng thái key hợp lệ)
local function saveKeyCache(key, expiresAt)
    if not writefile then return false end
    local success, err = pcall(function()
        local data = {
            key = key,
            hwid = HWID,
            expires = expiresAt,
            savedAt = os.time()
        }
        writefile("dieverhub.txt", HttpService:JSONEncode(data))
        return true
    end)
    return success
end

local function loadKeyCache()
    if not readfile then return nil end
    local success, result = pcall(function()
        local content = readfile("dieverhub.txt")
        if content and content ~= "" then
            local data = HttpService:JSONDecode(content)
            if data and data.hwid == HWID and data.expires and data.expires > os.time() then
                return data
            end
        end
    end)
    return success and result or nil
end

-- UTILS
local function kickPlayer(reason)
    player:Kick("\n\nKey System\n\n" .. reason .. "\n\nVui lòng lấy key mới và thử lại.")
end

local function showNotification(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
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

-- UI CREATION (Silver Glass)
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
    ScreenGui.Parent = CoreGui or player:WaitForChild("PlayerGui")

    -- Màu sắc trong suốt ánh bạc
    local colors = {
        bg = Color3.fromRGB(255, 255, 255),
        card = Color3.fromRGB(220, 225, 235),
        accent = Color3.fromRGB(200, 210, 225),
        text = Color3.fromRGB(50, 55, 65),
        textDim = Color3.fromRGB(100, 110, 120),
        inputBg = Color3.fromRGB(240, 245, 250),
        border = Color3.fromRGB(210, 220, 230),
        buttonBg = Color3.fromRGB(230, 235, 245),
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 340, 0, 280)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = colors.card
    MainFrame.BackgroundTransparency = 0.25
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.5
    UIStroke.Parent = MainFrame

    local Shadow = Instance.new("UIShadow")
    Shadow.Size = 16
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Transparency = 0.3
    Shadow.Parent = MainFrame

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 245, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 225, 235))
    })
    Gradient.Rotation = 45
    Gradient.Transparency = 0.2
    Gradient.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = CONFIG.SCRIPT_NAME .. " " .. CONFIG.SCRIPT_VERSION
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = colors.text
    Title.TextXAlignment = Enum.TextXAlignment.Center
    Title.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 10)
    CloseBtn.BackgroundColor3 = colors.buttonBg
    CloseBtn.BackgroundTransparency = 0.6
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = colors.textDim
    CloseBtn.Parent = MainFrame
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = CloseBtn
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -30, 1, -70)
    Content.Position = UDim2.new(0, 15, 0, 55)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, 0, 0, 44)
    InputBox.Position = UDim2.new(0, 0, 0, 0)
    InputBox.BackgroundColor3 = colors.inputBg
    InputBox.BackgroundTransparency = 0.5
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
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = InputBox

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Size = UDim2.new(1, 0, 0, 44)
    CheckBtn.Position = UDim2.new(0, 0, 0, 54)
    CheckBtn.BackgroundColor3 = colors.accent
    CheckBtn.BackgroundTransparency = 0.3
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓ Kiểm tra key"
    CheckBtn.TextSize = 14
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.TextColor3 = colors.text
    CheckBtn.Parent = Content
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 10)
    checkCorner.Parent = CheckBtn

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 44)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 108)
    GetKeyBtn.BackgroundColor3 = colors.buttonBg
    GetKeyBtn.BackgroundTransparency = 0.6
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "🔑 Lấy key mới"
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Font = Enum.Font.Gotham
    GetKeyBtn.TextColor3 = colors.text
    GetKeyBtn.Parent = Content
    local getCorner = Instance.new("UICorner")
    getCorner.CornerRadius = UDim.new(0, 10)
    getCorner.Parent = GetKeyBtn

    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Size = UDim2.new(1, 0, 0, 44)
    JoinBtn.Position = UDim2.new(0, 0, 0, 162)
    JoinBtn.BackgroundColor3 = colors.buttonBg
    JoinBtn.BackgroundTransparency = 0.6
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "💬 Tham gia Discord"
    JoinBtn.TextSize = 14
    JoinBtn.Font = Enum.Font.Gotham
    JoinBtn.TextColor3 = colors.text
    JoinBtn.Parent = Content
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 10)
    joinCorner.Parent = JoinBtn

    -- Hover effects
    local function setHover(btn, targetColor, targetTrans)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor,
                BackgroundTransparency = targetTrans or 0.2
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = btn.BackgroundColor3,
                BackgroundTransparency = btn.BackgroundTransparency
            }):Play()
        end)
    end

    setHover(CheckBtn, Color3.fromRGB(180, 195, 215), 0.2)
    setHover(GetKeyBtn, Color3.fromRGB(210, 220, 235), 0.4)
    setHover(JoinBtn, Color3.fromRGB(210, 220, 235), 0.4)
    setHover(CloseBtn, Color3.fromRGB(200, 210, 225), 0.5)

    -- Sự kiện Join
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

    -- Lấy key mới
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

    -- Kiểm tra key
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
            -- Lưu cache nếu server trả về expires
            if result.expires then
                saveKeyCache(key, result.expires)
            else
                saveKeyCache(key, os.time() + 24 * 3600) -- mặc định 24h
            end
            ScreenGui:Destroy()
            -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
        else
            local msg = (result and result.message) or "Key không hợp lệ!"
            CheckBtn.Text = "Kiểm tra"
            showNotification("Lỗi", msg, 5)
            if (result and result.kick) or (result and result.reason == "wrong_device") then
                task.wait(1)
                kickPlayer("Key chỉ dùng được trên một thiết bị.\nNếu bạn vừa tạo key mới, hãy thử tạo lại.")
            end
        end
        isChecking = false
    end)

    -- Animation mở
    MainFrame.BackgroundTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.25
    }):Play()
end

-- MAIN LOGIC (có cache)
local function main()
    -- Thử đọc cache trước
    local cache = loadKeyCache()
    if cache then
        -- Nếu còn hạn, coi như key hợp lệ
        local remaining = math.floor((cache.expires - os.time()) / 3600)
        showNotification(CONFIG.SCRIPT_NAME, "Key từ cache hợp lệ! Còn " .. remaining .. "h", 4)
        -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
        return
    end

    -- Key từ getgenv
    local presetKey = getgenv().Key
    if presetKey and presetKey ~= "" then
        local result = checkKey(presetKey)
        if result and result.success and result.valid then
            showNotification(CONFIG.SCRIPT_NAME, "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 4)
            if result.expires then
                saveKeyCache(presetKey, result.expires)
            else
                saveKeyCache(presetKey, os.time() + 24 * 3600)
            end
            -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
            return
        else
            if result and (result.kick or result.reason == "wrong_device") then
                kickPlayer("Key chỉ dùng được trên một thiết bị.\nNếu bạn vừa tạo key mới, hãy thử tạo lại.")
                return
            end
        end
    end

    -- Kiểm tra HWID từ server
    local hwidResult = checkHWID()
    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then
        if hwidResult.expires then
            saveKeyCache(hwidResult.key, hwidResult.expires)
        else
            saveKeyCache("hwid_key", os.time() + 24 * 3600)
        end
        -- loadstring(game:HttpGet("URL_MAIN_SCRIPT"))()
        return
    end

    -- Hiển thị UI
    createKeyUI()
end

main()
