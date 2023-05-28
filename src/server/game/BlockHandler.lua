local BlockHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Data = require(script.Parent.Data)
-- local BlockService = Knit.GetService("BlockService")

function BlockHandler:placeBlock(position, material, parent)
    local block = ReplicatedStorage.blocks[material]:Clone()
    block.Position = position
    
    local rawChunk = {math.round((position/3/16).X), math.round((position/3/16).Z)}
    if rawChunk[1] == -0 then rawChunk[1] = 0 end
    if rawChunk[2] == -0 then rawChunk[2] = 0 end

    local chunk = {rawChunk[1],rawChunk[2]}
    local folder = workspace.blocks:FindFirstChild(chunk[1] .. "," .. chunk[2])

    --[[
        This is a very shitty way of "fixing" this
    ]]
    if folder == nil then
        folder = Instance.new("Folder")
        folder.Name = chunk[1] .. "," .. chunk[2]
        folder.Parent = workspace.blocks
    end

    block.Parent = workspace.blocks[chunk[1] .. "," .. chunk[2]]
    CollectionService:AddTag(block, "block")
end

function BlockHandler:breakBlock(block)
    block:Destroy()
end

local function buildModel(position, material, parent)
    --[[
        Makes it easier to add pre-build thinks like villages
    ]]
    local model = ReplicatedStorage.models[material]:Clone()
    model:SetPrimaryPartCFrame(CFrame.new(position))
    for _, block in model:GetChildren() do
        BlockHandler:placeBlock(block.position, block.Name)
    end
    model:Destroy()
end

function BlockHandler:buildChunk(startX, startZ)
    local chunkSize = 16
    local scale = 256
    local seed = 126

    local chunkData = {}

    for x = (startX*16)*3, (startX*16)*3 + chunkSize*3, 3 do
        for z = (startZ*16)*3, chunkSize*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale/2
            local pos = Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z)

            local material = "grass"

            local folder = workspace.blocks:FindFirstChild(startX .. "," .. startZ)
            if folder == nil then
                folder = Instance.new("Folder")
                folder.Name = startX .. "," .. startZ
                folder.Parent = workspace.blocks
            end

            BlockHandler:placeBlock(pos, material, folder)
            local blockData = {
                ["position"] = pos,
                ["material"] = material
            }
            if math.random(1, 50) == 1 then
                buildModel(Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z), "tree", folder)
            end
            table.insert(blockData, chunkData)
        end
    end
    Data:RegisterChunk({startX, startZ}, chunkData)
end

function BlockHandler:buildChunks(chunks)
    --coroutine.wrap(function()
        for _,v in chunks do
            BlockHandler:buildChunk(v[1], v[2])
            task.wait(.1)
        end
    --end)()
end

local function persistChunkLoading()
    local renderDistance = 5

    while true do
        for _, player in Players:GetPlayers() do
            local character = player.Character -- or player.CharacterAdded:Wait()
            if not player.Character then continue end

            local pos = character:FindFirstChild("HumanoidRootPart").Position/3/16
            local currentX = math.round(pos.X)
            local currentZ = math.round(pos.Z)

            local chunks = {}
            for x = math.round(currentX-(renderDistance/2)), math.round(currentX+(renderDistance)-1) do
                for z = currentZ-(renderDistance), currentZ+(renderDistance)-1 do
                    if not Data:IsChunkLoaded({x, z}) then
                        table.insert(chunks, {x, z})
                    end
                end
            end
            BlockHandler:buildChunks(chunks)
            task.wait()
        end
        wait()
    end
end

function BlockHandler:init()
    BlockHandler:buildChunk(0, 0)
    spawn( persistChunkLoading )
end

return BlockHandler