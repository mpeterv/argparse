local utils = require "argparse.utils"

describe("tests related to utils.parse_boundaries", function()
   it("handles * correctly", function()
      local min, max = utils.parse_boundaries("*")
      assert.equal(min, 0)
      assert.equal(max, math.huge)
   end)

   it("handles + correctly", function()
      local min, max = utils.parse_boundaries("+")
      assert.equal(min, 1)
      assert.equal(max, math.huge)
   end)

   it("handles ? correctly", function()
      local min, max = utils.parse_boundaries("?")
      assert.equal(min, 0)
      assert.equal(max, 1)
   end)

   it("handles numbers correctly", function()
      local min, max = utils.parse_boundaries(42)
      assert.equal(min, 42)
      assert.equal(max, 42)
   end)

   it("handles numbers+ correctly", function()
      local min, max = utils.parse_boundaries("42+")
      assert.equal(min, 42)
      assert.equal(max, math.huge)
   end)

   it("handles ranges correctly", function()
      local min, max = utils.parse_boundaries("42-96")
      assert.equal(min, 42)
      assert.equal(max, 96)
   end)
end)
