-- loadstring(game:HttpGet("https://raw.githubusercontent.com/lnaa323sda/scki343/refs/heads/main/theme.lua"))()
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local function tryProtect(screenGui)
	pcall(function()
		if type(protectgui) == "function" then
			protectgui(screenGui)
		end
	end)
	pcall(function()
		if syn and type(syn.protect_gui) == "function" then
			syn.protect_gui(screenGui)
		end
	end)
end

local function parentIntroGui(screenGui)
	pcall(function()
		if type(gethui) == "function" then
			screenGui.Parent = gethui()
		end
	end)
	if screenGui.Parent then
		tryProtect(screenGui)
		return
	end

	screenGui.Parent = CoreGui
	if screenGui.Parent then
		tryProtect(screenGui)
		return
	end

	local lp = Players.LocalPlayer
	if not lp then
		local ok = pcall(function()
			lp = Players:WaitForChild("LocalPlayer", 20)
		end)
		if not ok or not lp then
			return
		end
	end

	local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 20)
	if pg then
		screenGui.Parent = pg
	end
	if screenGui.Parent then
		tryProtect(screenGui)
	end
end

local function destroyIntroNamed(name)
	local old = CoreGui:FindFirstChild(name)
	if old then
		old:Destroy()
	end
	pcall(function()
		if type(gethui) == "function" then
			local h = gethui()
			if h then
				old = h:FindFirstChild(name)
				if old then
					old:Destroy()
				end
			end
		end
	end)
	local lp = Players.LocalPlayer
	local pg = lp and lp:FindFirstChildOfClass("PlayerGui")
	if pg then
		old = pg:FindFirstChild(name)
		if old then
			old:Destroy()
		end
	end
end

pcall(function()
	for _, name in ipairs({ "DieverHubTheme", "VxezeHubTheme" }) do
		destroyIntroNamed(name)
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "DieverHubTheme"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100

local oldBlur = Lighting:FindFirstChild("VxezeBlur")
if oldBlur then
	oldBlur:Destroy()
end

local blur = Instance.new("BlurEffect")
blur.Name = "VxezeBlur"
blur.Size = 0
blur.Parent = Lighting

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Position = UDim2.new(0, 0, 0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.35
overlay.BorderSizePixel = 0
overlay.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 14, 28)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
})
gradient.Parent = overlay

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.Size = UDim2.new(0, 420, 0, 260)
main.BackgroundTransparency = 1
main.Parent = gui

local logo = Instance.new("ImageLabel")
logo.Name = "Logo"
logo.AnchorPoint = Vector2.new(0.5, 0.5)
logo.Position = UDim2.new(0.5, 0, 0.34, 0)
logo.Size = UDim2.new(0, 150, 0, 150)
logo.BackgroundTransparency = 1
logo.ImageTransparency = 0
logo.ScaleType = Enum.ScaleType.Fit
logo.Image = "rbxassetid://134841272452705"
logo.Parent = main

local hubTitle = "Diever Hub"
local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.76, 0)
title.Size = UDim2.new(0, 340, 0, 55)
title.BackgroundTransparency = 1
title.Text = hubTitle
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SciFi
title.TextTransparency = 0
title.Parent = main

-- color
local titleMetal = Instance.new("UIGradient")
titleMetal.Rotation = 95
titleMetal.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 214, 90)),
	ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 245, 210)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(195, 205, 220)),
})
titleMetal.Parent = title

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(55, 42, 28)
titleStroke.Thickness = 2.8
titleStroke.Transparency = 0.15
pcall(function()
	titleStroke.LineJoinMode = Enum.LineJoinMode.Round
end)
titleStroke.Parent = title

local glow = Instance.new("TextLabel")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0.5, 0.5)
glow.Position = title.Position
glow.Size = title.Size
glow.BackgroundTransparency = 1
glow.Text = hubTitle
glow.TextColor3 = Color3.new(1, 1, 1)
glow.TextScaled = true
glow.Font = Enum.Font.SciFi
glow.TextTransparency = 0.72
glow.ZIndex = title.ZIndex - 1
glow.Parent = main

