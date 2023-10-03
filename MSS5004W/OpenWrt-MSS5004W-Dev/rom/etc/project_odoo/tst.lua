local function incrementBootCounter()
    local bootFilePath = "/etc/project_odoo/bootcount"

    -- Open the file for reading
    local bootFile = io.open(bootFilePath, "r")
    if not bootFile then
        -- File doesn't exist, start from 0
        bootFile = io.open(bootFilePath, "w")
        bootFile:write("0")
        bootFile:close()
        return
    end

    -- Read the current boot count
    local bootCount = tonumber(bootFile:read("*all"))
    bootFile:close()

    -- Increment the boot count
    bootCount = bootCount + 1

    -- Open the file for writing
    bootFile = io.open(bootFilePath, "w")
    bootFile:write(tostring(bootCount))
    bootFile:close()
end

local function readBootCounter()
    local bootFilePath = "/etc/project_odoo/bootcount"

    -- Open the file for reading
    local bootFile = io.open(bootFilePath, "r")
    if not bootFile then
        -- File doesn't exist, return 0
        return 0
    end

    -- Read the boot count
    local bootCount = tonumber(bootFile:read("*all"))
    bootFile:close()

    return bootCount
end


incrementBootCounter()
print(readBootCounter())
incrementBootCounter()
print(readBootCounter())
