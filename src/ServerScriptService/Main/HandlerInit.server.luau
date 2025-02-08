--!strict
local Handlers = game.ReplicatedStorage.Core.Server.Handlers
for _, H  in Handlers:GetChildren() do
    if H:IsA("ModuleScript") then
        task.spawn(function()
            require(H)
        end)
    end
end
