local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

local function useReducer<S, A>(
	reducer: (state: S, action: A) -> S,
	initialState: S,
	discriminator: unknown?
): (S, (action: A) -> ())
	local storage = Matter.useHookState(discriminator)

	if storage.state == nil then
		storage.state = initialState
	end

	local dependencies = { storage.state }

	-- We want to be able to use this dispatch function as a dependency for other
	-- hooks. Memoizing it this way based on state changes allows us to do that
	-- without it updating dependencies every frame.
	if diffTables(dependencies, storage.dependencies) then
		storage.dependencies = dependencies

		storage.dispatch = function(action: A)
			storage.state = reducer(storage.state, action)
		end
	end

	return storage.state, storage.dispatch
end

return useReducer
