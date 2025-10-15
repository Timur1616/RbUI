local TeleporterModule = {}
local player = game.Players.LocalPlayer

local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local showCoords = false
local coordThread

function TeleporterModule:Init(section)
	-- 🟢 Телепорт вперед
	section:NewButton("Teleport Forward", "Телепортує тебе вперед на вказану кількість студів", function()
		local studs = tonumber(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("TeleportStuds") or 10)
		local hrp = getHRP()
		if hrp and studs then
			hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -math.floor(studs))
		end
	end)

	-- 🟣 Телепорт за координатами
	section:NewButton("Teleport to Coords", "Введи координати (X, Y, Z) у консоль", function()
		rconsoleprint("@@YELLOW@@\nВведи координати у форматі X Y Z та натисни Enter:\n")
		local input = rconsoleinput()
		local nums = {}
		for num in string.gmatch(input, "-?%d+") do
			table.insert(nums, tonumber(num))
		end
		if #nums == 3 then
			local hrp = getHRP()
			hrp.CFrame = CFrame.new(nums[1], nums[2], nums[3])
			rconsoleprint("@@GREEN@@\nТелепортовано до ("..table.concat(nums, ", ")..")\n")
		else
			rconsoleprint("@@RED@@\nНевірний формат координат!\n")
		end
	end)

	-- 🟡 Показ координат
	section:NewToggle("Show Coords", "Показує твої поточні координати у консолі", function(state)
		showCoords = state
		if state then
			rconsoleprint("@@LIGHT_BLUE@@\n[Teleport] Координати активні. Натисни ще раз щоб вимкнути.\n")
			coordThread = task.spawn(function()
				while showCoords do
					local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						local pos = hrp.Position
						rconsoleprint(string.format("@@LIGHT_GREY@@X: %d, Y: %d, Z: %d\n", pos.X, pos.Y, pos.Z))
					end
					task.wait(1)
				end
			end)
		else
			if coordThread then task.cancel(coordThread) end
			rconsoleprint("@@RED@@\n[Teleport] Координати вимкнено.\n")
		end
	end)

	-- 🔵 Копіювати координати
	section:NewButton("Copy Coords", "Копіює твої координати в буфер обміну", function()
		local hrp = getHRP()
		local pos = hrp.Position
		setclipboard("("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")")
		rconsoleprint("@@CYAN@@\nКоординати скопійовано у буфер обміну!\n")
	end)
end

function TeleporterModule:Shutdown()
	showCoords = false
	if coordThread then task.cancel(coordThread) end
end

return TeleporterModule
