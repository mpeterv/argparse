local argparse = {}

local class = require "30log"

local State = class {
   context = {}, -- {alias -> element}
   result = {}
}

function State:__init(parser)
   self:switch(parser)
end

function State:switch(parser)
   self.parser = parser
   self.parser:make_targets()

   for _, option in ipairs(parser.options) do
      table.insert(self.options, option)
   end

   self.arguments = parser.arguments
   self.commands = parser.commands
end

function Parser:make_target(element)
   if not element.target then
      for _, alias in ipairs(element.aliases) do
         if alias:match "^%-%-" then
            element.target = alias:sub(3)
            return
         end
      end

      element.target = element.aliases[1]:match "^%-*(.*)"
   end
end



function State:parse(args)
   args = args or arg



function State:handle_option(name)
   local option = self:_assert(self.context[name], "unknown option %s", name)

   self:_open(option)
end

function State:handle_argument(data)
   if self._current then
      if self:_can_pass(self._current) then
         self:_pass(self._current, data)
         return
      else
         self._current = nil
      end
   end

   local argument = self._arguments[self._next_arg_i]
   if argument then
      self:_open(argument)
      self:_pass(argument, data)
   else
      local command = self.context[data]
      if command and command.type == "command" then
         self._result[command.target] = {{}}
         self:_switch(command)
      else
         if #self._commands > 0 then
            self:_error("unknown command %s", data)
         else
            self:_error("too many arguments")
         end
      end
   end
end

function State:get_result()
   self:_check()

   local result = {}

   local invocations
   for _, element in ipairs(self._all_elements) do
      invocations = self._result[element.target]

      if element.maxcount == 1 then
         if element.maxargs == 0 then
            if #invocations > 0 then
               result[element.target] = true
            end
         elseif element.maxargs == 1 and element.minargs == 1 then
            if #invocations > 0 then
               result[element.target] = invocations[1][1]
            end
         else
            result[element.target] = invocations[1]
         end
      else
         if element.maxargs == 0 then
            result[element.target] = #invocations
         elseif element.maxargs == 1 and element.minargs == 1 then
            local new_result = {}
            for i, passed in ipairs(invocations) do
               new_result[i] = passed[1]
            end
            result[element.target] = new_result
         else
            result[element.target] = invocations
         end
      end
   end

   return result
end

function State:_check()
   self:_assert(not self._parser.must_command, "a command is required")

   local invocations
   for _, element in ipairs(self._all_elements) do
      invocations = self._result[element.target] or {}

      if element.type == "argument" and #invocations == 0 then
         invocations[1] = {}
      end

      if #invocations > element.maxcount then
         if element.no_overwrite then
            self:_error("option %s must be used at most %d times", element.name, element.maxcount)
         else
            local new_invocations = {}
            for i = 1, element.maxcount do
               new_invocations[i] = invocations[#invocations-element.maxcount+i]
            end
            invocations = new_invocations
         end
      end

      self:_assert(#invocations >= element.mincount, "option %s must be used at least %d times", element.name, element.mincount)

      for _, passed in ipairs(invocations) do
         self:_assert(#passed <= element.maxargs, "too many arguments")
         if #passed < element.minargs then
            if element.default then
               for i = 1, element.minargs-#passed do
                  table.insert(passed, element.default)
               end 
            else
               self:_error("too few arguments")
            end
         end
      end

      self._result[element.target] = invocations
   end

   for _, group in ipairs(self._all_groups) do
      local invoked
      for _, element in ipairs(group.elements) do
         if #self._result[element.target] > 0 then
            if invoked then
               self:_error("%s can not be used together with %s", invoked.name, element.name)
            else
               invoked = element
            end
         end
      end

      if group.required then
         self:_assert(invoked, "WIP(required mutually exclusive group)")
      end
   end
end

function State:_open(element)
   if not self._result[element.target] then
      self._result[element.target] = {}
   end

   table.insert(self._result[element.target], {})

   if element.type == "argument" then
      self._next_arg_i = self._next_arg_i+1
   end

   self._current = element
end

function State:_can_pass(element)
   local invocations = self._result[element.target]
   local passed = invocations[#invocations]

   return #passed < element.maxargs
end

function State:_pass(element, data)
   local invocations = self._result[element.target]
   local passed = invocations[#invocations]

   table.insert(passed, data)
end

function State:_switch(command)
   self._parser = command
   self._arguments = command.arguments
   self._commands = command.commands

   for _, element in ipairs(command.elements) do
      table.insert(self._all_elements, element)
   end

   for _, group in ipairs(command.groups) do
      table.insert(self._all_groups, group)
   end

   self.context = setmetatable(command.context, {__index = self.context})
   self._next_arg_i = 1
end

function State:_error(...)
   return self._parser:error(...)
end

function State:_assert(...)
   return self._parser:assert(...)
end


local utils = require "argparse.utils"

local Declarative = {}

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
   charset = {"-"},
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

function Parser:error(fmt, ...)
   local msg = fmt:format(...)
   io.stderr:write("Error: " .. msg .. "\n")
   os.exit(1)
end

function Parser:assert(assertion, ...)
   return assertion or self:error(...)
end

function Parser:get_charset()
   for _, command in ipairs(self.commands) do
      for char in command:get_charset() do
         self.charset[char] = true
      end
   end

   for _, option in ipairs(self.options) do
      for _, alias in ipairs(option.aliases) do
         self.charset[alias:sub(1, 1)] = true
      end
   end

   return self.charset
end

-- to be called from State
function Parser:make_targets()
   for _, option in ipairs(self.options) do
      if not option.target then
         for _, alias in ipairs(option.aliases) do
            if alias:sub(1, 1) == alias:sub(2, 2) then
               option.target = alias:sub(3)
               break
            end
         end
      end

      option.target = option.target or option.aliases[1]:sub(2)
   end

   for _, argument in ipairs(self.arguments) do
      argument.target = argument.target or argument.name
   end

   for _, command in ipairs(self.commands) do
      command.target = command.target or command.name
   end
end

function Parser:parse(args)
   self:get_charset()
   return State(self):parse(args)
end


function Parser:parse(args)
   args = args or arg
   self.name = self.name or args[0]

   local state = State(self)

   local handle_options = true
   for _, data in ipairs(args) do
      local plain = true

      if handle_options then
         if data:sub(1, 1) == "-" then
            if #data > 1 then
               if data:sub(2, 2):match "[a-zA-Z]" then
                  plain = false

                  local name, element
                  for i = 2, #data do
                     name = "-" .. data:sub(i, i)
                     element = self:assert(state.context[name], "unknown option " .. name)
                     state:handle_option(name)

                     if i ~= #data and not (element.minargs == 0 and state.context["-" .. data:sub(i+1, i+1)]) then
                        state:handle_argument(data:sub(i+1))
                        break
                     end
                  end
               elseif data:sub(2, 2) == "-" then
                  if #data == 2 then
                     plain = false
                     handle_options = false
                  elseif data:sub(3, 3):match "[a-zA-Z]" then
                     plain = false

                     local equal = data:find "="
                     if equal then
                        local name = data:sub(1, equal-1)
                        local element = self:assert(state.context[name], "unknown option " .. name)
                        self:assert(element.maxargs > 0, "option " .. name .. " doesn't take arguments")

                        state:handle_option(data:sub(1, equal-1))
                        state:handle_argument(data:sub(equal+1))
                     else
                        state:handle_option(data)
                     end
                  end
               end
            end
         end
      end

      if plain then
         state:handle_argument(data)
      end
   end

   local result = state:get_result()

   return result
end

argparse.parser = Parser

return argparse
