local useChange = require(script.useChange)
local useContextAction = require(script.useContextAction)
local useMemo = require(script.useMemo)
local useReducer = require(script.useReducer)

--[=[
	@class Hooks
]=]

return {
	useChange = useChange,
	useContextAction = useContextAction,
	useMemo = useMemo,
	useReducer = useReducer,
}
