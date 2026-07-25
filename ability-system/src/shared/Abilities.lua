local Types = require(script.Parent.Types)

--// EnergyBoltVisualizer
local function EnergyBoltVisualizer(Origin: Vector3, Direction: Vector3)
	local CF = CFrame.lookAlong(Origin, Direction)

	local Bolt = Instance.new("Part")
	Bolt.Shape = Enum.PartType.Ball
	Bolt.Size = Vector3.new(1, 1, 1)
	Bolt.Material = Enum.Material.Neon
	Bolt.Color = Color3.fromRGB(80, 170, 255)
	Bolt.CanCollide = false
	Bolt.Anchored = true
	Bolt.CFrame = CF
	Bolt.Parent = workspace

	return Bolt, CF
end

--// Abilities
local Abilities: { [string]: Types.AbilityConfig } = {
	EnergyBolt = {
		Name = "EnergyBolt",
		Cooldown = 2,
		Damage = 15,
		ProjectileSpeed = 90,
		Visualizer = EnergyBoltVisualizer,
	},
}

return Abilities
