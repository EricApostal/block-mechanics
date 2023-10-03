local Interact = {}

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local WorldData = require(game:GetService("ReplicatedStorage").Common.world.WorldData)
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)
local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)

local BlockService = Knit.GetService("BlockService")

local function handleEvents()
    -- Breaking blocks.
    Mouse.Button1Down:Connect(function()
        if not Mouse.Target then return end

        local chunkHash = BlockMap:toHash(BlockMap:getChunk(Mouse.Target.Position))
        local blockHash = BlockMap:toHash( BlockMap:RBXToVoxel(Mouse.Target.Position) )

        local chunk = WorldData[chunkHash]
        local block = chunk.blocks[blockHash]

        BlockService:BreakBlock(block:serialize())
    end)

    -- Placing Blocks.
    Mouse.Button2Down:Connect(function()
        if not Mouse.Target then return end

        local target = Mouse.Target
        local modifier = Vector3.new(0,0,0)

        if (Mouse.TargetSurface.Name == "Top") then
            modifier = Vector3.new(0,1,0)
            elseif (Mouse.TargetSurface.Name == "Bottom") then
            modifier = Vector3.new(0,-1,0)
            elseif (Mouse.TargetSurface.Name == "Left") then
            modifier = Vector3.new(-1,0,0)
            elseif (Mouse.TargetSurface.Name == "Right") then
            modifier = Vector3.new(1,0,0)
            elseif (Mouse.TargetSurface.Name == "Front") then
            modifier = Vector3.new(0,0,-1)
            elseif (Mouse.TargetSurface.Name == "Back") then
            modifier = Vector3.new(0,0,1)
            else
            error("Invalid surface name!")
        end

        local mappedTarget = BlockMap:RBXToVoxel(target.Position)
        local block = Block:new(mappedTarget + modifier, "grass")

        BlockService:PlaceBlock(block:serialize())
    end)
end

function Interact:init()
    handleEvents()
end

return Interact