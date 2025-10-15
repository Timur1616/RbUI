-- RbUI-main/Teleport_Module.lua
-- Повністю переписаний та покращений модуль телепортації

local TeleportModule = {}

-- Сервіси Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Локальні змінні
local player = Players.LocalPlayer
local showCoords = false
local coordsLabel = nil -- Зберігаємо посилання на лейбл для оновлення

-- Функція для безпечного отримання HumanoidRootPart
local function getHumanoidRootPart()
    local character = player.Character
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Основна функція ініціалізації модуля
function TeleportModule:Init(section)
    -- Створюємо текстове поле для введення координат
    section:NewTextBox("Teleport (X,Y,Z)", "Введіть координати через кому, напр. 100, 50, -200", function(text)
        local hrp = getHumanoidRootPart()
        if not hrp then return end -- Перевірка, чи існує персонаж

        -- Розділяємо введений текст на числа
        local coords = {}
        for num in text:gmatch("[-?%d]+") do
            table.insert(coords, tonumber(num))
        end

        -- Перевіряємо, чи маємо 3 координати
        if #coords == 3 then
            local x, y, z = coords[1], coords[2], coords[3]
            -- pcall для безпечної телепортації
            pcall(function()
                hrp.CFrame = CFrame.new(x, y, z)
            end)
        end
    end)

    -- Кнопка для телепортації вперед на 50 студів
    section:NewButton("Teleport Forward (50 studs)", "Телепортує вас вперед на 50 студів", function()
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -50)
        end
    end)

    -- Кнопка для копіювання поточних координат
    section:NewButton("Copy Coords", "Копіює ваші поточні координати у буфер обміну", function()
        local hrp = getHumanoidRootPart()
        if hrp then
            local pos = hrp.Position
            -- Використовуємо setclipboard (якщо доступно)
            local success, err = pcall(function()
                setclipboard(string.format("%.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z))
            end)
            if not success then
                warn("Не вдалося скопіювати координати:", err)
            end
        end
    end)

    -- Перемикач для відображення координат
    section:NewToggle("Show Coords", "Показує ваші поточні координати", function(state)
        showCoords = state
        if not state and coordsLabel then
            -- Одразу оновлюємо текст, коли вимикаємо
            coordsLabel:UpdateLabel("Coordinates: (Off)")
        end
    end)

    -- Створюємо лейбл для відображення координат і зберігаємо його
    coordsLabel = section:NewLabel("Coordinates: (Off)")

    -- Підключаємо оновлення координат до RenderStepped для плавності
    RunService.RenderStepped:Connect(function()
        if showCoords and coordsLabel then
            local hrp = getHumanoidRootPart()
            if hrp then
                local pos = hrp.Position
                -- Використовуємо метод UpdateLabel з вашої UI-бібліотеки
                coordsLabel:UpdateLabel(string.format("Coords: (%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z))
            else
                -- Якщо персонаж не знайдений
                coordsLabel:UpdateLabel("Coordinates: (No Character)")
            end
        end
    end)
end

-- Функція для очищення при виході (необов'язково для цього модуля, але гарна практика)
function TeleportModule:Shutdown()
    showCoords = false
    -- Тут можна було б від'єднати з'єднання RunService, але це не критично
end

return TeleportModule
