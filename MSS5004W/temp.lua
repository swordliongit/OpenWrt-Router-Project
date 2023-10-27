System = {}
function System.Get_firmwareVersion()
    local firmwareVersion_path = "/etc/project_master_modem/res/version"
    local version = ""

    -- Open the file for reading
    local firmwareVersion_file = io.open(firmwareVersion_path, "r")
    if firmwareVersion_file then
        version = firmwareVersion_file:read("*all")
        firmwareVersion_file:close()
    end

    return version
end

print(System.Get_firmwareVersion())
