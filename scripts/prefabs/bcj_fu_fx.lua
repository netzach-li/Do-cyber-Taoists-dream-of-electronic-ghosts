local function MakeFx(name, bank)
local assets =
{
	Asset("ANIM", "anim/"..bank..".zip")  
}

local function fn()
    local inst = CreateEntity() 

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(bank)  
    inst.AnimState:PlayAnimation("idle")

    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    --inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("bcj_fu_fx"..name, fn, assets)
end   

return MakeFx("1", "bcj_fu1_fx"),
       MakeFx("2", "bcj_fu2_fx"),
       MakeFx("3", "bcj_fu3_fx"),
       MakeFx("4", "bcj_fu4_fx"),
       MakeFx("5", "bcj_fu5_fx")     
