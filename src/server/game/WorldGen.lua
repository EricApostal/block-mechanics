--!native

local WorldGen = {}

local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)
local Chunk = require(game:GetService("ReplicatedStorage").Common.chunks.Chunk)
local WorldBuilder = require(game:GetService("ReplicatedStorage").Common.world.WorldBuilder)
local WorldData = require(game:GetService("ReplicatedStorage").Common.world.WorldData)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)


local function spawnTree(position: Vector3)
    local tree = ReplicatedStorage.models.tree
    local modelOffset = tree.PrimaryPart.Position
    for _, part in pairs(tree:GetChildren()) do
        local pos = BlockMap:RBXToVoxel(BlockMap:VoxelToRBX(position) + part.Position - modelOffset)
        local blockType = part.Name

        local block = Block:new(pos, blockType)
        WorldBuilder:AddBlock(block)
        -- If the chunk already exists, send an add block request to manually replicate it.
        if (WorldData[block:getChunkHash()] ~= nil) then
            local BlockService = Knit.GetService("BlockService")
            BlockService.Client.onBlockAdded:FireAll(block:serialize())
        end
    end
end

-- Generate chunk with specified position.
function WorldGen:GenerateChunk(position: Vector2)
    -- We need to convert this chunk's position to a block position.
    -- This is because the chunk is a 16x16 grid of blocks.
    -- So we need to convert the chunk position to a block position.
    -- This is done by multiplying the chunk position by 16.
    -- This will give us the bottom left corner of the chunk.
    -- Then we can iterate through the chunk and create blocks.

    local startBlockPosition = Vector3.new(position.X * 16, 0, position.Y * 16)

    -- If structures already exist in this chunk, we don't want to overwrite them.
    if (not WorldData[string.format("%s,%s",position.X, position.Y)]) then
        WorldData[string.format("%s,%s",position.X, position.Y)] = Chunk:new(position)
    end

    local chunk =  WorldData[string.format("%s,%s",position.X, position.Y)]

    local scale = 200
    local seed = 126

    for x = startBlockPosition.X, startBlockPosition.X + 15 do
        for z = startBlockPosition.Z, startBlockPosition.Z + 15 do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale
            local calculatedY = math.round((min+(max-min)*y)/3)

            local block = Block:new(Vector3.new(x, calculatedY, z), "grass")
            WorldBuilder:AddBlock(block)
            chunk:setTopLevelBlock(block)

            -- Now we need to generate blocks below the current block.
            for newY = calculatedY, 0, -1  do
                local block = Block:new(Vector3.new(x, math.round(calculatedY - newY), z), "dirt")
                WorldBuilder:AddBlock(block)
            end

            if (block:getChunkHash() ~= chunk.hash) then
                error("Block is not in the correct chunk! This is a FATAL error / desync with chunk placement!")
            end

            if (math.random(1,100) == 1) then
                spawnTree(Vector3.new(x, calculatedY + 1, z))
            end

        end
    end
    chunk.isGenerated = true
    WorldBuilder:AddChunk(chunk)

    return chunk
end

return WorldGen