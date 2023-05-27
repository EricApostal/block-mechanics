local Data = {}

local cachedWorldData = {}

function Data:IsChunkLoaded(chunkKey)
    -- return cachedWorldData[chunkKey] ~= nil -- not a good long term solution
    for key, chunkData in cachedWorldData do
        if key == chunkKey then
            return true
        end
    end
    return false
end

function Data:RegisterChunk(chunkKey)
    cachedWorldData[chunkKey] = {"asd"} -- will probably set to important stuff later
end

function Data:init()

end

return Data