Configuration file
==================

``LUAcheck`` tries to load configuration from ``.LUAcheckrc`` file in the current directory. If not found, it will look for it in the parent directory and so on, going up until it reaches file system root. Path to config can be set using ``--config`` option, in which case it will be used during recursive loading. Paths within config are interpreted relatively to the directory from which it was loaded.

Config loading can be disabled using ``--no-config`` flag.

If neither of ``--config``, ``--no-config``, and ``--no-default-config`` options are used, ``LUAcheck`` will attempt to load configuration from value of ``--default-config`` option,
or ``%LOCALAPPDATA%\LUAcheck\.LUAcheckrc`` on Windows, ``~/Library/Application Support/LUAcheck/.LUAcheckrc`` on OS X/macOS, and ``$XDG_CONFIG_HOME/LUAcheck/.LUAcheckrc``
or ``~/.config/LUAcheck/.LUAcheckrc`` on other systems by default. Paths within default config are interpreted relatively to the current directory.

Config is simply a LUA script executed by ``LUAcheck``. It may set various options by assigning to globals or by returning a table with option names as keys.

Options loaded from config have the lowest priority: it's possible to overwrite them with CLI options or inline options.

.. _options:

Config options
--------------

============================= ======================================== ===================
Option                        Type                                     Default value
============================= ======================================== ===================
``quiet``                     Integer in range 0..3                    ``0``
``color``                     Boolean                                  ``true``
``codes``                     Boolean                                  ``false``
``ranges``                    Boolean                                  ``false``
``formatter``                 String or function                       ``"default"``
``cache``                     Boolean or string                        ``false``
``jobs``                      Positive integer                         ``1``
``exclude_files``             Array of strings                         ``{}``
``include_files``             Array of strings                         (Include all files)
``global``                    Boolean                                  ``true``
``unused``                    Boolean                                  ``true``
``redefined``                 Boolean                                  ``true``
``unused_args``               Boolean                                  ``true``
``unused_secondaries``        Boolean                                  ``true``
``self``                      Boolean                                  ``true``
``std``                       String or set of standard globals        ``"_G"``
``globals``                   Array of strings or field definition map ``{}``
``new_globals``               Array of strings or field definition map (Do not overwrite)
``read_globals``              Array of strings or field definition map ``{}``
``new_read_globals``          Array of strings or field definition map (Do not overwrite)
``not_globals``               Array of strings                         ``{}``
``compat``                    Boolean                                  ``false``
``allow_defined``             Boolean                                  ``false``
``allow_defined_top``         Boolean                                  ``false``
``module``                    Boolean                                  ``false``
``max_line_length``           Number or ``false``                      ``120``
``max_code_line_length``      Number or ``false``                      ``120``
``max_string_line_length``    Number or ``false``                      ``120``
``max_comment_line_length``   Number or ``false``                      ``120``
``max_cyclomatic_complexity`` Number or ``false``                      ``false``
``ignore``                    Array of patterns (see :ref:`patterns`)  ``{}``
``enable``                    Array of patterns                        ``{}``
``only``                      Array of patterns                        (Do not filter)
``inline``                    Boolean                                  ``true``
============================= ======================================== ===================

An example of a config which makes ``LUAcheck`` ensure that only globals from the portable intersection of LUA 5.1, LUA 5.2, LUA 5.3 and LUAJIT 2.0 are used, as well as disables detection of unused arguments:

.. code-block:: LUA
   :linenos:

   std = "min"
   ignore = {"212"}

.. _custom_stds:


Custom sets of globals
----------------------

``std`` option allows setting a custom standard set of globals using a table. This table can have two fields: ``globals`` and ``read_globals``.
Both of them should contain a field definition map defining some globals. The simplest way to define globals is to list their names:

.. code-block:: LUA
   :linenos:

   std = {
      globals = {"foo", "bar"}, -- these globals can be set and accessed.
      read_globals = {"baz", "quux"} -- these globals can only be accessed.
   }

For globals defined like this LUAcheck will additionally consider any fields within them defined. To define a global with a restricted set of fields, use
global name as key and a table as value. In that table, ``fields`` subtable can contain the fields in the same format:

.. code-block:: LUA
   :linenos:

   std = {
      read_globals = {
         foo = { -- Defining read-only global `foo`...
            fields = {
               field1 = { -- `foo.field1` is now defined...
                  fields = {
                     nested_field = {} -- `foo.field1.nested_field` is now defined...
                  }
               },
               field2 = {} -- `foo.field2` is defined.
            }
         }
      }
   }

Globals and fields can be marked read-only or not using ``read_only`` property with a boolean value.
Property ``other_fields`` controls whether the global or field can also contain other unspecified fields:

.. code-block:: LUA
   :linenos:

   std = {
      read_globals = {
         foo = { -- `foo` and its fields are read-only by default (because they are within `read_globals` table).
            fields = {
               bar = {
                  read_only = false, -- `foo.bar` is not read-only, can be set.
                  other_fields = true, -- `foo.bar[anything]` is defined and can be set or mutated (inherited from `foo.bar`).
                  fields = {
                     baz = {read_only = true}, -- `foo.bar.baz` is read-only as an exception.
                  }
               }
            }
         }
      }
   }

Custom sets can be given names by mutating global ``stds`` variable, so that they can then be used in ``--std`` CLI option
and ``std`` inline and config option.

.. code-block:: LUA
   :linenos:

   stds.some_lib = {...}
   std = "min+some_lib"

In config, ``globals``, ``new_globals``, ``read_globals``, and ``new_read_globals`` can also contain definitions in same format:

.. code-block:: LUA
   :linenos:

   read_globals = {
      server = {
         fields = {
            -- Allow mutating `server.sessions` with any keys...
            sessions = {read_only = false, other_fields = true},
            -- other fields...
         }
      },
      --- other globals...
   }

Per-file and per-path overrides
-------------------------------

The environment in which ``LUAcheck`` loads the config contains a special global ``files``. When checking a file ``<path>``, ``LUAcheck`` will override options from the main config with entries from ``files[<glob>]`` if ``<glob>`` matches ``<path>``, applying entries for more general globs first. For example, the following config re-enables detection of unused arguments only for files in ``src/dir``, but not for files ending with ``_special.LUA``, and allows using `Busted <http://olivinelabs.com/busted/>`_ globals within ``spec/``:

.. code-block:: LUA
   :linenos:

   std = "min"
   ignore = {"212"}
   files["src/dir"] = {enable = {"212"}}
   files["src/dir/**/*_special.LUA"] = {ignore = {"212"}}
   files["spec"] = {std = "+busted"}

Note that ``files`` table supports autovivification, so that

.. code-block:: LUA

   files["src/dir"].enable = {"212"}

and

.. code-block:: LUA

   files["src/dir"] = {enable = {"212"}}

are equivalent.
