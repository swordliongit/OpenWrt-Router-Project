--[[
Author: Kılıçarslan SIMSIKI

Date Created: 20-05-2023
Date Modified: 23-05-2023

Description:
All modification and duplication of this software is forbidden and licensed under Apache.
]]


Time = {}

function Time.Get_updatetime()
    local http = require("socket.http")
    local json = require("json")
    local url = "http://213.188.196.246/api/timezone/Europe/Istanbul"

    local response, status, headers = http.request(url)
    if status == 200 then
        local time_data = json.decode(response)
        local timestamp = time_data.datetime

        -- Extract date and time components
        local year, month, day, hour, min, sec = string.match(timestamp, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
        
        -- Format the date and time
        local formatted_time = string.format("%s-%s-%s %s:%s:%s", day, month, year, hour, min, sec)
        
        return formatted_time
    else
        return "Failed to retrieve current time"
    end
end

-- function Time.Get_manualtime()
--     return os.date("%Y-%m-%d %H:%M:%S")
-- end

-- function Time.Set_manualtime(time)
--     local command = string.format("date -s '%s'", time)
--     os.execute(command)
-- end

function Time.Get_uptime()

    local luci_sys = require("luci.sys")

    local seconds = luci_sys.uptime()
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = seconds % 60
    
    local uptimeString = ""
    
    if hours > 0 then
        uptimeString = uptimeString .. hours .. "h "
    end
    
    if minutes > 0 then
        uptimeString = uptimeString .. minutes .. "m "
    end
    
    uptimeString = uptimeString .. remainingSeconds .. "s"
    
    return uptimeString
end