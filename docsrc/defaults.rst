Default values
==============

For elements such as arguments and options, if ``default`` property is set, its value is stored in case the element was not used.

.. code-block:: lua
   :linenos:

   parser:option("-o --output", "Output file.", "a.out")
   -- Equivalent:
   parser:option "-o" "--output"
      :description "Output file."
      :default "a.out"

::

   $ lua script.lua

.. code-block:: lua

   {
      output = "a.out"
   }

The existence of a default value is reflected in help message, unless ``show_default`` property is set to ``false``.

::

   $ lua script.lua --help

::

   Usage: script.lua [-o <output>] [-h]

   Options: 
      -o <output>, --output <output>
                            Output file. (default: a.out)
      -h, --help            Show this help message and exit.

Note that invocation without required arguments is still an error.

::

   $ lua script.lua -o

::

   Usage: script.lua [-o <output>] [-h]

   Error: too few arguments

Default mode
------------

``defmode`` property regulates how argparse should use the default value of an element.

If ``defmode`` contains ``u`` (for unused), the default value will be automatically passed to the element if it was not invoked at all. This is the default behavior.

If ``defmode`` contains ``a`` (for argument), the default value will be automatically passed to the element if not enough arguments were passed, or not enough invocations were made.

Consider the difference:

.. code-block:: lua
   :linenos:

   parser:option "-o"
      :default "a.out"
   parser:option "-p" 
      :default "password"
      :defmode "arg"

::

   $ lua script.lua -h

::

   Usage: script.lua [-o <o>] [-p [<p>]] [-h]

   Options:
      -o <o>                default: a.out
      -p [<p>]              default: password
      -h, --help            Show this help message and exit.

::

   $ lua script.lua

.. code-block:: lua

   {
      o = "a.out"
   }

::

   $ lua script.lua -p


.. code-block:: lua

   {
      o = "a.out",
      p = "password"
   }

::

   $ lua script.lua -o

::

   Usage: script.lua [-o <o>] [-p [<p>]] [-h]

   Error: too few arguments
