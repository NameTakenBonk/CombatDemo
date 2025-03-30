local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicate = ReplicatedStorage.Objects.Events.Replicate :: RemoteEvent

local Abilities = require(script.Abilities)

local Manager = {}

function Manager:Init()
    print("loaded")
    Abilities.LoadAbilities(require(ReplicatedStorage.Core.Configs.Classes.Yennefer))

    Replicate.OnClientEvent:Connect(function(...)
        Abilities.Replicate(...)
    end)
end

return Manager