local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("Replicate", function(Class, Ability, ...)
    print("1")
    assert(type(Class) == "string")
    print("2")
    assert(type(Ability) == "string")
    print("3")

    return Class, Ability, ...
end)