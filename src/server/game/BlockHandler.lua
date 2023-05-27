local BlockHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

function BlockHandler:placeBlock(position, type)
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

function BlockHandler:breakBlock(block)
    block:Destroy()
end

local function BuildChunk(startX, startZ)
    local chunkSize = 16
    local scale = 256
    local seed = 126

    for x = (startX*16)*3, (startX*16)*3 + chunkSize*3, 3 do
        for z = (startZ*16)*3, chunkSize*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale/2
            BlockHandler:placeBlock( Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z), "grass" )
            if math.random(0,50) == 1 then
                BlockHandler:placeBlock( Vector3.new(x, 3+math.round( (min+(max-min)*y)/3)*3, z), "tree" )
            end
        end
    end
end

local function buildChunks()
    coroutine.wrap(function()
        BuildChunk(0,0)
        for x = -10, 10 do
            for y = -10, 10 do
                BuildChunk(x,y)
            end
            task.wait()
        end
    end)()
end

function BlockHandler:init()
    print("Server BlockHandler Initialized")
    buildChunks()
end

return BlockHandler