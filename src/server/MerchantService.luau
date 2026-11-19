-- MerchantService: the travelling merchant by the conveyor.
-- A friendly seller stands at the stall near the belt and offers a
-- random brainrot for a premium over its usual price. Buying from the
-- merchant works like buying from the belt: it needs cash and a free
-- stand, and the brainrot goes straight onto the stand.

local Server = game:GetService("ServerScriptService")

local Models = require(Server:WaitForChild("BrainrotModels"))

local MerchantService = {}

local ctx = nil
-- The merchant charges half again over the belt price.
local MARKUP = 1.5

-- Build the merchant: a stout figure in an apron and a wide hat.
local function buildMerchant(spot)
	local npc = Instance.new("Model")
	npc.Name = "Merchant"

	local function part(name, shape, size, color, position)
		local p = Instance.new("Part")
		p.Name = name
		p.Shape = shape
		p.Size = size
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.Position = position
		p.Parent = npc
		return p
	end

	part("Body", Enum.PartType.Block, Vector3.new(2.4, 2.6, 1.6), Color3.fromRGB(240, 230, 210), spot + Vector3.new(0, 1.3, 0))
	part("Apron", Enum.PartType.Block, Vector3.new(2.0, 2.0, 0.3), Color3.fromRGB(60, 120, 60), spot + Vector3.new(0, 1.4, -0.9))
	part("Head", Enum.PartType.Ball, Vector3.new(1.8, 1.8, 1.8), Color3.fromRGB(240, 200, 150), spot + Vector3.new(0, 3.5, 0))
	part("HatTop", Enum.PartType.Cylinder, Vector3.new(0.5, 2.6, 0.5), Color3.fromRGB(120, 80, 40), spot + Vector3.new(0, 4.6, 0))
	part("HatBrim", Enum.PartType.Cylinder, Vector3.new(0.3, 3.6, 0.3), Color3.fromRGB(120, 80, 40), spot + Vector3.new(0, 4.3, 0))
	part("EyeLeft", Enum.PartType.Ball, Vector3.new(0.3, 0.3, 0.2), Color3.fromRGB(0, 0, 0), spot + Vector3.new(-0.4, 3.6, -0.9))
	part("EyeRight", Enum.PartType.Ball, Vector3.new(0.3, 0.3, 0.2), Color3.fromRGB(0, 0, 0), spot + Vector3.new(0.4, 3.6, -0.9))
	part("Moustache", Enum.PartType.Block, Vector3.new(1.0, 0.25, 0.2), Color3.fromRGB(60, 40, 20), spot + Vector3.new(0, 3.1, -0.95))

	-- A floating label so players can find the seller.
	local anchor = part("LabelAnchor", Enum.PartType.Block, Vector3.new(1, 1, 1), Color3.fromRGB(0, 0, 0), spot + Vector3.new(0, 5.6, 0))
	anchor.Transparency = 1
	local gui = Instance.new("BillboardGui")
	gui.Name = "MerchantLabel"
	gui.Size = UDim2.new(0, 140, 0, 40)
	gui.AlwaysOnTop = true
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "MERCHANT"
	label.TextColor3 = Color3.fromRGB(255, 220, 80)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui

	npc.PrimaryPart = npc:FindFirstChild("Body")
	npc.Parent = workspace
	return npc
end

-- Sell one random brainrot to the player at the merchant's price.
local function buyFromMerchant(player)
	local entry = ctx.data.randomCharacter()
	local price = math.floor(entry.price * MARKUP)
	if ctx.money.getCash(player) < price then
		ctx.remotes.Announce:FireClient(player, "The merchant wants $" .. tostring(price) .. " for a " .. entry.name .. ".", "error")
		return
	end
	local slot = ctx.bases.freeStand(player)
	if not slot then
		ctx.remotes.Announce:FireClient(player, "No free stand! Upgrade your base first.", "error")
		return
	end
	ctx.money.spend(player, price)
	local mutation = ctx.data.rollMutation()
	local model = Models.build(entry, mutation)
	ctx.bases.placeOnStand(player, slot, entry, mutation, model)
	ctx.remotes.Announce:FireClient(player, "The merchant sold you " .. entry.name .. " for $" .. tostring(price) .. "!", "good")
end

function MerchantService.start(context)
	ctx = context
	local npc = buildMerchant(ctx.world.merchantSpot)
	local body = npc:FindFirstChild("Body")
	if body then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = "Merchant"
		prompt.ActionText = "Buy random brainrot"
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = body
		prompt.Triggered:Connect(buyFromMerchant)
	end
end

return MerchantService
