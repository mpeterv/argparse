local argparse = {}

local class = require "30log"

local Declarative = {}

function Declarative:__init(...)
   self(...)
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
   __name = "Parser",
   arguments = {},
   options = {},
   commands = {},
   require_command = false,
   fields = {"name", "description", "target", "require_command"}
}:include(Declarative)

local Command = Parser:extends {
   __name = "Command",
   aliases = {}
}:include(Declarative)

local Argument = class {
   __name = "Argument",
   args = 1,
   count = 1,
   fields = {
      "name", "description", "target", "args",
      "minargs", "maxargs", "default", "convert"
   }
}:include(Declarative)

local Option = class {
   __name = "Option",
   aliases = {},
   args = 1,
   count = "?",
   overwrite = true,
   fields = {
      "name", "aliases", "description", "target", 
      "args", "minargs", "maxargs", "count",
      "mincount", "maxcount", "default", "convert",
      "overwrite"
   }
}:include(Declarative)

local Flag = Option:extends {
   __name = "Flag",
   args = 0
}:include(Declarative)

function Parser:argument(...)
   local argument = Argument:new(...)
   table.insert(self.arguments, argument)
   return argument
end

function Parser:option(...)
   local option = Option:new(...)
   table.insert(self.options, option)
   return option
end

function Parser:flag(...)
   local flag = Flag:new(...)
   table.insert(self.options, flag)
   return flag
end

function Parser:command(...)
   local command = Command:new(...)
   table.insert(self.commands, command)
   return command
end

function Parser:error(fmt, ...)
   local msg = fmt:format(...)

   if _TEST then
      error(msg)
   else
      io.stderr:write("Error: " .. msg .. "\r\n")
      os.exit(1)
   end
end

function Parser:assert(assertion, ...)
   return assertion or self:error(...)
end

function Parser:make_charset()
   if not self.charset then
      self.charset = {["-"] = true}

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

local function parse_boundaries(boundaries)
   if tonumber(boundaries) then
      return tonumber(boundaries), tonumber(boundaries)
   end

   if boundaries == "*" then
      return 0, math.huge
   end

   if boundaries == "+" then
      return 1, math.huge
   end

   if boundaries == "?" then
      return 0, 1
   end

   if boundaries:match "^%d+%-%d+$" then
      local min, max = boundaries:match "^(%d+)%-(%d+)$"
      return tonumber(min), tonumber(max)
   end

   if boundaries:match "^%d+%+$" then
      local min = boundaries:match "^(%d+)%+$"
      return tonumber(min), math.huge
   end
end

function Parser:make_boundaries()
   for _, elements in ipairs{self.arguments, self.options} do
      for _, element in ipairs(elements) do
         if not element.minargs or not element.maxargs then
            element.minargs, element.maxargs = parse_boundaries(element.args)
         end

         if not element.mincount or not element.maxcount then
            element.mincount, element.maxcount = parse_boundaries(element.count)
         end
      end
   end
end

function Parser:make_command_names()
   for _, command in ipairs(self.commands) do
      command.name = self.name .. " " .. command.name
   end
end

function Parser:prepare()
   self:make_charset()
   self:make_targets()
   self:make_boundaries()
   self:make_command_names()
   return self
end

