local argparse = require "argparse"

describe("tests related to default values", function()
   describe("default values for arguments", function()
      it("handles default argument correctly", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            default = "bar"
         })
         local args = parser:parse({})
         assert.same(args, {foo = "bar"})
      end)

      it("handles default multi-argument correctly", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            args = 3,
            default = "bar"
         })
         local args = parser:parse({"baz"})
         assert.same(args, {foo = {"baz", "bar", "bar"}})
      end)

      it("does not use default values if not needed", function()
         local parser = argparse.parser()
         parser:argument("foo", {
            args = "1-2",
            default = "bar"
         })
         local args = parser:parse({"baz"})
         assert.same(args, {foo = {"baz"}})
      end)
   end)

   describe("default values for options", function()
      it("handles option with default value correctly", function()
         local parser = argparse.parser()
         parser:option("-f", "--foo", {
            default = "bar"
         })
         local args = parser:parse({"-f"})
         assert.same(args, {foo = "bar"})
      end)

      it("doesn't use default if option is not invoked", function()
         local parser = argparse.parser()
         parser:option("-f", "--foo", {
            default = "bar"
         })
         local args = parser:parse({})
         assert.same(args, {})
      end)

      it("handles default multi-argument correctly", function()
         local parser = argparse.parser()
         parser:option("-f", "--foo", {
            args = 3,
            default = "bar"
         })
         local args = parser:parse({"--foo=baz"})
         assert.same(args, {foo = {"baz", "bar", "bar"}})
      end)

      it("does not use default values if not needed", function()
         local parser = argparse.parser()
          parser:option("-f", "--foo", {
            args = "1-2",
            default = "bar"
         })
         local args = parser:parse({"-f", "baz"})
         assert.same(args, {foo = {"baz"}})
      end)

      it("handles multi-count options with default value correctly", function()
         local parser = argparse.parser()
          parser:option("-f", "--foo", {
            count = "*",
            default = "bar"
         })
         local args = parser:parse({"-f", "--foo=baz", "--foo"})
         assert.same(args, {foo = {"bar", "baz", "bar"}})
      end)
   end)
end)
