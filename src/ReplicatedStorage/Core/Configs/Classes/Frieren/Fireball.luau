--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Core.Types)

local Simulate = ReplicatedStorage.Simulate

return {
    Title = "Fireball",
    Class = "Fieren",
    Description = "Frieren casts a simple yet powerful fireball at an enemy.",
    Cooldown = 5,
    Cost = 50,
    Animation = 101630424123246,

    OnActivate = function(hit, character, self)
        Simulate:FireServer(hit, character["Right Arm"].Position, self.Additional, workspace:GetServerTimeNow())
    end,

    Additional = {
        Modifier = {
            Gravity = -workspace.Gravity / 4,
            Velocity = 150
        },
        Projectile = ReplicatedStorage.Objects.Abillities.Frieren.Particles.Fireball,
        Impact = ReplicatedStorage.Objects.Abillities.Frieren.Particles.Impact
    }
} :: Types.Ability  