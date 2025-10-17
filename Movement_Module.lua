local MovementModule = {}

-- Сервіси та змінні
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

-- Локальні змінні стану
local infiniteJumpEnabled = false
local jumpConnection = nil

local function onJumpRequest()
	if infiniteJumpEnabled then
		local char = Player.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end

-- Ініціалізація UI
function MovementModule:Init(section)
	-- Walkspeed
	section:NewTextBox("Walkspeed", "Enter new walk speed and press Enter", function(text)
		local speed = tonumber(text)
		if speed and speed > 0 then
			local char = Player.Character
			if char and char:FindFirstChildOfClass("Humanoid") then
				char.Humanoid.WalkSpeed = speed
			end
		end
	end)
	
	-- Infinite Jump
	section:NewToggle("Infinite Jump", "Allows you to jump endlessly", function(enabled)
		infiniteJumpEnabled = enabled
		if enabled and not jumpConnection then
			jumpConnection = UserInputService.JumpRequest:Connect(onJumpRequest)
		elseif not enabled and jumpConnection then
			jumpConnection:Disconnect()
			jumpConnection = nil
		end
	end)
end

-- Очищення при виході
function MovementModule:Shutdown()
	if jumpConnection then
		jumpConnection:Disconnect()
		jumpConnection = nil
	end
end

return MovementModule
