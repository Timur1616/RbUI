-- Телепортер для вкладки Teleport у твоєму головному меню
local TeleportModule = {}

function TeleportModule:Init(section)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local showCoords = false
    local coordsLabel = section:NewLabel("Coordinates: (Off)")

    -- Поле для введення координат
    section:NewTextBox("Teleport to (X, Y, Z)", "Введіть координати", function(text)
        local coords = string.split(text, ",")
        if #coords == 3 then
            local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
            if x and y and z then
                humanoidRootPart.CFrame = CFrame.new(x, y, z)
            end
        end
    end)

    -- Кнопки
    section:NewButton("Studs Forward", "Телепортує на 10 студів вперед", function()
        humanoidRootPart.CFrame *= CFrame.new(0, 0, -10)
    end)

    section:NewButton("Teleport Forward (50)", "Телепортує на 50 студів вперед", function()
        humanoidRootPart.CFrame *= CFrame.new(0, 0, -50)
    end)

    section:NewButton("Copy Coords", "Копіює поточні координати", function()
        local pos = humanoidRootPart.Position
        setclipboard(string.format("%d, %d, %d", pos.X, pos.Y, pos.Z))
    end)

    section:NewToggle("Show Coords", "Показує поточні координати", function(state)
        showCoords = state
    end)

    -- Оновлення координат
    game:GetService("RunService").RenderStepped:Connect(function()
        if showCoords and humanoidRootPart then
            local pos = humanoidRootPart.Position
            coordsLabel.Text = string.format("Coordinates: (%d, %d, %d)", pos.X, pos.Y, pos.Z)
        elseif not showCoords then
            coordsLabel.Text = "Coordinates: (Off)"
        end
    end)
end

return TeleportModule
