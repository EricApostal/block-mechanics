local Network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldGen = require(game:GetService("ServerScriptService").Server.game.WorldGen)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        onChunkUpdated = Knit.CreateSignal(),
        onBlockRemoved = Knit.CreateSignal(),
        onBlockAdded = Knit.CreateSignal()
    },
}

-- // Server Functions \\--

-- Get the contents of a chunk by chunk hash.
function BlockService:GetChunk(player, chunkPosition: Vector2)
    -- Now we must serialize the chunk and the blocks inside of it.
    local serializedChunk = WorldGen:GenerateChunk(chunkPosition):serialize()
    print("GetChunk seralized")
    print(serializedChunk)
    return serializedChunk
end

--// Client Functions \\--

-- Get the contents of a chunk by chunk hash.
function BlockService.Client:GetChunk(player, chunkPosition: Vector2)
    return BlockService:GetChunk(player, chunkPosition)
end

-- Assumes the block is being placed by a player.
function BlockService.Client:PlaceBlock(player, block)
    local blockObj = Block:new(table.unpack(block))
    WorldBuilder:AddBlock(blockObj)

    BlockService.Client.onBlockAdded:Fire(player, block)
end

-- Update world data, then replicate to all clients.
function BlockService.Client:BreakBlock(player, block)
    local blockObj = Block:new(table.unpack(block))
    WorldBuilder:RemoveBlock(blockObj)

    -- Send changes to all clients.
    for _, player in pairs(Players:GetPlayers()) do
        BlockService.Client.onBlockRemoved:Fire(player, block)
    end
end


function Network:init()
    Players.PlayerAdded:Connect(function(player)
        print("Player joined!")
        -- for x = 1, 10 do
        --     local block = Block:new(Vector3.new(x,0,0), "grass")
        --     WorldBuilder:AddBlock(block)
        --     BlockService.Client.onBlockAdded:Fire(player, block:serialize())
        -- end
    end)
end


return Network