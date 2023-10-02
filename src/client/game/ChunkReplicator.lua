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
    local chunk = WorldData[hash]
    for blockHash, block in pairs(chunk.blocks) do
        local instance = ReplicatedStorage.blocks[block.texture]:Clone()
        instance.Name = blockHash
        instance.Position = block.position
        instance.Parent = workspace.blocks[hash]
    end
end

local function listener()
    BlockService.onBlockAdded:Connect(function(blockArray)
        local block = Block:new(table.unpack(blockArray))
        WorldBuilder:AddBlock(block)
        print(string.format("Placing block at %s", tostring(block.position)))
        drawChunk(block:getChunkHash())
    end)
    BlockService.onBlockRemoved:Connect(function(blockArray)
        print("do block removal thing")
    end)
end

function ChunkReplicator:init()
    listener()
end

return ChunkReplicator