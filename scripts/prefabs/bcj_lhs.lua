local assets =
{
	Asset("ANIM", "anim/bcj_lhs.zip"),
    Asset("ANIM", "anim/bcj_lhs_big.zip"), 
    --Asset("ANIM", "anim/gyc_kulou_body.zip"), 
    Asset("ANIM", "anim/swap_dug_bcj_lhs.zip"),
    Asset("ANIM", "anim/bcj_cl1_full.zip"),
    Asset("ANIM", "anim/swap_bcj_cl1_full.zip"),
    Asset("ATLAS", "images/inventoryimages/bcj_ghost_soul.xml"),
    Asset("ATLAS", "images/inventoryimages/bcj_cl1_full.xml"),
    Asset("ATLAS", "images/inventoryimages/dug_bcj_lhs.xml"),      
}

local BUSH_ANIMS =
{
    --{ idle="level_b_loop", grow = "level_b_loop" },
    { idle="1", grow = "2" },
    { idle="2", grow = "3" },
    { idle="3", grow = "4" },
}

local function play_idle(inst, stage)   
    inst.AnimState:PlayAnimation(stage, true)
    inst.components.growable:StartGrowing()
end

local function play_grow(inst, stage)   
    inst.AnimState:PushAnimation(stage, true)
end

local function set_stage1(inst)
    play_idle(inst, 1)
end

local function grow_to_stage1(inst)
    play_grow(inst, 1)
end

local function set_stage2(inst)
    play_idle(inst, 2)
end

local function grow_to_stage2(inst)
    play_grow(inst, 2)
end

local function set_stage3(inst)
    play_idle(inst, 3)
end

local function grow_to_stage3(inst)
    play_grow(inst, 3)
end

local function set_stage4(inst)
    play_idle(inst, 4)
end

local function grow_to_stage4(inst)
    --play_grow(inst, 4)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst:Remove()
    SpawnPrefab("bcj_lhs_big").Transform:SetPosition(x, 0, z)
end

local STAGE1 = "stage_1"
local STAGE2 = "stage_2"
local STAGE3 = "stage_3"
local STAGE4 = "stage_4"

local growth_stages =
{
    {
        name = STAGE1,
        time = function(inst) return 480 * 10 end,
        fn = set_stage1,
        growfn = grow_to_stage1,
    },
    {
        name = STAGE2,
        time = function(inst) return 480 * 10 end,
        fn = set_stage2,
        growfn = grow_to_stage2,
    },
    {
        name = STAGE3,
        time = function(inst) return 480 * 10 end,
        fn = set_stage3,
        growfn = grow_to_stage3,
    },
    {
        name = STAGE4,
        time = function(inst) return 480 * 1 end,
        fn = set_stage4,
        growfn = grow_to_stage4,
    },    
}

local function chop_tree(inst, chopper, chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
end

local function on_chop_up(inst, digger)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    inst.choped = true
    --if inst.components.pickable:CanBePicked() then
       -- onpickedfn(inst, digger)
    --end
    inst:Remove()
end 

local function ItemTradeTest(inst, item)
    if item and item.prefab == "treegrowthsolution" then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)------------给金子回耐久
    if item and item.prefab == "treegrowthsolution" then
        inst.components.growable:ExtendGrowTime(-480 * 3)

        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("treegrowthsolution_use_fx").Transform:SetPosition(x, 0, z) 
        inst.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
end

local function fn()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_lhs")
    inst.AnimState:SetBuild("bcj_lhs") 
    inst.MiniMapEntity:SetIcon("bcj_lhs.tex") 
    --inst.AnimState:PlayAnimation(name, true)
