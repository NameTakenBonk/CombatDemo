--!strict
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)

local Players : Players = game:GetService("Players")

local function onJoin(player : Player)
    local topic
    repeat 
        topic= GlobaEventService.GetTopicFromName("PlayerJoined")
        task.wait()
    until topic

    GlobaEventService.PublishToTopic("PlayerJoined", player)
end

local function onLeave(player : Player)
    GlobaEventService.PublishToTopic("PlayerLeave", player)
end

Players.PlayerAdded:Connect(onJoin)
Players.PlayerRemoving:Connect(onLeave)
