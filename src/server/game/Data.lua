local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockHandler = require(script.Parent.BlockHandler)

local cachedWorldData = {} -- rip performance

function Data:LoadChunk(player, chunkKey)
    -- local BlockService = Knit.GetService("BlockService")
    -- Hopefully I can make the type of chunkKey a vector2
    for key, chunkData in cachedWorldData do
        if key == chunkKey then
            -- chunk already loaded, just return
            return chunkData
        end
    end
    -- if the codepath gets here, then we need to gen the chunk
    local chunk = BlockHandler:buildChunk(chunkKey.X, chunkKey.Y)
    cachedWorldData[chunkKey] = chunk
    return chunk
end

--[[
IDEA
When working on updating the chunk for everyone, fire the clients with the updated changes,
but do another check (like the chunk update) to see what blocks actually need to be re-rendered
]]

function Data:SetChunk(player, chunkKey, chunkData)
    cachedWorldData[chunkKey] = chunkData -- I should verify it's in the array... maybe it's fine
end

function Data:init()
end

return Data