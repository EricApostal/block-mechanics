local Data = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockMap = require(ReplicatedStorage.Common.BlockMap)

local cachedWorldData = {}

function Data:GetChunkData(chunkKey: Vector2)
    local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    return chunkData
end

function Data:IsChunkLoaded(chunkKey: Vector2)
    -- local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    if Data:GetChunkData(chunkKey) then 
        return true
    else 
        return false 
    end
end

function Data:GetLoadedChunks()
    return cachedWorldData
end

function Data:RegisterChunk(chunkKey: Vector2, data)
    -- cachedWorldData[chunkKey.X..","..chunkKey.Y] = data -- data == blocks
    cachedWorldData[chunkKey.X..","..chunkKey.Y] = data
end

function Data:RemoveChunk(chunkKey: Vector2)
    cachedWorldData[chunkKey.X..","..chunkKey.Y] = nil
end

function Data:UnregisterBlock(position: Vector3)
    local pos = BlockMap:getChunk(position)
    local chunk = Vector2.new(math.round(pos.X), math.round(pos.Y))

    if not cachedWorldData[chunk.X..","..chunk.Y] then return end
    cachedWorldData[chunk.X..","..chunk.Y][position.X..","..position.Y] = nil
end

function Data:RegisterBlock(position:Vector3, material: string)
    -- local pos = position/3/16
    local pos = BlockMap:getChunk(position)
    local chunk = Vector2.new(math.round(pos.X), math.round(pos.Y))

    local blockData = {
        ["position"] = position,
        ["material"] = material
    }

    if not cachedWorldData[chunk.X..","..chunk.Y] then
        warn("tried to locally add block in null chunk... maybe look into that?")
        return
    end
    table.insert(cachedWorldData[chunk.X..","..chunk.Y], blockData)
end

function Data:init()

end

return Data