-- BrainrotData: the shared catalogue for Brainrot Blitz.
-- Every character, tier, price, income rate, mutation rule and economy
-- constant lives here so server and client always agree on the numbers.
-- The characters are ordered from the cheapest to the most expensive.

local BrainrotData = {}

BrainrotData.TIERS = { "Common", "Rare", "Epic", "Legendary", "Mythic" }

-- One entry per character. `body` is the main body colour, `accent` the
-- colour of the character's signature feature, `caption` a short joke
-- shown under the name in the index menu.
BrainrotData.CHARACTERS = {
	{ name = "Tung Tung Tung Sahur", tier = "Common", price = 50, income = 3, body = Color3.fromRGB(139, 90, 43), accent = Color3.fromRGB(90, 60, 30), caption = "Ketuk-ketuk sahur!" },
	{ name = "Boneca Ambalabu", tier = "Common", price = 75, income = 4, body = Color3.fromRGB(255, 170, 200), accent = Color3.fromRGB(255, 120, 170), caption = "Boneka paling imut." },
	{ name = "Trippi Troppi", tier = "Common", price = 110, income = 6, body = Color3.fromRGB(255, 140, 60), accent = Color3.fromRGB(255, 200, 90), caption = "Ikan tropis ceria." },
	{ name = "Lirili Larila", tier = "Rare", price = 180, income = 10, body = Color3.fromRGB(60, 190, 170), accent = Color3.fromRGB(140, 230, 120), caption = "Gajah kaktus berduri." },
	{ name = "Frigo Camelo", tier = "Rare", price = 260, income = 14, body = Color3.fromRGB(170, 220, 245), accent = Color3.fromRGB(120, 170, 220), caption = "Kulkas unta yang dingin." },
	{ name = "Chimpanzini Bananini", tier = "Rare", price = 380, income = 20, body = Color3.fromRGB(255, 220, 80), accent = Color3.fromRGB(150, 100, 50), caption = "Monyet pisang lincah." },
	{ name = "Brr Brr Patapim", tier = "Epic", price = 550, income = 30, body = Color3.fromRGB(150, 210, 255), accent = Color3.fromRGB(230, 245, 255), caption = "Dingin sampai menggigit." },
	{ name = "Ballerina Cappuccina", tier = "Epic", price = 800, income = 45, body = Color3.fromRGB(245, 225, 190), accent = Color3.fromRGB(200, 150, 110), caption = "Balerina kopi yang anggun." },
	{ name = "Cappuccino Assassino", tier = "Epic", price = 1100, income = 60, body = Color3.fromRGB(80, 50, 35), accent = Color3.fromRGB(40, 25, 18), caption = "Kopi yang berbahaya." },
	{ name = "Orangutini Ananasini", tier = "Legendary", price = 1600, income = 90, body = Color3.fromRGB(255, 170, 40), accent = Color3.fromRGB(120, 200, 60), caption = "Orangutan nanas raja hutan." },
	{ name = "La Vaca Saturno Saturnita", tier = "Legendary", price = 2400, income = 130, body = Color3.fromRGB(170, 130, 220), accent = Color3.fromRGB(240, 200, 90), caption = "Sapi Saturnus bercincin." },
	{ name = "Tralalero Tralala", tier = "Mythic", price = 3800, income = 210, body = Color3.fromRGB(60, 120, 255), accent = Color3.fromRGB(200, 220, 255), caption = "Hiu legendaris tiga sepatu." },
	{ name = "Bombardiro Crocodilo", tier = "Mythic", price = 5500, income = 300, body = Color3.fromRGB(60, 160, 80), accent = Color3.fromRGB(40, 90, 50), caption = "Buaya bomber paling ganas." },
}

-- Mutations: a small slice of spawns comes out Diamond (three times the
-- income) and a slightly bigger slice comes out Gold (twice the income).
BrainrotData.MUTATION_GOLD_CHANCE = 0.10
BrainrotData.MUTATION_DIAMOND_CHANCE = 0.04
BrainrotData.MUTATION_GOLD_MULT = 2
BrainrotData.MUTATION_DIAMOND_MULT = 3

-- Starting money and stands.
BrainrotData.START_CASH = 150
BrainrotData.START_STANDS = 4
BrainrotData.MAX_STANDS = 8
-- Each extra stand costs more than the last, growing with the square of
-- how many extra stands the player already bought.
BrainrotData.UPGRADE_BASE = 250
BrainrotData.SELL_RATE = 0.5

