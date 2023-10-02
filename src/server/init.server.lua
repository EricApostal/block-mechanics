local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Network = require(script.game.Network)

Knit.Start():catch(warn):await()

Network:init()
