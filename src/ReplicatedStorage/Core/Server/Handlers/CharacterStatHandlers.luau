--!strict
local BaseValues = require(game.ReplicatedStorage.Core.Server.Metadata.BaseValues)
local CharacterStats = require(game.ReplicatedStorage.Core.Server.Metadata.CharacterStats)
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)

--Order that we calculate stats based on states
local StatUpdatePriority = {
    "IsStunned",
    "IsTired",
    "IsBlocking",
    "IsRunning",
}

local topics : {[string] : any} = {
    UpdateHealth = function(stats)
        local baseStatValues = CharacterStats.GetReadOnlyBaseStats()
        local currentHealth : number = BaseValues.GetValue(stats.Health)
        BaseValues.SetValue(stats.Health, math.clamp(currentHealth + (currentHealth * baseStatValues.Multipliers.HealthRegen), 0, baseStatValues.MaxHealth))

        if BaseValues.GetValue( stats.Health) <= 0 then
            GlobaEventService.PublishToTopic("UpdateAlive", stats)
        end
    end,

    UpdateStamina = function(stats)
        local baseStatValues = CharacterStats.GetReadOnlyBaseStats()
        local currentStamina : number = BaseValues.GetValue(stats.Stamina)
        local changeAmount : number
        
        for priority, stateName : string in ipairs(StatUpdatePriority) do
            if BaseValues.GetValue(stats[stateName]) then
                changeAmount = baseStatValues.Multipliers[stateName .. "Drain"] or baseStatValues.Multipliers[stateName .. "Regen"]
                break
            end
        end

        if not changeAmount then
            changeAmount = baseStatValues.Multipliers.StaminaRegen
        end

        BaseValues.SetValue(stats.Stamina, math.clamp(currentStamina + changeAmount, 0, baseStatValues.MaxStamina))

        if BaseValues.GetValue( stats.Stamina) <= 0 then
            GlobaEventService.PublishToTopic("IsTired", stats)
        end
    end,

    UpdateWalkSpeed = function(stats)
        local baseStatValues = CharacterStats.GetReadOnlyBaseStats()
        local newWalkspeed : number

        for priority, stateName : string in ipairs(StatUpdatePriority) do
            if BaseValues.GetValue(stats[stateName]) then
                newWalkspeed = baseStatValues.DefaultWalkSpeed * baseStatValues.Multipliers[stateName .. "Speed"]
                break
            end
        end

        if not newWalkspeed then
            newWalkspeed = baseStatValues.DefaultWalkSpeed
        end

        BaseValues.SetValue(stats.WalkSpeed, newWalkspeed)
    end
}

for name , handler in topics do
    local topicData = GlobaEventService.newTopic(name, false)
    topicData.Event:Connect(handler)
end

return 0