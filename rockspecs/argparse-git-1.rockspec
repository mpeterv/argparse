package = "argparse"
version = "git-1"
source = {
   url = "git://github.com/mpeterv/literal.git"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.3",
   "30log >= 0.6"
}
build = {
   type = "builtin",
   modules = {
      argparse = "src/argparse.lua"
   }
}
