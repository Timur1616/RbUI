-- FreeCam_Module.lua
-- Сучасна версія FreeCam з власним GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local FreeCam = {}
FreeCam.Enabled = false
FreeCam.Speed = 32

function FreeCam:Toggle()
    self.Enabled = not self.Enabled
    if self.Enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function FreeCam:Enable()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    end
    camera.CameraType = Enum.CameraType.Scriptable
    self.CamPos = camera.CFrame.Position
end

function FreeCam:Disable()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
        hum.JumpPower = 50
    end
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = char:FindFirstChildOfClass("Humanoid")
end

function FreeCam:Init(section)
    section:NewToggle("FreeCam", "Enable FreeCam", function(val)
        self:Toggle()
    end)
    section:NewSlider("Speed", "FreeCam speed", 5, 250, function(val)
        self.Speed = val
    end)
end

function FreeCam:Shutdown()
    if self.Enabled then
        self:Disable()
    end
end

return FreeCam
