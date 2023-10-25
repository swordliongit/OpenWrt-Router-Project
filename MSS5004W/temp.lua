function ExecuteRemoteTerminal(commandString)
    if not commandString or commandString == "" then
        return "Error: Invalid command string"
    end

    -- Split the input string into individual commands
    local commands = {}
    for command in string.gmatch(commandString, "[^;]+") do
        table.insert(commands, command)
    end

    local outputs = {}

    for _, command in ipairs(commands) do
        -- Trim leading and trailing spaces
        command = command:gsub("^%s*(.-)%s*$", "%1")

        -- Execute the command and capture its output
        local outputHandle = io.popen(command)
        local output = outputHandle:read("*a")
        local exitCode = { outputHandle:close() }

        local result = {
            command = command,
            output = output,
            exitCode = exitCode,
        }

        table.insert(outputs, result)
    end

    local formattedResults = ""

    for _, result in ipairs(outputs) do
        formattedResults = formattedResults .. result.output .. ";\n" -- Add a newline
    end

    formattedResults = string.sub(formattedResults, 1, -3)

    return formattedResults
end

print(ExecuteRemoteTerminal("ls /etc/project_master_modem/ -l;df -h;netstat -rn;echo $PATH;"))
