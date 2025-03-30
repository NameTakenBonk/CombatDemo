--!strict

local Types = require(script.Parent.Parent.Parent.Types)

return {
    Info = {
        Name = "Yennefer", -- MOST STATS ARE NOT ACCURATE
        Title = "The Mage of Eternity",
        Role = "Mage",
        Pantheon = "Fantasy Realm",
        Type = {"Ranged", "Magical"}
    },

    Stats = {
        Health = 450,
        Mana = 300,
        Speed = 360,
        Range = 55,
        AttackPerSec = 0.95,
        MagicPower = 0,
        PhysicalProtection = 12,
        MagicalProtection = 30,
        HP5 = 7,
        MP5 = 5
    },

    Abilities = {
        --Passive = require(script.HealingArcane),
        Ability1 = require(script.AracaneDash),
        Ability2 = require(script.ChaosStorm),
        Ability3 = require(script.EldritchBindings),
        Ultimate = require(script.ArcaneAscension)
    }
} :: Types.Class