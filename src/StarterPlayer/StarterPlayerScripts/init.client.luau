
repeat
	task.wait()
until game:IsLoaded()

local ModuleTable = { }

local function LoadModules()
	print(script:GetChildren())
	for _, module in script:GetChildren() do
		if not module:IsA("ModuleScript") then
			return
		end
	
		local success, err = pcall(function()
			require(module):Init()
		end)
	
		if success then
			table.insert(ModuleTable, module)
		else
			warn("Failed to initiate "..module.Name.."client module due to", err)
		end
	end
end
LoadModules()

if #ModuleTable <= 0 then
	repeat
		warn("Retrying to load all modules!")
		print(script.Parent.Parent)
		LoadModules()
		task.wait(5)
	until #ModuleTable > 0
end

print("Loaded all modules")