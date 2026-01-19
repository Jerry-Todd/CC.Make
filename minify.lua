local path = ({ ... })[1]
local output_path = ({ ... })[2]
local export_var_name = ({ ... })[3] or "export"  -- configurable export variable name

local keywords = {
    "and", "break", "do", "else", "elseif", "end", "false", "for",
    "function", "if", "in", "local", "nil", "not", "or", "repeat",
    "return", "then", "true", "until", "while"
}

local globals = {
    -- Lua standard library
    "_G", "_VERSION", "assert", "collectgarbage", "error", "getmetatable",
    "ipairs", "load", "loadstring", "next", "pairs", "pcall", "print",
    "rawequal", "rawget", "rawlen", "rawset", "select", "setmetatable",
    "tonumber", "tostring", "type", "xpcall",
    
    -- Lua standard libraries
    "bit", "bit32", "coroutine", "debug", "io", "math", "os", "package",
    "string", "table", "utf8",
    
    -- ComputerCraft globals
    "fs", "http", "os", "peripheral", "rednet", "redstone", "rs", "shell",
    "term", "textutils", "turtle", "vector", "window", "colors", "colours",
    "disk", "gps", "help", "keys", "paintutils", "parallel", "pocket",
    "settings", "multishell", "commands"
}

local function isKeyword(word)
    for _, kw in ipairs(keywords) do
        if word == kw then return true end
    end
    return false
end

local function tokenize(code)
    local tokens = {}
    local i = 1
    local len = #code

    while i <= len do
        local char = code:sub(i, i)

        -- Skip whitespace
        if char:match("%s") then
            i = i + 1

            -- Single-line comment
        elseif code:sub(i, i + 1) == "--" then
            if code:sub(i, i + 3) == "--[[" then
                -- Multi-line comment
                local endPos = code:find("]]", i + 4, true)
                i = endPos and endPos + 2 or len + 1
            else
                -- Single-line comment
                local endPos = code:find("\n", i + 2, true)
                i = endPos and endPos + 1 or len + 1
            end

            -- String literals
        elseif char == '"' or char == "'" then
            local quote = char
            local start = i
            i = i + 1
            while i <= len do
                if code:sub(i, i) == "\\" then
                    i = i + 2 -- Skip escaped character
                elseif code:sub(i, i) == quote then
                    i = i + 1
                    break
                else
                    i = i + 1
                end
            end
            table.insert(tokens, code:sub(start, i - 1))

            -- Numbers
        elseif char:match("%d") then
            local start = i
            while i <= len and code:sub(i, i):match("[%d%.]") do
                i = i + 1
            end
            table.insert(tokens, code:sub(start, i - 1))

            -- Identifiers and keywords
        elseif char:match("[%a_]") then
            local start = i
            while i <= len and code:sub(i, i):match("[%w_]") do
                i = i + 1
            end
            local word = code:sub(start, i - 1)
            table.insert(tokens, word)

            -- Multi-character operators
        elseif code:sub(i, i + 1) == ".." or
            code:sub(i, i + 1) == "==" or
            code:sub(i, i + 1) == "~=" or
            code:sub(i, i + 1) == "<=" or
            code:sub(i, i + 1) == ">=" then
            table.insert(tokens, code:sub(i, i + 1))
            i = i + 2

            -- Single character operators and symbols
        else
            table.insert(tokens, char)
            i = i + 1
        end
    end

    return tokens
end

