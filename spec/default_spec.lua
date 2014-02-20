local Parser = require "argparse"

describe("tests related to default values", function()
   describe("default values for arguments", function()
      it("handles default argument correctly", function()
         local parser = Parser()
         parser:argument("foo", {
            default = "bar"
         })
         local args = parser:parse({})
         assert.same({foo = "bar"}, args)
      end)

      it("handles default multi-argument correctly", function()
         local parser = Parser()
         parser:argument("foo", {
            args = 3,
            default = "bar"
         })
         local args = parser:parse({"baz"})
         assert.same({foo = {"baz", "bar", "bar"}}, args)
      end)

      it("does not use default values if not needed", function()
         local parser = Parser()
         parser:argument("foo", {
            args = "1-2",
            default = "bar"
         })
         local args = parser:parse({"baz"})
         assert.same({foo = {"baz"}}, args)
      end)
   end)

   describe("default values for options", function()
      it("handles option with default value correctly", function()
         local parser = Parser()
         parser:option("-f", "--foo", {
            default = "bar"
         })
         local args = parser:parse({"-f"})
         assert.same({foo = "bar"}, args)
      end)

      it("handles underused option with default value correctly", function()
         local parser = Parser()
         parser:option "-o" "--output"
            :count(1)
            :default "a.out"
         local args = parser:parse{}
         assert.same({output = "a.out"}, args)
      end)

      it("doesn't use default if option is not invoked", function()
         local parser = Parser()
         parser:option("-f", "--foo", {
            default = "bar"
         })
         local args = parser:parse({})
         assert.same({}, args)
      end)

      it("handles default multi-argument correctly", function()
         local parser = Parser()
         parser:option("-f", "--foo", {
            args = 3,
            default = "bar"
         })
         local args = parser:parse({"--foo=baz"})
         assert.same({foo = {"baz", "bar", "bar"}}, args)
      end)

      it("does not use default values if not needed", function()
         local parser = Parser()
          parser:option("-f", "--foo", {
            args = "1-2",
            default = "bar"
         })
         local args = parser:parse({"-f", "baz"})
         assert.same({foo = {"baz"}}, args)
      end)

      it("handles multi-count options with default value correctly", function()
         local parser = Parser()
          parser:option("-f", "--foo", {
            count = "*",
            default = "bar"
         })
         local args = parser:parse({"-f", "--foo=baz", "--foo"})
         assert.same({foo = {"bar", "baz", "bar"}}, args)
      end)
   end)
end)
