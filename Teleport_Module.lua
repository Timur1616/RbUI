local player = game.Players.LocalPlayer

local Teleport_Module = {}

function Teleport_Module.Create()
	if player.PlayerGui:FindFirstChild("TeleportGUI") then return end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 300, 0, 220)
	mainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleText = Instance.new("TextLabel")
	titleText.Size = UDim2.new(1, -30, 1, 0)
	titleText.Position = UDim2.new(0, 5, 0, 0)
	titleText.BackgroundTransparency = 1
	titleText.Text = "Teleport Menu"
	titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleText.TextXAlignment = Enum.TextXAlignment.Left
	titleText.Parent = titleBar

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 1, 0)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
	closeButton.BackgroundTransparency = 1
	closeButton.Parent = titleBar

	local forwardBox = Instance.new("TextBox")
	forwardBox.Size = UDim2.new(0, 100, 0, 30)
	forwardBox.Position = UDim2.new(0, 10, 0, 50)
	forwardBox.PlaceholderText = "Studs Forward"
	forwardBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	forwardBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	forwardBox.ClearTextOnFocus = false
	forwardBox.Parent = mainFrame

	local forwardButton = Instance.new("TextButton")
	forwardButton.Size = UDim2.new(0, 100, 0, 30)
	forwardButton.Position = UDim2.new(0, 120, 0, 50)
	forwardButton.Text = "Teleport Forward"
	forwardButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	forwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	forwardButton.Parent = mainFrame

	local coordBox = Instance.new("TextBox")
	coordBox.Size = UDim2.new(0, 260, 0, 30)
	coordBox.Position = UDim2.new(0, 10, 0, 100)
	coordBox.PlaceholderText = "(X, Y, Z)"
	coordBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	coordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	coordBox.ClearTextOnFocus = false
	coordBox.Parent = mainFrame

	local coordButton = Instance.new("TextButton")
	coordButton.Size = UDim2.new(0, 260, 0, 30)
	coordButton.Position = UDim2.new(0, 10, 0, 140)
	coordButton.Text = "Teleport To Coordinates"
	coordButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	coordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	coordButton.Parent = mainFrame

	local coordDisplay = Instance.new("TextLabel")
	coordDisplay.Size = UDim2.new(0, 260, 0, 30)
	coordDisplay.Position = UDim2.new(0, 10, 0, 180)
	coordDisplay.Text = "Coordinates: (Off)"
	coordDisplay.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	coordDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
	coordDisplay.Parent = mainFrame

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 100, 0, 25)
	toggleButton.Position = UDim2.new(0, 10, 0, 215)
	toggleButton.Text = "Show Coords: OFF"
	toggleButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleButton.Parent = mainFrame

	local copyButton = Instance.new("TextButton")
	copyButton.Size = UDim2.new(0, 140, 0, 25)
	copyButton.Position = UDim2.new(0, 130, 0, 215)
	copyButton.Text = "Copy Coords"
	copyButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
	copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	copyButton.Parent = mainFrame

	local function getHRP()
		local char = player.Character or player.CharacterAdded:Wait()
		return char:WaitForChild("HumanoidRootPart")
	end

	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	forwardButton.MouseButton1Click:Connect(function()
		local studs = tonumber(forwardBox.Text)
		if studs then
			local hrp = getHRP()
			hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -math.floor(studs))
		end
	end)

	coordButton.MouseButton1Click:Connect(function()
		local text = coordBox.Text
		if text and text ~= "" then
			local nums = {}
			for num in string.gmatch(text, "-?%d+") do
				table.insert(nums, tonumber(num))
			end
			if #nums == 3 then
				local hrp = getHRP()
				hrp.CFrame = CFrame.new(nums[1], nums[2], nums[3])
			end
		end
	end)

	local show = false
	toggleButton.MouseButton1Click:Connect(function()
		show = not show
		toggleButton.Text = show and "Show Coords: ON" or "Show Coords: OFF"
	end)

	task.spawn(function()
		while screenGui.Parent do
			task.wait(0.2)
			if show then
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local pos = hrp.Position
					coordDisplay.Text = "Coordinates: ("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")"
				end
			else
				coordDisplay.Text = "Coordinates: (Off)"
			end
		end
	end)

	copyButton.MouseButton1Click:Connect(function()
		local hrp = getHRP()
		local pos = hrp.Position
		setclipboard("("..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z)..")")
	end)
end

return Teleport_Module
