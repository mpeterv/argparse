local function get_output(args)
   local handler = io.popen("./spec/script " .. args .. " 2>&1", "r")
   local output = handler:read("*a")
   handler:close()
   return output
end

describe("tests related to CLI behaviour #unsafe", function()
   describe("error messages", function()
      it("generates correct error message without arguments", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

Error: too few arguments
]], get_output(""))
      end)

      it("generates correct error message with too many arguments", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

Error: unknown command 'bar'
]], get_output("foo bar"))
      end)

      it("generates correct error message with unexpected argument", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

Error: option '--verbose' does not take arguments
]], get_output("--verbose=true"))
      end)

      it("generates correct error message with unexpected option", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

Error: unknown option '-q'
Did you mean one of these: '-h' '-v'?
]], get_output("-vq"))
      end)

      it("generates correct error message and tip with unexpected command", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

Error: unknown command 'nstall'
Did you mean 'install'?
]], get_output("foo nstall"))
      end)

      it("generates correct error message without arguments in command", function()
         assert.equal([[
Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]

Error: too few arguments
]], get_output("foo install"))
      end)

      it("generates correct error message and tip in command", function()
         assert.equal([[
Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]

Error: unknown option '--form'
Did you mean '--from'?
]], get_output("foo install bar --form=there"))
      end)
   end)

   describe("help messages", function()
      it("generates correct help message", function()
         assert.equal([[
Usage: ./spec/script [-v] [-h] <input> [<command>] ...

A testing program. 

Arguments:
   input

Options:
   -v, --verbose         Sets verbosity level. 
   -h, --help            Show this help message and exit.

Commands:
   install               Install a rock. 
]], get_output("--help"))
      end)

      it("generates correct help message for command", function()
         assert.equal([[
Usage: ./spec/script install [-f <from>] [-h] <rock> [<version>]

Install a rock. 

Arguments:
   rock                  Name of the rock. 
   version               Version of the rock. 

Options:
   -f <from>, --from <from>
                         Fetch the rock from this server. 
   -h, --help            Show this help message and exit.
]], get_output("foo install --help"))
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
