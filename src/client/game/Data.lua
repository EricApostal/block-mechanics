local Data = {}

local cachedWorldData = {}

function Data:IsChunkLoaded(chunkKey)
    local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    if chunkData == nil then
        return false
    end
    return true
end

function Data:RegisterChunk(chunkKey, data)
    cachedWorldData[chunkKey.X..","..chunkKey.Y] = data -- data == blocks
end

function Data:GetChunkData(chunkKey)
    local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    return chunkData
end

function Data:init()

end

return Data