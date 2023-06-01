local network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockHandler = require(script.Parent.BlockHandler)
local Data = require(script.Parent.Data)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        UpdateChunk = Knit.CreateSignal(), -- Create the signal
        removeBlock = Knit.CreateSignal(),
        addBlock = Knit.CreateSignal()
    },
}

local function registerFunctions()
    function BlockService:BreakBlock(player, position)
        Data:removeBlock(player, position)
    end

    function BlockService:PlaceBlock(player, position, material)
        Data:addBlock(player, position, material)
    end
    
    function BlockService:LoadChunk(player, chunk_vec)
        return Data:LoadChunk(player, chunk_vec) -- BlockHandler:buildChunk(chunk_vec.X, chunk_vec.Y)
    end

    --[[
        Client Functions :D

        Because of the way knit is structured it's ideal for handling bad or malicious requests
    ]]

    function BlockService.Client:SetChunk(player, chunkVec, chunkData)
        Data:SetChunk(player, chunkVec, chunkData)
    end

    function BlockService.Client:BreakBlock(player, block)
        if not block then return end
        BlockService:BreakBlock(player, block)
    end

    function BlockService.Client:PlaceBlock(player, position, material)
        BlockService:PlaceBlock(player, position, material)
    end

    function BlockService.Client:LoadChunk(player, chunk_vec)
        return BlockService:LoadChunk(player, chunk_vec)
    end

end

function network:init() 
    registerFunctions()
end

return network