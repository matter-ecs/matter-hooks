local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

--[=[
	Used to store memoized values that update when dependencies change.

	This is commonly used to perform tasks that are expensive and only need to be
	updated occasionally. The result of the operation will be memoized so you can
	retrieve the same values repeatedly after the action has been run.

	The values are only recalculated when the dependencies change. This can be
	used for values that need to be updated in response to something else.

	:::caution
	If no dependency array is provided, new values will be recalculated every
	time. For actions that only need to run once ever, an empty array can be
	provided.
	:::

	```lua
	local result = useMemo(function(): number
		return expensiveOperation(dependency)
	end, { dependency })
	```

	@within Hooks

	@return T... -- The memoized values
]=]
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
