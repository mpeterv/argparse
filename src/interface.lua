-- new, awesome declarative interface implementation

local class = require "30log"

local Declarative = class()

function Declarative:__init(...)
   return self(...)
end

function Declarative:__call(...)
   local name_or_options

   for i=1, select("#", ...) do
      name_or_options = select(i, ...)

      if type(name_or_options) == "string" then
         self:set_name(name_or_options)
      elseif type(name_or_options) == "table" then
         for _, field in ipairs(self.fields) do
            if name_or_options[field] ~= nil then
               self[field] = name_or_options[field]
            end
         end
      end
   end

   return self
end

local Aliased = {}

function Aliased:set_name(name)
   table.insert(self.aliases, name)

   if not self.name then
      self.name = name
   end
end

local Named = {}

function Named:set_name(name)
   self.name = name
end

local Parser = class {
   arguments = {},
   options = {},
   commands = {},
   groups = {},
   mutex_groups = {},
   fields = {"name", "description", "target"}
}:include(Declarative):include(Named)

local Command = Parser:extends {
   aliases = {}
}:include(Declarative):include(Aliased)

local Argument = class {
   args = 1,
   count = 1,
   fields = {"name", "description", "target", "args", "default", "convert"}
}:include(Declarative):include(Named)

local Option = class {
   aliases = {},
   args = 1,
   count = "?",
   fields = {"name", "aliases", "description", "target", "args", "count", "default", "convert"}
}:include(Declarative):include(Aliased)

local Flag = Option:extends {
   args = 0
}:include(Declarative):include(Aliased)

function Parser:argument(...)
   local argument = Argument(...)
   table.insert(self.arguments, argument)
   return argument
end

function Parser:option(...)
   local option = Option(...)
   table.insert(self.options, option)
   return option
end

function Parser:flag(...)
   local flag = Flag(...)
   table.insert(self.options, flag)
   return flag
end

function Parser:command(...)
   local command = Command(...)
   table.insert(self.commands, command)
   return command
end

return Parser
