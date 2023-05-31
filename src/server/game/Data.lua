local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Players = game:GetService("Players")
local BlockHandler = require(script.Parent.BlockHandler)

local cachedWorldData = {} -- rip performance

local BlockService

function Data:LoadChunk(player, chunkKey)
    -- local BlockService = Knit.GetService("BlockService")
    -- Hopefully I can make the type of chunkKey a vector2
    for key, chunkData in cachedWorldData do
        if key == chunkKey then
            -- chunk already loaded, just return
            return chunkData
        end
    end
    
    -- if the codepath gets here, then we need to gen the chunk
    local chunk = BlockHandler:buildChunk(chunkKey[1], chunkKey[2])

    cachedWorldData[chunkKey] = chunk
    return chunk
end

--[[
IDEA
When working on updating the chunk for everyone, fire the clients with the updated changes,
but do another check (like the chunk update) to see what blocks actually need to be re-rendered
]]

function Data:SetChunk(player, chunkVec, chunkData, chunkBuffer)
    cachedWorldData[chunkVec] = chunkData -- I should verify it's in the array... maybe it's fine
    for _, plr in Players:GetPlayers() do
        BlockService.Client.UpdateChunk:Fire(plr, chunkVec, chunkData, chunkBuffer)
    end
end

function Data:removeBlock(player, position)
    --[[
        WARNING: THIS WILL MESS STUFF UP REALLY BAD

        Right now this doesn't update the server chunk state AT ALL! VERY BAD!
    ]]
    for _, plr in Players:GetPlayers() do
        BlockService.Client.removeBlock:Fire(plr, position)
    end
end

function Data:addBlock(player, position, material)
    --[[
        WARNING: THIS WILL MESS STUFF UP REALLY BAD

        Right now this doesn't update the server chunk state AT ALL! VERY BAD!
    ]]
    for _, plr in Players:GetPlayers() do
        BlockService.Client.addBlock:Fire(plr, position, material)
    end 
end

function Data:init()
    BlockService = Knit.GetService("BlockService")
end

return Data