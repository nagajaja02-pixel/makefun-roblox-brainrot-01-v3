-- Game: the client side of Brainrot Blitz.
-- Builds the HUD (cash, income, rebirths, announcements and the four
-- action buttons), listens to the server for money updates and
-- announcements, and hands the carry pose and the menus to their own
-- modules.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BlitzRemotes")
local CarryPose = require(script.Parent:WaitForChild("CarryPose"))
local Menu = require(script.Parent:WaitForChild("Menu"))

local gui = Instance.new("ScreenGui")
gui.Name = "BlitzHud"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, text, size, position, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	label.BackgroundTransparency = 0.3
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	return label
end

local cashLabel = makeLabel("CashLabel", "Cash: $150", UDim2.new(0, 220, 0, 44), UDim2.new(0, 16, 0, 16), Color3.fromRGB(120, 255, 120))
local incomeLabel = makeLabel("IncomeLabel", "+$0/s", UDim2.new(0, 220, 0, 36), UDim2.new(0, 16, 0, 68), Color3.fromRGB(255, 220, 90))
local rebirthLabel = makeLabel("RebirthLabel", "Rebirths: 0", UDim2.new(0, 220, 0, 36), UDim2.new(0, 16, 0, 112), Color3.fromRGB(150, 220, 255))

-- Announcements appear in the middle of the screen and fade away.
local announceLabel = Instance.new("TextLabel")
announceLabel.Name = "AnnounceLabel"
announceLabel.Size = UDim2.new(0, 520, 0, 52)
announceLabel.Position = UDim2.new(0.5, -260, 0, 120)
announceLabel.BackgroundTransparency = 1
announceLabel.Text = ""
announceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
announceLabel.TextStrokeTransparency = 0
announceLabel.Font = Enum.Font.GothamBold
announceLabel.TextScaled = true
announceLabel.Parent = gui

local function makeButton(name, text, position, onClick)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 150, 0, 46)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(40, 90, 160)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamBold
	button.TextScaled = true
	button.Parent = gui
	button.MouseButton1Click:Connect(onClick)
	return button
end

makeButton("ShieldButton", "SHIELD", UDim2.new(1, -166, 0, 16), function()
	remotes.ShieldRequest:FireServer()
end)
makeButton("UpgradeButton", "UPGRADE", UDim2.new(1, -166, 0, 70), function()
	remotes.UpgradeRequest:FireServer()
end)
makeButton("RebirthButton", "REBIRTH", UDim2.new(1, -166, 0, 124), function()
	remotes.RebirthRequest:FireServer()
end)
makeButton("IndexButton", "INDEX", UDim2.new(1, -166, 0, 178), function()
	Menu.toggle()
end)

-- A hint line at the bottom so a new player knows what to do first.
makeLabel("HintLabel", "Click a brainrot on the belt to buy it!", UDim2.new(0, 420, 0, 34), UDim2.new(0.5, -210, 1, -50), Color3.fromRGB(255, 255, 255))

-- Money updates from the server.
remotes.CashChanged.OnClientEvent:Connect(function(cash, income, rebirths)
	cashLabel.Text = "Cash: $" .. tostring(cash)
	incomeLabel.Text = "+$" .. tostring(income) .. "/s"
	rebirthLabel.Text = "Rebirths: " .. tostring(rebirths)
end)

-- Announcements from the server, coloured by kind.
remotes.Announce.OnClientEvent:Connect(function(text, kind)
	if kind == "error" then
		announceLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
	elseif kind == "warn" then
		announceLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
	elseif kind == "good" then
		announceLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
	else
		announceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
	announceLabel.Text = text
	task.delay(4, function()
		if announceLabel.Text == text then
			announceLabel.Text = ""
		end
	end)
end)

-- The server tells the client when a carry starts or ends.
remotes.CarryState.OnClientEvent:Connect(function(carrying)
	CarryPose.setCarrying(carrying)
end)
