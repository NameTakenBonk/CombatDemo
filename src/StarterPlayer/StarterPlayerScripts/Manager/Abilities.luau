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

local AbilitiesMods = {}
for _, class in ReplicatedStorage.Core.Configs.Classes:GetChildren() do
    AbilitiesMods[class.Name] = { } :: { Types.Ability }
    
    for _, ability : ModuleScript in class:GetChildren() do
        if not ability:IsA("ModuleScript") then continue end

        local mod = require(ability) 
        print(class, ability, mod)
        AbilitiesMods[class.Name][ability.Name] = mod
    end
end


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
        elseif input.KeyCode == Enum.KeyCode.V then
            Abilities.Ability2.OnActivate(Character)
            Abilities.Ability2.AnimationTrack:Play()
        elseif input.KeyCode == Enum.KeyCode.E then
            Abilities.Ability3.OnActivate(Mouse:Get3DPosition())
        end
    end)
end

function Abilities.Replicate(class: string, ability: string, player: Player, ...)
    print("Replicate Client", class, ability, ...)
    print(AbilitiesMods)
    AbilitiesMods[class][ability].Replicate(player, ...)
end

return Abilities