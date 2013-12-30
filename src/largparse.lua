local largparse = {}

local class = require "30log"

local State = require "largparse.state"

local Parser = class()

function Parser:__init(options)
   options = options or {}
   self.description = options.description
   self.name = options.name
   self.no_help = options.no_help
   self.must_command = options.must_command

   self.arguments = {}
   self.elements = {}
   self.groups = {}
   self.commands = {}
   self.context = {}
end

function Parser:add_alias(element, alias)
   table.insert(element.aliases, alias)
   self.context[alias] = element
end

function Parser:apply_options(element, options)
   for k, v in pairs(options) do
      element[k] = v -- fixme
   end
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

function Parser:parse_boundaries(boundaries)
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

-- TODO: make it declarative as it was
function Parser:argument(name, ...)
   local element = {
      name = name,
      aliases = {},
      count = 1,
      args = 1,
      type = "argument"
   }

   self:add_alias(element, name)

   local argument
   for i = 1, select('#', ...) do
      argument = select(i, ...)

      if type(argument) == "string" then
         self:add_alias(element, argument)
      else
         self:apply_options(element, argument)
      end
   end

   self:make_target(element)

   element.mincount, element.maxcount = self:parse_boundaries(element.count)
   element.minargs, element.maxargs = self:parse_boundaries(element.args)

   table.insert(self.arguments, element)
   table.insert(self.elements, element)

   return element
end

function Parser:option(name, ...)
   local element = {
      name = name,
      aliases = {},
      count = "0-1",
      args = 1,
      type = "option"
   }

   self:add_alias(element, name)

   local argument
   for i = 1, select('#', ...) do
      argument = select(i, ...)

      if type(argument) == "string" then
         self:add_alias(element, argument)
      else
         self:apply_options(element, argument)
      end
   end

   self:make_target(element)

   element.mincount, element.maxcount = self:parse_boundaries(element.count)
   element.minargs, element.maxargs = self:parse_boundaries(element.args)

   table.insert(self.elements, element)

   return element
end

-- DRY?

function Parser:flag(name, ...)
   local element = {
      name = name,
      aliases = {},
      count = "0-1",
      args = 0,
      type = "option"
   }

   self:add_alias(element, name)

   local argument
   for i = 1, select('#', ...) do
      argument = select(i, ...)

      if type(argument) == "string" then
         self:add_alias(element, argument)
      else
         self:apply_options(element, argument)
      end
   end

   self:make_target(element)

   element.mincount, element.maxcount = self:parse_boundaries(element.count)
   element.minargs, element.maxargs = self:parse_boundaries(element.args)

   table.insert(self.elements, element)

   return element
end

function Parser:command(name, ...)
   local element = {
      name = name,
      aliases = {},
      count = "0-1",
      args = 0,
      type = "command"
   }

   local command = Parser() -- fixme
   for k, v in pairs(element) do
      command[k] = v
   end

   self:add_alias(command, name)

   local argument
   for i = 1, select('#', ...) do
      argument = select(i, ...)
      self:add_alias(command, argument)
   end

   self:make_target(command)

   command.mincount, command.maxcount = self:parse_boundaries(command.count)
   command.minargs, command.maxargs = self:parse_boundaries(command.args)

   table.insert(self.elements, command)

   return command
end

function Parser:group(...)
   --
end

function Parser:mutually_exclusive(...)
   local group = {
      elements = {...}
   }

   table.insert(self.groups, group)
   return group
end

function Parser:error(fmt, ...)
   local msg = fmt:format(...)
   io.stderr:write("Error: " .. msg .. "\n")
   os.exit(1)
end

function Parser:assert(assertion, ...)
   return assertion or self:error(...)
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

                     if i ~= #data and not (element:can_take(0) and data:sub(i+1, i+1):match "[a-zA-Z]") then
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

largparse.parser = Parser

return largparse
