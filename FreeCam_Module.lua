local FreeCamModule = {}

-- Сервіси та змінні
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer

-- Локальні змінні стану
local freecamEnabled = false
local baseSpeed = 32
local minSpeed, maxSpeed = 5, 250
local sensitivity = 0.18
local sprintMultiplier = 3
local pitch, yaw = 0, 0
local camPos = nil
local renderConn = nil
local moveKeys = {W=false, A=false, S=false, D=false, Space=false, LeftControl=false, LeftShift=false}
local freeCamToggleObject = nil -- Для зв'язку з UI

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

local function enableFreeCam()
	if freecamEnabled then return end
	freecamEnabled = true
	local char = Player.Character
	freezeCharacter(char, true)
	
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	camPos = Camera.CFrame.Position
	local rx, ry, rz = Camera.CFrame:ToEulerAnglesYXZ()
	pitch, yaw = math.deg(rx), math.deg(ry)
	Camera.CameraType = Enum.CameraType.Scriptable
	
	renderConn = RunService.RenderStepped:Connect(function(dt)
		local dx, dy = UserInputService:GetMouseDelta().X, UserInputService:GetMouseDelta().Y
		yaw = yaw - dx * sensitivity
		pitch = math.clamp(pitch - dy * sensitivity, -89, 89)
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
		Camera.CFrame = CFrame.new(camPos) * rot
	end)
end

local function disableFreeCam()
	if not freecamEnabled then return end
	freecamEnabled = false
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	
	UserInputService.MouseIconEnabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	local char = Player.Character
	freezeCharacter(char, false)
	
	Camera.CameraType = Enum.CameraType.Custom
	if char and char:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
	end
end

-- Функція ініціалізації, яка створює UI та підключає обробники
function FreeCamModule:Init(freeCamSection)
    freeCamToggleObject = freeCamSection:NewToggle("Enable Free Cam", "Activates free camera mode", function(toggled)
        if toggled then enableFreeCam() else disableFreeCam() end
    end)
    
    freeCamSection:NewSlider("Speed", "Adjusts camera movement speed", maxSpeed, minSpeed, function(value)
        baseSpeed = math.floor(value)
    end):UpdateSlider(baseSpeed)
    
    freeCamSection:NewKeybind("Toggle Hotkey", "Set a key to toggle free cam", Enum.KeyCode.F, function()
        if freeCamToggleObject then
            -- Програмно змінюємо стан перемикача
            freeCamToggleObject:UpdateToggle(nil, not freecamEnabled)
        end
    end)
    
    -- Обробники для руху камери
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local name = input.KeyCode.Name
            if moveKeys[name] ~= nil then moveKeys[name] = true end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local name = input.KeyCode.Name
            if moveKeys[name] ~= nil then moveKeys[name] = false end
        end
    end)

    Player.CharacterAdded:Connect(function(char)
        if freecamEnabled then
            task.wait(0.1)
            freezeCharacter(char, true)
        end
    end)
end

-- Функція для очищення при виході
function FreeCamModule:Shutdown()
    disableFreeCam()
end

return FreeCamModule
