--!strict

return function()
    return {
        --Base Stats
        MaxHealth = 100,
        MaxStamina = 100,
        DefaultWalkSpeed = 20,
    
        Multipliers = {
            HealthRegen = 1 / 600,
            StaminaRegen = 1 / 400,
            IsTiredRegen = 1 / 500,
    
            IsRunningDrain = 1 / 200,
            IsBlockingDrain = 1 / 150,
            IsStunnedDrain = 1 / 100,
    
            BlockAttackStaminaDrain = 25,
    
            BaseDamage = 1,
            BaseMitigation = 1,
    
            IsRunningSpeed = 1.5,
            IsBlockingSpeed = .5,
            IsStunnedSpeed = 0,
            IsTiredSpeed = .75,
        }
    }
end
