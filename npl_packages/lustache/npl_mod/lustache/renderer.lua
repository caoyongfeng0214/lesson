local Scanner  = require "./scanner"
local Context  = require "./context"
local templateHelper = require('./templatehelper');

local error, ipairs, loadstring, pairs, setmetatable, tostring, type = 
      error, ipairs, loadstring, pairs, setmetatable, tostring, type 
local math_floor, math_max, string_find, string_gsub, string_split, string_sub, table_concat, table_insert, table_remove =
      math.floor, math.max, string.find, string.gsub, string.split, string.sub, table.concat, table.insert, table.remove

local patterns = {
  white = "%s*",
  space = "%s+",
  nonSpace = "%S",
  eq = "%s*=",
  curly = "%s*}",
  tag = "[#\\^/><?+{&=!]"
}

local html_escape_characters = {
  ["&"] = "&amp;",
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ['"'] = "&quot;",
  ["'"] = "&#39;",
  ["/"] = "&#x2F;"
}

local function is_array(array)
  if type(array) ~= "table" then return false end
  local max, n = 0, 0
  for k, _ in pairs(array) do
    if not (type(k) == "number" and k > 0 and math_floor(k) == k) then
      return false 
    end
    max = math_max(max, k)
    n = n + 1
  end
  return n == max
end

-- Low-level function that compiles the given `tokens` into a
-- function that accepts two arguments: a Context and a
-- Renderer.

