-- Menu: the character index and the rebirth panel.
-- One toggleable panel that lists every brainrot in the catalogue with
-- its rarity, price, income and caption, plus a short section on what a
-- rebirth costs and what it pays. Built once, shown and hidden on demand.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Data = require(Shared:WaitForChild("BrainrotData"))

local Menu = {}

local frame = nil
local visible = false

local function tierColor(tier)
	if tier == "Common" then
		return Color3.fromRGB(200, 200, 200)
	elseif tier == "Rare" then
		return Color3.fromRGB(90, 160, 255)
	elseif tier == "Epic" then
		return Color3.fromRGB(180, 100, 255)
	elseif tier == "Legendary" then
		return Color3.fromRGB(255, 180, 40)
	end
	return Color3.fromRGB(255, 90, 200)
end

local function build()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "BlitzMenu"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	frame = Instance.new("Frame")
	frame.Name = "IndexFrame"
	frame.Size = UDim2.new(0, 460, 0, 520)
	frame.Position = UDim2.new(0.5, -230, 0.5, -260)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = Color3.fromRGB(90, 140, 220)
	frame.Visible = false
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundTransparency = 1
	title.Text = "BRAINROT INDEX"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = frame

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -16, 1, -110)
	list.Position = UDim2.new(0, 8, 0, 52)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.CanvasSize = UDim2.new(0, 0, 0, #Data.CHARACTERS * 62 + 90)
	list.Parent = frame

	local y = 0
	for _, entry in ipairs(Data.CHARACTERS) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -8, 0, 56)
		row.Position = UDim2.new(0, 4, 0, y)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		row.BorderSizePixel = 0
		row.Parent = list

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -12, 0, 26)
		nameLabel.Position = UDim2.new(0, 6, 0, 2)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = entry.name .. "  (" .. entry.tier .. ")"
		nameLabel.TextColor3 = tierColor(entry.tier)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local infoLabel = Instance.new("TextLabel")
		infoLabel.Size = UDim2.new(1, -12, 0, 22)
		infoLabel.Position = UDim2.new(0, 6, 0, 30)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Text = "$" .. tostring(entry.price) .. "   $" .. tostring(entry.income) .. "/s   —  " .. entry.caption
		infoLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
		infoLabel.Font = Enum.Font.Gotham
		infoLabel.TextSize = 14
		infoLabel.TextXAlignment = Enum.TextXAlignment.Left
		infoLabel.Parent = row

		y += 62
	end

	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Size = UDim2.new(1, -16, 0, 70)
	rebirthLabel.Position = UDim2.new(0, 8, 0, y + 8)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.Text = "REBIRTH: pay $12,000 x (rebirths + 1) to multiply ALL income by 1.5x forever. Mutations: Gold (2x) and Diamond (3x) spawn rarely."
	rebirthLabel.TextColor3 = Color3.fromRGB(255, 220, 90)
	rebirthLabel.Font = Enum.Font.Gotham
	rebirthLabel.TextSize = 14
	rebirthLabel.TextWrapped = true
	rebirthLabel.Parent = list

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 120, 0, 40)
	close.Position = UDim2.new(0.5, -60, 1, -50)
	close.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
	close.Text = "CLOSE"
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.GothamBold
	close.TextScaled = true
	close.Parent = frame
	close.MouseButton1Click:Connect(function()
		Menu.toggle()
	end)
end

function Menu.toggle()
	if not frame then
		build()
	end
	visible = not visible
	frame.Visible = visible
end

return Menu
