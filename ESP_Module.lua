local ESPModule = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local esp_settings = {
    Enabled = true, ShowNames = true, ShowOutline = true,
    ShowFill = false, ShowLines = false, TeamColor = false, Font = 2
}
local ESPCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Connection then ESPCache[player].Connection:Disconnect() end
        if ESPCache[player].Highlight and ESPCache[player].Highlight.Parent then ESPCache[player].Highlight:Destroy() end
        if ESPCache[player].NameLabel then ESPCache[player].NameLabel:Remove() end
        if ESPCache[player].Line then ESPCache[player].Line:Remove() end
        ESPCache[player] = nil
    end
end

function UpdateAllESP()
    for player, esp in pairs(ESPCache) do
        if esp and esp.Highlight then esp.Highlight.Enabled = esp_settings.Enabled end
    end
end

local function CreateESP(player)
    if ESPCache[player] or player == Player then return end
    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        if not character or not character.Parent then return end
        local esp = { Highlight = Instance.new("Highlight"), NameLabel = Drawing.new("Text"), Line = Drawing.new("Line"), Connection = nil }
        esp.Highlight.Parent, esp.Highlight.FillTransparency, esp.Highlight.OutlineTransparency = character, 1, 1
        esp.NameLabel.Visible, esp.NameLabel.Center, esp.NameLabel.Outline, esp.NameLabel.Font, esp.NameLabel.Size, esp.NameLabel.Text = false, true, true, esp_settings.Font, 18, player.Name
        esp.Line.Visible, esp.Line.Thickness = false, 1
        ESPCache[player] = esp
        esp.Connection = RunService.RenderStepped:Connect(function()
            local chr = player.Character
            if not chr or not chr.Parent or not chr:FindFirstChild("HumanoidRootPart") then RemoveESP(player) return end
            local rootPart, head = chr.HumanoidRootPart, chr:FindFirstChild("Head")
            if rootPart and head then
                local headPos, headOnScreen = Camera:WorldToScreenPoint(head.Position)
                local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local color = esp_settings.TeamColor and player.TeamColor.Color or Color3.fromHSV(math.clamp((rootPart.Position - Camera.CFrame.Position).Magnitude / 500, 0, 1) * 0.65, 0.75, 1)
                esp.Highlight.Enabled = esp_settings.Enabled
                esp.Highlight.FillTransparency = esp_settings.ShowFill and 0.5 or 1
                esp.Highlight.OutlineTransparency = esp_settings.ShowOutline and 0 or 1
                esp.Highlight.FillColor, esp.Highlight.OutlineColor = color, color
                esp.NameLabel.Visible = esp_settings.Enabled and esp_settings.ShowNames and headOnScreen
                if esp.NameLabel.Visible then esp.NameLabel.Position, esp.NameLabel.Color = Vector2.new(headPos.X, headPos.Y - 20), color end
                local lineVisible = esp_settings.Enabled and esp_settings.ShowLines and rootPos.Z > 0
                esp.Line.Visible = lineVisible
                if lineVisible then esp.Line.From, esp.Line.To, esp.Line.Color = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), Vector2.new(rootPos.X, rootPos.Y), color end
            end
        end)
    end)
end

function ESPModule:Init(espSection)
    espSection:NewToggle("Enable ESP", "Toggles all ESP features", function(toggled) esp_settings.Enabled = toggled; UpdateAllESP() end)
    espSection:NewToggle("Show Names", "Displays player names", function(toggled) esp_settings.ShowNames = toggled end)
    espSection:NewToggle("Show Outline", "Shows a colored outline", function(toggled) esp_settings.ShowOutline = toggled end)
    espSection:NewToggle("Show Fill", "Shows a colored fill", function(toggled) esp_settings.ShowFill = toggled end)
    espSection:NewToggle("Show Lines", "Draws lines to players", function(toggled) esp_settings.ShowLines = toggled end)
    espSection:NewToggle("Use Team Colors", "Colors ESP based on teams", function(toggled) esp_settings.TeamColor = toggled end)

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function() CreateESP(player) end)
        if player.Character then CreateESP(player) end
    end)
    Players.PlayerRemoving:Connect(RemoveESP)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then CreateESP(player) end
    end
end

function ESPModule:Shutdown()
    for player in pairs(ESPCache) do
        RemoveESP(player)
    end
end

return ESPModule
