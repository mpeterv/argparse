Adding and configuring arguments
================================

Positional arguments can be added using ``:argument(name, description, default, convert, args)`` method. It returns an Argument instance, which can be configured in the same way as Parsers. The ``name`` property is required.

.. code-block:: lua
   :linenos:

   parser:argument "input"

::

   $ lua script.lua foo

.. code-block:: lua

   {
      input = "foo"
   }

The data passed to the argument is stored in the result table at index ``input`` because it is the argument's name. The index can be changed using ``target`` property.

Setting number of consumed arguments
------------------------------------

``args`` property sets how many command line arguments the argument consumes. Its value is interpreted as follows:

================================================= =============================
Value                                             Interpretation
================================================= =============================
Number ``N``                                      Exactly ``N`` arguments
String ``A-B``, where ``A`` and ``B`` are numbers From ``A`` to ``B`` arguments
String ``N+``, where ``N`` is a number            ``N`` or more arguments
String ``?``                                      An optional argument
String ``*``                                      Any number of arguments
String ``+``                                      At least one argument
================================================= =============================

If more than one argument can be consumed, a table is used to store the data.

.. code-block:: lua
   :linenos:

   parser:argument("pair", "A pair of arguments.")
      :args(2)
   parser:argument("optional", "An optional argument.")
      :args "?"

::

   $ lua script.lua foo bar

.. code-block:: lua

   {
      pair = {"foo", "bar"}
   }

::

   $ lua script.lua foo bar baz

.. code-block:: lua

   {
      pair = {"foo", "bar"},
      optional = "baz"
   }
