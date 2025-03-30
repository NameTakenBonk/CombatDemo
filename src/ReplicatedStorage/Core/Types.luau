local Types = {}

export type Ability = {
    Title : string,
    Description : string,
    Cooldown : number,
    Cost : number,
    Animation : number | AnimationTrack,
    OnActivate : (any) -> nil,
    ClientReplication : (any) -> nil,
    CustomSettings : {any}?
}

export type Class = {
    Info : {
        Name : string,
        Title : string,
        Role : string, 
        Pantheon : string,
        Type: {string}
    },
    Stats : {
        Health : number,
        Mana : number,
        Speed : number,
        Range : number,
        AttackPerSec : number,
        MagicPower : number,
        PhysicalProtection : number,
        MagicalProtection : number,
        HP5 : number,
        MP5 : number
    },
    Abilities : { 
        Passive : Ability,
        Ability1 : Ability,
        Ability2 : Ability,
        Ability3 : Ability,
        Ultimate : Ability
     }
}

return Types