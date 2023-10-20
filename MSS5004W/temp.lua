json = require("json")

local requestBody = json.encode({
    ["name"] = "Name.Get_name()",
    ["x_site"] = "Site.Get_site()",
    -- ["x_device_update"] = false,
    -- ["x_update_date"] = Time.Get_updatetime(),  --> update time is now controlled through the web controller in Odoo server side
    ["x_uptime"] = "Time.Get_uptime()",
    ["x_channel"] = "Wireless.Get_wireless_channel()",
    ["x_mac"] = "Mac.Get_mac()",
    ["x_device_info"] = "Devices.Get_DevicesString()",
    ["x_ip"] = "LanIP.Get_Ip()",
    ["x_subnet"] = "Netmask.Get_netmask()",
    ["x_gateway"] = "Gateway.Get_gateway()",
    -- ["x_dhcp_server"] = Dhcp.Get_dhcp_server(),
    -- ["x_dhcp_client"] = Dhcp.Get_dhcp_client(),
    ["x_enable_wireless"] = "Wireless.Get_wireless_status()",
    ["x_ssid1"] = "Ssid.Get_ssid1()",
    ["x_passwd_1"] = "Ssid.Get_ssid1_passwd()",
    ["x_ssid2"] = "Ssid.Get_ssid2()",
    ["x_passwd_2"] = "Ssid.Get_ssid2_passwd()",
    ["x_ssid3"] = "Ssid.Get_ssid3()",
    ["x_passwd_3"] = "Ssid.Get_ssid3_passwd()",
    -- ["x_ssid4"] = Ssid.Get_ssid4(),
    -- ["x_passwd_4"] = Ssid.Get_ssid4_passwd(),
    ["x_enable_ssid1"] = "Ssid.Get_ssid1_status()",
    ["x_enable_ssid2"] = "Ssid.Get_ssid2_status()",
    ["x_enable_ssid3"] = "Ssid.Get_ssid3_status()",
    -- ["x_enable_ssid4"] = Ssid.Get_ssid4_status(),
    ["x_lostConnection"] = false,
    ["x_ram"] = "System.Get_ram()",
    ["x_cpu"] = "System.Get_cpu()",
    ["x_log"] = "System.Get_log()",
    ["x_vlanId"] = "Vlan.Get_VlanId()",
    ["x_logTrunkExecTime"] = "System.Get_ScriptExecutionTime()"
    -- ["x_manual_time"] = Time.Get_manualtime(),
    -- ["x_new_password"] = false,
    -- ["x_reboot"] = false,
    -- ["x_upgrade"] = false
})

print("Send " .. requestBody)
