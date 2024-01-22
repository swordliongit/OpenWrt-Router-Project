--[[
Author: Kılıçarslan SIMSIKI

Date Created: 20-05-2023
Date Modified: 24-11-2023

Description:
All modification and duplication of this software is forbidden and licensed under Apache.
]]


local uci = require("uci")


Ssid = {}
local cursor = uci.cursor()

-- SSID1
function Ssid.Get_ssid1()
    local ssid1 = cursor:get("wireless", "ra0", "ssid")
    return ssid1
end

function Ssid.Set_ssid1(ssid1)
    cursor:set("wireless", "ra0", "ssid", ssid1)
    cursor:commit("wireless")
end

function Ssid.Get_ssid1_status()
    local ssid1_status = cursor:get("wireless", "ra0", "enabled")
    return ssid1_status == "1" and true or false
end

function Ssid.Set_ssid1_status(ssid1_status)
    cursor:set("wireless", "ra0", "enabled", ssid1_status)
    -- cursor:set("wireless", "ra0", "hidden", "0")
    cursor:commit("wireless")
end

function Ssid.Set_ssid1_passwd(ssid1_passwd)
    if ssid1_passwd == false then
        cursor:set("wireless", "ra0", "securityMode", "NONE")
    else
        cursor:set("wireless", "ra0", "securityMode", "WPAPSK")
        cursor:set("wireless", "ra0", "wpapsk", ssid1_passwd)
    end
    cursor:commit("wireless")
end

function Ssid.Get_ssid1_passwd()
    local passwd1 = nil
    if cursor:get("wireless", "ra0", "securityMode") == "NONE" then
        passwd1 = false
    else
        passwd1 = cursor:get("wireless", "ra0", "wpapsk")
    end
    return passwd1
end

-- SSID2
function Ssid.Get_ssid2()
    local ssid2 = cursor:get("wireless", "ra1", "ssid")
    return ssid2
end

function Ssid.Set_ssid2(ssid2)
    cursor:set("wireless", "ra1", "ssid", ssid2)
    cursor:commit("wireless")
end

function Ssid.Get_ssid2_status()
    local ssid2_status = cursor:get("wireless", "ra1", "enabled")
    return ssid2_status == "1" and true or false
end

function Ssid.Set_ssid2_status(ssid2_status)
    cursor:set("wireless", "ra1", "enabled", ssid2_status)
    -- cursor:set("wireless", "ra1", "hidden", "0")
    cursor:commit("wireless")
end

function Ssid.Set_ssid2_passwd(ssid2_passwd)
    if ssid2_passwd == false then
        cursor:set("wireless", "ra1", "securityMode", "NONE")
    else
        cursor:set("wireless", "ra1", "securityMode", "WPAPSK")
        cursor:set("wireless", "ra1", "wpapsk", ssid2_passwd)
    end
end

function Ssid.Get_ssid2_passwd()
    local passwd2 = nil
    if cursor:get("wireless", "ra1", "securityMode") == "NONE" then
        passwd2 = false
    else
        passwd2 = cursor:get("wireless", "ra1", "wpapsk")
    end
    return passwd2
end

-- SSID3
function Ssid.Get_ssid3()
    local ssid3 = cursor:get("wireless", "ra2", "ssid")
    return ssid3
end

function Ssid.Set_ssid3(ssid3)
    cursor:set("wireless", "ra2", "ssid", ssid3)
    cursor:commit("wireless")
end

function Ssid.Get_ssid3_status()
    local ssid3_status = cursor:get("wireless", "ra2", "enabled")
    return ssid3_status == "1" and true or false
end

function Ssid.Set_ssid3_status(ssid3_status)
    cursor:set("wireless", "ra2", "enabled", ssid3_status)
    -- cursor:set("wireless", "ra2", "hidden", "0")
    cursor:commit("wireless")
end

function Ssid.Set_ssid3_passwd(ssid3_passwd)
    if ssid3_passwd == false then
        cursor:set("wireless", "ra2", "securityMode", "NONE")
    else
        cursor:set("wireless", "ra2", "securityMode", "WPAPSK")
        cursor:set("wireless", "ra2", "wpapsk", ssid3_passwd)
    end
end

function Ssid.Get_ssid3_passwd()
    local passwd3 = nil
    if cursor:get("wireless", "ra2", "securityMode") == "NONE" then
        passwd3 = false
    else
        passwd3 = cursor:get("wireless", "ra2", "wpapsk")
    end
    return passwd3
end

-- SSID4
function Ssid.Get_ssid4()
    local ssid4 = cursor:get("wireless", "ra3", "ssid")
    return ssid4
end

function Ssid.Set_ssid4(ssid4)
    cursor:set("wireless", "ra3", "ssid", ssid4)
    cursor:commit("wireless")
end

function Ssid.Get_ssid4_status()
    local ssid4_status = cursor:get("wireless", "ra3", "enabled")
    return ssid4_status == "1" and true or false
end

function Ssid.Set_ssid4_status(ssid4_status)
    cursor:set("wireless", "ra3", "enabled", ssid4_status)
    -- cursor:set("wireless", "ra3", "hidden", "0")
    cursor:commit("wireless")
end

function Ssid.Set_ssid4_passwd(ssid4_passwd)
    if ssid4_passwd == false then
        cursor:set("wireless", "ra3", "securityMode", "NONE")
    else
        cursor:set("wireless", "ra3", "securityMode", "WPAPSK")
        cursor:set("wireless", "ra3", "wpapsk", ssid4_passwd)
    end
end

function Ssid.Get_ssid4_passwd()
    local passwd4 = nil
    if cursor:get("wireless", "ra3", "securityMode") == "NONE" then
        passwd4 = false
    else
        passwd4 = cursor:get("wireless", "ra3", "wpapsk")
    end
    return passwd4
end
