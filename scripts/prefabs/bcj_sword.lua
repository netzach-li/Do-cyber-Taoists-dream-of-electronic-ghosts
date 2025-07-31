local skill_range = 12

local ShadowAnimal = {
    minotaur = true,
    stalker = true,
    stalker_forest = true,
    stalker_atrium = true
}

local function MakeSword(name, damage, range, mult, use, dapperness)
local assets =
{
    Asset("ANIM", "anim/bcj_sword.zip"),  
    Asset("ANIM", "anim/swap_bcj_sword.zip"), 
    Asset("ATLAS", "images/inventoryimages/bcj_sword"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/bcj_sword"..name..".xml", 256)   
}

local function IsRiding(inst)
    return inst.replica.rider and inst.replica.rider:IsRiding() or false
end                 

local function onequip(inst, owner)
	if owner.components.combat then
    inst.min_attack_period = owner.components.combat.min_attack_period
    owner.components.combat.min_attack_period = owner.prefab ~= "bcj" and 0.8 or 0
    end

    inst.components.equippable.dapperness = owner.prefab ~= "bcj" and dapperness or 0
    owner.AnimState:OverrideSymbol("swap_object", "swap_bcj_sword", "swap_bcj_sword"..name) 
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")   
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	if owner.components.combat and inst.min_attack_period then
	inst.min_attack_period = 0
    owner.components.combat.min_attack_period = inst.min_attack_period
    end       
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

local function onattack(inst, owner, target)  
    if owner and owner.prefab == "bcj" then
    local damage = inst.components.weapon:GetDamage(owner, target)
    local x, y, z = target.Transform:GetWorldPosition()
    local exclude_tags = {'FX', 'NOCLICK', 'INLIMBO', 'player', 'wall', "companion"}
    local ents = TheSim:FindEntities(x, 0, z, 4, { "_combat" }, exclude_tags) 
    for k, v in ipairs(ents) do
        if v and v.components.combat and v ~= target and owner.replica.combat:CanTarget(v) and not owner.replica.combat:IsAlly(v) then
            v.components.combat:GetAttacked(owner, damage/2)
        end    
    end
    end

    if target then
    local fx = SpawnPrefab("bcj_sword_fx")
    fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end	
end	

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_sword")
    inst.AnimState:SetBuild("bcj_sword")
    inst.AnimState:PlayAnimation("idle"..name, true)  --c_spawn"bcj_sword1".AnimState:PlayAnimation("idle2", true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")
    inst:AddTag(name)
    inst:AddTag("bcj_sword")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.shadow_mult = mult
    inst.atk_spd = 0

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(damage)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetRange(range)
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

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_sword"..name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_sword"..name..".xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = dapperness

    if name == "3" then
    inst.components.equippable.restrictedtag = "bcj"
    end
    --inst.components.equippable.walkspeedmult = speed 

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(use)
    inst.components.finiteuses:SetUses(use)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
--[[
    if name ~= "gyc_tmj1" then
    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    end
]]
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_sword"..name, fn, assets)
end   

return MakeSword("1", 40, 0.5, 1.2, 200, -0.5),  
       MakeSword("2", 56, 0.75, 1.3, 200, -1),
       MakeSword("3", 72, 1, 1.35, 200, 0)
           