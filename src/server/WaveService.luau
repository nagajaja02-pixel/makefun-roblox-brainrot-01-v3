-- WaveService: the tsunami that sweeps the island on a schedule.
-- The first wave comes about a minute after the game starts. Every
-- wave is announced, gives players time to climb to high ground, then
-- a wall of water crosses the island from north to south. Anyone still
-- standing low when the wall passes over them takes damage. After the
-- sweep the sea calms down until the next wave.

local Players = game:GetService("Players")

local WaveService = {}

local ctx = nil

-- Run one wave: warn, wait, sweep the wall across, then clean up.
local function runWave()
	ctx.remotes.Announce:FireAllClients("TSUNAMI INCOMING! Climb to a roof or the lookout deck!", "warn")
	task.wait(ctx.data.WAVE_WARN_FOR)

	local wall = Instance.new("Part")
	wall.Name = "TsunamiWall"
	wall.Shape = Enum.PartType.Block
	wall.Size = Vector3.new(280, 12, 6)
	wall.Color = Color3.fromRGB(30, 100, 200)
	wall.Material = Enum.Material.Water
	wall.Transparency = 0.2
	wall.Anchored = true
	wall.CanCollide = false
	wall.Position = Vector3.new(0, 6, -110)
	wall.Parent = workspace

	local startedAt = os.clock()
	local duration = ctx.data.WAVE_SWEEP_FOR
	while os.clock() - startedAt < duration do
		local progress = (os.clock() - startedAt) / duration
		local z = -110 + progress * 220
		wall.Position = Vector3.new(0, 6, z)
		-- Anyone low and close to the wall gets hit by the water.
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				local low = root.Position.Y < ctx.data.WAVE_SAFE_HEIGHT
				local nearWall = math.abs(root.Position.Z - z) < 8
				if low and nearWall then
					humanoid:TakeDamage(15)
				end
			end
		end
		task.wait(0.2)
	end
	wall:Destroy()
	ctx.remotes.Announce:FireAllClients("The wave has passed. Keep earning!", "good")
end

function WaveService.start(context)
	ctx = context
	task.spawn(function()
		task.wait(ctx.data.WAVE_FIRST_AT)
		while true do
			runWave()
			task.wait(ctx.data.WAVE_GAP)
		end
	end)
end

return WaveService
