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
    print("Server has called to remove a block!")
    return WorldBuilder:RemoveBlock(block)
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
    return WorldBuilder:RemoveBlock(block)
end

-- Removes a block from the world.
function BlockService.Client:RemoveBlock(player, block)
    print("Player has called to remove a block!")
    for _, player in pairs(Players:GetPlayers()) do
        -- TODO: Add proximity check.
        BlockService.Client.onBlockRemoved:Fire(player, block)
    end
end

function Network:init()
    Players.PlayerAdded:Connect(function(player)
        local block = Block:new(Vector3.new(1,0,1), "grass")
        WorldBuilder:AddBlock(block)
        BlockService.Client.AddBlock:Fire(player, block:serialize())
    end)
end


return Network