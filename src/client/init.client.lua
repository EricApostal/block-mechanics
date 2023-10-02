local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local ChunkReplicator = require(script.game.ChunkReplicator)
local Interface = require(script.interface.Interface)


ChunkReplicator:init()
Interface:init()