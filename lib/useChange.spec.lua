local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useChange = require(script.Parent.useChange)

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
				useChange({})
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should return true once with empty dependencies", function()
			local count = 0

			loop:scheduleSystem(function()
				if useChange({}) then
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
		end)

		it("should return true once each time a dependency changes", function()
			local count = 0
			local dependency = 0

			loop:scheduleSystem(function()
				if useChange({ dependency }) then
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			dependency += 1
			event:Fire()
			expect(count).to.equal(2)
			dependency += 1
			event:Fire()
			expect(count).to.equal(3)
			event:Fire()
			expect(count).to.equal(3)
		end)

		it("should return true once each time any dependency changes", function()
			local count = 0
			local dependency1 = 0
			local dependency2 = 0
			local dependency3 = 0

			loop:scheduleSystem(function()
				if useChange({ dependency1, dependency2, dependency3 }) then
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			dependency1 += 1
			event:Fire()
			expect(count).to.equal(2)
			dependency2 += 1
			event:Fire()
			expect(count).to.equal(3)
			event:Fire()
			expect(count).to.equal(3)
		end)
	end)
end
