local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local freecamEnabled = false
local baseSpeed = 32
local minSpeed, maxSpeed = 5, 250
local sensitivity = 0.18
local sprintMultiplier = 3
local pitch, yaw = 0,0
local camPos = nil
local renderConn = nil
local moveKeys = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false,LeftShift=false}
local hotkey = Enum.KeyCode.F

-- Функція для заморозки персонажа
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

-- Увімкнення FreeCam
local function enableFreeCam()
	if freecamEnabled then return end
	freecamEnabled = true
	local char = player.Character or player.CharacterAdded:Wait()
	freezeCharacter(char, true)
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	camPos = camera.CFrame.Position
	local rx, ry, rz = camera.CFrame:ToEulerAnglesYXZ()
	pitch, yaw = math.deg(rx), math.deg(ry)
	camera.CameraType = Enum.CameraType.Scriptable

	renderConn = RunService.RenderStepped:Connect(function(dt)
		local dx, dy = UserInputService:GetMouseDelta().X, UserInputService:GetMouseDelta().Y
		yaw = yaw - dx*sensitivity
		pitch = math.clamp(pitch - dy*sensitivity,-89,89)
		local rot = CFrame.fromEulerAnglesYXZ(math.rad(pitch), math.rad(yaw), 0)
		local fwd, right = rot.LookVector, rot.RightVector
		local movement = Vector3.zero
		if moveKeys.W then movement += fwd end
		if moveKeys.S then movement -= fwd end
		if moveKeys.A then movement -= right end
		if moveKeys.D then movement += right end
		if moveKeys.Space then movement += Vector3.yAxis end
		if moveKeys.LeftControl then movement -= Vector3.yAxis end
		local speed = baseSpeed
		if moveKeys.LeftShift then speed *= sprintMultiplier end
		if movement.Magnitude > 0 then camPos += movement.Unit * speed * dt end
		camera.CFrame = CFrame.new(camPos) * rot
	end)
end

-- Вимкнення FreeCam
local function disableFreeCam()
	if not freecamEnabled then return end
	freecamEnabled = false
	if renderConn then renderConn:Disconnect() renderConn=nil end
	UserInputService.MouseIconEnabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	local char = player.Character or player.CharacterAdded:Wait()
	freezeCharacter(char, false)
	camera.CameraType = Enum.CameraType.Custom
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then camera.CameraSubject = hum end
end

-- Зміна швидкості
local function setSpeed(speed)
	baseSpeed = math.clamp(speed, minSpeed, maxSpeed)
end

-- Клавіші руху
UserInputService.InputBegan:Connect(function(input, gp)
	if gp or UserInputService:GetFocusedTextBox() then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local name = input.KeyCode.Name
		if moveKeys[name] ~= nil then moveKeys[name] = true end
		if input.KeyCode == hotkey then
			if freecamEnabled then disableFreeCam() else enableFreeCam() end
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local name = input.KeyCode.Name
		if moveKeys[name] ~= nil then moveKeys[name] = false end
	end
end)

-- Перезапуск FreeCam після респавну
player.CharacterAdded:Connect(function(char)
	if freecamEnabled then
		char:WaitForChild("HumanoidRootPart",2)
		freezeCharacter(char,true)
	end
end)

-- Повертаємо функції для виклику з меню
return {
	Enable = enableFreeCam,
	Disable = disableFreeCam,
	SetSpeed = setSpeed,
	GetState = function() return freecamEnabled end
}
