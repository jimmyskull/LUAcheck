-- LUAcheck: push
-- LUAcheck: std +busted
tostring(setfenv, print(it))
-- LUAcheck: pop
-- LUAcheck: std other_std
tostring(setfenv, print(it))
