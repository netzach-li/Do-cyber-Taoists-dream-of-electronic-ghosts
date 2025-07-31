local assets =
{
	Asset("ANIM", "anim/bcj_table.zip"),
    Asset("ANIM", "anim/gyc_table.zip"),     
}

local prefabs =
{
    "lavaarena_creature_teleport_smoke_fx_1",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function temperaturetick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end
end

local function bcj()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("tent")

    inst.Light:SetFalloff(1)  
    inst.Light:SetIntensity(.6) 
    inst.Light:SetRadius(2.5)    
    inst.Light:SetColour(0, 0, 1)
    inst.Light:Enable(true) 

    inst.AnimState:SetBank("bcj_table")
    inst.AnimState:SetBuild("bcj_table") 
    inst.AnimState:PlayAnimation("idle", true)
    --inst.MiniMapEntity:SetIcon("bcj_lhs.tex") 

    MakeObstaclePhysics(inst, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("sleepingbag")
    --inst.components.sleepingbag.onsleep = onsleep
    --inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) 
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:DoPeriodicTask(0.5, function(inst)
        if TheWorld.state.isday or TheWorld.state.iscaveday then
            if not inst:HasTag("siestahut") then
                inst:AddTag("siestahut")
            end

            if TheWorld.state.isday then
                inst.Light:Enable(false)
            end 
            inst.components.sleepingbag:SetSleepPhase("day")
        else
            if inst:HasTag("siestahut") then
                inst:RemoveTag("siestahut")
            end
            inst.Light:Enable(true)             
            inst.components.sleepingbag:SetSleepPhase("night")
        end

        if inst.components.sleepingbag.sleeper then
        inst.AnimState:PlayAnimation("rest", true)
        else
        inst.AnimState:PlayAnimation("idle", true)
        end     
    end)
--[[
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
]]
    return inst
end

return Prefab("bcj_table", bcj, assets)
