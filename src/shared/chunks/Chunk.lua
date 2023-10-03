-- Creates a chunk class.
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)

Chunk = {
    position = Vector2.new(0, 0)
}

-- Makes a new chunk.
function Chunk:new(position: Vector2, blocks: table)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    self.blocks = blocks or {}
    self.position = position

    -- Check for serialization, if exists then recreate all of the blocks
    if (self.blocks[1] and typeof(self.blocks[1]) == "table") then
        print("I think this is a serialized chunk, recreating blocks...")
        for _, block in pairs(self.blocks) do
            print("Unpacking...")
            print(block)
            if (block["position"]) then
                warn("the error happened, I don't know why, but it's been added very wrong. Quick fix for now, but this needs to be fixed properly!")
                
            end
            local blockObj = Block:new(table.unpack(block))
            self.blocks[blockObj:getHash()] = blockObj
        end
    else
        print("No need to recreate blocks, this is a new chunk. Type: " .. typeof(self.blocks[1]))
    end

    -- So we can stop it from doing "-0"
    if position.X == 0 then
        self.hash = string.format("%s,%s", math.abs(position.X), position.Y)
    end

    if position.Y == 0 then
        self.hash = string.format("%s,%s", position.X, math.abs(position.Y))
    end

    if (game:GetService("RunService"):IsClient() ) then
        self.instance = Instance.new("Folder")
        self.instance.Name = self.hash
        self.instance.Parent = workspace.blocks
    end

    return o
end

-- Adds block by block object.
function Chunk:AddBlock(block)
    warn("This is a bad idea. Use WorldBuilder:AddBlock instead.")
    local hash = block:getHash()

    if (table.find(self.blocks, hash)) then
        warn("Tried to place block at position, but block was already placed!")
    else 
        self.blocks[hash] = block
    end
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
    for _, block in pairs(self.blocks) do
        table.insert(blocks, block:serialize())
    end

    return {
        self.position,
        blocks,
    }
end

return Chunk