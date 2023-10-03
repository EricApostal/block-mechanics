--!strict

local blockMap = {}
--[[
    Standardized module to map roblox coordinates to voxel coordinates
]]

function blockMap:RBXToVoxel(rblxPos: Vector3)
    return Vector3.new( math.round(rblxPos.X/3), math.round(rblxPos.Y/3), math.round(rblxPos.Z/3) )
end

function blockMap:VoxelToRBX(block)
    return Vector3.new( math.round(block.X*3), math.round(block.Y*3), math.round(block.Z*3) )
end

function blockMap:getChunk(position)
    local pos

    if (typeof(position) == "Vector2") then
        -- Are we getting the postition of a chunk?
       pos = {X = math.round(((position.X/3) - 8)/16) , Y = math.round(((position.Y/3) - 8)/16)}
        if pos.X == -0 then
            pos.X = 0
        end

        if pos.Y == -0 then
            pos.Y = 0
        end

        return Vector2.new(pos.X, pos.Y)
        
    elseif(typeof(position) == "Vector3") then
        -- Are we getting the position of a block?
        pos = {X = math.round( ((position.X/3) -8 )/16) , Z = math.round( ((position.Z/3) -8 )/16)}
        if pos.X == -0 then
            pos.X = 0
        end

        if pos.Y == -0 then
            pos.Y = 0
        end

        if pos.Z == -0 then
            pos.Z = 0
        end
        return Vector2.new(pos.X, pos.Z)
    else
        error("Tried to pass something other than a Vector2 / Vector3!")
        return nil
    end
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