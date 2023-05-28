local BlockMechanics = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Data = require(script.Parent.Data)

local Character = require(script.Parent.Character)
local player = Players.LocalPlayer -- 17.268
local mouse = player:GetMouse()

local BlockService

local function placeBlock(position, material)
    print("placing block")
    BlockService:PlaceBlock(position, material)
end

local function destroyBlock(block)
    BlockService:BreakBlock(block)
end

local lastClickUp = true
local function handlePlacing()
    mouse.Button2Down:Connect(function()
        if (not lastClickUp) or not (mouse.Target) or not (CollectionService:HasTag(mouse.Target, "block") ) then 
            return 
        end
        
        if mouse.TargetSurface.Name == "Right" then
            placeBlock( Vector3.new(mouse.Target.Position.X+3, mouse.Target.Position.Y, mouse.Target.Position.Z), "oak_log" )
        elseif mouse.TargetSurface.Name == "Top" then 
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y + 3, mouse.Target.Position.Z), "oak_log" )
        elseif mouse.TargetSurface.Name == "Left" then
            placeBlock( Vector3.new(mouse.Target.Position.X-3, mouse.Target.Position.Y, mouse.Target.Position.Z), "oak_log" )
        elseif mouse.TargetSurface.Name == "Bottom" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y - 3, mouse.Target.Position.Z), "oak_log" )
        elseif mouse.TargetSurface.Name == "Front" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y, mouse.Target.Position.Z-3), "oak_log" )
        elseif mouse.TargetSurface.Name == "Back" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y, mouse.Target.Position.Z+3), "oak_log" )
        end
    end)
    mouse.Button2Up:Connect(function()
        lastClickUp = true
    end)
end

local function handleBreaking()
    mouse.Button1Down:Connect(function()
        destroyBlock(mouse.Target)
    end)
end


function BlockMechanics:init()
    BlockService = Knit.GetService("BlockService")

    handlePlacing()
    handleBreaking()
end

return BlockMechanics