local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
Knit.Start():catch(warn):await()

local UiHandler = require(script.interface.UiHandler)

UiHandler:init()