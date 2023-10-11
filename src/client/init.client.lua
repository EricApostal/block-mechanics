local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local ChunkReplicator = require(script.game.ChunkReplicator)
local Interface = require(script.interface.Interface)
local Interact = require(script.game.Interact)
local Character = require(script.game.Character)

Interact:init()
ChunkReplicator:init()
Interface:init()
Character:init()