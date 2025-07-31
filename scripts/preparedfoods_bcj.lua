require("constants")

local function getCount(entity, name)
    return entity[name] or 0
end

local function create_light(eater)
   
end

local foods_bcj =
{
    bcj_food1 = 
    {
        test = function(cooker, names, tags)
        return tags.dairy and tags.dairy >= 3 and names.wetgoop
        end,
        priority = 20,
        hunger = 0,
        sanity = 0,
        health = 0,
        cooktime = 2,
        perishtime = 480 * 96,
        overridebuild = "bcj_foods",
        oneatenfn = function(inst, eater)   --食用后的效果 
            eater:AddDebuff("healthregenbuff", "healthregenbuff")     
        end,        
    },

    bcj_food2 = 
    {
        test = function(cooker, names, tags)
        return (names.pepper or names.pepper_cooked) and tags.egg and tags.egg == 1 and names.bcj_cl5
        and tags.meat and tags.meat >= 0.5
        end,
        priority = 20,
        hunger = 160,
        sanity = -20,
        health = -10,
        cooktime = 1,
        perishtime = 480 * 10,
        overridebuild = "bcj_foods",
        foodtype = FOODTYPE.VEGGIE,
        oneatenfn = function(inst, eater)   --食用后的效果 
            if eater and eater.components.temperature then
                if eater.components.temperature.current < 30 then
                    eater.components.temperature:SetTemperature(30)
                end

                eater.bcj_food2_task = eater:DoTaskInTime(60 * 8, function()
                    if eater.bcj_food2_task then
                        eater.bcj_food2_task:Cancel()
                        eater.bcj_food2_task = nil
                    end    
                end)   
            end     
        end,          
    },
    
    bcj_food3 = 
    {
        test = function(cooker, names, tags)  --小麦＝2，槐花=2
        local food1 = getCount(names, "bcj_cl6")
        local food2 = getCount(names, "bcj_cl10")
        return food1 >= 2 and food2 >= 2 
        end,
        priority = 20,
        hunger = 60,
        sanity = -10,
        health = 20,
        cooktime = 0.5,
        perishtime = 480 * 60,
        foodtype = FOODTYPE.VEGGIE,
        overridebuild = "bcj_foods",
        oneatenfn = function(inst, eater)   --食用后的效果   .hungerrate
            if eater and eater.components.hunger then
                if eater.bcj_food3_task then
                    eater.components.hunger.hungerrate = eater.components.hunger.hungerrate * 2
                end    
                eater.components.hunger.hungerrate = eater.components.hunger.hungerrate / 2

                eater.bcj_food3_task = eater:DoTaskInTime(60 * 10, function()
                    eater.components.hunger.hungerrate = eater.components.hunger.hungerrate * 2
                    if eater.bcj_food3_task then
                        eater.bcj_food3_task:Cancel()
                        eater.bcj_food3_task = nil
                    end    
                end)   
            end     
        end,          
    },

    bcj_food4 =  --花≥1、面粉≥1、甜度≥1 
    {
        test = function(cooker, names, tags)
        local food1 = getCount(names, "petals")
        local food2 = getCount(names, "bcj_cl5")
        return food1 >= 1 and food2 >= 1 and tags.sweetener and tags.sweetener >= 1 and (not tags.monster or tags.monster <= 1) and not tags.inedible and not tags.frozen
        end,
        priority = 20,
        hunger = 0,
        sanity = 0,
        health = 0,
        cooktime = 2,
        perishtime = 480 * 50,
        overridebuild = "bcj_foods",
        foodtype = FOODTYPE.VEGGIE,
    },

    bcj_food5 = 
    {
        test = function(cooker, names, tags)
        --print(cooker)
        --local food1 = getCount(names, "meat_dried")
        --local food2 = getCount(names, "smallmeat_dried")
        --local food3 = getCount(names, "monstermeat_dried")
        return false
        --return math.random() > 0.5 and true
        end,
        foodtype = FOODTYPE.MEAT,
        priority = 40,
        hunger = 40,
        sanity = -40,
        health = -40,
        cooktime = 0.2,
        perishtime = 480 * 10,
        overridebuild = "bcj_foods",
    },

    bcj_food6 = 
    {
        test = function(cooker, names, tags)
        local food1 = getCount(names, "tomato")
        local food2 = getCount(names, "tomato_cooked")
        return (food1 + food2 >= 2) and tags.egg and tags.egg >= 2 
        end,
        foodtype = FOODTYPE.MEAT,        
        priority = 20,
        hunger = 0,
        sanity = 0,
        health = 0,
        cooktime = 0.33,
        perishtime = 480 * 7,
        overridebuild = "bcj_foods",
    },

    bcj_food7 = 
    {
        test = function(cooker, names, tags)
        return false
        end,
        priority = 1080,
        hunger = 0,
        sanity = 0,
        health = 0,
        cooktime = 2,
        perishtime = 480 * 5,
        overridebuild = "bcj_foods",
        foodtype = FOODTYPE.VEGGIE,
        oneatenfn = function(inst, eater)
            --加强攻击力
            if eater.components.combat ~= nil then --这个buff需要攻击组件
                eater.components.combat.externaldamagemultipliers:SetModifier("bcj_food7", 2) 
                eater.bcj_food7_task = eater:DoTaskInTime(20, function()
                    if eater.bcj_food7_task then
                        eater.bcj_food7_task:Cancel()
                        eater.bcj_food7_task = nil
                    end
                    eater.components.combat.externaldamagemultipliers:RemoveModifier("bcj_food7")     
                end) 
            end

            --醉酒
            if eater:HasTag("player") then
                local drunkmap = {
                    wathgrithr = 0, wolfgang = 0, warly = 0, --酒量好
                    wormwood = 0, wx78 = 0, --身体结构不一样
                    wendy = 1, webber = 1, willow = 1, wes = 1, wurt = 1, walter = 1, --酒量差
                    yangjian = 0, yama_commissioners = 0, myth_yutu = 1 --mod人物
                }
                if drunkmap[eater.prefab] == 0 then --没有任何事
                    return
                elseif drunkmap[eater.prefab] == 1 then --直接睡着8-12秒
                    eater:PushEvent("yawn", { grogginess = 5, knockoutduration = 5 })
                else --12-20秒内减速
                    if eater.task_l_groggy ~= nil then
                        eater.task_l_groggy:Cancel()
                        eater.task_l_groggy = nil
                    end
                    if eater.components.locomotor ~= nil then
                        eater:AddTag("groggy") --添加标签，走路会摇摇晃晃
                        eater.components.locomotor:SetExternalSpeedMultiplier(eater, "bcj_food7", 0.4)
                        eater.task_l_groggy = eater:DoTaskInTime(5, function(eater)
                            if eater.components.locomotor ~= nil then
                                eater.components.locomotor:RemoveExternalSpeedMultiplier(eater, "bcj_food7")
                            end
                            eater:RemoveTag("groggy")
                            eater.task_l_groggy = nil
                        end)
                    end
                end
            elseif eater.components.sleeper ~= nil then
                eater.components.sleeper:AddSleepiness(5, 6)
            elseif eater.components.grogginess ~= nil then
                eater.components.grogginess:AddGrogginess(5, 6)
            else
                eater:PushEvent("knockedout")
            end
        end,        
    },

    bcj_food8 = 
    {
        test = function(cooker, names, tags)
        local food1 = getCount(names, "bcj_cl6")  --c_give("bcj_cl2",2)  --桃花≥1、面粉≥1、蛋度≥1、奶制品≥1
        --local food1 = getCount(names, "bcj_cl6")
        return food1 >= 3 and tags.frozen
        end,
        priority = 1080,
        hunger = 5,
        sanity = 10,
        health = 2,
        cooktime = 2,
        perishfood = "bcj_food9",
        perishtime = 480 * 5,
        overridebuild = "bcj_foods",
        foodtype = FOODTYPE.VEGGIE,
    },

    bcj_food9 = 
    {
        test = function(cooker, names, tags)
        return names.bcj_cl6 and names.bcj_cl5 and tags.egg and tags.dairy
        end,
        priority = 1080,
        hunger = 5,
        sanity = 40,
        health = 10,
        cooktime = 2,
        perishtime = 480 * 5, 
        overridebuild = "bcj_foods",
        foodtype = FOODTYPE.VEGGIE,
    },

    bcj_food10 = 
    { 
        test = function(cooker, names, tags)  --西瓜≥1、肉度≥1、盐晶≥1
        return names.watermelon and tags.meat and tags.meat >= 1 and names.saltrock and (not tags.monster or tags.monster <= 1) and not tags.inedible 
        end,
        priority = 1080,
        hunger = 66,
        sanity = -30,
        health = -10,
        cooktime = 0.4,
        perishtime = 480 * 1,
        overridebuild = "bcj_foods2",
        foodtype = FOODTYPE.MEAT,
    },

    bcj_food11 = 
    {
        test = function(cooker, names, tags)  --甜度≥1、果度≥0.5、冰≥1
        return tags.sweetener and tags.sweetener >= 1 and tags.fruit and tags.fruit >= 0.5 and tags.frozen and tags.frozen >= 1
        and (not tags.monster or tags.monster <= 1) and not tags.inedible 
        end,
        priority = 1080,
        hunger = 0,
        sanity = 0,
        health = 0,
        cooktime = 2,
        perishtime = 480 * 365,
        overridebuild = "bcj_foods2",
        foodtype = FOODTYPE.VEGGIE,
    },

    bcj_food12 = 
    {
        test = function(cooker, names, tags, doer)  --槐花≥2，面粉≥1（仅接受冰作为填充物
        local food1 = getCount(names, "bcj_cl2")  --c_give("bcj_cl2",2)
        local food2 = getCount(names, "bcj_cl5")
        return food1 >= 2 and food2 >= 1 and tags.frozen
        end,
        foodtype = FOODTYPE.VEGGIE,
        priority = 20,
        hunger = 10,
        sanity = 10,
        health = 50,
        cooktime = 2,
        perishtime = 480 * 365,
        overridebuild = "bcj_foods2",
    },
}

for k, v in pairs(foods_bcj) do
	v.name = k
	v.weight = v.weight or 1
	v.priority = v.priority or 0
end

return foods_bcj
