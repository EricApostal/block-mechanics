local network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockHandler = require(script.Parent.BlockHandler)

local BlockService = Knit.CreateService {
    Name = "BlockService",
}

local function registerFunctions()
    function BlockService:SetBlock(player, position, type)
        BlockHandler:placeBlock(position, "oak_log")
    end

    function BlockService:BreakBlock(player, block)
        BlockHandler:breakBlock(block)
    end

    function BlockService:LoadChunks(player, chunk_array)
        return BlockHandler:buildChunks(chunk_array)
    end
    
    function BlockService:LoadChunk(player, chunk_vec)
        local data = BlockHandler:buildChunk(chunk_vec.X, chunk_vec.Y)
        return data
    end

    --[[
        Client Functions :D

        Because of the way knit is structured it's ideal for handling bad or malicious requests
    ]]

    function BlockService.Client:SetBlock(player, position, type)
        BlockService:SetBlock(player, position, type)
    end

    function BlockService.Client:BreakBlock(player, block)
        if not block then return end
        BlockService:BreakBlock(player, block)
    end

    function BlockService.Client:LoadChunks(player, chunk_array)
        return BlockService:LoadChunks(player, chunk_array)
    end

    function BlockService.Client:LoadChunk(player, chunk_vec)
        return BlockService:LoadChunk(player, chunk_vec)
    end

end

function network:init() 
    registerFunctions()
end

return network