local argparse = require "argparse"

describe("tests related to commands", function()
   it("handles commands after arguments", function()
      local parser = argparse.parser "name"
      parser:argument "file"
      parser:command "create"
      parser:command "remove"

      local args = parser:parse{"temp.txt", "remove"}
      assert.same({file = "temp.txt", remove = true}, args)
   end)
end)
