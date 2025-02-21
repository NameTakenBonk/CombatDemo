--@EnumEnv
-- Services --
local UserInputService = game:GetService("UserInputService")

-- Class --
-- @class SimpleMouse
local SimpleMouse = {}
SimpleMouse.__index = function(self, key)
	-- Return as indexed --
	if key == "Target" then
		return self:_getTarget()
	end

	-- Return as "self" --
	return rawget(SimpleMouse, key) or rawget(self, key)
end

-- Types --
export type SimpleMouse = typeof(SimpleMouse) & {
	_connections: { RBXScriptConnection },
	Target: Instance?,
	_mouseLocation: UDim2,
	_rayLength: number,
	_raycastParams: RaycastParams?,
}

-- Variables --
local Camera = workspace.CurrentCamera
local DefaultParams = RaycastParams.new()

-- Local Functions --
--[=[
    Uses viewport point to ray to cast a ray from the camera with a certain position.
    @return Ray
--]=]
local function CastRayFromCamera(mouseLocation: UDim2): Ray?
	local ray = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y, 0)
	return ray
end

--[=[
    Fires to 3D Space and retuns a ray.
    @param ray --> Ray --> The ray casted from ViewportPoint.
    @param rayLength --> number --> The max length of the ray.
    @param raycastParms --> RaycastParams? --> Optional raycast params.
    @return RaycastResult?
--]=]
local function FireTo3DSpace(ray: Ray, rayLength: number, raycastParms: RaycastParams?): RaycastResult?
	local threeDeeSpaceRay = workspace:Raycast(ray.Origin, ray.Direction * rayLength, raycastParms or DefaultParams)
	return threeDeeSpaceRay
end

-- Class Functions --
--[=[
    Creates a new instance of SimpleMouse.
    @param rayLength --> number? --> The maximum reach distance.
    @return The newly created SimpleMouse instance.
--]=]
function SimpleMouse.new(rayLength: number?): SimpleMouse
	-- Define self --
	local self: SimpleMouse = setmetatable({}, SimpleMouse) :: any

	-- Load self --
	self._connections = {}
	self._rayLength = rayLength or 1000
	self._raycastParams = DefaultParams
	self._mouseLocation = UserInputService:GetMouseLocation()

	-- Connections --
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(inputObject: InputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
			self:_updateMouseLocation()
		end
	end)

	-- Store connections --
	table.insert(self._connections, inputChangedConnection)

	-- Return self --
	return self
end

--[=[
    Updates the mouse location every MouseMovement.
--]=]
function SimpleMouse._updateMouseLocation(self: SimpleMouse)
	self._mouseLocation = UserInputService:GetMouseLocation()
end

--[=[
    Returns the on-screen position of the mouse.
    @param UDIM2
--]=]
function SimpleMouse.Get2DPosition(self: SimpleMouse): UDim2
	return self._mouseLocation
end

--[=[
    Gets the 3D Position of the mouse.
    @param raycastParams --> RaycastParams? --> The optional raycast params.
    @return Vector3
--]=]
function SimpleMouse.Get3DPosition(self: SimpleMouse, raycastParams: RaycastParams?): Vector3
	-- Cover --
	local cameraRay = CastRayFromCamera(self._mouseLocation)
	local threeDeeRay = FireTo3DSpace(cameraRay, self._rayLength, raycastParams or self._raycastParams)
	local supposedEnd = cameraRay.Origin + (cameraRay.Direction.Unit * self._rayLength)

	-- Final --
	return threeDeeRay and threeDeeRay.Position or supposedEnd
end

--[=[
    Sets the 3D Raycast Parameters.
    @param raycastParams --> RaycastParams --> The new raycast params.
--]=]
function SimpleMouse.Set3DRaycastParams(self: SimpleMouse, raycastParams: RaycastParams)
	self._raycastParams = raycastParams
end

--[=[
    Internal function which returns the current target.
    @private
--]=]
function SimpleMouse._getTarget(self: SimpleMouse, raycastParams: RaycastParams?): Instance?
	-- Cover --
	local cameraRay = CastRayFromCamera(self._mouseLocation)
	local threeDeeRay = FireTo3DSpace(cameraRay, self._rayLength, raycastParams)

	-- Final --
	return threeDeeRay and threeDeeRay.Instance or nil
end

--[=[
    Cleans up the SimpleMouse instance.
--]=]
function SimpleMouse.Destroy(self: SimpleMouse)
	-- Handle connections --
	for _, connection: RBXScriptConnection in self._connections :: any do
		if connection and typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end

	-- Handle instances --
	if self._raycastParams then
		self._raycastParams = nil
	end

	-- Handle tables --
	table.clear(self._connections)
end

-- End --
return SimpleMouse :: SimpleMouse
