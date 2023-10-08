--!native

local ChunkReplicator = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockService = Knit.GetService("BlockService")
local Block = require(ReplicatedStorage.Common.blocks.Block)
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)
local BlockMap = require(ReplicatedStorage.Common.BlockMap)
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local WorldData = require(ReplicatedStorage.Common.world.WorldData)

-- Get the number of blocks touching the specified block.
local function getTouchingBlocks(block): number
    local touchingBlocks = 0
    local modifiers = {
        ["Top"] = Vector3.new(0,1,0),
        ["Bottom"] = Vector3.new(0,-1,0),
        ["Left"] = Vector3.new(-1,0,0),
        ["Right"] = Vector3.new(1,0,0),
        ["Front"] = Vector3.new(0,0,-1),
        ["Back"] = Vector3.new(0,0,1)
    }
    for i, position in modifiers do
        local blockPosition = block.position + position
        local blockHash = BlockMap:toHash(blockPosition)
        local chunkHash = BlockMap:toHash( BlockMap:getChunk(BlockMap:VoxelToRBX(blockPosition)))

        if (WorldData[chunkHash] and WorldData[chunkHash].blocks[blockHash]) then
            touchingBlocks += 1
        end
    end
    return touchingBlocks
end

local function drawChunk(hash)
    local chunk = WorldData[hash]
    -- print(string.format("Drawing chunk %s", hash))
    for blockHash, block in pairs(chunk.blocks) do
        if (workspace.blocks:FindFirstChild(hash) and workspace.blocks[hash]:FindFirstChild(blockHash)) then
            continue
        end

        if (getTouchingBlocks(block) == 6) then
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
        -- print("Block already exists at specified location!")
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
        -- print(string.format("Removing block %s from chunk %s", block:getHash(), block:getChunkHash()))
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
    local radius = 2
    -- Every frame, check the radius around us, and if there are any chunks that need to be loaded, load them.
    while true do
        local chunkPosition = BlockMap:getChunk(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)
        local chunkHash = BlockMap:toHash(chunkPosition)

        -- Load the chunk we're in.
        if (not WorldData[chunkHash]) then
            loadChunk(chunkPosition.X, chunkPosition.Y)
        end

        -- Load the chunks around us.
        local proximityChunks = {}
        for x = -radius, radius do
            for y = -radius, radius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                proximityChunks[chunkHash] = true
                if (not WorldData[chunkHash]) then
                    loadChunk(chunkPosition.X + x, chunkPosition.Y + y)
                end
            end
        end

        for chunkHash, _ in pairs(WorldData) do
            if (not proximityChunks[chunkHash]) then
                -- print(string.format("Unloading chunk %s", chunkHash))
                WorldData[chunkHash] = nil
                workspace.blocks[chunkHash]:Destroy()
            end
        end

        task.wait(1)
    end
end

function ChunkReplicator:init()
    listener()
    task.spawn(chunkListener)
end

return ChunkReplicator