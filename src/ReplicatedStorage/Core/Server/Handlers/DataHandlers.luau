--!strict
local PlayerStats = require(game.ReplicatedStorage.Core.Shared.DataSeeds.PlayerLeaderstats)
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)

local CustomStore = require(game.ReplicatedStorage.Core.Server.Services.DataStoreService)
local PlayerStatsStore : CustomStore.DataConnection = CustomStore.GetDataConnection("PlayerStats")

local LoadedPlayerData : {{Parent : Player, Data : any, Connection : CustomStore.DataConnection}} = {}

type PlayerStatsData = typeof(PlayerStats())

local topics : {[string] : any} = {
    PlayerJoined = function(player : Player)
        local playerStats : PlayerStatsData? = PlayerStatsStore:GetAsync(tostring(player.UserId))
        local data = {
            Parent = player,
            Data = playerStats or PlayerStats(),
            Connection = PlayerStatsStore
        }
    
        table.insert(LoadedPlayerData, data)
    end,

    PlayerLeave = function(player : Player)
        for i, v in LoadedPlayerData do
            if v.Parent ~= player then
                continue
            end
    
            task.spawn(function()
                v.Connection:UpdateAsync(tostring(player.UserId), function(old)
                    return v.Data or old
                end)
            end)
        end
    end
}

for name , handler in topics do
    local topicData = GlobaEventService.newTopic(name, false)
    topicData.Event:Connect(handler)
end

return 0