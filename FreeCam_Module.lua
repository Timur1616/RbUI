-- FreeCam_Module.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local FreeCam = {}
FreeCam._enabled = false
FreeCam._baseSpeed = 32
FreeCam._minSpeed, FreeCam._maxSpeed = 5, 250
FreeCam._sensitivity = 0.18
FreeCam._sprintMultiplier = 3

local pitch, yaw = 0, 0
local camPos = nil
local renderConn = nil
local moveKeys = {W=false,A=false,S=false,D=false,Space=false,LeftControl=false,LeftShift=false}

local inputBeganConn, inputEndedConn, charAddedConn = nil, nil, nil

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

local function enableInternal()
    if FreeCam._enabled then return end
    FreeCam._enabled = true

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
    yaw = yaw - dx * FreeCam._sensitivity
    pitch = math.clamp(pitch - dy * FreeCam._sensitivity, -89, 89)
    local rot = CFrame.fromEulerAnglesYXZ(math.rad(pitch), math.rad(yaw), 0)
    local fwd, right = rot.LookVector, rot.RightVector

    local movement = Vector3.zero
    if moveKeys.W then movement += fwd end
    if moveKeys.S then movement -= fwd end
    if moveKeys.A then movement -= right end
    if moveKeys.D then movement += right end
    if moveKeys.Space then movement += Vector3.yAxis end
    if moveKeys.LeftControl then movement -= Vector3.yAxis end

    -- Оновлена швидкість
    local speed = FreeCam._baseSpeed
    if moveKeys.LeftShift then speed *= FreeCam._sprintMultiplier end

    if movement.Magnitude > 0 then
        camPos += movement.Unit * speed * dt
    end

    camera.CFrame = CFrame.new(camPos) * rot
end)


    charAddedConn = player.CharacterAdded:Connect(function(char)
        if FreeCam._enabled then
            char:WaitForChild("HumanoidRootPart", 2)
            freezeCharacter(char, true)
        end
    end)
end

local function disableInternal()
    if not FreeCam._enabled then return end
    FreeCam._enabled = false

    if renderConn then renderConn:Disconnect() renderConn = nil end
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end

    UserInputService.MouseIconEnabled = true
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    local char = player.Character or player.CharacterAdded:Wait()
    freezeCharacter(char, false)
    camera.CameraType = Enum.CameraType.Custom
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
end

-- Public API
function FreeCam:Enable() enableInternal() end
function FreeCam:Disable() disableInternal() end
function FreeCam:Toggle()
    if self._enabled then self:Disable() else self:Enable() end
end
function FreeCam:SetSpeed(v)
    self._baseSpeed = math.clamp(tonumber(v) or self._baseSpeed, self._minSpeed, self._maxSpeed)
end
function FreeCam:GetState() return self._enabled end

-- Input handling для переміщення без toggle через F
local function registerInputHandling()
    if inputBeganConn or inputEndedConn then return end

    inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local name = input.KeyCode.Name
            if moveKeys[name] ~= nil then moveKeys[name] = true end
        end
    end)

    inputEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local name = input.KeyCode.Name
            if moveKeys[name] ~= nil then moveKeys[name] = false end
        end
    end)
end

local function unregisterInputHandling()
    if inputBeganConn then inputBeganConn:Disconnect() inputBeganConn = nil end
    if inputEndedConn then inputEndedConn:Disconnect() inputEndedConn = nil end
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
end

function FreeCam:Init(section)
    FreeCam._baseSpeed = 32
    registerInputHandling()

    -- Toggle в UI
    pcall(function()
        if section and section.NewToggle then
            section:NewToggle("FreeCam", "Enable/Disable FreeCam", function(val)
                if val then
                    FreeCam:Enable()
                else
                    FreeCam:Disable()
                end
            end, FreeCam._enabled)
        end
    end)

    -- Slider для швидкості
    pcall(function()
        if section and section.NewSlider then
            section:NewSlider("Speed", "FreeCam speed", FreeCam._minSpeed, FreeCam._maxSpeed, FreeCam._baseSpeed, function(val)
                FreeCam:SetSpeed(val)
            end)
        end
    end)
end

function FreeCam:Shutdown()
    disableInternal()
    unregisterInputHandling()
end

return FreeCam
