local Workspace = game:GetService("Workspace")
local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local Queue = require(Package.Queue)

export type StreamOptions = {
	descendants: boolean?,
	attribute: string?,
}

export type StreamInEvent = {
	adding: true,
	removing: false,
	descendant: boolean,
	instance: Instance,
}

export type StreamOutEvent = {
	adding: false,
	removing: true,
	descendant: boolean,
	instance: Instance,
}

export type StreamEvent = StreamInEvent | StreamOutEvent

local function streamInEvent(instance: Instance, descendant: boolean?): StreamInEvent
	return {
		adding = true,
		removing = false,
		descendant = if descendant ~= nil then descendant else false,
		instance = instance,
	}
end

local function streamOutEvent(instance: Instance, descendant: boolean?): StreamOutEvent
	return {
		adding = false,
		removing = true,
		descendant = if descendant ~= nil then descendant else false,
		instance = instance,
	}
end

type NormalizedOptions = {
	descendants: boolean,
	attribute: string,
}

local function normalizeOptions(options: StreamOptions?): NormalizedOptions
	return {
		descendants = if options and options.descendants ~= nil then options.descendants else false,
		attribute = if options and options.attribute then options.attribute else "serverEntityId",
	}
end

local function cleanup(storage)
	storage.addedConnection:Disconnect()
	storage.removingConnection:Disconnect()
	for _, connections in storage.trackedInstances do
		connections.addedConnection:Disconnect()
		connections.removingConnection:Disconnect()
	end
end

local function useStream(id: unknown, options: StreamOptions?)
	local storage = Matter.useHookState(id, cleanup)

	if not storage.queue then
		local options = normalizeOptions(options)
		storage.queue = Queue.new()
		storage.trackedInstances = {}

		storage.addedConnection = Workspace.DescendantAdded:Connect(function(instance: Instance)
			if instance:GetAttribute(options.attribute) ~= id then
				return
			end

			storage.queue:push(streamInEvent(instance))

			if not options.descendants then
				return
			end
			if storage.trackedInstances[instance] then
				return
			end

			storage.trackedInstances[instance] = {
				addedConnection = instance.DescendantAdded:Connect(function(instance: Instance)
					storage.queue:push(streamInEvent(instance, true))
				end),

				removingConnection = instance.DescendantRemoving:Connect(
					function(instance: Instance)
						storage.queue:push(streamOutEvent(instance, true))
					end
				),
			}

			for _, descendant in instance:GetDescendants() do
				storage.queue:push(streamInEvent(descendant, true))
			end
		end)

		storage.removingConnection = Workspace.DescendantRemoving:Connect(
			function(instance: Instance)
				if instance:GetAttribute(options.attribute) ~= id then
					return
				end

				storage.queue:push(streamOutEvent(instance))

				if not options.descendants then
					return
				end

				for _, descendant in instance:GetDescendants() do
					storage.queue:push(streamOutEvent(descendant, true))
				end

				local connections = storage.trackedInstances[instance]
				if not connections then
					return
				end

				connections.addedConnection:Disconnect()
				connections.removingConnection:Disconnect()
			end
		)
	end

	local index = 0
	return function(): (number?, StreamEvent)
		index += 1

		local value = storage.queue:shift()

		if value then
			return index, value
		end
		return nil, (nil :: unknown) :: StreamEvent
	end
end

return useStream
