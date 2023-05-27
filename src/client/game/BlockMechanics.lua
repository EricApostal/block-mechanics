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

local function placeBlock(position, material)
    --[[
        Alright so I have to update the user's own chunk data
        which means I need to find what chunk they placed it in, then add that block manually, then push to the server

        Or I push what block changed to the server, then I figure out what chunk I need to reload based on it's XYZ
    ]]
    local chunkKey = { math.round(position.X/3/16), math.round(position.Z/3/16) }
    
    local chunkData = Data:GetChunkData(chunkKey)
    local block = {}

    print("chunk key on click: ")
    print(chunkKey)
    print("data")
    print(chunkData)

    block["position"] = position
    block["material"] = material

    table.insert(chunkData, block)
    BlockService:SetChunk(chunkKey, chunkData)
    -- BlockService:SetBlock(position, material)
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
        local currentX = Character:GetChunk()[1]
        local currentZ = Character:GetChunk()[2]
        for x = currentX-(render_distance), currentX+(render_distance)-1 do
            for z = currentZ-(render_distance), currentZ+(render_distance)-1 do
                table.insert(chunks, {x, z})
            end
        end

        for _,v in chunks do
            if Data:IsChunkLoaded(v) then
                continue
            end
            BlockService:LoadChunk(v):andThen(function(blocks) 
                Data:RegisterChunk(v, blocks)
                -- print(blocks[1]["position"])
                for _, block in blocks do
                    buildBlock(block["position"], block["material"])
                end
            end)
            wait()
        end
        chunks = {}
        task.wait(1)
    end
end


BlockService.UpdateChunk:Connect(function(chunkVec, newChunkData)
    print("updating chunk...")
    -- BlockService:LoadChunk(chunkVec, chunkData)

    --[[
        I can get the locally stored version, compare to find the differences
        When difference found, either add or remove block
    ]]
    local oldChunkData = Data:GetChunkData(chunkVec)
    for _, block in newChunkData do
        if not table.find(oldChunkData, block) then
            buildBlock(block["position"], block["material"])
        end
    end

end)


function BlockMechanics:init()
    handlePlacing()
    handleBreaking()
    spawn(function()
        handleChunkRequests()
    end)
end

return BlockMechanics