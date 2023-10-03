local Odoo_write = function()
    local body = {}

    local requestBody = json.encode({
        ["name"] = "artinmodem",
        ["x_site"] = Site.Get_site(),
        -- ["x_device_update"] = false,
        ["x_update_date"] = Time.Get_updatetime(),
        ["x_uptime"] = Time.Get_uptime(),
        ["x_channel"] = Wireless.Get_wireless_channel(),
        ["x_mac"] = Mac.Get_mac(),
        ["x_device_info"] = Devices.Get_DevicesString(),
        ["x_ip"] = LanIP.Get_Ip(),
        ["x_subnet"] = Netmask.Get_netmask(),
        ["x_gateway"] = Gateway.Get_gateway(),
        -- ["x_dhcp_server"] = Dhcp.Get_dhcp_server(),
        -- ["x_dhcp_client"] = Dhcp.Get_dhcp_client(),
        ["x_enable_wireless"] = Wireless.Get_wireless_status(),
        ["x_ssid1"] = Ssid.Get_ssid1(),
        ["x_passwd_1"] = Ssid.Get_ssid1_passwd(),
        ["x_ssid2"] = Ssid.Get_ssid2(),
        ["x_passwd_2"] = Ssid.Get_ssid2_passwd(),
        ["x_ssid3"] = Ssid.Get_ssid3(),
        ["x_passwd_3"] = Ssid.Get_ssid3_passwd(),
        ["x_ssid4"] = Ssid.Get_ssid4(),
        ["x_passwd_4"] = Ssid.Get_ssid4_passwd(),
        ["x_enable_ssid1"] = Ssid.Get_ssid1_status(),
        ["x_enable_ssid2"] = Ssid.Get_ssid2_status(),
        ["x_enable_ssid3"] = Ssid.Get_ssid3_status(),
        ["x_enable_ssid4"] = Ssid.Get_ssid4_status(),
        -- ["x_manual_time"] = Time.Get_manualtime(),
        -- ["x_new_password"] = false,
        -- ["x_reboot"] = false,
        -- ["x_upgrade"] = false
    })

    local res, code, headers, status = http.request({
        method = "POST",
        url = "http://89.252.165.116:8069/create/create_or_update_record",
        source = ltn12.source.string(requestBody),
        headers = {
            ["content-type"] = "application/json",
            ["content-length"] = tostring(#requestBody),
            ["Cookie"] = _G.cookie
        },
        sink = ltn12.sink.table(body),
        protocol = "tlsv1_2"
    })

    local responseBody = table.concat(body)

    if code == 200 then
        io.write(responseBody .. "\n\n")
        return true
    else
        io.write("Failed to post data. HTTP code: " .. tostring(code) .. "\nResponse body:\n" .. responseBody .. "\n\n")
        return false
    end
end
