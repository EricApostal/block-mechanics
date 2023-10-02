local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

local ChunkReplicator = require(script.game.ChunkReplicator)
local Interface = require(script.interface.Interface)

Knit.Start():catch(warn):await()

ChunkReplicator:init()
Interface:init()