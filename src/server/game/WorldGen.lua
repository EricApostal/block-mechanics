local WorldGen = {}

local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)
local Chunk = require(game:GetService("ReplicatedStorage").Common.chunks.Chunk)
local WorldBuilder = require(game:GetService("ReplicatedStorage").Common.world.WorldBuilder)

-- Generate chunk with specified position.
function WorldGen:GenerateChunk(position: Vector2)
    -- We need to convert this chunk's position to a block position.
    -- This is because the chunk is a 16x16 grid of blocks.
    -- So we need to convert the chunk position to a block position.
    -- This is done by multiplying the chunk position by 16.
    -- This will give us the bottom left corner of the chunk.
    -- Then we can iterate through the chunk and create blocks.

    local chunk = Chunk:new(position)
    local startBlockPosition = Vector2.new(position.X * 16, position.Y * 16)

    for x = 0, 15 do
        for y = 0, 15 do
            local block = Block:new(Vector3.new(startBlockPosition.X + x, 0, startBlockPosition.Y + y), "grass")
            WorldBuilder:AddBlock(block)
        end
    end
    return chunk
end

return WorldGen