local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Players = game:GetService("Players")


--[[
    this file is still mostly applicable post-net change, it's just has a lesser purpose now

    This will be to maintain the world state for saving n stuff
]]

local cachedWorldData = {}

function Data:IsChunkLoaded(chunkKey)
    for key, _ in cachedWorldData do
        if key[1] == chunkKey[1] and key[2] == chunkKey[2] then
            -- chunk already loaded, just return
            return true
        end
    end
    return false
end

function Data:RegisterChunk(chunkKey, chunkData)
    cachedWorldData[chunkKey] = chunkData
end

function Data:init()
end

return Data