local Data = {}

local cachedWorldData = {}

function Data:IsChunkLoaded(chunkKey)
    -- return cachedWorldData[chunkKey] ~= nil -- not a good long term solution
    for key, chunkData in cachedWorldData do
        -- print(key)
        -- print(chunkKey)
        if key[1] == chunkKey[1] and key[2] == chunkKey[2] then
            return true
        end
    end
    return false
end

function Data:RegisterChunk(chunkKey, data)
    cachedWorldData[chunkKey] = data -- data == blocks
end

function Data:GetChunkData(chunkKey)
    for key, chunkData in cachedWorldData do
        -- print(key)
        -- print(chunkKey)
        if key[1] == chunkKey[1] and key[2] == chunkKey[2] then
            return chunkData
        end
    end
    print("IS STILL NIL")
    return nil
end

function Data:init()

end

return Data