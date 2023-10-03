local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local ChunkReplicator = require(script.game.ChunkReplicator)
local Interface = require(script.interface.Interface)
local Interact = require(script.game.Interact)

Interact:init()
ChunkReplicator:init()
Interface:init()