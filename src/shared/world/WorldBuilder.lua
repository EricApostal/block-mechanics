--!strict

--[[
    Handles routing for blocks across the entire world, or client based on the context from which this file is being run.
]]

local WorldBuilder = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)
local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldData = require(script.Parent.WorldData)

-- Calculates correct chunk to place block into, then places via WorldData.
function WorldBuilder:AddBlock(block)
    -- "position" is already converted, thus there's no need to put it through blockmap.
    local chunk = block:getChunk()
    local chunkIndex = string.format("%s,%s", chunk.X, chunk.Y)

    -- Create chunk, it doesn't exist yet
    if (WorldData[chunkIndex] == nil) then
        print(string.format("Creating chunk %s", chunkIndex))
        WorldData[chunkIndex] = Chunk:new(chunk)
    end

    -- Add block to chunk index.
    WorldData[chunkIndex]:AddBlock(block)
end

-- Calculates target chunk containing block, then removes via WorldData.
function WorldBuilder:RemoveBlock(block)
    print(string.format("Removing block at %s", tostring(block.position)))
    WorldData[block:getChunkHash()] = nil
    if (game:GetService("RunService"):IsClient()) then
        local instance = workspace.blocks[block:getChunkHash()][block:getHash()]
        instance:Destroy()
    end
    local serializedBlock = block:serialize()
    Knit.GetService("BlockService"):RemoveBlock(serializedBlock)
end

function WorldBuilder:GetChunk(hash: string)
    local data = WorldData[hash]
    --[[
        If nil then call get chunk via knit (so we can handle both the client and the server).
    ]]
    if (data == nil) then
        print(string.format("Generating chunk %s", hash))
        -- GENERATE CHUNK HERE
    end
    return data
end

return WorldBuilder