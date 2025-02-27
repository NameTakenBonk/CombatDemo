--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Teleport = ReplicatedStorage.Teleport :: RemoteEvent

local Types = require(script.Parent.Parent.Parent.Parent.Types)

return {
    Title = "Teleportation",
    Description = "Frieren teleports a short distance, evading attacks or repositioning herself.",
    Cooldown = 15,
    Cost = 40,
    Animation = 95844200176981,
    OnActivate = function(hit)
        Teleport:FireServer(hit)
    end
} :: Types.Ability  