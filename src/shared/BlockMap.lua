--!strict

local blockMap = {}
--[[
    Standardized module to map roblox coordinates to voxel coordinates
]]

function blockMap:getPos(rblxPos: Vector3)
    local pos = Vector3.new( math.round(rblxPos.X/3), math.round(rblxPos.Y/3), math.round(rblxPos.Z/3) )
    return pos
end

function blockMap:getChunk(chunkPos: Vector2)
    -- TODO: Handle if a Vector2 is passed
    local pos = Vector2.new(math.round( ((chunkPos.X/3) -8 )/16) , math.round( ((chunkPos.Y/3) -8 )/16))
    return pos
end

function blockMap:toHash(chunkPos: Vector3)
    local hash
    if (typeof(chunkPos) == "Vector2") then
        hash = string.format("%s,%s", math.floor(chunkPos.X), math.floor(chunkPos.Y))
    elseif (typeof(chunkPos) == "Vector3") then
        hash = string.format("%s,%s,%s", math.floor(chunkPos.X), math.floor(chunkPos.Y), math.floor(chunkPos.Z))
    else
        error("Invalid type passed to blockMap:toHash")
    end
    return hash
end

return blockMap