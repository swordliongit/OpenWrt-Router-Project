function Ping(address)
    require("luci.sys")
    return luci.sys.call("ping -c 1 " .. address) == 0
end
