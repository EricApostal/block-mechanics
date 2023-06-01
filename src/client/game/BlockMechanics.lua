local BlockMechanics = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Data = require(script.Parent.Data)

local Character = require(script.Parent.Character)
local player = Players.LocalPlayer -- 17.268
local mouse = player:GetMouse()
local BlockService = Knit.GetService("BlockService")

local function placeBlock(position, material)
    BlockService:PlaceBlock(position, material)
end

local function destroyBlock(position)
    BlockService:BreakBlock(position)
end

local lastClickUp = true
local function handlePlacing()
    mouse.Button2Down:Connect(function()
        if (not lastClickUp) or not (mouse.Target) then 
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
        if not mouse.target then return end
        destroyBlock(mouse.Target.Position)
    end)
end

local function buildBlock(position, type, parent)
    local block = ReplicatedStorage.blocks:WaitForChild(type):Clone()
    block.Parent = parent -- workspace.blocks
    if block:IsA("BasePart") then
        block.Position = position
        block.Anchored = true
    end
end

local function handleChunkRequests()
    --[[
        Accounts for render distance, and requests that the server builds chunks
        This will need some sort of system to find the chunk radius at which you need loaded
    ]]

    local render_distance = 1
    local chunks = {}
    while true do
        local currentX = Character:GetChunk().X
        local currentZ = Character:GetChunk().Y
        for x = currentX-(render_distance), currentX+(render_distance)-1 do
            for z = currentZ-(render_distance), currentZ+(render_distance)-1 do
                table.insert(chunks, Vector2.new(x, z))
            end
        end

        for _,v in chunks do
            if Data:IsChunkLoaded(v) then
                continue
            end
            
            BlockService:LoadChunk(v):andThen(function(blocks) 
                Data:RegisterChunk(v, blocks)
                for _, block in blocks do
                    buildBlock(block["position"], block["material"], workspace.blocks)
                end
            end)
            wait()
        end

        chunks = {}
        task.wait(1)
    end
end

BlockService.removeBlock:Connect(function(position)
    local block = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(1,1,1))[1]
    if not block then
        return
    end
    block:Destroy()
end)

BlockService.addBlock:Connect(function(position, material)
    local block = ReplicatedStorage.blocks[material]:Clone()
    block.Position = position
    block.Parent = workspace.blocks
end)

function BlockMechanics:init()
    handlePlacing()
    handleBreaking()
    task.spawn(handleChunkRequests)
end

return BlockMechanics