local function MakeItem(name, stackable, castspell)
local assets =
{
	Asset("ANIM", "anim/bcj_item.zip"),
    Asset("ATLAS", "images/inventoryimages/bcj_item"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/bcj_item"..name..".xml", 256)  
}

---PURPLE
local function onequip_purple(inst, owner)
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, true)
    end
end

local function onunequip_purple(inst, owner)
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, false)
    end
end

local function onequiptomodel_purple(inst, owner, from_ground)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    if owner.components.sanity ~= nil then
        owner.components.sanity:SetInducedInsanity(inst, false)
    end
end

local function onequip(inst, owner)
    if owner.show_444 == 0 then
        owner.show_444 = 1
    else
        owner.show_444 = 0
    end

    owner.has_dg = true    
    inst:DoTaskInTime(0, inst.Remove)
end    

local function onequip_bcj(inst, owner) 
    owner.has_dg = true  
    inst:DoTaskInTime(0, inst.Remove)
end   

local function spellfn(inst, target, pos, caster)
    if caster ~= nil then
    if caster and caster.prefab ~= "gyc" then
        for k, v in ipairs(AllPlayers) do
        if v.prefab == "gyc" then
            local x, y, z = v.Transform:GetWorldPosition()
            caster.Transform:SetPosition(x, y, z)
        end    
        end     
    end    
    end
end

local find_prefab = {
    "bcj_taos",
    "walrus_camp",
    {"dragonfly_spawner", "dragonfly"},
    "moon_fissure",
    "hermitcrab",
    "moonbase",
    "critterlab",
    "pigking", 
    "chester_eyebone",
    {"crabking_spawner", "crabking"},
    "monkeyisland_portal",
    {"klaus", "klaus_sack"},
    "sharkboi",
    {"beequeenhive", "beequeenhivegrown"},
    "stagehand"        
}

local function GetTarget(inst, doer)
    local target = nil
    local num = 0
    for i = 1, #inst.find_table do
        if inst.find_table[i] == 0 and target == nil then
            num = i
            if type(find_prefab[i]) == "table" then
            print("是表")
            target = c_findnext(find_prefab[i][1]) or c_findnext(find_prefab[i][2])
            else
            print("正常")    
            target = c_findnext(find_prefab[i])
            end
        end
    end

    return target, num
end

local function FindSpace(inst, doer)
    local target, num = GetTarget(inst, doer)
    if target then
    --print(num)
    --print(find_prefab[num])
    local targetpos = Vector3(target.Transform:GetWorldPosition()) 
    local x, y, z = targetpos.x, targetpos.y, targetpos.z

    if targetpos then
    inst.find_table[num] = 1
    if doer.player_classified ~= nil then
        doer.player_classified.revealmapspot_worldx:set(x)
        doer.player_classified.revealmapspot_worldz:set(z)
        doer.player_classified.revealmapspotevent:push()

        doer:DoStaticTaskInTime(4*FRAMES, function()
            doer.player_classified.MapExplorer:RevealArea(x, y, z, true, true)
        end)
    end
    end
    elseif target == nil then
        doer.components.talker:Say("没有可以寻找的地方了。")
    end
end

local function onuse(inst)
    local owner = inst.components.inventoryitem.owner
    if owner and owner.prefab == "gyc" then
        --local cd = inst.components.timer:GetTimeLeft("FindSpace")
        if inst.components.rechargeable:IsCharged() then
           if math.random() > 0.5 then
              FindSpace(inst, owner)
              --owner.components.talker:Say("找到了。")
              --inst.components.timer:StartTimer("FindSpace", 480)                           
           else
              owner.components.talker:Say("今天手气一般。")
           end
           inst.components.rechargeable:Discharge(480)   
        else    
           owner.components.talker:Say("冷却中")
        end
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_item")
    inst.AnimState:SetBuild("bcj_item")

    if name == "1" then
    inst:AddTag("rechargeable") 
    end    

    if name ~= "4" and name ~= "5" then  
    inst.AnimState:PlayAnimation(name, true)
    else
    inst.AnimState:PlayAnimation((name == "4" and "5") or "4", true)
    end

    inst:AddTag("bcj_item"..name)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    --inst.Transform:SetScale(1.6, 1.6, 1.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_item"..name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_item"..name..".xml"

    inst:AddComponent("tradable")

    if stackable then
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    end

    if name == "1" then
    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(onuse)

    inst:AddComponent("rechargeable")

    --inst:AddComponent("timer")

    inst:AddComponent("equippable") 

    inst.find_table = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    inst.OnSave = function(inst, data)
        data.find_table = inst.find_table
    end

    inst.OnLoad = function(inst, data)
        if data and data.find_table then
            inst.find_table = data.find_table
        end       
    end
    end    

    if name == "2" then
    inst:AddComponent("equippable")    
    inst.components.equippable:SetOnEquip(onequip_purple)
    inst.components.equippable:SetOnUnequip(onunequip_purple)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel_purple)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY      
    end

    if name == "3" then
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(spellfn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.canonlyuseonlocomotorspvp = true
    end

    if name == "4" then
    inst:AddComponent("equippable")    
    inst.components.equippable:SetOnEquip(onequip_bcj)
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable.restrictedtag = "gyc"
    end  


    if name == "5" then
    inst:AddComponent("equippable")    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable.restrictedtag = "bcj"
    end  

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_item"..name, fn, assets)
end   

return MakeItem("1"),
       MakeItem("2"),
       MakeItem("3"),
       MakeItem("4"),
       MakeItem("5")     
