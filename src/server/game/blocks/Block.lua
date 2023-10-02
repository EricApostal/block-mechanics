--[[
    Creates a block class.
]]

local WorldBuilder = require(script.Parent.Parent.world.WorldBuilder)

Block = {
    position = Vector3.new(0, 0, 0),
    texture = "stone",
    breakTimes = {
        hand = 3
    }
}

--[[
    Makes a new block.
]]
function Block:new(position: Vector3, texture: string, breakTimes: number)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.position = position
    self.texture = texture
    self.breakTimes = breakTimes

    if (texture == nil) then
        error("ERROR: Block was created by no texture was defined.")
    end

    WorldBuilder:AddBlock(self)

    return obj
end

-- Move block by converting Roblox coordinates to Voxel coordinates.
function Block:moveTo(position: Vector3)
    -- TODO: Perhaps make a RBLX -> Voxel conversion module?
    local robloxPosition = Vector3.new(position.X*3, position.Y*3, position.Z*3)
    self.instance.Position = robloxPosition
end

-- Get the X,Y,Z hash of the block
function Block:getHash(): string
    local hash = string.format("%s,%s,%s", self.position.X, self.position.Y, self.position.Z)
    return hash
end

-- Serialize so we can pass over the network.
function Block:serialize()
    return {
        ['position'] = self.position,
        ['texture'] = self.texture,
        ['breakTimes'] = self.breakTimes
    }
end

return Block