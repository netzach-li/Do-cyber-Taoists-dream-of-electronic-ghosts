local assets =
{
    Asset("ANIM", "anim/444.zip"),  
    Asset("ATLAS", "images/inventoryimages/bcj_444.xml") 
} 

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("444")
    inst.AnimState:SetBuild("444")
    inst.Transform:SetScale(1.5, 1.5, 1.5) 

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("bcj_444_pet", fn, assets)
