package = "largparse"
version = "lrcompat-1"
source = {
   url = "src"
}
description = {
   summary = "*** please specify description summary ***",
   detailed = "*** please enter a detailed description ***",
   homepage = "*** please enter a project homepage ***",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.1, < 5.3"
}
build = {
   type = "builtin",
   modules = {
      largparse = "src/largparse.lua",
      ["largparse.state"] = "src/state.lua",
      ["largparse.utils"] = "src/utils.lua"
   }
}
