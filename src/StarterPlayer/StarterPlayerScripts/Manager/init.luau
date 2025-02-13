local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abilities = require(script.Abilities)

local Manager = {}

function Manager:Init()
    Abilities.LoadAbility(ReplicatedStorage.Core.Configs.Abilities.AbilityShowcase)
end

return Manager