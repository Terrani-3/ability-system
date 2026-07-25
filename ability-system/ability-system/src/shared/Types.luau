export type AbilityConfig = {
	Name: string,
	Cooldown: number,
	Damage: number,
	ProjectileSpeed: number,
	Visualizer: (Origin: Vector3, Direction: Vector3) -> (BasePart, CFrame),
}

export type ActivateRequest = {
	Ability: string,
	Origin: Vector3,
	Direction: Vector3,
}

return nil