local glowMetal = Instance.new("UIGradient")
glowMetal.Rotation = 95
glowMetal.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 190, 70)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 175, 195)),
})
glowMetal.Parent = glow

local discord = Instance.new("TextLabel")
discord.Name = "Discord"
discord.AnchorPoint = Vector2.new(0, 1)
discord.Position = UDim2.new(0, 18, 1, -14)
discord.Size = UDim2.new(0, 340, 0, 30)
discord.BackgroundTransparency = 1
discord.Text = "discord.gg/Suxv39x9ZS"
discord.TextXAlignment = Enum.TextXAlignment.Left
discord.Font = Enum.Font.GothamSemibold
discord.TextSize = 22
discord.TextColor3 = Color3.fromRGB(220, 220, 220)
discord.TextTransparency = 0
discord.Parent = gui

-- noti
local toast = Instance.new("Frame")
toast.Name = "ThemeActiveToast"
toast.AnchorPoint = Vector2.new(1, 1)
toast.Position = UDim2.new(1, -18, 1, -18)
toast.Size = UDim2.new(0, 300, 0, 46)
toast.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
toast.BackgroundTransparency = 0.12
toast.BorderSizePixel = 0
toast.ZIndex = 200
toast.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 12)
toastCorner.Parent = toast

local toastStroke = Instance.new("UIStroke")
toastStroke.Color = Color3.fromRGB(210, 185, 120)
toastStroke.Thickness = 1.2
toastStroke.Transparency = 0.35
toastStroke.Parent = toast

local toastGrad = Instance.new("UIGradient")
toastGrad.Rotation = 90
toastGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 28, 22)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24)),
})
toastGrad.Parent = toast

local toastText = Instance.new("TextLabel")
toastText.Name = "ToastText"
toastText.AnchorPoint = Vector2.new(0, 0.5)
toastText.Position = UDim2.new(0, 14, 0.5, 0)
toastText.Size = UDim2.new(1, -52, 0, 22)
toastText.BackgroundTransparency = 1
toastText.Font = Enum.Font.GothamSemibold
toastText.TextSize = 15
toastText.TextXAlignment = Enum.TextXAlignment.Left
toastText.TextColor3 = Color3.fromRGB(255, 236, 200)
toastText.Text = "Diever Hub — Done"
toastText.Parent = toast

local toastIcon = Instance.new("TextLabel")
toastIcon.Name = "ToastIcon"
toastIcon.AnchorPoint = Vector2.new(1, 0.5)
toastIcon.Position = UDim2.new(1, -10, 0.5, 0)
toastIcon.Size = UDim2.new(0, 22, 0, 22)
toastIcon.BackgroundTransparency = 1
toastIcon.Text = "✓"
toastIcon.TextColor3 = Color3.fromRGB(200, 255, 160)
toastIcon.Font = Enum.Font.GothamBold
toastIcon.TextSize = 16
toastIcon.Parent = toast

parentIntroGui(gui)

if not gui.Parent then
	warn("[DieverHub] Không parent được ScreenGui, gethui , CoreGui ,PlayerGui.")
	return
end

toast.Position = UDim2.new(1, 320, 1, -18)
TweenService:Create(toast, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Position = UDim2.new(1, -18, 1, -18),
}):Play()

task.delay(8, function()
	if not toast or not toast.Parent then
		return
	end
	local ti = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(toast, ti, {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(toastStroke, ti, { Transparency = 1 }):Play()
	TweenService:Create(toastText, ti, { TextTransparency = 1 }):Play()
	TweenService:Create(toastIcon, ti, { TextTransparency = 1 }):Play()
	task.delay(0.5, function()
		pcall(function()
			toast:Destroy()
		end)
	end)
end)

TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Size = 18,
}):Play()

task.spawn(function()
	while gui.Parent do
		local up = TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 158, 0, 158),
		})
		local down = TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 150, 0, 150),
		})
		up:Play()
		up.Completed:Wait()
		down:Play()
		down.Completed:Wait()
	end
end)
