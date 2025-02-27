--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Player = game:GetService("Players").LocalPlayer

local Types = require(script.Parent.Parent.Parent.Parent.Types)

local function AddEffectsToCharacter(character)
    local particleClone = ReplicatedStorage.Objects.Abillities.Frieren.Particles.MagicalBarrier:Clone()
    particleClone.Parent = character
    particleClone.CFrame = character.HumanoidRootPart.CFrame

    local motor6D = Instance.new("Motor6D")
    motor6D.Parent = character.HumanoidRootPart
    motor6D.Part0 = character.HumanoidRootPart
    motor6D.Part1 = particleClone

    Debris:AddItem(particleClone, 7.5)
    Debris:AddItem(motor6D, 7.5)
end

return {
    Title = "Magic Barrier",
    Description = "Frieren conjures a protective barrier around herself or an ally.",
    Cooldown = 12,
    Cost = 60,
    Animation = 85191474909660,
    OnActivate = function(Character)
        AddEffectsToCharacter(Character)
    end,
    Replicate = function(character)
        AddEffectsToCharacter(character)
    end
} :: Types.Ability  