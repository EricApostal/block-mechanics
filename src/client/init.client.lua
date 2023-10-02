local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local BlockService = Knit.GetService("BlockService")

local UiHandler = require(script.interface.UiHandler)

UiHandler:init()

BlockService.addBlock:Connect(function(block)
    print("block added")
    print(block)
end)