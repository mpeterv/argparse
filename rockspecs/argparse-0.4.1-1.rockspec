package = "argparse"
version = "0.4.1-1"
source = {
   url = "git://github.com/mpeterv/argparse",
   tag = "0.4.1"
}
description = {
   summary = "A feature-rich command-line argument parser",
   detailed = "Argparse supports positional arguments, options, flags, optional arguments, subcommands and more. Argparse automatically generates usage, help and error messages.",
   homepage = "https://github.com/mpeterv/argparse",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}
build = {
   type = "builtin",
   modules = {
      argparse = "src/argparse.lua"
   },
   copy_directories = {"doc", "spec"}
}
