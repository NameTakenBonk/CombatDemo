local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Player = game:GetService("Players").LocalPlayer

local Camera = workspace.CurrentCamera

local SecureCast = require(ReplicatedStorage.Packages["secure-cast"])
SecureCast.Initialize()
local CameraShake = require(ReplicatedStorage.Core.Shared.Util.CameraShaker)
local ExplosionShake = CameraShake.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
	Camera.CFrame = Camera.CFrame * shakeCf
end)
ExplosionShake:Start()

local Simulate = ReplicatedStorage.Simulate

local ImpactEvent = Instance.new("BindableEvent")

Simulate.OnClientEvent:Connect(function(player, config, origin, direction, projectile)
    local modifier = config
    modifier.OnImpact = ImpactEvent

    SecureCast.Cast(player, "Bullet", origin, direction, workspace:GetServerTimeNow(), projectile, config)
end)

-- TEMP CODE NOT MODULAR YET
ImpactEvent.Event:Connect(function(_, _, Caster : Player, Velocity : Vector3, ImpactedPart : BasePart, Normal : Vector3, ImpactPosition : Vector3, Material : EnumItem, ...)
    local effectClone = ReplicatedStorage.Objects.Abillities.Frieren.Particles.Impact:Clone()
    effectClone.Parent = workspace
    effectClone.Position = ImpactPosition
    Debris:AddItem(effectClone, 10)

    for _, child in effectClone:GetChildren() do
        child:Emit(5)
        task.wait()
    end

    if (Player.Character.HumanoidRootPart.Position - ImpactPosition).Magnitude <= 50 then
        print("Shake")
        ExplosionShake:Shake(CameraShake.Presets.Explosion)
    end
end)