-- MoneyService: cash, income and rebirths.
-- Every player starts with a little cash. Each brainrot on their stands
-- pays its rate every second, multiplied by its mutation and by the
-- player's rebirths. Rebirths are saved in a DataStore so they survive
-- between sessions; cash itself is per session.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local MoneyService = {}

local ctx = nil
local cash = {}
local rebirths = {}
local store = nil

-- Push the player's money state to their HUD.
local function push(player)
	local income = MoneyService.incomePerSecond(player)
	ctx.remotes.CashChanged:FireClient(player, cash[player] or 0, income, rebirths[player] or 0)
end

-- Load a joining player's saved rebirths and set up their wallet.
local function onJoin(player)
	local saved = 0
	local ok, value = pcall(function()
		return store:GetAsync("rebirths_" .. tostring(player.UserId))
	end)
	if ok and typeof(value) == "number" then
		saved = value
	end
	rebirths[player] = saved
	cash[player] = ctx.data.START_CASH

	local board = Instance.new("Folder")
	board.Name = "leaderstats"
	board.Parent = player
	local cashValue = Instance.new("IntValue")
	cashValue.Name = "Cash"
	cashValue.Value = cash[player]
	cashValue.Parent = board
	local rebirthValue = Instance.new("IntValue")
	rebirthValue.Name = "Rebirths"
	rebirthValue.Value = saved
	rebirthValue.Parent = board

	push(player)
end

-- Save a leaving player's rebirths.
local function onLeave(player)
	local count = rebirths[player]
	if count ~= nil and count > 0 then
		pcall(function()
			store:SetAsync("rebirths_" .. tostring(player.UserId), count)
		end)
	end
	cash[player] = nil
	rebirths[player] = nil
end

-- Income per second from every brainrot on the player's stands.
function MoneyService.incomePerSecond(player)
	local baseIndex = ctx.bases.getBase(player)
	if not baseIndex then
		return 0
	end
	local total = 0
	local count = rebirths[player] or 0
	for _, slot in ipairs(ctx.world.bases[baseIndex].stands) do
		if slot.occupant then
			total += ctx.data.incomePerSecond(slot.occupant.entry, slot.occupant.mutation, count)
		end
	end
	return total
end

function MoneyService.getCash(player)
	return cash[player] or 0
end

function MoneyService.getRebirths(player)
	return rebirths[player] or 0
end

function MoneyService.spend(player, amount)
	cash[player] = (cash[player] or 0) - amount
	push(player)
end

function MoneyService.earn(player, amount)
	cash[player] = (cash[player] or 0) + amount
	push(player)
end

-- Pay for a rebirth: permanent extra income, priced by how many
-- rebirths the player already has.
local function rebirth(player)
	local count = rebirths[player] or 0
	local cost = ctx.data.rebirthCost(count)
	if (cash[player] or 0) < cost then
		ctx.remotes.Announce:FireClient(player, "Rebirth costs $" .. tostring(cost) .. ". Keep earning!", "error")
		return
	end
	cash[player] -= cost
	rebirths[player] = count + 1
	pcall(function()
		store:SetAsync("rebirths_" .. tostring(player.UserId), count + 1)
	end)
	local board = player:FindFirstChild("leaderstats")
	if board then
		local value = board:FindFirstChild("Rebirths")
		if value then
			value.Value = count + 1
		end
	end
	ctx.remotes.Announce:FireClient(player, "Rebirth complete! All income is now x" .. tostring(ctx.data.rebirthMultiplier(count + 1)) .. ".", "good")
	push(player)
end

function MoneyService.start(context)
	ctx = context
	store = DataStoreService:GetDataStore(ctx.data.REBIRTH_STORE)

	Players.PlayerAdded:Connect(onJoin)
	for _, player in ipairs(Players:GetPlayers()) do
		onJoin(player)
	end
	Players.PlayerRemoving:Connect(onLeave)

	ctx.remotes.RebirthRequest.OnServerEvent:Connect(rebirth)

	-- Every second, pay every player what their stands earned.
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				local income = MoneyService.incomePerSecond(player)
				if income > 0 then
					cash[player] = (cash[player] or 0) + income
					local board = player:FindFirstChild("leaderstats")
					if board then
						local value = board:FindFirstChild("Cash")
						if value then
							value.Value = cash[player]
						end
					end
				end
				push(player)
			end
		end
	end)
end

return MoneyService
