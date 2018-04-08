local Parser = require "argparse"
getmetatable(Parser()).error = function(_, msg) error(msg) end

describe("tests related to help message generation", function()
   it("creates correct help message for empty parser", function()
      local parser = Parser "foo"
      assert.equal([[
Usage: foo [-h]

Options:
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("does not create extra help options when :prepare is called several times", function()
      local parser = Parser "foo"
      assert.equal([[
Usage: foo [-h]

Options:
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("uses custom help option ", function()
      local parser = Parser "foo"
         :add_help "/?"
      assert.equal([[
Usage: foo [/?]

Options:
   /?                    Show this help message and exit.]], parser:get_help())
   end)

   it("uses description and epilog", function()
      local parser = Parser("foo", "A description.", "An epilog.")

      assert.equal([[
Usage: foo [-h]

A description.

Options:
   -h, --help            Show this help message and exit.

An epilog.]], parser:get_help())
   end)

   it("creates correct help message for arguments", function()
      local parser = Parser "foo"
      parser:argument "first"
      parser:argument "second-and-third"
         :args "2"
      parser:argument "maybe-fourth"
         :args "?"
      parser:argument("others", "Optional.")
         :args "*"

      assert.equal([[
Usage: foo [-h] <first> <second-and-third> <second-and-third>
       [<maybe-fourth>] [<others>] ...

Arguments:
   first
   second-and-third
   maybe-fourth
   others                Optional.

Options:
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("creates correct help message for options", function()
      local parser = Parser "foo"
      parser:flag "-q" "--quiet"
      parser:option "--from"
         :count "1"
         :target "server"
      parser:option "--config"

      assert.equal([[
Usage: foo [-q] --from <from> [--config <config>] [-h]

Options:
   -q, --quiet
   --from <from>
   --config <config>
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("adds margin for multiline descriptions", function()
      local parser = Parser "foo"
      parser:flag "-v"
         :count "0-2"
         :target "verbosity"
         :description [[
Sets verbosity level.
-v: Report all warnings.
-vv: Report all debugging information.]]

      assert.equal([[
Usage: foo [-v] [-h]

Options:
   -v                    Sets verbosity level.
                         -v: Report all warnings.
                         -vv: Report all debugging information.
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("puts different aliases on different lines if there are arguments", function()
      local parser = Parser "foo"

      parser:option "-o --output"

      assert.equal([[
Usage: foo [-o <output>] [-h]

Options:
         -o <output>,
   --output <output>
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("handles description with more lines than usage", function()
      local parser = Parser "foo"

      parser:option "-o --output"
         :description [[
Sets output file.
If missing, 'a.out' is used by default.
If '-' is passed, output to stdount.
]]

      assert.equal([[
Usage: foo [-o <output>] [-h]

Options:
         -o <output>,    Sets output file.
   --output <output>     If missing, 'a.out' is used by default.
                         If '-' is passed, output to stdount.
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("handles description with less lines than usage", function()
      local parser = Parser "foo"

      parser:option "-o --output"
         :description "Sets output file."

      assert.equal([[
Usage: foo [-o <output>] [-h]

Options:
         -o <output>,    Sets output file.
   --output <output>
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("shows default values", function()
      local parser = Parser "foo"
      parser:option "-o"
         :default "a.out"
      parser:option "-p"
         :default "8080"
         :description "Port."

      assert.equal([[
Usage: foo [-o <o>] [-p <p>] [-h]

Options:
   -o <o>                default: a.out
   -p <p>                Port. (default: 8080)
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("does not show default value when show_default == false", function()
      local parser = Parser "foo"
      parser:option "-o"
         :default "a.out"
         :show_default(false)
      parser:option "-p"
         :default "8080"
         :show_default(false)
         :description "Port."

      assert.equal([[
Usage: foo [-o <o>] [-p <p>] [-h]

Options:
   -o <o>
   -p <p>                Port.
   -h, --help            Show this help message and exit.]], parser:get_help())
   end)

   it("creates correct help message for commands", function()
      local parser = Parser "foo"
      parser:flag "-q --quiet"
      local run = parser:command "run"
         :description "Run! "
      run:option "--where"

      assert.equal([[
Usage: foo [-q] [-h] <command> ...

Options:
   -q, --quiet
   -h, --help            Show this help message and exit.

Commands:
   run                   Run! ]], parser:get_help())
   end)

   it("creates correct help message for subcommands", function()
      local parser = Parser "foo"
      parser:flag "-q" "--quiet"
      local run = parser:command "run"
      run:option "--where"

      assert.equal([[
Usage: foo run [--where <where>] [-h]

Options:
   --where <where>
   -h, --help            Show this help message and exit.]], run:get_help())
   end)

   it("uses message provided by user", function()
      local parser = Parser "foo"
         :help "I don't like your format of help messages"
      parser:flag "-q" "--quiet"

      assert.equal([[
I don't like your format of help messages]], parser:get_help())
   end)

   it("does not mention hidden arguments, options, and commands", function()
      local parser = Parser "foo"
      parser:argument "normal"
      parser:argument "deprecated"
         :args "?"
         :hidden(true)
      parser:flag "--feature"
      parser:flag "--misfeature"
         :hidden(true)
      parser:command "good"
      parser:command "okay"
      parser:command "never-use-this-one"
         :hidden(true)

      assert.equal([[
Usage: foo [--feature] [-h] <normal> <command> ...

Arguments:
   normal

Options:
   --feature
   -h, --help            Show this help message and exit.

Commands:
   good
   okay]], parser:get_help())
   end)

   it("omits categories if all elements are hidden", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:argument "deprecated"
         :args "?"
         :hidden(true)
      parser:flag "--misfeature"
         :hidden(true)

      assert.equal([[
Usage: foo]], parser:get_help())
   end)

   it("supports grouping options", function()
      local parser = Parser "foo"
         :add_help(false)
      parser:argument "thing"

      parser:group("Options for setting position",
         parser:option "--coords"
            :args(2)
            :argname {"<x>", "<y>"}
            :description "Set coordinates.",
         parser:option "--polar"
            :args(2)
            :argname {"<rad>", "<ang>"}
            :description "Set polar coordinates."
      )

      parser:group("Options for setting style",
         parser:flag "--dotted"
            :description "More dots.",
         parser:option "--width"
            :argname "<px>"
            :description "Set width."
      )

      assert.equal([[
Usage: foo [--coords <x> <y>] [--polar <rad> <ang>] [--dotted]
       [--width <px>] <thing>

Arguments:
   thing

Options for setting position:
   --coords <x> <y>      Set coordinates.
   --polar <rad> <ang>   Set polar coordinates.

Options for setting style:
   --dotted              More dots.
   --width <px>          Set width.]], parser:get_help())
   end)

   it("adds default group with 'other' prefix if not all elements of a type are grouped", function()
      local parser = Parser "foo"

      parser:group("Main arguments",
         parser:argument "foo",
         parser:argument "bar",
         parser:flag "--use-default-args"
      )

      parser:argument "optional"
         :args "?"

      parser:group("Main options",
         parser:flag "--something",
         parser:option "--test"
      )

      parser:flag "--version"

      parser:group("Some commands",
         parser:command "foo",
         parser:command "bar"
      )

      parser:command "another-command"

      assert.equal([[
Usage: foo [--use-default-args] [--something] [--test <test>]
       [--version] [-h] <foo> <bar> [<optional>] <command> ...

Main arguments:
   foo
   bar
   --use-default-args

Other arguments:
   optional

Main options:
   --something
   --test <test>

Other options:
   --version
   -h, --help            Show this help message and exit.

Some commands:
   foo
   bar

Other commands:
   another-command]], parser:get_help())
   end)
end)
