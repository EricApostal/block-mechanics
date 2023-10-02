local ChunkReplicator = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockService = Knit.GetService("BlockService")
local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local WorldData = require(ReplicatedStorage.Common.world.WorldData)

-- Actually create the blocks from WorldData.
-- There should be a different function for chunks and individual blocks.
local function drawChunk(hash)
    for chunkHash, chunk in pairs(WorldData) do
        for blockHash, block in pairs(chunk.blocks) do
            local instance = ReplicatedStorage.blocks[block.texture]:Clone()
            instance.Name = blockHash
            instance.Position = block.position
            instance.Parent = workspace.blocks[chunkHash]
        end
    end
end

local function listener()
    BlockService.AddBlock:Connect(function(block)
        local blockInstance = Block:new(table.unpack(block))
        WorldBuilder:AddBlock(blockInstance)
        print("drawing changes!")
        drawChunks()
    end)
end

function ChunkReplicator:init()
    listener()
end

return ChunkReplicator