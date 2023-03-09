local Package = script.Parent
local ContextActionService = game:GetService("ContextActionService")
local Matter = require(Package.Parent.Matter)

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
