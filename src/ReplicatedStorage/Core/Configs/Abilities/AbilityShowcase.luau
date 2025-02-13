--!strict

local Types = require(script.Parent.Parent.Parent.Types)

return {
    ActivationKey = Enum.KeyCode.F,
    OnActivate = function()
        print("test")
    end
} :: Types.Ability