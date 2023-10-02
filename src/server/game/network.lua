local Network = {}

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local WorldBuilder = require(ReplicatedStorage.Common.world.WorldBuilder)
local Block = require(ReplicatedStorage.Common.blocks.Block)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        UpdateChunk = Knit.CreateSignal(), -- Create the signal
        RemoveBlock = Knit.CreateSignal(),
        AddBlock = Knit.CreateSignal()
    },
}

local function registerFunctions()
    --// Server Functions \\--
    function BlockService:BreakBlock(player, block)
        return WorldBuilder:RemoveBlock(block)
    end

    function BlockService:PlaceBlock(player, block)
        return WorldBuilder:AddBlock(block)
    end

    -- Note: I am using namings like "Break" and "Place" because adding / removing *could* have a different meaning.

    --// Client Functions \\--
    function BlockService.Client:GetChunk(player, chunkHash)
        return WorldBuilder:GetChunk(chunkHash)
    end

    function BlockService.Client:PlaceBlock(player, block)
        return WorldBuilder:AddBlock(block)
    end

end

function Network:init()
    registerFunctions()
    Players.PlayerAdded:Connect(function(player)
        local block = Block:new(Vector3.new(1,0,1), "grass")
        WorldBuilder:AddBlock(block)
        BlockService.Client.AddBlock:Fire(player, block:serialize())
    end)
end


return Network