local skill_range = 12

local ShadowAnimal = {
    minotaur = true,
    stalker = true,
    stalker_forest = true,
    stalker_atrium = true
}

local function MakeSword(name, use, shadow_size, water, hel_abo)
local assets =
{
    Asset("ANIM", "anim/bcj_san.zip"),  
    Asset("ANIM", "anim/swap_bcj_san.zip"), 
    Asset("ATLAS", "images/inventoryimages/bcj_san"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/bcj_san"..name..".xml", 256)   
}

local function IsRiding(inst)
    return inst.replica.rider and inst.replica.rider:IsRiding() or false
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_bcj_san", "swap_bcj_san"..name) 
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.DynamicShadow:SetSize(2.2*shadow_size, 1.4*shadow_size)

    if inst.components.fueled then
    inst.components.fueled:StartConsuming() 
    end

    if name == "3" then
    inst.Light:Enable(true)
    end      
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal") 

    owner.DynamicShadow:SetSize(1.3, 0.6)

    if inst.components.fueled then
    inst.components.fueled:StartConsuming() 
    end        
end

--桃木枝修复5%，紫宝石修复5%，雷击木修复10%，橙黄绿宝石修复10%，彩虹宝石修复15%

local RepairTable = {
    bcj_san1 = {silk = 0.1},
    bcj_san2 = {nightmarefuel = 0.1},
}

local function CanTakeItem(inst, ammo, giver)
    return RepairTable[inst.prefab][ammo.prefab] ~= nil and inst.components.fueled:GetPercent() < 1
end

local function OnGetItemFromPlayer(inst, giver, item)  
    if item and RepairTable[inst.prefab][item.prefab] ~= nil and inst.components.fueled:GetPercent() < 1 then
        local rapair_amount = RepairTable[inst.prefab][item.prefab] or 0.1
        local percent = inst.components.fueled:GetPercent() + 0.1
        if percent > 1 then percent = 1 end

        
        --print(RepairTable[inst.prefab][item.prefab])
        --print(rapair_amount)
        inst.components.fueled:SetPercent(percent)
        inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")    
    end      
end

local function onperish(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data =
            {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            inst:Remove()
            owner:PushEvent("umbrellaranout", data)
            return
        end
    end
    inst:Remove()
end

local function SeasonChange(inst)
    if TheWorld.state.isspring or TheWorld.state.iswinter then
        inst.components.insulator:SetWinter() 
    else
        inst.components.insulator:SetSummer()    
    end
end

local function turnon(inst)
    inst.components.raindome:Enable()
    inst.components.inventoryitem.canbepickedup = false
    inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")

    inst.AnimState:SetBank("swap_bcj_san")
    inst.AnimState:SetBuild("swap_bcj_san")
    inst.AnimState:PlayAnimation("BUILD3", true)
end

local function turnoff(inst)
    inst.components.raindome:Disable()
    inst.components.inventoryitem.canbepickedup = true
    inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_close")

    inst.AnimState:SetBank("bcj_san")
    inst.AnimState:SetBuild("bcj_san")
    inst.AnimState:PlayAnimation("idle3", true) 
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_san")
    inst.AnimState:SetBuild("bcj_san")
    inst.AnimState:PlayAnimation("idle"..name, true)  --c_spawn"bcj_sword1".AnimState:PlayAnimation("idle2", true)

    inst:AddTag("bcj_san")
    inst:AddTag("nopunch")
    inst:AddTag("umbrella")
    inst:AddTag("waterproofer")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    if name == "3" then
    inst:AddTag("bcj_san3")

    inst.entity:AddLight()
    inst.Light:SetFalloff(0.55)  --衰减
    inst.Light:SetIntensity(.7) --亮度
    inst.Light:SetRadius(2)     --半径
    inst.Light:SetColour(237/255, 237/255, 209/255)

    inst:AddComponent("raindome")     
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.hel_abo = hel_abo

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_san"..name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_san"..name..".xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "bcj"
    inst.components.equippable.walkspeedmult = name == "3" and 1.25 or 1 

    inst:AddComponent("waterproofer") 
    inst.components.waterproofer:SetEffectiveness(water)

    --inst:AddComponent("insulator")
    --inst.components.insulator:SetSummer()

    if name ~= "3" then
    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:InitializeFuelLevel(use)
    else
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.NET)

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst:WatchWorldState("isspring", SeasonChange)
    inst:WatchWorldState("issummer", SeasonChange)
    inst:WatchWorldState("isautumn", SeasonChange)
    inst:WatchWorldState("iswinter", SeasonChange)
    inst:DoTaskInTime(0, SeasonChange)

    inst.components.raindome:SetRadius(TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS)

    inst:AddComponent("machine")
    inst.components.machine:SetGroundOnlyMachine(true)
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0.5
    end


    if name ~= "3" then
    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_san"..name, fn, assets)
end   

return MakeSword("1", 480 * 3, 1, 0.3, 0.5),  
       MakeSword("2", 480 * 15, 1.2, 0.7, 0.2),
       MakeSword("3", 480 * 15, 1.35, 1, 0) --(name, use, shadow_size, water, hel_abo)
           