-- StealService: carrying brainrots between bases.
-- A player can grab a brainrot off someone else's stand and carry it
-- home: the model welds in front of them while they walk, and a prompt
-- on one of their own free stands puts it down as theirs. A shielded
-- base cannot be raided. If the carrier dies or takes too long, the
-- brainrot walks itself back to the stand it came from.

local Players = game:GetService("Players")

local StealService = {}

local ctx = nil
local carrying = {}
local CARRY_TIMEOUT = 30
-- The model's Body sits this far above its base.
local PIVOT_LIFT = 1.5

-- Set every part of a model anchored or not.
local function setAnchored(model, anchored)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = anchored
		end
	end
end

-- Send a carried brainrot back to the stand it was taken from.
local function returnHome(record)
	local base = ctx.world.bases[record.fromBase]
	if not base then
		record.model:Destroy()
		return
	end
	local slot = base.stands[record.fromSlot]
	if slot and not slot.occupant then
		slot.occupant = { entry = record.entry, mutation = record.mutation, model = record.model, owner = record.fromOwner, baseIndex = record.fromBase, slotIndex = record.fromSlot }
		setAnchored(record.model, true)
		record.model:PivotTo(CFrame.new(slot.position.X, slot.position.Y + PIVOT_LIFT, slot.position.Z))
		record.model.Parent = workspace
	else
		record.model:Destroy()
	end
end

-- Drop what a player is carrying, returning it home.
local function dropCarried(player, reason)
	local record = carrying[player]
	if not record then
		return
	end
	carrying[player] = nil
	if record.weld then
		record.weld:Destroy()
	end
	ctx.remotes.CarryState:FireClient(player, false)
	if reason == "placed" then
		return
	end
	returnHome(record)
end

-- Put a carried brainrot onto one of the carrier's own free stands.
local function placeCarried(player, baseIndex, slotIndex)
	local record = carrying[player]
	if not record then
		return
	end
	local base = ctx.world.bases[baseIndex]
	if not base then
		return
	end
	if ctx.bases.getOwner(baseIndex) ~= player then
		ctx.remotes.Announce:FireClient(player, "That is not your base.", "error")
		return
	end
	local slot = base.stands[slotIndex]
	if not slot or slot.occupant then
		ctx.remotes.Announce:FireClient(player, "That stand is already taken.", "error")
		return
	end
	carrying[player] = nil
	if record.weld then
		record.weld:Destroy()
	end
	setAnchored(record.model, true)
	slot.occupant = { entry = record.entry, mutation = record.mutation, model = record.model, owner = player, baseIndex = baseIndex, slotIndex = slotIndex }
	record.model:PivotTo(CFrame.new(slot.position.X, slot.position.Y + PIVOT_LIFT, slot.position.Z))
	record.model.Parent = workspace
	ctx.remotes.CarryState:FireClient(player, false)
	ctx.remotes.Announce:FireClient(player, "Stolen! " .. record.entry.name .. " is yours now.", "good")
end

-- The Take prompt on a stand: steal from someone else, or place what
-- you are carrying on one of your own free stands.
function StealService.tryTake(player, baseIndex, slotIndex)
	local base = ctx.world.bases[baseIndex]
	if not base then
		return
	end
	local slot = base.stands[slotIndex]
	if not slot then
		return
	end

	-- Placing: the player carries one and this is their own free stand.
	if carrying[player] then
		placeCarried(player, baseIndex, slotIndex)
		return
	end

	-- Stealing: the stand must hold a brainrot that belongs to someone else.
	if not slot.occupant then
		ctx.remotes.Announce:FireClient(player, "That stand is empty.", "error")
		return
	end
	if slot.occupant.owner == player then
		ctx.remotes.Announce:FireClient(player, "That brainrot is already yours. Use Sell to cash it out.", "error")
		return
	end
	if ctx.shield.isProtected(baseIndex) then
		ctx.remotes.Announce:FireClient(player, "This base is shielded! The raid is blocked.", "error")
		return
	end

	local occupant = slot.occupant
	slot.occupant = nil
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		-- The carrier is not in a state to carry; put it back.
		slot.occupant = occupant
		return
	end

	-- Weld the model in front of the player and let them walk it home.
	setAnchored(occupant.model, false)
	for _, part in ipairs(occupant.model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
	local weld = Instance.new("Weld")
	weld.Part0 = root
	weld.Part1 = occupant.model.PrimaryPart
	weld.C0 = CFrame.new(0, 0.5, -3)
	weld.Parent = root
	occupant.model:PivotTo(root.CFrame * CFrame.new(0, 0.5, -3))

	carrying[player] = {
		entry = occupant.entry,
		mutation = occupant.mutation,
		model = occupant.model,
		weld = weld,
		fromBase = baseIndex,
		fromSlot = slotIndex,
		fromOwner = occupant.owner,
		startedAt = os.clock(),
	}

	-- If the carrier dies, the brainrot goes home.
	humanoid.Died:Connect(function()
		dropCarried(player, "died")
	end)

	ctx.remotes.CarryState:FireClient(player, true)
	ctx.remotes.Announce:FireClient(player, "You grabbed " .. occupant.entry.name .. "! Carry it to your base before time runs out.", "good")
	local victim = occupant.owner
	if victim and victim ~= player then
		ctx.remotes.Announce:FireClient(victim, player.Name .. " is stealing your " .. occupant.entry.name .. "!", "warn")
	end
end

function StealService.start(context)
	ctx = context
	-- A slow sweep returns brainrots whose carrier took too long or left.
	task.spawn(function()
		while true do
			task.wait(1)
			for player, record in pairs(carrying) do
				if not player.Parent then
					dropCarried(player, "left")
				elseif os.clock() - record.startedAt > CARRY_TIMEOUT then
					ctx.remotes.Announce:FireClient(player, "You took too long! The brainrot ran back home.", "error")
					dropCarried(player, "timeout")
				end
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		dropCarried(player, "left")
	end)
end

return StealService