local function compile_tokens(tokens, originalTemplate)
  local subs = {}

  local function subrender(i, tokens)
    if not subs[i] then
      local fn = compile_tokens(tokens, originalTemplate)
      subs[i] = function(ctx, rnd) return fn(ctx, rnd) end
    end
    return subs[i]
  end

  local function render(ctx, rnd)
    local buf = {}
    local token, section
    for i, token in ipairs(tokens) do
      local t = token.type
      buf[#buf+1] = 
        t == "#" and rnd:_section(
          token, ctx, subrender(i, token.tokens), originalTemplate
        ) or
        t == "^" and rnd:_inverted(
          token.value, ctx, subrender(i, token.tokens)
        ) or
        t == ">" and rnd:_partial(token.value, ctx, originalTemplate) or
        (t == "{" or t == "&") and rnd:_name(token.value, ctx, false) or
        t == "name" and rnd:_name(token.value, ctx, true) or
        t == "text" and token.value or ""
    end
    return table_concat(buf)
  end
  return render
end

local function escape_tags(tags)

  return {
    string_gsub(tags[1], "%%", "%%%%").."%s*",
    "%s*"..string_gsub(tags[2], "%%", "%%%%"),
  }
end

local function nest_tokens(tokens)
  local tree = {}
  local collector = tree 
  local sections = {}
  local token, section
  local father = nil;
  local places = nil;
  local placeins = nil;

  for i,token in ipairs(tokens) do
	token.__idx = i;
    if token.type == "#" or token.type == "^" or token.type == "+" then
      token.tokens = {}
      sections[#sections+1] = token
      collector[#collector+1] = token
      collector = token.tokens
	  if(token.type == '+') then
		if(not placeins) then
			placeins = {};
		end
		placeins[token.value] = token;
	  end
    elseif token.type == "/" then
      if #sections == 0 then
        error("Unopened section: "..token.value)
      end

      -- Make sure there are no open sections when we're done
      section = table_remove(sections, #sections)

      if not section.value == token.value then
        error("Unclosed section: "..section.value)
      end

      section.closingTagIndex = token.startIndex

      if #sections > 0 then
        collector = sections[#sections].tokens
      else
        collector = tree
      end
    else
      collector[#collector+1] = token;
	  if(token.type == '<') then
		father = token;
	  elseif(token.type == '?') then
		if(not places) then
			places = {};
		end
		places[token.value] = token;
	  end
    end
  end

  section = table_remove(sections, #sections)

  if section then
    error("Unclosed section: "..section.value)
  end

  return tree, {father = father, places = places, placeins = placeins};
end

-- Combines the values of consecutive text tokens in the given `tokens` array
-- to a single token.
local function squash_tokens(tokens)
  local out, txt = {}, {}
  local txtStartIndex, txtEndIndex
  for _, v in ipairs(tokens) do
    if v.type == "text" then
      if #txt == 0 then
        txtStartIndex = v.startIndex
      end
      txt[#txt+1] = v.value
      txtEndIndex = v.endIndex
    else
      if #txt > 0 then
        out[#out+1] = { type = "text", value = table_concat(txt), startIndex = txtStartIndex, endIndex = txtEndIndex }
        txt = {}
      end
      out[#out+1] = v
    end
  end
  if #txt > 0 then
    out[#out+1] = { type = "text", value = table_concat(txt), startIndex = txtStartIndex, endIndex = txtEndIndex  }
  end
  return out
end

local function make_context(view)
  if not view then return view end
  return getmetatable(view) == Context and view or Context:new(view)
end

local renderer = { }

function renderer:clear_cache()
  self.cache = {}
  self.partial_cache = {}
end

function renderer:compile(tokens, tags, originalTemplate)
  tags = tags or self.tags
  if type(tokens) == "string" then
    tokens = self:parse(tokens, tags)
  end

  local fn = compile_tokens(tokens, originalTemplate)

  return function(view)
    return fn(make_context(view), self)
  end
end

function renderer:render(template, view, partials)
  if type(self) == "string" then
    error("Call mustache:render, not mustache.render!")
  end

  if partials then
    -- remember partial table
    -- used for runtime lookup & compile later on
    self.partials = partials
  end

  if not template then
    return ""
  end

  local fn = self.cache[template]

  if not fn then
    fn = self:compile(template, self.tags, template)
    self.cache[template] = fn
  end

  return fn(view)
end

function renderer:renderFile(path, view, partials)
	if(not path) then
		error('renderFill(...), the first param is required');
	end
	local template = templateHelper.get(path);
	if(not template) then
		error('not found the template file: '.. path);
	end
	return self:render(template, view, partials);
end

function renderer:_section(token, context, callback, originalTemplate)
  local value = context:lookup(token.value)

  if type(value) == "table" then
    if is_array(value) then
      local buffer = ""

      for i,v in ipairs(value) do
        buffer = buffer .. callback(context:push(v), self)
      end

      return buffer
    end

    return callback(context:push(value), self)
  elseif type(value) == "function" then
    local section_text = string_sub(originalTemplate, token.endIndex+1, token.closingTagIndex - 1)

    local scoped_render = function(template)
      return self:render(template, context)
    end

    return value(section_text, scoped_render) or ""
  else
    if value then
      return callback(context, self)
    end
  end

  return ""
end

function renderer:_inverted(name, context, callback)
  local value = context:lookup(name)

  -- From the spec: inverted sections may render text once based on the
  -- inverse value of the key. That is, they will be rendered if the key
  -- doesn't exist, is false, or is an empty list.

  if value == nil or value == false or (type(value) == "table" and is_array(value) and #value == 0) then
    return callback(context, self)
  end

  return ""
end

function renderer:_partial(name, context, originalTemplate)
  local fn = self.partial_cache[name]

  -- check if partial cache exists
  if (not fn and self.partials) then

    local partial = self.partials[name]
    if (not partial) then
      return ""
    end
    
    -- compile partial and store result in cache
    fn = self:compile(partial, nil, originalTemplate)
    self.partial_cache[name] = fn
  end
  return fn and fn(context, self) or ""
end

function renderer:_name(name, context, escape)
  local value = context:lookup(name)

  if type(value) == "function" then
    value = value(context.view)
  end

  local str = value == nil and "" or value
  str = tostring(str)

  if escape then
    return string_gsub(str, '[&<>"\'/]', function(s) return html_escape_characters[s] end)
  end

  return str
end

-- Breaks up the given `template` string into a tree of token objects. If
-- `tags` is given here it must be an array with two string values: the
-- opening and closing tags used in the template (e.g. ["<%", "%>"]). Of
-- course, the default is to use mustaches (i.e. Mustache.tags).
function renderer:parse(template, tags)
  tags = tags or self.tags
  local tag_patterns = escape_tags(tags)
  local scanner = Scanner:new(template)
  local tokens = {} -- token buffer
  local spaces = {} -- indices of whitespace tokens on the current line
  local has_tag = false -- is there a {{tag} on the current line?
  local non_space = false -- is there a non-space char on the current line?

  -- Strips all whitespace tokens array for the current line if there was
  -- a {{#tag}} on it and otherwise only space
  local function strip_space()
    if has_tag and not non_space then
      while #spaces > 0 do
        table_remove(tokens, table_remove(spaces))
      end
    else
      spaces = {}
    end
    has_tag = false
    non_space = false
  end

  local type, value, chr

  while not scanner:eos() do
    local start = scanner.pos

    value = scanner:scan_until(tag_patterns[1])

    if value then
      for i = 1, #value do
        chr = string_sub(value,i,i)

        if string_find(chr, "%s+") then
          spaces[#spaces+1] = #tokens + 1
        else
          non_space = true
        end

        tokens[#tokens+1] = { type = "text", value = chr, startIndex = start, endIndex = start }
        start = start + 1
        if chr == "\n" then
          strip_space()
        end
      end
    end

    if not scanner:scan(tag_patterns[1]) then
      break
    end

    has_tag = true
    type = scanner:scan(patterns.tag) or "name"

    scanner:scan(patterns.white)

    if type == "=" then
      value = scanner:scan_until(patterns.eq)
      scanner:scan(patterns.eq)
      scanner:scan_until(tag_patterns[2])
    elseif type == "{" then
      local close_pattern = "%s*}"..tags[2]
      value = scanner:scan_until(close_pattern)
      scanner:scan(patterns.curly)
      scanner:scan_until(tag_patterns[2])
    else
      value = scanner:scan_until(tag_patterns[2])
    end

    if not scanner:scan(tag_patterns[2]) then
      error("Unclosed tag at " .. scanner.pos)
    end

    tokens[#tokens+1] = { type = type, value = value, startIndex = start, endIndex = scanner.pos - 1 }
    if type == "name" or type == "{" or type == "&" then
      non_space = true --> what does this do?
    end

    if type == "=" then
      tags = string_split(value, patterns.space)
      tag_patterns = escape_tags(tags)
    end
  end

  local ntokens, ps = nest_tokens(squash_tokens(tokens));

  if(ps.father) then
	local str = templateHelper.get(ps.father.value);
	local fntokens, fps = self:parse(str);
	-- if(fps.places and ps.placeins) then
	-- 	local replaces = {};
	-- 	for k, place in pairs(fps.places) do
	-- 		replaces[place.__idx] = ps.placeins[k].tokens;
	-- 	end
	-- 	local newtokens = {};
	-- 	local i = 1;
	-- 	for i = 1, #fntokens do
	-- 		local replacetokens = replaces[i];
	-- 		if(replacetokens) then
	-- 			local j = 1;
	-- 			for j = 1, #replacetokens do
	-- 				--newtokens:insert(replacetokens[j]);
	-- 				table.insert(newtokens, replacetokens[j]);
	-- 			end
	-- 		else
	-- 			--newtokens:insert(fntokens[i]);
	-- 			table.insert(newtokens, fntokens[i]);
	-- 		end
	-- 	end
  --   fntokens = newtokens;
  -- end

  if(fps.places and ps.placeins) then
		local newtokens = {};
		local i = 1;
		for i = 1, #fntokens do
			local fntoken = fntokens[i];
			if(fntoken.type == '?') then
				local placein = ps.placeins[fntoken.value];
				if(placein) then
					local j = 1;
					for j = 1, #(placein.tokens) do
						table.insert(newtokens, placein.tokens[j]);
					end
				end
			else
				table.insert(newtokens, fntoken);
			end
		end
		fntokens = newtokens;
	end
	ntokens = fntokens;
  end

  return ntokens, ps;
end

function renderer:new()
  local out = { 
    cache         = {},
    partial_cache = {},
    tags          = {"{{", "}}"}
  }
  return setmetatable(out, { __index = self })
end

return renderer
