local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldBuilder = require(script.game.world.WorldBuilder)

local Players = game:GetService("Players")

-- local network = require(script.game.Network)

local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        UpdateChunk = Knit.CreateSignal(), -- Create the signal
        RemoveBlock = Knit.CreateSignal(),
        AddBlock = Knit.CreateSignal()
    },
}

Players.PlayerAdded:Connect(function(player)
    local block = Block:new(Vector3.new(1,1,1), "grass")
    WorldBuilder:AddBlock(block)
    print("sending")
    print(block.texture)
    BlockService.Client.AddBlock:Fire(player, block:serialize())
end)



Knit.Start():catch(warn):await()
