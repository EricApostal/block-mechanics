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
    block["actionType"] = "build"

    local buffer = 1

    table.insert(chunkData, block)
    BlockService:SetChunk(chunkKey, chunkData, buffer)
    -- BlockService:SetBlock(position, material)
end

local function destroyBlock(position, id)
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
    block["id"] = id
    block["actionType"] = "destroy"

    local buffer = 1

    table.insert(chunkData, block)
    BlockService:SetChunk(chunkKey, chunkData, buffer)
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
        destroyBlock(mouse.Target.Position, mouse.Target:GetAttribute("id"))
    end)
end

local function buildBlock(position, type, parent, id)
    local block = ReplicatedStorage.blocks:WaitForChild(type):Clone()
    block.Parent = parent -- workspace.blocks
    if block:IsA("BasePart") then
        block.Position = position
        block.Anchored = true
        block:SetAttribute("id", id)
    else
        --[[
            I just need to scrap this,
            fuck the trees
        ]]
        block:SetPrimaryPartCFrame(CFrame.new(position))
        for _, part in block:GetChildren() do
            part.Parent = parent
        end
        block:Destroy()
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
            local chunkFolder = workspace.blocks:FindFirstChild(v[1] .. "," .. v[2])
            if not chunkFolder then
                chunkFolder = Instance.new("Folder")
                chunkFolder.Name = v[1] .. "," .. v[2]
                chunkFolder.Parent = workspace.blocks
            end
            BlockService:LoadChunk(v):andThen(function(blocks) 
                Data:RegisterChunk(v, blocks)
                -- print(blocks[1]["position"])
                for _, block in blocks do
                    buildBlock(block["position"], block["material"], chunkFolder, block["id"])
                end
            end)
            wait()
        end
        chunks = {}
        task.wait(1)
    end
end

BlockService.UpdateChunk:Connect(function(_, newChunkData, newChunkBuffer)
    print("updating chunk...")
    local change = newChunkData[#newChunkData]

    --[[
        For whatever reason I am either looking in or the folder contains chunkdata from the wrong region
    ]]

    if change.actionType == "build" then
        buildBlock(change.position, change.material, change.id)
    elseif change.actionType == "destroy" then
        for _, block in ipairs(newChunkData) do
            if block.position == change.position then
               -- Block positions are approximately equal
               -- Perform destruction logic here
                local chunkVec = {math.round(block.position.X/3/16), math.round(block.position.Z/3/16)}

                if chunkVec[1] == -0 then chunkVec[1] = 0 end
                if chunkVec[2] == -0 then chunkVec[2] = 0 end
                local blocks = workspace.blocks[chunkVec[1]..","..chunkVec[2]]:GetChildren()
                print(#blocks)
                for _, v in ipairs(blocks) do
                    if v.Position == block.position then
                        print("FOUND!")
                        v:Destroy()
                        break  -- Exit the loop once the block is destroyed
                    end
                    print("position: ")
                    print(v.Position/3)
                    print("chunk vector")
                    print(chunkVec)
                end
                print("Did not find the specified ID in all existing blocks within the chunk.")
                print(block.position)
            end
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