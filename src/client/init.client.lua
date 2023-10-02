local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Block = require(ReplicatedStorage.Common.blocks.Block)

Knit.Start():catch(warn):await()

local BlockService = Knit.GetService("BlockService")


local UiHandler = require(script.interface.UiHandler)

UiHandler:init()

BlockService.AddBlock:Connect(function(block)
    print("client:")
    local blockInstance = Block:new(block.position, block.texture, block.breakTimes)
    print(blockInstance.texture)
    print(blockInstance:getHash())
end)