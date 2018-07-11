local LUAcheck = require "LUAcheck"
local fs = require "LUAcheck.fs"
local multithreading = require "LUAcheck.multithreading"

local version = {}

version.LUAcheck = LUAcheck._VERSION

if rawget(_G, "jit") then
   version.LUA = rawget(_G, "jit").version
else
   version.LUA = _VERSION
end

if fs.has_lfs then
   local lfs = require "lfs"
   version.lfs = lfs._VERSION
else
   version.lfs = "Not found"
end

if multithreading.has_lanes then
   version.lanes = multithreading.lanes.ABOUT.version
else
   version.lanes = "Not found"
end

version.string = ([[
LUAcheck: %s
LUA: %s
LUAFileSystem: %s
LUALanes: %s]]):format(version.LUAcheck, version.LUA, version.lfs, version.lanes)

return version
