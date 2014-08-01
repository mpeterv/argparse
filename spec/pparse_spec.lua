local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to :pparse()", function()
   it("returns true and result on success", function()
      local parser = Parser()
      parser:option "-s" "--server"
      local ok, args = parser:pparse{"--server", "foo"}
      assert.is_true(ok)
      assert.same({server = "foo"}, args)
   end)

   it("returns false and bare error message on failure", function()
      local parser = Parser()
      parser:argument "foo"
      local ok, errmsg = parser:pparse{}
      assert.is_false(ok)
      assert.equal("too few arguments", errmsg)
   end)

   it("still raises an error if it is caused by misconfiguration", function()
      local parser = Parser()
      parser:option "--foo"
         :aliases {1, 2, 3}
      assert.has_error(function() parser:pparse{} end)
   end)
end)
