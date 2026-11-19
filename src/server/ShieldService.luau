-- ShieldService: the laser shield that guards a base from raids.
-- A player raises a glowing barrier around their own base. It holds for
-- a while, then needs a long cooldown before it can be raised again.
-- The cooldown is counted after the shield ends, never from the moment
-- it was raised: one full cycle is the duration plus the cooldown.
-- This file also owns the thirteen collision groups the game uses, so
-- carried brainrots, shields and the wave never snag on the wrong thing.

local PhysicsService = game:GetService("PhysicsService")

local ShieldService = {}

local ctx = nil
local shields = {}

-- The thirteen collision groups: the default plus one for every kind
-- of thing that needs its own collision behaviour.
local GROUP_NAMES = {
	"Default",
	"Players",
	"Brainrots",
	"Stands",
	"Walls",
	"Water",
	"Shield",
	"Belt",
	"Decor",
	"Carried",
	"SafeZone",
	"Merchant",
	"Wave",
}

-- Build one glowing wall of the barrier around a base pad.
local function barrierWall(folder, name, size, position)
	local wall = Instance.new("Part")
	wall.Name = name
	wall.Shape = Enum.PartType.Block
	wall.Size = size
	wall.Color = Color3.fromRGB(80, 200, 255)
	wall.Material = Enum.Material.Neon
	wall.Transparency = 0.4
	wall.Anchored = true
	wall.CanCollide = false
	wall.Position = position
	-- The barrier belongs to the Shield group, which nothing collides with.
	pcall(function()
		PhysicsService:SetPartCollisionGroup(wall, "Shield")
	end)
	wall.Parent = folder
	return wall
end

-- Raise the shield of the player's base, if its cooldown has run out.
local function activate(player)
	local baseIndex = ctx.bases.getBase(player)
	if not baseIndex then
		return
	end
	local now = os.clock()
	local shield = shields[baseIndex]
	if shield and now < shield.cooldownUntil then
		local left = math.ceil(shield.cooldownUntil - now)
		ctx.remotes.Announce:FireClient(player, "Shield is recharging: " .. tostring(left) .. "s left.", "error")
		return
	end

	local base = ctx.world.bases[baseIndex]
	local folder = Instance.new("Folder")
	folder.Name = "ShieldBarrier"
	folder.Parent = base.folder
	local center = base.position
	-- Four walls around the 34 by 26 pad, eight studs tall.
	barrierWall(folder, "ShieldNorth", Vector3.new(34, 8, 1), center + Vector3.new(0, 5, -13))
	barrierWall(folder, "ShieldSouth", Vector3.new(34, 8, 1), center + Vector3.new(0, 5, 13))
	barrierWall(folder, "ShieldWest", Vector3.new(1, 8, 26), center + Vector3.new(-17, 5, 0))
	barrierWall(folder, "ShieldEast", Vector3.new(1, 8, 26), center + Vector3.new(17, 5, 0))

	-- The shield ends after the duration; the cooldown runs after that.
	local raisedAt = now
	local endsAt = raisedAt + ctx.data.SHIELD_DURATION
	local readyAgainAt = endsAt + ctx.data.SHIELD_COOLDOWN
	shields[baseIndex] = { activeUntil = endsAt, cooldownUntil = readyAgainAt, barrier = folder }
	ctx.remotes.Announce:FireClient(player, "Shield up! Your base is safe for " .. tostring(ctx.data.SHIELD_DURATION) .. " seconds.", "good")
end

-- Is this base's shield up right now?
function ShieldService.isProtected(baseIndex)
	local shield = shields[baseIndex]
	if not shield then
		return false
	end
	return os.clock() < shield.activeUntil
end

function ShieldService.start(context)
	ctx = context

	-- Create every collision group, then set the pairs that must pass
	-- through each other.
	for _, name in ipairs(GROUP_NAMES) do
		pcall(function()
			PhysicsService:CreateCollisionGroup(name)
		end)
	end
	PhysicsService:CollisionGroupSetCollidable("Carried", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Carried", "Brainrots", false)
	PhysicsService:CollisionGroupSetCollidable("Carried", "Stands", false)
	PhysicsService:CollisionGroupSetCollidable("Shield", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Shield", "Brainrots", false)
	PhysicsService:CollisionGroupSetCollidable("Wave", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Wave", "Brainrots", false)
	PhysicsService:CollisionGroupSetCollidable("Water", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Water", "Brainrots", false)
	PhysicsService:CollisionGroupSetCollidable("Water", "Stands", false)

	ctx.remotes.ShieldRequest.OnServerEvent:Connect(activate)

	-- A slow sweep takes down barriers whose shield has run out.
	task.spawn(function()
		while true do
			task.wait(1)
			local now = os.clock()
			for _, shield in pairs(shields) do
				if shield.barrier and now >= shield.activeUntil then
					shield.barrier:Destroy()
					shield.barrier = nil
				end
			end
		end
	end)
end

return ShieldService
