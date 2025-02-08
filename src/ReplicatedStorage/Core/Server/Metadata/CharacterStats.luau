--!strict
local BaseUtils = require(game.ReplicatedStorage.Core.Shared.GeneralUtility)
local BaseValues = require(game.ReplicatedStorage.Core.Server.Metadata.BaseValues)
local BaseStats = require(game.ReplicatedStorage.Core.Server.DataSeeds.BaseStats)()

local ReadOnlyStats = BaseUtils.MakeTableReadOnly(BaseStats)
local StatUtils = {}
function StatUtils.GetReadOnlyBaseStats()
    return ReadOnlyStats :: typeof(BaseStats)
end

function StatUtils.CreateNewCharacterStats()
    return {
        Health = BaseValues.Float(BaseStats.MaxHealth),
        Stamina = BaseValues.Float(BaseStats.MaxStamina),
        WalkSpeed = BaseValues.Float(BaseStats.DefaultWalkSpeed),
    }
end

return StatUtils
