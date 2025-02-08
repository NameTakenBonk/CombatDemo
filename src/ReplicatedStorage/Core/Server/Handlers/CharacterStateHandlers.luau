--!strict
local BaseValues = require(game.ReplicatedStorage.Core.Server.Metadata.BaseValues)
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)

local topics : {[string] : any} = {
    UpdateRunning = function(states)
        local isRunning = BaseValues.GetValue(states.IsRunning)
        BaseValues.SetValue(states.IsRunning, not isRunning)
    end,

    UpdateBlocking = function(states)
        local isBlocking = BaseValues.GetValue(states.IsBlocking)
        BaseValues.SetValue(states.IsRunning, false)
        BaseValues.SetValue(states.IsBlocking, not isBlocking)    
    end,

    UpdateStunned = function(states)
        local isStunned = BaseValues.GetValue(states.IsStunned)
        BaseValues.SetValue(states.IsRunning, false)
        BaseValues.SetValue(states.IsBlocking, false)
        BaseValues.SetValue(states.IsStunned, not isStunned)
    end,

    UpdateAlive = function(states)
        local isAlive = BaseValues.GetValue(states.IsAlive)
        BaseValues.SetValue(states.IsRunning, false)
        BaseValues.SetValue(states.IsBlocking, false)
        BaseValues.SetValue(states.IsStunned, false)
        BaseValues.SetValue(states.IsAlive, not isAlive)
    end,

    UpdateTired = function(states)
        local isTired = BaseValues.GetValue(states.IsTired)
        BaseValues.SetValue(states.IsRunning, false)
        BaseValues.SetValue(states.IsBlocking, false)
        BaseValues.SetValue(states.IsStunned, false)
        BaseValues.SetValue(states.IsTired, not isTired)
    end
}

for name , handler in topics do
    local topicData = GlobaEventService.newTopic(name, false)
    topicData.Event:Connect(handler)
end

return 0