--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replicate = ReplicatedStorage.Objects.Events.Replicate :: RemoteEvent

local Types = require(ReplicatedStorage.Core.Types)

return {
    Title = "Chaos Storm",
    Description = "Yennefer channels her immense magical energy to summon a devastating storm of chaotic magic.",
    Cooldown = 15,
    Cost = 40,
    Animation = 136591963334888,
    OnActivate = function()
        print("Test")
        Replicate:FireServer("Yennefer", script.Name)
    end,
    Replicate = function(character)
        local position = character.HumanoidRootPart.Position:: Vector3
        local particlePartClone = ReplicatedStorage.Objects.Abillities.Yennefer.Particles.ChaosStorm:Clone()
        particlePartClone.Position = position
        particlePartClone.Parent = workspace

        for _, child in particlePartClone:GetDescendants() do
            if not child:IsA("ParticleEmitter") then continue end

            task.delay(child:GetAttribute("EmitDelay"), function()
                child:Emit(child:GetAttribute("EmitCount"))
            end)
        end
    end
}:: Types.Ability  