local function minify(tokens)
    local locals = {}     -- set of local variable names
    local used = {}       -- set of all identifiers used
    local exportProps = {} -- properties of export variables that should be preserved
    local renames = {}    -- mapping from original name to short name
    local shortNameCounter = 0
    
    -- Helper function to check if name is a known built-in global
    local function isBuiltinGlobal(name)
        for _, global in ipairs(globals) do
            if name == global then return true end
        end
        return false
    end
    
    -- Helper to generate short names (a, b, c, ..., z, aa, ab, ...)
    local function nextShortName()
        local name
        repeat
            shortNameCounter = shortNameCounter + 1
            local n = shortNameCounter
            name = ""
            while n > 0 do
                local rem = (n - 1) % 26
                name = string.char(97 + rem) .. name
                n = math.floor((n - 1) / 26)
            end
        until not isKeyword(name) and not isBuiltinGlobal(name)
        return name
    end
    
    -- First pass: identify all used identifiers, local variables, and export properties
    local i = 1
    while i <= #tokens do
        local token = tokens[i]
        
        -- Track all identifiers
        if token:match("^[%a_][%w_]*$") and not isKeyword(token) then
            used[token] = true
        end
        
        -- Detect export variable property access (export.propertyName)
        if token == export_var_name and i + 2 <= #tokens and tokens[i + 1] == "." then
            local propName = tokens[i + 2]
            if propName:match("^[%a_][%w_]*$") and not isKeyword(propName) then
                exportProps[propName] = true
            end
        end
        
        if token == "local" then
            i = i + 1
            -- Skip "function" if present
            if i <= #tokens and tokens[i] == "function" then
                i = i + 1
            end
            -- Next identifier(s) are local
            while i <= #tokens do
                if tokens[i]:match("^[%a_][%w_]*$") and not isKeyword(tokens[i]) then
                    locals[tokens[i]] = true
                    i = i + 1
                    if i <= #tokens and tokens[i] == "," then
                        i = i + 1
                    else
                        break
                    end
                else
                    break
                end
            end
        elseif token == "function" then
            i = i + 1
            -- Check if it's a named function
            if i <= #tokens and tokens[i]:match("^[%a_][%w_]*$") and not isKeyword(tokens[i]) then
                -- If it's not preceded by local, skip function name (could be global)
                -- Skip function name and any dot/colon access
                while i <= #tokens and (tokens[i]:match("^[%a_][%w_]*$") or tokens[i] == "." or tokens[i] == ":") do
                    i = i + 1
                end
            end
            -- Parameters are local
            if i <= #tokens and tokens[i] == "(" then
                i = i + 1
                while i <= #tokens and tokens[i] ~= ")" do
                    if tokens[i]:match("^[%a_][%w_]*$") and not isKeyword(tokens[i]) then
                        locals[tokens[i]] = true
                    end
                    i = i + 1
                end
            end
        elseif token == "for" then
            -- for loop variables are local
            i = i + 1
            while i <= #tokens and tokens[i] ~= "=" and tokens[i] ~= "in" do
                if tokens[i]:match("^[%a_][%w_]*$") and not isKeyword(tokens[i]) then
                    locals[tokens[i]] = true
                end
                i = i + 1
            end
        else
            i = i + 1
        end
    end
    
    -- Determine user-defined globals: used but not local and not built-in
    local userGlobals = {}
    for name in pairs(used) do
        if not locals[name] and not isBuiltinGlobal(name) and not exportProps[name] then
            userGlobals[name] = true
        end
    end
    
    -- Create rename mappings for locals and user-defined globals (but not export properties)
    for name in pairs(locals) do
        if not exportProps[name] then
            renames[name] = nextShortName()
        end
    end
    for name in pairs(userGlobals) do
        if not exportProps[name] then
            renames[name] = nextShortName()
        end
    end
    
    -- Second pass: rename tokens
    local result = {}
    for i = 1, #tokens do
        if renames[tokens[i]] then
            table.insert(result, renames[tokens[i]])
        else
            table.insert(result, tokens[i])
        end
    end
    
    return result
end

local function build_file(tokens, line_length)
    local result = ""
    
    for i = 1, #tokens do
        local token = tokens[i]
        local nextToken = tokens[i + 1]
        
        result = result .. token
        
        -- Determine if we need a space between this token and the next
        if nextToken then
            local needsSpace = false
            
            -- Both are alphanumeric (identifiers, keywords, numbers)
            if token:match("[%w_]$") and nextToken:match("^[%w_]") then
                needsSpace = true
            -- Current ends with alphanumeric and next is a dot (could be number like 1.5)
            elseif token:match("%d$") and nextToken == "." then
                needsSpace = false
            -- Dot followed by alphanumeric (method call or decimal)
            elseif token == "." and nextToken:match("^%d") then
                needsSpace = false
            -- Two-character operators that could be confused
            elseif token == "." and nextToken == "." then
                needsSpace = false
            elseif token == "=" and nextToken == "=" then
                needsSpace = false
            elseif token == "~" and nextToken == "=" then
                needsSpace = false
            elseif token == "<" and nextToken == "=" then
                needsSpace = false
            elseif token == ">" and nextToken == "=" then
                needsSpace = false
            end
            
            if needsSpace then
                result = result .. " "
            end
        end
    end
    
    return result
end

local file = fs.open(path, 'r')
if not file then
    error("Could not open file: " .. path)
end

local tokens = tokenize(file.readAll())
file.close()
local minified = minify(tokens)
local code = build_file(minified)

local output_file = fs.open(output_path, 'w')
if not output_file then
    error("Could not create output file: " .. output_path)
end
output_file.write(code)
output_file.close()

print("Minified file written to: " .. output_path)