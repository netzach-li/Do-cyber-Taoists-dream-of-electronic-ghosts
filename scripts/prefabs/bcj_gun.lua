local assets =
{
    Asset("ANIM", "anim/bcj_gun.zip"),
    Asset("ANIM", "anim/swap_bcj_gun.zip"),
    Asset("ANIM", "anim/moluo_gun_project.zip"),
    Asset("ATLAS", "images/inventoryimages/bcj_gun.xml")    
}

local function OnProjectileLaunched(inst, attacker, target)
    if inst.components.container ~= nil then
        local ammo_stack = inst.components.container:GetItemInSlot(1)
        local item = inst.components.container:RemoveItem(ammo_stack, false)
        if item ~= nil then
            if item == ammo_stack then
                item:PushEvent("ammounloaded", {slingshot = inst})
            end

            item:Remove()
        end
    end
end
local function OnAmmoLoaded(inst, data)
    if inst.components.weapon ~= nil then
        if data ~= nil and data.item ~= nil then
            inst.components.weapon:SetProjectile("bcj_gun_project")
            data.item:PushEvent("ammoloaded", {slingshot = inst})
        end
    end
end

local function OnAmmoUnloaded(inst, data)
    if inst.components.weapon ~= nil then
        inst.components.weapon:SetProjectile(nil)
        if data ~= nil and data.prev_item ~= nil then
            data.prev_item:PushEvent("ammounloaded", {slingshot = inst})
        end
    end
end
 
local function onattack(inst, attacker, target)
    --print("攻击")
    local mth = math.random()
    if mth > 0.96 then
    inst.atk_time = 1
    elseif mth <= 0.99 and mth >= 0.5 then     
    inst.atk_time = 2
    else
    inst.atk_time = 3
    end
    print(inst.atk_time)
    inst.components.weapon:SetDamage(inst.atk_time ~= 3 and 50 or 0)
    inst.components.planardamage:SetBaseDamage(inst.atk_time ~= 3 and 18 or 0)

    print(inst.components.weapon.damage)
end    

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bcj_gun", "swap_handgun_albert")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end    
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function builder_onbuilt(inst, builder)
    for i = 1, 3 do
       local soul = SpawnPrefab("bcj_ghost_soul")
       inst.components.container:GiveItem(soul)
    end  
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_gun")
    inst.AnimState:SetBuild("bcj_gun")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst:AddTag("bcj_gun")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
        if inst.replica.container then
            inst.replica.container:WidgetSetup("bcj_gun")
        end    
        end
        return inst
    end

    inst.atk_time = 1

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(50)
    inst.components.weapon:SetRange(10)
    inst.components.weapon:SetProjectile("bcj_gun_project")
    --inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)

    local GetDamage = inst.components.weapon.GetDamage
    inst.components.weapon.GetDamage = function(self, attacker, target) 
        onattack(self.inst, attacker, target)
        local damage, spdamage = GetDamage(self, attacker, target)  

        return damage, spdamage
    end   

    local planardamage = inst:AddComponent("planardamage")
    planardamage:SetBaseDamage(18)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_gun"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_gun.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
    inst.components.equippable.restrictedtag = "bcj" 

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("bcj_gun")
    inst.components.container:EnableInfiniteStackSize(true)
    inst.components.container.canbeopened = false
    inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)

    inst:DoTaskInTime(0, function()    
        if inst.components.container:GetItemInSlot(1) == nil then
            inst.components.weapon:SetProjectile(nil)
        end
    end)

    inst.OnBuiltFn = builder_onbuilt
        
    MakeHauntableLaunch(inst)

    return inst
end

local function onhit(inst, attacker, target)
    if target == nil or attacker == nil then return end
    local weapon = attacker.components.combat ~= nil and attacker.components.combat:GetWeapon() or nil
    if weapon and weapon.prefab == "bcj_gun" then
    if weapon.atk_time == 1 then
        local fx = SpawnPrefab("bcj_gun_fx")
        fx.Transform:SetPosition(target:GetPosition():Get())

        if target.components.health and not target.components.health:IsDead() then
            target.components.health:Kill()
        end    
        attacker.components.talker:Say("我听到了【强运】的回响。”")

    elseif weapon.atk_time == 2 then
        local fx = SpawnPrefab("explosivehit")
        fx.Transform:SetPosition(target:GetPosition():Get())
    end

    --weapon.components.weapon:SetDamage(weapon.atk_time ~= 3 and 50 or 0)
    --weapon.components.planardamage:SetBaseDamage(weapon.atk_time ~= 3 and 18 or 0)
    end    

    inst:Remove()   
end

local function project()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    inst.AnimState:SetBank("moluo_gun_project")
    inst.AnimState:SetBuild("moluo_gun_project")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetLaunchOffset(Vector3(2, 0, 0))
    inst.components.projectile:SetOnHitFn(onhit)
    
    return inst
end


return Prefab("bcj_gun", fn, assets),
       Prefab("bcj_gun_project", project, assets)