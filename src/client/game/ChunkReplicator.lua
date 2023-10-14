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

    local function getChunkWithOptimizedBlocks(chunk): table
        local parsedBlocks = {}
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

            table.insert(parsedBlocks, block)
        end
        return parsedBlocks
    end
    

    local optimized = getChunkWithOptimizedBlocks(chunk)

    -- sort optimized such that the blocks are in rows / cols
    -- table.sort(optimized, function(a, b)
    --     return a.position.X < b.position.X or (a.position.X == b.position.X and a.position.Y < b.position.Y) or (a.position.X == b.position.X and a.position.Y == b.position.Y and a.position.Z < b.position.Z)
    -- end)

    local cacheInstances = {}
    local cachePositions = {}

    while #workspace.blockCache:GetChildren() < #optimized do
        task.wait()
    end

    for _, block in pairs(optimized) do
        local blockHash = block:getHash()

        local _cacheInstance = workspace.blockCache:WaitForChild("grass")
        local _cacheTextureInstances = _cacheInstance:GetChildren()

        local _cacheTextures = {}
        for _, texture in ipairs(_cacheTextureInstances) do
            if (texture:IsA("Texture")) then
                _cacheTextures[texture.Face.Value] = texture
            end
        end
        -- Now we can get the texture, and copy the texture from the block in replicatedstorage, then apply it
        for i, texture in ipairs(ReplicatedStorage.blocks[block.texture]:GetChildren()) do
            if (texture:IsA("Texture")) then
                local face = texture.Face.Value
                _cacheTextures[face].Texture = tostring(texture.Texture)
            end
        end

        _cacheInstance.Name = blockHash
        _cacheInstance.Parent = workspace.blocks[hash]
        table.insert(cacheInstances, _cacheInstance)
        table.insert(cachePositions, CFrame.new(BlockMap:VoxelToRBX(block.position)))
    end
    workspace:BulkMoveTo(cacheInstances, cachePositions)
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
    -- Radius to actively load
    local loadRadius = 2

    -- Radius to not delete
    local cacheRadius = 2

    -- Every frame, check the radius around us, and if there are any chunks that need to be loaded, load them.
    while true do
        print(#workspace.blockCache:GetChildren())
        local chunkPosition = BlockMap:getChunk(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)

        -- Load the chunks around us.
        local loadChunks = {}
        local cacheChunks = {}
        local toLoad = {}

        for x = -loadRadius, loadRadius do
            for y = -loadRadius, loadRadius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                loadChunks[chunkHash] = true
                if ((not WorldData[chunkHash]) or (WorldData[chunkHash].isGenerated == false)) then
                    local chunk = loadChunk(chunkPosition.X + x, chunkPosition.Y + y)
                    toLoad[chunkHash] = chunk
                end
            end
        end

        for x = -cacheRadius, cacheRadius do
            for y = -cacheRadius, cacheRadius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                cacheChunks[chunkHash] = true
            end
        end

        for hash, chunk in pairs(toLoad) do
            task.spawn(function() drawChunk(chunk:getHash()) end)
            task.wait(0.1)
        end

        for chunkHash, _ in pairs(WorldData) do
            if (not cacheChunks[chunkHash]) then
                WorldData[chunkHash] = nil
                workspace.blocks[chunkHash]:Destroy()
                task.wait(0.1)
            end
        end

        task.wait(1)
    end
end

local function createBlockCache()
    --[[
        Most of the chunk loading lag is due to Roblox creating new parts, not inheritly that they exist.
        So if we create a bunch of parts in the workspace, then use workspace:MoveBulk (I think), we can just load the blocks async,
        and then move them into the workspace when they're ready.
    ]]

    RunService.RenderStepped:Connect(function(deltaTime)
            ReplicatedStorage.blocks["grass"]:Clone().Parent = workspace.blockCache
    end)
end

function ChunkReplicator:init()
    listener()
    for _ = 1,20 do
        createBlockCache()
    end
    task.spawn(chunkListener)
end

return ChunkReplicator