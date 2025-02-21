--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer

local Mouse = require(ReplicatedStorage.Core.Shared.Util.Mouse).new()

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
local Animator = Humanoid:WaitForChild("Animator") :: Animator

local Types = require(ReplicatedStorage.Core.Types)

local class

local Abilities = {}

local function LoadAnimations(class)
    print(class)
    for name, ability : Types.Ability in class.Abilities do
        Abilities[name] = ability

        local newAnimation = Instance.new("Animation")
        newAnimation.AnimationId = "rbxassetid://"..ability.Animation

        local newTrack = Animator:LoadAnimation(newAnimation)
        Abilities[name].AnimationTrack = newTrack

        newTrack:GetMarkerReachedSignal("Fire"):Connect(function()
            Abilities.Ability1.OnActivate(Mouse:Get3DPosition(), Character, Abilities.Ability1)
        end)
    end
end

Player.CharacterAdded:Connect(function(character)
    Character = character; Humanoid = Character:WaitForChild("Humanoid"); Animator = Humanoid:WaitForChild("Animator"); LoadAnimations(class)
end)

function Abilities.LoadAbilities(Class : Types.Class)
    class = Class
    -- // Loading Animation
   LoadAnimations(Class)

    -- // Connecting the inputs to the abilities
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        --if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.F then
            Abilities.Ability1.AnimationTrack:Play()
        end
    end)
end

return Abilities