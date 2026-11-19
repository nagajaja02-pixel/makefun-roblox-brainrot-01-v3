-- Bootstrap: the server entry script for Brainrot Blitz.
-- Builds the island, creates the remote events every service shares,
-- hands every service the same context table, and starts them in an
-- order that lets each one find the others already in place.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BrainrotData = require(Shared:WaitForChild("BrainrotData"))
local World = require(ServerScriptService:WaitForChild("World"))
local BrainrotModels = require(ServerScriptService:WaitForChild("BrainrotModels"))
local MoneyService = require(ServerScriptService:WaitForChild("MoneyService"))
local BaseService = require(ServerScriptService:WaitForChild("BaseService"))
local ConveyorService = require(ServerScriptService:WaitForChild("ConveyorService"))
local StealService = require(ServerScriptService:WaitForChild("StealService"))
local ShieldService = require(ServerScriptService:WaitForChild("ShieldService"))
local WaveService = require(ServerScriptService:WaitForChild("WaveService"))
local MerchantService = require(ServerScriptService:WaitForChild("MerchantService"))

-- The remote events every service and the client share.
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "BlitzRemotes"
remotesFolder.Parent = ReplicatedStorage

local function makeRemote(name)
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local remotes = {
	UpgradeRequest = makeRemote("UpgradeRequest"),
	ShieldRequest = makeRemote("ShieldRequest"),
	RebirthRequest = makeRemote("RebirthRequest"),
	Announce = makeRemote("Announce"),
	CashChanged = makeRemote("CashChanged"),
	CarryState = makeRemote("CarryState"),
}

-- The island comes first: every service works on what it builds.
local world = World.build()

local ctx = {
	data = BrainrotData,
	world = world,
	remotes = remotes,
	models = BrainrotModels,
	money = MoneyService,
	bases = BaseService,
	conveyor = ConveyorService,
	steal = StealService,
	shield = ShieldService,
	wave = WaveService,
	merchant = MerchantService,
}

-- Money and bases first (players join into a wallet and a base),
-- then the systems that fill and threaten those bases.
MoneyService.start(ctx)
BaseService.start(ctx)
ConveyorService.start(ctx)
StealService.start(ctx)
ShieldService.start(ctx)
WaveService.start(ctx)
MerchantService.start(ctx)

-- A slow heartbeat that keeps the server's loops honest: if a service
-- ever stops, its own loop is the one to blame, not this one.
task.spawn(function()
	while true do
		task.wait(30)
	end
end)
