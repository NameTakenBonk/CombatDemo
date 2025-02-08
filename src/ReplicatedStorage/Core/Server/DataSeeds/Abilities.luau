--!strict
export type Ability = {
    Name : string,
    Id : number,
    Description : string,

    OnActivate : (caster : Player) -> nil,
    Cooldown : number,
}

return function() : {Ability}
    return {
       {
        Name = "TestRegular", 
        Id = 1, 
        Description = "Test Regular Ability", 
        OnActivate = function(plr)
            --Ability logic here
       end,
       Cooldown = 1,
    }
    }
end
