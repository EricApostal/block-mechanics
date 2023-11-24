local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Network = require(script.game.Net)

Knit.Start():catch(warn):await()

Network:init()
