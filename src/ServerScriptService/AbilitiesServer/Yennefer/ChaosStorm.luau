local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Replicate = ReplicatedStorage.Objects.Events.Replicate :: RemoteEvent

return function (class: string, ability: string, player: Player)
    Replicate:FireAllClients(class, ability, player.Character)
end