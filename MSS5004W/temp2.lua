Json = require("json")
Http = require("socket.http")
Https = require("ssl.https")

Ltn12 = require("ltn12")

Http.TIMEOUT = 5

local Odoo_login = function()
    local body = {}

    local requestBody = Json.encode({
        ["jsonrpc"] = "2.0",
        ["params"] = {
            ["login"] = "admin",
            ["password"] = "Artin.modem",
            ["db"] = "modem"
        }
    })

    local res, code, headers, status = Https.request {
        method = "POST",
        url = "https://modem.nitrawork.com/web/session/authenticate",
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody)
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    }

    local responseBody = table.concat(body)

    if code == 200 then
        _G.cookie = headers["set-cookie"]:match("(.-);")
        print(cookie .. "\n\n")
        return true
    else
        print("Failed to authenticate. HTTP code: " ..
            tostring(code) .. "\nResponse body:\n" .. responseBody .. "\n\n")
        return false
    end
end


Odoo_login()
