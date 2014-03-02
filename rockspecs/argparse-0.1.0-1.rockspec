package = "argparse"
version = "0.1.0-1"
source = {
   url = "git://github.com/mpeterv/argparse.git",
   tag = "0.1.0"
}
description = {
   summary = "A feature-rich command-line argument parser",
   detailed = "argparse supports positional arguments, options, flags, optional arguments, subcommands and more. argparse automatically generates usage, help and error messages. ",
   homepage = "https://github.com/mpeterv/argparse",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.3",
   "30log >= 0.8"
}
build = {
   type = "builtin",
   modules = {
      argparse = "src/argparse.lua"
   },
   copy_directories = {"doc", "spec"}
}
