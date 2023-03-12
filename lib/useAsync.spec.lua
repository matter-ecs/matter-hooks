local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useAsync = require(script.Parent.useAsync)

return function()
	describe("Some Test", function()
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
				useAsync(function() end, {})
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should call an async function once only with empty dependencies", function()
			local count = 0

			loop:scheduleSystem(function()
				useAsync(function()
					count += 1
				end, {})
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			task.wait()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			task.wait()
			expect(count).to.equal(1)
		end)

		it("should call an async function once each time a dependency changes", function()
			local count = 0
			local dependency = 0

			loop:scheduleSystem(function()
				useAsync(function()
					count += 1
				end, { dependency })
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			task.wait()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			task.wait()
			expect(count).to.equal(1)
			dependency += 1
			event:Fire()
			expect(count).to.equal(1)
			task.wait()
			expect(count).to.equal(2)
		end)

		it("should return the status the async function returns", function()
			local memoized = {}
			local returned

			loop:scheduleSystem(function()
				returned = useAsync(function()
					return memoized
				end, {})
			end)

			expect(returned).never.to.be.ok()
			event:Fire()
			expect(returned).to.be.ok()
			expect(returned.completed).to.equal(false)
			expect(returned.result).never.to.be.ok()
			task.wait()
			event:Fire()
			expect(returned).to.be.ok()
			expect(returned.completed).to.equal(true)
			expect(returned.result).to.be.ok()
			expect(returned.result.success).to.equal(true)
			expect(returned.result.error).never.to.be.ok()
			expect(returned.result.value).to.equal(memoized)
			local original = returned
			memoized = { 1, 2, 3 }
			event:Fire()
			expect(returned).to.equal(original)
		end)

		it("should return an error status the async function errors", function()
			local returned

			loop:scheduleSystem(function()
				returned = useAsync(function()
					error("Uh oh!")
				end, {})
			end)

			expect(returned).never.to.be.ok()
			event:Fire()
			expect(returned).to.be.ok()
			expect(returned.completed).to.equal(false)
			expect(returned.result).never.to.be.ok()
			task.wait()
			event:Fire()
			expect(returned).to.be.ok()
			expect(returned.completed).to.equal(true)
			expect(returned.result).to.be.ok()
			expect(returned.result.success).to.equal(false)
			expect(returned.result.value).never.to.be.ok()
			expect(returned.result.error:find("Uh oh!")).to.be.ok()
		end)

		it(
			"should return the updated value the async function returns when the dependency changes",
			function()
				local memoized = {}
				local dependency = 0
				local returned

				loop:scheduleSystem(function()
					returned = useAsync(function()
						return memoized
					end, { dependency })
				end)

				expect(returned).never.to.be.ok()
				event:Fire()
				expect(returned).to.be.ok()
				expect(returned.completed).to.equal(false)
				expect(returned.result).never.to.be.ok()
				task.wait()
				event:Fire()
				expect(returned).to.be.ok()
				expect(returned.completed).to.equal(true)
				expect(returned.result).to.be.ok()
				expect(returned.result.success).to.equal(true)
				expect(returned.result.error).never.to.be.ok()
				expect(returned.result.value).to.equal(memoized)
				local original = returned
				memoized = { 1, 2, 3 }
				event:Fire()
				expect(returned).to.equal(original)
				dependency += 1
				event:Fire()
				expect(returned).never.to.equal(original)
				expect(returned).to.be.ok()
				expect(returned.completed).to.equal(false)
				expect(returned.result).never.to.be.ok()
				task.wait()
				event:Fire()
				expect(returned).to.be.ok()
				expect(returned.completed).to.equal(true)
				expect(returned.result).to.be.ok()
				expect(returned.result.success).to.equal(true)
				expect(returned.result.error).never.to.be.ok()
				expect(returned.result.value).to.equal(memoized)
			end
		)

		it("should cancel the async function when the hook is no longer called", function()
			local count = 0
			local shouldRun = true

			loop:scheduleSystem(function()
				if shouldRun then
					shouldRun = false
					useAsync(function()
						count += 1
					end, {})
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			task.wait()
			expect(count).to.equal(0)
		end)

		it("should cancel the async function when the dependencies change early", function()
			local count = 0
			local dependency = 0

			loop:scheduleSystem(function()
				useAsync(function()
					count += 1
				end, { dependency })
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			event:Fire()
			dependency += 1
			expect(count).to.equal(0)
			task.wait()
			expect(count).to.equal(1)
		end)
	end)
end
