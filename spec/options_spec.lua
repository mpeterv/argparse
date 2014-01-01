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

      it("handles multi-argument options correctly", function()
         local parser = largparse.parser()
         parser:option("--pair", {
            args = 2
         })
         local args = parser:parse({"--pair", "Alice", "Bob"})
         assert.same(args, {pair = {"Alice", "Bob"}})
      end)

      describe("Multi-count options", function()
         it("handles multi-count option correctly", function()
            local parser = largparse.parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({"-efoo", "--exclude=bar", "-e", "baz"})
            assert.same(args, {exclude = {"foo", "bar", "baz"}})
         end)

         it("handles not used multi-count option correctly", function()
            local parser = largparse.parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same(args, {exclude = {}})
         end)

         it("handles multi-count multi-argument option correctly", function()
            local parser = largparse.parser()
            parser:option("-e", "--exclude", {
               count = "*",
               args = 2
            })
            local args = parser:parse({"-e", "Alice", "Bob", "-e", "Emma", "Jacob"})
            assert.same(args, {exclude = {{"Alice", "Bob"}, {"Emma", "Jacob"}}})
         end)

         it("handles multi-count option with optional argument correctly", function()
            local parser = largparse.parser()
            parser:option("-w", "--why", "--why-would-someone-use-this", {
               count = "*",
               args = "?"
            })
            local args = parser:parse({"-w", "-wfoo", "--why=because", "-ww"})
            assert.same(args, {why = {{}, {"foo"}, {"because"}, {}, {}}})
         end)

         it("handles multi-count flag correctly", function()
            local parser = largparse.parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({"-qq", "--quiet"})
            assert.same(args, {quiet = 3})
         end)

         it("handles not used multi-count flag correctly", function()
            local parser = largparse.parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same(args, {quiet = 0})
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

      it("handles lack of required argument correctly", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         assert.has_error(curry(parser.parse, parser, {"--server"}), "too few arguments")
      end)

      it("handles too many arguments correctly", function()
         local parser = largparse.parser()
         parser:option("-s", "--server")
         assert.has_error(curry(parser.parse, parser, {"-sfoo", "bar"}), "too many arguments")
      end)


   end)
end)