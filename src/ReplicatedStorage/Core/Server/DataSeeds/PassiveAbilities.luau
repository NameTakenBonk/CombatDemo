--!strict
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)
local CharacterService = require(game.ReplicatedStorage.Core.Server.Services.CharacterStateService)()
local BaseStatValues = require(game.ReplicatedStorage.Core.Server.DataSeeds.BaseStats)()

export type PassiveAbility = {
    Name : string,
    Id : number,
    OnTick : (owner : Player) -> nil,
    TickRate : number,
}

return function () : {PassiveAbility}
    return {
        {
            Name = "PassiveHealthRegen",
            Id = 1,
            OnTick = function(owner : Player)
                local characterStats = CharacterService.GetCharacterStatesById(owner.UserId)
                GlobaEventService.PublishToTopic("UpdateHealth", characterStats)
            end,

            TickRate = BaseStatValues.Multipliers.HealthRegen
        }
    }
end
