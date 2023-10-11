--!native

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

        local modifiers = {
            ["Top"] = Vector3.new(0,1,0),
            ["Bottom"] = Vector3.new(0,-1,0),
            ["Left"] = Vector3.new(-1,0,0),
            ["Right"] = Vector3.new(1,0,0),
            ["Front"] = Vector3.new(0,0,-1),
            ["Back"] = Vector3.new(0,0,1)
        }
        
        -- Determine face to place block on.
        local mappedTarget = BlockMap:RBXToVoxel(target.Position)
        local block = Block:new(mappedTarget + modifiers[Mouse.TargetSurface.Name], "grass")

        BlockService:PlaceBlock(block:serialize())
    end)
end

function Interact:init()
    handleEvents()
end

return Interact