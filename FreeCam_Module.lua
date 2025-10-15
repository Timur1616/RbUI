--[[
    ================================================
    Universal Free Cam (Виправлена версія)
    ================================================
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Налаштування GUI (без змін)
local DISPLAY_ORDER = 10000
local CONTAINER_W, CONTAINER_H = 200, 136
local BTN_W, BTN_H = 88, 26
local BTN_COLOR = Color3.fromRGB(28, 28, 28)
local BTN_HOVER = Color3.fromRGB(82, 44, 154)
local TEXT_COLOR = Color3.fromRGB(210, 190, 255)
local LABEL_COLOR = Color3.fromRGB(180, 120, 255)
local BORDER_COL = Color3.fromRGB(120, 0, 180)
local baseColors = {
	Color3.fromRGB(100,0,130),
	Color3.fromRGB(120,0,160),
	Color3.fromRGB(150,0,200),
	Color3.fromRGB(120,0,160),
}

-- Створення GUI (без змін)
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalFreeCam"
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = DISPLAY_ORDER
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end

local container = Instance.new("Frame")
container.Size = UDim2.fromOffset(CONTAINER_W, CONTAINER_H)
container.Position = UDim2.new(0, 18, 0, 18)
container.BackgroundColor3 = Color3.fromRGB(18,18,18)
container.BorderSizePixel = 2
container.BorderColor3 = BORDER_COL
container.Parent = gui
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

local grad = Instance.new("UIGradient")
grad.Rotation = 0
grad.Parent = container
local animT = 0
RunService.RenderStepped:Connect(function(dt)
	animT = animT + dt
	local idx = math.floor(animT * 1.6) % #baseColors + 1
	local nextIdx = idx % #baseColors + 1
	local alpha = (animT * 1.6) % 1
	local c1 = baseColors[idx]:Lerp(baseColors[nextIdx], alpha)
	local c2 = baseColors[nextIdx]:Lerp(baseColors[idx], alpha)
	grad.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2) }
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -18, 0, 22)
title.Position = UDim2.fromOffset(9, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = LABEL_COLOR
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Universal Free Cam"
title.Parent = container

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.fromOffset(BTN_W, BTN_H)
toggleBtn.Position = UDim2.fromOffset(9, 36)
toggleBtn.BackgroundColor3 = BTN_COLOR
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 12
toggleBtn.TextColor3 = TEXT_COLOR
toggleBtn.Text = "OFF"
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = container
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

local bindBtn = Instance.new("TextButton")
bindBtn.Size = UDim2.fromOffset(BTN_W, BTN_H)
bindBtn.Position = UDim2.fromOffset(9 + BTN_W + 8, 36)
bindBtn.BackgroundColor3 = BTN_COLOR
bindBtn.Font = Enum.Font.GothamSemibold
bindBtn.TextSize = 12
bindBtn.TextColor3 = TEXT_COLOR
bindBtn.Text = "Key: F"
bindBtn.AutoButtonColor = false
bindBtn.Parent = container
Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.fromOffset(60, 18)
sliderLabel.Position = UDim2.fromOffset(9, 72)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 12
sliderLabel.TextColor3 = LABEL_COLOR
sliderLabel.Text = "Speed"
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
sliderLabel.Parent = container

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.fromOffset(60, 18)
valueLabel.Position = UDim2.fromOffset(CONTAINER_W - 9 - 60, 72)
valueLabel.BackgroundTransparency = 1
valueLabel.Font = Enum.Font.Gotham
valueLabel.TextSize = 12
valueLabel.TextColor3 = LABEL_COLOR
valueLabel.Text = ""
valueLabel.TextXAlignment = Enum.TextXAlignment.Right
valueLabel.Parent = container

local SLIDER_MARGIN = 9
local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.fromOffset(CONTAINER_W - SLIDER_MARGIN*2, 6)
sliderBar.Position = UDim2.fromOffset(SLIDER_MARGIN, 98)
sliderBar.BackgroundColor3 = Color3.fromRGB(36,36,36)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = container
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(140,72,200)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBar
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 3)

local knobSize = 12
local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.fromOffset(knobSize, knobSize)
sliderKnob.Position = UDim2.fromOffset(-knobSize/2, -3)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200,150,255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBar
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(0, 6)

-- ЗМІННІ FREE CAM
local freecamEnabled = false
local baseSpeed = 32
local minSpeed, maxSpeed = 5, 250
local sensitivity = 0.18
local sprintMultiplier = 3
local pitch, yaw = 0, 0
local camPos = nil
local renderConn = nil
local hotkey = Enum.KeyCode.F
local waitingForBind = false

-- Функції-хелпери
local hoverTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function AddHover(button, hoverColor)
	button.MouseEnter:Connect(function() TweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = hoverColor}):Play() end)
	button.MouseLeave:Connect(function() TweenService:Create(button, hoverTweenInfo, {BackgroundColor3 = BTN_COLOR}):Play() end)
