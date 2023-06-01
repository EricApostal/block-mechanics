--!strict

local blockMap = {}
--[[
    Standardized module to map roblox coordinates to voxel coordinates
]]

function blockMap:getPos(rblxPos: Vector3)
    local pos = Vector3.new( math.round(rblxPos.X/3), math.round(rblxPos.Y/3), math.round(rblxPos.Z/3) )
    return pos
end

function blockMap:getChunk(chunkPos: Vector3)
    -- TODO: Handle if a Vector2 is passed
    local pos = Vector2.new(math.round( ((chunkPos.X/3) -8 )/16) , math.round( ((chunkPos.Z/3) -8 )/16))
    return pos
end

return blockMap