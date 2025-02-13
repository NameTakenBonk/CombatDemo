local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = {}

-- Initialising all modules under the client
for _, module in script:GetChildren() do
    if module:IsA("ModuleScript") then
        local name = module.Name
        Modules[name] = require(module)
        
        local success, response = pcall(function()
            Modules[name]:Init()
        end)

        if not success then warn(response) end
    end
end

-- I will need to add a proper controller to this
Modules.Abilities.LoadAbility(ReplicatedStorage.Core.Configs.Abilities.AbilityShowcase)