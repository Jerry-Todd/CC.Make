

local args = {...}

local file1_path = args[1]
local file2_path = args[2]

if not file1_path or not file2_path then
    error("Usage: compare <file1> <file2>")
end

if not fs.exists(file1_path) then
    error("File does not exist: " .. file1_path)
end

if not fs.exists(file2_path) then
    error("File does not exist: " .. file2_path)
end

local size1 = fs.getSize(file1_path)
local size2 = fs.getSize(file2_path)
local difference = size2 - size1
local percentChange = size1 > 0 and (difference / size1 * 100) or 0

print(file1_path .. ": " .. size1 .. " bytes")
print(file2_path .. ": " .. size2 .. " bytes")
print("")

if difference > 0 then
    print("File 2 is larger by " .. difference .. " bytes (" .. string.format("%.2f", percentChange) .. "% increase)")
elseif difference < 0 then
    print("File 2 is smaller by " .. math.abs(difference) .. " bytes (" .. string.format("%.2f", math.abs(percentChange)) .. "% reduction)")
else
    print("Files are the same size")
end