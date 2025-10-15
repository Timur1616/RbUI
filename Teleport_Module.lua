-- Телепортер для вкладки Teleport у твоєму головному меню

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local teleportTab = Instance.new("Frame")
teleportTab.Name = "TeleportTab"
teleportTab.Size = UDim2.new(1, 0, 1, 0)
teleportTab.BackgroundTransparency = 1
teleportTab.Visible = false
teleportTab.Parent = TabsFrame -- 👈 Замінити на твій контейнер вкладок

-- Стиль кнопок
local function createButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Text = text
    button.Parent = teleportTab

    button.MouseButton1Click:Connect(callback)
    return button
end

-- Поле для введення координат
local coordBox = Instance.new("TextBox")
coordBox.Size = UDim2.new(0, 200, 0, 30)
coordBox.Position = UDim2.new(0, 20, 0, 80)
coordBox.PlaceholderText = "(X, Y, Z)"
coordBox.Text = ""
coordBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
coordBox.TextColor3 = Color3.new(1, 1, 1)
coordBox.Font = Enum.Font.SourceSans
coordBox.TextSize = 18
coordBox.Parent = teleportTab

-- Кнопки
createButton("Studs Forward", UDim2.new(0, 20, 0, 30), function()
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -10)
end)

createButton("Teleport Forward", UDim2.new(0, 230, 0, 30), function()
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -50)
end)

createButton("Teleport To Coordinates", UDim2.new(0, 20, 0, 120), function()
    local coords = string.split(coordBox.Text, ",")
    if #coords == 3 then
        local x, y, z = tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3])
        if x and y and z then
            humanoidRootPart.CFrame = CFrame.new(x, y, z)
        end
    end
end)

-- Координати гравця
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Size = UDim2.new(0, 200, 0, 30)
coordsLabel.Position = UDim2.new(0, 20, 0, 160)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.new(1, 1, 1)
coordsLabel.Font = Enum.Font.SourceSansBold
coordsLabel.TextSize = 18
coordsLabel.Text = "Coordinates: (Off)"
coordsLabel.Parent = teleportTab

local showCoords = false

local showButton = createButton("Show Coords: OFF", UDim2.new(0, 20, 0, 200), function(self)
    showCoords = not showCoords
    self.Text = showCoords and "Show Coords: ON" or "Show Coords: OFF"
end)

local copyButton = createButton("Copy Coords", UDim2.new(0, 230, 0, 200), function()
    local pos = humanoidRootPart.Position
    setclipboard(string.format("%d, %d, %d", pos.X, pos.Y, pos.Z))
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
