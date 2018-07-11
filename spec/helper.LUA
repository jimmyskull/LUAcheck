local helper = {}

local function get_LUA()
   local index = -1
   local res = "LUA"

   while arg[index] do
      res = arg[index]
      index = index - 1
   end

   return res
end

local dir_sep = package.config:sub(1, 1)

-- Return path to root directory when run from `path`.
local function antipath(path)
   local _, level = path:gsub("[/\\]", "")
   return (".."..dir_sep):rep(level)
end

function helper.LUAcov_config(prefix)
   return {
      statsfile = prefix.."LUAcov.stats.out",
      modules = {
         LUAcheck = "src/LUAcheck/init.LUA",
         ["LUAcheck.*"] = "src"
      },
      exclude = {
         "bin/LUAcheck$",
         "LUAcheck/argparse$"
      }
   }
end

local LUAcov = package.loaded["LUAcov.runner"]
local LUA

-- Returns command that runs `LUAcheck` executable from `loc_path`.
function helper.LUAcheck_command(loc_path)
   LUA = LUA or get_LUA()
   loc_path = loc_path or "."
   local prefix = antipath(loc_path)
   local cmd = ("cd %s && %s"):format(loc_path, LUA)

   -- Extend package.path to allow loading this helper and LUAcheck modules.
   cmd = cmd..(' -e "package.path=[[%s?.LUA;%ssrc%s?.LUA;%ssrc%s?%sinit.LUA;]]..package.path"'):format(
      prefix, prefix, dir_sep, prefix, dir_sep, dir_sep)

   if LUAcov then
      -- Launch LUAcov.
      cmd = cmd..(' -e "require[[LUAcov.runner]](require[[spec.helper]].LUAcov_config([[%s]]))"'):format(prefix)
   end

   return ("%s %sbin%sLUAcheck.LUA"):format(cmd, prefix, dir_sep)
end

return helper
