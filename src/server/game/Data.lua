local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Players = game:GetService("Players")
local BlockHandler = require(script.Parent.BlockHandler)

local cachedWorldData = {}

local BlockService

function Data:GetChunkData(chunkKey)
    local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    return chunkData
end

function Data:LoadChunk(player, chunkKey)
    -- local BlockService = Knit.GetService("BlockService")
    -- Hopefully I can make the type of chunkKey a vector2
    local chunkData = Data:GetChunkData(chunkKey)
    if chunkData ~= nil then
        return chunkData
    end

    -- if the codepath gets here, then we need to gen the chunk
    local chunk = BlockHandler:buildChunk(chunkKey.X, chunkKey.Y)
    cachedWorldData[chunkKey.X..","..chunkKey.Y] = chunk

    return chunk
end

--[[
IDEA
When working on updating the chunk for everyone, fire the clients with the updated changes,
but do another check (like the chunk update) to see what blocks actually need to be re-rendered
]]

function Data:SetChunk(player, chunk, data)
    -- cachedWorldData[chunk] = data -- I should verify it's in the array... maybe it's fine
    -- for _, plr in Players:GetPlayers() do
    --     BlockService.Client.UpdateChunk:Fire(plr, chunk, data)
    -- end
end

function Data:removeBlock(player, position)
    local pos = position/16
    local chunk = Vector3.new(math.round(pos.X), math.round(pos.Y), math.round(pos.Z))

    if not cachedWorldData[chunk.X..","..chunk.Y] then cachedWorldData[chunk.X..","..chunk.Y] = {} end
    cachedWorldData[chunk.X..","..chunk.Y][position.X..","..position.Y] = nil

    for _, plr in Players:GetPlayers() do
        BlockService.Client.removeBlock:Fire(plr, position)
    end
end

function Data:addBlock(player, position, material)
    local pos = position/3/16
    local chunk = Vector2.new(math.round(pos.X), math.round(pos.Z))

    local blockData = {
        ["position"] = position,
        ["material"] = material
    }

    -- if not cachedWorldData[chunk.X..","..chunk.Y] then cachedWorldData[chunk.X..","..chunk.Y] = {} end
    if not cachedWorldData[chunk.X..","..chunk.Y] then
        print("tried to place into unloaded chunk...")
        return
    end
    table.insert(cachedWorldData[chunk.X..","..chunk.Y], blockData)

    for _, plr in Players:GetPlayers() do
        BlockService.Client.addBlock:Fire(plr, position, material)
    end 
end

function Data:init()
    BlockService = Knit.GetService("BlockService")
end

return Data