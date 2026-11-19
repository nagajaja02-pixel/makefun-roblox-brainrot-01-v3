-- BrainrotModels: builds the 3D model of one brainrot character.
-- Every model is assembled from parts at runtime: a body, a head, a
-- signature feature drawn from the character's name, and a floating
-- label with the name, the rarity and the money per second. Models face
-- minus Z and stand with their base at Y zero, so they sit cleanly on
-- the conveyor belt and on stands.

local BrainrotModels = {}

local function makePart(name, shape, size, color, position, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = shape
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.Position = position
	part.Parent = parent
	return part
end

local function makeLabel(model, title, detail, color)
	local anchor = Instance.new("Part")
	anchor.Name = "LabelAnchor"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Position = Vector3.new(0, 5.4, 0)
	anchor.Parent = model

	local gui = Instance.new("BillboardGui")
	gui.Name = "NameLabel"
	gui.Size = UDim2.new(0, 150, 0, 54)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
	gui.AlwaysOnTop = true
	gui.Parent = anchor

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Title"
	nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = title
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Parent = gui

	local detailLabel = Instance.new("TextLabel")
	detailLabel.Name = "Detail"
	detailLabel.Size = UDim2.new(1, 0, 0.45, 0)
	detailLabel.Position = UDim2.new(0, 0, 0.55, 0)
	detailLabel.BackgroundTransparency = 1
	detailLabel.Text = detail
	detailLabel.TextColor3 = color
	detailLabel.TextStrokeTransparency = 0
	detailLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	detailLabel.Font = Enum.Font.GothamBold
	detailLabel.TextScaled = true
	detailLabel.Parent = gui
end

-- One signature feature per character, picked from what the name
-- suggests: fins for the shark, a snout for the crocodile, a peel for
-- the banana monkey, and so on. Each feature is a few extra parts.
local function addFeature(model, entry)
	local body = entry.body
	local accent = entry.accent
	local name = entry.name

	if name == "Tralalero Tralala" then
		-- Shark: a tall fin on top and a tail at the back.
		makePart("Fin", Enum.PartType.Block, Vector3.new(0.3, 2.2, 1.6), accent, Vector3.new(0, 4.4, 0.2), model)
		makePart("Tail", Enum.PartType.Block, Vector3.new(0.3, 1.6, 1.2), body, Vector3.new(0, 2.4, 1.6), model)
		makePart("Snout", Enum.PartType.Block, Vector3.new(1.6, 1.0, 1.2), accent, Vector3.new(0, 2.6, -1.8), model)
	elseif name == "Bombardiro Crocodilo" then
		-- Crocodile: a long snout, a ridged back and a heavy tail.
		makePart("Snout", Enum.PartType.Block, Vector3.new(1.8, 0.9, 2.4), accent, Vector3.new(0, 2.2, -1.9), model)
		makePart("Ridge", Enum.PartType.Block, Vector3.new(0.6, 1.0, 2.6), accent, Vector3.new(0, 4.2, 0.4), model)
		makePart("Tail", Enum.PartType.Block, Vector3.new(1.0, 0.8, 3.0), body, Vector3.new(0, 1.6, 2.4), model)
	elseif name == "Chimpanzini Bananini" then
		-- Banana monkey: a curved peel over the shoulders and a tail.
		makePart("Peel", Enum.PartType.Block, Vector3.new(2.6, 0.5, 1.4), accent, Vector3.new(0, 4.6, 0), model)
		makePart("Tail", Enum.PartType.Block, Vector3.new(0.4, 2.2, 0.4), accent, Vector3.new(1.2, 2.6, 1.2), model)
		makePart("EarLeft", Enum.PartType.Ball, Vector3.new(0.8, 0.8, 0.8), body, Vector3.new(-1.5, 4.4, 0), model)
		makePart("EarRight", Enum.PartType.Ball, Vector3.new(0.8, 0.8, 0.8), body, Vector3.new(1.5, 4.4, 0), model)
	elseif name == "Lirili Larila" then
		-- Cactus elephant: a trunk, two tusks and spines.
		makePart("Trunk", Enum.PartType.Cylinder, Vector3.new(0.8, 2.4, 0.8), accent, Vector3.new(0, 2.8, -1.7), model)
		makePart("TuskLeft", Enum.PartType.Block, Vector3.new(0.3, 0.3, 1.4), Color3.fromRGB(255, 250, 230), Vector3.new(-0.9, 3.2, -1.5), model)
		makePart("TuskRight", Enum.PartType.Block, Vector3.new(0.3, 0.3, 1.4), Color3.fromRGB(255, 250, 230), Vector3.new(0.9, 3.2, -1.5), model)
		makePart("Spine", Enum.PartType.Block, Vector3.new(0.4, 1.4, 0.4), accent, Vector3.new(0, 4.8, 0.6), model)
	elseif name == "Frigo Camelo" then
		-- Fridge camel: a cold box on the back and two humps.
		makePart("Fridge", Enum.PartType.Block, Vector3.new(2.4, 2.0, 1.6), accent, Vector3.new(0, 3.4, 0.9), model)
		makePart("HumpLeft", Enum.PartType.Ball, Vector3.new(1.2, 1.0, 1.2), body, Vector3.new(-0.7, 4.6, 0), model)
		makePart("HumpRight", Enum.PartType.Ball, Vector3.new(1.2, 1.0, 1.2), body, Vector3.new(0.7, 4.6, 0), model)
	elseif name == "Brr Brr Patapim" then
		-- Ice creature: crystals on the head and shoulders.
		makePart("CrystalTop", Enum.PartType.Block, Vector3.new(0.7, 1.6, 0.7), accent, Vector3.new(0, 5.2, 0), model)
		makePart("CrystalLeft", Enum.PartType.Block, Vector3.new(0.5, 1.0, 0.5), accent, Vector3.new(-1.4, 4.4, 0), model)
		makePart("CrystalRight", Enum.PartType.Block, Vector3.new(0.5, 1.0, 0.5), accent, Vector3.new(1.4, 4.4, 0), model)
	elseif name == "Ballerina Cappuccina" then
		-- Ballerina: a tutu skirt and a bun.
		makePart("Tutu", Enum.PartType.Cylinder, Vector3.new(1.2, 3.6, 1.2), accent, Vector3.new(0, 1.8, 0), model)
		makePart("Bun", Enum.PartType.Ball, Vector3.new(1.0, 1.0, 1.0), body, Vector3.new(0, 5.4, 0.4), model)
		makePart("Sash", Enum.PartType.Block, Vector3.new(2.4, 0.4, 0.2), accent, Vector3.new(0, 3.4, -1.15), model)
	elseif name == "Cappuccino Assassino" then
		-- Assassin cup: a lid, a handle and a dark hood.
		makePart("Lid", Enum.PartType.Cylinder, Vector3.new(0.5, 2.6, 0.5), accent, Vector3.new(0, 5.0, 0), model)
		makePart("Handle", Enum.PartType.Block, Vector3.new(0.5, 1.2, 0.5), accent, Vector3.new(1.5, 3.2, 0), model)
		makePart("Hood", Enum.PartType.Block, Vector3.new(2.8, 0.8, 2.8), accent, Vector3.new(0, 5.0, 0), model)
	elseif name == "Orangutini Ananasini" then
		-- Pineapple orangutan: a leafy crown and long arms.
		makePart("LeafOne", Enum.PartType.Block, Vector3.new(0.4, 1.8, 0.4), accent, Vector3.new(-0.5, 5.6, 0), model)
		makePart("LeafTwo", Enum.PartType.Block, Vector3.new(0.4, 1.8, 0.4), accent, Vector3.new(0.5, 5.6, 0), model)
		makePart("ArmLeft", Enum.PartType.Block, Vector3.new(0.6, 2.6, 0.6), body, Vector3.new(-1.7, 2.6, 0), model)
		makePart("ArmRight", Enum.PartType.Block, Vector3.new(0.6, 2.6, 0.6), body, Vector3.new(1.7, 2.6, 0), model)
	elseif name == "La Vaca Saturno Saturnita" then
		-- Saturn cow: a ring around the body and two horns.
		makePart("Ring", Enum.PartType.Cylinder, Vector3.new(0.3, 5.4, 0.3), accent, Vector3.new(0, 3.0, 0), model)
		makePart("HornLeft", Enum.PartType.Block, Vector3.new(0.4, 1.2, 0.4), Color3.fromRGB(255, 250, 230), Vector3.new(-1.2, 5.0, 0), model)
		makePart("HornRight", Enum.PartType.Block, Vector3.new(0.4, 1.2, 0.4), Color3.fromRGB(255, 250, 230), Vector3.new(1.2, 5.0, 0), model)
	elseif name == "Tung Tung Tung Sahur" then
		-- Wooden log drummer: a drum on the belly and two sticks.
		makePart("Drum", Enum.PartType.Cylinder, Vector3.new(1.2, 1.6, 1.2), accent, Vector3.new(0, 2.6, -1.4), model)
		makePart("StickLeft", Enum.PartType.Block, Vector3.new(0.3, 1.6, 0.3), Color3.fromRGB(220, 190, 140), Vector3.new(-1.4, 3.6, -1.2), model)
		makePart("StickRight", Enum.PartType.Block, Vector3.new(0.3, 1.6, 0.3), Color3.fromRGB(220, 190, 140), Vector3.new(1.4, 3.6, -1.2), model)
	elseif name == "Boneca Ambalabu" then
		-- Doll: a bow on the head and a dress.
		makePart("BowLeft", Enum.PartType.Block, Vector3.new(0.9, 0.7, 0.3), accent, Vector3.new(-0.8, 5.2, 0), model)
		makePart("BowRight", Enum.PartType.Block, Vector3.new(0.9, 0.7, 0.3), accent, Vector3.new(0.8, 5.2, 0), model)
		makePart("Dress", Enum.PartType.Cylinder, Vector3.new(1.0, 3.0, 1.0), accent, Vector3.new(0, 1.4, 0), model)
	elseif name == "Trippi Troppi" then
		-- Tropical fish: a tail fin and side fins.
		makePart("TailFin", Enum.PartType.Block, Vector3.new(0.3, 1.8, 1.4), accent, Vector3.new(0, 2.6, 1.7), model)
		makePart("FinLeft", Enum.PartType.Block, Vector3.new(1.0, 0.6, 0.3), accent, Vector3.new(-1.6, 3.0, 0), model)
		makePart("FinRight", Enum.PartType.Block, Vector3.new(1.0, 0.6, 0.3), accent, Vector3.new(1.6, 3.0, 0), model)
	end
end

-- Build one character model from its catalogue entry and mutation.
-- The model is anchored and ready to be placed on the belt or a stand.
function BrainrotModels.build(entry, mutation)
	local model = Instance.new("Model")
	model.Name = entry.name

	-- Body and head, sized so every character reads at a glance.
	makePart("Body", Enum.PartType.Block, Vector3.new(2.6, 3.0, 1.8), entry.body, Vector3.new(0, 1.5, 0), model)
	makePart("Head", Enum.PartType.Block, Vector3.new(2.2, 2.0, 2.0), entry.body, Vector3.new(0, 4.0, 0), model)

	-- Two eyes on the front face (minus Z is the front).
	makePart("EyeLeft", Enum.PartType.Ball, Vector3.new(0.5, 0.6, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(-0.55, 4.2, -1.05), model)
	makePart("EyeRight", Enum.PartType.Ball, Vector3.new(0.5, 0.6, 0.3), Color3.fromRGB(255, 255, 255), Vector3.new(0.55, 4.2, -1.05), model)
	makePart("PupilLeft", Enum.PartType.Ball, Vector3.new(0.25, 0.3, 0.15), Color3.fromRGB(0, 0, 0), Vector3.new(-0.55, 4.2, -1.2), model)
	makePart("PupilRight", Enum.PartType.Ball, Vector3.new(0.25, 0.3, 0.15), Color3.fromRGB(0, 0, 0), Vector3.new(0.55, 4.2, -1.2), model)

	-- The character's own signature feature.
	addFeature(model, entry)

	-- A mutation changes the look: gold shines, diamond sparkles.
	if mutation == "Gold" then
		local glow = makePart("GoldTrim", Enum.PartType.Block, Vector3.new(2.8, 0.3, 2.0), Color3.fromRGB(255, 210, 60), Vector3.new(0, 3.1, 0), model)
		glow.Material = Enum.Material.Neon
	elseif mutation == "Diamond" then
		local glow = makePart("DiamondTrim", Enum.PartType.Block, Vector3.new(2.8, 0.3, 2.0), Color3.fromRGB(150, 230, 255), Vector3.new(0, 3.1, 0), model)
		glow.Material = Enum.Material.Neon
	end

	-- A small base plate so the model sits flat anywhere.
	local plate = makePart("Plate", Enum.PartType.Cylinder, Vector3.new(0.4, 3.4, 0.4), Color3.fromRGB(60, 60, 70), Vector3.new(0, 0.2, 0), model)
	plate.Material = Enum.Material.Metal

	-- The readable label: name on top, rarity and income below.
	local labelColor = Color3.fromRGB(255, 255, 255)
	if mutation == "Gold" then
		labelColor = Color3.fromRGB(255, 210, 60)
	elseif mutation == "Diamond" then
		labelColor = Color3.fromRGB(150, 230, 255)
	end
	local detail = entry.tier
	if mutation ~= "Normal" then
		detail = mutation .. " " .. entry.tier
	end
	detail = detail .. "  $" .. tostring(entry.income) .. "/s"
	makeLabel(model, entry.name, detail, labelColor)

	model.PrimaryPart = model:FindFirstChild("Body")
	return model
end

return BrainrotModels
