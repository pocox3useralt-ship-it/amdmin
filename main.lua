```lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- UI Layout
local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 5)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Admin Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = mainFrame

-- Commands container
local commandsFrame = Instance.new("Frame")
commandsFrame.Size = UDim2.new(1, -20, 1, -60)
commandsFrame.BackgroundTransparency = 1
commandsFrame.Parent = mainFrame
commandsFrame.Position = UDim2.new(0, 10, 0, 50)

local commandsLayout = Instance.new("UIListLayout")
commandsLayout.Padding = UDim.new(0, 5)
commandsLayout.SortOrder = Enum.SortOrder.LayoutOrder
commandsLayout.Parent = commandsFrame

-- Helper function to create buttons with cogwheel icon
local function createCommandButton(commandName, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 40)
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 18
	button.Text = commandName
	button.AutoButtonColor = true
	button.Parent = commandsFrame

	-- Cogwheel icon button
	local cogButton = Instance.new("ImageButton")
	cogButton.Size = UDim2.new(0, 24, 0, 24)
	cogButton.Position = UDim2.new(1, -30, 0.5, -12)
	cogButton.BackgroundTransparency = 1
	cogButton.Image = "rbxassetid://6031094678" -- cogwheel icon
	cogButton.Parent = button

	cogButton.MouseButton1Click:Connect(function()
		callback()
	end)

	return button
end

-- Command implementations

-- Lag command: Example [username]
local function lagCommand()
	local targetName = player.Name -- default to self if no input
	local inputBox = Instance.new("TextBox")
	inputBox.Size = UDim2.new(1, -40, 0, 30)
	inputBox.Position = UDim2.new(0, 0, 0, 0)
	inputBox.PlaceholderText = "Enter username"
	inputBox.ClearTextOnFocus = false
	inputBox.Text = ""
	inputBox.Parent = mainFrame

	local confirmButton = Instance.new("TextButton")
	confirmButton.Size = UDim2.new(0, 40, 0, 30)
	confirmButton.Position = UDim2.new(1, -40, 0, 0)
	confirmButton.Text = "OK"
	confirmButton.Font = Enum.Font.GothamBold
	confirmButton.TextSize = 18
	confirmButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmButton.Parent = mainFrame

	local function cleanup()
		inputBox:Destroy()
		confirmButton:Destroy()
	end

	confirmButton.MouseButton1Click:Connect(function()
		local targetText = inputBox.Text
		if targetText ~= "" then
			targetName = targetText
		end
		cleanup()

		local targetPlayer = Players:FindFirstChild(targetName)
		if targetPlayer then
			-- Lag simulation: spawn a loop that creates many parts around the target player's character to cause lag
			local char = targetPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local root = char.HumanoidRootPart
				for i = 1, 50 do
					local part = Instance.new("Part")
					part.Size = Vector3.new(1,1,1)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 0.5
					part.Color = Color3.fromRGB(255, 0, 0)
					part.CFrame = root.CFrame * CFrame.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
					part.Parent = workspace
					game.Debris:AddItem(part, 10)
				end
			end
		end
	end)
end

-- Other admin commands (excluding ban and kick)
local commands = {
	["Lag"] = lagCommand,
	["Freeze"] = function()
		local target = Players:GetPlayers()[1]
		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			target.Character.Humanoid.WalkSpeed = 0
		end
	end,
	["Unfreeze"] = function()
		local target = Players:GetPlayers()[1]
		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			target.Character.Humanoid.WalkSpeed = 16
		end
	end,
	["Teleport To Me"] = function()
		local target = Players:GetPlayers()[1]
		if target and target.Character and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
				target.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(3,0,0)
			end
		end
	end,
}

-- Create buttons for commands
for cmdName, cmdFunc in pairs(commands) do
	createCommandButton(cmdName, cmdFunc)
end

-- AI Chat UI
local chatFrame = Instance.new("Frame")
chatFrame.Size = UDim2.new(1, 0, 0, 150)
chatFrame.Position = UDim2.new(0, 0, 1, -150)
chatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
chatFrame.BorderSizePixel = 0
chatFrame.Parent = screenGui

local chatTitle = Instance.new("TextLabel")
chatTitle.Size = UDim2.new(1, 0, 0, 30)
chatTitle.BackgroundTransparency = 1
chatTitle.Text = "AI Assistant"
chatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
chatTitle.Font = Enum.Font.GothamBold
chatTitle.TextSize = 20
chatTitle.Parent = chatFrame

local chatBox = Instance.new("TextBox")
chatBox.Size = UDim2.new(1, -60, 0, 30)
chatBox.Position = UDim2.new(0, 5, 0, 40)
chatBox.PlaceholderText = "Ask me anything..."
chatBox.ClearTextOnFocus = true
chatBox.Text = ""
chatBox.Font = Enum.Font.Gotham
chatBox.TextSize = 18
chatBox.Parent = chatFrame

local sendButton = Instance.new("TextButton")
sendButton.Size = UDim2.new(0, 50, 0, 30)
sendButton.Position = UDim2.new(1, -55, 0, 40)
sendButton.Text = "Send"
sendButton.Font = Enum.Font.GothamBold
sendButton.TextSize = 18
sendButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
sendButton.Parent = chatFrame

local chatLog = Instance.new("ScrollingFrame")
chatLog.Size = UDim2.new(1, -10, 1, -80)
chatLog.Position = UDim2.new(0, 5, 0, 75)
chatLog.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
chatLog.BorderSizePixel = 0
chatLog.CanvasSize = UDim2.new(0, 0, 0, 0)
chatLog.ScrollBarThickness = 6
chatLog.Parent = chatFrame

local chatLayout = Instance.new("UIListLayout")
chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
