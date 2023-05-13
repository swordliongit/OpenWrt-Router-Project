
function Odoo_login()

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
        url = "http://192.168.100.67:8072/web/session/authenticate",
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
        local cookie = headers["set-cookie"]:match("(.-);")
        print(cookie)
        return cookie
    else
        print("Failed to authenticate. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
    end
end


function Odoo_read(cookie)
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local json = require("json")
    local body = {}

    local requestBody = json.encode({
        ["id"] = 20,
        ["jsonrpc"] = "2.0",
        ["method"] = "call",
        ["params"] = {
            ["model"] = "modem.profile",
            ["domain"] = {
                {"x_mac", "=", "1c:18:4a:47:63:81"}
            },
            ["fields"] = {
                "x_hotel_name",
                "x_update_date",
                "x_uptime",
                "x_wireless_status",
                "x_channel",
                "x_mac",
                "x_device_info",
                "x_ip",
                "x_subnet",
                "x_dhcp",
                "x_enable_wireless",
                "x_enable_ssid1",
                "x_enable_ssid2",
                "x_enable_ssid3",
                "x_enable_ssid4",
                "x_manual_time",
                "x_new_password",
                "x_reboot",
                "name",
                "modem_status",
                "city",
                "live_status"
            },
            ["limit"] = 80,
            ["sort"] = "live_status DESC",
            ["context"] = {
                ["lang"] = "en_US",
                ["tz"] = "Europe/Istanbul",
                ["uid"] = 2,
                ["allowed_company_ids"] = {1},
                ["params"] = {
                    ["cids"] = 1,
                    ["menu_id"] = 129,
                    ["action"] = 182,
                    ["model"] = "modem.profile",
                    ["view_type"] = "list"
                },
                ["bin_size"] = true
            }
        }
    })

    local res, code, headers, status = http.request {
        method = "POST",
        url = "http://192.168.100.67:8072/web/dataset/search_read",
        source = ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
            ["Cookie"] = cookie
        },
        sink = ltn12.sink.table(body),
        protocol = "tlsv1_2"
    }

    local responseBody = table.concat(body)

    if code == 200 then
        print(responseBody)
    else
        print("Failed to fetch data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
    end
end

Odoo_read(Odoo_login())