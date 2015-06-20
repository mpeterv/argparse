Mutually exclusive groups
=========================

A group of options can be marked as mutually exclusive using ``:mutex(option, ...)`` method of the Parser class.

.. code-block:: lua
   :linenos:

   parser:mutex(
      parser:flag "-q --quiet",
      parser:flag "-v --verbose"
   )

If more than one element of a mutually exclusive group is used, an error is raised.

::

   $ lua script.lua -qv

::

   Usage: script.lua ([-q] | [-v]) [-h]

   Error: option '-v' can not be used together with option '-q'
