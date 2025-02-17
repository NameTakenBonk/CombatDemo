local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Abilities = require(script.Abilities)

local Manager = {}

function Manager:Init()
    Abilities.LoadAbilities(require(ReplicatedStorage.Core.Configs.Classes.Frieren))
end

return Manager