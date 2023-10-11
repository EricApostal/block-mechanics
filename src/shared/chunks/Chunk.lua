--!native

-- Creates a chunk class.

local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)

local Chunk = {}

-- Makes a new chunk.
function Chunk:new(position: Vector2, blocks: table, topLevelBlocks: table)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.hash = BlockMap:toHash(position)
    obj.instance = nil
    obj.topLevelBlocks = topLevelBlocks or {} -- Initialize "topLevelBlocks" as an empty table.

    -- Initialize "blocks" as an empty table.
    obj.blocks = {}

    obj.position = position

    if (typeof("position") == "Vector3") then
        error("Should be passing a Vector2 to Chunk:new(), not a Vector3!")
    end

    -- If blocks is passed in at all, it's a serialized chunk.
    if (blocks ~= nil) then
        for _, block in pairs(blocks) do
            local blockObj = Block:new(table.unpack(block))
            obj.blocks[blockObj:getHash()] = blockObj
        end
    else
        -- print("No need to recreate blocks, this is a new chunk.")
    end

    if (game:GetService("RunService"):IsClient() and (not workspace.blocks:FindFirstChild(obj.hash))) then
        obj.instance = Instance.new("Folder")
        obj.instance.Name = obj.hash
        obj.instance.Parent = workspace.blocks
    end

    return obj
end

function Chunk:getBlocks()
    return self.blocks
end

-- Register a block as being at the top of a chunk. Useful for lazy rendering later.
function Chunk:setTopLevelBlock(block)
    self.topLevelBlocks[block:getHash()] = block
end

-- Check if a block is top level.
function Chunk:isTopLevelBlock(block)
    return self.topLevelBlocks[block:getHash()] ~= nil
end

-- Adds a block to the chunk.
function Chunk:addBlock(block)
    -- WARNING: THIS SHOULD ONLY BE CALLED BY WORLDGEN!
    -- TODO: Add range check to ensure placement validity.
    self.blocks[block:getHash()] = block
end

-- Removes block by block object.
function Chunk:RemoveBlock(block)
    if self.topLevelBlocks[block:getHash()] then
        self.topLevelBlocks[block:getHash()] = nil
    end
    self.blocks[block:getHash()] = nil
end

function Chunk:getHash()
    return self.hash
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
        self.topLevelBlocks
    }
end

return Chunk