local argparse = {}

local class = require "30log"

local State = class {
   opt_context = {},
   result = {},
   stack = {},
   invocations = {},
   top_is_opt = false
}

function State:__init(parser)
   self:switch(parser)
end

function State:switch(parser)
   self.parser = parser:prepare()
   self.charset = parser.charset

   for _, option in ipairs(parser.options) do
      table.insert(self.options, option)

      for _, alias in ipairs(option.aliases) do
         self.opt_context[alias] = option
      end
   end

   self.arguments = parser.arguments
   self.commands = parser.commands
   self.com_context = {}

   for _, command in ipairs(parser.commands) do
      for _, alias in ipairs(command.aliases) do
         self.com_context[][alias] = command
      end
   end
end

function State:invoke(element)
   if not self.invocatons then
      

function State:push(option)
   if self.top_is_opt then
      self:pop()
   end

   self:invoke(option)

   if option.maxargs ~= 0 then
      table.insert(self.stack, option)
      self.top_is_opt = true
   end
end

function State:pop()
   if self.top_is_opt 

function State:iterargs(args)
   return coroutine.wrap(function()
      local handle_options = true

      for _, data in ipairs(args) do
         local plain = true
         local first, name, option

         if handle_options then
            first = data:sub(1, 1)
            if self.charset[first] then
               if #data > 1 then
                  if data:sub(2, 2):match "[a-zA-Z]" then
                     plain = false

                     for i = 2, #data do
                        name = first .. data:sub(i, i)
                        option = self:assert(self.opt_context[name], "unknown option " .. name)
                        coroutine.yield(nil, name)

                        if i ~= #data and not (options.minargs == 0 and self.opt_context[first .. data:sub(i+1, i+1)]) then
                           coroutine.yield(data:sub(i+1), nil)
                           break
                        end
                     end
                  elseif data:sub(2, 2) == first then
                     if #data == 2 then
                        plain = false
                        handle_options = false
                     elseif data:sub(3, 3):match "[a-zA-Z]" then
                        plain = false

                        local equal = data:find "="
                        if equal then
                           name = data:sub(1, equal-1)
                           option = self:assert(self.opt_context[name], "unknown option " .. name)
                           self:assert(option.maxargs > 0, "option " .. name .. " doesn't take arguments")

                           coroutine.yield(nil, data:sub(1, equal-1))
                           coroutine.yield(data:sub(equal+1), nil)
                        else
                           coroutine.yield(nil, data)
                        end
                     end
                  end
               end
            end
         end

         if plain then
            coroutine.yield(data, nil)
         end
      end
   end)
end

function State:parse(args)
   for arg, opt in self:iterargs(args) do
      if arg then

      elseif opt then


      end
   end
end



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
         if self.aliases then
            table.insert(self.aliases, name_or_options)
         end

         if not self.name then
            self.name = name_or_options
         end
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

local Parser = class {
   arguments = {},
   options = {},
   commands = {},
   fields = {"name", "description", "target"}
}:include(Declarative)

local Command = Parser:extends {
   aliases = {}
}:include(Declarative)

local Argument = class {
   args = 1,
   count = 1,
   fields = {"name", "description", "target", "args", "default", "convert"}
}:include(Declarative)

local Option = class {
   aliases = {},
   args = 1,
   count = "?",
   fields = {"name", "aliases", "description", "target", "args", "count", "default", "convert"}
}:include(Declarative)

local Flag = Option:extends {
   args = 0
}:include(Declarative)

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

function Parser:make_charset()
   if not self.charset then
      self.charset = {}

      for _, command in ipairs(self.commands) do
         command:make_charset()

         for char in pairs(command.charset) do
            self.charset[char] = true
         end
      end

      for _, option in ipairs(self.options) do
         for _, alias in ipairs(option.aliases) do
            self.charset[alias:sub(1, 1)] = true
         end
      end
   end
end

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

function self:make_command_names()
   for _, command in ipairs(self.commands) do
      command.name = self.name .. " " .. command.name
   end
end

function Parser:prepare()
   self:make_charset()
   self:make_targets()
   self:make_command_names()
   return self
end

function Parser:parse(args)
   args = args or arg
   self.name = self.name or args[0]
   return State(self):parse(args)
end

argparse.parser = Parser

return argparse
