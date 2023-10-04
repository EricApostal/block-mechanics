-- Creates a chunk class.
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)

local Chunk = {}
-- Makes a new chunk.
function Chunk:new(position: Vector2, blocks: table)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.hash = ""
    obj.instance = nil

    obj.blocks = blocks

    if (not obj.blocks) then
        obj.blocks = {}
    end
    
    obj.position = position

    if (typeof("position") == "Vector3") then
        error("Should be passing a Vector2 to Chunk:new(), not a Vector3!")
    end

    -- If blocks is passed in at all, it's a serialized chunk.
    if (blocks ~= nil) then
        print("I think this is a serialized chunk, recreating blocks...")
        for _, block in pairs(obj.blocks) do
            print("Unpacking...")
            if (block["position"]) then
                error("Wrong format, should not be passing an obj through here!")
            end

            local blockObj = Block:new(table.unpack(block))
            obj.blocks[blockObj:getHash()] = blockObj
        end
    else
        print("No need to recreate blocks, this is a new chunk.")
    end

    -- So we can stop it from doing "-0"
    if position.X == 0 then
        obj.hash = string.format("%s,%s", math.abs(position.X), position.Y)
    end

    if position.Y == 0 then
        obj.hash = string.format("%s,%s", position.X, math.abs(position.Y))
    end

    if (game:GetService("RunService"):IsClient() ) then
        obj.instance = Instance.new("Folder")
        obj.instance.Name = obj.hash
        obj.instance.Parent = workspace.blocks
    end

    return obj
end


-- Removes block by block object.
function Chunk:RemoveBlock(block)
    local BlockService = Knit:GetService("BlockService")

    local hash = block:getHash()

    local players = Players:GetPlayers()
    BlockService:RemoveBlock(block:serialize())
end

function Chunk:serialize()
    local blocks = {}
    for index, block in pairs(self.blocks) do
        -- Replace instance entirely.
        blocks[index] = block:serialize()
    end

    return {
        self.position,
        blocks,
    }
end

return Chunk