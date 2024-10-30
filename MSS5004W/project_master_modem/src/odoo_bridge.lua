--[[
Author: Kılıçarslan SIMSIKI

Date Created: 20-05-2023
Date Modified: 10-08-2023

Description:
All modification and duplication of this software are forbidden and licensed under Apache.

Flow of the overall program:

Odoo_Write
loop:
    Odoo_execute <-- Bridge_Parse <-- Odoo_Read
    Odoo_Write
]]

_G.Serror_backoff_counter = 0
_G.MAX_SERROR = 10
_G.Monitor = ""
_G.Prev_Read_Accepted = true
_G.CONTEXT_CHANGED = false -- to control if we should send write requests

require("luci.sys")
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

function BRIDGE_CHECK(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        WriteLog(bridge .. "Error: " .. result)
    end
    return result
end

local Odoo_Read = function()
    local body = {}
    local config = ReadConfig()

    local requestBody = Json.encode({
        ["mac"] = Mac.Get_mac(),
        ["fields"] = {
            "name",
            "site",
            "channel",
            "enable_wireless",
            "ssid1",
            "passwd_1",
            "ssid2",
            "passwd_2",
            "ssid3",
            "passwd_3",
            "enable_ssid1",
            "enable_ssid2",
            "enable_ssid3",
            "new_password",
            "reboot",
            "upgrade",
            "vlanId",
            "terminal",
        }
    })

    WriteLog(client .. "Read " .. requestBody)

    local res, code, headers, status = Http.request {
        method = "POST",
        url = config.url_read,
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    }

    local responseBody = table.concat(body)

    if code == 200 then
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            WriteLog(server .. "Read ERROR: " .. responseBody)
            return false
        else
            WriteLog(client .. "Receive " .. responseBody)
            return true, responseBody
        end
    else
        WriteLog(server ..
            "Failed to fetch data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
        return false, responseBody
    end
end

local Bridge_Parse = function(responseBody)
    local responseJson = Json.decode(responseBody)
    local modem = responseJson.result.modem

    if responseJson.result.success then
        _G.Prev_Read_Accepted = true
    else
        _G.Prev_Read_Accepted = false
    end

    local parsed_values = {
        ["name"] = modem.name,
        ["site"] = modem.site,
        ["channel"] = modem.channel,
        ["enable_wireless"] = modem.enable_wireless,
        ["ssid1"] = modem.ssid1,
        ["passwd_1"] = modem.passwd_1,
        ["ssid2"] = modem.ssid2,
        ["passwd_2"] = modem.passwd_2,
        ["ssid3"] = modem.ssid3,
        ["passwd_3"] = modem.passwd_3,
        ["enable_ssid1"] = modem.enable_ssid1,
        ["enable_ssid2"] = modem.enable_ssid2,
        ["enable_ssid3"] = modem.enable_ssid3,
        ["reboot"] = modem.reboot,
        ["upgrade"] = modem.upgrade,
        ["vlanId"] = modem.vlanId,
        ["terminal"] = modem.terminal,
    }

    return parsed_values
end

local Bridge_Execute = function(parsed_values)
    local luci_util = require("luci.util")
    local need_reboot = false
    local need_wifi_reload = false
    local need_upgrade = false
    local pra_fail = false
    local anything_changed = false

    -- Define the order of execution for keys
    local execution_order = {
        "upgrade",
        "name",
        "ssid1",
        "ssid2",
        "ssid3",
        "passwd_1",
        "passwd_2",
        "passwd_3",
        "enable_ssid1",
        "enable_ssid2",
        "enable_ssid3",
        "enable_wireless",
        "site",
        "channel",
        "terminal",
        "vlanId",
        "reboot"
    }
    -- WriteLog(bridge .. tostring(anything_changed) .. "Before Execute")
    WriteLog(client .. "Execution Queue: [", "wrapper_start")
    if _G.Prev_Read_Accepted then
        for _, key in pairs(execution_order) do
            local value = parsed_values[key]

            if key == "name" and value ~= BRIDGE_CHECK(Name.Get_name) then
                WriteLog("Change Name", "task")
                BRIDGE_CHECK(Name.Set_name, value)
                anything_changed = true
            elseif key == "site" and value ~= BRIDGE_CHECK(Site.Get_site) then
                WriteLog("Change Site", "task")
                BRIDGE_CHECK(Site.Set_site, value)
                anything_changed = true
            elseif key == "channel" and value ~= BRIDGE_CHECK(Wireless.Get_wireless_channel) then
                WriteLog("Change Channel", "task")
                if value == "auto" then
                    BRIDGE_CHECK(Wireless.Set_wireless_channel, "0")
                else
                    BRIDGE_CHECK(Wireless.Set_wireless_channel, value)
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "enable_wireless" and value ~= BRIDGE_CHECK(Wireless.Get_wireless_status) then
                if value then
                    WriteLog("Enable Wireless", "task")
                    BRIDGE_CHECK(Wireless.Set_wireless_status, "1")
                else
                    WriteLog("Disable Wireless", "task")
                    BRIDGE_CHECK(Wireless.Set_wireless_status, "0")
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "ssid1" and value ~= BRIDGE_CHECK(Ssid.Get_ssid1) then
                if value ~= false then
                    WriteLog("Change SSID1", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid1, value)
                else
                    WriteLog("Change SSID1 - Empty", "task")
                    WriteLog("Hide SSID1", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid1, value)
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "passwd_1" and value ~= BRIDGE_CHECK(Ssid.Get_ssid1_passwd) then
                WriteLog("Change SSID1 Password", "task")
                BRIDGE_CHECK(Ssid.Set_ssid1_passwd, value)
                need_wifi_reload = true
                anything_changed = true
            elseif key == "ssid2" and value ~= BRIDGE_CHECK(Ssid.Get_ssid2) then
                if value ~= false then
                    WriteLog("Change SSID2", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid2, value)
                else
                    WriteLog("Change SSID2 - Empty", "task")
                    WriteLog("Hide SSID2", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid2, value)
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "passwd_2" and value ~= BRIDGE_CHECK(Ssid.Get_ssid2_passwd) then
                WriteLog("Change SSID2 Password", "task")
                BRIDGE_CHECK(Ssid.Set_ssid2_passwd, value)
                need_wifi_reload = true
                anything_changed = true
            elseif key == "ssid3" and value ~= BRIDGE_CHECK(Ssid.Get_ssid3) then
                if value ~= false then
                    WriteLog("Change SSID3", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid3, value)
                else
                    WriteLog("Change SSID3 - Empty", "task")
                    WriteLog("Hide SSID3", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid3, value)
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "passwd_3" and value ~= BRIDGE_CHECK(Ssid.Get_ssid3_passwd) then
                WriteLog("Change SSID3 Password", "task")
                BRIDGE_CHECK(Ssid.Set_ssid3_passwd, value)
                need_wifi_reload = true
                anything_changed = true
            elseif key == "enable_ssid1" and value ~= BRIDGE_CHECK(Ssid.Get_ssid1_status) then
                if value then
                    WriteLog("Enable SSID1", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid1_status, "1")
                else
                    WriteLog("Disable SSID1", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid1_status, "0")
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "enable_ssid2" and value ~= BRIDGE_CHECK(Ssid.Get_ssid2_status) then
                if value then
                    WriteLog("Enable SSID2", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid2_status, "1")
                else
                    WriteLog("Disable SSID2", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid2_status, "0")
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "enable_ssid3" and value ~= BRIDGE_CHECK(Ssid.Get_ssid3_status) then
                if value then
                    WriteLog("Enable SSID3", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid3_status, "1")
                else
                    WriteLog("Disable SSID3", "task")
                    BRIDGE_CHECK(Ssid.Set_ssid3_status, "0")
                end
                need_wifi_reload = true
                anything_changed = true
            elseif key == "reboot" and value ~= false then
                WriteLog("Forced Reboot", "task")
                need_reboot = true
                anything_changed = true
            elseif key == "upgrade" and value ~= false then
                WriteLog("Upgrade", "task")
                need_upgrade = true
                anything_changed = true
            elseif key == "vlanId" and value ~= BRIDGE_CHECK(Vlan.Get_VlanId) then
                WriteLog("Change VlanId", "task")
                if BRIDGE_CHECK(Vlan.Set_VlanId, value) then
                    need_reboot = true
                end
                anything_changed = true
            elseif key == "terminal" then
                if value ~= false then
                    WriteLog("Execute Remote Command", "task")
                    Monitor = BRIDGE_CHECK(ExecuteRemoteTerminal, value)
                    anything_changed = true
                end
            end
        end
    else
        pra_fail = true
    end
    -- WriteLog(bridge .. tostring(anything_changed) .. "After Execute")
    if anything_changed then
        CONTEXT = true
    else
        CONTEXT = false
    end

    if need_upgrade then
        WriteLog("]", "wrapper_end")
        BRIDGE_CHECK(Sysupgrade.Upgrade)
    end
    if need_reboot then
        WriteLog("Reboot", "task")
        WriteLog("]", "wrapper_end")
        return true
        -- os.execute("reboot")
    end
    if need_wifi_reload then
        WriteLog("Reload Wifi", "task")
        luci_util.exec("/sbin/wifi")
    end

    WriteLog("]", "wrapper_end")
    if pra_fail then
        WriteLog(client .. "Previous read attempt unsuccessful, not changing anything...")
    end
end

local Odoo_Write = function()
    local body = {}
    local config = ReadConfig()

    local requestData = {
        ["name"] = BRIDGE_CHECK(Name.Get_name),
        ["site"] = BRIDGE_CHECK(Site.Get_site),
        ["channel"] = BRIDGE_CHECK(Wireless.Get_wireless_channel),
        ["mac"] = BRIDGE_CHECK(Mac.Get_mac),
        ["device_info"] = BRIDGE_CHECK(Devices.Get_DevicesString),
        ["ip"] = BRIDGE_CHECK(LanIP.Get_Ip),
        ["subnet"] = BRIDGE_CHECK(Netmask.Get_netmask),
        ["gateway"] = BRIDGE_CHECK(Gateway.Get_gateway),
        ["enable_wireless"] = BRIDGE_CHECK(Wireless.Get_wireless_status),
        ["ssid1"] = BRIDGE_CHECK(Ssid.Get_ssid1),
        ["passwd_1"] = BRIDGE_CHECK(Ssid.Get_ssid1_passwd),
        ["ssid2"] = BRIDGE_CHECK(Ssid.Get_ssid2),
        ["passwd_2"] = BRIDGE_CHECK(Ssid.Get_ssid2_passwd),
        ["ssid3"] = BRIDGE_CHECK(Ssid.Get_ssid3),
        ["passwd_3"] = BRIDGE_CHECK(Ssid.Get_ssid3_passwd),
        ["enable_ssid1"] = BRIDGE_CHECK(Ssid.Get_ssid1_status),
        ["enable_ssid2"] = BRIDGE_CHECK(Ssid.Get_ssid2_status),
        ["enable_ssid3"] = BRIDGE_CHECK(Ssid.Get_ssid3_status),
        ["ram"] = BRIDGE_CHECK(System.Get_ram),
        ["cpu"] = BRIDGE_CHECK(System.Get_cpu),
        ["disk"] = BRIDGE_CHECK(System.Get_disk),
        ["log"] = BRIDGE_CHECK(Get_log),
        ["vlanId"] = BRIDGE_CHECK(Vlan.Get_VlanId),
        ["lastTimeLogTrimmed"] = BRIDGE_CHECK(Get_ScriptExecutionTime),
        ["monitor"] = _G.Monitor,
        ["firmwareVersion"] = BRIDGE_CHECK(System.Get_firmwareVersion),
        ["pra"] = _G.Prev_Read_Accepted
    }

    local requestBody = Json.encode(requestData)
    -- Add excluded fields for logging purposes
    requestData["log"] = nil
    requestData["monitor"] = nil
    -- I need to exclude the log field
    local RequestBody_forPrint = Json.encode(requestData)

    WriteLog(client .. "Write " .. RequestBody_forPrint)

    local res, code, headers, status = Http.request({
        method = "POST",
        url = config.url_write,
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    })

    local responseBody = table.concat(body)

    if code == 200 then
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            WriteLog(server .. "Write ERROR: " .. responseBody)
            return false
        else
            WriteLog(client .. "Receive " .. responseBody)
            return true
        end
    else
        WriteLog(server ..
            "Failed to post data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
        return false
    end
end

local SendHeartbeat = function()
    local body = {}
    local config = ReadConfig()

    local requestBody = Json.encode({
        ["mac"] = Mac.Get_mac(),
        ["success"] = true,
        ["uptime"] = Time.Get_uptime()
    })

    WriteLog(client .. "Heartbeat " .. requestBody)

    local res, code, headers, status = Http.request {
        method = "POST",
        url = config.url_heartbeat,
        source = Ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
        },
        sink = Ltn12.sink.table(body),
        protocol = "tlsv1_2"
    }

    local responseBody = table.concat(body)

    if code == 200 then
        -- Check for specific error conditions in the response body ( Odoo Server Error )
        if responseBody:find("Odoo Server Error") then
            -- Handle the server error condition here
            WriteLog(server .. "Heartbeat ERROR: " .. responseBody)
            return false
        else
            WriteLog(client .. "Receive " .. responseBody)
            -- return true, responseBody
            local responseJson = Json.decode(responseBody)
            local ctx_chnged = responseJson.result.context

            if ctx_chnged then
                _G.CONTEXT_CHANGED = true;
                WriteLog(client .. "Context Changed")
            end
        end
    else
        WriteLog(server ..
            "Failed to send heartbeat. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody)
        -- return false, responseBody
    end
end


function Odoo_Connector()
    local backoff_counter = 5
    local write_completed = false
    local read_completed = false
    local read_response = nil
    local reboot_required = false
    local first_time_writing = true
    local cycle_counter = 0
    local config = ReadConfig()

    -- Main program loop
    while true do
        WriteLog(bridge .. "CYCLE ------------{")
        -- SUBSCRIBE PHASE
        -- Keep trying to write ourselves into Odoo until successful
        if CONTEXT_CHANGED or first_time_writing then
            backoff_counter = 5
            first_time_writing = false
            repeat
                write_completed = BRIDGE_CHECK(Odoo_Write)
                if write_completed == false then
                    WriteLog(bridge .. "Write Backoff activated! Sleeping for " .. backoff_counter .. " seconds..")
                    luci.sys.call("echo 1 > /sys/class/leds/richerlink:green:system/brightness")
                    luci.sys.call("sleep " .. tostring(backoff_counter))
                    backoff_counter = backoff_counter + 2
                    if backoff_counter >= 36 then
                        reboot_required = true
                        WriteLog(bridge .. "Write Backoff reboot signal received...")
                        break
                    end
                end
            until write_completed
            luci.sys.call("echo 0 > /sys/class/leds/richerlink:green:system/brightness")
            write_completed = false
            CONTEXT_CHANGED = false
        end

        if reboot_required then
            break
        end


        luci.sys.call("sleep 15")

        if Ping(config.server_address) then
            SendHeartbeat()
        end

        -- Keep trying to read data from Odoo until successful
        if CONTEXT_CHANGED then
            backoff_counter = 5 -- Defensive counter against continous error cycles
            repeat
                read_completed, read_response = Odoo_Read()
                if read_completed == false then
                    WriteLog(bridge .. "Read Backoff activated! Sleeping for " .. backoff_counter .. " seconds..")
                    luci.sys.call("echo 1 > /sys/class/leds/richerlink:green:system/brightness")
                    luci.sys.call("sleep " .. tostring(backoff_counter))
                    backoff_counter = backoff_counter + 2
                    if backoff_counter >= 36 then
                        reboot_required = true
                        WriteLog(bridge .. "Read Backoff reboot signal received...")
                        break
                    end
                end
            until read_completed
            luci.sys.call("echo 0 > /sys/class/leds/richerlink:green:system/brightness")
        end

        if reboot_required then
            break
        end

        if CONTEXT_CHANGED then
            -- Parse the read values and execute necessary modifications
            local parse_results = BRIDGE_CHECK(Bridge_Parse, read_response)
            if Bridge_Execute(parse_results) then
                WriteLog(bridge .. "Reboot signal received from Parse()...")
                break -- Reboot signal received, break
            end
            read_completed = false
            WriteLog(bridge .. "CYCLE ------------}")
        end
    end

    WriteLog(bridge .. "Elevating Reboot signal to PIALB()")
    return true
end

return Odoo_Connector()
