local class = require "30log"

local State = class()

function State:__init(parser)
   self.context = {}
   self._all_elements = {}
   self._all_groups = {}
   self:_switch(parser)

   self._result = {}
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
            self:_error("option %s can only be used %d times", element.name, element.maxcount)
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
         if element.type == "option" then
            self:_assert(#passed <= element.maxargs, "%s takes at most %d arguments", element.name, element.maxargs)
            self:_assert(#passed >= element.minargs, "%s takes at least %d arguments", element.name, element.minargs)
         else
            self:_assert(#passed <= element.maxargs, "too many arguments")
            self:_assert(#passed >= element.minargs, "too few arguments")
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

return State
