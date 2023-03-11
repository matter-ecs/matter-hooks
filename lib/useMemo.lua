local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

local function useMemo<T...>(
	callback: () -> T...,
	dependencies: { unknown },
	discriminator: unknown?
): T...
	local storage = Matter.useHookState(discriminator)

	if storage.value == nil or diffTables(dependencies, storage.dependencies) then
		storage.dependencies = dependencies
		storage.value = { callback() }
	end

	-- Luau claims this is a type error. We have specific knowledge that the only
	-- thing ever stored in `storage.value` is a table that captures the return
	-- value of a function that returns `T...`. We also know that it is always
	-- stored at least once before reaching this point.
	return unpack(storage.value)
end

return useMemo
