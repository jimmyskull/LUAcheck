local format = require "LUAcheck.format".format

local function mark_colors(s)
   return (s:gsub("\27%[%d+m", "\27"):gsub("\27+", "#"))
end

describe("format", function()
   it("returns formatted report", function()
      assert.equal([[Checking stdin                                    1 warning

    stdin:2:7: unused global variable 'foo'

Checking foo.LUA                                  1 warning

    foo.LUA:2:7: empty statement

Checking bar.LUA                                  OK
Checking baz.LUA                                  1 error

    baz.LUA:4:3: something went wrong

Total: 2 warnings / 1 error in 4 files]], format({
   warnings = 2,
   errors = 1,
   fatals = 0,
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {
      {
         code = "551",
         line = 2,
         column = 7
      }
   },
   {},
   {
      {
         code = "011",
         line = 4,
         column = 3,
         msg = "something went wrong"
      }
   }
}, {"stdin", "foo.LUA", "bar.LUA", "baz.LUA"}, {color = false}))
   end)

   it("does not output OK messages with options.quiet >= 1", function()
      assert.equal([[Checking stdin                                    1 warning

    stdin:2:7: unused global variable 'foo'

Checking foo.LUA                                  1 warning / 1 error

    foo.LUA:2:7: unused global variable 'foo'
    foo.LUA:3:10: bad, bad inline option

Checking baz.LUA                                  Syntax error

    baz.LUA: error message

Total: 2 warnings / 1 error in 3 files, couldn't check 1 file]], format({
   warnings = 2,
   errors = 1,
   fatals = 1,
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      },
      {
         code = "021",
         msg = "bad, bad inline option",
         line = 3,
         column = 10
      }
   },
   {},
   {
      fatal = "syntax",
      msg = "error message"
   }
}, {"stdin", "foo.LUA", "bar.LUA", "baz.LUA"}, {quiet = 1, color = false}))
   end)

   it("does not output warnings with options.quiet >= 2", function()
      assert.equal([[Checking stdin                                    1 warning
Checking foo.LUA                                  1 warning
Checking baz.LUA                                  Syntax error

Total: 2 warnings / 0 errors in 3 files, couldn't check 1 file]], format({
   warnings = 2,
   errors = 0,
   fatals = 1,
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {},
   {
      fatal = "syntax"
   }
}, {"stdin", "foo.LUA", "bar.LUA", "baz.LUA"}, {quiet = 2, color = false}))
   end)

   it("does not output file info with options.quiet == 3", function()
      assert.equal("Total: 2 warnings / 0 errors in 3 files, couldn't check 1 file", format({
   warnings = 2,
   errors = 0,
   fatals = 1,
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {},
   {
      fatal = "syntax"
   }
}, {"stdin", "foo.LUA", "bar.LUA", "baz.LUA"}, {quiet = 3, color = false}))
   end)

   it("colors output by default", function()
      if package.config:sub(1, 1) == "\\" and not os.getenv("ANSICON") then
         pending("uses terminal colors")
      end

      assert.equal([[Checking stdin                                    #1 warning#

    stdin:2:7: unused global variable #foo#

Checking foo.LUA                                  #1 warning#

    foo.LUA:2:7: unused global variable #foo#

Checking bar.LUA                                  #OK#
Checking baz.LUA                                  #Syntax error#

    baz.LUA: error message

Total: #2# warnings / #0# errors in 3 files, couldn't check 1 file]], mark_colors(format({
   warnings = 2,
   errors = 0,
   fatals = 1,
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {
      {
         code = "131",
         name = "foo",
         line = 2,
         column = 7
      }
   },
   {},
   {
      fatal = "syntax",
      msg = "error message"
   }
}, {"stdin", "foo.LUA", "bar.LUA", "baz.LUA"}, {})))
   end)
end)
