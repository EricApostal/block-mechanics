local ChunkReplicator = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local BlockService = Knit.GetService("BlockService")
local Block = require(ReplicatedStorage.Common.blocks.Block)
local Chunk = require(ReplicatedStorage.Common.chunks.Chunk)

-- 
function ChunkReplicator:AddBlock(block)
    
end

local function listener()
    BlockService.AddBlock:Connect(function(block)
        local blockInstance = Block:new(table.unpack(block))
    end)
end

function ChunkReplicator:init()
    listener()
end

return ChunkReplicator