local network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockHandler = require(script.Parent.BlockHandler)

local BlockService = Knit.CreateService {
    Name = "BlockService",
}

local function registerFunctions()
    function network:SetBlock(player, position, type)
        BlockHandler:placeBlock(position, "oak_log")
    end

    function network:BreakBlock(player, block)
        BlockHandler:breakBlock(block)
    end
    
    --[[
        Client Functions :D

        Because of the way knit is structured it's ideal for handling bad or malicious requests
    ]]

    function BlockService.Client:SetBlock(player, position, type)
        network:SetBlock(player, position, type)
    end

    function BlockService.Client:BreakBlock(player, block)
        if not block then return end
        network:BreakBlock(player, block)
    end

end

function network:init() 
    registerFunctions()
end

return network