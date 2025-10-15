--[[
    ================================================
    Модуль логіки для Universal Free Cam
    (Без власного GUI, для інтеграції з RbUI)
    ================================================
]]
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
local freeCamToggleObject = nil -- Для зв'язку з UI

-- "Заморожує" або "розморожує" персонажа
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

-- Функція, що оновлює позицію камери кожен кадр
local function updateCamera(dt)
	-- Обертання камери за рухом миші
	local mouseDelta = UserInputService:GetMouseDelta()
	yaw = yaw - mouseDelta.X * sensitivity
	pitch = math.clamp(pitch - mouseDelta.Y * sensitivity, -89, 89)
	local rot = CFrame.fromEulerAnglesYXZ(math.rad(pitch), math.rad(yaw), 0)
	
	-- Рух камери за натисканням клавіш
	local fwd, right = rot.LookVector, rot.RightVector
	local movement = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then movement += fwd end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then movement -= fwd end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then movement -= right end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then movement += right end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then movement += Vector3.yAxis end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then movement -= Vector3.yAxis end
	
	local speed = baseSpeed
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed *= sprintMultiplier end
	
	if movement.Magnitude > 0 then
		camPos += movement.Unit * speed * dt
	end
	
	-- Застосування нової позиції до камери
	camera.CFrame = CFrame.new(camPos) * rot
end

-- Вмикає режим вільної камери
local function enableFreeCam()
	if freecamEnabled then return end
	freecamEnabled = true
	
	local char = Player.Character
	freezeCharacter(char, true)
	
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	camPos = camera.CFrame.Position
	local ry, rx = camera.CFrame:ToEulerAnglesYXZ()
	pitch, yaw = math.deg(rx), math.deg(ry)
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Прив'язуємо оновлення до RenderStepped з високим пріоритетом
	RunService:BindToRenderStep("FreeCamUpdate", Enum.RenderPriority.Camera.Value + 1, updateCamera)
end

-- Вимикає режим вільної камери
local function disableFreeCam()
	if not freecamEnabled then return end
	freecamEnabled = false
	
	-- Відв'язуємо функцію оновлення
	RunService:UnbindFromRenderStep("FreeCamUpdate")
	
	UserInputService.MouseIconEnabled = true
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	local char = Player.Character
	freezeCharacter(char, false)
	
	camera.CameraType = Enum.CameraType.Custom
	if char and char:FindFirstChildOfClass("Humanoid") then
		camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
	end
end

-- Ця функція викликається головним скриптом для створення елементів керування
function FreeCamModule:Init(freeCamSection)
    freeCamToggleObject = freeCamSection:NewToggle("Enable Free Cam", "Activates free camera mode", function(toggled)
        if toggled then enableFreeCam() else disableFreeCam() end
    end)
    
    freeCamSection:NewSlider("Speed", "Adjusts camera movement speed", maxSpeed, minSpeed, function(value)
        baseSpeed = math.floor(value)
    end):UpdateSlider(baseSpeed)
    
    freeCamSection:NewKeybind("Toggle Hotkey", "Set a key to toggle free cam", Enum.KeyCode.F, function()
        if freeCamToggleObject then
            -- Програмно змінюємо стан перемикача в UI
            freeCamToggleObject:UpdateToggle(nil, not freecamEnabled)
        end
    end)

    -- Обробник для заморозки персонажа при респавні, якщо камера активна
    Player.CharacterAdded:Connect(function(char)
        if freecamEnabled then
            task.wait(0.1)
            freezeCharacter(char, true)
        end
    end)
end

-- Ця функція викликається при закритті GUI для очищення
function FreeCamModule:Shutdown()
    disableFreeCam()
end

return FreeCamModule
