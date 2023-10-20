System = {}

function System.base64_encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do
            r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
        end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then
            return ''
        end
        local c = 0
        for i = 1, 6 do
            c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
        end
        return b:sub(c + 1, c + 1)
    end) .. (data:len() % 3 == 1 and '==' or (data:len() % 3 == 2 and '=' or '')))
end

function System.Get_log()
    local log_filename = "/tmp/trunkedlog.txt"
    local max_lines = 200

    -- Attempt to open the log file
    local file = io.open("/tmp/script.log", "r")
    if not file then
        return "Error: Log file not found or cannot be opened."
    end

    local log_lines = {}

    -- Read all lines into a table
    for line in file:lines() do
        table.insert(log_lines, line)
    end

    -- Calculate the number of lines to return
    local num_lines = #log_lines
    local start_index = math.max(num_lines - max_lines + 1, 1)

    -- Open a text file to save the last 200 lines
    local log_file = io.open(log_filename, "w+b")

    -- Write the last 200 lines to the text file
    for i = start_index, num_lines do
        log_file:write(log_lines[i] .. "\n")
    end

    -- Close both files
    file:close()
    log_file:close()

    local log_file_content = ""
    if log_filename then
        local file = io.open(log_filename, "r")
        if file then
            log_file_content = file:read("*a")
            file:close()
        end
    end
    return System.base64_encode(log_file_content)
end

print(System.Get_log())


function System.Get_log()
    -- Attempt to open the log file
    local file = io.open("/tmp/script.log", "r")
    if not file then
        return "Error: Log file not found or cannot be opened."
    end

    local log_lines = {}
    local max_lines = 30

    -- Read all lines into a table
    for line in file:lines() do
        table.insert(log_lines, line)
    end

    -- Calculate the number of lines to return
    local num_lines = #log_lines
    local start_index = math.max(num_lines - max_lines + 1, 1)

    -- Retrieve the last 200 lines
    local last_200_lines = table.concat(log_lines, "\n", start_index, num_lines)

    -- Close the file
    file:close()

    return last_200_lines
end
