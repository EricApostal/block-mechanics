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
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

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
    for _, position in modifiers do
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

    local lastBlockInstance = nil
    local iterations = 0
    for blockHash, block in pairs(chunk.blocks) do
        if (workspace.blocks:FindFirstChild(hash) and workspace.blocks[hash]:FindFirstChild(blockHash)) then
            continue
        end

        if (getTouchingBlocks(block) == 6) then
            continue
        end

        if (block.position.Y == 0) then
            continue
        end

        --[[
            TODO: Sort the blocks such that they are structured properly in rows / cols.
        ]]

        -- if (lastBlockInstance ~= nil) and (WorldData[hash].blocks[lastBlockInstance.Name].texture == block.texture) and ( (iterations % 16) ~= 0) then
        --     print("OPTIMIZED")
        --     lastBlockInstance.Size = lastBlockInstance.Size + Vector3.new(3,0,0)
        -- else
            local instance = ReplicatedStorage.blocks[block.texture]:Clone()
            instance.Name = blockHash
            instance.Position = BlockMap:VoxelToRBX(block.position)
            -- I don't know why this is nil *sometimes*, maybe a race condition?
            if workspace.blocks:FindFirstChild(hash) then
                instance.Parent = workspace.blocks[hash]
            end
            lastBlockInstance = instance
        -- end
        -- iterations += 1
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
        local blockInstance = workspace.blocks[block:getChunkHash()][block:getHash()]
        WorldData[block:getChunkHash()].blocks[block:getHash()] = nil
        blockInstance:Destroy()
        -- Now we need to look for the blocks around it and place if applicaple.
        local modifiers = {
            ["Top"] = Vector3.new(0,1,0),
            ["Bottom"] = Vector3.new(0,-1,0),
            ["Left"] = Vector3.new(-1,0,0),
            ["Right"] = Vector3.new(1,0,0),
            ["Front"] = Vector3.new(0,0,-1),
            ["Back"] = Vector3.new(0,0,1)
        }
        for _, position in modifiers do
            local blockPosition = block.position + position
            local blockHash = BlockMap:toHash(blockPosition)
            local chunkHash = BlockMap:toHash( BlockMap:getChunk(BlockMap:VoxelToRBX(blockPosition)))

            if (WorldData[chunkHash] and WorldData[chunkHash].blocks[blockHash]) then
                drawBlock(WorldData[chunkHash].blocks[blockHash])
            end
        end
    end)
end

local function loadChunk(x, y)
    local chunkHash = string.format("%s,%s", x,y)
    local chunk

    BlockService:GetChunk(Vector2.new(x,y)):andThen(function(chunkArray)
        chunk = Chunk:new(table.unpack(chunkArray))
        WorldData[chunkHash] = chunk
    end)

    -- Shit async -> sync
    while not chunk do task.wait() end

    return chunk
end

-- Create a listener to automatically send requests for chunks in a specified radius.
local function chunkListener()
    local radius = 1

    -- Every frame, check the radius around us, and if there are any chunks that need to be loaded, load them.
    while true do
        local chunkPosition = BlockMap:getChunk(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)

        -- Load the chunks around us.
        local proximityChunks = {}

        local toLoad = {}

        for x = -radius, radius do
            for y = -radius, radius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                proximityChunks[chunkHash] = true
                if ((not WorldData[chunkHash]) or (WorldData[chunkHash].isGenerated == false)) then
                    local chunk = loadChunk(chunkPosition.X + x, chunkPosition.Y + y)
                    toLoad[chunkHash] = chunk
                end
            end
        end

        for hash, chunk in pairs(toLoad) do
            task.spawn(function() drawChunk(chunk:getHash()) end)
            task.wait(0.1)
        end

        for chunkHash, _ in pairs(WorldData) do
            if (not proximityChunks[chunkHash]) then
                WorldData[chunkHash] = nil
                workspace.blocks[chunkHash]:Destroy()
                task.wait(0.1)
            end
        end

        task.wait(1)
    end
end

-- local function isPosVisible(pos): boolean
--     local _, OnScreen = workspace.CurrentCamera:WorldToScreenPoint(pos)

--     if OnScreen then
--         if #workspace.CurrentCamera:GetPartsObscuringTarget({workspace.CurrentCamera.CFrame.Position, pos}, {}) == 0 then
--             return true
--         end
--     end
--     return false
-- end

-- local function initViewportBlockCheck()
--     RunService.Heartbeat:Connect(function(deltaTime)
--         for _, chunk in WorldData do
--             for _, block in chunk.blocks do
--                 local chunkHash = chunk:getHash()
--                 local blockInstance = workspace.blocks[chunkHash]:FindFirstChild(block:getHash())
--                 if not blockInstance and isPosVisible(block.position) then
--                     drawBlock(block)
--                 end

--                 if blockInstance and not isPosVisible(blockInstance.Position) then
--                     blockInstance:Destroy()
--                 end
--             end
--         end
--     end)
-- end

function ChunkReplicator:init()
    listener()
    -- initViewportBlockCheck()
    task.spawn(chunkListener)
end

return ChunkReplicator