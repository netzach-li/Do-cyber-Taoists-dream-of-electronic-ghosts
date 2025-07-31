local assets =
{
    
    Asset("ANIM", "anim/bcj_glass.zip"),  
    Asset("ATLAS", "images/inventoryimages/bcj_glass.xml") 
} 

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", "bcj_glass", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")

    owner:AddTag("reader")
    owner:AddTag("bookbuilder")
    if owner.components.reader == nil then
    owner:AddComponent("reader")
    end
    owner.components.builder.science_bonus = 1
    owner.components.builder.magic_bonus = 1  

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end        
end 

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    owner:RemoveTag("reader")
    owner:RemoveTag("bookbuilder")
    if owner.components.reader then
    owner:RemoveComponent("reader")
    end
    owner.components.builder.science_bonus = 0
    owner.components.builder.magic_bonus = 0 

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end         
end  

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_glass")
    inst.AnimState:SetBuild("bcj_glass")
    inst.AnimState:PlayAnimation("idle", true)  

    inst:AddTag("hat")
    inst:AddTag("bcj_glass")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_glass"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_glass.xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "bcj"
    inst.components.equippable.dapperness = 30/60

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_glass", fn, assets)