-- Creates a chunk class.
local Players = game:GetService("Players")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)

Chunk = {
    position = Vector2.new(0, 0)
}

-- Makes a new chunk.
function Chunk:new(position: Vector2)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    self.blocks = {}
    self.position = position
    self.hash = string.format("%s,%s", position.X, position.Y)

    if (game:GetService("RunService"):IsClient() ) then
        self.instance = Instance.new("Folder")
        self.instance.Name = self.hash
        self.instance.Parent = workspace.blocks
    end

    return o
end

-- Adds block by block object.
function Chunk:AddBlock(block)
    local hash = block:getHash()

    if (table.find(self.blocks, hash)) then
        warn("Tried to place block at position, but block was already placed!")
    else 
        print("New block being placed, adding to table!")
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

return Chunk