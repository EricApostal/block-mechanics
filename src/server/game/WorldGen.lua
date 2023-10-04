local WorldGen = {}

local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)
local Chunk = require(game:GetService("ReplicatedStorage").Common.chunks.Chunk)
local WorldBuilder = require(game:GetService("ReplicatedStorage").Common.world.WorldBuilder)

-- Generate chunk with specified position.
function WorldGen:GenerateChunk(position: Vector2)
    print("generating chunk w/ position")
    print(position)
    local chunk = Chunk:new(position)

    for x = 1,16 do
        for y = 1,16 do
            local block = Block:new(Vector3.new(position.X + x, 0, position.Y + y), "grass")
            WorldBuilder:AddBlock(block)
        end
    end
    return chunk
end

return WorldGen