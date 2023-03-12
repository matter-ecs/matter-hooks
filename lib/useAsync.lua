local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local diffTables = require(Package.diffTables)

export type AsyncSuccess<T> = {
	success: true,
	value: T,
}

export type AsyncError<E> = {
	success: false,
	error: E,
}

export type AsyncResult<T, E> = AsyncSuccess<T> | AsyncError<E>

export type AsyncComplete<T> = {
	completed: true,
	result: AsyncResult<T, string>,
}

export type AsyncIncomplete = {
	completed: false,
}

export type AsyncReady<T> = AsyncComplete<T> | AsyncIncomplete

local function cleanup(storage)
	if storage.thread then
		task.cancel(storage.thread)
	end
	storage.ready = {
		completed = false,
	}
end

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
