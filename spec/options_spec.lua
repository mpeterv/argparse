local largparse = require "largparse"

describe("tests related to options", function()
   local function curry(f, ...)
      local args = {...}
      return function() return f(table.unpack(args)) end
   end

   describe("passing correct options", function()
      it("handles no options passed correctly", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({})
         assert.same(args, {})
      end)

      it("handles one option correctly", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server", "foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles GNU-style long options", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server=foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles short option correclty", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-s", "foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles flag correclty", function()
         local parser = largparse.parser()
         parser:flag("-q", "--quiet")
         local args = parser:parse({"--quiet"})
         assert.same(args, {quiet = true})
      end)

      it("handles combined flags correclty", function()
         local parser = largparse.parser()
         parser:flag("-q", "--quiet")
         parser:flag("-f", "--fast")
         local args = parser:parse({"-qf"})
         assert.same(args, {quiet = true, fast = true})
      end)

      it("handles short options without space between option and argument", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-sfoo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles flags combined with short option correclty", function()
         local parser = largparse.parser()
         parser:flag("-q", "--quiet")
         parser:option("-s", "--server")
         local args = parser:parse({"-qsfoo"})
         assert.same(args, {quiet = true, server = "foo"})
      end)

      describe("Options with optional argument", function()
         it("handles emptiness correctly", function()
            local parser = largparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({})
            assert.same(args, {})
         end)

         it("handles option without argument correctly", function()
            local parser = largparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p"})
            assert.same(args, {password = {}})
         end)

         it("handles option with argument correctly", function()
            local parser = largparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p", "password"})
            assert.same(args, {password = {"password"}})
         end)
      end)
   end)

   describe("passing incorrect options", function()
      local old_parser = largparse.parser

      setup(function()
         largparse.parser = old_parser:extends()
         function largparse.parser:error(fmt, ...)
            error(fmt:format(...))
         end
      end)

      -- TODO

   end)
end)