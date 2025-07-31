local assets =
{  
    Asset("ANIM", "anim/swap_bcj_ym.zip"), 
    Asset("ATLAS", "images/inventoryimages/bcj_ym.xml"), 
}


local function onequip(inst, owner)
    inst.components.equippable.dapperness = owner.prefab == "bcj" and 0 or -10/60
    owner.AnimState:OverrideSymbol("swap_object", "swap_bcj_ym", "swap_bcj_ym") 
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")   
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")      
end

--桃木枝修复5%，紫宝石修复5%，雷击木修复10%，橙黄绿宝石修复10%，彩虹宝石修复15%

local RepairTable = {
    bcj_ym = {livinglog = 0.25, bcj_ghost_soul = 0.5},
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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("tool")
    inst:AddTag("bcj_ym")
    inst:AddTag("fishingrod")

    inst:AddTag("weapon")

    inst.AnimState:SetBank("swap_bcj_ym")
    inst.AnimState:SetBuild("swap_bcj_ym")
    inst.AnimState:PlayAnimation("idle", true) 

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_ym"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_ym.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = 0
    --inst.components.equippable.walkspeedmult = speed 

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1)
    inst.components.tool:SetAction(ACTIONS.MINE, 1)
    inst.components.tool:SetAction(ACTIONS.HAMMER, 1)
    inst.components.tool:SetAction(ACTIONS.DIG, 1)
    inst.components.tool:SetAction(ACTIONS.NET)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(4, 40)
    inst.components.fishingrod:SetStrainTimes(0, 5)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_ym", fn, assets)

           