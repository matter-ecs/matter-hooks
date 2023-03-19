local Workspace = game:GetService("Workspace")
local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local Queue = require(Package.Queue)

--[=[
	.descendants boolean? -- Whether to collect events about descendants
	.attribute string? -- The attribute to use

	@within Hooks
	@interface StreamOptions
]=]
export type StreamOptions = {
	descendants: boolean?,
	attribute: string?,
}

--[=[
	An event for an instance that has streamed in.

	.adding true
	.removing false
	.descendant boolean
	.instance Instance

	@within Hooks
	@interface StreamInEvent
]=]
export type StreamInEvent = {
	adding: true,
	removing: false,
	descendant: boolean,
	instance: Instance,
}

--[=[
	An event for an instance that has streamed out.

	.adding false
	.removing true
	.descendant boolean
	.instance Instance

	@within Hooks
	@interface StreamOutEvent
]=]
export type StreamOutEvent = {
	adding: false,
	removing: true,
	descendant: boolean,
	instance: Instance,
}

--[=[
	An event for an instance that has streamed in or out. The `adding` and
	`removing` fields indicate whether the instance is streaming in or out.

	@within Hooks
	@type StreamEvent StreamInEvent | StreamOutEvent
]=]
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

--[=[
	Collects instance streaming events for a streaming ID attribute.

	Allows iteration over collected events for the instances tagged with an ID
	using an attribute. It can optionally collect events for the descendants of
	that instance as they stream in and out.

	Each streaming event is returned in the order it happened.

	```lua
	for _, streamEvent in useStream(entityId) do
		if streamEvent.adding then
			processStreamedIn(streamEvent.instance)
		else
			processStreamedOut(streamEvent.instance)
		end
	end
	```

	If the hook is no longer called, all events will be cleaned up automatically.

	:::caution
	The events are stored in a queue that must be processed. If events are left in
	the queue they will remain for next frame, arriving late.

	To avoid this, all events should be processed each frame.

	```lua
	for _, streamEvent in useStream(entityId) do
		if processEvent(streamEvent) then
			break -- Uh oh! This can miss events!
		end
	end
	```
	:::

	The ID can be anything you use to identify instances streamed from the server,
	but is typically a server entity ID. The default attribute this hook uses to
	discover instances by this ID is `serverEntityId`, but can be optionally
	configured.

	```lua
	for _, streamEvent in
		useStream(entityId, {
			attribute = "StreamingId",
		})
	do
		processStream(streamEvent)
	end
	```

	If the instance being streamed has descendants that stream in at different
	times, you may want to listen for them. This can be configured as well.

	```lua
	for _, streamEvent in
		useStream(entityId, {
			descendants = true,
		})
	do
		processStream(streamEvent)
	end
	```

	@within Hooks

	@return () -> (number, StreamEvent)?  -- The event iterator
]=]
local function useStream(id: unknown, options: StreamOptions?): () -> (number?, StreamEvent)
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
