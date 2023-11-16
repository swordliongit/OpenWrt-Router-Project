function StartUdhcpc()
    dofile("/etc/project_master_modem/src/vlan.lua")
    dofile("/etc/project_master_modem/src/mac.lua")
    local vlanId = Vlan.Get_VlanId()
    print("Vlan id: " .. vlanId)

    local udhcpcCommand
    if vlanId == "1" then
        print("Trying UDHCPC on br-lan...")
        udhcpcCommand =
            "udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-" ..
            Mac.Get_mac() .. " -C -R -O staticroutes &>/dev/null &"
    else
        print("Trying UDHCPC on eth1_0...")
        udhcpcCommand =
            "udhcpc -p /var/run/udhcpc-eth1_0.pid -s /usr/share/udhcpc/default.script -f -t 0 -i eth1_0 -x hostname:MSS5004W-" ..
            Mac.Get_mac() .. "-C -R -O staticroutes &>/dev/null &"
    end

    -- Capture the output of the command
    local handle = io.popen(udhcpcCommand)
    local result = handle:read("*a")
    handle:close()
    os.execute("sleep 2")
end

StartUdhcpc()


udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes