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
    WorldData[chunkIndex].blocks[block:getHash()] = block
end

-- Calculates target chunk containing block, then removes via WorldData.
function WorldBuilder:RemoveBlock(block)
    WorldData[block:getChunkHash()] = nil
    if (game:GetService("RunService"):IsClient()) then
        local instance = workspace.blocks[block:getChunkHash()][block:getHash()]
        instance:Destroy()
    end
end

function WorldBuilder:GetChunk(position: Vector2)
    print("GETTING CHUNKS")

    -- Get hash and look for it in WorldData.
    local hash = string.format("%s,%s", position.X, position.Y)
    local data = WorldData[hash]

    -- If nil then call get chunk via knit (so we can handle both the client and the server).
    if (data == nil) then
        print(string.format("Generating chunk %s", hash))
        -- Call knit to generate, which will run in WorldGen, then return.

    end
    return data
end

return WorldBuilder