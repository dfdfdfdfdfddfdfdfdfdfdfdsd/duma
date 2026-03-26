--// =========================================
--// DIEVER HUB KEY SYSTEM - FULL SOURCE FIX
--// =========================================

local CONFIG = {
    API_BASE_URL = "https://shoproblox29.cfd/api",
    ADMIN_PASSWORD = "hentaixyz",
    SCRIPT_NAME = "Diever Hub",
    SCRIPT_VERSION = "v1.0",
    KEY_PREFIX = "DVH",

    JOIN_SERVER_URL = "https://discord.gg/yourserver",
    CACHE_FILE = "dieverhub.txt",
    URL_MAIN_SCRIPT = "loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua"))()"
}

--// SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

--// HWID
local function getHWID()
    local hwid = ""
    pcall(function()
        hwid = RbxAnalyticsService:GetClientId()
    end)

    if hwid == "" or hwid == nil then
        hwid = tostring(player.UserId) .. "_" .. tostring(game.PlaceId)
    end

    local today = os.date("%Y-%m-%d")
    hwid = hwid .. "_" .. today
    return hwid
end

local HWID = getHWID()

--// HTTP
local function httpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if success and result then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(result)
        end)
        if ok then
            return data
        end
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

--// CACHE
local function saveKeyCache(key, expiresAt)
    if not writefile then
        return false
    end

    local success = pcall(function()
        local data = {
            key = key,
            hwid = HWID,
            expires = expiresAt,
            savedAt = os.time()
        }
        writefile(CONFIG.CACHE_FILE, HttpService:JSONEncode(data))
    end)

    return success
end

local function loadKeyCache()
    if not readfile or not isfile then
        return nil
    end

    local success, result = pcall(function()
        if not isfile(CONFIG.CACHE_FILE) then
            return nil
        end

        local content = readfile(CONFIG.CACHE_FILE)
        if not content or content == "" then
            return nil
        end

        local data = HttpService:JSONDecode(content)
        if data and data.hwid == HWID and data.expires and tonumber(data.expires) and tonumber(data.expires) > os.time() then
            return data
        end

        return nil
    end)

    return success and result or nil
end

--// UTILS
local function kickPlayer(reason)
    player:Kick("\n\nKey System\n\n" .. tostring(reason) .. "\n\nVui lòng lấy key mới và thử lại.")
end

local function showNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = duration or 5
        })
    end)
end

local function copyText(text)
    if not text or text == "" then
        return false
    end

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

local function tryOpenLink(url)
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

local function loadMainScript()
    if not CONFIG.URL_MAIN_SCRIPT or CONFIG.URL_MAIN_SCRIPT == "" or CONFIG.URL_MAIN_SCRIPT == "https://your-main-script-url-here" then
        showNotification(CONFIG.SCRIPT_NAME, "Chưa đặt URL_MAIN_SCRIPT.", 5)
        return
    end

    local ok, err = pcall(function()
        loadstring(game:HttpGet(CONFIG.URL_MAIN_SCRIPT))()
    end)

    if not ok then
        showNotification(CONFIG.SCRIPT_NAME, "Load script lỗi: " .. tostring(err), 6)
    end
end

