local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

local Block = require(ReplicatedStorage.Common.blocks.Block)
local WorldBuilder = require(script.game.world.WorldBuilder)
local Network = require(script.game.Network)


Knit.Start():catch(warn):await()

Network:init()
