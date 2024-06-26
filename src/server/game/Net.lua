local Network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldGen = require(game:GetService("ServerScriptService").Server.game.WorldGen)
local WorldData = require(ReplicatedStorage.Common.world.WorldData)
local BlockMap = require(ReplicatedStorage.Common.BlockMap)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        onChunkUpdated = Knit.CreateSignal(),
        onBlockRemoved = Knit.CreateSignal(),
        onBlockAdded = Knit.CreateSignal()
    },
}

-- // Server Functions \\--

-- Get the contents of a chunk by chunk position.
function BlockService:GetChunk(player, chunkPosition: Vector2)
    -- Now we must serialize the chunk and the blocks inside of it.
    local chunk = WorldData[BlockMap:toHash(chunkPosition)]
    if ((chunk == nil) or (not chunk.isGenerated)) then
        chunk = WorldGen:GenerateChunk(chunkPosition)
    end

    return chunk:serialize()
end

function BlockService:GetChunkGroup(player, chunks)
    local toGenerate = {}
    local alreadyGenerated = {}
    local chunkGroup = {}

    for _, chunkPosition in chunks do
        -- Now we must serialize the chunk and the blocks inside of it.
        local chunk = WorldData[BlockMap:toHash(chunkPosition)]
        if (chunk == nil) then
            table.insert(toGenerate, chunkPosition)
        else
            table.insert(alreadyGenerated, chunk)
        end
    end
    local generatedChunks = WorldGen:GenerateChunkGroup(toGenerate)
    local toSerialize = {}
    -- table.unpack(generatedChunks), table.unpack(alreadyGenerated)
    for _, chunk in pairs(generatedChunks) do
        table.insert(toSerialize, chunk)
    end
    for _, chunk in pairs(alreadyGenerated) do
        table.insert(toSerialize, chunk)
    end
    local serialized = {}
    for _, chunk in pairs(toSerialize) do
        table.insert(serialized, chunk:serialize())
    end

    return serialized
end

--// Client Functions \\--

-- Get the contents of a chunk by chunk hash.
function BlockService.Client:GetChunk(player, chunkPosition: Vector2)
    return BlockService:GetChunk(player, chunkPosition)
end

function BlockService.Client:GetChunkGroup(player, chunks)
    return BlockService:GetChunkGroup(player, chunks)
end

-- Assumes the block is being placed by a player.
function BlockService.Client:PlaceBlock(player, block)
    local blockObj = Block:new(table.unpack(block))
    WorldBuilder:AddBlock(blockObj)

    for _, player in pairs(Players:GetPlayers()) do
        BlockService.Client.onBlockAdded:Fire(player, block)
    end
end

-- Update world data, then replicate to all clients.
function BlockService.Client:BreakBlock(player, block)
    local blockObj = Block:new(table.unpack(block))
    WorldData[blockObj:getChunkHash()]:RemoveBlock(blockObj)
    WorldBuilder:RemoveBlock(blockObj)

    -- Send changes to all clients.
    for _, player in pairs(Players:GetPlayers()) do
        BlockService.Client.onBlockRemoved:Fire(player, block)
    end
end


function Network:init()
end


return Network