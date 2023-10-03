local Interact = {}

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local WorldData = require(game:GetService("ReplicatedStorage").Common.world.WorldData)
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)

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
        print("PLACING BLOCK")
        if not Mouse.Target then return end

        local chunkHash = BlockMap:toHash(BlockMap:getChunk(Mouse.Target.Position))
        local blockHash = BlockMap:toHash( BlockMap:RBXToVoxel(Mouse.Target.Position) )

        local chunk = WorldData[chunkHash]
        local block = chunk.blocks[blockHash]

        block.position = Vector3.new(block.position.X, block.position.Y + 1, block.position.Z)

        BlockService:PlaceBlock(block:serialize())
    end)
end

function Interact:init()
    handleEvents()
end

return Interact