# Ability System

A small server-authoritative ability framework for Roblox, built around a data-driven registry — new abilities are added as config entries, not new code paths.

## Design

- **Config-driven** — `Abilities.luau` maps an ability name to its cooldown, damage, and a `Visualizer` function that spawns whatever the ability looks like. Adding an ability means adding an entry, not touching the service or controller.
- **Server-authoritative** — the client only *requests* an ability. The server checks cooldown and character state before anything happens, then tells every client to replicate the visual. Damage resolution is intentionally left out of this repo (it would need to hook into a specific hitbox/health system), but the cooldown gate is the same shape you'd extend for it.
- **Two layers of rate limiting** — `RemoteCooldown` is a blunt per-player anti-spam gate on the remote itself (stops flooding the event), separate from the actual per-ability cooldown tracked in `AbilityService`. Spamming the remote doesn't bypass the real cooldown, and a legitimate ability off cooldown doesn't get blocked by the anti-spam layer.
- **Projectile replication** — `Projectile` is a lightweight class that lerps a visual instance toward a target CFrame every frame, cleaned up automatically through `Job` when the instance is destroyed or the cast ends.

## Structure

```
ReplicatedStorage
├── Shared
│   ├── Types
│   ├── Job              (lightweight cleanup, similar idea to Janitor)
│   ├── Projectile
│   └── Abilities        (the registry — add new abilities here)
└── Remotes
    ├── ActivateAbility   (client → server)
    └── ReplicateAbility  (server → clients)

ServerScriptService
└── AbilityService.Start()

StarterPlayerScripts
└── AbilityController.Start()
```

## Flow

```
Player presses Q
   │
   ▼
AbilityController → ActivateAbility:FireServer("EnergyBolt", direction)
   │
   ▼
AbilityService validates cooldown + character state
   │
   ▼
ReplicateAbility:FireAllClients(...)
   │
   ▼
Every client spawns the visual via Projectile.new(...)
```

## Notes

- The included `EnergyBolt` ability is a placeholder example — a glowing ball that lerps toward its target — meant to show the pattern, not a finished effect.
- `Job` is a minimal cleanup utility (connections, instances, and functions get cleaned up together). I use the same pattern as Janitor-style libraries, just trimmed to what this system needs.
- Remotes (`ActivateAbility`, `ReplicateAbility`) need to exist under `ReplicatedStorage.Remotes` before `Start()` is called — this repo doesn't include remote-creation boilerplate since that's usually handled by whatever framework wires up the rest of the game.
