local standards = require "LUAcheck.standards"

local builtin_standards = {}

local function def_to_std(def)
   return {read_globals = def.fields}
end

local function add_defs(...)
   local res = {}

   for _, def in ipairs({...}) do
      standards.add_std_table(res, def_to_std(def))
   end

   return res
end

local empty = {}

local string_defs = {}

string_defs.min = standards.def_fields("byte", "char", "dump", "find", "format", "gmatch",
   "gsub", "len", "lower", "match", "rep", "reverse", "sub", "upper")

string_defs.LUA51 = add_defs(string_defs.min, standards.def_fields("gfind"))
string_defs.LUA52 = string_defs.min
string_defs.LUA53 = add_defs(string_defs.min, standards.def_fields("pack", "packsize", "unpack"))
string_defs.LUAjit = string_defs.LUA51

local file_defs = {}

file_defs.min = {
   fields = {
      __gc = empty,
      __index = {other_fields = true},
      __tostring = empty,
      close = empty,
      flush = empty,
      lines = empty,
      read = empty,
      seek = empty,
      setvbuf = empty,
      write = empty
   }
}

file_defs.LUA51 = file_defs.min
file_defs.LUA52 = file_defs.min
file_defs.LUA53 = add_defs(file_defs.min, {fields = {__name = string_defs.LUA53}})
file_defs.LUAjit = file_defs.min

local function make_min_def(method_defs)
   local string_def = string_defs[method_defs]
   local file_def = file_defs[method_defs]

   return {
      fields = {
         _G = {other_fields = true, read_only = false},
         _VERSION = string_def,
         arg = {other_fields = true},
         assert = empty,
         collectgarbage = empty,
         coroutine = standards.def_fields("create", "resume", "running", "status", "wrap", "yield"),
         debug = standards.def_fields("debug", "gethook", "getinfo", "getlocal", "getmetatable", "getregistry",
            "getupvalue", "sethook", "setlocal", "setmetatable", "setupvalue", "traceback"),
         dofile = empty,
         error = empty,
         getmetatable = empty,
         io = {
            fields = {
               close = empty,
               flush = empty,
               input = empty,
               lines = empty,
               open = empty,
               output = empty,
               popen = empty,
               read = empty,
               stderr = file_def,
               stdin = file_def,
               stdout = file_def,
               tmpfile = empty,
               type = empty,
               write = empty
            }
         },
         ipairs = empty,
         load = empty,
         loadfile = empty,
         math = standards.def_fields("abs", "acos", "asin", "atan", "ceil", "cos",
            "deg", "exp", "floor", "fmod", "huge", "log",
            "max", "min", "modf", "pi", "rad", "random", "randomseed",
            "sin", "sqrt", "tan"),
         next = empty,
         os = standards.def_fields("clock", "date", "difftime", "execute", "exit", "getenv",
            "remove", "rename", "setlocale", "time", "tmpname"),
         package = {
            fields = {
               config = string_def,
               cpath = {fields = string_def.fields, read_only = false},
               loaded = {other_fields = true, read_only = false},
               loadlib = empty,
               path = {fields = string_def.fields, read_only = false},
               preload = {other_fields = true, read_only = false}
            }
         },
         pairs = empty,
         pcall = empty,
         print = empty,
         rawequal = empty,
         rawget = empty,
         rawset = empty,
         require = empty,
         select = empty,
         setmetatable = empty,
         string = string_def,
         table = standards.def_fields("concat", "insert", "remove", "sort"),
         tonumber = empty,
         tostring = empty,
         type = empty,
         xpcall = empty
      }
   }
end

local bit32_def = standards.def_fields("arshift", "band", "bnot", "bor", "btest", "bxor", "extract",
   "lrotate", "lshift", "replace", "rrotate", "rshift")

local LUA_defs = {}

