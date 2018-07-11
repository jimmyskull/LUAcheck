local raw_check = require "luacheck.check"

local function remove_cyclomatic_complexity_warnings(events)
   for i = #events, 1, -1 do
      if events[i].code == "561" then
         table.remove(events, i)
      end
   end
end

local function check_full(src)
   local report = raw_check(src)
   remove_cyclomatic_complexity_warnings(report.events)
   return report
end

local function check(src)
   return check_full(src).events
end

describe("check", function()
   it("does not find anything wrong in an empty block", function()
      assert.same({}, check(""))
   end)

   it("detects duplicated fields in table literals", function()
      assert.same({
         {code = "314", field = "key", line = 3, column = 4, end_column = 4,
            overwritten_line = 7, overwritten_column = 4, overwritten_end_column = 6},
         {code = "314", field = "2", index = true, line = 6, column = 4, end_column = 4,
            overwritten_line = 9, overwritten_column = 4, overwritten_end_column = 4},
         {code = "314", field = "key", line = 7, column = 4, end_column = 6,
            overwritten_line = 8, overwritten_column = 4, overwritten_end_column = 6},
         {code = "314", field = "0.2e1", line = 9, column = 4, end_column = 4,
            overwritten_line = 10, overwritten_column = 4, overwritten_end_column = 4}
      }, check[[
local x, y, z = 1, 2, 3
return {
   ["key"] = 4,
   [z] = 7,
   1,
   y,
   key = x,
   key = 0,
   [0.2e1] = 6,
   [2] = 7
}
]])
   end)

   it("considers a variable assigned even if it can't get a value due to short rhs (it still gets nil)", function()
      assert.same({
         {code = "311", name = "a", line = 1, column = 7, end_column = 7,
            overwritten_line = 2, overwritten_column = 1, overwritten_end_column = 1},
         {code = "311", name = "b", line = 1, column = 10, end_column = 10,
            overwritten_line = 2, overwritten_column = 4, overwritten_end_column = 4},
         {code = "532", line = 2, column = 6, end_column = 6}
      }, check[[
local a, b = "foo", "bar"
a, b = "bar"
return a, b
]])
   end)

   it("reports vartype == var when the unused value is not the initial", function()
      assert.same({
         {code = "312", name = "b", line = 1, column = 23, end_column = 23,
            overwritten_line = 4, overwritten_column = 4, overwritten_end_column = 4},
         {code = "311", name = "a", line = 2, column = 4, end_column = 4,
            overwritten_line = 3, overwritten_column = 4, overwritten_end_column = 4}
      }, check[[
local function foo(a, b)
   a = a or "default"
   a = 42
   b = 7
   return a, b
end

return foo
]])
   end)

   it("does not detect unused values in loops", function()
      assert.same({
         {code = "113", name = "print", indexing = {"print"}, line = 3, column = 4, end_column = 8},
         {code = "113", name = "math", indexing = {"math", "floor"}, line = 4, column = 8, end_column = 11}
      }, check[[
local a = 10
while a > 0 do
   print(a)
   a = math.floor(a/2)
end
]])
   end)

   it("detects unused local value referred to from closure in incompatible branch", function()
      assert.same({
         {code = "311", name = "a", line = 4, column = 4, end_column = 4},
         {code = "321", name = "a", line = 6, column = 28, end_column = 28}
      }, check[[
local a

if (...)() then
   a = 1
else
   (...)(function() return a end)
end
]])
   end)

   it("detects unused upvalue value referred to from closure in incompatible branch", function()
      assert.same({
         {code = "311", name = "a", line = 4, column = 21, end_column = 21},
         {code = "321", name = "a", line = 6, column = 28, end_column = 28}
      }, check[[
local a

if (...)() then
   (...)(function() a = 1 end)
else
   (...)(function() return a end)
end
]])
   end)

   it("handles upvalues before infinite loops", function()
      assert.same({
         {code = "221", name = "x", line = 1, column = 7, end_column = 7},
         {code = "211", name = "f", func = true, line = 2, column = 16, end_column = 16}
      }, check[[
local x
local function f() return x end
::loop::
goto loop
]])
   end)

   it("detects redefinition in the same scope", function()
      assert.same({
         {code = "211", name = "foo", line = 1, column = 7, end_column = 9},
         {code = "411", name = "foo", line = 2, column = 7, end_column = 9,
            prev_line = 1, prev_column = 7, prev_end_column = 9},
         {code = "113", name = "print", indexing = {"print"}, line = 3, column = 1, end_column = 5}
      }, check[[
local foo
local foo = "bar"
print(foo)
]])
   end)

   it("detects redefinition of function arguments", function()
      assert.same({
         {code = "212", name = "foo", line = 1, column = 17, end_column = 19},
         {code = "212", name = "...", line = 1, column = 22, end_column = 24},
         {code = "412", name = "foo", line = 2, column = 10, end_column = 12,
            prev_line = 1, prev_column = 17, prev_end_column = 19}
      }, check[[
return function(foo, ...)
   local foo = 1
   return foo
end
]])
   end)

   it("marks redefinition of implicit self", function()
      assert.same({
         {code = "212", name = "self", line = 2, column = 11, end_column = 11, self = true},
         {code = "212", name = "self", line = 4, column = 14, end_column = 14, self = true},
         {code = "432", name = "self", line = 4, column = 14, end_column = 14, self = true,
            prev_line = 2, prev_column = 11, prev_end_column = 11}
      }, check[[
local t = {}
function t:f()
   local o = {}
   function o:g() end
   return o
end
return t
]])

      assert.same({
         {code = "212", name = "self", line = 2, column = 14, end_column = 17},
         {code = "212", name = "self", line = 4, column = 14, end_column = 14, self = true},
         {code = "432", name = "self", line = 4, column = 14, end_column = 14,
            prev_line = 2, prev_column = 14, prev_end_column = 17}
      }, check[[
local t = {}
function t.f(self)
   local o = {}
   function o:g() end
   return o
end
return t
]])

      assert.same({
         {code = "212", name = "self", line = 2, column = 11, end_column = 11, self = true},
         {code = "212", name = "self", line = 4, column = 17, end_column = 20},
         {code = "432", name = "self", line = 4, column = 17, end_column = 20,
            prev_line = 2, prev_column = 11, prev_end_column = 11}
      }, check[[
local t = {}
function t:f()
   local o = {}
   function o.g(self) end
   return o
end
return t
]])
   end)

   it("detects shadowing definitions", function()
      assert.same({
         {code = "431", name = "a", line = 4, column = 10, end_column = 10,
            prev_line = 1, prev_column = 7, prev_end_column = 7},
         {code = "421", name = "a", line = 7, column = 13, end_column = 13,
            prev_line = 4, prev_column = 10, prev_end_column = 10}
      }, check[[
local a = 46

return a, function(foo, ...)
   local a = 1

   do
      local a = 6
      foo(a, ...)
   end

   return a
end
]])
   end)

   it("detects unused labels", function()
      assert.same({
         {code = "521", label = "fail", line = 2, column = 4, end_column = 11}
      }, check[[
::fail::
do ::fail:: end
goto fail
]])
   end)

   it("detects unbalanced assignments", function()
      assert.same({
         {code = "532", line = 4, column = 6, end_column = 6},
         {code = "531", line = 5, column = 6, end_column = 6}
      }, check[[
local a, b = 4; (...)(a)

a, b = (...)(); (...)(a, b)
a, b = 5; (...)(a, b)
a, b = 1, 2, 3; (...)(a, b)
]])
   end)

   it("detects empty blocks", function()
      assert.same({
         {code = "541", line = 1, column = 1, end_column = 2},
         {code = "542", line = 3, column = 8, end_column = 11},
         {code = "542", line = 5, column = 12, end_column = 15},
         {code = "542", line = 7, column = 1, end_column = 4}
      }, check[[
do end

if ... then

elseif ... then

else

end

while ... do end
repeat until ...
]])
   end)

   it("detects empty statements", function()
      assert.same({
         {code = "551", line = 1, column = 1, end_column = 1},
         {code = "541", line = 2, column = 1, end_column = 2},
         {code = "551", line = 2, column = 8, end_column = 8},
         {code = "551", line = 4, column = 20, end_column = 20},
         {code = "551", line = 7, column = 17, end_column = 17}
      }, check[[
;
do end;;
local foo = "bar";
foo = foo .. "baz";;

while true do
   if foo() then;
      goto fail;
   elseif foo() then
      break;
   end
end

::fail::
return foo;
]])
   end)

   it("emits events, per-line options, and line lengths", function()
      assert.same({
         events = {
            {push = true, line = 1, column = 1, end_column = 28},
            {options = {ignore = {"bar"}}, line = 1, column = 1, end_column = 28},
            {code = "211", name = "foo", line = 2, column = 7, end_column = 9},
            {code = "211", name = "bar", line = 2, column = 12, end_column = 14},
            {pop = true, line = 3, column = 1, end_column = 16},
            {push = true, closure = true, line = 4, column = 8},
            {options = {ignore = {".*"}}, line = 5, column = 1, end_column = 19},
            {code = "512", line = 7, column = 1, end_column = 3},
            {code = "213", name = "_", line = 7, column = 5, end_column = 5},
            {code = "113", name = "pairs", indexing = {"pairs"}, line = 7, column = 10, end_column = 14},
            {pop = true, closure = true, line = 9, column = 1}
         },
         per_line_options = {
            [2] = {{options = {ignore = {"foo"}}, line = 2, column = 16, end_column = 38}}
         },
         line_lengths = {28, 38, 16, 17, 19, 17, 32, 16, 3},
         line_endings = {"comment", "comment", "comment", nil, "comment", "comment", nil, "comment", nil}
      }, check_full[[
-- luacheck: push ignore bar
local foo, bar -- luacheck: ignore foo
-- luacheck: pop
return function()
-- luacheck: ignore
-- luacheck: push
for _ in pairs({}) do return end
-- luacheck: pop
end
]])
   end)

   it("emits correct inline option error messages", function()
      assert.same({
         {code = "023", line = 1, column = 1, end_column = 16},
         {code = "022", line = 2, column = 1, end_column = 17},
         {code = "021", msg = "unknown inline option 'something strange'", line = 3, column = 1, end_column = 30},
         {code = "021", msg = "inline option 'std' expects 1 argument, 0 given", line = 4, column = 1, end_column = 16},
         {code = "021", msg = "inline option 'std' expects 1 argument, 3 given", line = 5, column = 1, end_column = 30},
         {code = "021", msg = "inline option 'no unused' expects 0 arguments, 2 given",
            line = 6, column = 1, end_column = 43},
         {code = "021", msg = "unknown inline option 'no ignore anything please'",
            line = 7, column = 1, end_column = 38},
         {code = "021", msg = "empty inline option", line = 8, column = 1, end_column = 12},
         {code = "021", msg = "empty inline option invocation", line = 9, column = 1, end_column = 38}
      }, check_full[[
-- luacheck: pop
-- luacheck: push
-- luacheck: something strange
-- luacheck: std
-- luacheck: std lua51 + lua52
-- luacheck: no unused, no unused very much
-- luacheck: no ignore anything please
-- luacheck:
-- luacheck: no unused, , no redefined
]].events)
   end)

   it("handles argparse sample", function()
      assert.table(check(io.open("spec/samples/argparse.lua", "rb"):read("*a")))
   end)
end)
