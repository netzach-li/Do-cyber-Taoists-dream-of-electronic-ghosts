local assets =
{
    Asset("ANIM", "anim/my.zip")
}

local function onload(inst,data)
	if data and data.give_dwq then
		inst.give_dwq = data.give_dwq
	end
end

local function onsave(inst,data)
	data.give_dwq = inst.give_dwq
end

local function OnNear(inst, player)
    if inst.give_dwq == false then
    inst.give_dwq = true    
    inst.components.lootdropper:SpawnLootPrefab("my_cd_dwq")
    end

    if inst.talk_task == nil and inst.talk_end_task == nil then
        inst.AnimState:PlayAnimation("dial_loop")
        inst.AnimState:PushAnimation("idle_loop", true)     
        inst.components.talker:Say(STRINGS.BCJ_CD1_SPEECH[math.random(1, 10)])

        inst.talk_task = inst:DoPeriodicTask(2, function(inst)
        inst.AnimState:PlayAnimation("dial_loop")
        inst.AnimState:PushAnimation("idle_loop", true)    
        inst.components.talker:Say(STRINGS.BCJ_CD1_SPEECH[math.random(1, 10)])
        end)

        inst.talk_end_task = inst:DoTaskInTime(10, function(inst)
            if inst.talk_task then
                inst.talk_task:Cancel()
                inst.talk_task = nil 
            end    
            if inst.talk_end_task then
                inst.talk_end_task:Cancel()
                inst.talk_end_task = nil
            end    
        end)
    end   
end

local function OnFar(inst, player)
    if inst.talk_task then
        inst.talk_task:Cancel()
        inst.talk_task = nil 
    end    
    if inst.talk_end_task then
        inst.talk_end_task:Cancel()
        inst.talk_end_task = nil
    end 
end

local GiftTable = {  
    "gears",
    "purplegem",
    "bluegem",
    "redgem",
    "orangegem",
    "yellowgem",
    "greengem",
    "opalpreciousgem",
    "amulet",
    "goldnugget"
}

local function SpawnGift(inst)
    if math.random() > 0.5 then
        inst.components.lootdropper:SpawnLootPrefab(GiftTable[math.random(#GiftTable)])
    else
        local item = PickRandomTrinket()
        if item ~= nil then
            inst.components.lootdropper:SpawnLootPrefab(item)
        end
    end    
end

local function isOnWater(x, y, z)
    if not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) and not TheWorld.Map:GetPlatformAtPoint(x, z) then
        return true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst:AddTag("character")    
    inst:AddTag("notraptrigger")
    inst:AddTag("scarytoprey")
    inst:AddTag("companion")

   -- MakeCharacterPhysics(inst, 75, .5)
    MakeObstaclePhysics(inst, .5)
    inst.DynamicShadow:SetSize(1.3, .6)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("my")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")

    inst.AnimState:Hide("HEAD")
    inst.AnimState:Show("HEAD_HAT")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:StopIgnoringAll()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.give_dwq = false
    inst.give_gift = false

    inst:AddComponent("inspectable") 

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)               
        if data.name == "tele_time" then
            --print("时间到了")

            local fx = SpawnPrefab("spawn_fx_medium") 
            fx.Transform:SetPosition(inst:GetPosition():Get()) 

            local dwq = c_findnext("my_cd_dwq_jz")
            local x, z = 0, 0
            if math.random() >= 0.5 and dwq and dwq:IsValid() then
            local dwq_x, dwq_y, dwq_z = dwq.Transform:GetWorldPosition()

            for i = 1, 10 do    
            x = math.random(3, 16)
            z = math.random(3, 16)
            if math.random() > 0.5 then x = -x end
            if math.random() > 0.5 then z = -z end
            --print("传到定位器这里了")

            if not isOnWater(dwq_x + x, 0, dwq_z + z) then
            inst.Transform:SetPosition(dwq_x + x, 0, dwq_z + z)

            if math.random() >= 0.5 then
            SpawnGift(inst) 
            end             
            break
            end
            end

            --if math.random() >= 0.5 then
            --SpawnGive(inst) 
            --end    
            else
            for i = 1, 10 do     
            x = math.random(1, 600)
            z = math.random(1, 600)
            if math.random() > 0.5 then x = -x end
            if math.random() > 0.5 then z = -z end
            --print("传到其他位置了")
            if not isOnWater(x, 0, z) then
            inst.Transform:SetPosition(x, 0, z)
            break
            end
            end
            end

            inst.give_gift = false
            inst.components.timer:StartTimer("tele_time", 600)

            local fx = SpawnPrefab("spawn_fx_medium") 
            fx.Transform:SetPosition(inst:GetPosition():Get())  
        end
    end)

    local time = inst.components.timer:GetTimeLeft("tele_time") or 0
    inst:DoTaskInTime(1, function(inst)
        if time == 0 then
        inst.components.timer:StartTimer("tele_time", 600)
        end     
    end)   

    inst:AddComponent("lootdropper")

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(8, 10)
    inst.components.playerprox:SetOnPlayerFar(OnFar)
    inst.components.playerprox:SetOnPlayerNear(OnNear)

    inst:DoTaskInTime(0, function(inst)
        if c_countprefabs("my_cd", true) >= 2 then
            inst:Remove()
        end
    end)    

	inst.OnSave = onsave
	inst.OnLoad = onload    

    return inst
end

local function ondeploy(inst, pt)--, deployer)
    local ent = SpawnPrefab("my_cd_dwq_jz")
    inst:Remove()

    ent.Transform:SetPosition(pt:Get())
    ent.SoundEmitter:PlaySound("dontstarve/common/sign_craft")
end

local function item()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sign_mini")
    inst.AnimState:SetBuild("sign_mini")
    inst.AnimState:PlayAnimation("item")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "minisign_item"
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"   

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    return inst
end

local function jz()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sign_mini")
    inst.AnimState:SetBuild("sign_mini")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst
end

return Prefab("my_cd", fn, assets),
       Prefab("my_cd_dwq", item, assets),
       Prefab("my_cd_dwq_jz", jz, assets),
       MakePlacer("my_cd_dwq_placer", "sign_mini", "sign_mini", "idle")
