require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/coldfirepit.zip"),
}

local prefabs =
{
    "coldfirefire",
    "collapse_small",
    "ash",
}

local function onhammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("ash").Transform:SetPosition(x, y, z)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onextinguish(inst)
    if inst.components.fueled ~= nil then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function ontakefuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function updatefuelrate(inst)
	inst.components.fueled.rate = TheWorld.state.israining and inst.components.rainimmunity == nil and 1 + TUNING.COLDFIREPIT_RAIN_RATE * TheWorld.state.precipitationrate or 1
end

local function onupdatefueled(inst)
    if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
        updatefuelrate(inst)
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        inst.components.burnable:Extinguish()
    else
        if not inst.components.burnable:IsBurning() then
            updatefuelrate(inst)
            inst.components.burnable:Ignite()
        end
        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())
    end
end

local function ItemTradeTest(inst, item)
    if item and (item.prefab == "charcoal" or item.prefab == "nightmarefuel" or item.prefab == "bcj_ghost_soul") then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item and (item.prefab == "charcoal" or item.prefab == "nightmarefuel" or item.prefab == "bcj_ghost_soul") then
        local del = (item.prefab == "charcoal" and 0.05) or (item.prefab == "nightmarefuel" and 0.1) or 0.5
        inst.components.fueled:DoDelta(TUNING.COLDFIREPIT_FUEL_MAX * del)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
        inst.components.fueled:StartConsuming()
       -- inst.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
end

local SECTION_STATUS =
{
    [0] = "OUT",
    [1] = "EMBERS",
    [2] = "LOW",
    [3] = "NORMAL",
    [4] = "HIGH",
}
local function getstatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE and
        inst.components.fueled ~= nil and
        not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(TUNING.MED_FUEL)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    --#HAUNTFIX
    --elseif math.random() <= TUNING.HAUNT_CHANCE_HALF and
        --inst.components.workable ~= nil and
        --inst.components.workable:CanBeWorked() then
        --inst.components.workable:WorkedBy(haunter, 1)
        --inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        --return true
    end
    return false
end

local function OnInit(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:FixFX()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("coldfirepit.png")
    inst.MiniMapEntity:SetPriority(1)

    inst.AnimState:SetBank("bcj_jianzhu")
    inst.AnimState:SetBuild("bcj_jianzhu") 
    inst.AnimState:PlayAnimation("6", false)

    inst:AddTag("campfire")
    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")
    inst:AddTag("blueflame")

	-- for storytellingprop component
	inst:AddTag("storytellingprop")

	inst:SetDeploySmartRadius(1.25) --recipe min_spacing/2
    MakeObstaclePhysics(inst, .3)
    --inst.Transform:SetFourFaced()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("coldfirefire", Vector3(0, 2.2, 0))
    inst:ListenForEvent("onextinguish", onextinguish)

    -------------------------
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.COLDFIREPIT_FUEL_MAX
    inst.components.fueled.accepting = true
    inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL
    inst.components.fueled:SetSections(4)
    inst.components.fueled.bonusmult = TUNING.COLDFIREPIT_BONUS_MULT
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.COLDFIREPIT_FUEL_START)

    -----------------------------
    inst:AddComponent("storytellingprop")

    -----------------------------
    inst:AddComponent("cooker")

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:DoTaskInTime(0, OnInit)

    inst.restart_firepit = function( inst )
        local fuel_percent = inst.components.fueled:GetPercent()
        inst.components.fueled:MakeEmpty()
        inst.components.fueled:SetPercent( fuel_percent )
    end

    return inst
end

return Prefab("bcj_jianzhu6", fn, assets, prefabs),  --c_findnext("bcj_jianzhu6", 4).Transform:SetScale(1.2, 1, 1.2)
       MakePlacer("bcj_jianzhu6_placer", "bcj_jianzhu", "bcj_jianzhu", "6")
