aseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = colors.cardBorder
    CloseStroke.Thickness = 1
    CloseStroke.Transparency = 0.25
    CloseStroke.Parent = CloseBtn

    -- HOVER TITLE BUTTONS
    local function hoverBtn(btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.08
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.25
            }):Play()
        end)
    end

    hoverBtn(MinBtn)
    hoverBtn(CloseBtn)

    -- CONTENT
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -28, 1, -48)
    Content.Position = UDim2.new(0, 14, 0, 42)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- INPUT
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
        TweenService:Create(InputStroke, TweenInfo.new(0.22), {
            Color = colors.accent,
            Transparency = 0
        }):Play()
    end)

    KeyInput.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.22), {
            Color = colors.inputBorder,
            Transparency = 0.2
        }):Play()
    end)

    -- CHECK KEY
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Name = "CheckBtn"
    CheckBtn.Size = UDim2.new(1, 0, 0, 38)
    CheckBtn.Position = UDim2.new(0, 0, 0, 48)
    CheckBtn.BackgroundColor3 = colors.primary
    CheckBtn.BackgroundTransparency = 0.08
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓  Check Key"
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

    -- GET KEY
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 38)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 94)
    GetKeyBtn.BackgroundColor3 = colors.buttonBg
    GetKeyBtn.BackgroundTransparency = 0.18
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "🔑  Get Key"
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

    -- JOIN SERVER
    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Name = "JoinBtn"
    JoinBtn.Size = UDim2.new(1, 0, 0, 38)
    JoinBtn.Position = UDim2.new(0, 0, 0, 140)
    JoinBtn.BackgroundColor3 = colors.buttonBg
    JoinBtn.BackgroundTransparency = 0.18
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "💬  Join Server"
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

    -- FOOT TEXT
    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, 0, 0, 24)
    FooterText.Position = UDim2.new(0, 0, 1, -24)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = CONFIG.SCRIPT_VERSION .. "  •  Silver Glass UI"
    FooterText.TextSize = 11
    FooterText.Font = Enum.Font.Gotham
    FooterText.TextColor3 = colors.textSec
    FooterText.Parent = Content

    local function setupHover(btn, stroke)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.05
            }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.18), {
                    Transparency = 0.02
                }):Play()
            end
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.18
            }):Play()
            if stroke then
                TweenService:Create(stroke, TweenInfo.new(0.18), {
                    Transparency = 0.18
                }):Play()
            end
        end)
    end

    setupHover(CheckBtn, CheckStroke)
    setupHover(GetKeyBtn, GetKeyStroke)
    setupHover(JoinBtn, JoinStroke)

    -- ENTRANCE
    MainFrame.BackgroundTransparency = 1
    MainStroke.Transparency = 1

    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.28
    }):Play()

    TweenService:Create(MainStroke, TweenInfo.new(0.45), {
        Transparency = 0.18
    }):Play()

    -- MINIMIZE/CLOSE
    local isMinimized = false
    local expandedSize = UDim2.new(0, 320, 0, 245)
    local minimizedSize = UDim2.new(0, 320, 0, 38)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Content.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = minimizedSize
            }):Play()
            MinBtn.Text = "+"
        else
            Content.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = expandedSize
            }):Play()
            MinBtn.Text = "—"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.26)
        ScreenGui:Destroy()
    end)

    -- JOIN SERVER BUTTON
    JoinBtn.MouseButton1Click:Connect(function()
        local url = CONFIG.JOIN_SERVER_URL
        local opened = tryOpenLink(url)
        local copied = copyText(url)

        if opened then
            showNotification("Join Server", "Đã mở link server.", 5)
        elseif copied then
            showNotification("Join Server", "Không mở trực tiếp được, đã copy link server.", 6)
        else
            showNotification("Join Server", "Link server: " .. url, 6)
        end
    end)

    -- GET KEY BUTTON
    local isGettingKey = false
    GetKeyBtn.MouseButton1Click:Connect(function()
        if isGettingKey then return end
        isGettingKey = true

        GetKeyBtn.Text = "⏳  Creating..."
        GetKeyBtn.TextColor3 = colors.textDark

        local data = createKeyAndLink()

        if not data or not data.success then
            local errMsg = (data and data.message) or "Lỗi kết nối server!"
            GetKeyBtn.Text = "❌  Failed"
            showNotification("Get Key", errMsg, 6)

            task.wait(2)
            GetKeyBtn.Text = "🔑  Get Key"
            isGettingKey = false
            return
        end

        local link = data.link or ""
        local newKey = data.key or ""
        local copiedText = (link ~= "" and link) or newKey

        local copied = copyText(copiedText)

        GetKeyBtn.Text = copied and "✅  Copied" or "✅  Created"
        showNotification(
            "Get Key",
            copied and "Đã tạo link getkey và tự copy." or "Đã tạo key/link thành công.",
            6
        )

        task.wait(2.5)
        GetKeyBtn.Text = "🔑  Get Key"
        isGettingKey = false
    end)

    -- CHECK KEY BUTTON
    local isProcessing = false

    CheckBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true

        local key = KeyInput.Text:gsub("%s+", "")

        if key == "" then
            showNotification("Check Key", "Vui lòng nhập key.", 4)
            TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()
            task.wait(0.45)
            TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = colors.inputBorder
            }):Play()
            isProcessing = false
            return
        end

        CheckBtn.Text = "⏳  Checking..."

        local result = checkKey(key)

        if result and result.success and result.valid then
            CheckBtn.Text = "✅  Valid"
            showNotification("Diever Hub", "Key thành công! Đang tải script...", 5)

            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            task.wait(0.45)
            ScreenGui:Destroy()

            -- LOAD YOUR MAIN SCRIPT HERE
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        else
            local errorMsg = (result and result.message) or "Key không hợp lệ!"
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false

            CheckBtn.Text = "Check Key"

            local origPos = InputFrame.Position
            for i = 1, 4 do
                TweenService:Create(InputFrame, TweenInfo.new(0.04), {
                    Position = origPos + UDim2.new(0, (i % 2 == 0 and 6 or -6), 0, 0)
                }):Play()
                task.wait(0.04)
            end
            TweenService:Create(InputFrame, TweenInfo.new(0.04), {
                Position = origPos
            }):Play()

            TweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()

            showNotification("Check Key", errorMsg, 5)

            task.wait(0.8)
            TweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = colors.inputBorder
            }):Play()

            if shouldKick or reason == "wrong_device" then
                task.wait(1)
                kickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
            else
                task.wait(1.6)
                kickPlayer("Key không hợp lệ hoặc đã hết hạn!\n\nIb Admin")
            end
        end

        isProcessing = false
    end)

    return ScreenGui
