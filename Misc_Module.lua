local MiscModule = {}

local RunService = game:GetService("RunService")
local Player = game:GetService("Players").LocalPlayer

local floatEnabled = false
local bodyVelocity = nil
local floatConnection = nil

local function updateFloat()
    local char = Player.Character
    if floatEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not bodyVelocity or bodyVelocity.Parent ~= hrp then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = hrp
        end
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    elseif (not floatEnabled or not char) and bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

function MiscModule:Init(section)

	section:NewButton("Platform", "Spawns a platform under you", function()
		local char = Player.Character
		if not char or not char.PrimaryPart then return end
		
		local platform = Instance.new("Part")
		platform.Size = Vector3.new(10, 1, 10)
		platform.Position = char.PrimaryPart.Position - Vector3.new(0, 4, 0)
		platform.Anchored = true
		platform.Color = Color3.fromRGB(29, 29, 32)
		platform.Material = Enum.Material.SmoothPlastic
		platform.Parent = workspace
		game:GetService("Debris"):AddItem(platform, 15)
	end)


	section:NewToggle("Float", "Makes you float in the air", function(enabled)
		floatEnabled = enabled
        if enabled and not floatConnection then
            floatConnection = RunService.Heartbeat:Connect(updateFloat)
        elseif not enabled and floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil; end
        end
	end)

	section:NewTextBox("Fake Chat", "Send a message as if you typed it", function(text)
		if text ~= "" then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
            end)
		end
	end)
end

function MiscModule:Shutdown()
    if floatConnection then
        floatConnection:Disconnect()
        floatConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

return MiscModule
