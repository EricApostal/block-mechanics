local Network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local Block = require(ReplicatedStorage.Common.blocks.Block)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        onChunkUpdated = Knit.CreateSignal(),
        onBlockRemoved = Knit.CreateSignal(),
        onBlockAdded = Knit.CreateSignal()
    },
}

--// Server Functions \\--

-- Removed a block from the world.
function BlockService:RemoveBlock(block)
    for _, player in pairs(Players:GetPlayers()) do
        BlockService.Client.onBlockRemoved:Fire(player, block)
    end
end

function BlockService:AddBlock(block)
    return WorldBuilder:AddBlock(block)
end

--// Client Functions \\--

-- Get the contents of a chunk by chunk hash.
function BlockService.Client:GetChunk(player, chunkHash)
    return WorldBuilder:GetChunk(chunkHash)
end

-- Assumes the block is being placed by a player.
function BlockService.Client:PlaceBlock(player, block)
    return WorldBuilder:AddBlock(block)
end

-- Assumes the block is being broken by a player.
function BlockService.Client:BreakBlock(player, block)
    local blockObj = Block:new(table.unpack(block))
    return WorldBuilder:RemoveBlock(blockObj)
end

-- Removes a block from the world.
function BlockService.Client:RemoveBlock(player, block)
    return BlockService:RemoveBlock(block)
end

function Network:init()
    Players.PlayerAdded:Connect(function(player)
        print("Player joined!")
        for x = 1, 10 do
            local block = Block:new(Vector3.new(x,0,0), "grass")
            WorldBuilder:AddBlock(block)
            BlockService.Client.onBlockAdded:Fire(player, block:serialize())
        end
    end)
end


return Network