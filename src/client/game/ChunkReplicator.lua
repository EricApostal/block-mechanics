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

local view_distance = 1

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

local function isBlockAtWorldEdge(chunk, block): boolean
            -- If so, continue
            local xChunks = {}
            local yChunks = {}
            -- make a list of every position
            for _, chunkData in pairs(WorldData) do
                table.insert(xChunks, chunkData.position.x)
                table.insert(yChunks, chunkData.position.y)
            end

            local xMax = 0
            local yMax = 0
            local xMin = 0
            local yMin = 0
            for _, xPos in pairs(xChunks) do
                if xPos > xMax then
                    xMax = xPos
                end
                if xPos < xMin then
                    xMin = xPos
                end
            end

            for _, yPos in pairs(yChunks) do
                if yPos > yMax then
                    yMax = yPos
                end
                if yPos < yMin then
                    yMin = yPos
                end
            end

            -- if (chunk.position.X >= xMax or chunk.position.X <= xMin or chunk.position.Y >= yMax or chunk.position.Y <= yMin) then
                -- Now we need to check if the block is at the edge of the chunk
            if (chunk.position.X >= xMax) then
                local outOfBoundsChunkPosition = BlockMap:getChunk(BlockMap:VoxelToRBX(Vector3.new(block.position.X + 1, block.position.Y, block.position.Z)))
                if outOfBoundsChunkPosition.X ~= chunk.position.X then
                    -- print("out of bounds x!")
                    return true
                end
            elseif (chunk.position.X <= xMin) then
                local outOfBoundsChunkPosition = BlockMap:getChunk(BlockMap:VoxelToRBX(Vector3.new(block.position.X - 1, block.position.Y, block.position.Z)))
                if outOfBoundsChunkPosition.X ~= chunk.position.X then
                    -- print("out of bounds -x!")
                    return true
                end
            elseif (chunk.position.Y >= yMax) then
                local outOfBoundsChunkPosition = BlockMap:getChunk(BlockMap:VoxelToRBX(Vector3.new(block.position.X, block.position.Y + 1, block.position.Z)))
                if outOfBoundsChunkPosition.Y ~= chunk.position.Y then
                    -- print("out of bounds y!")
                    return true
                end
            elseif (chunk.position.Y <= yMin) then
                local outOfBoundsChunkPosition = BlockMap:getChunk(BlockMap:VoxelToRBX(Vector3.new(block.position.X, block.position.Y - 1, block.position.Z)))
                if outOfBoundsChunkPosition.Y ~= chunk.position.Y then
                    -- print("out of bounds -y!")
                    return true
                end
            else
                return false
                --  print("Not at edge")
            end
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

            if (isBlockAtWorldEdge(chunk, block)) then
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

local function requestChunk(x, y)
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

local function requestChunkGroup(groupTable)
    local chunkGroup = {}
    local complete = false
    print("Requesting Data: ")
    print(groupTable)
    BlockService:GetChunkGroup(groupTable):andThen(function(chunks)
        for _, chunkArray in chunks do
            local chunk = Chunk:new(table.unpack(chunkArray))
            table.insert(chunkGroup, chunk)
            WorldData[chunk:getHash()] = chunk
        end
        complete = true
    end)

    -- Shit async -> sync
    while not complete do task.wait() end
    return chunkGroup
end

-- Create a listener to automatically send requests for chunks in a specified radius.
local function chunkListener()
    -- Radius to actively load
    local loadRadius = 2

    -- local chunk = loadChunk(0,1)
    -- drawChunk(chunk:getHash())
    -- Radius to not delete
    local cacheRadius = 2

    -- Every frame, check the radius around us, and if there are any chunks that need to be loaded, load them.
    while true do
        local chunkPosition = BlockMap:getChunk(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)

        -- Load the chunks around us.
        local loadChunks = {}
        local cacheChunks = {}
        local toLoad = {}

        local toRequest = {}
        for x = -loadRadius, loadRadius do
            for y = -loadRadius, loadRadius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                -- print(x,y)
                if (not WorldData[chunkHash]) then
                    table.insert(toRequest,Vector2.new(chunkPosition.X + x, chunkPosition.Y + y))
                end
            end
        end

        for x = -cacheRadius, cacheRadius do
            for y = -cacheRadius, cacheRadius do
                local chunkHash = string.format("%s,%s", chunkPosition.X + x, chunkPosition.Y + y)
                cacheChunks[chunkHash] = true
            end
        end

        -- for chunkHash, _ in pairs(toRequest) do
        --     local split = chunkHash:split(",")
        --     local chunk = requestChunk(split[1], split[2])
        --     table.insert(toLoad, chunk)
        -- end
        if (#toRequest > 0) then
            local chunks = requestChunkGroup(toRequest)
            for _, chunk in pairs(chunks) do
                table.insert(toLoad, chunk)
                -- print(WorldData[string.format("%s,%s",chunk.position.X, chunk.position.Y)])
            end

            for _, chunk in pairs(toLoad) do
                -- print(WorldData[chunk])
                drawChunk(chunk:getHash())
                task.wait(.1)
            end
        end

        local instances = {}
        local positions = {}

        for chunkHash, _ in pairs(WorldData) do
            if (not cacheChunks[chunkHash]) then
                for _, block in pairs(workspace.blocks[chunkHash]:GetChildren()) do
                    -- block:Destroy()
                    block.Parent = workspace.blockCache
                    table.insert(instances, block)
                    table.insert(positions, CFrame.new(0,500,0))
                    task.spawn(function()
                        block.Name = "grass"
                    end)
                end
                workspace:BulkMoveTo(instances, positions)
                WorldData[chunkHash] = nil
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

    local allowedCache = 10000

    --- initial cache
    for _ = 1,allowedCache do
        ReplicatedStorage.blocks["grass"]:Clone().Parent = workspace.blockCache
    end

    for _ = 1, 30 do
        RunService.RenderStepped:Connect(function()
            if (#workspace.blockCache:GetChildren() < allowedCache) then
                ReplicatedStorage.blocks["grass"]:Clone().Parent = workspace.blockCache
            end
        end)
    end
end

function ChunkReplicator:init()
    listener()
    task.spawn(createBlockCache)
    task.spawn(chunkListener)
end

return ChunkReplicator