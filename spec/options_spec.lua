local argparse = require "argparse"

describe("tests related to options", function()
   describe("passing correct options", function()
      it("handles no options passed correctly", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({})
         assert.same(args, {})
      end)

      it("handles one option correctly", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server", "foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles GNU-style long options", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"--server=foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles GNU-style long options even when it could take more arguments", function()
         local parser = argparse.parser()
         parser:option("-s", "--server", {
            args = "*"
         })
         local args = parser:parse({"--server=foo"})
         assert.same(args, {server = {"foo"}})
      end)

      it("handles GNU-style long options for multi-argument options", function()
         local parser = argparse.parser()
         parser:option("-s", "--server", {
            args = "1-2"
         })
         local args = parser:parse({"--server=foo", "bar"})
         assert.same(args, {server = {"foo", "bar"}})
      end)

      it("handles short option correclty", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-s", "foo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles flag correclty", function()
         local parser = argparse.parser()
         parser:flag("-q", "--quiet")
         local args = parser:parse({"--quiet"})
         assert.same(args, {quiet = true})
      end)

      it("handles combined flags correclty", function()
         local parser = argparse.parser()
         parser:flag("-q", "--quiet")
         parser:flag("-f", "--fast")
         local args = parser:parse({"-qf"})
         assert.same(args, {quiet = true, fast = true})
      end)

      it("handles short options without space between option and argument", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         local args = parser:parse({"-sfoo"})
         assert.same(args, {server = "foo"})
      end)

      it("handles flags combined with short option correclty", function()
         local parser = argparse.parser()
         parser:flag("-q", "--quiet")
         parser:option("-s", "--server")
         local args = parser:parse({"-qsfoo"})
         assert.same(args, {quiet = true, server = "foo"})
      end)

      describe("Options with optional argument", function()
         it("handles emptiness correctly", function()
            local parser = argparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({})
            assert.same(args, {})
         end)

         it("handles option without argument correctly", function()
            local parser = argparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p"})
            assert.same(args, {password = {}})
         end)

         it("handles option with argument correctly", function()
            local parser = argparse.parser()
            parser:option("-p", "--password", {
               args = "?"
            })
            local args = parser:parse({"-p", "password"})
            assert.same(args, {password = {"password"}})
         end)
      end)

      it("handles multi-argument options correctly", function()
         local parser = argparse.parser()
         parser:option("--pair", {
            args = 2
         })
         local args = parser:parse({"--pair", "Alice", "Bob"})
         assert.same(args, {pair = {"Alice", "Bob"}})
      end)

      describe("Multi-count options", function()
         it("handles multi-count option correctly", function()
            local parser = argparse.parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({"-efoo", "--exclude=bar", "-e", "baz"})
            assert.same(args, {exclude = {"foo", "bar", "baz"}})
         end)

         it("handles not used multi-count option correctly", function()
            local parser = argparse.parser()
            parser:option("-e", "--exclude", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same(args, {exclude = {}})
         end)

         it("handles multi-count multi-argument option correctly", function()
            local parser = argparse.parser()
            parser:option("-e", "--exclude", {
               count = "*",
               args = 2
            })
            local args = parser:parse({"-e", "Alice", "Bob", "-e", "Emma", "Jacob"})
            assert.same(args, {exclude = {{"Alice", "Bob"}, {"Emma", "Jacob"}}})
         end)

         it("handles multi-count flag correctly", function()
            local parser = argparse.parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({"-qq", "--quiet"})
            assert.same(args, {quiet = 3})
         end)

         it("overwrites old invocations", function()
            local parser = argparse.parser()
            parser:option("-u", "--user", {
               count = "0-2"
            })
            local args = parser:parse({"-uAlice", "--user=Bob", "--user", "John"})
            assert.same(args, {user = {"Bob", "John"}})
         end)

         it("handles not used multi-count flag correctly", function()
            local parser = argparse.parser()
            parser:flag("-q", "--quiet", {
               count = "*"
            })
            local args = parser:parse({})
            assert.same(args, {quiet = 0})
         end)
      end)
   end)

   describe("passing incorrect options", function()
      it("handles lack of required argument correctly", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         assert.has_error(function() parser:parse{"--server"} end, "too few arguments")
      end)

      it("handles too many arguments correctly", function()
         local parser = argparse.parser()
         parser:option("-s", "--server")
         assert.has_error(function() parser:parse{"-sfoo", "bar"} end, "too many arguments")
      end)

      it("doesn't accept GNU-like long options when it doesn't need arguments", function()
         local parser = argparse.parser()
         parser:flag("-q", "--quiet")
         assert.has_error(function() parser:parse{"--quiet=very_quiet"} end, "option --quiet doesn't take arguments")
      end)

      it("handles too many invocations correctly", function()
         local parser = argparse.parser()
         parser:flag("-q", "--quiet", {
            count = 1,
            overwrite = false
         })
         assert.has_error(function() parser:parse{"-qq"} end, "option -q must be used at most 1 times")
      end)

      it("handles too few invocations correctly", function()
         local parser = argparse.parser()
         parser:option("-f", "--foo", {
            count = "3-4"
         })
         assert.has_error(function() parser:parse{"-fFOO", "-fBAR"} end, "option -f must be used at least 3 times")
      end)
   end)
end)
