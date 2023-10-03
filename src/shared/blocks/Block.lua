--[[
    Creates a block class.
]]

local BlockMap = require(script.Parent.Parent.BlockMap)

local Block = {} -- Create an empty table for the Block class

-- Constructor for a new block.
function Block:new(position, texture, breakTimes)
    local obj = {} -- Create a new table for the block instance
    setmetatable(obj, self)
    self.__index = self
    obj.position = position
    obj.texture = texture
    obj.breakTimes = breakTimes

    if texture == nil then
        error("ERROR: Block was created but no texture was defined.")
    end

    return obj
end

-- Move block by converting Roblox coordinates to Voxel coordinates.
function Block:moveTo(position)
    -- This may just not work
    local robloxPosition = BlockMap:getPos(position)
    -- Update the instance-specific position
    self.position = robloxPosition
end

function Block:getChunk()
    return BlockMap:getChunk(self.position)
end

-- Get the X,Y,Z hash of the block
function Block:getHash()
    local position = table.clone({X = self.position.X, Y = self.position.Y, Z = self.position.Z})
    if position.X == -0 then
        position.X = 0
    end
    if position.Y == -0 then
        position.Y = 0
    end
    if position.Z == -0 then
        position.Z = 0
    end
    
    return string.format("%s,%s,%s", position.X, position.Y, position.Z)
end

-- Get the hash of the current chunk
function Block:getChunkHash()
    return string.format("%s,%s", self:getChunk().X, self:getChunk().Y)
end

-- Serialize so we can pass over the network.
function Block:serialize()
    return { self.position, self.texture, self.breakTimes, self:getChunk() }
end

return Block
