local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

local function useChange(dependencies: { unknown }, discriminator: unknown?): boolean
	local storage = Matter.useHookState(discriminator)
	local previous = storage.dependencies
	storage.dependencies = dependencies
	return diffTables(dependencies, previous)
end

return useChange
