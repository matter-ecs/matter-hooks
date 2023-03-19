local Package = script.Parent
local ContextActionService = game:GetService("ContextActionService")
local Matter = require(Package.Parent.Matter)

--[=[
	.createButton boolean? -- Whether the context action creates a button
	.inputTypes { Enum.Keycode | Enum.UserInputType }? -- An array of inputs for the context action

	@within Hooks
	@interface ContextActionOptions
]=]
export type ContextActionOptions = {
	createButton: boolean?,
	inputTypes: { Enum.KeyCode | Enum.UserInputType }?,
}

type NormalizedOptions = {
	createButton: boolean,
	inputTypes: { Enum.KeyCode | Enum.UserInputType },
}

local function normalizeOptions(options: ContextActionOptions?): NormalizedOptions
	return {
		createButton = if options and options.createButton ~= nil
			then options.createButton
			else false,
		inputTypes = if options and options.inputTypes then options.inputTypes else {},
	}
end

local function cleanup(storage)
	ContextActionService:UnbindAction(storage.actionName)
end

--[=[
	Registers asynchronous context actions within systems.

	The callback is run as a context action normally would be and can sink inputs
	as it normally would by returning a [ContextActionResult]. The callback can be
	updated dynamically as the hook is called.

	:::info
	It's important to keep in mind that the callback doesn't run within your
	system, but as a normal context action.

	Assuming that it runs during your system can lead to subtle bugs.
	:::

	The action name and callback parameters are the same as are used in a normal
	context action. The optional properties encapsulate additional context action
	parameters.

	:::warning
	Only one context action can be registered for each action name.

	It's important to discriminate your action name with each call of this hook,
	such as when calling it in a loop.
	:::

	```lua
	useContextAction(
		"systemAction",
		function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
			if inputState == Enum.UserInputState.Begin then
				updatePosition(actionName, inputObject.Position)
			end
		end,
		{
			inputTypes = {
				Enum.UserInputType.MouseButton1,
				Enum.UserInputType.Touch,
			},
		}
	)
	```

	@within Hooks
]=]
local function useContextAction(
	actionName: string,
	callback: (
		string,
		Enum.UserInputState,
		InputObject
	) -> Enum.ContextActionResult?,
	options: ContextActionOptions
)
	local storage = Matter.useHookState(actionName, cleanup)

	if not storage.actionName then
		local options = normalizeOptions(options)
		storage.actionName = actionName

		ContextActionService:BindAction(actionName, function(...)
			return storage.callback(...)
		end, options.createButton, unpack(options.inputTypes))
	end

	storage.callback = callback
end

return useContextAction
