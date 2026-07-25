--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// Folders
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--// Packages
local Abilities = require(Shared.Abilities)
local Projectile = require(Shared.Projectile)

--// Remotes
local ActivateAbility = Remotes:WaitForChild("ActivateAbility") :: RemoteEvent
local ReplicateAbility = Remotes:WaitForChild("ReplicateAbility") :: RemoteEvent

--// Declarations
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Keybinds = {
	[Enum.KeyCode.Q] = "EnergyBolt",
}

--// Module
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

	--// ConfigKey
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
