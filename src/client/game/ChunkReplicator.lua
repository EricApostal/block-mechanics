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
    print("chunk: ")
    print(chunk)
    for blockHash, block in pairs(chunk.blocks) do
        if (workspace.blocks:FindFirstChild(hash) and workspace.blocks[hash]:FindFirstChild(blockHash)) then
            continue
        end
        print("drawing block: ")
        print(block)
        print(block.texture)
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
        local blockInstance = workspace.blocks[block:getChunkHash()][block:getHash()]
        blockInstance:Destroy()
    end)
end

-- Create a listener to automatically send requests for chunks in a specified radius.
local function chunkListener()
    for x = -2,2 do
        for y = -2,2 do
            local chunkHash = string.format("%s,%s", x, y)
            BlockService:GetChunk(Vector2.new(x,y)):andThen(function(chunkArray)
                local chunk = Chunk:new(table.unpack(chunkArray))
                print("got chunk from promise!")
                print(chunkArray)
                WorldData[chunkHash] = chunk
                drawChunk(chunkHash)
            end)
            -- drawChunk(chunkHash)
        end
    end
end

function ChunkReplicator:init()
    listener()
    task.spawn(chunkListener)
end

return ChunkReplicator