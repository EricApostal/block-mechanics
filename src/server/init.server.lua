local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Block = require(script.game.blocks.Block)
local Players = game:GetService("Players")

-- local network = require(script.game.Network)


local BlockService = Knit.CreateService {
    Name = "BlockService",
    Client = {
        UpdateChunk = Knit.CreateSignal(), -- Create the signal
        removeBlock = Knit.CreateSignal(),
        addBlock = Knit.CreateSignal()
    },
}

local block = Block:new(Vector3.new(1,1,1), "grass")

Players.PlayerAdded:Connect(function(player)
    BlockService.Client.addBlock:Fire(player, block:serialize())
end)



Knit.Start():catch(warn):await()
