local skill_range = 12

local function MakeBow(name, damage, range, speed, use)
local assets =
{
    
    Asset("ANIM", "anim/gyc_mb.zip"), 
	Asset("ANIM", "anim/swap_gyc_mb.zip"),  
    Asset("ATLAS", "images/inventoryimages/"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/"..name..".xml", 256)   
}

local function ReticuleTargetFn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(6.5, 0, 0))
end

local function ReticuleMouseTargetFn(inst, mousepos)
    if mousepos ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local dx = mousepos.x - x
        local dz = mousepos.z - z
        local l = dx * dx + dz * dz
        if l <= 0 then
            return inst.components.reticule.targetpos
        end
        l = 6.5 / math.sqrt(l)
        return Vector3(x + dx * l, 0, z + dz * l)
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end


local function IsRiding(inst)
    return inst.replica.rider and inst.replica.rider:IsRiding() or false
end

local function onattack(inst, owner, target)
    print("攻击了")
    if target then
    local fx = SpawnPrefab("gyc_mb_fx")
    fx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end    

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_gyc_mb", "swap_"..name) --ThePlayer.AnimState:OverrideSymbol("swap_remote", "swap_gyc_mb", "swap_gyc_mb3")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal") 

    if name == "gyc_mb3" then
        owner.AnimState:OverrideSymbol("swap_remote", "swap_gyc_mb", "swap_gyc_mb3")
    end    
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")   
end

local function slingshot2ex_SpellFn(inst, doer, pos)
    --[[
    local specialammo = inst.components.container:GetItemInSlot(2)
    if specialammo then
        local oldammo = inst.components.container:GetItemInSlot(1)
        if oldammo then
            oldammo:PushEvent("ammounloaded", { slingshot = inst })
        end
        inst.components.weapon:SetProjectile(specialammo.prefab.."_proj")
        specialammo:PushEvent("ammoloaded", { slingshot = inst })

        local x, y, z = doer.Transform:GetWorldPosition()
        local angle = pos.x == x and pos.z == z and doer.Transform:GetRotation() * DEGREES or math.atan2(z - pos.z, pos.x - x)
        local target = CreateTarget()
        target.Transform:SetPosition(x + math.cos(angle) * TARGET_RANGE, 0, z - math.sin(angle) * TARGET_RANGE)

        inst.overrideammoslot = 2
        inst.magicamplified = true
        inst.components.weapon:LaunchProjectile(doer, target)
        inst.magicamplified = nil
        inst.overrideammoslot = nil

        if specialammo:IsValid() then
            specialammo:PushEvent("ammounloaded", { slingshot = inst })
        end
        if oldammo then
            inst.components.weapon:SetProjectile(oldammo.prefab.."_proj")
            oldammo:PushEvent("ammoloaded", { slingshot = inst })
        else
            inst.components.weapon:SetProjectile(nil)
        end
    end
    ]]
end

local function slingshotex_RefreshChargeTicks(inst, reticule, ticks)
    if reticule.SetChargeScale then
        local scale = math.min(1, ticks * FRAMES / TUNING.SLINGSHOT_MAX_CHARGE_TIME)
        reticule:SetChargeScale(scale)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gyc_mb")
    inst.AnimState:SetBuild("gyc_mb")
    inst.AnimState:PlayAnimation(name, true)  --c_findnext("skd_sword")  .AnimState:PlayAnimation("gyc_mb2", true)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    inst:AddTag("weapon")

    inst:AddTag("rangedweapon")
    inst:AddTag(name)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    if name == "gyc_mb3" then

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(true)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelongmulti"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongmultiping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true

    --inst:AddComponent("aoecharging")
    --inst.components.aoecharging.reticuleprefab = "reticulecharging"
    --inst.components.aoecharging.pingprefab = "reticulelongping"
    --inst.components.aoecharging:SetEnabled(true)
    --inst.components.aoecharging:SetRefreshChargeTicksFn(slingshotex_RefreshChargeTicks)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst.base_range = range

    inst:AddComponent("weapon")
    inst.components.weapon:SetRange(range)  
    inst.components.weapon:SetDamage(damage)

    inst.components.weapon:SetOnAttack(onattack)
--[[    
    inst.components.weapon:SetProjectile("houndstooth_proj") 
    local GetDamage = inst.components.weapon.GetDamage
    inst.components.weapon.GetDamage = function(self, attacker, target) 
        local damage, spdamage = GetDamage(self, attacker, target) 
        if target and target:IsValid() then
        if (FlyAnimal[target.prefab] == true or target:HasTag("flying")) and inst.components.container:HasItemWithTag("archetto_chip2", 1) then
            local mult = (inst.components.container:Has("archetto_chip2_1", 1) and 1.1) or (inst.components.container:Has("archetto_chip2_2", 1) and 1.2)
            or (inst.components.container:Has("archetto_chip2_3", 1) and 1.3) or 1
            damage = damage * mult

        elseif (ShadowAnimal[target.prefab] == true or (target:HasTag("shadowcreature") or target:HasTag("shadow") or target:HasTag("shadowchesspiece") or target:HasTag("shadowthrall")))
        and inst.components.container:HasItemWithTag("archetto_chip1", 1) then
            local mult = (inst.components.container:Has("archetto_chip1_1", 1) and 1.1) or (inst.components.container:Has("archetto_chip1_2", 1) and 1.2)
            or (inst.components.container:Has("archetto_chip1_3", 1) and 1.3) or 1        
            damage = damage * mult
        end
        end    

        return damage, spdamage
    end   
]]

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/"..name..".xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "gyc"
    inst.components.equippable.walkspeedmult = speed 

    if name == "gyc_mb3" then
    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(slingshot2ex_SpellFn)
    end    

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab(name, fn, assets)
end   

return MakeBow("gyc_mb1", 20, 8, 1.15),
       MakeBow("gyc_mb2", 35, 8, 1.1),
       MakeBow("gyc_mb3", 40, 8, 1.1)