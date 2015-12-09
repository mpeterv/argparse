Callbacks
=========

Converters
----------

argparse can perform automatic validation and conversion on arguments. If ``convert`` property of an element is a function, it will be applied to all the arguments passed to it. The function should return ``nil`` and, optionally, an error message if conversion failed. Standard ``tonumber`` and ``io.open`` functions work exactly like that.

.. code-block:: lua
   :linenos:

   parser:argument "input"
      :convert(io.open)
   parser:option "-t --times"
      :convert(tonumber)

::

   $ lua script.lua foo.txt -t5

.. code-block:: lua

   {
      input = file_object,
      times = 5
   }

::

   $ lua script.lua nonexistent.txt

::

   Usage: script.lua [-t <times>] [-h] <input>

   Error: nonexistent.txt: No such file or directory

::

   $ lua script.lua foo.txt --times=many

::

   Usage: script.lua [-t <times>] [-h] <input>

   Error: malformed argument 'many'

Table converters
^^^^^^^^^^^^^^^^

If convert property of an element is a table, arguments passed to it will be used as keys. If a key is missing, an error is raised.

.. code-block:: lua
   :linenos:

   parser:argument "choice"
      :convert {
         foo = "Something foo-related",
         bar = "Something bar-related"
      }

::

   $ lua script.lua bar

.. code-block:: lua

   {
      choice = "Something bar-related"
   }

::

   $ lua script.lua baz

::

   Usage: script.lua [-h] <choice>

   Error: malformed argument 'baz'

Actions
-------

.. _actions:

Argument and option actions
^^^^^^^^^^^^^^^^^^^^^^^^^^^

argparse uses action callbacks to process invocations of arguments and options. Default actions simply put passed arguments into the result table as a single value or insert into an array depending on number of arguments the option can take and how many times it can be used.

A custom action can be set using ``action`` property. An action must be a function. and will be called after each invocation of the option or the argument it is assigned to. Four arguments are passed: result table, target index in that table, an argument or an array of arguments passed by user, and overwrite flag used when an option is invoked too many times.

Converters are applied before actions.

Initial value to be stored at target index in the result table can be set using ``init`` property, or also using ``default`` property if the value is not a string.

.. code-block:: lua
   :linenos:

   parser:option("--exceptions"):args("*"):action(function(args, _, exceptions)
      for _, exception in ipairs(exceptions) do
         table.insert(args.exceptions, exception)
      end
   end):init({"foo", "bar"})

   parser:flag("--no-exceptions"):action(function()
      args.exceptions = {}
   end)

::

   $ lua script.lua --exceptions x y --exceptions z t

.. code-block:: lua

   {
      exceptions = {
         "foo",
         "bar",
         "x",
         "y",
         "z",
         "t"
      }
   }

::

   $ lua script.lua --exceptions x y --no-exceptions

.. code-block:: lua

   {
      exceptions = {}
   }

Actions can also be used when a flag needs to print some message and exit without parsing remaining arguments.

.. code-block:: lua
   :linenos:

   parser:flag("-v --version"):action(function()
      print("script v1.0.0")
      os.exit(0)
   end)

::

   $ lua script.lua -v

::

   script v1.0.0

Built-in actions
^^^^^^^^^^^^^^^^

These actions can be referred to by their string names when setting ``action`` property:

=========== =======================================================
Name        Description
=========== =======================================================
store       Stores argument or arguments at target index.
store_true  Stores ``true`` at target index.
store_false Stores ``false`` at target index.
count       Increments number at target index.
append      Appends argument or arguments to table at target index.
concat      Appends arguments one by one to table at target index.
=========== =======================================================

Examples using ``store_false`` and ``concat`` actions:

.. code-block:: lua
   :linenos:

   parser:flag("--candy")
   parser:flag("--no-candy"):target("candy"):action("store_false")
   parser:flag("--rain", "Enable rain", false)
   parser:option("--exceptions"):args("*"):action("concat"):init({"foo", "bar"})

::

   $ lua script.lua

.. code-block:: lua

   {
      rain = false
   }

::

   $ lua script.lua --candy

.. code-block:: lua

   {
      candy = true,
      rain = false
   }

::

   $ lua script.lua --no-candy --rain

.. code-block:: lua

   {
      candy = false,
      rain = true
   }

::

   $ lua script.lua --exceptions x y --exceptions z t

.. code-block:: lua

   {
      exceptions = {
         "foo",
         "bar",
         "x",
         "y",
         "z",
         "t"
      },
      rain = false
   }

Command actions
^^^^^^^^^^^^^^^

Actions for parsers and commands are simply callbacks invoked after parsing, with result table and command name as the arguments. Actions for nested commands are called first.

.. code-block:: lua
   :linenos:

   local install = parser:command("install"):action(function(args, name)
      print("Running " .. name)
      -- Use args here
   )

   parser:action(function(args)
      print("Callbacks are fun!")
   end)

::

   $ lua script.lua install

::

   Running install
   Callbacks are fun!
