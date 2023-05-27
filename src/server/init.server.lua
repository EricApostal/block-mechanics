local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

local network = require(script.game.network)
local BlockHandler = require(script.game.BlockHandler)

-- Create the service:
-- local BlockService = Knit.CreateService {
--     Name = "BlockService",
-- }

-- function BlockService:SetBlock(player, position)
--     print("Block placed")
-- end

-- function BlockService:GetBlocks(player)
--     print("getting blocks")
--     return "blocks def go here :D"
-- end

-- function BlockService.Client:GetBlocks(player)
--     print("getting blocks")
--     return "blocks def go here :D"
-- end

network:init()
BlockHandler:init()

Knit.Start():catch(warn):await()