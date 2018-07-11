package = "LUAcheck"
version = "dev-1"
source = {
   url = "git+https://github.com/mpeterv/LUAcheck.git"
}
description = {
   summary = "A static analyzer and a linter for LUA",
   detailed = [[
LUAcheck is a command-line tool for linting and static analysis of LUA code. It is able to spot usage of undefined global variables, unused local variables and a few other typical problems within LUA programs.
]],
   homepage = "https://github.com/mpeterv/LUAcheck",
   license = "MIT"
}
dependencies = {
   "LUA >= 5.1, < 5.4",
   "LUAfilesystem >= 1.6.3"
}
build = {
   type = "builtin",
   modules = {
      LUAcheck = "src/LUAcheck/init.LUA",
      ["LUAcheck.argparse"] = "src/LUAcheck/argparse.LUA",
      ["LUAcheck.builtin_standards"] = "src/LUAcheck/builtin_standards.LUA",
      ["LUAcheck.cache"] = "src/LUAcheck/cache.LUA",
      ["LUAcheck.check"] = "src/LUAcheck/check.LUA",
      ["LUAcheck.config"] = "src/LUAcheck/config.LUA",
      ["LUAcheck.core_utils"] = "src/LUAcheck/core_utils.LUA",
      ["LUAcheck.detect_bad_whitespace"] = "src/LUAcheck/detect_bad_whitespace.LUA",
      ["LUAcheck.detect_cyclomatic_complexity"] = "src/LUAcheck/detect_cyclomatic_complexity.LUA",
      ["LUAcheck.detect_globals"] = "src/LUAcheck/detect_globals.LUA",
      ["LUAcheck.detect_uninit_access"] = "src/LUAcheck/detect_uninit_access.LUA",
      ["LUAcheck.detect_unreachable_code"] = "src/LUAcheck/detect_unreachable_code.LUA",
      ["LUAcheck.detect_unused_locals"] = "src/LUAcheck/detect_unused_locals.LUA",
      ["LUAcheck.detect_unused_rec_funcs"] = "src/LUAcheck/detect_unused_rec_funcs.LUA",
      ["LUAcheck.expand_rockspec"] = "src/LUAcheck/expand_rockspec.LUA",
      ["LUAcheck.filter"] = "src/LUAcheck/filter.LUA",
      ["LUAcheck.format"] = "src/LUAcheck/format.LUA",
      ["LUAcheck.fs"] = "src/LUAcheck/fs.LUA",
      ["LUAcheck.globbing"] = "src/LUAcheck/globbing.LUA",
      ["LUAcheck.inline_options"] = "src/LUAcheck/inline_options.LUA",
      ["LUAcheck.lexer"] = "src/LUAcheck/lexer.LUA",
      ["LUAcheck.lfs_fs"] = "src/LUAcheck/lfs_fs.LUA",
      ["LUAcheck.linearize"] = "src/LUAcheck/linearize.LUA",
      ["LUAcheck.love_standard"] = "src/LUAcheck/love_standard.LUA",
      ["LUAcheck.LUA_fs"] = "src/LUAcheck/LUA_fs.LUA",
      ["LUAcheck.main"] = "src/LUAcheck/main.LUA",
      ["LUAcheck.name_functions"] = "src/LUAcheck/name_functions.LUA",
      ["LUAcheck.multithreading"] = "src/LUAcheck/multithreading.LUA",
      ["LUAcheck.ngx_standard"] = "src/LUAcheck/ngx_standard.LUA",
      ["LUAcheck.options"] = "src/LUAcheck/options.LUA",
      ["LUAcheck.parser"] = "src/LUAcheck/parser.LUA",
      ["LUAcheck.resolve_locals"] = "src/LUAcheck/resolve_locals.LUA",
      ["LUAcheck.runner"] = "src/LUAcheck/runner.LUA",
      ["LUAcheck.standards"] = "src/LUAcheck/standards.LUA",
      ["LUAcheck.utils"] = "src/LUAcheck/utils.LUA",
      ["LUAcheck.version"] = "src/LUAcheck/version.LUA"
   },
   install = {
      bin = {
         LUAcheck = "bin/LUAcheck.LUA"
      }
   }
}
