local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

local function test(roots)
	print()
	local completed, result = xpcall(function()
		local results = TestEZ.TestBootstrap.run(roots)
		return results.failureCount == 0
	end, debug.traceback)
	print()
	return completed, result
end

return test
