

local args = {...}

local file1_path = args[1]
local file2_path = args[2]

if not file1_path or not file2_path then
    error("Usage: compare <file1|folder1> <file2|folder2>")
end

if not fs.exists(file1_path) then
    error("Path does not exist: " .. file1_path)
end

if not fs.exists(file2_path) then
    error("Path does not exist: " .. file2_path)
end

-- Function to recursively calculate total size of a directory
local function getDirectorySize(path)
    local totalSize = 0
    local fileCount = 0
    
    local function traverse(currentPath)
        if fs.isDir(currentPath) then
            local files = fs.list(currentPath)
            for _, file in ipairs(files) do
                local fullPath = fs.combine(currentPath, file)
                traverse(fullPath)
            end
        else
            totalSize = totalSize + fs.getSize(currentPath)
            fileCount = fileCount + 1
        end
    end
    
    traverse(path)
    return totalSize, fileCount
end

-- Get size for path 1
local size1, count1
local isDir1 = fs.isDir(file1_path)
if isDir1 then
    size1, count1 = getDirectorySize(file1_path)
else
    size1 = fs.getSize(file1_path)
    count1 = 1
end

-- Get size for path 2
local size2, count2
local isDir2 = fs.isDir(file2_path)
if isDir2 then
    size2, count2 = getDirectorySize(file2_path)
else
    size2 = fs.getSize(file2_path)
    count2 = 1
end

local difference = size2 - size1
local percentChange = size1 > 0 and (difference / size1 * 100) or 0

-- Display results
local type1 = isDir1 and "folder" or "file"
local type2 = isDir2 and "folder" or "file"

print(file1_path .. " (" .. type1 .. "): " .. size1 .. " bytes" .. (isDir1 and " across " .. count1 .. " files" or ""))
print(file2_path .. " (" .. type2 .. "): " .. size2 .. " bytes" .. (isDir2 and " across " .. count2 .. " files" or ""))
print("")

if difference > 0 then
    print("Path 2 is larger by " .. difference .. " bytes (" .. string.format("%.2f", percentChange) .. "% increase)")
elseif difference < 0 then
    print("Path 2 is smaller by " .. math.abs(difference) .. " bytes (" .. string.format("%.2f", math.abs(percentChange)) .. "% reduction)")
else
    print("Paths are the same size")
end