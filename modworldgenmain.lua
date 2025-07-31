-----------------------------------------添加新地皮
GLOBAL.require("map/terrain")
GLOBAL.require("map/tasks")
GLOBAL.require("constants")

local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS
local GROUND = GLOBAL.GROUND
local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

local require = GLOBAL.require
require("constants")
require("map/tasks")
local LAYOUTS = require("map/layouts").Layouts
local STATICLAYOUT = require("map/static_layout")

require("map/rooms/forest/bcj_rosepatch")	--引入一种room的文件，范围内随机分布

AddTaskPreInit("Speak to the king", function(task)	--将对应的room加入task中，出现这个task时就肯定有这个room出现
    task.room_choices["BcjRosePatch"] = 1	--玫瑰花丛区域会出现在猪王村附近
end)

AddTaskPreInit("Speak to the king classic", function(task)	--玫瑰花丛区域会出现在猪王村附近
    task.room_choices["BcjRosePatch"] = 1
end)

local beefalorooms =
{
	"BeefalowPlain",
}

for i, room in ipairs(beefalorooms) do
	AddRoomPreInit(room, function(room)
		if room.contents == nil then
			room.contents = {}
		end
		if room.contents.countprefabs == nil then
			room.contents.countprefabs = {}
		end
		--room.contents.countprefabs.hln_telechair = function () return 1 end
		room.contents.countprefabs.bcj_jianzhu14 = function () return 1 end
		room.contents.countprefabs.my_cd = function () return 1 end		
	end)
end




