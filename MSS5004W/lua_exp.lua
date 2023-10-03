function Get_Subnet_Mask()
    local handle = io.popen("ifconfig br-lan")
    local subnetMask = nil

    if handle then
        for line in handle:lines() do
            subnetMask = line:match("Mask:(%d+%.%d+%.%d+%.%d+)")
            if subnetMask then
                break
            end
        end

        handle:close()
    end

    return subnetMask
end



print(Get_Subnet_Mask())