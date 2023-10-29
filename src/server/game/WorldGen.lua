--!native

local WorldGen = {}

local Block = require(game:GetService("ReplicatedStorage").Common.blocks.Block)
local Chunk = require(game:GetService("ReplicatedStorage").Common.chunks.Chunk)
local WorldBuilder = require(game:GetService("ReplicatedStorage").Common.world.WorldBuilder)
local WorldData = require(game:GetService("ReplicatedStorage").Common.world.WorldData)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BlockMap = require(game:GetService("ReplicatedStorage").Common.BlockMap)
local Knit = require(game:GetService("ReplicatedStorage").modules.knit)
local http = game:GetService("HttpService")

local function spawnTree(position: Vector3)
    local tree = ReplicatedStorage.models.tree
    local modelOffset = tree.PrimaryPart.Position
    for _, part in pairs(tree:GetChildren()) do
        local pos = BlockMap:RBXToVoxel(BlockMap:VoxelToRBX(position) + part.Position - modelOffset)
        local blockType = part.Name

        local block = Block:new(pos, blockType)
        local chunk = WorldData[block:getChunkHash()]

        WorldBuilder:AddBlock(block)

        if chunk then
            chunk:setTopLevelBlock(block)
        end

        -- If the chunk already exists, send an add block request to manually replicate it.
        if (WorldData[block:getChunkHash()] ~= nil) then
            local BlockService = Knit.GetService("BlockService")
            BlockService.Client.onBlockAdded:FireAll(block:serialize())
        end
    end
end

-- Generate chunk with specified position.
function WorldGen:GenerateChunk(position: Vector2)
    -- print(string.format("http://193.122.131.242:8080/?x=5&y=5", position.X, position.Y))
    WorldData[string.format("%s,%s",position.X, position.Y)] = Chunk:new(position)
    local raw = ''
    while raw == '' do
        raw = http:GetAsync("http://193.122.131.242:8080/chunk?x=1&y=1")
        print(raw)
    end
    local blocks = http:JSONDecode(raw)
    print("decoded!")
    for _, block in blocks do
        local blockTexture = "grass"
        if ReplicatedStorage.blocks:FindFirstChild(block.t) then
           blockTexture = block.t
        end
        local blockObj = Block:new(Vector3.new(block.x, block.y, block.z), blockTexture)
        WorldBuilder:AddBlock(blockObj)
    end
    local chunk =  WorldData[string.format("%s,%s",position.X, position.Y)]
    return chunk
end

local function parseChunk(blocks, position)
    local didBlockCheck = false
    local lastChunk = nil
    -- print("parsing chunk "..position.X..","..position.Y)
    -- print(blocks)
    for _, block in blocks do
        local blockTexture = "grass"
        if ReplicatedStorage.blocks:FindFirstChild(block.t) then
           blockTexture = block.t
        end
        local blockObj = Block:new(Vector3.new(block.x, block.y, block.z), blockTexture)
        WorldBuilder:AddBlock(blockObj)
        if not (didBlockCheck) then
            -- print("block in chunk: "..BlockMap:toHash(BlockMap:getChunk( BlockMap:VoxelToRBX(blockObj.position)) ))
            if not lastChunk then
                lastChunk = BlockMap:toHash(BlockMap:getChunk( BlockMap:VoxelToRBX(blockObj.position)) )
            elseif lastChunk ~= BlockMap:toHash(BlockMap:getChunk( BlockMap:VoxelToRBX(blockObj.position)) ) then
                print("Chunks do not match...")
                didBlockCheck = true
            end
            
        end
    end

    local chunk = WorldData[string.format("%s,%s",position.X, position.Y)]
    return chunk
end

function WorldGen:GenerateChunkGroup(chunksToGenerate: table)
    local chunks = {}
    
    local encoded = ''
    for _, position in chunksToGenerate do
        if encoded ~= '' then
            encoded = encoded.."&"
        end
        encoded = encoded.."chunk="..position.X..","..position.Y
    end
    
    -- local raw = http:GetAsync("http://193.122.131.242:8080/chunkgroup?chunk=-1,-1&chunk=-1,0")
    print("endpoint: ")
    print("http://193.122.131.242:8080/chunkgroup?"..encoded)
    local raw = ''
    while raw == '' do
        raw = http:GetAsync("http://193.122.131.242:8080/chunkgroup?"..encoded)
    end
    print("decoding chunks...")
    local data = http:JSONDecode(raw)
    print("decoded chunks.")
    for hash, blocks in data["chunks"] do
        local _s = string.split(hash, ",")
        local x = _s[1]
        local y = _s[2]
        local position = Vector2.new(x,y)
        local parsed = parseChunk(blocks, position)
        table.insert(chunks, parsed)
    end
    print("returning chunks!")
    return chunks
end


return WorldGen