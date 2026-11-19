-- CarryPose: the arms-up pose while a player carries a brainrot.
-- When the server says a carry starts, both shoulders swing forward so
-- the character looks like it is holding something in front of it. When
-- the carry ends, the shoulders go back to how they were. Works for the
-- classic R6 rig; on any other rig it simply does nothing.

local Players = game:GetService("Players")

local CarryPose = {}

local carrying = false
local saved = {}

-- The raised pose for one shoulder: forward, slightly out.
local function raisedPose(side)
	local across = if side == "Left" then -1 else 1
	return CFrame.new(across, 0.5, 0) * CFrame.Angles(math.rad(-80), 0, math.rad(across * -12))
end

local function apply(character)
	if not character then
		return
	end
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	for _, side in ipairs({ "Left", "Right" }) do
		local joint = torso:FindFirstChild(side .. " Shoulder")
		if joint and joint:IsA("Motor6D") then
			if carrying then
				if not saved[side] then
					saved[side] = joint.C0
				end
				joint.C0 = raisedPose(side)
			elseif saved[side] then
				joint.C0 = saved[side]
				saved[side] = nil
			end
		end
	end
end

function CarryPose.setCarrying(value)
	carrying = value
	local player = Players.LocalPlayer
	apply(player.Character)
end

-- A respawned character starts with normal arms; if the player is
-- still carrying, raise them again.
Players.LocalPlayer.CharacterAdded:Connect(function(character)
	task.wait(0.5)
	apply(character)
end)

return CarryPose
