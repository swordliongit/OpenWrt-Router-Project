-- Author : Kılıçarslan SIMSIKI - ART-IN SYSTEMS 13.05.2023


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

    local responseBody = table.concat(body)

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


function Odoo_write(cookie)
    local http = require("socket.http")
    local ltn12 = require("ltn12")
    local json = require("json")
    local body = {}

    local requestBody = json.encode({
        ["id"] = 149,
        ["jsonrpc"] = "2.0",
        ["method"] = "call",
        ["params"] = {
            ["args"] = {{
                ["modem_image"] = false,
                ["__last_update"] = false,
                ["name"] = "fromrouter_1",
                ["x_hotel_name"] = "hotelfallen",
                ["x_device_update"] = false,
                ["x_update_date"] = false,
                ["x_uptime"] = false,
                ["x_wireless_status"] = false,
                ["x_channel"] = false,
                ["x_mac"] = "1c:18:4a:5d:54:23",
                ["x_device_info"] = false,
                ["x_ip"] = false,
                ["x_subnet"] = false,
                ["x_dhcp"] = false,
                ["x_enable_wireless"] = false,
                ["x_enable_ssid1"] = false,
                ["x_enable_ssid2"] = false,
                ["x_enable_ssid3"] = false,
                ["x_enable_ssid4"] = false,
                ["x_manual_time"] = false,
                ["x_new_password"] = false,
                ["x_reboot"] = false,
                ["modem_id"] = false,
                ["city"] = false,
                ["live_status"] = "offline",
                ["last_action_user"] = 3,
                ["modem_status"] = false,
                ["modem_home_mode"] = false,
                ["customer_id"] = {{6,false,{}}},
                ["modem_update"] = false,
                ["modem_version"] = false
            }},
            ["model"] = "modem.profile",
            ["method"] = "create",
            ["kwargs"] = {
                ["context"] = {
                    ["lang"] = "en_US",
                    ["tz"] = "Europe/Istanbul",
                    ["uid"] = 2,
                    ["allowed_company_ids"] = {1}
                }
            }
        }
    })

    local res, code, headers, status = http.request {
        method = "POST",
        url = "http://192.168.100.67:8072/web/dataset/call_kw/modem.profile/create",
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
        print("Failed to post data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
    end
end


Odoo_write(Odoo_login())