--// UI
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

    local ok = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ok then
        ScreenGui.Parent = player:WaitForChild("PlayerGui")
    end

    if not ScreenGui.Parent then
        warn("Không thể tạo UI")
        return
    end

    local colors = {
        main = Color3.fromRGB(102, 108, 118),
        main2 = Color3.fromRGB(82, 88, 98),
        panel = Color3.fromRGB(135, 142, 154),
        panel2 = Color3.fromRGB(160, 168, 180),
        stroke = Color3.fromRGB(235, 239, 244),
        text = Color3.fromRGB(22, 25, 30),
        text2 = Color3.fromRGB(34, 37, 42),
        muted = Color3.fromRGB(72, 78, 88),
        input = Color3.fromRGB(219, 224, 232),
        btn = Color3.fromRGB(192, 198, 208),
        btn2 = Color3.fromRGB(178, 184, 194),
        white = Color3.fromRGB(255, 255, 255)
    }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 270)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = colors.main
    MainFrame.BackgroundTransparency = 0.06
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = colors.stroke
    MainStroke.Thickness = 1.2
    MainStroke.Transparency = 0.1
    MainStroke.Parent = MainFrame

    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors.panel2),
        ColorSequenceKeypoint.new(1, colors.main2)
    })
    MainGradient.Rotation = 90
    MainGradient.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundTransparency = 1
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -90, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = CONFIG.SCRIPT_NAME .. "  " .. CONFIG.SCRIPT_VERSION
    Title.TextColor3 = colors.white
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -68, 0, 7)
    MinBtn.BackgroundColor3 = colors.btn
    MinBtn.BackgroundTransparency = 0.12
    MinBtn.BorderSizePixel = 0
    MinBtn.Text = "—"
    MinBtn.TextColor3 = colors.text
    MinBtn.TextSize = 16
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TopBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinBtn

    local MinStroke = Instance.new("UIStroke")
    MinStroke.Color = colors.stroke
    MinStroke.Thickness = 1
    MinStroke.Transparency = 0.2
    MinStroke.Parent = MinBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = colors.btn
    CloseBtn.BackgroundTransparency = 0.12
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = colors.text
    CloseBtn.TextSize = 15
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = colors.stroke
    CloseStroke.Thickness = 1
    CloseStroke.Transparency = 0.2
    CloseStroke.Parent = CloseBtn

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -24, 1, -54)
    Content.Position = UDim2.new(0, 12, 0, 46)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Name = "InputBox"
    InputBox.Size = UDim2.new(1, 0, 0, 44)
    InputBox.Position = UDim2.new(0, 0, 0, 0)
    InputBox.BackgroundColor3 = colors.input
    InputBox.BackgroundTransparency = 0.03
    InputBox.BorderSizePixel = 0
    InputBox.PlaceholderText = "Nhập key tại đây..."
    InputBox.PlaceholderColor3 = colors.muted
    InputBox.Text = ""
    InputBox.TextColor3 = colors.text
    InputBox.TextSize = 14
    InputBox.Font = Enum.Font.Gotham
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Content

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = InputBox

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = colors.stroke
    InputStroke.Thickness = 1
    InputStroke.Transparency = 0.15
    InputStroke.Parent = InputBox

    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Name = "CheckBtn"
    CheckBtn.Size = UDim2.new(1, 0, 0, 42)
    CheckBtn.Position = UDim2.new(0, 0, 0, 56)
    CheckBtn.BackgroundColor3 = colors.btn
    CheckBtn.BackgroundTransparency = 0.04
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓ Kiểm tra key"
    CheckBtn.TextColor3 = colors.text2
    CheckBtn.TextSize = 14
    CheckBtn.Font = Enum.Font.GothamBold
    CheckBtn.AutoButtonColor = false
    CheckBtn.Parent = Content

    local CheckCorner = Instance.new("UICorner")
    CheckCorner.CornerRadius = UDim.new(0, 10)
    CheckCorner.Parent = CheckBtn

    local CheckStroke = Instance.new("UIStroke")
    CheckStroke.Color = colors.stroke
    CheckStroke.Thickness = 1
    CheckStroke.Transparency = 0.18
    CheckStroke.Parent = CheckBtn

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 42)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 108)
    GetKeyBtn.BackgroundColor3 = colors.btn
    GetKeyBtn.BackgroundTransparency = 0.06
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "🔑 Lấy key mới"
    GetKeyBtn.TextColor3 = colors.text2
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Font = Enum.Font.GothamSemibold
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Parent = Content

    local GetCorner = Instance.new("UICorner")
    GetCorner.CornerRadius = UDim.new(0, 10)
    GetCorner.Parent = GetKeyBtn

    local GetStroke = Instance.new("UIStroke")
    GetStroke.Color = colors.stroke
    GetStroke.Thickness = 1
    GetStroke.Transparency = 0.18
    GetStroke.Parent = GetKeyBtn

    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Name = "JoinBtn"
    JoinBtn.Size = UDim2.new(1, 0, 0, 42)
    JoinBtn.Position = UDim2.new(0, 0, 0, 160)
    JoinBtn.BackgroundColor3 = colors.btn
    JoinBtn.BackgroundTransparency = 0.06
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "💬 Join Server"
    JoinBtn.TextColor3 = colors.text2
    JoinBtn.TextSize = 14
    JoinBtn.Font = Enum.Font.GothamSemibold
    JoinBtn.AutoButtonColor = false
    JoinBtn.Parent = Content

    local JoinCorner = Instance.new("UICorner")
    JoinCorner.CornerRadius = UDim.new(0, 10)
    JoinCorner.Parent = JoinBtn

    local JoinStroke = Instance.new("UIStroke")
    JoinStroke.Color = colors.stroke
    JoinStroke.Thickness = 1
    JoinStroke.Transparency = 0.18
    JoinStroke.Parent = JoinBtn

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -20)
    Footer.BackgroundTransparency = 1
    Footer.Text = "Silver Basic UI"
    Footer.TextColor3 = Color3.fromRGB(245, 247, 250)
    Footer.TextSize = 11
    Footer.Font = Enum.Font.Gotham
    Footer.Parent = Content

    local function bindHover(btn, baseTrans, hoverTrans)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = hoverTrans
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundTransparency = baseTrans
            }):Play()
        end)
    end

    bindHover(CheckBtn, 0.04, 0)
    bindHover(GetKeyBtn, 0.06, 0.01)
    bindHover(JoinBtn, 0.06, 0.01)
    bindHover(MinBtn, 0.12, 0.02)
    bindHover(CloseBtn, 0.12, 0.02)

    InputBox.Focused:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {
            Transparency = 0
        }):Play()
    end)

    InputBox.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.15), {
            Transparency = 0.15
        }):Play()
    end)

    local minimized = false
    local normalSize = UDim2.new(0, 350, 0, 270)
    local miniSize = UDim2.new(0, 350, 0, 42)

    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Content.Visible = false
            MinBtn.Text = "+"
            TweenService:Create(MainFrame, TweenInfo.new(0.22), {
                Size = miniSize
            }):Play()
        else
            Content.Visible = true
            MinBtn.Text = "—"
            TweenService:Create(MainFrame, TweenInfo.new(0.22), {
                Size = normalSize
            }):Play()
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    JoinBtn.MouseButton1Click:Connect(function()
        local url = CONFIG.JOIN_SERVER_URL
        if tryOpenLink(url) then
            showNotification("Join Server", "Đã mở link server.", 5)
        elseif copyText(url) then
            showNotification("Join Server", "Đã copy link server.", 5)
        else
            showNotification("Join Server", url, 5)
        end
    end)

    local isGettingKey = false
    GetKeyBtn.MouseButton1Click:Connect(function()
        if isGettingKey then
            return
        end

        isGettingKey = true
        GetKeyBtn.Text = "Đang tạo..."

        local data = createKeyAndLink()
        if not data or not data.success then
            GetKeyBtn.Text = "❌ Thất bại"
            showNotification("Lỗi", (data and data.message) or "Không thể kết nối server", 5)
            task.wait(2)
            GetKeyBtn.Text = "🔑 Lấy key mới"
            isGettingKey = false
            return
        end

        local link = data.link or ""
        local newKey = data.key or ""
        local finalText = (link ~= "" and link) or newKey

        copyText(finalText)
        GetKeyBtn.Text = "✅ Đã copy"
        showNotification("Get Key", "Đã tạo link/key và copy vào clipboard.", 5)

        task.wait(2)
        GetKeyBtn.Text = "🔑 Lấy key mới"
        isGettingKey = false
    end)

    local isChecking = false
    CheckBtn.MouseButton1Click:Connect(function()
        if isChecking then
            return
        end

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

            if result.expires then
                saveKeyCache(key, result.expires)
            else
                saveKeyCache(key, os.time() + 24 * 3600)
            end

            task.wait(0.5)
            ScreenGui:Destroy()
            loadMainScript()
        else
            local msg = (result and result.message) or "Key không hợp lệ!"
            CheckBtn.Text = "✓ Kiểm tra key"
            showNotification("Lỗi", msg, 5)

            if (result and result.kick) or (result and result.reason == "wrong_device") then
                task.wait(1)
                kickPlayer("Key chỉ dùng được trên một thiết bị.\nNếu bạn vừa tạo key mới, hãy thử tạo lại.")
            end
        end

        isChecking = false
    end)

    MainFrame.BackgroundTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.06
    }):Play()
