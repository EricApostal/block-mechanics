local BlockMechanics = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer -- 17.268

local mouse = player:GetMouse()

local function placeBlock(position, type)
    local block = ReplicatedStorage.blocks:WaitForChild(type):Clone()
    CollectionService:AddTag(block, "block")
    block.Parent = workspace.blocks
    if block:IsA("BasePart") then
        block.Position = position
        block.Anchored = true
    else
        block:SetPrimaryPartCFrame(CFrame.new(position))
    end
end
    

local lastClickUp = true

local function BuildChunk(startX, startZ)
    local chunkSize = 16
    local scale = 256
    local seed = 126
    for x = (startX*16)*3, (startX*16)*3 + chunkSize*3, 3 do
        for z = (startZ*16)*3, chunkSize*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale/2
            placeBlock( Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z), "grass" )
            math.randomseed(seed)
            for i = 1, 50 do
                if math.random(1, 25) == i then
                    placeBlock( Vector3.new(x, 3+math.round( (min+(max-min)*y)/3)*3, z), "tree" )
                end
            end
        end
    end
end

local function handleBreaking()
    mouse.Button2Down:Connect(function()
        if (not lastClickUp) or not (mouse.Target) or not (CollectionService:HasTag(mouse.Target, "block") ) then return end
        
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

    mouse.Button1Down:Connect(function()
        mouse.Target:Destroy()
    end)
end

local function buildChunks()
    --coroutine.wrap(function()
        BuildChunk(0,0)
        for x = -3, 3 do
            for y = -3, 3 do
                BuildChunk(x,y)
            end
            task.wait()
        end
    --end)()
end

function BlockMechanics:init()
    handleBreaking()
    buildChunks()
end

return BlockMechanics