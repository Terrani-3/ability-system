--[[ SERVICES ]]
local RunService = game:GetService("RunService")

--[[ PACKAGES ]]
local Job = require(script.Parent.Job)

--[[ DECLARATIONS ]]
local LerpAlpha = 0.4
local Active = {}

--[[ MODULE ]]
local Projectile = {}
Projectile.__index = Projectile

function Projectile.new(Config, Origin: Vector3, Direction: Vector3, Visualizer)
	local Visual, TargetCFrame = Visualizer(Origin, Direction)
	if not Visual then
		return
	end

	local self = setmetatable({}, Projectile)
	self.Job = Job.new()

	self.Visual = Visual
	self.TargetCFrame = TargetCFrame
	self.Config = Config

	Active[Config] = self

	self.Job:Task(RunService.PreSimulation:Connect(function(Delta)
		self:Update(Delta)
	end))

	self.Job:Task(Visual.Destroying:Connect(function()
		self:Destroy()
	end))

	return self
end

function Projectile:Update(Delta: number)
	self.Visual.CFrame = self.Visual.CFrame:Lerp(self.TargetCFrame, LerpAlpha * (Delta * 60))
end

function Projectile:SetTarget(Position: Vector3, Direction: Vector3)
	self.TargetCFrame = CFrame.lookAlong(Position, Direction)
end

function Projectile:Destroy()
	Active[self.Config] = nil

	self.Job:Destroy()
	self.Visual:Destroy()
end

--// Static access, keyed by the config/request that owns the projectile
function Projectile.Get(Config)
	return Active[Config]
end

return Projectile
