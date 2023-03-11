local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useMemo = require(script.Parent.useMemo)

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
				useMemo(function() end, {})
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should call a memo function once only with empty dependencies", function()
			local count = 0

			loop:scheduleSystem(function()
				useMemo(function()
					count += 1
				end, {})
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
		end)

		it("should call a memo function once each time a dependency changes", function()
			local count = 0
			local dependency = 0

			loop:scheduleSystem(function()
				useMemo(function()
					count += 1
				end, { dependency })
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			dependency += 1
			event:Fire()
			expect(count).to.equal(2)
			event:Fire()
			expect(count).to.equal(2)
			dependency += 1
			event:Fire()
			expect(count).to.equal(3)
		end)

		it("should return the value the memoized function returns", function()
			local memoized = {}
			local returned

			loop:scheduleSystem(function()
				returned = useMemo(function()
					return memoized
				end, {})
			end)

			expect(returned).never.to.be.ok()
			event:Fire()
			expect(returned).to.equal(memoized)
			event:Fire()
			expect(returned).to.equal(memoized)
			local original = memoized
			memoized = { 1, 2, 3 }
			event:Fire()
			expect(returned).to.equal(original)
		end)

		it(
			"should return the updated value the memoized function returns when the dependency changes",
			function()
				local memoized = {}
				local dependency = 0
				local returned

				loop:scheduleSystem(function()
					returned = useMemo(function()
						return memoized
					end, { dependency })
				end)

				expect(returned).never.to.be.ok()
				event:Fire()
				expect(returned).to.equal(memoized)
				local original = memoized
				memoized = { 1, 2, 3 }
				event:Fire()
				expect(returned).to.equal(original)
				dependency += 1
				event:Fire()
				expect(returned).to.equal(memoized)
			end
		)

		it("should return multiple values the memoized function returns", function()
			local returned1
			local returned2
			local returned3

			loop:scheduleSystem(function()
				returned1, returned2, returned3 = useMemo(function()
					return 1, 2, 3
				end, {})
			end)

			expect(returned1).never.to.be.ok()
			expect(returned2).never.to.be.ok()
			expect(returned3).never.to.be.ok()
			event:Fire()
			expect(returned1).to.equal(1)
			expect(returned2).to.equal(2)
			expect(returned3).to.equal(3)
		end)
	end)
end
