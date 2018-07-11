-- LUAcheck: read globals foo bar
foo(bar, baz)
foo, bar, baz, baz[1] = false, true, nil, 5 -- LUAcheck: ignore 111/foo 121/ba.
-- LUAcheck: globals bar baz
foo, bar, baz = 678, 829, 914
