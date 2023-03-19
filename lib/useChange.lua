local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

--[=[
	Activates when the provided dependencies change.

	:::caution
	If no dependency array is provided, this returns true always. For actions that
	only need to run once ever, an empty array can be provided.
	:::

	```lua
	if useChange({ dependency }) then
		dependingOperation(dependency)
	end
	```

	@within Hooks

	@return boolean -- True if the dependencies have changed, false otherwise
]=]
local function useChange(dependencies: { unknown }, discriminator: unknown?): boolean
	local storage = Matter.useHookState(discriminator)
	local previous = storage.dependencies
	storage.dependencies = dependencies
	return diffTables(dependencies, previous)
end

return useChange
