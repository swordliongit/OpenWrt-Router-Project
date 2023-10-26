Vlan = {}
uci = require("uci")

function Vlan.Set_VlanId(vlanId)
    local filename = "/etc/config/network"
    local file = io.open(filename, "r")
    if not file then
        return false, "Failed to open network configuration file"
    end

    local lines = {}
    for line in file:lines() do
        -- Modify the 'ifname' line to set the VLAN ID
        if line:match("option%s+'ifname'") then
            line = line:gsub("eth1_0.%d+", "eth1_0." .. vlanId)
        end
        table.insert(lines, line)
    end
    file:close()

    local newFile = io.open(filename, "w")
    if not newFile then
        return false, "Failed to open network configuration file for writing"
    end

    for _, line in ipairs(lines) do
        newFile:write(line, "\n")
    end

    newFile:close()
    return true
end

Vlan.Set_VlanId("20")
