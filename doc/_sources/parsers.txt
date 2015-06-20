Creating and using parsers
==========================

The ``argparse`` module is a function which, when called, creates an instance of the Parser class.

.. code-block:: lua
   :linenos:

   -- script.lua
   local argparse = require "argparse"
   local parser = argparse()

``parser`` is now an empty parser which does not recognize any command line arguments or options.

Parsing command line arguments
------------------------------

``:parse([args])`` method of the Parser class returns a table with processed data from the command line or ``args`` array.

.. code-block:: lua
   :linenos:

   local args = parser:parse()
   print(args)  -- Assuming print is patched to handle tables nicely.

When executed, this script prints ``{}`` because the parser is empty and no command line arguments were supplied.

Error handling
^^^^^^^^^^^^^^

If the provided command line arguments are not recognized by the parser, it will print an error message and call ``os.exit(1)``.

::

   $ lua script.lua foo

::

   Usage: script.lua [-h]

   Error: too many arguments

If halting the program is undesirable, ``:pparse([args])`` method should be used. It returns boolean flag indicating success of parsing and result or error message.

An error can raised manually using ``:error()`` method.

.. code-block:: lua
   :linenos:

   parser:error("manual argument validation failed")

::

   Usage: script.lua [-h]

   Error: manual argument validation failed

Help option
^^^^^^^^^^^

As the automatically generated usage message states, there is a help option ``-h`` added to any parser by default.

When a help option is used, parser will print a help message and call ``os.exit(0)``.

::

   $ lua script.lua -h

::

   Usage: script.lua [-h]

   Options: 
      -h, --help            Show this help message and exit.

Typo autocorrection
^^^^^^^^^^^^^^^^^^^

When an option is not recognized by the parser, but there is an option with a similar name, a suggestion is automatically added to the error message.

::

   $ lua script.lua --hepl

::

   Usage: script.lua [-h]

   Error: unknown option '--hepl'
   Did you mean '--help'?

Configuring parsers
-------------------

Parsers have several properties affecting their behavior. For example, ``description`` and ``epilog`` properties set the text to be displayed in the help message after the usage message and after the listings of options and arguments, respectively. Another is ``name``, which overwrites the name of the program which is used in the usage message (default value is inferred from command line arguments).

There are several ways to set properties. The first is to chain setter methods of Parser object.

.. code-block:: lua
   :linenos:

   local parser = argparse()
      :name "script"
      :description "A testing script."
      :epilog "For more info, see http://example.com"

The second is to call a parser with a table containing some properties.

.. code-block:: lua
   :linenos:

   local parser = argparse() {
      name = "script",
      description = "A testing script.",
      epilog "For more info, see http://example.com."
   }

Finally, ``name``. ``description`` and ``epilog`` properties can be passed as arguments when calling a parser.

.. code-block:: lua
   :linenos:

   local parser = argparse("script", "A testing script.", "For more info, see http://example.com.")
