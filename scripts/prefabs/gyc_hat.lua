local assets =
{
    Asset("ANIM", "anim/gyc_hat.zip"),
    Asset("ANIM", "anim/gyc_eq_hat.zip"),
    Asset("ATLAS", "images/inventoryimages/gyc_hat.xml") 
}

local function onequip(inst, owner)
    owner:DoTaskInTime(0, function()
        owner.AnimState:OverrideSymbol("headbase", "gyc_eq_hat", "headbase")
        owner.AnimState:OverrideSymbol("headbase_hat", "gyc_eq_hat", "headbase_hat")
    end)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end        
end 

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("headbase")
    owner.AnimState:ClearOverrideSymbol("headbase_hat")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end          
end  

local function FuelChange(inst, data)
    if data and data.percent then
    if data.percent > 0 then
        if not inst:HasTag("gyc_power_hat") then
            inst:AddTag("gyc_power_hat")
        end    
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
    else
        if inst:HasTag("gyc_power_hat") then
            inst:RemoveTag("gyc_power_hat")
        end 
        inst.components.insulator:SetInsulation(0)
        inst.components.equippable.dapperness = 0
    end    
    end    
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("gyc_hat")
    inst.AnimState:SetBuild("gyc_hat")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hat")  
    inst:AddTag("gyc_hat")
    inst:AddTag("gyc_power_hat")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gyc_hat"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gyc_hat.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
    inst.components.equippable.restrictedtag = "gyc" 

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
    --inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:ListenForEvent("percentusedchange", FuelChange)

    return inst
end

return Prefab("gyc_hat", fn, assets, prefabs)
