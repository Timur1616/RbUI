
local TeleportModule = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local showCoords = false
local coordsLabel = nil
local fastTeleportActive = false
local targetPlayerName = nil
local dropdown = nil
local clickTeleportEnabled = false
local clickTpConnection = nil
local function getHumanoidRootPart(p)
    local character = p and p.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end


local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    return names
end

local function onClickToTeleport(input, gameProcessed)
    if gameProcessed or not clickTeleportEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local hrp = getHumanoidRootPart(player)
        local mouse = player:GetMouse()
        if hrp and mouse.Target and mouse.Target:IsA("BasePart") then
            hrp.CFrame = CFrame.new(mouse.Hit.p)
        end
    end
end

function TeleportModule:Init(section)

    section:NewLabel("Teleport to Player:")

    dropdown = section:NewDropdown("Select Player", "Оберіть гравця для телепортації", getPlayerNames(), function(selectedPlayer)
        targetPlayerName = selectedPlayer
    end)

    section:NewButton("Teleport to Player", "Телепортуватися до обраного гравця", function()
        if targetPlayerName then
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer then
                local localHRP = getHumanoidRootPart(player)
                local targetHRP = getHumanoidRootPart(targetPlayer)
                if localHRP and targetHRP then
                    pcall(function() localHRP.CFrame = targetHRP.CFrame end)
                end
            end
        end
    end)

    section:NewToggle("Fast Teleport to Player", "Постійно телепортуватися до обраного гравця", function(state)
        fastTeleportActive = state
    end)


    section:NewLabel("Special Teleports:")

    section:NewToggle("Click to Teleport", "Телепортує вас туди, куди ви клікнете", function(enabled)
		clickTeleportEnabled = enabled
        if enabled and not clickTpConnection then
            clickTpConnection = UserInputService.InputBegan:Connect(onClickToTeleport)
        elseif not enabled and clickTpConnection then
            clickTpConnection:Disconnect()
            clickTpConnection = nil
        end
	end)

	section:NewButton("Ultra Instinct", "Телепортуватися за спину найближчого гравця", function()
		local closestPlayer, closestDistance = nil, 50 
		local localHRP = getHumanoidRootPart(player)
		if not localHRP then return end
		
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= player then
                local targetHRP = getHumanoidRootPart(otherPlayer)
				if targetHRP then
                    local distance = (localHRP.Position - targetHRP.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = otherPlayer
                    end
                end
			end
		end
		
		if closestPlayer then
			local targetHRP = getHumanoidRootPart(closestPlayer)
			local behindPosition = targetHRP.CFrame * CFrame.new(0, 0, 4) 
			localHRP.CFrame = CFrame.new(behindPosition.Position, targetHRP.Position)
		end
	end)

    section:NewLabel("Coords & Position:")

    section:NewTextBox("Teleport (X,Y,Z)", "Введіть координати, напр. 100, 50, -200", function(text)
        local hrp = getHumanoidRootPart(player)
        if not hrp then return end
        local coords = {}
        for num in text:gmatch("[-?%d%.]+") do 
            table.insert(coords, tonumber(num))
        end
        if #coords == 3 then
            pcall(function() hrp.CFrame = CFrame.new(coords[1], coords[2], coords[3]) end)
        end
    end)

    section:NewButton("Teleport Forward (50 studs)", "Телепортує вас вперед на 50 студів", function()
        local hrp = getHumanoidRootPart(player)
        if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -50) end
    end)

    section:NewButton("Copy Coords", "Копіює ваші поточні координати", function()
        local hrp = getHumanoidRootPart(player)
        if hrp then
            pcall(function() setclipboard(string.format("%.0f, %.0f, %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)) end)
        end
    end)

    section:NewToggle("Show Coords", "Показує ваші поточні координати", function(state)
        showCoords = state
        if not state and coordsLabel then coordsLabel:UpdateLabel("Coordinates: (Off)") end
    end)

    coordsLabel = section:NewLabel("Coordinates: (Off)")

    local function refreshPlayerList()
        if dropdown then dropdown:Refresh(getPlayerNames()) end
    end
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)

    RunService.RenderStepped:Connect(function()
        if fastTeleportActive and targetPlayerName then
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer then
                local localHRP = getHumanoidRootPart(player)
                local targetHRP = getHumanoidRootPart(targetPlayer)
                if localHRP and targetHRP then localHRP.CFrame = targetHRP.CFrame end
            else
                fastTeleportActive = false; targetPlayerName = nil
            end
        end

        if showCoords and coordsLabel then
            local hrp = getHumanoidRootPart(player)
            if hrp then
                local pos = hrp.Position
                coordsLabel:UpdateLabel(string.format("Coords: (%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z))
            else
                coordsLabel:UpdateLabel("Coordinates: (No Character)")
            end
        end
    end)
end

function TeleportModule:Shutdown()
    fastTeleportActive = false
    showCoords = false
    if clickTpConnection then
        clickTpConnection:Disconnect()
        clickTpConnection = nil
    end
end

return TeleportModule
