local args = { ... }

-- Show help
if args[1] == "help" then
    term.clear()
    term.setCursorPos(1, 1)
    print("CCPack Usage:")
    print("  ccpack build")
    print("    Build project from config.json")
    print("")
    print("  ccpack bundle <folder> <entry> <output>")
    print("    Bundle project into single file")
    print("")
    print("  ccpack minify <input> <output>")
    print("    Minify a lua file")
    print("")
    print("  ccpack config")
    print("    Edit config.json")
    print("")
    print("  ccpack config create")
    print("    Create template config.json")
    print("")
    print("  ccpack config help")
    print("    Show config options")
    return
end

-- Config commands
if args[1] == "config" then
    if args[2] == "help" then
        term.clear()
        term.setCursorPos(1, 1)
        print("Config Settings (config.json):")
        print("")
        print("  project_folder")
        print("    Folder containing source files")
        print("")
        print("  entry_file")
        print("    Main program file to execute")
        print("")
        print("  output_path")
        print("    Where to write bundled output")
        return
    end
    if args[2] == "create" then
        if fs.exists("config.json") then
            print("Config already exists")
            write("Overwrite? (y/N) ")
            local event, key = os.pullEvent("key")
            if key ~= keys.y then
                print("")
                print("Cancelled")
                return
            end
            print("")
        end
        local config = {
            project_folder = "Project",
            entry_file = "project.lua",
            output_path = "output.lua"
        }
        local config_text = textutils.serialiseJSON(config)
        config_text = config_text:gsub("{", "{\n    "):gsub(",", ",\n   "):gsub("}", "\n}"):gsub(":", ": ")
        local config_file = fs.open("config.json", 'w')
        config_file.write(config_text)
        config_file.close()
        print("Created config.json")
        sleep(0.1)
        return
    end
    shell.run("edit config.json")
    return
end

-- Bundle & Minify with config
if args[1] == "build" then
    -- Load config from file
    local configFile = fs.open("config.json", "r")
    local configText = configFile.readAll()
    configFile.close()
    local config = textutils.unserializeJSON(configText)

    -- Verify project folder
    if not fs.isDir(config.project_folder) then
        print("Project folder not found")
        return
    end
    print("Project folder:",config.project_folder)

    -- Verify entrypoint
    if not fs.exists(config.entry_file) then
        print("Entry file does not exist")
        return
    end
    print("Entry point:",config.entry_file)

    -- Verify output path
    if not config.output_path or config.output_path == "" then
        print("Output path not specified")
        return
    end
    print("Output:",config.output_path)

    -- Build
    print("Bundling...")
    local bundleFunc = loadfile("src/bundle.lua")
    if not bundleFunc then
        print("Bundler not found")
        return
    end
    bundleFunc(
        config.project_folder,
        config.entry_file,
        config.output_path
    )

    print("Minifying...")
    local minifyFunc = loadfile("src/minify.lua")
    if not minifyFunc then
        print("Minifier not found")
        return
    end
    minifyFunc(
        config.output_path,
        config.output_path,
        "50"
    )

    print("Project built successfully")
    return
end

if args[1] == "bundle" then
    if not args[2] or not args[3] or not args[4] then
        print("Usage: ccpack bundle <folder> <entry> <output>")
        return
    end
    local bundleFunc = loadfile("src/bundle.lua")
    if not bundleFunc then
        print("Bundler not found")
        return
    end
    bundleFunc(args[2], args[3], args[4])
    print("Bundled to "..args[4])
    return
end

if args[1] == "minify" then
    if not args[2] or not args[3] then
        print("Usage: ccpack minify <input> <output>")
        return
    end
    local minifyFunc = loadfile("src/minify.lua")
    if not minifyFunc then
        print("Minifier not found")
        return
    end
    minifyFunc(args[2], args[3], args[4], args[5])
    print("Minified to "..args[3])
    return
end
