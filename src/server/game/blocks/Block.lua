
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
function Block:new(o, position: Vector3, texture: string, breakTimes: number)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.position = position
    self.texture = texture

    if (texture == nil) then
        error("ERROR: Block was created by no texture was defined.")
    end

    local function createBlock()
        -- make new instance
        local block = game:GetService("ReplicatedStorage"):WaitForChild("blocks"):WaitForChild(texture):Clone()
        self.instance = block

        -- We want to pass this object into the chunk.
        WorldBuilder:AddBlock(self)
    end
    createBlock()

    return o
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