local FlyModule = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = game:GetService("Players").LocalPlayer
local fly_nowe = false
local fly_speeds = 1
local fly_tpwalking = false

local function ResetCharacterState()
    local chr = Player.Character
    if not chr then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    fly_nowe = false
    fly_tpwalking = false
    
    for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(state, true) end
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
    
    if chr:FindFirstChild("Animate") then chr.Animate.Disabled = false end
    hum.PlatformStand = false

    for _, obj in pairs(chr:GetChildren()) do
        if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then obj:Destroy() end
    end
end

local function StartTpWalk()
    fly_tpwalking = true
    for i = 1, fly_speeds do
        task.spawn(function()
            local hb = RunService.Heartbeat
            while fly_tpwalking and hb:Wait() and Player.Character and Player.Character.Humanoid and Player.Character.Humanoid.Parent do
                local hum = Player.Character.Humanoid
                if hum.MoveDirection.Magnitude > 0 then Player.Character:TranslateBy(hum.MoveDirection) end
            end
        end)
    end
end

local function ApplyFlyPhysics(rigType)
    local chr = Player.Character
    if not chr then return end
    local part = chr:FindFirstChild(rigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")
    if not part then return end

    local bg = Instance.new("BodyGyro", part)
    bg.P, bg.MaxTorque = 9e4, Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = part.CFrame
    
    local bv = Instance.new("BodyVelocity", part)
    bv.Velocity, bv.MaxForce = Vector3.new(0, 0.1, 0), Vector3.new(9e9, 9e9, 9e9)
    chr.Humanoid.PlatformStand = true
    
    while fly_nowe and chr.Humanoid.Health > 0 do RunService.RenderStepped:Wait() end
    
    if bg and bg.Parent then bg:Destroy() end
    if bv and bv.Parent then bv:Destroy() end
end

local function ToggleFly(enabled)
    local chr = Player.Character or Player.CharacterAdded:Wait()
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    
    if enabled then
        if fly_nowe then return end
        fly_nowe = true
        for _, state in ipairs(Enum.HumanoidStateType:GetEnumItems()) do hum:SetStateEnabled(state, false) end
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
        if chr:FindFirstChild("Animate") then chr.Animate.Disabled = true end
        for i, v in next, hum:GetPlayingAnimationTracks() do v:AdjustSpeed(0) end
        StartTpWalk()
        task.spawn(function() ApplyFlyPhysics(hum.RigType) end)
    else
        if not fly_nowe then return end
        ResetCharacterState()
    end
end

function FlyModule:Init(flySection)
    flySection:NewToggle("Enable Fly", "Activates flight mode", function(toggled) ToggleFly(toggled) end)
    flySection:NewSlider("Speed", "Adjusts the speed of flight", 50, 1, function(value)
        fly_speeds = math.floor(value)
        if fly_nowe then fly_tpwalking = false; task.wait(0.05); StartTpWalk() end
    end)
end

function FlyModule:Shutdown()
    ResetCharacterState()
end

return FlyModule
