local diffTables = require(script.Parent.diffTables)

return function()
	describe("function", function()
		it("should be true when both parameters are nil", function()
			expect(diffTables()).to.equal(true)
		end)

		it("should be true when the first parameter is nil", function()
			expect(diffTables(nil, {})).to.equal(true)
		end)

		it("should be true when the second parameter is nil", function()
			expect(diffTables({})).to.equal(true)
		end)

		it("should be false with two different empty tables", function()
			local left = {}
			local right = {}
			expect(diffTables(left, right)).to.equal(false)
		end)

		it("should be true with tables with different elements", function()
			local left = {
				1,
				2,
				3,
			}
			local right = {
				"a",
				"b",
				"c",
			}
			expect(diffTables(left, right)).to.equal(true)
		end)

		it("should be true with tables with nearly the same elements", function()
			local left = {
				1,
				2,
				3,
			}
			local right = {
				1,
				2,
				3,
				4,
			}
			expect(diffTables(left, right)).to.equal(true)
		end)

		it("should be false with different identical tables", function()
			local left = {
				1,
				2,
				3,
			}
			local right = {
				1,
				2,
				3,
			}
			expect(diffTables(left, right)).to.equal(false)
		end)

		it("should be false with the same table", function()
			local left = {
				1,
				2,
				3,
			}
			expect(diffTables(left, left)).to.equal(false)
		end)
	end)
end
