local assets =
{
	Asset("ANIM", "anim/bcj_taos.zip") 
}

local BUSH_ANIMS =
{
    --{ idle="level_b_loop", grow = "level_b_loop" },
    { idle="1", grow = "2" },
    { idle="2", grow = "3" },
    { idle="3", grow = "1" },
}

local function play_idle(inst, stage)
	if inst.components.growable.stage == 3 then   --print(c_findnext("bcj_taos", 4).components.growable.stage)
		local anim = ((TheWorld.state.isautumn or TheWorld.state.iswinter) and "4") or (TheWorld.state.isspring and "3") or "5"
        inst.AnimState:PlayAnimation(anim, true)
        inst.components.growable:StopGrowing()
	else	
        inst.AnimState:PlayAnimation(stage, true)
        inst.components.growable:StartGrowing()
    end 
end

local function play_grow(inst, stage)
	if inst.components.growable.stage == 3 then 
		local anim = ((TheWorld.state.isautumn or TheWorld.state.iswinter) and "4") or (TheWorld.state.isspring and "4") or "5"
        inst.AnimState:PlayAnimation(anim, true)
        inst.components.growable:StopGrowing()
	else	
        inst.AnimState:PushAnimation(stage, true)
        inst.components.growable:StartGrowing()
    end
end

local function set_stage1(inst)
    play_idle(inst, 1)
    inst.Transform:SetScale(1.7, 1.7, 1.7)
    inst.components.pickable.canbepicked = false
end

local function grow_to_stage1(inst)
    play_grow(inst, 1)
    inst.Transform:SetScale(1.7, 1.7, 1.7)
    inst.components.pickable.canbepicked = false
end

local function set_stage2(inst)
    play_idle(inst, 2)
    inst.Transform:SetScale(1.2, 1.2, 1.2)
    inst.components.growable:StartGrowing()
    inst.components.pickable.canbepicked = false
end

local function grow_to_stage2(inst)
    play_grow(inst, 2)
    inst.Transform:SetScale(1.2, 1.2, 1.2)
    inst.components.growable:StartGrowing()
    inst.components.pickable.canbepicked = false
end

local function set_stage3(inst)
    play_idle(inst, 3)
    inst.Transform:SetScale(1.1, 1.1, 1.1)
    inst.components.growable:StopGrowing()
    inst.components.pickable.canbepicked = true
end

local function grow_to_stage3(inst)
    play_grow(inst, 3)
    inst.Transform:SetScale(1.1, 1.1, 1.1)
    inst.components.pickable:Regen()
    inst.components.pickable.canbepicked = true
    inst.components.growable:StopGrowing()
end

local STAGE1 = "stage_1"
local STAGE2 = "stage_2"
local STAGE3 = "stage_3"

local growth_stages =
{
    {
        name = STAGE1,
        time = function(inst) return TUNING.BERRY_REGROW_TIME end,
        fn = set_stage1,
        growfn = grow_to_stage1,
    },
    {
        name = STAGE2,
        time = function(inst) return TUNING.BERRY_REGROW_TIME end,
        fn = set_stage2,
        growfn = grow_to_stage2,
    },
    {
        name = STAGE3,
        time = function(inst) return TUNING.BERRY_REGROW_TIME end,
        fn = set_stage3,
        growfn = grow_to_stage3,
    },
}

local function onpickedfn(inst, picker)
    if inst.components.growable.stage == 3 then  --and picker and (picker.prefab ~= "bcj" or inst.choped)
        if TheWorld.state.isspring then	
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl6")
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl6")
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl6")
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl7")
            if math.random() >= 0.9 then
                inst.components.lootdropper:SpawnLootPrefab("gyc_tmj1")
            end

        elseif TheWorld.state.issummer then	
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl7")
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl8")
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl8")
            if math.random() >= 0.9 then
                inst.components.lootdropper:SpawnLootPrefab("gyc_tmj1")
            end

        elseif TheWorld.state.isautumn then	
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl7")
            if math.random() >= 0.8 then
                inst.components.lootdropper:SpawnLootPrefab("gyc_tmj1")
            end

        elseif TheWorld.state.iswinter then	
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl7")
            if math.random() >= 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("gyc_tmj1")
            end                                     
        end
    end

    inst.components.growable:SetStage(2)
end

local function SeasonChange(inst)
    if inst.components.growable.stage == 3 then
        play_idle(inst)
    end
end

local function chop_tree(inst, chopper, chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
end

local function on_chop_up(inst, digger)
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
	inst.choped = true
	if inst.components.pickable:CanBePicked() then
        onpickedfn(inst, digger)
    end
    inst:Remove()
end	

local function fn()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("taos")

    inst.AnimState:SetBank("bcj_taos")
    inst.AnimState:SetBuild("bcj_taos")   --c_findnext("bcj_taos", 4).AnimState:PlayAnimation("3", true)
    inst.AnimState:PlayAnimation("1", true)

    inst.MiniMapEntity:SetIcon("bcj_taos.tex")

    MakeObstaclePhysics(inst, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP) --c_spawn.components.growable:SetStage(1).Transform:SetScale(1.4, 1.4, 1.4)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(on_chop_up)
    inst.components.workable:SetOnWorkCallback(chop_tree)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.numtoharvest = 0
    inst.components.pickable.canbepicked = false
    inst.components.pickable.onpickedfn = onpickedfn

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable.loopstages = true
    inst.components.growable.magicgrowable = true
    inst.components.growable:SetStage(2)
    inst.components.growable:StartGrowing()

    SeasonChange(inst)
    inst:WatchWorldState("isspring", SeasonChange)
    inst:WatchWorldState("issummer", SeasonChange)
    inst:WatchWorldState("isautumn", SeasonChange)
    inst:WatchWorldState("iswinter", SeasonChange)

    inst:DoTaskInTime(0, function(inst)
        if inst.components.growable.stage < 3 then
            inst.components.growable:StartGrowing()
        end	
    end)	

    return inst
end

local function chop_tree(inst, chopper, chops)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
end

local function on_chop_up(inst, digger)
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    inst.components.lootdropper:SpawnLootPrefab("bcj_cl4")
    inst.components.lootdropper:SpawnLootPrefab("bcj_cl4")
    inst.components.lootdropper:SpawnLootPrefab("bcj_cl4")
    inst.components.lootdropper:SpawnLootPrefab("bcj_cl4")
    inst.components.lootdropper:SpawnLootPrefab("bcj_cl4")
    inst.components.lootdropper:SpawnLootPrefab("gyc_tmj1")

    inst:Remove()
end	

local function burnt()

    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("marsh_tree") 
    inst.AnimState:SetBuild("tree_marsh")
    inst.AnimState:PlayAnimation("burnt_idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP) 
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_chop_up)
    inst.components.workable:SetOnWorkCallback(chop_tree)

    return inst
end

return Prefab("bcj_taos", fn, assets),  
       Prefab("bcj_taos_burnt", burnt, assets)
 
