local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")
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
local responseBody = ''
responseBody = table.concat(body)

if code == 200 then
    print(responseBody)
else
    print("Failed to authenticate. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
end



