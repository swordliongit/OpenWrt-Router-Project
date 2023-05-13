function Odoo_login()
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local json = require("json")
    local url = "http://89.252.165.116:8069/web/session/authenticate"
    local headers = {
        ["Connection"] = "keep-alive",
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5",
        ["Content-Type"] = "application/json"
    }
    local body = {
        ["jsonrpc"] = "2.0",
        ["params"] = {
            ["login"] = "admin",
            ["password"] = "Artin.modem",
            ["db"] = "modem"
        }
    }
    local requestBody = json.encode(body)
    local response_body = {}
    local res, code, response_headers = http.request{
        url = url,
        method = "POST",
        headers = headers,
        source = ltn12.source.string(requestBody),
        sink = ltn12.sink.table(response_body),
        protocol = "tlsv1_2"
    }

    -- Print the response headers
    for k, v in pairs(response_headers) do
        print(k, v)
    end
    if code == 200 then
        local responseBody = table.concat(response_body)
        return responseBody
    else
        return "Failed to authenticate. HTTP code: " .. tostring(code)
    end
end

print(Odoo_login())
