local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

--[=[
	Indicates that an async action has succeeded and holds a value.

	```lua
	local result = ready.result

	if result.success then
		processValue(result.value)
	end
	```

	.success true
	.value T

	@within Hooks
	@interface AsyncSuccess
]=]
export type AsyncSuccess<T> = {
	success: true,
	value: T,
}

--[=[
	Indicates that an async action has failed and holds an error.

	```lua
	local result = ready.result

	if not result.success then
		processError(result.error)
	end
	```

	.success false
	.error E

	@within Hooks
	@interface AsyncError
]=]
export type AsyncError<E> = {
	success: false,
	error: E,
}

--[=[
	Indicates whether an async action succeeded or failed.

	The `success` field always exists. A value of `true` indicates that the
	operation succeeded and is an [AsyncSuccess] containing the value from the
	async action. A value of `false` indicates that the operation failed and is an
	[AsyncError] containing an error from the async action.

	```lua
	local result = ready.result

	if result.success then
		-- The action was successful and we have a value.
	else
		-- The action failed and we have an error.
	end
	```

	@within Hooks
	@type AsyncResult AsyncSuccess<T> | AsyncError<E>
]=]
export type AsyncResult<T, E> = AsyncSuccess<T> | AsyncError<E>

--[=[
	Indicates that an async action has completed and the result is ready.

	```lua
	local ready = useAsync(...)

	if ready.completed then
		processResult(ready.result)
	end
	```

	.completed true
	.result AsyncResult<T, string>

	@within Hooks
	@interface AsyncComplete
]=]
export type AsyncComplete<T> = {
	completed: true,
	result: AsyncResult<T, string>,
}

--[=[
	Indicates that an async action has not yet completed.

	.completed false

	@within Hooks
	@interface AsyncIncomplete
]=]
export type AsyncIncomplete = {
	completed: false,
}

--[=[
	Indicates whether an async action has completed.

	The `completed` field always exists. A value of `true` indicates that the
	action is completed and is an [AsyncComplete] containing an [AsyncResult]. A
	value of `false` indicates the action has not yet completed and is an
	[AsyncIncomplete] that does not yet have a result.

	```lua
	local ready = useAsync(...)

	if ready.completed then
		-- The action has completed and we can use the result.
	else
		-- We're still waiting for the action to complete.
	end
	```

	@within Hooks
	@type AsyncReady AsyncComplete<T> | AsyncIncomplete
]=]
export type AsyncReady<T> = AsyncComplete<T> | AsyncIncomplete

local function cleanup(storage)
	if storage.thread then
		task.cancel(storage.thread)
	end
	storage.ready = {
		completed = false,
	}
end

--[=[
	Used to store the result of an asynchronous action.

	This is commonly used to perform tasks that take a long time to complete and
	only need to be done occasionally. The result of the operation is memoized so
	you can retrieve the same value repeatedly after the action has been run.

	The action is only performed when the dependencies change. This can be used
	for values that need to be updated in response to something else.

	:::caution
	If no dependency array is provided, new values will be recalculated every
	time. For actions that only need to run once ever, an empty array can be
	provided.
	:::

	Returns an [AsyncReady] that indicates completion. This type in turn provides
	an [AsyncResult] that indicates whether the operation succeeded or failed.

	If the hook is no longer called, or if the dependencies change before an
	action is completed, any in progress action is canceled early.

	```lua
	local ready = useAsync(function(): number
		return asyncOperation(dependency)
	end, { dependency })

	if ready.completed then
		if ready.result.success then
			updateWithAsyncValue(ready.result.value)
		else
			cancelBehavior()
		end
	end
	```

	@within Hooks

	@return AsyncReady<T> -- The completion status
]=]
local function useAsync<T>(
	callback: () -> T,
	dependencies: { unknown },
	discriminator: unknown?
): AsyncReady<T>
	local storage = Matter.useHookState(discriminator, cleanup)

	if diffTables(dependencies, storage.dependencies) then
		cleanup(storage)
		storage.dependencies = dependencies

		storage.thread = task.defer(function()
			local success, resultOrError = pcall(callback)

			storage.ready = {
				completed = true,
				result = {
					success = success,
					value = if success then resultOrError else nil,
					error = if success then nil else resultOrError,
				},
			}
		end)
	end

	return storage.ready
end

return useAsync
