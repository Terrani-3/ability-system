--// Module
local RemoteCooldown = {}
local Cooldowns = {}

function RemoteCooldown.CanFire(Player: Player)
	return Cooldowns[Player] == nil
end

function RemoteCooldown.Cooldown(Player: Player, Duration: number?)
	if Cooldowns[Player] then
		return
	end

	Cooldowns[Player] = true

	task.delay(Duration or 1, function()
		Cooldowns[Player] = nil
	end)
end

function RemoteCooldown.OnServerEvent(Remote: RemoteEvent, Callback: (Player, ...any) -> ())
	return Remote.OnServerEvent:Connect(function(Player, ...)
		if RemoteCooldown.CanFire(Player) then
			RemoteCooldown.Cooldown(Player)
			Callback(Player, ...)
		end
	end)
end

return RemoteCooldown
