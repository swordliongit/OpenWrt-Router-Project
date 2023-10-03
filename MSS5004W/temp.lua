_G.cookie = "" -- global cookie

http = require("socket.http")
ltn12 = require("ltn12")
json = require("json")

local Odoo_login = function()
    local body = {}

    local requestBody = json.encode({
        ["jsonrpc"] = "2.0",
        ["params"] = {
            ["login"] = "admin",
            ["password"] = "Artin.modem",
            ["db"] = "modem"
        }
    })

    local res, code, headers, status = http.request {
        method = "POST",
        url = "http://89.252.165.116:8069/web/session/authenticate",
        source = ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody)
        },
        sink = ltn12.sink.table(body),
        protocol = "tlsv1_2"
    }

    local responseBody = table.concat(body)

    if code == 200 then
        _G.cookie = headers["set-cookie"]:match("(.-);")
        io.write(cookie .. "\n\n")
        return true
    else
        io.write("Failed to authenticate. HTTP code: " ..
            tostring(code) .. "\nResponse body:\n" .. responseBody .. "\n\n")
        return false
    end
end


Odoo_login()