function Parser:parse(args)
   args = args or arg
   self.name = self.name or args[0]

   local parser
   local charset
   local options = {}
   local arguments = {}
   local commands
   local opt_context = {}
   local com_context
   local result = {}
   local cur_option
   local cur_arg_i = 1
   local cur_arg

   local function close(element)
      local invocations = result[element.target]
      local passed = invocations[#invocations]

      if #passed < element.minargs then
         if element.default then
            while #passed < element.minargs do
               table.insert(passed, element.default)
            end
         else
            parser:error("too few arguments")
         end
      end

      if element == cur_option then
         cur_option = nil
      elseif element == cur_arg then
         cur_arg_i = cur_arg_i+1
         cur_arg = arguments[cur_arg_i]
      end
   end

   local function invoke(element)
      local invocations = result[element.target]

      if #invocations == element.maxcount then
         if element.overwrite then
            table.remove(invocations, 1)
         else
            parser:error("option %s must be used at most %d times", element.name, element.maxcount)
         end
      end

      table.insert(result[element.target], {})

      if element.maxargs == 0 then
         close(element)
      end
   end

   local function pass(element, data)
      local invocations = result[element.target]
      local passed = invocations[#invocations]
      table.insert(passed, data)

      if #passed == element.maxargs then
         close(element)
      end
   end

   local function switch(p)
      parser = p:prepare()
      charset = p.charset

      for _, option in ipairs(p.options) do
         table.insert(options, option)

         for _, alias in ipairs(option.aliases) do
            opt_context[alias] = option
         end

         result[option.target] = {}
      end

      for _, argument in ipairs(p.arguments) do
         table.insert(arguments, argument)
         result[argument.target] = {}
         invoke(argument)
      end

      cur_arg = arguments[cur_arg_i]
      commands = p.commands
      com_context = {}

      for _, command in ipairs(p.commands) do
         for _, alias in ipairs(command.aliases) do
            com_context[alias] = command
         end
      end
   end

   local function handle_argument(data)
      if cur_option then
         pass(cur_option, data)
      elseif cur_arg then
         pass(cur_arg, data)
      else
         local com = com_context[data]

         if not com then
            if #commands > 0 then
               parser:error("unknown command %s", data) -- add lev-based guessing here
            else
               parser:error("too many arguments")
            end
         else
            result[com.target] = true
            switch(com)
         end
      end
   end

   local function handle_option(data)
      if cur_option then
         close(cur_option)
      end

      cur_option = opt_context[data]
      invoke(cur_option)
   end

   local function mainloop()
      local handle_options = true

      for _, data in ipairs(args) do
         local plain = true
         local first, name, option

         if handle_options then
            first = data:sub(1, 1)
            if charset[first] then
               if #data > 1 then
                  if data:sub(2, 2):match "[a-zA-Z]" then
                     plain = false

                     for i = 2, #data do
                        name = first .. data:sub(i, i)
                        option = parser:assert(opt_context[name], "unknown option %s", name)
                        handle_option(name)

                        if i ~= #data and option.minargs > 0 then
                           handle_argument(data:sub(i+1))
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
                           option = parser:assert(opt_context[name], "unknown option %s", name)
                           parser:assert(option.maxargs > 0, "option %s doesn't take arguments", name)

                           handle_option(data:sub(1, equal-1))
                           handle_argument(data:sub(equal+1))
                        else
                           parser:assert(opt_context[data], "unknown option %s", data)
                           handle_option(data)
                        end
                     end
                  end
               end
            end
         end

         if plain then
            handle_argument(data)
         end
      end
   end

   local function convert(element, data)
      if element.convert then
         local ok, err = element.convert(data)

         return parser:assert(ok, "%s", err or "malformed argument " .. data)
      else
         return data
      end
   end

   local function format()
      local invocations

      for _, elements in ipairs{options, arguments} do
         for _, element in ipairs(elements) do
            invocations = result[element.target]

            parser:assert(#invocations >= element.mincount,
               "option %s must be used at least %d times", element.name, element.mincount)

            if element.maxcount == 1 then
               if element.maxargs == 0 then
                  if #invocations > 0 then
                     result[element.target] = true
                  else
                     result[element.target] = nil
                  end
               elseif element.maxargs == 1 and element.minargs == 1 then
                  if #invocations > 0 then
                     result[element.target] = convert(element, invocations[1][1])
                  else
                     result[element.target] = nil
                  end
               else
                  result[element.target] = invocations[1]

                  if #invocations > 0 and element.convert then
                     for i=1, #result[element.target] do
                        result[element.target][i] = convert(element, result[element.target][i])
                     end
                  end
               end
            else
               if element.maxargs == 0 then
                  result[element.target] = #invocations
               elseif element.maxargs == 1 and element.minargs == 1 then
                  for i=1, #invocations do
                     invocations[i] = convert(element, invocations[i][1])
                  end
               elseif element.convert then
                  for _, invocation in ipairs(invocations) do
                     for i=1, #invocation do
                        invocation[i] = convert(element, invocation[i])
                     end
                  end
               end
            end
         end
      end
   end

   switch(self)
   mainloop()

   if cur_option then
      close(cur_option)
   end

   while cur_arg do
      close(cur_arg)
   end

   if parser.require_command and #commands > 0 then
      parser:error("command is required")
   end

   format()

   return result
end

argparse.parser = Parser

return argparse