-- Rebirth: each rebirth lifts every income by half again, and the price
-- of the next rebirth grows with how many rebirths are already done.
BrainrotData.REBIRTH_BASE = 12000
BrainrotData.REBIRTH_MULT = 1.5
BrainrotData.REBIRTH_STORE = "BlitzRebirthsV1"

-- The conveyor belt runs along X in the middle of the island.
BrainrotData.CONVEYOR_MIN_X = -131
BrainrotData.CONVEYOR_MAX_X = 131
BrainrotData.CONVEYOR_SPAWN_EVERY = 3.5
BrainrotData.CONVEYOR_SPEED = 4.2

-- A shield lasts a while, then needs a long cooldown before it can be
-- raised again. The cooldown is counted after the shield ends.
BrainrotData.SHIELD_DURATION = 26
BrainrotData.SHIELD_COOLDOWN = 48

-- The tsunami cycle: first wave, warning, sweep, then the gap to the
-- next wave.
BrainrotData.WAVE_FIRST_AT = 52
BrainrotData.WAVE_WARN_FOR = 14
BrainrotData.WAVE_SWEEP_FOR = 8
BrainrotData.WAVE_GAP = 54
-- Standing higher than this keeps a player dry during the sweep.
BrainrotData.WAVE_SAFE_HEIGHT = 10

-- The six safehouses: two on the centre line, four in the corners.
BrainrotData.BASE_POSITIONS = {
	Vector3.new(0, 0, -51),
	Vector3.new(0, 0, 51),
	Vector3.new(-82, 0, -51),
	Vector3.new(-82, 0, 51),
	Vector3.new(82, 0, -51),
	Vector3.new(82, 0, 51),
}

-- The island itself: a harbour rectangle in bright morning light.
BrainrotData.ISLAND_WIDTH = 268
BrainrotData.ISLAND_DEPTH = 200
BrainrotData.CLOCK_TIME = 10.5

-- Cost of buying the next stand when the player already has `stands`.
function BrainrotData.upgradeCost(stands)
	local extra = stands - BrainrotData.START_STANDS + 1
	return BrainrotData.UPGRADE_BASE * extra * extra
end

-- Cost of the next rebirth when the player already has `rebirths`.
function BrainrotData.rebirthCost(rebirths)
	return BrainrotData.REBIRTH_BASE * (rebirths + 1)
end

-- Income multiplier from rebirths: each rebirth adds half again.
function BrainrotData.rebirthMultiplier(rebirths)
	return BrainrotData.REBIRTH_MULT ^ rebirths
end

-- Roll a mutation for a fresh spawn. Returns "Diamond", "Gold" or "Normal".
function BrainrotData.rollMutation()
	local roll = math.random()
	if roll < BrainrotData.MUTATION_DIAMOND_CHANCE then
		return "Diamond"
	elseif roll < BrainrotData.MUTATION_DIAMOND_CHANCE + BrainrotData.MUTATION_GOLD_CHANCE then
		return "Gold"
	end
	return "Normal"
end

-- Multiplier a mutation applies to a character's income.
function BrainrotData.mutationMultiplier(mutation)
	if mutation == "Diamond" then
		return BrainrotData.MUTATION_DIAMOND_MULT
	elseif mutation == "Gold" then
		return BrainrotData.MUTATION_GOLD_MULT
	end
	return 1
end

-- Look a character up by name. Returns the entry or nil.
function BrainrotData.findCharacter(name)
	for _, entry in ipairs(BrainrotData.CHARACTERS) do
		if entry.name == name then
			return entry
		end
	end
	return nil
end

-- Pick a random character, weighted so cheap ones show up most often.
function BrainrotData.randomCharacter()
	local total = 0
	for _, entry in ipairs(BrainrotData.CHARACTERS) do
		total += 1 / entry.price
	end
	local pick = math.random() * total
	for _, entry in ipairs(BrainrotData.CHARACTERS) do
		pick -= 1 / entry.price
		if pick <= 0 then
			return entry
		end
	end
	return BrainrotData.CHARACTERS[1]
end

-- Income per second of one character on a stand, with mutation and
-- rebirth applied.
function BrainrotData.incomePerSecond(entry, mutation, rebirths)
	return entry.income * BrainrotData.mutationMultiplier(mutation) * BrainrotData.rebirthMultiplier(rebirths)
end

return BrainrotData