end

--// MAIN
local function main()
    local cache = loadKeyCache()
    if cache then
        local remaining = math.floor((cache.expires - os.time()) / 3600)
        if remaining < 0 then
            remaining = 0
        end
        showNotification(CONFIG.SCRIPT_NAME, "Key từ cache hợp lệ! Còn " .. tostring(remaining) .. "h", 4)
        loadMainScript()
        return
    end

    local presetKey = nil
    pcall(function()
        presetKey = getgenv().Key
    end)

    if presetKey and presetKey ~= "" then
        local result = checkKey(presetKey)
        if result and result.success and result.valid then
            showNotification(CONFIG.SCRIPT_NAME, "Key hợp lệ! Còn " .. tostring(result.remaining_hours or "?") .. "h", 4)

            if result.expires then
                saveKeyCache(presetKey, result.expires)
            else
                saveKeyCache(presetKey, os.time() + 24 * 3600)
            end

            loadMainScript()
            return
        else
            if result and (result.kick or result.reason == "wrong_device") then
                kickPlayer("Key chỉ dùng được trên một thiết bị.\nNếu bạn vừa tạo key mới, hãy thử tạo lại.")
                return
            end
        end
    end

    local hwidResult = checkHWID()
    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then
        if hwidResult.expires then
            saveKeyCache(hwidResult.key or "hwid_key", hwidResult.expires)
        else
            saveKeyCache(hwidResult.key or "hwid_key", os.time() + 24 * 3600)
        end

        loadMainScript()
        return
    end

    createKeyUI()
end

main()
