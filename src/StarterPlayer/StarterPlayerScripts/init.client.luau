
for _, module in script:GetChildren() do
	if not module:IsA("ModuleScript") then
		return
	end

	local success, err = pcall(function()
		require(module):Init()
	end)

	if not success then
		warn("Failed to initiate "..module.Name.."client module due to", err)
	end
end
