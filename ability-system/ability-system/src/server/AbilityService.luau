--[[ SERVICES ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--[[ FOLDERS ]]
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

--[[ PACKAGES ]]
local RemoteCooldown = require(script.Parent.RemoteCooldown)
local Abilities = require(Shared.Abilities)

--[[ REMOTES ]]
local ActivateAbility = Remotes:WaitForChild("ActivateAbility") :: RemoteEvent
local ReplicateAbility = Remotes:WaitForChild("ReplicateAbility") :: RemoteEvent

--[[ DECLARATIONS ]]
local PlayerCooldowns = {}

--[[ MODULE ]]
local AbilityService = {}

--// Per-player, per-ability cooldown check — separate from the anti-spam layer,
--// which only guards against firing the remote too fast
local function isAbilityReady(Player: Player, AbilityName: string)
	local PlayerData = PlayerCooldowns[Player]
	if not PlayerData then
		return true
	end

	local ReadyAt = PlayerData[AbilityName]
	return ReadyAt == nil or time() >= ReadyAt
end

local function startCooldown(Player: Player, Ability)
	PlayerCooldowns[Player] = PlayerCooldowns[Player] or {}
	PlayerCooldowns[Player][Ability.Name] = time() + Ability.Cooldown
end

local function onActivateAbility(Player: Player, AbilityName: string, Direction: Vector3)
	local Ability = Abilities[AbilityName]
	if not Ability then
		return
	end

	local Character = Player.Character
	local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	if not isAbilityReady(Player, AbilityName) then
		return
	end

	if typeof(Direction) ~= "Vector3" or Direction.Magnitude == 0 then
		return
	end

	startCooldown(Player, Ability)

	local Origin = RootPart.Position

	--// Replicate to everyone so the projectile is visible to all clients,
	--// server keeps authority over damage separately (not shown here)
	ReplicateAbility:FireAllClients(Player, AbilityName, Origin, Direction.Unit)
end

function AbilityService.Start()
	RemoteCooldown.OnServerEvent(ActivateAbility, onActivateAbility)
end

Players.PlayerRemoving:Connect(function(Player)
	PlayerCooldowns[Player] = nil
end)

return AbilityService
