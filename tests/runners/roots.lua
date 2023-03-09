local rootTree = require(script.Parent.rootTree)

local function getRoots(node, parent)
	local roots = {}

	for key, subNode in node do
		local subRoots =
			getRoots(subNode, parent:FindFirstChild(key) or error("Could not find child" .. key))
		table.move(subRoots, 1, #subRoots + 1, #roots + 1, roots)
	end

	if #roots == 0 then
		table.insert(roots, parent)
	end

	return roots
end

local function getAllRoots(node)
	local roots = {}

	for key, subNode in node do
		local subRoots = getRoots(subNode, game:GetService(key))
		table.move(subRoots, 1, #subRoots + 1, #roots + 1, roots)
	end

	return roots
end

return getAllRoots(rootTree)
