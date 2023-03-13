local Queue = {}
Queue.__index = Queue

function Queue.new()
	local self = setmetatable({}, Queue)
	return self
end

function Queue:push<T>(value: T)
	local node = {
		value = value,
	}

	if self.front == nil then
		self.front = node
		self.back = node
		return
	end

	self.back.next = node
	self.back = node
end

function Queue:shift(): unknown
	local node = self.front
	if node == nil then
		return nil
	end

	self.front = node.next
	if self.back == node then
		self.back = nil
	end

	return node.value
end

return Queue
