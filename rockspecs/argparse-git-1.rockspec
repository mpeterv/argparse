package = "argparse"
version = "git-1"
source = {
   url = "git://github.com/mpeterv/argparse.git"
}
description = {
   summary = "A feature-rich command-line argument parser",
   detailed = "argparse allows you to define positional arguments, options, flags and default values. Provides automatically generated usage, error and help messages. Supports subcommands and generates a hint when a command or an option is mistyped. ",
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
   }
}
