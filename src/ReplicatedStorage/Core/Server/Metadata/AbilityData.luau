--!strict
local AbilityDataSeed = require(game.ReplicatedStorage.Core.Server.DataSeeds.Abilities)
type Ability = AbilityDataSeed.Ability

local abilities : {Ability} = {}
local util = {}

function util.GetAbilityById(abilityId : number) : Ability?
    local foundAbility : Ability? = nil
    for _, ability : Ability in abilities do
        if ability.Id == abilityId then
            foundAbility = ability
            break
        end
    end

    return foundAbility
end

function util.RegisterNewAbility(name : string, id : number, info : string, onActivate : any, cooldown : number)
    local ability : Ability = {
        Name = name,
        Id = id,
        Description = info,

        OnActivate = onActivate,
        Cooldown = cooldown,
    }

    table.insert(abilities, ability)
end

for _, ab in AbilityDataSeed() do
    util.RegisterNewAbility(ab.Name, ab.Id, ab.Description, ab.OnActivate, ab.Cooldown)
end


return util
