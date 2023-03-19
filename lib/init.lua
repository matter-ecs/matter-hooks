local useAsync = require(script.useAsync)
local useChange = require(script.useChange)
local useContextAction = require(script.useContextAction)
local useMap = require(script.useMap)
local useMemo = require(script.useMemo)
local useReducer = require(script.useReducer)
local useStream = require(script.useStream)

--[=[
	@class Hooks
]=]

return {
	useAsync = useAsync,
	useChange = useChange,
	useContextAction = useContextAction,
	useMap = useMap,
	useMemo = useMemo,
	useReducer = useReducer,
	useStream = useStream,
}
