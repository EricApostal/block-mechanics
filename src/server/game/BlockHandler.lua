--!strict

local BlockHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getModel(model: string, position: Vector3)
    local m = ReplicatedStorage.models[model]:Clone()
    m:SetPrimaryPartCFrame( CFrame.new(position) )

    local blocks = {}
    for _,part in m:GetChildren() do
        table.insert(blocks, part)
    end
    m:Destroy()

    return blocks;
end

function BlockHandler:buildChunk(startX: number, startZ: number)
    local chunkData = {}

    local chunkSize = 16
    local scale = 300
    local seed = 126 -- math.random(100, 999)

    for x = (startX*16)*3, (startX*16)*3 + (chunkSize-1)*3, 3 do
        for z = (startZ*16)*3, (chunkSize-1)*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale

            local blockData = {}
            blockData["position"] = Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z)
            blockData["material"] = "grass"

            -- shitty tree spawn
            if math.random(1,50) == 1 then
                local treeParts = getModel("tree", Vector3.new(x, math.round( ((min+(max-min)*y)+3)/3)*3, z))
                for _,partInstance in treeParts do
                    local treeData = {}
                    treeData["position"] = partInstance.Position
                    treeData["material"] = partInstance.Name
                    table.insert(chunkData, treeData)
                end
            end

            table.insert(chunkData, blockData)
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
end

return BlockHandler