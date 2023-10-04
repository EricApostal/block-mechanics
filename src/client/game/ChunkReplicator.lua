local ChunkReplicator = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockService = Knit.GetService("BlockService")
local Block = require(ReplicatedStorage.Common.blocks.Block)
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)
local BlockMap = require(ReplicatedStorage.Common.BlockMap)
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local WorldData = require(ReplicatedStorage.Common.world.WorldData)

-- Actually create the blocks from WorldData.
-- There should be a different function for chunks and individual blocks.
local function drawChunk(hash)
    local chunk = WorldData[hash]
    print(string.format("Drawing chunk %s", hash))
    for blockHash, block in pairs(chunk.blocks) do
        if (workspace.blocks:FindFirstChild(hash) and workspace.blocks[hash]:FindFirstChild(blockHash)) then
            continue
        end

        local instance = ReplicatedStorage.blocks[block.texture]:Clone()
        instance.Name = blockHash
        instance.Position = BlockMap:VoxelToRBX(block.position)
        instance.Parent = workspace.blocks[hash]
    end
end

local function drawBlock(block)
    local chunkHash = block:getChunkHash()
    if (workspace.blocks[chunkHash]:FindFirstChild(block:getHash())) then
        print("Block already exists at specified location!")
        return
    end

    local instance = ReplicatedStorage.blocks[block.texture]:Clone()
    instance.Name = block:getHash()
    instance.Position = BlockMap:VoxelToRBX(block.position)
    instance.Parent = workspace.blocks[chunkHash]
end


-- Create a listener for all block events.
local function listener()
    BlockService.onBlockAdded:Connect(function(blockArray)
        local block = Block:new(table.unpack(blockArray))
        WorldBuilder:AddBlock(block)
        drawBlock(block)
    end)

    BlockService.onBlockRemoved:Connect(function(blockArray)
        local block = Block:new(table.unpack(blockArray))
        print(string.format("Removing block %s from chunk %s", block:getHash(), block:getChunkHash()))
        local blockInstance = workspace.blocks[block:getChunkHash()][block:getHash()]
        blockInstance:Destroy()
    end)
end

local function loadChunk(x, y)
    local chunkHash = string.format("%s,%s", x,y)
    BlockService:GetChunk(Vector2.new(x,y)):andThen(function(chunkArray)
        local chunk = Chunk:new(table.unpack(chunkArray))
        WorldData[chunkHash] = chunk
        drawChunk(chunkHash)
    end)
end

-- Create a listener to automatically send requests for chunks in a specified radius.
local function chunkListener()
    loadChunk(0, 0)
end

function ChunkReplicator:init()
    listener()
    task.spawn(chunkListener)
end

return ChunkReplicator