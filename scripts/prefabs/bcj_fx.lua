
local assets =
{
	Asset("ANIM", "anim/bcj_sword_fx.zip"),
    Asset("ANIM", "anim/bcj_gun_fx.zip"),
    Asset("ANIM", "anim/gyc_mb_fx.zip"),
    Asset("ANIM", "anim/gyc_tmj_fx.zip")         
}

local function bcj_sword_fx()
    local inst = CreateEntity() 

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("bcj_sword_fx")
    inst.AnimState:SetBuild("bcj_sword_fx")  
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function bcj_gun_fx()
    local inst = CreateEntity() 

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("bcj_gun_fx")
    inst.AnimState:SetBuild("bcj_gun_fx")  
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function gyc_mb_fx()
    local inst = CreateEntity() 

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("gyc_mb_fx")
    inst.AnimState:SetBuild("gyc_mb_fx")  
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function gyc_tmj_fx()
    local inst = CreateEntity() 

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("gyc_tmj_fx")
    inst.AnimState:SetBuild("gyc_tmj_fx")  
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("bcj_sword_fx", bcj_sword_fx, assets),
       Prefab("bcj_gun_fx", bcj_gun_fx, assets),
       Prefab("gyc_mb_fx", gyc_mb_fx, assets),
       Prefab("gyc_tmj_fx", gyc_tmj_fx, assets) 
