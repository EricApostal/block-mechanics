local BlockMechanics = {}

local Players = game:GetService("Players")

local player = Players.LocalPlayer -- 17.268

local mouse = player:GetMouse()

local function placeBlock(position)
    local block = Instance.new("Part")
    block.Size = Vector3.new(3,3,3)
    block.Parent = workspace.blocks
    block.Anchored = true
    block.Name = "block"
    block.Position = position
    block.Material = "Grass"
    block.Color = Color3.fromRGB(26,165,16)
end

local lastClickUp = true

local function BuildChunk(startX, startZ)
    local chunkSize = 16
    local scale = 256
    local seed = 126
    for x = (startX*16)*3, (startX*16)*3 + chunkSize*3, 3 do
        for z = (startZ*16)*3, chunkSize*3 + (startZ*16)*3, 3  do
            local y = ((1+math.noise(x/scale, z/scale, seed/1000))/2)
            local min, max = 0, scale
            placeBlock( Vector3.new(x, math.round( (min+(max-min)*y)/3)*3, z) )
        end
    end
end
BuildChunk(0,0)
for x = -10, 10 do
    for y = -10, 10 do
        BuildChunk(x,y)
    end
end

function BlockMechanics:init()

    mouse.Button2Down:Connect(function()
        if (not lastClickUp) or not (mouse.Target) or not (mouse.Target.Name == "block") then return end
        
        if mouse.TargetSurface.Name == "Right" then
            placeBlock( Vector3.new(mouse.Target.Position.X+3, mouse.Target.Position.Y, mouse.Target.Position.Z) )
        elseif mouse.TargetSurface.Name == "Top" then 
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y + 3, mouse.Target.Position.Z) )
        elseif mouse.TargetSurface.Name == "Left" then
            placeBlock( Vector3.new(mouse.Target.Position.X-3, mouse.Target.Position.Y, mouse.Target.Position.Z) )
        elseif mouse.TargetSurface.Name == "Bottom" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y - 3, mouse.Target.Position.Z) )
        elseif mouse.TargetSurface.Name == "Front" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y, mouse.Target.Position.Z-3) )
        elseif mouse.TargetSurface.Name == "Back" then
            placeBlock( Vector3.new(mouse.Target.Position.X, mouse.Target.Position.Y, mouse.Target.Position.Z+3) )
        end
    end)
    mouse.Button2Up:Connect(function()
        lastClickUp = true
    end)

    mouse.Button1Down:Connect(function()
        mouse.Target:Destroy()
    end)


end

return BlockMechanics