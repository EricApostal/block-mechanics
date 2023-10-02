--!strict

--[[
    Handles routing for blocks across the entire world, or client based on the context from which this file is being run.
]]

local WorldBuilder = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)
local WorldData = require(script.Parent.WorldData)

-- Calculates correct chunk to place block into, then places via WorldData.
function WorldBuilder:AddBlock(block)
    -- "position" is already converted, thus there's no need to put it through blockmap.
    local chunk = Vector2.new(math.floor(block.position.X/16), math.floor(block.position.Y/16))
    local chunkIndex = string.format("%s,%s", chunk.X, chunk.Y)

    -- Create chunk, it doesn't exist yet
    if (WorldData[chunkIndex] == nil) then
        print("chunk doesn't exist yet, creating...")
        WorldData[chunkIndex] = Chunk:new(chunk)
    end

    -- Add block to chunk index.
    WorldData[chunkIndex]:AddBlock(block)
end

-- Calculates target chunk containing block, then removes via WorldData.
function WorldBuilder:RemoveBlock(block)

end

function WorldBuilder:GetChunk(hash: string)
    local data = WorldData[hash]
    if (data == nil) then
        print(string.format("Generating chunk %s", hash))
        -- GENERATE CHUNK HERE
    end
    return data
end

return WorldBuilder