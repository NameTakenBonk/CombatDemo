--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Animator = Humanoid:WaitForChild("Animator") :: Animator
Player.CharacterAdded:Connect(function(character)
    Character = character; Humanoid = Character.Humanoid; Animator = Humanoid.Animator
end)

local Types = require(ReplicatedStorage.Core.Types)

local Abilities = {}

function Abilities.LoadAbilities(Class : Types.Class)
    -- // Loading Animation
    for name, ability : Types.Ability in Class.Abilities do
        Abilities[name] = ability

        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = "rbxassetid://"..ability.Animation

        local newTrack = Animator:LoadAnimation(newAnimation)
        Abilities[name].Animation = newTrack
    end

    -- // Connecting the inputs to the abilities
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.F then
            Abilities.Ability1.OnActivate()
            Abilities.Ability1.Animation:Play()
        end
    end)
end

return Abilities