end

-- MAIN LOGIC
local function main()
    local presetKey = ""
    pcall(function()
        if getgenv().Key and getgenv().Key ~= "" then
            presetKey = getgenv().Key
        end
    end)

    if presetKey ~= "" then
        local result = checkKey(presetKey)

        if result and result.success and result.valid then
            showNotification("Diever Hub", "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 5)
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
            return
        else
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false
            if shouldKick or reason == "wrong_device" then
                kickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
                return
            end
        end
    end

    local hwidResult = checkHWID()

    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then
        -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        return
    end

    createKeyUI()
end

aseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local CloseStroke = Instance.new("UIStroke")
    CloseStroke.Color = colors.cardBorder
    CloseStroke.Thickness = 1
    CloseStroke.Transparency = 0.25
    CloseStroke.Parent = CloseBtn

    -- HOVER TITLE BUTTONS
    local function hoverBtn(btn)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.08
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.25
            }):Play()
        end)
    end

    hoverBtn(MinBtn)
    hoverBtn(CloseBtn)

    -- CONTENT
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -28, 1, -48)
    Content.Position = UDim2.new(0, 14, 0, 42)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- INPUT
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
        TweenService:Create(InputStroke, TweenInfo.new(0.22), {
            Color = colors.accent,
            Transparency = 0
        }):Play()
    end)

    KeyInput.FocusLost:Connect(function()
        TweenService:Create(InputStroke, TweenInfo.new(0.22), {
            Color = colors.inputBorder,
            Transparency = 0.2
        }):Play()
    end)

    -- CHECK KEY
    local CheckBtn = Instance.new("TextButton")
    CheckBtn.Name = "CheckBtn"
    CheckBtn.Size = UDim2.new(1, 0, 0, 38)
    CheckBtn.Position = UDim2.new(0, 0, 0, 48)
    CheckBtn.BackgroundColor3 = colors.primary
    CheckBtn.BackgroundTransparency = 0.08
    CheckBtn.BorderSizePixel = 0
    CheckBtn.Text = "✓  Check Key"
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

    -- GET KEY
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(1, 0, 0, 38)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 94)
    GetKeyBtn.BackgroundColor3 = colors.buttonBg
    GetKeyBtn.BackgroundTransparency = 0.18
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Text = "🔑  Get Key"
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

    -- JOIN SERVER
    local JoinBtn = Instance.new("TextButton")
    JoinBtn.Name = "JoinBtn"
    JoinBtn.Size = UDim2.new(1, 0, 0, 38)
    JoinBtn.Position = UDim2.new(0, 0, 0, 140)
    JoinBtn.BackgroundColor3 = colors.buttonBg
    JoinBtn.BackgroundTransparency = 0.18
    JoinBtn.BorderSizePixel = 0
    JoinBtn.Text = "💬  Join Server"
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

    -- FOOT TEXT
    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, 0, 0, 24)
    FooterText.Position = UDim2.new(0, 0, 1, -24)
    FooterText.BackgroundTransparency = 1
    FooterText.Text = CONFIG.SCRIPT_VERSION .. "  •  Silver Glass UI"
    FooterText.TextSize = 11
    FooterText.Font = Enum.Font.Gotham
    FooterText.TextColor3 = colors.textSec
    FooterText.Parent = Content

    local function setupHover(btn, stroke)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18), {
                BackgroundTransparency = 0.05
            })  6
        )

        task.wait(2.5)
        GetKeyBtn.Text = "🔑  Get Key"
        isGettingKey = false
    end)

    -- CHECK KEY BUTTON
    local isProcessing = false

    CheckBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true

        local key = KeyInput.Text:gsub("%s+", "")

        if key == "" then
            showNotification("Check Key", "Vui lòng nhập key.", 4)
            TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()
            task.wait(0.45)
            TweenService:Create(InputStroke, TweenInfo.new(0.2), {
                Color = colors.inputBorder
            }):Play()
            isProcessing = false
            return
        end

        CheckBtn.Text = "⏳  Checking..."

        local result = checkKey(key)

        if result and result.success and result.valid then
            CheckBtn.Text = "✅  Valid"
            showNotification("Diever Hub", "Key thành công! Đang tải script...", 5)

            TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()

            task.wait(0.45)
            ScreenGui:Destroy()

            -- LOAD YOUR MAIN SCRIPT HERE
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        else
            local errorMsg = (result and result.message) or "Key không hợp lệ!"
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false

            CheckBtn.Text = "Check Key"

            local origPos = InputFrame.Position
            for i = 1, 4 do
                TweenService:Create(InputFrame, TweenInfo.new(0.04), {
                    Position = origPos + UDim2.new(0, (i % 2 == 0 and 6 or -6), 0, 0)
                }):Play()
                task.wait(0.04)
            end
            TweenService:Create(InputFrame, TweenInfo.new(0.04), {
                Position = origPos
            }):Play()

            TweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = Color3.fromRGB(255, 255, 255)
            }):Play()

            showNotification("Check Key", errorMsg, 5)

            task.wait(0.8)
            TweenService:Create(InputStroke, TweenInfo.new(0.25), {
                Color = colors.inputBorder
            }):Play()

            if shouldKick or reason == "wrong_device" then
                task.wait(1)
                kickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
            else
                task.wait(1.6)
                kickPlayer("Key không hợp lệ hoặc đã hết hạn!\n\nIb Admin")
            end
        end

        isProcessing = false
    end)

    return ScreenGui
end

-- MAIN LOGIC
local function main()
    local presetKey = ""
    pcall(function()
        if getgenv().Key and getgenv().Key ~= "" then
            presetKey = getgenv().Key
        end
    end)

    if presetKey ~= "" then
        local result = checkKey(presetKey)

        if result and result.success and result.valid then
            showNotification("Diever Hub", "Key hợp lệ! Còn " .. tostring(result.remaining_hours) .. "h", 5)
            -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
            return
        else
            local reason = (result and result.reason) or ""
            local shouldKick = (result and result.kick) or false
            if shouldKick or reason == "wrong_device" then
                kickPlayer("MduccDev!\nMỗi key chỉ dùng được trên 1 thiết bị.")
                return
            end
        end
    end

    local hwidResult = checkHWID()

    if hwidResult and hwidResult.success and hwidResult.has_key and hwidResult.valid then
        -- loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        return
    end

    createKeyUI()
end

main()
