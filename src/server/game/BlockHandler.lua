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

function BlockHandler:buildChunk(startX, startZ)
    local chunkData = {}

    local chunkSize = 16
    local scale = 256
    local seed = 126

    for x = (startX*16)*3, (startX*16)*3 + chunkSize*3, 3 do
        for z = (startZ*16)*3, chunkSize*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale/2

            local blockData = {}
            blockData["position"] = Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z)
            blockData["material"] = "grass"

            table.insert(chunkData, blockData)

            blockData = {}
            if math.random(0,50) == 1 then
                blockData["position"] =  Vector3.new(x, 3+math.round( (min+(max-min)*y)/3)*3, z)
                blockData["material"] = "tree"
                table.insert(chunkData, blockData)
            end
            
        end
    end
    return chunkData
end

function BlockHandler:buildChunks(chunks)
    coroutine.wrap(function()
        for _,v in chunks do
            BlockHandler:buildChunk(v.X, v.Y)
        end
    end)()
end

function BlockHandler:init()
    -- buildChunks()
end

return BlockHandler