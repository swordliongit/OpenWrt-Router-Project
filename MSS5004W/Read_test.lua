Http = require("socket.http")
Ltn12 = require("ltn12")
Json = require("json")

dofile("/etc/project_master_modem/src/mac.lua")

local Odoo_read = function()
    local body = {}

    local requestData = {
        ["x_mac"] = Mac.Get_mac(),
        ["fields"] = {
            "name",
            "x_site",
            "x_channel",
            "x_enable_wireless",
            "x_ssid1",
            "x_passwd_1",
            "x_ssid2",
            "x_passwd_2",
            "x_ssid3",
            "x_passwd_3",
            "x_enable_ssid1",
            "x_enable_ssid2",
            "x_enable_ssid3",
            "x_new_password",
            "x_reboot",
            "x_upgrade",
            "x_vlanId",
            "x_terminal",
        }
    }

    local requestBody = Json.encode(requestData)
    local res, code, headers, status = Http.request({
        method = "POST",
        url = "http://modem.nitrawork.com:8081/cc/read_records",
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    })

    local responseBody = table.concat(body)

    print(responseBody)

    if code == 200 then
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            print("Read ERROR: " .. responseBody)
            return false
            --     if Serror_backoff_counter >= MAX_SERROR then
            --         Serror_backoff_counter = 0
            --         os.execute("reboot")
            --     end
            --     Serror_backoff_counter = Serror_backoff_counter + 1
            --     WriteLog(bridge ..
            --         "SERROR backoff activated! Rebooting in " .. tostring(MAX_SERROR - Serror_backoff_counter) .. " tries...")
            -- else
            --     WriteLog(server .. responseBody)
            --     Serror_backoff_counter = 0
        else
            return true, responseBody
        end
    else
        print("Failed to fetch data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
        return false, responseBody
    end
end


local Odoo_parse = function(responseBody)
    local responseJson = Json.decode(responseBody)
    local modem = responseJson.result.modem

    local parsed_values = {
        ["name"] = modem.name,
        ["x_site"] = modem.x_site,
        ["x_channel"] = modem.x_channel,
        ["x_enable_wireless"] = modem.x_enable_wireless,
        ["x_ssid1"] = modem.x_ssid1,
        ["x_passwd_1"] = modem.x_passwd_1,
        ["x_ssid2"] = modem.x_ssid2,
        ["x_passwd_2"] = modem.x_passwd_2,
        ["x_ssid3"] = modem.x_ssid3,
        ["x_passwd_3"] = modem.x_passwd_3,
        ["x_enable_ssid1"] = modem.x_enable_ssid1,
        ["x_enable_ssid2"] = modem.x_enable_ssid2,
        ["x_enable_ssid3"] = modem.x_enable_ssid3,
        ["x_reboot"] = modem.x_reboot,
        ["x_upgrade"] = modem.x_upgrade,
        ["x_vlanId"] = modem.x_vlanId,
        ["x_terminal"] = modem.x_terminal,
        ["x_modify"] = modem.x_modify
    }

    return parsed_values
end

read_completed, read_response = Odoo_read()
parse_results = Odoo_parse(read_response)

function print_table(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            print_table(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end

print_table(parse_results)
