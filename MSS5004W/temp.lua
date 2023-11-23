-- tail -n 20 /etc/project_master_modem/res/script.log
-- tail -n 20 /etc/project_master_modem/res/master_init.log


Sysupgrade = {}


Http = require("socket.http")
Ltn12 = require("ltn12")
Json = require("json")

dofile("/etc/project_master_modem/src/util.lua")
function Sysupgrade.Upgrade()
    local url = "http://modem.nitrawork.com:8081/web/content/45?download=true&access_token="
    local filename = "new-firmware.bin"

    local response = {}
    local _, code, headers, status = Http.request {
        url = url,
        redirect = true, -- Follow redirection
        sink = Ltn12.sink.table(response),
        timeout = 60,    -- Set a timeout (adjust as needed)
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
                    print("Error writing to file: " .. error_message)
                    file:close()
                    return false
                end
            end
            file:close()
            print("File downloaded and saved: " .. filename)
            -- local exitStatus = os.execute("sysupgrade -n /tmp/" .. filename)
            -- return exitStatus
        else
            print("Error opening file for writing")
        end
    end
end

Sysupgrade.Upgrade()
