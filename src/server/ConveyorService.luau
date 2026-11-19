-- ConveyorService: the belt that supplies the game.
-- A new brainrot rolls out every few seconds, rides the belt from the
-- west dock to the east gate, and leaves if nobody buys it. Clicking
-- one buys it onto a free stand in the buyer's own base.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Server = game:GetService("ServerScriptService")

local Models = require(Server:WaitForChild("BrainrotModels"))

local ConveyorService = {}

local ctx = nil
local active = {}
local nextId = 0
-- The model's Body sits this far above its base, so a model placed on
-- a surface needs its pivot lifted by this much.
local PIVOT_LIFT = 1.5

-- Put one fresh brainrot on the belt at the west dock.
local function spawnOne()
	local entry = ctx.data.randomCharacter()
	local mutation = ctx.data.rollMutation()
	local model = Models.build(entry, mutation)
	model:PivotTo(CFrame.new(ctx.world.beltStart + Vector3.new(0, PIVOT_LIFT, 0)))
	model.Parent = workspace

	local detector = Instance.new("ClickDetector")
	detector.MaxActivationDistance = 24
	detector.Parent = model

	nextId += 1
	local id = nextId
	active[id] = { id = id, entry = entry, mutation = mutation, model = model, x = ctx.data.CONVEYOR_MIN_X }
	detector.MouseClick:Connect(function(player)
		ConveyorService.buy(player, id)
	end)
end

-- Slide every brainrot along the belt; drop the ones that reach the
-- east gate unsold.
local function step(dt)
	for id, item in pairs(active) do
		item.x += ctx.data.CONVEYOR_SPEED * dt
		if item.x >= ctx.data.CONVEYOR_MAX_X then
			item.model:Destroy()
			active[id] = nil
		else
			item.model:PivotTo(CFrame.new(item.x, 2 + PIVOT_LIFT, 0))
		end
	end
end

-- Buy the brainrot with this id onto one of the buyer's free stands.
function ConveyorService.buy(player, id)
	local item = active[id]
	if not item then
		return
	end
	if ctx.money.getCash(player) < item.entry.price then
		ctx.remotes.Announce:FireClient(player, "Not enough cash for " .. item.entry.name .. " ($" .. tostring(item.entry.price) .. ").", "error")
		return
	end
	local slot = ctx.bases.freeStand(player)
	if not slot then
		ctx.remotes.Announce:FireClient(player, "No free stand! Upgrade your base to hold more brainrots.", "error")
		return
	end
	ctx.money.spend(player, item.entry.price)
	active[id] = nil
	ctx.bases.placeOnStand(player, slot, item.entry, item.mutation, item.model)
	ctx.remotes.Announce:FireClient(player, "Bought " .. item.entry.name .. " for $" .. tostring(item.entry.price) .. "!", "good")
end

function ConveyorService.start(context)
	ctx = context
	task.spawn(function()
		while true do
			task.wait(ctx.data.CONVEYOR_SPAWN_EVERY)
			spawnOne()
		end
	end)
	RunService.Heartbeat:Connect(step)
end

return ConveyorService
