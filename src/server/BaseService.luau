-- BaseService: the six safehouses and their stands.
-- The first player to join claims the first free base. Each base holds
-- up to eight stand slots, of which the player starts with four and can
-- buy more. A stand holds one brainrot: the model sits on the slot, a
-- Sell prompt lets the owner cash it out, and a Take prompt lets anyone
-- else try to steal it (or lets the owner place a carried brainrot).

local Players = game:GetService("Players")

local World = require(script.Parent:WaitForChild("World"))

local BaseService = {}

local ctx = nil
local owners = {}
local playerBase = {}
local standCount = {}

-- The model's Body sits this far above its base.
local PIVOT_LIFT = 1.5

-- How many stands of this base the player may use right now.
local function usableStands(player)
	return standCount[player] or ctx.data.START_STANDS
end

-- Hide the stand slots a player has not bought yet.
local function refreshStands(player)
	local baseIndex = playerBase[player]
	if not baseIndex then
		return
	end
	local allowed = usableStands(player)
	for i, slot in ipairs(ctx.world.bases[baseIndex].stands) do
		slot.pad.Transparency = if i <= allowed then 0 else 0.7
	end
end

-- Give the joining player the first base nobody owns yet.
local function assign(player)
	for i, base in ipairs(ctx.world.bases) do
		if not owners[i] then
			owners[i] = player
			playerBase[player] = i
			standCount[player] = ctx.data.START_STANDS
			local gui = base.sign:FindFirstChild("SignGui")
			if gui then
				gui.SignText.Text = player.Name .. "'s Base"
			end
			refreshStands(player)
			return i
		end
	end
	return nil
end

-- The first free, usable stand slot of the player's base, or nil.
function BaseService.freeStand(player)
	local baseIndex = playerBase[player]
	if not baseIndex then
		return nil
	end
	local allowed = usableStands(player)
	for i, slot in ipairs(ctx.world.bases[baseIndex].stands) do
		if i <= allowed and not slot.occupant then
			return { baseIndex = baseIndex, slotIndex = i, slot = slot }
		end
	end
	return nil
end

-- Set a brainrot model onto a stand slot and record who owns it.
function BaseService.placeOnStand(player, slotRef, entry, mutation, model)
	local slot = slotRef.slot
	local surfaceY = slot.position.Y
	model:PivotTo(CFrame.new(slot.position.X, surfaceY + PIVOT_LIFT, slot.position.Z))
	model.Parent = workspace
	slot.occupant = { entry = entry, mutation = mutation, model = model, owner = player, baseIndex = slotRef.baseIndex, slotIndex = slotRef.slotIndex }
end

-- Sell the brainrot on one of the player's own stands for half its price.
local function sellFromStand(player, baseIndex, slotIndex)
	local base = ctx.world.bases[baseIndex]
	if not base then
		return
	end
	local slot = base.stands[slotIndex]
	if not slot or not slot.occupant then
		return
	end
	if slot.occupant.owner ~= player then
		ctx.remotes.Announce:FireClient(player, "That brainrot is not yours to sell.", "error")
		return
	end
	local entry = slot.occupant.entry
	local refund = math.floor(entry.price * ctx.data.SELL_RATE)
	slot.occupant.model:Destroy()
	slot.occupant = nil
	ctx.money.earn(player, refund)
	ctx.remotes.Announce:FireClient(player, "Sold " .. entry.name .. " for $" .. tostring(refund) .. ".", "good")
end

-- Buy one more stand, if the player can afford it and has room.
local function upgrade(player)
	local baseIndex = playerBase[player]
	if not baseIndex then
		return
	end
	local current = usableStands(player)
	if current >= ctx.data.MAX_STANDS then
		ctx.remotes.Announce:FireClient(player, "Your base already has the maximum stands.", "error")
		return
	end
	local cost = ctx.data.upgradeCost(current)
	if ctx.money.getCash(player) < cost then
		ctx.remotes.Announce:FireClient(player, "Upgrade costs $" .. tostring(cost) .. ".", "error")
		return
	end
	ctx.money.spend(player, cost)
	standCount[player] = current + 1
	refreshStands(player)
	ctx.remotes.Announce:FireClient(player, "Base upgraded! You now have " .. tostring(current + 1) .. " stands.", "good")
end

-- The base this player owns, or nil.
function BaseService.getBase(player)
	return playerBase[player]
end

-- The player who owns this base, or nil.
function BaseService.getOwner(baseIndex)
	return owners[baseIndex]
end

function BaseService.start(context)
	ctx = context

	-- One Sell prompt and one Take prompt on every stand disc.
	for baseIndex, base in ipairs(ctx.world.bases) do
		for slotIndex, slot in ipairs(base.stands) do
			local sellPrompt = World.makePrompt(slot.pad, "Brainrot", "Sell", 0)
			sellPrompt.Triggered:Connect(function(player)
				sellFromStand(player, baseIndex, slotIndex)
			end)
			local takePrompt = World.makePrompt(slot.pad, "Brainrot", "Steal / Place", 0)
			takePrompt.Triggered:Connect(function(player)
				ctx.steal.tryTake(player, baseIndex, slotIndex)
			end)
		end
	end

	Players.PlayerAdded:Connect(assign)
	for _, player in ipairs(Players:GetPlayers()) do
		assign(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		local baseIndex = playerBase[player]
		if baseIndex then
			owners[baseIndex] = nil
		end
		playerBase[player] = nil
		standCount[player] = nil
	end)

	ctx.remotes.UpgradeRequest.OnServerEvent:Connect(upgrade)
end

return BaseService
