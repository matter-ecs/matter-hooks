local Package = script.Parent
local Matter = require(Package.Parent.Matter)

--[=[
	Used to store and retrieve values in a map based on a given key.

	This hook can be used to create a map of values that can be accessed and
	updated from within a system. The map is initialized with a default value that
	is used when a key is accessed for the first time.

	:::tip
	While this hook is useful in certain situations it may not be appropriate for
	every situation. Often a variable or table can serve the same purpose.
	:::

	:::caution
	Using non-unique keys may result in unexpected behavior or errors.
	:::

	```lua
	for id in world:query(Component) do
		local name = useMap(id, "Unknown")
		displayName(name.value)
	end
	```

	The `value` field can be updated directly when updating the key in the map.

	```lua
	for id in world:query(Component) do
		local rendered = useMap(id, false)
		if condition then
			rendered.value = true
		elseif otherCondition then
			rendered.value = false
		end
	end
	```

	@within Hooks

	@return { value: T } -- The associated value
]=]
local function useMap<T>(key: unknown, defaultValue: T): { value: T }
	local storage = Matter.useHookState(key)
	if not storage.value then
		storage.value = {
			value = defaultValue,
		}
	end
	return storage.value
end

return useMap
