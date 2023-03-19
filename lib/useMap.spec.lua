local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useMap = require(script.Parent.useMap)

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
				useMap(1, true)
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should return the default value each time", function()
			local value

			loop:scheduleSystem(function()
				value = useMap(1, true)
			end)

			event:Fire()
			expect(value.value).to.equal(true)
			event:Fire()
			expect(value.value).to.equal(true)
			event:Fire()
			expect(value.value).to.equal(true)
		end)

		it("should return the set value each time", function()
			local value

			loop:scheduleSystem(function()
				value = useMap(1, true)
			end)

			event:Fire()
			expect(value.value).to.equal(true)
			value.value = false
			event:Fire()
			expect(value.value).to.equal(false)
			event:Fire()
			expect(value.value).to.equal(false)
			value.value = 5
			event:Fire()
			expect(value.value).to.equal(5)
			event:Fire()
			expect(value.value).to.equal(5)
		end)

		it("should return the default value in a loop", function()
			local source = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
			local values

			loop:scheduleSystem(function()
				values = {}
				for index in source do
					values[index] = useMap(index, true)
				end
			end)

			event:Fire()
			for index in source do
				expect(values[index]).to.be.ok()
				expect(values[index].value).to.equal(true)
			end

			event:Fire()
			for index in source do
				expect(values[index]).to.be.ok()
				expect(values[index].value).to.equal(true)
			end
		end)

		it("should return the set value in a loop", function()
			local source = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
			local values

			loop:scheduleSystem(function()
				values = {}
				for index in source do
					values[index] = useMap(index, true)
				end
			end)

			event:Fire()
			for index in source do
				expect(values[index]).to.be.ok()
				expect(values[index].value).to.equal(true)
			end

			for index, value in source do
				values[index].value = value
			end

			event:Fire()
			for index, value in source do
				expect(values[index]).to.be.ok()
				expect(values[index].value).to.equal(value)
			end

			local source = { "A", "B", "C" }

			for index, value in source do
				values[index].value = value
			end

			event:Fire()
			for index, value in source do
				expect(values[index]).to.be.ok()
				expect(values[index].value).to.equal(value)
			end
		end)
	end)
end
