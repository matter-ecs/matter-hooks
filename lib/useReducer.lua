local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

--[=[
	Used to store a stateful value that is updated by a reducer function.

	If you're familiar with Redux/Rodux you'll be familiar with the concept of
	reducers for state management already.

	Every time the dispatch is called, the reducer function is called to provide
	the updated state. It passes an action with information the reducer uses while
	updating the state.

	:::tip
	Its common to use the field `type` of the action to indicate what sort of
	action is being dispatched. Any remaining fields are open to be extended and
	used when calculating the new state.
	:::

	The reducer creates a new state based on the current state and the action
	passed by the reducer. The state is immutable and shouldn't be changed
	directly.

	:::caution
	Nothing is preventing your reducer from mutating state or causing side
	effects. If you do, things may not act as you expect.
	:::

	```lua
	type State = {
		value: number,
	}

	type Action = {
		type: "increase" | "decrease",
	}

	local state, dispatch = useReducer(function(state: State, action: Action): State
		if action.type == "increase" then
			return {
				value = state.value + 1,
			}
		elseif action.type == "decrease" then
			return {
				value = state.value - 1,
			}
		end

		return state
	end, {
		value = 0,
	})

	if state.value > 10 then
		highValueAction()
	end

	if increaseCondition then
		dispatch("increase")
	elseif decreaseCondition then
		dispatch("decrease")
	end
	```

	@within Hooks

	@return S -- The current state
	@return (action: A) -> () -- The dispatch function
]=]
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
