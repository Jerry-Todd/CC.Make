local args = { ... }

local configFile = fs.open("config.json", "r")
local configText = configFile.readAll()
configFile.close()

local config = textutils.unserializeJSON(configText)

shell.run(
    "bundle",
    args[1] or config.project_folder,
    args[2] or config.entry_file,
    args[3] or config.output_name
)

shell.run(
    "minify",
    "Output/"..(args[3] or config.output_name),
    "Output/mini.lua"
)