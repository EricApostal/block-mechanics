local BlockHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Data = require(script.Parent.Data)
local BlockService

function BlockHandler:placeBlock(position, material, parent)
    local block = ReplicatedStorage.blocks[material]:Clone()
    block.Position = position
    
    local rawChunk = {math.round((position/3/16).X), math.round((position/3/16).Z)}
    if rawChunk[1] == -0 then rawChunk[1] = 0 end
    if rawChunk[2] == -0 then rawChunk[2] = 0 end

    local chunk = {rawChunk[1],rawChunk[2]}
    local folder = ServerStorage.blocks:FindFirstChild(chunk[1] .. "," .. chunk[2])

    --[[
        This is a very shitty way of "fixing" this
    ]]
    if folder == nil then
        folder = Instance.new("Folder")
        folder.Name = chunk[1] .. "," .. chunk[2]
        folder.Parent = ServerStorage.blocks
    end

    block.Parent = ServerStorage.blocks[chunk[1] .. "," .. chunk[2]]
    CollectionService:AddTag(block, "block")
    return block
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

function BlockHandler:buildChunk(startX, startZ, player)
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

            local folder = ServerStorage.blocks:FindFirstChild(startX .. "," .. startZ)
            if folder == nil then
                folder = Instance.new("Folder")
                folder.Name = startX .. "," .. startZ
                folder.Parent = ServerStorage.blocks
            end

            local block = BlockHandler:placeBlock(pos, material, folder)
            local blockData = {
                --[[
                    Originally for datastorage since you obviously can save instances,
                    but that may not work out
                ]]
                ["position"] = pos,
                ["material"] = material
            }
            if math.random(1, 50) == 1 then
                buildModel(Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z), "tree", folder)
            end
            table.insert(chunkData, block) -- blockData is ideal
        end
    end
    Data:RegisterChunk({startX, startZ}, chunkData)
    print("pre-packet")
    print(#chunkData)
    BlockService.Client.onChunkPacket:Fire(player, {startX, startZ}, chunkData)
end

function BlockHandler:buildChunks(chunks, player)
    --coroutine.wrap(function()
        for _,v in chunks do
            BlockHandler:buildChunk(v[1], v[2], player)
            -- task.wait(.1)
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
            BlockHandler:buildChunks(chunks, player)
           
            task.wait(10)
        end
        wait()
    end
end

function BlockHandler:init()
    BlockService = Knit.GetService("BlockService")
    spawn( persistChunkLoading )
end

return BlockHandler