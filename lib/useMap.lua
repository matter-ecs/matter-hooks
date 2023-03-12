local Package = script.Parent
local Matter = require(Package.Parent.Matter)

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
