local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useReducer = require(script.Parent.useReducer)

return function()
	describe("hook", function()
		local event = Instance.new("BindableEvent")
		local world
		local loop
		local connections

		beforeEach(function()
			world = Matter.World.new()
			loop = Matter.Loop.new(world)
			connections = loop:begin({
				default = event.Event,
			})
		end)

		afterEach(function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end)

		it("should only work within a Loop-system context", function()
			expect(function()
				useReducer(function(state)
					return state
				end, {})
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should not update the state if the dispatcher isn't called", function()
			local state = 0

			loop:scheduleSystem(function()
				state = useReducer(function(state)
					return state + 1
				end, state)
			end)

			expect(state).to.equal(0)
			event:Fire()
			expect(state).to.equal(0)
		end)

		it("should update the state once each time dispatcher is called", function()
			local state = 0
			local shouldDispatch = false

			loop:scheduleSystem(function()
				local dispatch

				state, dispatch = useReducer(function(state)
					return state + 1
				end, state)

				if shouldDispatch then
					shouldDispatch = false
					dispatch()
				end
			end)

			expect(state).to.equal(0)
			event:Fire()
			expect(state).to.equal(0)
			shouldDispatch = true
			event:Fire()
			expect(state).to.equal(0)
			event:Fire()
			expect(state).to.equal(1)
			shouldDispatch = true
			event:Fire()
			expect(state).to.equal(1)
			shouldDispatch = true
			event:Fire()
			expect(state).to.equal(2)
			event:Fire()
			expect(state).to.equal(3)
			event:Fire()
			expect(state).to.equal(3)
		end)

		it("should pass the action to the reducer", function()
			local state = 0
			local dispatchValue = 1
			local previousDispatchValue = 0
			local previousPreviousDispatchValue = 0

			loop:scheduleSystem(function()
				local dispatch

				state, dispatch = useReducer(function(_, action)
					return action
				end, state)

				dispatch(dispatchValue)
				previousPreviousDispatchValue = previousDispatchValue
				previousDispatchValue = dispatchValue
			end)

			expect(state).to.equal(previousPreviousDispatchValue)
			dispatchValue = 2
			event:Fire()
			expect(state).to.equal(previousPreviousDispatchValue)
			dispatchValue = 3
			event:Fire()
			expect(state).to.equal(previousPreviousDispatchValue)
			dispatchValue = 10
			event:Fire()
			expect(state).to.equal(previousPreviousDispatchValue)
			dispatchValue = 0
			event:Fire()
			expect(state).to.equal(previousPreviousDispatchValue)
		end)

		it("should only provide a new dispatch when the state changes", function()
			local shouldDispatch = false
			local dispatch
			local previousDispatch

			loop:scheduleSystem(function()
				local _state

				previousDispatch = dispatch
				_state, dispatch = useReducer(function(state)
					return state + 1
				end, 0)

				if shouldDispatch then
					shouldDispatch = false
					dispatch()
				end
			end)

			event:Fire()
			event:Fire()
			expect(dispatch).to.equal(previousDispatch)
			event:Fire()
			expect(dispatch).to.equal(previousDispatch)
			shouldDispatch = true
			event:Fire()
			expect(dispatch).to.equal(previousDispatch)
			event:Fire()
			expect(dispatch).never.to.equal(previousDispatch)
			shouldDispatch = true
			event:Fire()
			expect(dispatch).to.equal(previousDispatch)
			shouldDispatch = true
			event:Fire()
			expect(dispatch).never.to.equal(previousDispatch)
			shouldDispatch = true
			event:Fire()
			expect(dispatch).never.to.equal(previousDispatch)
		end)
	end)
end
