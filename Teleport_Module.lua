-- RbUI-main/Teleport_Module.lua
-- Повністю переписаний та покращений модуль телепортації з функцією телепорту до гравця

local TeleportModule = {}

-- Сервіси Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Локальні змінні
local player = Players.LocalPlayer
local showCoords = false
local coordsLabel = nil
local fastTeleportActive = false
local targetPlayerName = nil
local dropdown = nil -- Зберігаємо посилання на випадаючий список

-- Функція для безпечного отримання HumanoidRootPart
local function getHumanoidRootPart(p)
    local character = p and p.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Функція для отримання списку імен гравців
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then -- Не додаємо себе до списку
            table.insert(names, p.Name)
        end
    end
    return names
end

-- Основна функція ініціалізації модуля
function TeleportModule:Init(section)
    --[[
        ТЕЛЕПОРТАЦІЯ ДО ГРАВЦЯ
    ]]
    section:NewLabel("Teleport to Player:") -- Заголовок для нового розділу

    -- Створюємо випадаючий список для вибору гравця
    dropdown = section:NewDropdown("Select Player", "Оберіть гравця для телепортації", getPlayerNames(), function(selectedPlayer)
        targetPlayerName = selectedPlayer
    end)

    -- Кнопка для звичайної телепортації до обраного гравця
    section:NewButton("Teleport to Player", "Телепортуватися до обраного гравця", function()
        if targetPlayerName then
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer then
                local localHRP = getHumanoidRootPart(player)
                local targetHRP = getHumanoidRootPart(targetPlayer)
                if localHRP and targetHRP then
                    pcall(function()
                        localHRP.CFrame = targetHRP.CFrame
                    end)
                end
            end
        end
    end)

    -- Перемикач для "Швидкого телепорту" (постійна телепортація)
    section:NewToggle("Fast Teleport to Player", "Постійно телепортуватися до обраного гравця", function(state)
        fastTeleportActive = state
    end)

    --[[
        ТЕЛЕПОРТАЦІЯ ЗА КООРДИНАТАМИ (старий функціонал)
    ]]
    section:NewLabel("Teleport to Coords:") -- Розділювач

    section:NewTextBox("Teleport (X,Y,Z)", "Введіть координати, напр. 100, 50, -200", function(text)
        local hrp = getHumanoidRootPart(player)
        if not hrp then return end

        local coords = {}
        for num in text:gmatch("[-?%d]+") do
            table.insert(coords, tonumber(num))
        end

        if #coords == 3 then
            pcall(function()
                hrp.CFrame = CFrame.new(coords[1], coords[2], coords[3])
            end)
        end
    end)

    section:NewButton("Teleport Forward (50 studs)", "Телепортує вас вперед на 50 студів", function()
        local hrp = getHumanoidRootPart(player)
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -50)
        end
    end)

    section:NewButton("Copy Coords", "Копіює ваші поточні координати", function()
        local hrp = getHumanoidRootPart(player)
        if hrp then
            pcall(function()
                setclipboard(string.format("%.0f, %.0f, %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
            end)
        end
    end)

    section:NewToggle("Show Coords", "Показує ваші поточні координати", function(state)
        showCoords = state
        if not state and coordsLabel then
            coordsLabel:UpdateLabel("Coordinates: (Off)")
        end
    end)

    coordsLabel = section:NewLabel("Coordinates: (Off)")

    --[[
        ГЛОБАЛЬНІ ОБРОБНИКИ ДЛЯ МОДУЛЯ
    ]]
    -- Оновлення списку гравців при вході/виході
    local function refreshPlayerList()
        if dropdown then
            dropdown:Refresh(getPlayerNames())
        end
    end
    Players.PlayerAdded:Connect(refreshPlayerList)
    Players.PlayerRemoving:Connect(refreshPlayerList)

    -- Головний цикл оновлення
    RunService.RenderStepped:Connect(function()
        -- Логіка швидкого телепорту
        if fastTeleportActive and targetPlayerName then
            local targetPlayer = Players:FindFirstChild(targetPlayerName)
            if targetPlayer then
                local localHRP = getHumanoidRootPart(player)
                local targetHRP = getHumanoidRootPart(targetPlayer)
                if localHRP and targetHRP then
                    localHRP.CFrame = targetHRP.CFrame
                end
            else
                -- Якщо гравець вийшов, вимикаємо швидкий телепорт
                fastTeleportActive = false
                targetPlayerName = nil
            end
        end

        -- Логіка відображення координат
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
end

return TeleportModule