end
AddHover(toggleBtn, BTN_HOVER)
AddHover(bindBtn, Color3.fromRGB(100,50,180))
AddHover(sliderKnob, Color3.fromRGB(255,200,255))

local function freezeCharacter(char, freeze)
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Anchored = freeze end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = freeze and 0 or 16
		hum.JumpPower = freeze and 0 or 50
	end
end

-- ==========================================================
-- ОСНОВНА ЛОГІКА FREE CAM (ВИПРАВЛЕНО)
-- ==========================================================

local function enableFreeCam()
	if freecamEnabled then return end
	freecamEnabled = true
	toggleBtn.Text = "ON"
	toggleBtn.BackgroundColor3 = Color3.fromRGB(60,120,60)
	local char = player.Character
	freezeCharacter(char, true)
	
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	camPos = camera.CFrame.Position
	local rx, ry = camera.CFrame:ToEulerAnglesYXZ()
	pitch, yaw = math.deg(rx), math.deg(ry)
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Створюємо з'єднання з RenderStepped
	renderConn = RunService.RenderStepped:Connect(function(dt)
		-- Обертання камери
		local mouseDelta = UserInputService:GetMouseDelta()
		yaw = yaw - mouseDelta.X * sensitivity
		pitch = math.clamp(pitch - mouseDelta.Y * sensitivity, -89, 89)
		local rot = CFrame.fromEulerAnglesYXZ(math.rad(pitch), math.rad(yaw), 0)
		
		-- **ВИПРАВЛЕНО:** Перевірка натиснутих клавіш всередині циклу
		local fwd, right = rot.LookVector, rot.RightVector
		local movement = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then movement += fwd end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then movement -= fwd end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then movement -= right end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then movement += right end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then movement += Vector3.yAxis end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then movement -= Vector3.yAxis end
		
		-- Розрахунок швидкості
		local speed = baseSpeed
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed *= sprintMultiplier end
		
		-- Рух камери
		if movement.Magnitude > 0 then
			camPos += movement.Unit * speed * dt
		end
		
		-- Оновлення позиції камери
		camera.CFrame = CFrame.new(camPos) * rot
	end)
end

local function disableFreeCam()
	if not freecamEnabled then return end
	freecamEnabled = false
	toggleBtn.Text = "OFF"
	toggleBtn.BackgroundColor3 = BTN_COLOR
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	
	UserInputService.MouseIconEnabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	local char = player.Character
	freezeCharacter(char, false)
	
	camera.CameraType = Enum.CameraType.Custom
	if char and char:FindFirstChildOfClass("Humanoid") then
		camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
	end
end

-- Логіка слайдера (без змін)
local function setSpeedFromPercent(p)
	p = math.clamp(p or 0,0,1)
	baseSpeed = math.floor(minSpeed+(maxSpeed-minSpeed)*p+0.5)
	valueLabel.Text = tostring(baseSpeed)
	sliderFill.Size = UDim2.new(p,0,1,0)
	sliderKnob.Position = UDim2.new(p,-knobSize/2,0,-3)
end
setSpeedFromPercent((baseSpeed-minSpeed)/(maxSpeed-minSpeed))

local draggingSlider=false
local function updateSliderFromX(x)
	local barX, barW = sliderBar.AbsolutePosition.X, sliderBar.AbsoluteSize.X
	if barW <= 0 then return end
	setSpeedFromPercent((x-barX)/barW)
end

sliderBar.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		draggingSlider=true; updateSliderFromX(UserInputService:GetMouseLocation().X)
	end
end)
sliderBar.InputEnded:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType==Enum.UserInputType.MouseMovement then
		updateSliderFromX(input.Position.X)
	end
end)

-- Обробники кнопок та хоткеїв (без змін)
local fadeTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
UserInputService.InputBegan:Connect(function(input, gp)
	if waitingForBind and input.UserInputType==Enum.UserInputType.Keyboard then
		hotkey=input.KeyCode; bindBtn.Text="Key: "..hotkey.Name; waitingForBind=false; return
	end
	if gp or UserInputService:GetFocusedTextBox() then return end
	
	if input.KeyCode==hotkey then
		if freecamEnabled then disableFreeCam() else enableFreeCam() end
	elseif input.KeyCode==Enum.KeyCode.RightShift then
		container.Visible = not container.Visible -- Спрощено для наочності
	end
end)

bindBtn.MouseButton1Click:Connect(function()
	if waitingForBind then return end
	waitingForBind=true; bindBtn.Text="Press any key..."
end)

toggleBtn.MouseButton1Click:Connect(function()
	if freecamEnabled then disableFreeCam() else enableFreeCam() end
end)

-- Перетягування вікна (без змін)
local dragging=false; local dragInput, mousePos, framePos
title.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true; mousePos=input.Position; framePos=container.Position
		input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - mousePos
		container.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
	end
end)

player.CharacterAdded:Connect(function(char)
	if freecamEnabled then
		task.wait(0.1) -- Даємо персонажу завантажитись
		freezeCharacter(char,true)
	end
end)
