local function MakeItem(name, stackable, castspell)
local assets =
{
	Asset("ANIM", "anim/bcj_cl.zip"),
    Asset("ATLAS", "images/inventoryimages/bcj_cl"..name..".xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/bcj_cl"..name..".xml", 256)  
}

local function OnPack(inst, unpackedEntity)
    local pt = inst:GetPosition()
    SpawnPrefab("die_fx").Transform:SetPosition(pt:Get())
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_cl")
    inst.AnimState:SetBuild("bcj_cl")  
    inst.AnimState:PlayAnimation(name, true)

    --inst:AddTag("archetto_item")
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    --inst.Transform:SetScale(1.6, 1.6, 1.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_cl"..name
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_cl"..name..".xml"

    inst:AddComponent("tradable")

    if stackable then
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
    end 

    if name == "1" then
    inst:AddComponent("package")
    inst.components.package:SetOnPackFn(OnPack)
    end    

    if name == "3" then
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    end

    if name == "8" then
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 6
    inst.components.edible.hungervalue = 10.5
    inst.components.edible.sanityvalue = 5
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_cl"..name, fn, assets)
end   

return MakeItem("1"),
       MakeItem("2", true),
       MakeItem("3", true),
       MakeItem("4", true),
       MakeItem("5", true),
       MakeItem("6", true),
       MakeItem("7", true),
       MakeItem("8", true),
       --MakeItem("9"),
       MakeItem("10", true),
       MakeItem("11", true)       
