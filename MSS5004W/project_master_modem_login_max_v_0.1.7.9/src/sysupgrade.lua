Sysupgrade = {}

function Sysupgrade.Upgrade()
    local url = "http://89.252.165.116:8069/web/content/45?download=true&access_token="
    local filename = "new-firmware.bin"

    local response = {}
    local _, code, headers, status = Http.request {
        url = url,
        redirect = true,           -- Follow redirection
        headers = {
            ["Cookie"] = _G.cookie -- Include the session cookie
        },
        sink = Ltn12.sink.table(response),
        timeout = 60, -- Set a timeout (adjust as needed)
    }

    if code == 200 then
        local contentDisposition = headers["content-disposition"]
        if contentDisposition and contentDisposition:match("filename=\"([^\"]+)\"") then
            filename = contentDisposition:match("filename=\"([^\"]+)\"")
        end

        local file = io.open("/tmp/" .. filename, "wb")
        if file then
            for _, chunk in ipairs(response) do
                local result, error_message = file:write(chunk)
                if not result then
                    WriteLog(client .. "Error writing to file: " .. error_message)
                    file:close()
                    return false
                end
            end
            file:close()
            WriteLog(client .. "File downloaded and saved: " .. filename)
            local exitStatus = os.execute("sysupgrade -n /tmp/" .. filename)
            return exitStatus
        else
            WriteLog(client .. "Error opening file for writing")
        end
    end
end
