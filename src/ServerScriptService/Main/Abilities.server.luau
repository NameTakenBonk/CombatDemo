-- Will be modulated soon

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Teleport = ReplicatedStorage.Teleport :: RemoteEvent
local Replicate = ReplicatedStorage.Objects.Events.Replicate :: RemoteEvent

local Types = require(ReplicatedStorage.Core.Types)

local Abilities = { }
for _, class in ServerScriptService.AbilitiesServer:GetChildren() do
    Abilities[class.Name] = { }
    for _, ability in class:GetChildren() do
        local mod = require(ability) 
        Abilities[class.Name][ability.Name] = mod
    end
end
print(Abilities)

Teleport.OnServerEvent:Connect(function(player, hit)
    local particleClone1 = ReplicatedStorage.Objects.Abillities.Frieren.Particles.TP1:Clone()
    particleClone1.CFrame = player.Character.HumanoidRootPart.CFrame
    particleClone1.Parent = workspace
    for _, child in particleClone1:GetDescendants() do
        if not child:IsA("ParticleEmitter") then continue end
        child:Emit(child:GetAttribute("EmitCount"))
    end

    player.Character.HumanoidRootPart.Position = (hit + Vector3.new(0, 2.5, 0))

    local particleClone2 = ReplicatedStorage.Objects.Abillities.Frieren.Particles.TP2:Clone()
    particleClone2.CFrame = player.Character.HumanoidRootPart.CFrame
    particleClone2.Parent = workspace
    for _, child in particleClone2:GetDescendants() do
        if not child:IsA("ParticleEmitter") then continue end
        child:Emit(child:GetAttribute("EmitCount"))
    end
end)

Replicate.OnServerEvent:Connect(function(player: Player, class: string, ability: string, ...)
    -- I will add sanity checks later but I can'r right now as there is no proper character system
    print("Replicate Server", class, ability, ...)
    print(Abilities)
    Abilities[class][ability](class, ability, player, ...)
end)