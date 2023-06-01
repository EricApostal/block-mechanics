local Data = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Players = game:GetService("Players")
local BlockHandler = require(script.Parent.BlockHandler)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockMap = require(ReplicatedStorage.Common.BlockMap)

local cachedWorldData = {}

local BlockService

function Data:GetChunkData(chunkKey: Vector2)
    local chunkData = cachedWorldData[chunkKey.X..","..chunkKey.Y]
    return chunkData
end

function Data:LoadChunk(player: Instance, chunkKey: Vector2)
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

function Data:SetChunk(player: Instance, chunk: Vector2, data)
    -- cachedWorldData[chunk] = data -- I should verify it's in the array... maybe it's fine
    -- for _, plr in Players:GetPlayers() do
    --     BlockService.Client.UpdateChunk:Fire(plr, chunk, data)
    -- end
end

function Data:removeBlock(player: Instance, position: Vector3)
    local pos = BlockMap:getChunk(position)
    local chunk = Vector2.new(math.round(pos.X), math.round(pos.Y))

    if not cachedWorldData[chunk.X..","..chunk.Y] then return end
    cachedWorldData[chunk.X..","..chunk.Y][position.X..","..position.Y] = nil

    for _, plr in Players:GetPlayers() do
        -- TODO: send material to validate state. If client state doesn't match, reload chunk
        BlockService.Client.removeBlock:Fire(plr, position)
    end
end

function Data:addBlock(player: Instance, position:Vector3, material: string)
    -- local pos = position/3/16
    local pos = BlockMap:getChunk(position)
    local chunk = Vector2.new(math.round(pos.X), math.round(pos.Y))

    local blockData = {
        ["position"] = position,
        ["material"] = material
    }

    if not cachedWorldData[chunk.X..","..chunk.Y] then
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