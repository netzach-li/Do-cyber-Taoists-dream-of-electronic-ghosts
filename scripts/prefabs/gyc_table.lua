local assets =
{
	Asset("ANIM", "anim/bcj_table.zip"),
    Asset("ANIM", "anim/gyc_table.zip"),     
}

local prefabs =
{
    "lavaarena_creature_teleport_smoke_fx_1",
}


local function MakeTable(name, constructionsite_prefab)

local function StartConstructed(inst, doer)
    if doer and doer.prefab ~= "gyc" and doer.sg then
        doer:DoTaskInTime(0, function()
        	doer.sg:GoToState("idle")
        end)
        doer.components.talker:Say("只能由古宇辰建造、。")
    end 	
end

local function OnConstructed(inst, doer)
    local concluded = true
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end

    if concluded then
    	local x, y, z = inst.Transform:GetWorldPosition()
    	inst:Remove() 
        local newhouse = SpawnPrefab(constructionsite_prefab)
        newhouse.Transform:SetPosition(x, y, z)

        local fx = SpawnPrefab("lavaarena_creature_teleport_smoke_fx_1")
        fx.Transform:SetPosition(x, 2, z)

        if doer and doer.prefab == "gyc" then
           doer:DoLevelUp1() 
           doer:DoLevelUp2() 
        end     
    end
end

local function fn()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    if name ~= "6" then
    inst:AddTag("constructionsite")
    end	

    inst.nameoverride = "gyc_table" 

    inst.Light:SetFalloff(1)  
    inst.Light:SetIntensity(.6) 
    inst.Light:SetRadius(2.5)    
    inst.Light:SetColour(1, 1, 1)
    inst.Light:Enable(true) 

    inst.AnimState:SetBank("gyc_table")
    inst.AnimState:SetBuild("gyc_table") 
    inst.AnimState:PlayAnimation("idle", true)

    MakeObstaclePhysics(inst, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "gyc_table" 

    inst:AddComponent("lootdropper")
--[[
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP) 
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(on_chop_up)
    inst.components.workable:SetOnWorkCallback(chop_tree)
]]


    inst:DoPeriodicTask(0.5, function(inst)
        if TheWorld.state.isday then
            inst.Light:Enable(false)
        else
            inst.Light:Enable(true)             
        end     
    end)

    if name ~= "6" then
        inst:AddComponent("constructionsite")
        inst.components.constructionsite:SetConstructionPrefab("construction_container")
        inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
        inst.components.constructionsite:SetOnStartConstructionFn(StartConstructed)
    end

    return inst 
end

return Prefab("gyc_table"..name, fn, assets, prefabs)
end    

return MakeTable("1", "gyc_table2"),
       MakeTable("2", "gyc_table3"),
       MakeTable("3", "gyc_table4"),
       MakeTable("4", "gyc_table5"),
       MakeTable("5", "gyc_table6"),
       MakeTable("6")       