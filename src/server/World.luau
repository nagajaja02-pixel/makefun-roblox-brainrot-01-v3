-- World: builds the whole island at server start.
-- A harbour rectangle with a conveyor down the middle, six safehouse
-- pads on the sides, walls around the edge, harbour decoration, and a
-- high lookout deck players can climb when the tsunami comes. Everything
-- is plain parts so the place builds the same way on every run.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotData"))

local World = {}

-- One part, the way every builder in this file makes one.
function World.part(name, shape, size, color, position, parent, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.Position = position
	part.Parent = parent
	return part
end

-- A sign board on a pole, with a floating label that services can
-- rename (the base owner's name goes here).
function World.makeSign(parent, position, title)
	local pole = World.part("SignPole", Enum.PartType.Cylinder, Vector3.new(0.6, 6, 0.6), Color3.fromRGB(90, 70, 50), position + Vector3.new(0, 3, 0), parent)
	pole.Orientation = Vector3.new(0, 0, 90)
	local board = World.part("SignBoard", Enum.PartType.Block, Vector3.new(8, 3, 0.5), Color3.fromRGB(40, 70, 120), position + Vector3.new(0, 6.5, 0), parent)
	local gui = Instance.new("BillboardGui")
	gui.Name = "SignGui"
	gui.Size = UDim2.new(0, 160, 0, 50)
	gui.AlwaysOnTop = true
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
	return board
end

-- A proximity prompt with one action line, ready for a service to
-- listen to.
function World.makePrompt(parent, objectText, actionText, holdSeconds)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = objectText
	prompt.ActionText = actionText
	prompt.HoldDuration = holdSeconds or 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

-- The harbour ground, the sea around it and the boundary walls.
local function buildGround(folder)
	World.part("Island", Enum.PartType.Block, Vector3.new(Data.ISLAND_WIDTH, 2, Data.ISLAND_DEPTH), Color3.fromRGB(235, 215, 160), Vector3.new(0, -1, 0), folder, Enum.Material.Sand)
	World.part("Sea", Enum.PartType.Block, Vector3.new(700, 1, 600), Color3.fromRGB(40, 120, 200), Vector3.new(0, -2.5, 0), folder, Enum.Material.Water)
	-- A sandy rim so the island reads as a beach from above.
	World.part("BeachNorth", Enum.PartType.Block, Vector3.new(Data.ISLAND_WIDTH, 0.5, 8), Color3.fromRGB(245, 230, 180), Vector3.new(0, 0.2, -96), folder, Enum.Material.Sand)
	World.part("BeachSouth", Enum.PartType.Block, Vector3.new(Data.ISLAND_WIDTH, 0.5, 8), Color3.fromRGB(245, 230, 180), Vector3.new(0, 0.2, 96), folder, Enum.Material.Sand)
	-- Low walls around the edge so players stay on the island.
	World.part("WallNorth", Enum.PartType.Block, Vector3.new(Data.ISLAND_WIDTH, 4, 2), Color3.fromRGB(120, 120, 130), Vector3.new(0, 2, -99), folder, Enum.Material.Concrete)
	World.part("WallSouth", Enum.PartType.Block, Vector3.new(Data.ISLAND_WIDTH, 4, 2), Color3.fromRGB(120, 120, 130), Vector3.new(0, 2, 99), folder, Enum.Material.Concrete)
	World.part("WallWest", Enum.PartType.Block, Vector3.new(2, 4, Data.ISLAND_DEPTH), Color3.fromRGB(120, 120, 130), Vector3.new(-133, 2, 0), folder, Enum.Material.Concrete)
	World.part("WallEast", Enum.PartType.Block, Vector3.new(2, 4, Data.ISLAND_DEPTH), Color3.fromRGB(120, 120, 130), Vector3.new(133, 2, 0), folder, Enum.Material.Concrete)
end

-- The long belt down the middle of the island, with rails on both
-- sides and a glowing strip so it reads from far away.
local function buildConveyor(folder)
	local belt = World.part("Belt", Enum.PartType.Block, Vector3.new(262, 2, 10), Color3.fromRGB(70, 70, 80), Vector3.new(0, 1, 0), folder, Enum.Material.Metal)
	World.part("BeltStripe", Enum.PartType.Block, Vector3.new(262, 0.3, 1), Color3.fromRGB(255, 200, 40), Vector3.new(0, 2.1, 0), folder, Enum.Material.Neon)
	World.part("RailNorth", Enum.PartType.Block, Vector3.new(262, 1.5, 1), Color3.fromRGB(40, 40, 50), Vector3.new(0, 2.5, -5.5), folder, Enum.Material.Metal)
	World.part("RailSouth", Enum.PartType.Block, Vector3.new(262, 1.5, 1), Color3.fromRGB(40, 40, 50), Vector3.new(0, 2.5, 5.5), folder, Enum.Material.Metal)
	-- Loading dock at the west end where new brainrots appear.
	World.part("Dock", Enum.PartType.Block, Vector3.new(8, 3, 14), Color3.fromRGB(150, 100, 50), Vector3.new(-131, 1.5, 0), folder, Enum.Material.Wood)
	-- Exit gate at the east end where unsold brainrots leave.
	World.part("ExitGate", Enum.PartType.Block, Vector3.new(2, 6, 12), Color3.fromRGB(150, 60, 60), Vector3.new(131, 3, 0), folder, Enum.Material.Metal)
	return belt
end

-- One safehouse pad: a raised floor, eight stand slots in two rows, a
-- sign, a roof deck above it (the dry spot in a tsunami) and a ramp up
-- to that roof.
local function buildBase(folder, index, position)
	local pad = Instance.new("Folder")
	pad.Name = "Base" .. tostring(index)
	pad.Parent = folder

	local floor = World.part("Floor", Enum.PartType.Block, Vector3.new(34, 1, 26), Color3.fromRGB(180, 160, 120), position + Vector3.new(0, 0.5, 0), pad, Enum.Material.Concrete)
	floor.CanCollide = true
	-- A coloured border so each base is easy to tell apart.
	local borderColors = {
		Color3.fromRGB(255, 90, 90),
		Color3.fromRGB(90, 160, 255),
		Color3.fromRGB(90, 220, 120),
		Color3.fromRGB(255, 200, 60),
		Color3.fromRGB(200, 120, 255),
		Color3.fromRGB(255, 140, 200),
	}
	World.part("Border", Enum.PartType.Block, Vector3.new(34, 0.4, 2), borderColors[index], position + Vector3.new(0, 1.1, -12), pad, Enum.Material.Neon)
	World.part("BorderBack", Enum.PartType.Block, Vector3.new(34, 0.4, 2), borderColors[index], position + Vector3.new(0, 1.1, 12), pad, Enum.Material.Neon)

	-- Eight stand slots: two rows of four.
	local stands = {}
	local columns = { -12, -4, 4, 12 }
	local rows = { -6, 6 }
	for _, row in ipairs(rows) do
		for _, column in ipairs(columns) do
			local slot = position + Vector3.new(column, 0, row)
			local disc = World.part("Stand", Enum.PartType.Cylinder, Vector3.new(0.6, 4.4, 0.6), Color3.fromRGB(220, 220, 230), slot + Vector3.new(0, 1.3, 0), pad, Enum.Material.Metal)
			disc.Orientation = Vector3.new(0, 0, 0)
			table.insert(stands, { position = slot + Vector3.new(0, 1.6, 0), pad = disc, occupant = nil })
		end
	end

	-- Roof deck above the stands: the dry spot when the wave comes.
	local roof = World.part("Roof", Enum.PartType.Block, Vector3.new(30, 1, 22), Color3.fromRGB(90, 90, 110), position + Vector3.new(0, 12, 0), pad, Enum.Material.Concrete)
	-- Four posts holding the roof up.
	for _, dx in ipairs({ -14, 14 }) do
		for _, dz in ipairs({ -10, 10 }) do
			World.part("RoofPost", Enum.PartType.Block, Vector3.new(1, 11, 1), Color3.fromRGB(110, 110, 130), position + Vector3.new(dx, 6, dz), pad, Enum.Material.Metal)
		end
	end
	-- A ramp up to the roof on the side facing the conveyor. The end
	-- toward the belt sits low on the ground and the end toward the base
	-- rises to the roof: the tilt leans toward the belt.
	local ramp = World.part("Ramp", Enum.PartType.Block, Vector3.new(6, 0.6, 16), Color3.fromRGB(150, 130, 100), position + Vector3.new(0, 6, 0), pad, Enum.Material.Wood)
	local towardBelt = 1
	if position.Z > 0 then
		towardBelt = -1
	end
	ramp.CFrame = CFrame.new(position + Vector3.new(0, 6, towardBelt * 16)) * CFrame.Angles(math.rad(38 * towardBelt), 0, 0)

	local sign = World.makeSign(pad, position + Vector3.new(0, 1, -11), "Base " .. tostring(index))
	return { index = index, position = position, floor = floor, stands = stands, roof = roof, sign = sign, folder = pad }
end

-- Harbour decoration: crates, barrels, palm trees, lamps and a stack
-- of shipping containers near the east dock.
local function buildDecor(folder)
	local crateSpots = { Vector3.new(-100, 0, -70), Vector3.new(-96, 0, -66), Vector3.new(100, 0, 70), Vector3.new(104, 0, 66), Vector3.new(-60, 0, 80), Vector3.new(60, 0, -80) }
	for i, spot in ipairs(crateSpots) do
		World.part("Crate" .. tostring(i), Enum.PartType.Block, Vector3.new(4, 4, 4), Color3.fromRGB(170, 120, 60), spot + Vector3.new(0, 2, 0), folder, Enum.Material.Wood)
	end
	local barrelSpots = { Vector3.new(-110, 0, 40), Vector3.new(-108, 0, 44), Vector3.new(110, 0, -40), Vector3.new(108, 0, -44) }
	for i, spot in ipairs(barrelSpots) do
		World.part("Barrel" .. tostring(i), Enum.PartType.Cylinder, Vector3.new(2.5, 2, 2.5), Color3.fromRGB(200, 60, 50), spot + Vector3.new(0, 1.2, 0), folder, Enum.Material.Metal)
	end
	-- Palm trees along the beach edges.
	local palmSpots = { Vector3.new(-120, 0, -85), Vector3.new(-40, 0, -85), Vector3.new(40, 0, -85), Vector3.new(120, 0, -85), Vector3.new(-120, 0, 85), Vector3.new(120, 0, 85) }
	for i, spot in ipairs(palmSpots) do
		local trunk = World.part("PalmTrunk" .. tostring(i), Enum.PartType.Cylinder, Vector3.new(10, 1.2, 1.2), Color3.fromRGB(140, 100, 60), spot + Vector3.new(0, 5, 0), folder, Enum.Material.Wood)
		trunk.Orientation = Vector3.new(0, 0, 8)
		World.part("PalmTop" .. tostring(i), Enum.PartType.Ball, Vector3.new(5, 3, 5), Color3.fromRGB(60, 180, 80), spot + Vector3.new(0, 11, 0), folder, Enum.Material.Grass)
	end
	-- Lamp posts so the island reads at a glance.
	for i, x in ipairs({ -100, -50, 0, 50, 100 }) do
		World.part("Lamp" .. tostring(i), Enum.PartType.Cylinder, Vector3.new(8, 0.6, 0.6), Color3.fromRGB(50, 50, 60), Vector3.new(x, 4, 20), folder, Enum.Material.Metal)
		local bulb = World.part("LampBulb" .. tostring(i), Enum.PartType.Ball, Vector3.new(1.6, 1.6, 1.6), Color3.fromRGB(255, 240, 150), Vector3.new(x, 8.5, 20), folder, Enum.Material.Neon)
		bulb.CanCollide = false
	end
	-- Shipping containers stacked near the east end.
	World.part("ContainerA", Enum.PartType.Block, Vector3.new(12, 5, 5), Color3.fromRGB(60, 120, 200), Vector3.new(115, 2.5, 60), folder, Enum.Material.Metal)
	World.part("ContainerB", Enum.PartType.Block, Vector3.new(12, 5, 5), Color3.fromRGB(200, 90, 60), Vector3.new(115, 7.5, 60), folder, Enum.Material.Metal)
	World.part("ContainerC", Enum.PartType.Block, Vector3.new(12, 5, 5), Color3.fromRGB(90, 180, 90), Vector3.new(100, 2.5, 60), folder, Enum.Material.Metal)
	-- Buoys bobbing in the sea outside the walls.
	for i, spot in ipairs({ Vector3.new(-60, 0, -130), Vector3.new(60, 0, -130), Vector3.new(-60, 0, 130), Vector3.new(60, 0, 130) }) do
		World.part("Buoy" .. tostring(i), Enum.PartType.Ball, Vector3.new(2.5, 2.5, 2.5), Color3.fromRGB(255, 120, 40), spot + Vector3.new(0, -1, 0), folder)
	end
end

-- The merchant stall near the conveyor, and the tall lookout deck in
-- the middle of the island for watching the wave come in.
local function buildLandmarks(folder)
	-- Merchant stall: a counter and a striped awning.
	World.part("StallCounter", Enum.PartType.Block, Vector3.new(10, 3, 4), Color3.fromRGB(150, 110, 70), Vector3.new(-40, 1.5, 24), folder, Enum.Material.Wood)
	World.part("StallAwning", Enum.PartType.Block, Vector3.new(12, 0.6, 6), Color3.fromRGB(255, 90, 90), Vector3.new(-40, 6, 24), folder, Enum.Material.Fabric)
	for i, dx in ipairs({ -4, 0, 4 }) do
		World.part("StallPost" .. tostring(i), Enum.PartType.Cylinder, Vector3.new(5, 0.5, 0.5), Color3.fromRGB(80, 60, 40), Vector3.new(-40 + dx, 3, 26.5), folder, Enum.Material.Wood)
	end
	-- Lookout deck: a high platform with a ramp, the best view of the belt.
	local deck = World.part("LookoutDeck", Enum.PartType.Block, Vector3.new(18, 1, 14), Color3.fromRGB(100, 100, 120), Vector3.new(0, 14, 34), folder, Enum.Material.Concrete)
	for _, dx in ipairs({ -8, 8 }) do
		for _, dz in ipairs({ -6, 6 }) do
			World.part("LookoutPost", Enum.PartType.Block, Vector3.new(1, 13, 1), Color3.fromRGB(120, 120, 140), Vector3.new(dx, 7, 34 + dz), folder, Enum.Material.Metal)
		end
	end
	local ramp = World.part("LookoutRamp", Enum.PartType.Block, Vector3.new(6, 0.6, 18), Color3.fromRGB(150, 130, 100), Vector3.new(0, 7, 44), folder, Enum.Material.Wood)
	ramp.CFrame = CFrame.new(0, 7, 44) * CFrame.Angles(math.rad(38), 0, 0)
	return deck
end

-- Build the whole island and hand back every reference the services
-- need: the belt, the six bases, the merchant spot and the lookout.
function World.build()
	local folder = Instance.new("Folder")
	folder.Name = "BlitzWorld"
	folder.Parent = workspace

	-- Bright morning light over the harbour.
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = Data.CLOCK_TIME
	lighting.Brightness = 2
	lighting.Ambient = Color3.fromRGB(140, 140, 150)
	lighting.OutdoorAmbient = Color3.fromRGB(150, 160, 180)

	buildGround(folder)
	local belt = buildConveyor(folder)
	buildDecor(folder)
	local lookout = buildLandmarks(folder)

	local bases = {}
	for i, position in ipairs(Data.BASE_POSITIONS) do
		bases[i] = buildBase(folder, i, position)
	end

	return {
		folder = folder,
		belt = belt,
		beltStart = Vector3.new(Data.CONVEYOR_MIN_X, 2, 0),
		beltEnd = Vector3.new(Data.CONVEYOR_MAX_X, 2, 0),
		bases = bases,
		merchantSpot = Vector3.new(-40, 0, 24),
		lookout = lookout,
	}
end

return World
