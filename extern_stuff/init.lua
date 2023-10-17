local ie = minetest.request_insecure_environment()
local http = minetest.request_http_api()
local currPath = "/home/ubuntu/.minetest/mods/rblx_chunkgen"

print("started chunkgen bridge")

local function getChunk(x, y, callback)
    print("running getChunk()!")
    local chunkData = {}

    local pos_min = vector.new(x * 16, 0, y * 16)
    local pos_max = vector.new(x * 16 + 15, 256, y * 16 + 15)

    local iters = 0
    local function runGetChunkThing()
        iters = iters + 1

        if iters < 17 then
            return
        end
        minetest.log("Iterations: "..iters)

        local voxelmanip = minetest.get_voxel_manip(pos_min, pos_max)
        local emin, emax = voxelmanip:read_from_map(pos_min, pos_max)
        local area = VoxelArea:new{ MinEdge = emin, MaxEdge = emax }
        local data = voxelmanip:get_data()

        for z = pos_min.z, pos_max.z do
            for y = pos_min.y, pos_max.y do
                for x = pos_min.x, pos_max.x do
                    if (data[area:index(x, y, z)] == nil) then
                        minetest.log("Tried to index nil block position!")
                    else
                        local blockType = minetest.get_name_from_content_id(data[area:index(x, y, z)])
                        if not (blockType == "air") then
                            local blockData = {x=x, y=y, z=z, t=blockType:gsub("default:", "")}
                            table.insert(chunkData, blockData)
                            -- local blockHash = x..","..y..","..z
                            -- chunkData[blockHash] = blockData
                        end
                    end
                end
            end
        end
        callback(chunkData)
        end
    minetest.emerge_area(pos_min, pos_max, runGetChunkThing)
end

minetest.register_chatcommand("cc", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()
        -- getChunk(math.floor(pos.x / 16), math.floor(pos.z / 16))
        getChunk(1000, 1000, function() minetest.log("called!") end)
    end,
})

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- local alreadyRequested = {}
local function checkRequests()
    -- Use Long Poll to wait for hash, then do request
    local GETRequest = {
        url="http://localhost:8080/local/recieverequest",
        timeout = 10000,
        method = "GET",
    }
    http.fetch(GETRequest, function(data)
        local hash = data["data"]
        print("Full Return: ")
        print(dump(data))
        print("Got hash: "..hash)
        print("Split: ")
        print(dump(split(hash, ",")))
        local x = tonumber(split(hash, ",")[1])
        local y = tonumber(split(hash, ",")[2])

        getChunk(x,y,function(blocks)
            local POSTRequest = {
                url="http://localhost:8080/local/sendrequest",
                timeout = 10000,
                method = "POST",
                data = '{"hash": "0,0","blocks": {"1,1": {"t": "grass"}}}',--{hash=hash, blocks=blocks},
                extra_headers = { "Content-Type", "application/json" }
            }
            print("GetChunk called, sending POST...")
            http.fetch(POSTRequest, function(ret)
                print("POST returned: "..ret)
            end)
        end)
    end)
end

minetest.register_chatcommand("host", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        os.execute("mkdir "..currPath.."/requests")
        os.execute("mkdir "..currPath.."/responses")
        checkRequests()
    end,
})

minetest.register_chatcommand("pos", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()
        minetest.log(dump(pos))
    end,
})

minetest.register_globalstep(function()
    checkRequests()
end)
