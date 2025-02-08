--!strict
local PlayerStats = require(game.ReplicatedStorage.Core.Server.DataSeeds.PlayerLeaderstats)
local PlayerStoreData = require(game.ReplicatedStorage.Core.Server.DataSeeds.DefaultPlayerStoreData)
local GlobalEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)
local CustomStore = require(game.ReplicatedStorage.Core.Server.Services.DataStoreService)

-- Get data connections
local PlayerStatsStore : CustomStore.DataConnection = CustomStore.GetDataConnection("PlayerLeaderstats")
local PlayerPurchaseStore : CustomStore.DataConnection = CustomStore.GetDataConnection("PlayerPurchaseStore")

type PlayerStatsData = typeof(PlayerStats())
type PlayerPurchases = typeof(PlayerStoreData())

-- Store player data in a dictionary keyed by the player's universal key
local LoadedPlayerData : { [string]: {
    Parent: Player,
    Leaderstats: PlayerStatsData,
    StoreData: PlayerPurchases,
    OnLeaveCallbacks: {() -> ()}
} } = {}

-- Handler for when a player joins
local function onPlayerJoin(player: Player)
    local universalKey = tostring(player.UserId)
    local playerStats: PlayerStatsData = PlayerStatsStore:GetAsync(universalKey) or PlayerStats()
    local playerPurchases: PlayerPurchases = PlayerPurchaseStore:GetAsync(universalKey) or PlayerStoreData()
    
    LoadedPlayerData[universalKey] = {
        Parent = player,
        Leaderstats = playerStats,
        StoreData = playerPurchases,
        OnLeaveCallbacks = {
            function()
                PlayerStatsStore:UpdateAsync(universalKey, function(old)
                    return playerStats or old
                end)
            end,
            function()
                PlayerPurchaseStore:UpdateAsync(universalKey, function(old)
                    return playerPurchases or old
                end)
            end,
        },
    }
end

-- Handler for when a player leaves
local function onPlayerLeave(player: Player)
    local universalKey = tostring(player.UserId)
    local data = LoadedPlayerData[universalKey]
    if data then
        task.spawn(function()
            for _, callback in ipairs(data.OnLeaveCallbacks) do
                callback()
            end
        end)
        LoadedPlayerData[universalKey] = nil -- Cleanup the player's data
    end
end

-- Bind events using GlobalEventService
GlobalEventService.newTopic("PlayerJoined", false).Event:Connect(onPlayerJoin)
GlobalEventService.newTopic("PlayerLeave", false).Event:Connect(onPlayerLeave)

return 0