--!strict
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)
local AbilityData = require(game.ReplicatedStorage.Core.Server.Metadata.AbilityData)

local topics : {[string] : any} = {
    ActivateAbility = function(caster : Player, abilityId : number)
        local abilityData = AbilityData.GetAbilityById(abilityId)
        assert(abilityData)

        print(caster, abilityData)
    end
}

for name , handler in topics do
    local topicData = GlobaEventService.newTopic(name, false)
    topicData.Event:Connect(handler)
end

return 0