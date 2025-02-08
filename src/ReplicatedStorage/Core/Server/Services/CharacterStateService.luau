--!strict
local BaseValues = require(game.ReplicatedStorage.Core.Shared.Metadata.BaseValues)
local CharacterStats = require(game.ReplicatedStorage.Core.Shared.Metadata.CharacterStats)
local GlobaEventService = require(game.ReplicatedStorage.Core.Shared.Services.GlobalEventService)

export type CharacterStates = {
    Health : BaseValues.Float,
    Stamina : BaseValues.Float,

    WalkSpeed : BaseValues.Integer,
    ParentId : BaseValues.Integer,

    IsStunned : BaseValues.Boolean,
    IsBlocking : BaseValues.Boolean,
    IsRunning : BaseValues.Boolean,
    IsAlive : BaseValues.Boolean,
    IsTired : BaseValues.Boolean,
}

local topicData, topicMetadata = GlobaEventService.newTopic("CharacterUpdate", true)
local ActiveCharacters : {CharacterStates} = {}
local Service = {}

function Service.GetCharacterStatesById(userId : number)
   local states : CharacterStates?
   for _, state : CharacterStates in ActiveCharacters do
        local stateParent : number = BaseValues.GetValue(state.ParentId)
        if stateParent == userId then
            states = state
        end

        if states then
            break
        end
   end

   return states
end

function Service.UpdateCharacterState(userId : number, stateName : string, value : boolean)
    local charStates = Service.GetCharacterStatesById(userId)
    assert(charStates, `No character states for {userId}`)

    local currentStateValue : any = charStates[value]
    assert(currentStateValue, `No state value found under name {stateName}`)

end

function Service.GetServiceTopic()
    return topicData, topicMetadata
end

function Service.NewCharacter(instance : {UserId : number})
    local baseStats : any  = CharacterStats.CreateNewCharacterStats()
    baseStats.ParentId = BaseValues.Integer(instance.UserId)
    baseStats.IStunned = BaseValues.Boolean(false)
    baseStats.IsBlocking = BaseValues.Boolean(false)
    baseStats.IsRunning = BaseValues.Boolean(false)
    baseStats.IsAlive = BaseValues.Boolean(false)
    baseStats.IsTired = BaseValues.Boolean(false)
    table.insert(ActiveCharacters, baseStats)
    return baseStats :: CharacterStates
end

local function _update(dt : number)
    for _, stats : CharacterStates in ActiveCharacters do
        local updateArgs =   {stats}
        GlobaEventService.MassPublish({
            "UpdateStamina",
            "UpdateWalkSpeed"
        },
        {
            updateArgs,
            updateArgs,
        }
    )
    end
end

topicData.Event:Connect(_update)
return (function()
    return Service
end)
