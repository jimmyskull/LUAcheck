-- LUAcheck: allow defined top
foo = 4
print(foo)
bar = 6 -- LUAcheck: ignore 131

function f()
   baz = 5
   -- LUAcheck: allow defined
   qu = 4
   print(qu)
end

-- LUAcheck: module, globals external
quu = 7
print(external)

local function g() -- LUAcheck: ignore
   external = 8
end
