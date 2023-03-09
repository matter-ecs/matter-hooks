local ContextActionService = game:GetService("ContextActionService")
local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useContextAction = require(script.Parent.useContextAction)

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
			ContextActionService:UnbindAction("testAction")
		end)

		it("should only work within a Loop-system context", function()
			expect(function()
				useContextAction("testAction", function() end, {
					inputTypes = {
						Enum.KeyCode.Space,
					},
				})
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should register a context action", function()
			loop:scheduleSystem(function()
				useContextAction("testAction", function() end, {
					inputTypes = {
						Enum.KeyCode.Space,
					},
				})
			end)
			event:Fire()
			expect(ContextActionService:GetBoundActionInfo("testAction").stackOrder).to.be.ok()
		end)

		it("should register with the provided input types", function()
			local inputTypes = {
				Enum.KeyCode.Space,
				Enum.KeyCode.A,
				Enum.KeyCode.B,
				Enum.KeyCode.C,
			}

			loop:scheduleSystem(function()
				useContextAction("testAction", function() end, {
					inputTypes = inputTypes,
				})
			end)

			event:Fire()

			local registeredInputTypes =
				ContextActionService:GetBoundActionInfo("testAction").inputTypes
			for _, input in inputTypes do
				expect(table.find(registeredInputTypes, input)).to.be.ok()
			end
		end)

		it("should not immediately call the provided callback", function()
			local called = false

			loop:scheduleSystem(function()
				useContextAction("testAction", function()
					called = true
				end, {
					inputTypes = {
						Enum.KeyCode.Space,
					},
				})
			end)

			event:Fire()

			expect(called).to.equal(false)
		end)
	end)
end
