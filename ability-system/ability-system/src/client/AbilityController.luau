--[[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--[[ FOLDERS ]]
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--[[ PACKAGES ]]
local Abilities = require(Shared.Abilities)
local Projectile = require(Shared.Projectile)

--[[ REMOTES ]]
local ActivateAbility = Remotes:WaitForChild("ActivateAbility") :: RemoteEvent
local ReplicateAbility = Remotes:WaitForChild("ReplicateAbility") :: RemoteEvent

--[[ DECLARATIONS ]]
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Keybinds = {
	[Enum.KeyCode.Q] = "EnergyBolt",
}

--[[ MODULE ]]
local AbilityController = {}

local function requestAbility(AbilityName: string)
	local Direction = Camera.CFrame.LookVector
	ActivateAbility:FireServer(AbilityName, Direction)
end

local function onReplicateAbility(Caster: Player, AbilityName: string, Origin: Vector3, Direction: Vector3)
	local Ability = Abilities[AbilityName]
	if not Ability then
		return
	end

	--// Config key just needs to be unique per active cast — the (player, ability)
	--// pair is enough since one caster can't have two of the same ability in flight
	local ConfigKey = { Player = Caster, Ability = AbilityName }
	Projectile.new(ConfigKey, Origin, Direction, Ability.Visualizer)
end

function AbilityController.Start()
	UserInputService.InputBegan:Connect(function(Input, GameProcessed)
		if GameProcessed then
			return
		end

		local AbilityName = Keybinds[Input.KeyCode]
		if AbilityName then
			requestAbility(AbilityName)
		end
	end)

	ReplicateAbility.OnClientEvent:Connect(onReplicateAbility)
end

return AbilityController
