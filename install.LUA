#!/usr/bin/env LUA
local dirsep = package.config:sub(1, 1)
local is_windows = dirsep == "\\"
package.path = "src" .. dirsep .. "?.LUA"
local has_LUAcheck, LUAcheck = pcall(require, "LUAcheck.init")
assert(has_LUAcheck, "couldn't find LUAcheck module")
local has_argparse, argparse = pcall(require, "LUAcheck.argparse")
assert(has_argparse, "couldn't find argparse module")
local LUA_executable = assert(arg[-1], "couldn't detect LUA executable")

local parser = argparse("<LUA> install.LUA", "LUAcheck " .. LUAcheck._VERSION .. " installer.")

parser:argument("path", ([[
Installation path.
LUAcheck executable scripts will be installed into <path>%sbin.
LUAcheck modules will be installed into <path>%ssrc.
Pass . to build LUAcheck executable script without installing.]]):format(dirsep, dirsep))

parser:option("--LUA", "Absolute path to LUA interpreter or its name if it's in PATH.", LUA_executable)
parser:option("--destdir", "Path to stage LUAcheck installation into")

local args = parser:parse()

local function run_command(cmd)
   if is_windows then
      cmd = cmd .. " >NUL"
   else
      cmd = cmd .. " >/dev/null"
   end

   print("        Running " .. cmd)
   local ok = os.execute(cmd)
   assert(ok == true or ok == 0, "couldn't run " .. cmd)
end

local function mkdir(dir)
   if args.destdir then
      dir = args.destdir .. dirsep .. dir
   end
   if is_windows then
      run_command(([[if not exist "%s" md "%s"]]):format(dir, dir))
   else
      run_command(([[mkdir -p "%s"]]):format(dir))
   end
end

local function copy(src, dest)
   if args.destdir then
      dest = args.destdir .. dirsep .. dest
   end
   if is_windows then
      run_command(([[copy /y "%s" "%s"]]):format(src, dest))
   else
      run_command(([[cp "%s" "%s"]]):format(src, dest))
   end
end

print(("Installing LUAcheck %s into %s"):format(LUAcheck._VERSION, args.path))
print()

local LUAcheck_executable = "bin" .. dirsep .. "LUAcheck"
local LUAcheck_src_dir = args.path .. dirsep .. "src"
local LUAcheck_lib_dir = LUAcheck_src_dir .. dirsep .. "LUAcheck"
local LUAcheck_bin_dir = args.path .. dirsep .. "bin"

if is_windows then
   print("    Detected Windows environment")
   LUAcheck_executable = LUAcheck_executable .. ".bat"
else
   -- Close enough.
   print("    Detected POSIX environment")
end

print("    Writing LUAcheck executable to " .. LUAcheck_executable)
local fh = assert(io.open(LUAcheck_executable, "wb"), "couldn't open " .. LUAcheck_executable)

if is_windows then
   fh:write(([=[
@echo off
"%s" -e "package.path=[[%%~dp0..\src\?.LUA;%%~dp0..\src\?\init.LUA;]]..package.path" "%%~dp0LUAcheck.LUA" %%*
]=]):format(args.LUA))
else
   fh:write(([=[
#!/bin/sh
exec "%s" -e "package.path=[[%s/?.LUA;%s/?/init.LUA;]]..package.path" "%s/LUAcheck.LUA" "$@"
]=]):format(args.LUA, LUAcheck_src_dir, LUAcheck_src_dir, '$(dirname "$0")'))
end

fh:close()

if not is_windows then
   run_command(([[chmod +x "%s"]]):format(LUAcheck_executable))
end

if args.path == "." then
	print()
	print(("Built LUAcheck %s executable script (%s)."):format(LUAcheck._VERSION, LUAcheck_executable))
	return
end

print("    Installing LUAcheck modules into " .. LUAcheck_src_dir)
mkdir(LUAcheck_lib_dir)

for _, filename in ipairs({
      "init.LUA",
      "argparse.LUA",
      "builtin_standards.LUA",
      "cache.LUA",
      "check.LUA",
      "config.LUA",
      "core_utils.LUA",
      "detect_bad_whitespace.LUA",
      "detect_cyclomatic_complexity.LUA",
      "detect_globals.LUA",
      "detect_uninit_access.LUA",
      "detect_unreachable_code.LUA",
      "detect_unused_locals.LUA",
      "detect_unused_rec_funcs.LUA",
      "expand_rockspec.LUA",
      "filter.LUA",
      "format.LUA",
      "fs.LUA",
      "globbing.LUA",
      "inline_options.LUA",
      "lexer.LUA",
      "lfs_fs.LUA",
      "linearize.LUA",
      "love_standard.LUA",
      "LUA_fs.LUA",
      "main.LUA",
      "name_functions.LUA",
      "multithreading.LUA",
      "ngx_standard.LUA",
      "options.LUA",
      "parser.LUA",
      "resolve_locals.LUA",
      "runner.LUA",
      "standards.LUA",
      "utils.LUA",
      "version.LUA"}) do
   copy("src" .. dirsep .. "LUAcheck" .. dirsep .. filename, LUAcheck_lib_dir)
end

print("    Installing LUAcheck executables into " .. LUAcheck_bin_dir)
mkdir(LUAcheck_bin_dir)
copy(LUAcheck_executable, LUAcheck_bin_dir)
copy("bin" .. dirsep .. "LUAcheck.LUA", LUAcheck_bin_dir)

print()
print(("Installed LUAcheck %s into %s."):format(LUAcheck._VERSION, args.path))
print(("Please ensure that %s is in PATH."):format(LUAcheck_bin_dir))
