
local args = {...}

local function findfiles(path, list)
    local root = false
    if not list then
        root = true
        list = {}
    end

    local directory = fs.list(path)
    for i, item in ipairs(directory) do
        if fs.isDir(fs.combine(path, item)) then
            findfiles(fs.combine(path, item), list)
        else
            table.insert(list, fs.combine(path, item))
        end
    end

    if root then return list end
end

local function run(path, entrypoint, output_name)
    local output = ""
    local files = findfiles(path)
    local fileMap = {}
    
    -- Create bundled functions and build file mapping
    for i, value in ipairs(files) do
        local file = fs.open(value, 'r')
        local content = file.readAll()
        output = output.."\nfunction Bundlefile"..i.."(...) "..content.." end"
        file.close()
        
        -- Extract full path relative to bundle root and convert to module name
        local relativePath = value:sub(#path + 2) -- Remove root path + separator
        local moduleName = relativePath:gsub("%.lua$", ""):gsub("/", ".")
        fileMap[moduleName] = "Bundlefile"..i
        
        -- Also map just the filename for simple requires
        local filename = fs.getName(value):gsub("%.lua$", "")
        fileMap[filename] = "Bundlefile"..i
    end
    
    -- Replace require() calls with bundled function calls
    for filename, funcName in pairs(fileMap) do
        -- Escape special pattern characters in filename
        local escapedFilename = filename:gsub("([%.%-])", "%%%1")
        -- Match require("filename") or require('filename')
        output = output:gsub('require%s*%(%s*["\']'..escapedFilename..'["\']%s*%)', funcName..'()')
    end
    
    -- Replace loadfile() calls with bundled function references
    for filename, funcName in pairs(fileMap) do
        -- Escape special pattern characters in filename
        local escapedFilename = filename:gsub("([%.%-])", "%%%1")
        -- Match loadfile("filename.lua") or loadfile('filename.lua')
        -- Also handle with or without .lua extension
        output = output:gsub('loadfile%s*%(%s*["\']'..escapedFilename..'%.lua["\']%s*%)', funcName)
        output = output:gsub('loadfile%s*%(%s*["\']'..escapedFilename..'["\']%s*%)', funcName)
    end
    
    -- Add entrypoint function call at the end
    local entrypointName = entrypoint:gsub("%.lua$", "")
    if fileMap[entrypointName] then
        output = output.."\n\n"..fileMap[entrypointName].."(...)"
    end
    
    local outputfile = fs.open((output_name or "output.lua"), 'w')
    outputfile.write(output)
    outputfile.close()
end

run(args[1], args[2], args[3])