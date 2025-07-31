local skill_range = 12

local ShadowAnimal = {
    minotaur = true,
    stalker = true,
    stalker_forest = true,
    stalker_atrium = true
}

local function MakeTmj(name, damage, mult, use)
local assets =
{
    
    Asset("ANIM", "anim/gyc_tmj.zip"), 
	Asset("ANIM", "anim/swap_gyc_tmj.zip"),  
    Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/"..name..".xml", 256)   
}

local function IsRiding(inst)
    return inst.replica.rider and inst.replica.rider:IsRiding() or false
end

local function onattack(inst, owner, target)
    if target then
    local fx = SpawnPrefab("gyc_tmj_fx")
    fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end 
end    

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_gyc_tmj", "swap_"..name) 
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")   
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")   
end

--桃木枝修复5%，紫宝石修复5%，雷击木修复10%，橙黄绿宝石修复10%，彩虹宝石修复15%

local RepairTable = {
    gyc_tmj2 = {silk = 0.05, bcj_cl7 = 0.15},
    gyc_tmj3 = {houndstooth = 0.05, bcj_cl7 = 0.1, bcj_cl4 = 0.5},
    gyc_tmj4 = {redgem = 0.05, bluegem = 0.05, bcj_cl7 = 0.1, purplegem = 0.1, bcj_cl4 = 0.15},
    gyc_tmj5 = {bcj_cl7 = 0.05, purplegem = 0.05, bcj_cl4 = 0.1, orangegem = 0.1, yellowgem = 0.1, greengem = 0.1, opalpreciousgem = 0.15},
}


local function CanTakeItem(inst, ammo, giver)
    --print(RepairTable[inst.prefab])
    --print(ammo.prefab)
    --return false
    return RepairTable[inst.prefab][ammo.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)  
    if item and RepairTable[inst.prefab][item.prefab] ~= nil and inst.components.finiteuses:GetPercent() < 1 then
        local rapair_amount = RepairTable[inst.prefab][item.prefab] or 0.1
        rapair_amount = inst.components.finiteuses.total * rapair_amount
        --print(RepairTable[inst.prefab][item.prefab])
        --print(rapair_amount)
        inst.components.finiteuses:Repair(rapair_amount)
        inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")    
    end      
end

local function seed_ondeploy(inst, pt, deployer)
    local tree = SpawnPrefab("bcj_taos")
    if tree ~= nil then
        tree.Transform:SetPosition(pt:Get())
        tree.components.growable:SetStage(1)
        inst.components.stackable:Get():Remove()
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gyc_tmj")
    inst.AnimState:SetBuild("gyc_tmj")
    inst.AnimState:PlayAnimation(name, true)  --c_findnext("skd_sword")  .AnimState:PlayAnimation("gyc_mb2", true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag(name)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.shadow_mult = mult

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(damage)
    inst.components.weapon:SetOnAttack(onattack)
--[[
    local GetDamage = inst.components.weapon.GetDamage
    inst.components.weapon.GetDamage = function(self, attacker, target) 
        local damage, spdamage = GetDamage(self, attacker, target) 
        if target and target:IsValid() then
        if (ShadowAnimal[target.prefab] == true or (target:HasTag("shadowcreature") or target:HasTag("shadow") or target:HasTag("shadowchesspiece") or target:HasTag("shadowthrall"))) then      
            damage = damage * inst.shadow_mult
        end
        end    

        return damage, spdamage
    end   
]]
    if name == "gyc_tmj5" then
    inst.base_damage = damage
    local planardamage = inst:AddComponent("planardamage")
    planardamage:SetBaseDamage(15)

    local damagetypebonus = inst:AddComponent("damagetypebonus")
    damagetypebonus:AddBonus("shadow_aligned", inst, mult)
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "gyc"
    --inst.components.equippable.walkspeedmult = speed 

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(use)
    inst.components.finiteuses:SetUses(use)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    if name ~= "gyc_tmj1" then
    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    else
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = seed_ondeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab(name, fn, assets),
       MakePlacer("gyc_tmj1_placer", "bcj_taos", "bcj_taos", "1")
end   

return MakeTmj("gyc_tmj1", 20, 1.2, 200),  --ThePlayer.AnimState:OverrideSymbol("swap_object", "swap_gyc_tmj", "swap_gyc_tmj1") 
       MakeTmj("gyc_tmj2", 25, 1.3, 200),
       MakeTmj("gyc_tmj3", 30, 1.35, 200),
       MakeTmj("gyc_tmj4", 35, 1.4, 300),
       MakeTmj("gyc_tmj5", 40, 1.5, 400)