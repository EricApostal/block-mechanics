--!strict

--[[
    Handles routing for blocks across the entire world.
]]

local WorldBuilder = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)
local WorldData = require(script.Parent.WorldData)

-- Calculates correct chunk to place block into, then places via WorldData.
function WorldBuilder:AddBlock(block)
    local position = Vector2.new(math.floor(block.position.X/16), math.floor(block.position.X/16))
    local index = string.format("%s,%s", position.X, position.Y)

    if (WorldData[index] == nil) then
        print("chunk doesn't exist yet, creating...")
        -- Create chunk, it doesn't exist yet
        WorldData[index] = Chunk:new(position)
    end
    WorldData[index]:AddBlock(block)
end

-- Calculates target chunk containing block, then removes via WorldData.
function WorldBuilder:RemoveBlock(block)

end

return WorldBuilder