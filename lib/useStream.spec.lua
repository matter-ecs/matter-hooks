local Workspace = game:GetService("Workspace")
local Package = script.Parent
local Matter = require(Package.Parent.Matter)
local useStream = require(script.Parent.useStream)

return function()
	describe("hook", function()
		local event = Instance.new("BindableEvent")
		local world
		local loop
		local connections
		local instances

		beforeEach(function()
			instances = {}
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
			for _, instance in instances do
				instance:Destroy()
			end
		end)

		it("should only work within a Loop-system context", function()
			expect(function()
				useStream(1)
			end).to.throw(
				"Attempt to access topologically-aware storage outside of a Loop-system context."
			)
		end)

		it("should not loop when nothing is streamed", function()
			local count = 0

			loop:scheduleSystem(function()
				for _, _ in useStream(1) do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
		end)

		it("should loop when the id is streamed in", function()
			local count = 0
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)

			loop:scheduleSystem(function()
				for _, _ in useStream(1) do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			instance.Parent = Workspace
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
		end)

		it("should loop when the id is streamed out", function()
			local count = 0
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)

			loop:scheduleSystem(function()
				for _, _ in useStream(1) do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			instance.Parent = Workspace
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			instance.Parent = nil
			event:Fire()
			expect(count).to.equal(2)
			event:Fire()
			expect(count).to.equal(2)
		end)

		it("should give an event when the id is streamed in", function()
			local storedEvent
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)

			loop:scheduleSystem(function()
				storedEvent = nil
				for _, event in useStream(1) do
					storedEvent = event
				end
			end)

			expect(storedEvent).never.to.be.ok()
			event:Fire()
			expect(storedEvent).never.to.be.ok()
			instance.Parent = Workspace
			event:Fire()
			expect(storedEvent).to.be.ok()
			expect(storedEvent.adding).to.equal(true)
			expect(storedEvent.removing).to.equal(false)
			expect(storedEvent.descendant).to.equal(false)
			expect(storedEvent.instance).to.equal(instance)
			event:Fire()
			expect(storedEvent).never.to.be.ok()
		end)

		it("should give an event when the id is streamed out", function()
			local storedEvent
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)

			loop:scheduleSystem(function()
				storedEvent = nil
				for _, event in useStream(1) do
					storedEvent = event
				end
			end)

			expect(storedEvent).never.to.be.ok()
			event:Fire()
			expect(storedEvent).never.to.be.ok()
			instance.Parent = Workspace
			event:Fire()
			expect(storedEvent).to.be.ok()
			event:Fire()
			expect(storedEvent).never.to.be.ok()
			instance.Parent = nil
			event:Fire()
			expect(storedEvent).to.be.ok()
			expect(storedEvent.adding).to.equal(false)
			expect(storedEvent.removing).to.equal(true)
			expect(storedEvent.descendant).to.equal(false)
			expect(storedEvent.instance).to.equal(instance)
			event:Fire()
			expect(storedEvent).never.to.be.ok()
		end)

		it("should allow a custom id attribute", function()
			local count = 0
			local instance = Instance.new("Part")
			instance:SetAttribute("myCustomIdAttribute", 1)
			table.insert(instances, instance)

			loop:scheduleSystem(function()
				for _, _ in
					useStream(1, {
						attribute = "myCustomIdAttribute",
					})
				do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			instance.Parent = Workspace
			event:Fire()
			expect(count).to.equal(1)
			event:Fire()
			expect(count).to.equal(1)
			instance.Parent = nil
			event:Fire()
			expect(count).to.equal(2)
			event:Fire()
			expect(count).to.equal(2)
		end)

		it("should loop over descendants", function()
			local count = 0
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)
			local descendant1 = Instance.new("Folder")
			local descendant2 = Instance.new("Folder")
			local descendant3 = Instance.new("Folder")
			descendant1.Parent = instance
			descendant2.Parent = instance
			descendant3.Parent = instance

			loop:scheduleSystem(function()
				for _, _ in useStream(1, { descendants = true }) do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			event:Fire()
			expect(count).to.equal(0)
			instance.Parent = Workspace
			event:Fire()
			expect(count).to.equal(4)
			event:Fire()
			expect(count).to.equal(4)
			instance.Parent = nil
			event:Fire()
			expect(count).to.equal(8)
			event:Fire()
			expect(count).to.equal(8)
		end)

		it("should loop over descendants changed later", function()
			local count = 0
			local instance = Instance.new("Part")
			instance:SetAttribute("serverEntityId", 1)
			table.insert(instances, instance)
			local descendant1 = Instance.new("Folder")
			table.insert(instances, descendant1)
			local descendant2 = Instance.new("Folder")
			table.insert(instances, descendant2)
			local descendant3 = Instance.new("Folder")
			table.insert(instances, descendant3)

			loop:scheduleSystem(function()
				for _, _ in useStream(1, { descendants = true }) do
					count += 1
				end
			end)

			expect(count).to.equal(0)
			descendant1.Parent = instance
			event:Fire()
			expect(count).to.equal(0)
			instance.Parent = Workspace
			event:Fire()
			expect(count).to.equal(2)
			event:Fire()
			expect(count).to.equal(2)
			event:Fire()
			descendant2.Parent = instance
			event:Fire()
			expect(count).to.equal(3)
			event:Fire()
			expect(count).to.equal(3)
			descendant3.Parent = instance
			event:Fire()
			expect(count).to.equal(4)
			event:Fire()
			expect(count).to.equal(4)
			descendant2.Parent = nil
			event:Fire()
			expect(count).to.equal(5)
			event:Fire()
			expect(count).to.equal(5)
			instance.Parent = nil
			event:Fire()
			expect(count).to.equal(8)
			event:Fire()
			expect(count).to.equal(8)
		end)
	end)
end
