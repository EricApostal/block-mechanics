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
        local chunk = WorldData[block:getChunkHash()]

        WorldBuilder:AddBlock(block)

        if chunk then
            chunk:setTopLevelBlock(block)
        end

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

    local seed = 160
    local noisescale = 30
    local amplitude = 18
    local height = 64

    for x = startBlockPosition.X, startBlockPosition.X + 15 do
        for z = startBlockPosition.Z, startBlockPosition.Z + 15 do
            local heightArray = {}
            for y = 0, height do
                local xnoise = math.noise(y/noisescale, z/noisescale, seed)*amplitude
                local ynoise = math.noise(x/noisescale, z/noisescale, seed)*amplitude
                local znoise = math.noise(x/noisescale, y/noisescale, seed)*amplitude

                local density = xnoise + ynoise + znoise + y
                if density < 20 then
                    local formatted = string.format( "%s,%s,%s", x, y, z)
                    heightArray[formatted] = formatted
                end
            end
            -- Now we need to parse the height array and create blocks.
            table.sort(heightArray, function(a,b)
                return string.split(a, ",")[2] < string.split(b, ",")[2]
            end)
            -- WorldBuilder:AddBlock(Block:new(heightArray[#heightArray], "grass"))
            -- table.remove(heightArray, #heightArray)
            for _, posStr in heightArray do
                local _split = string.split(posStr, ",")
                local pos = Vector3.new(_split[1], _split[2], _split[3])
                WorldBuilder:AddBlock(Block:new(pos, "dirt"))
                if not heightArray[string.format( "%s,%s,%s", pos.X, pos.Y + 1, pos.Z)] then
                    WorldBuilder:AddBlock(Block:new(Vector3.new(pos.X, pos.Y, pos.Z), "grass"))
                else
                    WorldBuilder:AddBlock(Block:new(Vector3.new(pos.X, pos.Y, pos.Z), "dirt"))
                end

                -- if (math.random(1,100) == 1) then
                --     spawnTree(Vector3.new(x, calculatedY + 1, z))
                -- end
            end
        end
    end
    chunk.isGenerated = true
    WorldBuilder:AddChunk(chunk)

    return chunk
end

return WorldGen