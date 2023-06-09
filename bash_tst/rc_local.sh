# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

exec > /tmp/script.log 2>&1
echo "Log start" >> /tmp/tracker

# to check if packages were installed
FLAG_FILE="/etc/flag_packages_installed"
# To check internet
PING_IP="8.8.8.8"
echo "Before killing the current udhcpc" >> /tmp/tracker
# kill the current udhcpc
pid=$(pgrep -f "udhcpc -t 0 -i br-lan -b -p /var/run/dhcp-br-lan.pid")
pid2=$(pgrep -f "udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &")
if [ -n "$pid" ]; then
    kill "$pid"
fi
if [ -n "$pid2" ]; then
    kill "$pid2"
fi
echo "After killing the current udhcpc" >> /tmp/tracker
# dhcp client check block, we have to start the dhcp client if there are no static ips set
dhcp_client_on=$(lua /etc/project_odoo/dhcp_check.lua)
echo "$dhcp_client_on" >> /tmp/tracker
has_internet="false"
gateway=""
if [ "$dhcp_client_on" = "true" ]; then

    while [ "$has_internet" != "true" ]; do
        # start our own udhcpc process
        udhcpc -p /var/run/udhcpc-br-lan.pid -s /usr/share/udhcpc/default.script -f -t 0 -i br-lan -x hostname:MSS5004W-OpenWrt -C -R -O staticroutes &>/dev/null &
        sleep 1
        if ping -c 1 "$PING_IP" >/dev/null 2>&1; then
            has_internet="true"
        fi
    done
else
    gateway=$(cat /etc/project_odoo/gateway_for_static | awk -F ':' '{print $2}')
    ip route replace default via $gateway
    # ip and netmask had already been saved to configs by the Odoo_Connector()
fi
echo "$has_internet before ping" >> /tmp/tracker
echo "$gateway" >> /tmp/tracker

if ping -c 1 "$PING_IP" >/dev/null 2>&1; then
    has_internet="true"
fi

echo "$has_internet after ping" >> /tmp/tracker
# Check if the script has executed before and if the device has internet
if [ "$has_internet" = "true" ]; then
    if [ -f "$FLAG_FILE" ]; then
        echo "before lua init - flag on" >> /tmp/tracker
        lua /etc/project_odoo/odoo_bridge.lua
    else
        # Download package to /tmp
        wget -P /tmp http://81.0.124.218/attitude_adjustment/12.09/ramips/rt305x/packages/luasocket_2.0.2-3_ramips.ipk
        wget -P /tmp http://81.0.124.218/chaos_calmer/15.05.1/ramips/rt288x/packages/packages/json4lua_0.9.53-1_ramips.ipk

        # Install the downloaded packages
        opkg install /tmp/luasocket_2.0.2-3_ramips.ipk
        opkg install /tmp/json4lua_0.9.53-1_ramips.ipk

        rm -r /tmp/luasocket_2.0.2-3_ramips.ipk
        rm -r /tmp/json4lua_0.9.53-1_ramips.ipk

        # Create flag file to indicate script has executed
        touch "$FLAG_FILE"
        echo "before lua init - flag off" >> /tmp/tracker
        lua /etc/project_odoo/odoo_bridge.lua
    fi
fi

exit 0