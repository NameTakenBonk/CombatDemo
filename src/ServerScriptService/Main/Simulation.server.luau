local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SecureCast = require(ReplicatedStorage.Packages["secure-cast"])
SecureCast.Initialize()

local Simulate = ReplicatedStorage.Simulate :: RemoteEvent
local Impact = Instance.new("BindableEvent")

local Classes = {}

for _, class in ReplicatedStorage.Core.Configs.Classes:GetChildren() do
    if not class:IsA("ModuleScript") then return end
    Classes[class.Name] = require(class)
end

-- // I will secure this later right now I can't
Simulate.OnServerEvent:Connect(function(player, hit, origin, config, timestamp)
    local latency = (workspace:GetServerTimeNow() - timestamp)
    local interpolation = (player:GetNetworkPing() + SecureCast.Settings.Interpolation)

    --> Validate the latency and avoid players with very slow connections
    if (latency < 0) or (latency > 800) then
        return
    end

    local direction = (hit - origin).Unit

    Simulate:FireAllClients(player, config.Modifier, origin, direction, config.Projectile)

    local modifier = config.Modifier
    modifier.OnImpact = Impact

    SecureCast.Cast(player, "Bullet", origin, direction, timestamp - interpolation, config.Projectile, modifier)
end)

Impact.Event:Connect(function(_, _, Caster : Player, Velocity : Vector3, ImpactedPart : BasePart, Normal : Vector3, ImpactPosition : Vector3, Material : EnumItem, ...)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end

		if not character.HumanoidRootPart then
			continue
		end

		local root = character.HumanoidRootPart	
		local magnitude = (root.Position - ImpactPosition).Magnitude

		if magnitude <= 15 then
			local constant = 80
			local clamp = 2
			local damping = 3.5
			local distanceValue = (constant/(magnitude + clamp)) ^ (1/damping)

			character.Humanoid.Health -= distanceValue * 100

			task.wait(0.1)
		elseif magnitude <= 60 then
			local rayParams = RaycastParams.new()
			rayParams.RespectCanCollide = false

			local rayCast = workspace:Raycast(ImpactPosition, (root.Position - ImpactPosition) * 100, rayParams)

			if rayCast then
				local hit = rayCast.Instance

				local partInCharacter = character:FindFirstChild(hit.Name)
				if partInCharacter then
					character.Humanoid.Health -= 100
				end
			end
		else continue
		end
	end
end)