--[[
    if name ~= "5" then
    inst.AnimState:SetBank("bcj_lhs")
    inst.AnimState:SetBuild("bcj_lhs")  
    inst.AnimState:PlayAnimation(name, true)
    else
    inst.AnimState:SetBank("bcj_lhs_big")
    inst.AnimState:SetBuild("bcj_lhs_big")  
    inst.AnimState:PlayAnimation("idle", true)
    inst.Transform:SetScale(1.5, 1.5, 1.5)
    end
]]
    --inst:AddTag("archetto_item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable.loopstages = true
    inst.components.growable.magicgrowable = true
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP) 
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(on_chop_up)
    inst.components.workable:SetOnWorkCallback(chop_tree)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    inst:DoTaskInTime(0, function(inst)
        inst.components.growable:StartGrowing() 
    end)

    return inst
end

local MIN = TUNING.SHADE_CANOPY_RANGE - 6
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER - 6

local function OnFar(inst, player)
    if player.canopytrees then   
        player.canopytrees = player.canopytrees - 1
        player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
    end
    inst.players[player] = nil

    if player:HasTag("near_lhs") then
    --print("远离")
    player:RemoveTag("near_lhs") 
    end   
end

local function OnNear(inst,player)
    inst.players[player] = true
    player.canopytrees = (player.canopytrees or 0) + 1
    player:PushEvent("onchangecanopyzone", player.canopytrees > 0)

    if not player:HasTag("near_lhs") then
    --print("靠近")
    player:AddTag("near_lhs") 
    end     
end


local function fn_big()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_lhs_big")
    inst.AnimState:SetBuild("bcj_lhs_big")  
    inst.AnimState:PlayAnimation("idle", true)
    inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst.MiniMapEntity:SetIcon("bcj_lhs.tex")

    if not TheNet:IsDedicated() then
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15, 25)

        inst:AddComponent("canopyshadows")
        inst.components.canopyshadows.range = math.floor(TUNING.SHADE_CANOPY_RANGE/6)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("canopylightrays")
    inst.components.canopylightrays.range = math.floor(TUNING.SHADE_CANOPY_RANGE/6)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst.players = {}
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(MIN, MAX)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    inst.components.playerprox:SetOnPlayerNear(OnNear)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable:SetUp("bcj_cl3", 480)
    --inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.max_cycles = 10000
    inst.components.pickable.cycles_left = 10000

    inst:DoPeriodicTask(10, function()
        if TheWorld.state.issummer and math.random() > 0.1 then
            local x, y, z = inst.Transform:GetWorldPosition()
            local num = math.random(0, 6)
            if math.random() > 0.5 then num = -num end

            local num2 = math.random(0, 6)
            if math.random() > 0.5 then num2 = -num2 end
            local x, y, z = inst.Transform:GetWorldPosition()
            local flower = SpawnPrefab("bcj_cl2")
            flower.Transform:SetPosition(x+num, 5, z+num2)            
        end    
    end)    

    inst:DoPeriodicTask(30, function()
        local exclude_tags = {'INLIMBO'}
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, 0, z, 14, { "ghost_soul" }, exclude_tags) 
        local number = #ents or nil

        if math.random() > 0.5 and (TheWorld.state.isnight or TheWorld.state.iscavenight) and (number == nil or (number ~= nil and number < 10)) then
            local x, y, z = inst.Transform:GetWorldPosition()
            local num = math.random(1, 7)
            if math.random() > 0.5 then num = -num end

            local num2 = math.random(1, 7)
            if math.random() > 0.5 then num2 = -num2 end
            local x, y, z = inst.Transform:GetWorldPosition()
            local flower = SpawnPrefab("bcj_ghost_soul")
            flower.Transform:SetPosition(x+num, 5, z+num2)            
        end
    end)    

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP) 
    inst.components.workable:SetWorkLeft(9999)
    inst.components.workable:SetOnFinishCallback(on_chop_up)
    inst.components.workable:SetOnWorkCallback(chop_tree)

    return inst
end

local function fn_fx()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("oceantree_pillar")
    inst.AnimState:SetBuild("oceantree_pillar_build1")
    inst.AnimState:PlayAnimation("idle", true)

    --inst.AnimState:AddOverrideBuild("oceantree_pillar_build2")

    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function oversized_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_dug_bcj_lhs", "swap_body")
