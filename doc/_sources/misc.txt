Miscellaneous
=============

Generating and overwriting help and usage messages
--------------------------------------------------

The usage and help messages of parsers and commands can be generated on demand using ``:get_usage()`` and ``:get_help()`` methods, and overridden using ``help`` and ``usage`` properties.

Overwriting default help option
-------------------------------

If the property ``add_help`` of a parser is set to ``false``, no help option will be added to it. Otherwise, the value of the field will be used to configure it.

.. code-block:: lua
   :linenos:

   local parser = argparse()
      :add_help "/?"

::

   $ lua script.lua /?

::

   Usage: script.lua [/?]

   Options:
      /?                    Show this help message and exit.

Setting argument placeholder
----------------------------

For options and arguments, ``argname`` property controls the placeholder for the argument in the usage message.

.. code-block:: lua
   :linenos:

   parser:option "-f" "--from"
      :argname "<server>"

::

   $ lua script.lua --help

::

   Usage: script.lua [-f <server>] [-h]

   Options:
      -f <server>, --from <server>
      -h, --help            Show this help message and exit.

``argname`` can be an array of placeholders.

.. code-block:: lua
   :linenos:

   parser:option "--pair"
      :args(2)
      :argname {"<key>", "<value>"}

::

   $ lua script.lua --help

::

   Usage: script.lua [--pair <key> <value>] [-h]

   Options:
      --pair <key> <value>
      -h, --help            Show this help message and exit.

Disabling option handling
-------------------------

When ``handle_options`` property of a parser or a command is set to ``false``, all options will be passed verbatim to the argument list, as if the input included double-hyphens.

.. code-block:: lua
   :linenos:

   parser:handle_options(false)
   parser:argument "input"
      :args "*"
   parser:option "-f" "--foo"
      :args "*"

::

   $ lua script.lua bar -f --foo bar

.. code-block:: lua

   {
      input = {"bar", "-f", "--foo", "bar"}
   }

Prohibiting overuse of options
------------------------------

By default, if an option is invoked too many times, latest invocations overwrite the data passed earlier.

.. code-block:: lua
   :linenos:

   parser:option "-o --output"

::

   $ lua script.lua -oFOO -oBAR

.. code-block:: lua

   {
      output = "BAR"
   }

Set ``overwrite`` property to ``false`` to prohibit this behavior.

.. code-block:: lua
   :linenos:

   parser:option "-o --output"
      :overwrite(false)

::

   $ lua script.lua -oFOO -oBAR

::

   Usage: script.lua [-o <output>] [-h]

   Error: option '-o' must be used at most 1 time

Parsing algorithm
-----------------

argparse interprets command line arguments in the following way:

============= ================================================================================================================
Argument      Interpretation
============= ================================================================================================================
``foo``       An argument of an option or a positional argument.
``--foo``     An option.
``--foo=bar`` An option and its argument. The option must be able to take arguments.
``-f``        An option.
``-abcdef``   Letters are interpreted as options. If one of them can take an argument, the rest of the string is passed to it.
``--``        The rest of the command line arguments will be interpreted as positional arguments.
============= ================================================================================================================

Property lists
--------------

Parser properties
^^^^^^^^^^^^^^^^^

Properties that can be set as arguments when calling or constructing a parser, in this order:

=============== ======
Property        Type
=============== ======
``name``        String
``description`` String
``epilog``      String
=============== ======

Other properties:

=================== ==========================
Property            Type
=================== ==========================
``usage``           String
``help``            String
``require_command`` Boolean
``handle_options``  Boolean
``add_help``        Boolean or string or table
=================== ==========================

Command properties
^^^^^^^^^^^^^^^^^^

Properties that can be set as arguments when calling or constructing a command, in this order:

=============== ======
Property        Type
=============== ======
``name``        String
``description`` String
``epilog``      String
=============== ======

Other properties:

=================== ==========================
Property            Type
=================== ==========================
``target``          String
``usage``           String
``help``            String
``require_command`` Boolean
``handle_options``  Boolean
``action``          Function
``add_help``        Boolean or string or table
=================== ==========================

Argument properties
^^^^^^^^^^^^^^^^^^^

Properties that can be set as arguments when calling or constructing an argument, in this order:

=============== =================
Property        Type
=============== =================
``name``        String
``description`` String
``default``     String
``convert``     Function or table
``args``        Number or string
=============== =================

Other properties:

=================== ===============
Property            Type
=================== ===============
``target``          String
``defmode``         String
``show_default``    Boolean
``argname``         String or table
=================== ===============

Option and flag properties
^^^^^^^^^^^^^^^^^^^^^^^^^^

Properties that can be set as arguments when calling or constructing an option or a flag, in this order:

=============== =================
Property        Type
=============== =================
``name``        String
``description`` String
``default``     String
``convert``     Function or table
``args``        Number or string
``count``       Number or string
=============== =================

Other properties:

=================== ===============
Property            Type
=================== ===============
``target``          String
``defmode``         String
``show_default``    Boolean
``overwrite``       Booleans
``argname``         String or table
``action``          Function
=================== ===============
