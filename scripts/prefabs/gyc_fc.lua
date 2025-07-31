local assets =
{
    Asset("ANIM", "anim/swap_gyc_fc.zip"),
    Asset("ATLAS", "images/inventoryimages/gyc_fc.xml"),
}

local function onblink(staff, pos, caster)
    if caster then
        if caster.components.staffsanity then
            caster.components.staffsanity:DoCastingDelta(-TUNING.SANITY_MED)
        elseif caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-TUNING.SANITY_MED)
        end
    end
end

local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local function blinkstaff_reticuletargetfn()
    return ControllerReticle_Blink_GetPosition(ThePlayer, NoHoles)
end


local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_gyc_fc", "swap_bcj_fc")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("swap_gyc_fc")
    inst.AnimState:SetBuild("swap_gyc_fc")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "small")

    inst.scrapbook_subcat = "tool"

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = blinkstaff_reticuletargetfn
    inst.components.reticule.ease = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = {1, 145/255, 0}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff:SetFX("sand_puff_large_front", "sand_puff_large_back")
    inst.components.blinkstaff.onblinkfn = onblink

    inst.scrapbook_animoffsetx = 30

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "gyc_fc"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/gyc_fc.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("gyc_fc", fn, assets)
