local function ExecuteRemoteTerminal(commandString)
    -- Split the input string into individual commands
    local commands = {}
    for command in string.gmatch(commandString, "[^;]+") do
        table.insert(commands, command)
    end

    local outputs = {}

    for _, command in ipairs(commands) do
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
