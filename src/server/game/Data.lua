local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockHandler = require(script.Parent.BlockHandler)

local cachedWorldData = {} -- rip performance

function Data:LoadChunk(player, chunkKey)
    local BlockService = Knit.GetService("BlockService")
    -- Hopefully I can make the type of chunkKey a vector2
    for key, chunkData in cachedWorldData do
        if key == chunkKey then
            -- chunk already loaded, just return
            return chunkData
        end
    end
    -- if the codepath gets here, then we need to gen the chunk
    local chunk = BlockService:LoadChunk(player, chunkKey)
    cachedWorldData[chunkKey] = chunk
    return chunk
end

function Data:init()
end

return Data