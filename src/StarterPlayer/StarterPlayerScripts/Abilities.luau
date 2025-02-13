--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Types = require(ReplicatedStorage.Core.Types)

local Abilities = {}

function Abilities.LoadAbility(module : ModuleScript)
    local Config = require(module) :: Types.Ability

    -- Connecting the activation key to the function inside the config
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Config.ActivationKey then
            Config.OnActivate()
        end
    end)
end

return Abilities