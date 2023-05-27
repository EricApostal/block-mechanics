local BlockMechanics = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Data = require(script.Parent.Data)

local Character = require(script.Parent.Character)
local player = Players.LocalPlayer -- 17.268
local mouse = player:GetMouse()

local BlockService = Knit.GetService("BlockService")

local function placeBlock(position, type)
    BlockService:SetBlock(position, type)
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
        BlockService:BreakBlock(mouse.Target)
    end)
end

local function buildBlock(position, type)
    local block = ReplicatedStorage.blocks:WaitForChild(type):Clone()
    CollectionService:AddTag(block, "block")
    block.Parent = workspace.blocks
    if block:IsA("BasePart") then
        block.Position = position
        block.Anchored = true
    else
        block:SetPrimaryPartCFrame(CFrame.new(position))
        local Folder = Instance.new("Folder")
        Folder.Parent = workspace:WaitForChild("blocks")
        Folder.Name = "Model Folder Conversion"
        for _, part in block:GetChildren() do
            CollectionService:AddTag(part, "block")
            part.Parent = Folder
        end
        block:Destroy()
    end
end

local function handleChunkRequests()
    --[[
        Accounts for render distance, and requests that the server builds chunks
        This will need some sort of system to find the chunk radius at which you need loaded
    ]]

    local render_distance = 2
    local chunks = {}
    while true do
        local currentX = Character:GetChunk().X
        local currentZ = Character:GetChunk().Y

        for x = currentX-(render_distance), currentX+(render_distance)-1 do
            for z = currentZ-(render_distance), currentZ+(render_distance)-1 do
                table.insert(chunks, Vector2.new(x,z))
            end
        end

        for _,v in chunks do
            if Data:IsChunkLoaded(v) then
                continue
            end
            BlockService:LoadChunk(v):andThen(function(blocks) 
                -- print(blocks[1]["position"])
                for _, block in blocks do
                    buildBlock(block["position"], block["material"])
                    Data:RegisterChunk(v)
                end
            end)
            wait()
        end
        chunks = {}
        task.wait(.1)
    end
end

function BlockMechanics:init()
    handlePlacing()
    handleBreaking()
    spawn(function()
        handleChunkRequests()
    end)
end

return BlockMechanics