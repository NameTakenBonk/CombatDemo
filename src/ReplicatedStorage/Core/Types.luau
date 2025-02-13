local Types = {}

export type Ability = {
    Title : string,
    Description : string,
    Cooldown : number,
    Cost : number,
    OnActivate : any
}

export type Character = {
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
    Abilities : { Ability }
}

return Types