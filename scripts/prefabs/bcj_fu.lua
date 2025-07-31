local function MakeItem(name, stackable, castspell)
local assets =
{
	Asset("ANIM", "anim/swap_bcj_fu.zip"),
    Asset("ATLAS", "images/inventoryimages/bcj_fu"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/bcj_fu"..name..".xml", 256)  
}

local function OnIsNight(inst, isnight)
    if not TheWorld.state.isday and (inst._light == nil or not inst._light:IsValid())
    and inst.components.inventoryitem.owner and inst.components.equippable:IsEquipped()
    and inst.components.fueled:GetPercent() > 0 then
        inst._light = SpawnPrefab("minerhatlight") 
        inst._light.entity:SetParent(inst.entity)  
    end
end    

local function OnIsDay(inst)    
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()   
        end
        inst._light = nil
    end
end

local function onequip(inst, owner)
    if name == "3" then
        OnIsNight(inst)
    end    
    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end      
end    


local function onunequip(inst, owner)
    OnIsDay(inst)
    if inst.components.fueled ~= nil then
    inst.components.fueled:StartConsuming()
    end  
end 

local function Spell_1(inst, target, pos, caster) 
    local del = 40  --caster.prefab == "gyc" and -20 or
    if caster.components.health then
        caster.components.health:DoDelta(del)
    end 

    if caster.components.temperature then
        caster.components.temperature:SetTemperature(30)
    end

    if caster:HasTag("groggy") then
        caster:RemoveTag("groggy")
    end    

    if caster.components.burnable and caster.components.burnable:IsBurning() then
        caster.components.burnable:Extinguish()
    end

    if caster.components.grogginess ~= nil then
        caster.components.grogginess:AddGrogginess(-100, -100)
    end 

    caster.bcj_fu1_task = caster:DoTaskInTime(60, function()
        if caster.bcj_fu1_task then
            caster.bcj_fu1_task:Cancel()
            caster.bcj_fu1_task = nil
        end    
    end)              
end

local function Spell_4(inst, target, pos, caster)
    local x, y, z = caster.Transform:GetWorldPosition()
    local lightning1 = SpawnPrefab("lightning")
    lightning1.Transform:SetPosition(x, y - .1, z)
    lightning1.AnimState:SetMultColour(1, 1, 0, 1)

    local lightning1 = SpawnPrefab("electricchargedfx")
    lightning1.Transform:SetPosition(x, y, z)
    --lightning1.AnimState:SetMultColour(1, 1, 0, 1)

    caster.components.combat.externaldamagemultipliers:SetModifier("bcj_fu4", 1.5) 

    caster.bcj_fu4_task = caster:DoTaskInTime(30, function()
        caster.components.combat.externaldamagemultipliers:RemoveModifier("bcj_fu4") 
        if caster.bcj_fu4_task then
            caster.bcj_fu4_task:Cancel()
            caster.bcj_fu4_task = nil
        end    
    end)

   
    local bcj = FindEntity(caster, 30, nil, {"bcj"})
    if bcj then
        bcj.components.combat:GetAttacked(caster, 50, nil, "electric")  
        SpawnPrefab("lightning").Transform:SetPosition(bcj.Transform:GetWorldPosition())
        return
    end    

    local taos = FindEntity(caster, 30, nil, {"taos"})
    if taos then
        local x, y, z = taos.Transform:GetWorldPosition()
        taos:Remove()         
        SpawnPrefab("bcj_taos_burnt").Transform:SetPosition(x, 0, z)
        SpawnPrefab("lightning").Transform:SetPosition(x, 0, z)
        return
    end  

    local x, y, z = caster.Transform:GetWorldPosition()
    local exclude_tags = {'FX', 'NOCLICK', 'INLIMBO', 'player', "noauradamage"}
    local ents = TheSim:FindEntities(x, y, z, 30, {"_combat"}, exclude_tags) 
    for k, v in ipairs(ents) do
        if v and v:IsValid()  then
            v.components.combat:GetAttacked(caster, 50, nil, "electric")
            break
        end    
    end              
end

local function Spell_5(inst, target, pos, caster) 
    caster.bcj_fu5_per_task = caster:DoPeriodicTask(2, function()
    local pt = Vector3(caster.Transform:GetWorldPosition())    
    local angle = 0
    local radius = 8
    local number = 6
    for i = 1, number do
        local prefab = i <= 3 and "ghost" or ((math.random() > 0.5 and "crawlingnightmare") or "nightmarebeak")        
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt + offset
        local x, y, z = newpt:Get()

        local monster = SpawnPrefab(prefab)
        monster.components.combat:SetTarget(caster)
        monster.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
        angle = angle + (PI*2/number)
    end         
    end)

    caster.bcj_fu5_task = caster:DoTaskInTime(10, function()
        if caster.bcj_fu5_task then
            caster.bcj_fu5_task:Cancel()
            caster.bcj_fu5_task = nil
        end

        if caster.bcj_fu5_per_task then
            caster.bcj_fu5_per_task:Cancel()
            caster.bcj_fu5_per_task = nil
        end             
    end) 
end    

local function spellfn(inst, target, pos, caster)
    if caster ~= nil then
    if name == "1" then
        Spell_1(inst, target, pos, caster)

    elseif name == "4" then 
        Spell_4(inst, target, pos, caster)

    elseif name == "5" then 
        Spell_5(inst, target, pos, caster)        
    end

    if name == "1" or name == "4" or name == "5" then
    local x, y, z = caster.Transform:GetWorldPosition()
    SpawnPrefab("bcj_fu_fx"..name).Transform:SetPosition(x, 0, z)
    end      
    end

    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()  --ThePlayer.AnimState:OverrideSymbol("swap_object", "swap_bcj_fu", "swap_1")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("swap_bcj_fu")
    inst.AnimState:SetBuild("swap_bcj_fu")  
    inst.AnimState:PlayAnimation(name, true)

    inst:AddTag("bcj_fu"..name)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    --inst.Transform:SetScale(1.6, 1.6, 1.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_fu"..name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_fu"..name..".xml"

    if stackable then
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 10

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(spellfn)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = true
    inst.components.spellcaster.canonlyuseonlocomotorspvp = true
    else
    inst:AddComponent("equippable")
    --inst.components.equippable.restrictedtag = equiptag    
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    end 

    if name == "2" or name == "3" then
    inst:AddComponent("fueled")
    inst.components.fueled:InitializeFuelLevel(480 * 3)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    end

    if name == "2" then
    inst:AddComponent("planardefense")
    inst.components.planardefense:SetBaseDefense(15)
    end    

    if name == "3" then
    inst:DoTaskInTime(0, OnIsNight)
    inst:WatchWorldState("isdusk", OnIsNight)
    inst:WatchWorldState("isday", OnIsDay)

    inst:WatchWorldState("iscaveday", OnIsDay)
    inst:WatchWorldState("iscavedusk", OnIsNight)
    inst:WatchWorldState("iscavenight", OnIsNight) 
    end    

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_fu"..name, fn, assets)
end   

return MakeItem("1", true),
       MakeItem("2"),
       MakeItem("3"),
       MakeItem("4", true),
       MakeItem("5", true)     
