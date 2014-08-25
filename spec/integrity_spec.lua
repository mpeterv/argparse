describe("tests related to CLI behaviour #unsafe", function()
   describe("error messages", function()
      it("generates correct error message without arguments", function()
         local handler = io.popen("./spec/script 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "Error: too few arguments",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message with too many arguments", function()
         local handler = io.popen("./spec/script foo bar 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "Error: unknown command 'bar'",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message with unexpected argument", function()
         local handler = io.popen("./spec/script --verbose=true 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "Error: option '--verbose' does not take arguments",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message with unexpected option", function()
         local handler = io.popen("./spec/script -vq 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "Error: unknown option '-q'",
            "Did you mean one of these: '-h' '-v'?",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message and tip with unexpected command", function()
         local handler = io.popen("./spec/script foo nstall 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "Error: unknown command 'nstall'",
            "Did you mean 'install'?",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message without arguments in command", function()
         local handler = io.popen("./spec/script foo install 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]",
            "",
            "Error: too few arguments",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct error message and tip in command", function()
         local handler = io.popen("./spec/script foo install bar --form=there 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]",
            "",
            "Error: unknown option '--form'",
            "Did you mean '--from'?",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)
   end)

   describe("help messages", function()
      it("generates correct help message", function()
         local handler = io.popen("./spec/script --help 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script [-v] [-h] <input> [<command>] ...",
            "",
            "A testing program. ",
            "",
            "Arguments: ",
            "   input",
            "",
            "Options: ",
            "   -v, --verbose         Sets verbosity level. ",
            "   -h, --help            Show this help message and exit. ",
            "",
            "Commands: ",
            "   install               Install a rock. ",
            ""
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)

      it("generates correct help message for command", function()
         local handler = io.popen("./spec/script foo install --help 2>&1", "r")
         assert.equal(table.concat({
            "Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]",
            "",
            "Install a rock. ",
            "",
            "Arguments: ",
            "   rock                  Name of the rock. ",
            "   version               Version of the rock. ",
            "",
            "Options: ",
            "   -f <from>, --from <from>",
            "                         Fetch the rock from this server. ",
            "   -h, --help            Show this help message and exit. ",
            "",
         }, "\r\n"), handler:read "*a")
         handler:close()
      end)
   end)

   describe("data flow", function()
      it("works with one argument", function()
         local handler = io.popen("./spec/script foo 2>&1", "r")
         assert.equal("foo", handler:read "*l")
         assert.equal("0", handler:read "*l")
         handler:close()
      end)

      it("works with one argument and a flag", function()
         local handler = io.popen("./spec/script -v foo --verbose 2>&1", "r")
         assert.equal("foo", handler:read "*l")
         assert.equal("2", handler:read "*l")
         handler:close()
      end)

      it("works with command", function()
         local handler = io.popen("./spec/script foo -v install bar 2>&1", "r")
         assert.equal("foo", handler:read "*l")
         assert.equal("1", handler:read "*l")
         assert.equal("true", handler:read "*l")
         assert.equal("bar", handler:read "*l")
         assert.equal("nil", handler:read "*l")
         assert.equal("nil", handler:read "*l")
         handler:close()
      end)

      it("works with command and options", function()
         local handler = io.popen("./spec/script foo --verbose install bar 0.1 --from=there -vv 2>&1", "r")
         assert.equal("foo", handler:read "*l")
         assert.equal("2", handler:read "*l")
         assert.equal("true", handler:read "*l")
         assert.equal("bar", handler:read "*l")
         assert.equal("0.1", handler:read "*l")
         assert.equal("there", handler:read "*l")
         handler:close()
      end)
   end)
end)
