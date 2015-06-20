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

argparse can trigger a callback when an option or a command is encountered. The callback can be set using ``action`` property. Actions are called regardless of whether the rest of command line arguments are correct.

.. code-block:: lua
   :linenos:

   parser:argument "required_argument"

   parser:flag("-v --version", "Show version info and exit.")
      :action(function()
         print("script.lua v1.0.0")
         os.exit(0)
      end)

::

   $ lua script.lua -v

::

   script.lua v1.0.0