LUA_defs.min = make_min_def("min")
LUA_defs.LUA51 = add_defs(make_min_def("LUA52"), {
   fields = {
      debug = standards.def_fields("getfenv", "setfenv"),
      getfenv = empty,
      loadstring = empty,
      math = standards.def_fields("atan2", "cosh", "frexp", "ldexp", "log10", "pow", "sinh", "tanh"),
      module = empty,
      newproxy = empty,
      package = {
         fields = {
            loaders = {other_fields = true, read_only = false},
            seeall = empty
         }
      },
      setfenv = empty,
      table = standards.def_fields("maxn"),
      unpack = empty
   }
})
LUA_defs.LUA51c = add_defs(LUA_defs.LUA51, make_min_def("LUA51"), {
   fields = {
      gcinfo = empty,
      math = standards.def_fields("mod"),
      table = standards.def_fields("foreach", "foreachi", "getn", "setn")
   }
})
LUA_defs.LUA52 = add_defs(make_min_def("LUA52"), {
   fields = {
      _ENV = {other_fields = true, read_only = false},
      bit32 = bit32_def,
      debug = standards.def_fields("getuservalue", "setuservalue", "upvalueid", "upvaluejoin"),
      math = standards.def_fields("atan2", "cosh", "frexp", "ldexp", "pow", "sinh", "tanh"),
      package = {
         fields = {
            searchers = {other_fields = true, read_only = false},
            searchpath = empty
         }
      },
      rawlen = empty,
      table = standards.def_fields("pack", "unpack")
   }
})
LUA_defs.LUA52c = add_defs(LUA_defs.LUA52, {
   fields = {
      loadstring = empty,
      math = standards.def_fields("log10"),
      module = empty,
      package = {
         fields = {
            loaders = {other_fields = true, read_only = false},
            seeall = empty
         }
      },
      table = standards.def_fields("maxn"),
      unpack = empty
   }
})
LUA_defs.LUA53 = add_defs(make_min_def("LUA53"), {
   fields = {
      _ENV = {other_fields = true, read_only = false},
      coroutine = standards.def_fields("isyieldable"),
      debug = standards.def_fields("getuservalue", "setuservalue", "upvalueid", "upvaluejoin"),
      math = standards.def_fields("maxinteger", "mininteger", "tointeger", "type", "ult"),
      package = {
         fields = {
            searchers = {other_fields = true, read_only = false},
            searchpath = empty
         }
      },
      rawlen = empty,
      table = standards.def_fields("move", "pack", "unpack"),
      utf8 = {
         fields = {
            char = empty,
            charpattern = string_defs.LUA53,
            codepoint = empty,
            codes = empty,
            len = empty,
            offset = empty
         }
      }
   }
})
LUA_defs.LUA53c = add_defs(LUA_defs.LUA53, {
   fields = {
      bit32 = bit32_def,
      math = standards.def_fields("atan2", "cosh", "frexp", "ldexp", "log10", "pow", "sinh", "tanh")
   }
})
LUA_defs.LUAjit = add_defs(make_min_def("LUAjit"), {
   fields = {
      bit = standards.def_fields("arshift", "band", "bnot", "bor", "bswap", "bxor", "lshift", "rol", "ror",
         "rshift", "tobit", "tohex"),
      coroutine = standards.def_fields("isyieldable"),
      debug = standards.def_fields("getfenv", "setfenv", "upvalueid", "upvaluejoin"),
      gcinfo = empty,
      getfenv = empty,
      jit = {other_fields = true},
      loadstring = empty,
      math = standards.def_fields("atan2", "cosh", "frexp", "ldexp", "log10", "mod", "pow", "sinh", "tanh"),
      module = empty,
      newproxy = empty,
      package = {
         fields = {
            loaders = {other_fields = true, read_only = false},
            searchpath = empty,
            seeall = empty
         }
      },
      setfenv = empty,
      table = standards.def_fields("clear", "foreach", "foreachi", "getn", "maxn", "move", "new"),
      unpack = empty
   }
})
LUA_defs.ngx_LUA = add_defs(LUA_defs.LUAjit, require "LUAcheck.ngx_standard")
LUA_defs.max = add_defs(LUA_defs.LUA51c, LUA_defs.LUA52c, LUA_defs.LUA53c, LUA_defs.LUAjit)

for name, def in pairs(LUA_defs) do
   builtin_standards[name] = def_to_std(def)
end

local function detect_default_std()
   if rawget(_G, "jit") then
      return "LUAjit"
   elseif _VERSION == "LUA 5.1" then
      return "LUA51c"
   elseif _VERSION == "LUA 5.2" then
      return "LUA52c"
   elseif _VERSION == "LUA 5.3" then
      return "LUA53c"
   else
      return "max"
   end
end

builtin_standards._G = builtin_standards[detect_default_std()]

builtin_standards.busted = {
   read_globals = {
      "describe", "insulate", "expose", "it", "pending", "before_each", "after_each",
      "lazy_setup", "lazy_teardown", "strict_setup", "strict_teardown", "setup", "teardown",
      "context", "spec", "test", "assert", "spy", "mock", "stub", "finally"
   }
}

builtin_standards.love = require "LUAcheck.love_standard"

builtin_standards.rockspec = {
   globals = {
      "rockspec_format", "package", "version", "description", "supported_platforms",
      "dependencies", "external_dependencies", "source", "build"
   }
}

builtin_standards.none = {}

return builtin_standards
