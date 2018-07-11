Command line interface
======================

``LUAcheck`` program accepts files, directories and `rockspecs <https://github.com/LUArocks/LUArocks/wiki/Rockspec-format>`_ as arguments. They can be filtered using ``--include-files`` and ``--exclude-files`` options, see below.

* Given a file, ``LUAcheck`` will check it.
* Given ``-``, ``LUAcheck`` will check stdin.
* Given a directory, ``LUAcheck`` will check all files within it, selecting only files with ``.LUA`` extension unless ``--include-files`` option is used. This feature requires `LUAFileSystem <http://keplerproject.github.io/LUAfilesystem/>`_ (installed automatically if LUARocks was used to install LUAcheck).
* Given a rockspec (a file with ``.rockspec`` extension), ``LUAcheck`` will check all files with ``.LUA`` extension mentioned in the rockspec in ``build.install.LUA``, ``build.install.bin`` and ``build.modules`` tables.

The output of ``LUAcheck`` consists of separate reports for each checked file and ends with a summary::

   $ LUAcheck src
   Checking src/bad_code.LUA                         5 warnings

       src/bad_code.LUA:3:16: unused variable helper
       src/bad_code.LUA:3:23: unused variable length argument
       src/bad_code.LUA:7:10: setting non-standard global variable embrace
       src/bad_code.LUA:8:10: variable opt was previously defined as an argument on line 7
       src/bad_code.LUA:9:11: accessing undefined variable hepler

   Checking src/good_code.LUA                        OK
   Checking src/python_code.LUA                      1 error

       src/python_code.LUA:1:6: expected '=' near '__future__'

   Checking src/unused_code.LUA                      9 warnings

       src/unused_code.LUA:3:18: unused argument baz
       src/unused_code.LUA:4:8: unused loop variable i
       src/unused_code.LUA:5:13: unused variable q
       src/unused_code.LUA:7:11: unused loop variable a
       src/unused_code.LUA:7:14: unused loop variable b
       src/unused_code.LUA:7:17: unused loop variable c
       src/unused_code.LUA:13:7: value assigned to variable x is unused
       src/unused_code.LUA:14:1: value assigned to variable x is unused
       src/unused_code.LUA:22:1: value assigned to variable z is unused

   Total: 14 warnings / 1 error in 4 files

``LUAcheck`` chooses exit code as follows:

* Exit code is ``0`` if no warnings or errors occurred.
* Exit code is ``1`` if some warnings occurred but there were no syntax errors or invalid inline options.
* Exit code is ``2`` if there were some syntax errors or invalid inline options.
* Exit code is ``3`` if some files couldn't be checked, typically due to an incorrect file name.
* Exit code is ``4`` if there was a critical error (invalid CLI arguments, config, or cache file).

.. _cliopts:

Command line options
--------------------

Short options that do not take an argument can be combined into one, so that ``-qqu`` is equivalent to ``-q -q -u``. For long options, both ``--option value`` or ``--option=value`` can be used.

Options taking several arguments can be used several times; ``--ignore foo --ignore bar`` is equivalent to ``--ignore foo bar``.

Note that options that may take several arguments, such as ``--globals``, should not be used immediately before positional arguments; given ``--globals foo bar file.LUA``, ``LUAcheck`` will consider all ``foo``, ``bar`` and ``file.LUA`` global and then panic as there are no file names left.

======================================= ================================================================================
Option                                  Meaning
======================================= ================================================================================
``-g | --no-global``                    Filter out warnings related to global variables.
``-u | --no-unused``                    Filter out warnings related to unused variables and values.
``-r | --no-redefined``                 Filter out warnings related to redefined variables.
``-a | --no-unused-args``               Filter out warnings related to unused arguments and loop variables.
``-s | --no-unused-secondaries``        Filter out warnings related to unused variables set together with used ones.

                                        See :ref:`secondaryvaluesandvariables`
