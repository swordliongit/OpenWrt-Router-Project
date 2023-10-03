--[[
Author: Kılıçarslan SIMSIKI

Date Created: 20-05-2023
Date Modified: 23-05-2023

Description:
All modification and duplication of this software is forbidden and licensed under Apache.
]]


local uci = require("uci")

LanIP = {}
local cursor = uci.cursor()

function LanIP.Get_Ip()
    -- local handle = io.popen("ip addr show dev br-lan")
    -- if handle then
    --     local output = handle:read("*a")
    --     handle:close()
    --     local ip = output:match("inet (%d+%.%d+%.%d+%.%d+)")
    --     return ip
    -- end
    local ip = cursor:get("network", "lan", "ipaddr")
    return ip
end

-- Function to add IP from eth1_0 to br-lan
function LanIP.AddIpToBridge()
    local handle = io.popen("ifconfig eth1_0")
    local output = handle:read("*a")
    handle:close()

    local eth1_0_ip = output:match("inet addr:([%d%.]+)")
    local eth1_0_netmask = output:match("Mask:([%d%.]+)")

    if eth1_0_ip and eth1_0_netmask then
        local cursor = uci.cursor()

        -- Set the IP details for br-lan
        cursor:set("network", "lan", "ipaddr", eth1_0_ip)
        cursor:set("network", "lan", "netmask", eth1_0_netmask)

        -- Commit the changes
        cursor:commit("network")
    else
        print("Failed to retrieve IP address or netmask from eth1_0")
    end
end

function LanIP.Set_Ip(ip)
    cursor:set("network", "lan", "ipaddr", ip)
    cursor:commit("network")
end
