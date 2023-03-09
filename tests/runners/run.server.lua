local roots = require(script.Parent.roots)
local test = require(script.Parent.tests)

local completed, result = test(roots)

if completed then
	if not result then
		error("Tests have failed.", 0)
	end
else
	error(result, 0)
end
