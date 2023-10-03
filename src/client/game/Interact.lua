local Interact = {}

local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local WorldData = require(game:GetService("ReplicatedStorage").Common.world.WorldData)
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)

local BlockService = Knit.GetService("BlockService")

local function handleBreaking()
    Mouse.Button1Down:Connect(function()
        if not Mouse.Target then return end

        local chunkHash = BlockMap:toHash(BlockMap:getChunk(Mouse.Target.Position))
        local blockHash = BlockMap:toHash( BlockMap:RBXToVoxel(Mouse.Target.Position) )

        print(string.format("Trying to break chunk %s, block %s", chunkHash, blockHash))
        local chunk = WorldData[chunkHash]
        local block = chunk.blocks[blockHash]

        print("serialized: ")
        print(block:serialize())
        print("raw position")
        print(block.position)
        print("blocks: ")
        print(chunk.blocks)

        BlockService:BreakBlock(block:serialize())
    end)
end

function Interact:init()
    handleBreaking()
end

return Interact