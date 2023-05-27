local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

local network = require(script.game.network)
local BlockHandler = require(script.game.BlockHandler)
local ChunkBuilder = require(script.game.ChunkBuilder)
local Data = require(script.game.Data)

network:init()
BlockHandler:init()
ChunkBuilder:init()
Data:init()

Knit.Start():catch(warn):await()