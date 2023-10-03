--[[
    Daily logs:
    If device reboots, it hangs on the udhcpc command on br-lan, not getting any ip

]]

--[[
    DEFINITIONS
]]
-- Set output log file
local logFile = io.open("/tmp/script.log", "w")
io.output(logFile)

-- Check if packages were installed
local flagFile = "/etc/flag_packages_installed"

-- Check internet
local pingIP = "8.8.8.8"

-- Function to check if DHCP client should be started
local function shouldStartDhcpClient()
    local dhcpClientOn = dofile("/etc/project_odoo/dhcp_check.lua")
    return dhcpClientOn == true
end

local function hasInternet()
    return os.execute("ping -c 1 " .. pingIP .. " >/dev/null 2>&1") == 0
end

local function startUdhcpc()
    os.execute(
        "udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &")
    os.execute("sleep 1")
end

local function dhcpOn()
    local uci = require("uci")
    local cursor = uci.cursor()
    local dhcp = cursor:get("network", "lan", "proto")
    return dhcp == "dhcp" and true or false
end

-- Kill the current udhcpc processes
local function killUdhcpc(processPattern)
    local handle = io.popen("pgrep -f '" .. processPattern .. "'")
    local pid = handle:read("*a")
    handle:close()

    if pid and pid ~= "" then
        os.execute("kill " .. pid)
    end
end

local function clearIpOnBridge()
    local uci = require("uci")
    local cursor = uci.cursor()
    cursor:delete("network", "lan", "ipaddr")
    cursor:delete("network", "lan", "netmask")
    cursor:commit("network")
end

local function executeAndWait(command)
    local handle = io.popen(command)
    local output = handle:read("*all")
    handle:close()
    return output
end


--[[
    EXECUTION START
]]
io.write("Log start\n")
io.write("Before killing the current udhcpc\n")

killUdhcpc("udhcpc -t 0 -i br-lan -b -p /var/run/dhcp-br-lan.pid")
killUdhcpc(
    "udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &")
io.write("After killing the current udhcpc\n")

if dhcpOn() then
    clearIpOnBridge()
    io.write("DHCPC IP cleared\n")
end
os.execute("ifup lan")

io.write("Before ping loop\n")
while not hasInternet() do
    startUdhcpc()
    os.execute("sleep 1")
    io.write("Tried to get ip\n")
end
io.write("Connection Established using UDHCPC\n")

if hasInternet() then
    local flagExists = io.open(flagFile) ~= nil
    if flagExists then
        io.write("before lua init - flag on\n")
        executeAndWait("/etc/init.d/network restart")
        os.execute(
            "udhcpc -p /var/run/udhcpc-eth1_0.pid -s /usr/share/udhcpc/default.script -f -t 0 -i eth1_0 -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &")
        os.execute("sleep 1")
        -- Execute odoo_bridge.lua and capture errors to script.log
        local success, error_message = pcall(dofile, "/etc/project_odoo/odoo_bridge.lua")

        -- Log any error messages
        if not success then
            local logFile = io.open("/tmp/script.log", "a")
            io.output(logFile)
            io.write("Error in odoo_bridge.lua: " .. error_message .. "\n")
            io.close(logFile)
        end
    else
        os.execute(
            "wget -P /tmp http://81.0.124.218/attitude_adjustment/12.09/ramips/rt305x/packages/luasocket_2.0.2-3_ramips.ipk")
        os.execute(
            "wget -P /tmp http://81.0.124.218/chaos_calmer/15.05.1/ramips/rt288x/packages/packages/json4lua_0.9.53-1_ramips.ipk")
        os.execute(
            "wget -P /tmp http://81.0.124.218/attitude_adjustment/12.09/ramips/rt305x/packages/luafilesystem_1.5.0-1_ramips.ipk")

        os.execute("opkg install /tmp/luasocket_2.0.2-3_ramips.ipk")
        os.execute("opkg install /tmp/json4lua_0.9.53-1_ramips.ipk")
        os.execute("opkg install /tmp/luafilesystem_1.5.0-1_ramips.ipk")

        os.remove("/tmp/luasocket_2.0.2-3_ramips.ipk")
        os.remove("/tmp/json4lua_0.9.53-1_ramips.ipk")
        os.remove("/tmp/luafilesystem_1.5.0-1_ramips.ipk")

        io.open(flagFile, "w"):close()
        io.write("before lua init - flag off\n")

        executeAndWait("/etc/init.d/network restart")
        os.execute(
            "udhcpc -p /var/run/udhcpc-eth1_0.pid -s /usr/share/udhcpc/default.script -f -t 0 -i eth1_0 -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &")
        os.execute("sleep 1")
        -- Execute odoo_bridge.lua and capture errors to script.log
        local success, error_message = pcall(dofile, "/etc/project_odoo/odoo_bridge.lua")

        -- Log any error messages
        if not success then
            local logFile = io.open("/tmp/script.log", "a")
            io.output(logFile)
            io.write("Error in odoo_bridge.lua: " .. error_message .. "\n")
            io.close(logFile)
        end
    end
end

io.close(logFile)
