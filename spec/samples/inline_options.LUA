-- LUAcheck: ignore 4
-- LUAcheck: ignore foo bar
foo()
bar()

local function f(a) -- LUAcheck: no unused args
   -- LUAcheck: globals baz
   foo()
   bar()
   baz()
   qu() -- LUAcheck: globals qu
   qu()
end

baz() -- LUAcheck should ignore this comment

-- LUAcheck: push ignore 2/f
local f
-- LUAcheck: push ignore 2/g
local g
-- LUAcheck: pop
local f, g
-- LUAcheck: pop
local f, g

-- LUAcheck: push
local function f() --LUAcheck: ignore
   -- LUAcheck: pop
end

-- LUAcheck: ignore 5
do end
-- LUAcheck: enable 54
do end
if false then end
