Adding and configuring commands
===============================

A command is a subparser invoked when its name is passed as an argument. For example, in `git <http://git-scm.com>`_ CLI ``add``, ``commit``, ``push``, etc. are commands. Each command has its own set of arguments and options, but inherits options of its parent.

Commands can be added using ``:command(name, description, epilog)`` method. Just as options, commands can have several aliases.

.. code-block:: lua
   :linenos:

   parser:command "install i"

If a command it used, ``true`` is stored in the corresponding field of the result table.

::

   $ lua script.lua install

.. code-block:: lua

   {
      install = true
   }

A typo will result in an appropriate error message.

::

   $ lua script.lua instal

::

   Usage: script.lua [-h] <command> ...

   Error: unknown command 'instal'
   Did you mean 'install'?

Adding elements to commands
---------------------------

The Command class is a subclass of the Parser class, so all the Parser's methods for adding elements work on commands, too.

.. code-block:: lua
   :linenos:

   local install = parser:command "install"
   install:argument "rock"
   install:option "-f --from"

::

   $ lua script.lua install foo --from=bar


.. code-block:: lua

   {
      install = true,
      rock = "foo",
      from = "bar"
   }

Commands have their own usage and help messages.

::

   $ lua script.lua install

::

   Usage: script.lua install [-f <from>] [-h] <rock>

   Error: too few arguments

::

   $ lua script.lua install --help

::

   Usage: script.lua install [-f <from>] [-h] <rock>

   Arguments:
      rock

   Options:
      -f <from>, --from <from>
      -h, --help            Show this help message and exit.

Making a command optional
-------------------------

By default, if a parser has commands, using one of them is obligatory.


.. code-block:: lua
   :linenos:

   local parser = argparse()
   parser:command "install"

::

   $ lua script.lua

::

   Usage: script.lua [-h] <command> ...

   Error: a command is required

This can be changed using ``require_command`` property.

.. code-block:: lua
   :linenos:

   local parser = argparse()
      :require_command(false)
   parser:command "install"
