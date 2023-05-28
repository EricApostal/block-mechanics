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

local function handleUnloading()
    local renderDistance = 2

    while wait() do
        local pos = Character:GetChunk()
        local currentX = math.round(pos[1])
        local currentZ = math.round(pos[2])

        local shouldBeLoaded = {}
        for x = math.round(currentX - (renderDistance / 2)), math.round(currentX + (renderDistance - 1)) do
            for z = currentZ - renderDistance, currentZ + (renderDistance - 1) do
                table.insert(shouldBeLoaded, x .. "," .. z)
            end
        end

        for _, chunk in ipairs(ReplicatedStorage.MapCache:GetChildren()) do
            if not table.find(shouldBeLoaded, chunk.Name) then
                for _, block in ipairs(chunk:GetDescendants()) do
                    block.Transparency = 1
                end
            else 
                for _, block in ipairs(chunk:GetDescendants()) do
                    block.Transparency = 0
                end
            end
        
        end
    end
end

local function handleChunkPackets()
    BlockService.onChunkPacket:Connect(function(chunkPos, chunkData)
        print("post packet: ")
        print(#chunkData)
        -- local x, z = chunkPos[1], chunkPos[2]
        for _, block in chunkData do
            print(block)
            block.Parent = workspace
        end
    end)
end

function BlockMechanics:init()
    BlockService = Knit.GetService("BlockService")

    handlePlacing()
    handleBreaking()
    handleChunkPackets()
    -- spawn(handleUnloading)
end

return BlockMechanics