``--no-self``                           Filter out warnings related to implicit ``self`` argument.
``--std <std>``                         Set standard globals. ``<std>`` can be one of:

                                        * ``LUA51`` - globals of LUA 5.1 without deprecated ones;
                                        * ``LUA51c`` - globals of LUA 5.1;
                                        * ``LUA52`` - globals of LUA 5.2;
                                        * ``LUA52c`` - globals of LUA 5.2 compiled with LUA_COMPAT_ALL;
                                        * ``LUA53`` - globals of LUA 5.3;
                                        * ``LUA53c`` - globals of LUA 5.3 compiled with LUA_COMPAT_5_2;
                                        * ``LUAjit`` - globals of LUAJIT 2.x;
                                        * ``ngx_LUA`` - globals of Openresty `LUA-nginx-module <https://github.com/openresty/LUA-nginx-module>`_ 0.10.10, including standard LUAJIT 2.x globals;
                                        * ``min`` - intersection of globals of LUA 5.1, LUA 5.2, LUA 5.3 and LUAJIT 2.x;
                                        * ``max`` - union of globals of LUA 5.1, LUA 5.2, LUA 5.3 and LUAJIT 2.x;
                                        * ``_G``  (default) - same as ``LUA51c``, ``LUA52c``, ``LUA53c``, or ``LUAjit`` depending on version of LUA used
                                          to run ``LUAcheck`` or same as ``max`` if couldn't detect the version;
                                        * ``love`` - globals added by `LÖVE <https://love2d.org>`_ (love2d);
                                        * ``busted`` - globals added by Busted 2.0;
                                        * ``rockspec`` - globals allowed in rockspecs;
                                        * ``none`` - no standard globals.

                                        See :ref:`stds`
``--globals [<name>] ...``              Add custom global variables or fields on top of standard ones. See :ref:`fields`
``--read-globals [<name>] ...``         Add read-only global variables or fields.
``--new-globals [<name>] ...``          Set custom global variables or fields. Removes custom globals added previously.
``--new-read-globals [<name>] ...``     Set read-only global variables or fields. Removes read-only globals added previously.
``--not-globals [<name>] ...``          Remove custom and standard global variables or fields.
``-c | --compat``                       Equivalent to ``--std max``.
``-d | --allow-defined``                Allow defining globals implicitly by setting them.

                                        See :ref:`implicitlydefinedglobals`
``-t | --allow-defined-top``            Allow defining globals implicitly by setting them in the top level scope.

                                        See :ref:`implicitlydefinedglobals`
``-m | --module``                       Limit visibility of implicitly defined globals to their files.

                                        See :ref:`modules`
``--max-line-length <length>``          Set maximum allowed line length (default: 120).
``--no-max-line-length``                Do not limit line length.
``--max-code-line-length <length>``     Set maximum allowed length for lines ending with code (default: 120).
``--no-max-code-line-length``           Do not limit code line length.
``--max-string-line-length <length>``   Set maximum allowed length for lines within a string (default: 120).
``--no-max-string-line-length``         Do not limit string line length.
``--max-comment-line-length <length>``  Set maximum allowed length for comment lines (default: 120).
``--no-max-comment-line-length``        Do not limit comment line length.
``--max-cyclomatic-complexity <limit>`` Set maximum cyclomatic complexity for functions.
``--no-max-cyclomatic-complexity``      Do not limit function cyclomatic complexity (default).
``--ignore | -i <patt> [<patt>] ...``   Filter out warnings matching patterns.
``--enable | -e <patt> [<patt>] ...``   Do not filter out warnings matching patterns.
``--only | -o <patt> [<patt>] ...``     Filter out warnings not matching patterns.
``--no-inline``                         Disable inline options.
``--config <config>``                   Path to custom configuration file (default: ``.LUAcheckrc``).
``--no-config``                         Do not look up custom configuration file.
``--default-config <config>``           Default path to custom configuration file, to be used if ``--[no-]config`` is not used and ``.LUAcheckrc`` is not found.

                                        Default global location is:

                                        * ``%LOCALAPPDATA%\LUAcheck\.LUAcheckrc`` on Windows;
                                        * ``~/Library/Application Support/LUAcheck/.LUAcheckrc`` on OS X/macOS;
                                        * ``$XDG_CONFIG_HOME/LUAcheck/.LUAcheckrc`` or ``~/.config/LUAcheck/.LUAcheckrc`` on other systems.
``--no-default-config``                 Do not use fallback configuration file.
``--filename <filename>``               Use another filename in output, for selecting
                                        configuration overrides and for file filtering.
