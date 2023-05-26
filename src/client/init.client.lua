local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local BlockMechanics = require(script.game.BlockMechanics)
local Data = require(script.game.Data)
local UiHandler = require(script.interface.UiHandler)
local Character = require(script.game.Character)

BlockMechanics:init()
Data:init()
UiHandler:init()
Character:init()