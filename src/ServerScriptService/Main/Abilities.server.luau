-- Will be modulated soon

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Teleport = ReplicatedStorage.Teleport :: RemoteEvent

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