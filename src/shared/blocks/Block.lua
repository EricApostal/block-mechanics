--[[
    Creates a block class.
]]

local BlockMap = require(script.Parent.Parent.BlockMap)

Block = {
    position = Vector3.new(0, 0, 0),
    texture = "stone",
    breakTimes = {
        hand = 3
    }
}

-- Makes a new block.
function Block:new(position: Vector3, texture: string, breakTimes: number)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.position = position
    self.texture = texture
    self.breakTimes = breakTimes

    if (texture == nil) then
        error("ERROR: Block was created but no texture was defined.")
    end

    return obj
end

-- Move block by converting Roblox coordinates to Voxel coordinates.
function Block:moveTo(position: Vector3)
    -- This may just not work
    local robloxPosition = BlockMap:getPos(position)
end

function Block:getChunk(): Vector2
    return BlockMap:getChunk(self.position)
end

-- Get the X,Y,Z hash of the block
function Block:getHash(): string
    return string.format("%s,%s,%s", self.position.X, self.position.Y, self.position.Z)
end

-- Get the hash of the current chunk
function Block:getChunkHash():string
    return string.format("%s,%s", self:getChunk().X, self:getChunk().Y)
end

-- Serialize so we can pass over the network.
function Block:serialize()
    return {self.position, self.texture, self.breakTimes, self.chunk}
end

return Block