``--exclude-files <glob> [<glob>] ...`` Do not check files matching these globbing patterns. Recursive globs such as ``**/*.LUA`` are supported.
``--include-files <glob> [<glob>] ...`` Do not check files not matching these globbing patterns.
``--cache [<cache>]``                   Path to cache file. (default: ``.LUAcheckcache``). See :ref:`cache`
``--no-cache``                          Do not use cache.
``-j | --jobs``                         Check ``<jobs>`` files in parallel. Requires `LUALanes <http://cmr.github.io/lanes/>`_.
                                        Default number of jobs is set to number of available processing units.
``--formatter <formatter>``             Use custom formatter. ``<formatter>`` must be a module name or one of:

                                        * ``TAP`` - Test Anything Protocol formatter;
                                        * ``JUnit`` - JUnit XML formatter;
                                        * ``visual_studio`` - MSBuild/Visual Studio aware formatter;
                                        * ``plain`` - simple warning-per-line formatter;
                                        * ``default`` - standard formatter.
``-q | --quiet``                        Suppress report output for files without warnings.

                                        * ``-qq`` - Suppress output of warnings.
                                        * ``-qqq`` - Only output summary.
``--codes``                             Show warning codes.
``--ranges``                            Show ranges of columns related to warnings.
``--no-color``                          Do not colorize output.
``-v | --version``                      Show version of LUAcheck and its dependencies and exit.
``-h | --help``                         Show help and exit.
======================================= ================================================================================

.. _patterns:

Patterns
--------

CLI options ``--ignore``, ``--enable`` and ``--only`` and corresponding config options allow filtering warnings using pattern matching on warning codes, variable names or both. If a pattern contains a slash, the part before slash matches warning code and the part after matches variable name. Otherwise, if a pattern contains a letter or underscore, it matches variable name. Otherwise, it matches warning code. E.g.:

======= =========================================================================
Pattern Matching warnings
======= =========================================================================
4.2     Shadowing declarations of arguments or redefining them.
.*_     Warnings related to variables with ``_`` suffix.
4.2/.*_ Shadowing declarations of arguments with ``_`` suffix or redefining them.
======= =========================================================================

Unless already anchored, patterns matching variable names are anchored at both sides and patterns matching warning codes are anchored at their beginnings. This allows one to filter warnings by category (e.g. ``--only 1`` focuses ``LUAcheck`` on global-related warnings).

.. _fields:

Defining extra globals and fields
---------------------------------

CLI options ``--globals``, ``--new-globals``, ``--read-globals``, ``--new-read-globals``, and corresponding config options add new allowed globals or fields. E.g. ``--read-globals foo --globals foo.bar`` allows accessing ``foo`` global and mutating its ``bar`` field. ``--not-globals`` also operates on globals and fields and removes definitions of both standard and custom globals.

.. _stds:

Sets of standard globals
------------------------

CLI option ``--stds`` allows combining built-in sets described above using ``+``. For example, ``--std max`` is equivalent to ``--std=LUA51c+LUA52c+LUA53c+LUAjit``. Leading plus sign adds new sets to current one instead of replacing it. For instance, ``--std +busted`` is suitable for checking test files that use `Busted <http://olivinelabs.com/busted/>`_ testing framework. Custom sets of globals can be defined by mutating global variable ``stds`` in config. See :ref:`custom_stds`

Formatters
----------

CLI option ``--formatter`` allows selecting a custom formatter for ``LUAcheck`` output. A custom formatter is a LUA module returning a function with three arguments: report as returned by ``LUAcheck`` module (see :ref:`report`), array of file names and table of options. Options contain values assigned to ``quiet``, ``color``, ``limit``, ``codes``, ``ranges`` and ``formatter`` options in CLI or config. Formatter function must return a string.

.. _cache:

Caching
-------

If LUAFileSystem is available, LUAcheck can cache results of checking files. On subsequent checks, only files which have changed since the last check will be rechecked, improving run time significantly. Changing options (e.g. defining additional globals) does not invalidate cache. Caching can be enabled by using ``--cache <cache>`` option or ``cache`` config option. Using ``--cache`` without an argument or setting ``cache`` config option to ``true`` sets ``.LUAcheckcache`` as the cache file. Note that ``--cache`` must be used every time ``LUAcheck`` is run, not on the first run only.

Stable interface for editor plugins and tools
---------------------------------------------

Command-line interface of LUAcheck can change between minor releases. Starting from 0.11.0 version, the following interface is guaranteed at least till 1.0.0 version, and should be used by tools using LUAcheck output, e.g. editor plugins.

* LUAcheck should be started from the directory containing the checked file.
* File can be passed through stdin using ``-`` as argument or using a temporary file. Real filename should be passed using ``--filename`` option.
* Plain formatter should be used. It outputs one issue (warning or error) per line.
* To get precise error location, ``--ranges`` option can be used. Each line starts with real filename (passed using ``--filename``), followed by ``:<line>:<start_column>-<end_column>:``, where ``<line>`` is line number on which issue occurred and ``<start_column>-<end_column>`` is inclusive range of columns of token related to issue. Numbering starts from 1. If ``--ranges`` is not used, end column and dash is not printed.
* To get warning and error codes, ``--codes`` option can be used. For each line, substring between parentheses contains three digit issue code, prefixed with ``E`` for errors and ``W`` for warnings. Lack of such substring indicates a fatal error (e.g. I/O error).
* The rest of the line is warning message.

If compatibility with older LUAcheck version is desired, output of ``LUAcheck --help`` can be used to get its version. If it contains string ``0.<minor>.<patch>``, where ``<minor>`` is at least 11 and ``patch`` is any number, interface described above should be used.