end

local function oversized_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function fn_dug()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("dug_lhs")
    inst:AddTag("heavy")
    inst:AddTag("irreplaceable")

    inst.AnimState:SetBank("bcj_lhs")
    inst.AnimState:SetBuild("bcj_lhs")  
    inst.AnimState:PlayAnimation("4", true)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dug_bcj_lhs"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dug_bcj_lhs.xml"
    inst.components.inventoryitem.cangoincontainer = false
    --inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(oversized_onequip)
    inst.components.equippable:SetOnUnequip(oversized_onunequip)
    inst.components.equippable.walkspeedmult = 0.3

    inst:AddComponent("tradable")

    --inst:AddComponent("stackable")
    --inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    MakeHauntableLaunch(inst)

    return inst
end

local function OnWorked(inst, worker)
    worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
end

local function fn_soul()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.Light:SetFalloff(.6)  --衰减
    inst.Light:SetIntensity(.4) --亮度
    inst.Light:SetRadius(1)     --半径
    inst.Light:SetColour(0, 183 / 255, 1)
    inst.Light:Enable(true)

    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("wortox_soul_ball")
    inst.AnimState:SetBuild("wortox_soul_ball")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(0, 0.2, 1, 0.5)
    --inst.AnimState:SetScale(SCALE, SCALE)

    inst:AddTag("ghost_soul")
    inst:AddTag("nosteal")
    --inst:AddTag("NOCLICK")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_ghost_soul"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_ghost_soul.xml"
    inst.components.inventoryitem.canbepickedup = false
    --inst.components.inventoryitem.canonlygoinpocket = true
    --inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("tradable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:DoPeriodicTask(1, function()
    if TheWorld.state.isday and not inst:HasTag("INLIMBO") then
        --inst:Remove()
        inst:ListenForEvent("animover", inst.Remove)
        inst.AnimState:PlayAnimation("idle_pst")
        inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    end
    end)    

    return inst
end

local function oversized_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_bcj_cl1_full", "swap_body")
end

local function oversized_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnPack(inst, unpackedEntity)
    local pt = inst:GetPosition()
    
    SpawnPrefab("die_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
end

local function OnUnpack(inst, unpacked, unpacker)
    local pt = inst:GetPosition()
    unpacker.components.inventory:GiveItem(SpawnPrefab("bcj_cl1"), nil, pt)

    if unpacker then
    unpacker.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
    end

    inst:Remove()
    SpawnPrefab("die_fx").Transform:SetPosition(pt:Get())
    --inst:Remove()
end

local function OnDrop(inst)
    inst.Physics:SetVel(0, 0, 0)
end

local function fn_box_full()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("full")
    inst:AddTag("heavy")
    inst:AddTag("irreplaceable")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    --MakeSmallHeavyObstaclePhysics(inst, 0.15)
    inst.AnimState:SetBank("bcj_cl1_full")
    inst.AnimState:SetBuild("bcj_cl1_full") 
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable") 

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_cl1_full"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_cl1_full.xml"
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem:SetSinks(true)
    --inst.components.inventoryitem:SetOnDroppedFn(OnDrop)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(oversized_onequip)
    inst.components.equippable:SetOnUnequip(oversized_onunequip)
    inst.components.equippable.walkspeedmult = 0.3
    inst.components.equippable.restrictedtag = "gyc"

    inst:AddComponent("package")
    inst.components.package:SetOnPackFn(OnPack)
    inst.components.package:SetOnUnpackFn(OnUnpack)

    return inst
end

return Prefab("bcj_lhs", fn, assets),
       Prefab("bcj_lhs_big", fn_big, assets),
       Prefab("dug_bcj_lhs", fn_dug, assets),
       Prefab("dug_bcj_lhs_fx", fn_fx, assets), 
       Prefab("bcj_ghost_soul", fn_soul, assets),
       Prefab("bcj_cl1_full", fn_box_full, assets)

