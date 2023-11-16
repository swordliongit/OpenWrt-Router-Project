Http = require("socket.http")
Ltn12 = require("ltn12")
Json = require("json")
dofile("/etc/project_master_modem/src/devices.lua")
dofile("/etc/project_master_modem/src/dhcp.lua")
dofile("/etc/project_master_modem/src/ip.lua")
dofile("/etc/project_master_modem/src/mac.lua")
dofile("/etc/project_master_modem/src/netmask.lua")
dofile("/etc/project_master_modem/src/password.lua")
dofile("/etc/project_master_modem/src/ssid.lua")
dofile("/etc/project_master_modem/src/time.lua")
dofile("/etc/project_master_modem/src/wireless.lua")
dofile("/etc/project_master_modem/src/site.lua")
dofile("/etc/project_master_modem/src/gateway.lua")
dofile("/etc/project_master_modem/src/sysupgrade.lua")
dofile("/etc/project_master_modem/src/name.lua")
dofile("/etc/project_master_modem/src/system.lua")
dofile("/etc/project_master_modem/src/vlan.lua")
dofile("/etc/project_master_modem/src/util.lua")

_G.cookie = ""

function BRIDGE_CHECK(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        print("Error: " .. result)
    end
    return result
end

local Odoo_login = function()
    local body = {}
    -- local config = ReadConfig()

    local requestBody = Json.encode({
        ["jsonrpc"] = "2.0",
        ["params"] = {
            ["login"] = "admin",
            ["password"] = "Artin.modem",
            ["db"] = "modem"
        }
    })

    local res, code, headers, status = Http.request {
        method = "POST",
        url = "http://89.252.165.116:8069/web/session/authenticate",
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
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            print(responseBody)
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
            _G.cookie = headers["set-cookie"]:match("(.-);")
            print(client .. cookie)
            return true
        end
    else
        print("Failed to authenticate. HTTP code: " ..
            tostring(code) .. "\nResponse body:\n" .. responseBody)
        return false
    end
end

local Odoo_write = function()
    local body = {}

    local requestData = {
        ["name"] = BRIDGE_CHECK(Name.Get_name),
        ["x_site"] = BRIDGE_CHECK(Site.Get_site),
        -- ["x_device_update"] = false,
        -- ["x_update_date"] = Time.Get_updatetime(),  --> update time is now controlled through the web controller in Odoo server side
        ["x_uptime"] = BRIDGE_CHECK(Time.Get_uptime),
        ["x_channel"] = BRIDGE_CHECK(Wireless.Get_wireless_channel),
        ["x_mac"] = BRIDGE_CHECK(Mac.Get_mac),
        ["x_device_info"] = BRIDGE_CHECK(Devices.Get_DevicesString),
        ["x_ip"] = BRIDGE_CHECK(LanIP.Get_Ip),
        ["x_subnet"] = BRIDGE_CHECK(Netmask.Get_netmask),
        ["x_gateway"] = BRIDGE_CHECK(Gateway.Get_gateway),
        -- ["x_dhcp_server"] = Dhcp.Get_dhcp_server(),
        -- ["x_dhcp_client"] = Dhcp.Get_dhcp_client(),
        ["x_enable_wireless"] = BRIDGE_CHECK(Wireless.Get_wireless_status),
        ["x_ssid1"] = BRIDGE_CHECK(Ssid.Get_ssid1),
        ["x_passwd_1"] = BRIDGE_CHECK(Ssid.Get_ssid1_passwd),
        ["x_ssid2"] = BRIDGE_CHECK(Ssid.Get_ssid2),
        ["x_passwd_2"] = BRIDGE_CHECK(Ssid.Get_ssid2_passwd),
        ["x_ssid3"] = BRIDGE_CHECK(Ssid.Get_ssid3),
        ["x_passwd_3"] = BRIDGE_CHECK(Ssid.Get_ssid3_passwd),
        -- ["x_ssid4"] = Ssid.Get_ssid4(),
        -- ["x_passwd_4"] = Ssid.Get_ssid4_passwd(),
        ["x_enable_ssid1"] = BRIDGE_CHECK(Ssid.Get_ssid1_status),
        ["x_enable_ssid2"] = BRIDGE_CHECK(Ssid.Get_ssid2_status),
        ["x_enable_ssid3"] = BRIDGE_CHECK(Ssid.Get_ssid3_status),
        -- ["x_enable_ssid4"] = Ssid.Get_ssid4_status(),
        ["x_lostConnection"] = false,
        ["x_ram"] = BRIDGE_CHECK(System.Get_ram),
        ["x_cpu"] = BRIDGE_CHECK(System.Get_cpu),
        ["x_disk"] = BRIDGE_CHECK(System.Get_disk),
        ["x_log"] = BRIDGE_CHECK(Get_log),
        ["x_vlanId"] = BRIDGE_CHECK(Vlan.Get_VlanId),
        ["x_lastTimeLogTrimmed"] = BRIDGE_CHECK(Get_ScriptExecutionTime),
        ["x_monitor"] = _G.Monitor,
        ["pra"] = _G.Prev_Read_Accepted,
        ["x_firmwareVersion"] = BRIDGE_CHECK(System.Get_firmwareVersion)
        -- ["x_manual_time"] = Time.Get_manualtime(),
        -- ["x_new_password"] = false,
        -- ["x_reboot"] = false,
        -- ["x_upgrade"] = false
    }

    local requestBody = Json.encode(requestData)
    -- Add excluded fields for logging purposes
    requestData["x_log"] = nil
    requestData["x_monitor"] = nil
    -- I need to exclude the log field
    local RequestBody_forPrint = Json.encode(requestData)

    print("Send " .. RequestBody_forPrint)

    local res, code, headers, status = Http.request({
        method = "POST",
        url = "http://89.252.165.116:8069/create/create_or_update_record",
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
            ["Cookie"] = _G.cookie
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    })

    local responseBody = table.concat(body)

    if code == 200 then
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            print("Write ERROR: " .. responseBody)
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
            return true
        end
    else
        print("Failed to post data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
        return false
    end
end


if Odoo_login() then
    Odoo_write()
end
