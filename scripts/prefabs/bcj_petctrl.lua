local assets =  
{  
    Asset("ANIM", "anim/moonrock_seed.zip"),
    Asset("ANIM", "anim/archetto_petctrlon.zip"),
    Asset("ANIM", "anim/archetto_petctrloff.zip"),

    Asset("ATLAS", "images/inventoryimages/archetto_petctrlon.xml"),
    Asset("ATLAS", "images/inventoryimages/archetto_petctrloff.xml"),
    Asset("ATLAS_BUILD", "images/inventoryimages/archetto_petctrlon.xml", 256), 
    Asset("ATLAS_BUILD", "images/inventoryimages/archetto_petctrloff.xml", 256)       
}

local UPGRADED_LIGHT_RADIUS = 2.5

local function updatelight(inst)
    inst._light = inst._light < inst._targetlight and math.min(inst._targetlight, inst._light + .04) or math.max(inst._targetlight, inst._light - .02)
    inst.AnimState:SetLightOverride(inst._light)
    inst.Light:SetRadius(UPGRADED_LIGHT_RADIUS * inst._light / inst._targetlight)
    if inst._light == inst._targetlight then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function fadelight(inst, target, instant)
    inst._targetlight = target
    if inst._light ~= target then
        if instant then
            if inst._task ~= nil then
                inst._task:Cancel()
                inst._task = nil
            end
            inst._light = target
            inst.AnimState:SetLightOverride(target)
            inst.Light:SetRadius(UPGRADED_LIGHT_RADIUS)
        elseif inst._task == nil then
            inst._task = inst:DoPeriodicTask(FRAMES, updatelight)
        end
    elseif inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end

local function cancelblink(inst)
    if inst._blinktask ~= nil then
        inst._blinktask:Cancel()
        inst._blinktask = nil
    end
end

local function updateblink(inst, data)
    local c = easing.outQuad(data.blink, 0, 1, 1)
    inst.AnimState:SetAddColour(c, c, c, 0)
    if data.blink > 0 then
        data.blink = math.max(0, data.blink - .05)
    else
        inst._blinktask:Cancel()
        inst._blinktask = nil
    end
end

local function blink(inst)
    if inst._blinktask ~= nil then
        inst._blinktask:Cancel()
    end
    local data = { blink = 1 }
    inst._blinktask = inst:DoPeriodicTask(FRAMES, updateblink, nil, data)
    updateblink(inst, data)
end

local function dodropsound(inst, taskid, volume)
    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, volume)
    inst._tasks[taskid] = nil
end

local function canceldropsounds(inst)
    local k, v = next(inst._tasks)
    while k ~= nil do
        v:Cancel()
        inst._tasks[k] = nil
        k, v = next(inst._tasks)
    end
end

local function scheduledropsounds(inst)
    inst._tasks[1] = inst:DoTaskInTime(6 * FRAMES, dodropsound, 1)
    inst._tasks[2] = inst:DoTaskInTime(13 * FRAMES, dodropsound, 2, .5)
    inst._tasks[3] = inst:DoTaskInTime(18 * FRAMES, dodropsound, 2, .15)
end

local function onturnon(inst)
    if not inst:IsInLimbo() then 
    canceldropsounds(inst)
    inst.AnimState:PlayAnimation("proximity_pre")
    inst.AnimState:PushAnimation("proximity_loop", true)
    if inst._upgraded then
        inst.Light:Enable(true)
    end
    fadelight(inst, .15, false)
    if not inst.SoundEmitter:PlayingSound("idlesound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/idle_LP", "idlesound")
    end
    end
end

local function onturnoff(inst)    
    canceldropsounds(inst)
    inst.Light:Enable(false)
    inst.Light:SetRadius(0)
    if not inst.components.inventoryitem:IsHeld() then
        inst.AnimState:PlayAnimation("proximity_pst")
        inst.AnimState:PushAnimation("idle", false)
        fadelight(inst, 0, false)
        scheduledropsounds(inst)
    else
        inst.AnimState:PlayAnimation("idle")
        fadelight(inst, 0, true)
    end
    inst.SoundEmitter:KillSound("idlesound")
end

local function onactivate(inst)
    blink(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/celestial_orb/active")
    inst._fx:push()
end

local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("onremove", inst._oncontainerremoved, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("onremove", inst._oncontainerremoved, inst._container)
        inst._container = nil
    end
end

local function tostore(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
    if inst._owner ~= owner then
        inst._owner = owner
        inst.icon.entity:SetParent(owner.entity)
    end
end

local function topocket(inst, owner)
    cancelblink(inst)
    onturnoff(inst)
end

local function toground(inst)
    onturnon(inst)
    unstore(inst)
    inst._owner = nil
    inst.icon.entity:SetParent(inst.entity)
end

local function OnFX(inst)
    if not inst:HasTag("INLIMBO") then
        local fx = CreateEntity()

        fx:AddTag("FX")
        --[[Non-networked entity]]
        fx.entity:SetCanSleep(false)
        fx.persists = false

        fx.entity:AddTransform()
        fx.entity:AddAnimState()

        fx.Transform:SetFromProxy(inst.GUID)

        fx.AnimState:SetBank("moonrock_seed")
        fx.AnimState:SetBuild("moonrock_seed")
        fx.AnimState:PlayAnimation("use")
        fx.AnimState:SetFinalOffset(3)

        fx:ListenForEvent("animover", fx.Remove)
    end
end

local function OnSpawned(inst)
    canceldropsounds(inst)
    scheduledropsounds(inst)
    inst.AnimState:PlayAnimation("proximity_pst")
    inst.AnimState:PushAnimation("idle", false)
end

local function ondropped(inst)
    inst.Light:Enable(false)
end

local function SpawnPet(inst, doer)
    if inst.pet == nil or (inst.pet and not inst.pet:IsValid()) then
--[[
    local pos = Vector3(inst:GetPosition():Get()) + Vector3(2, 2, 2)
    SpawnPrefab("spawn_fx_small").Transform:SetPosition(pos:Get())  
    ]]

    local pos = Vector3(inst:GetPosition():Get()) + Vector3(2, 2, 2)
    SpawnPrefab("spawn_fx_small").Transform:SetPosition(pos:Get())  

    local pet = SpawnPrefab("archetto_petball")
    local pos = Vector3(inst:GetPosition():Get()) + Vector3(2, 0, 2)
    pet.Transform:SetPosition(pos:Get())  

    inst.pet = pet       
    inst.components.leader:AddFollower(pet)

    doer.components.talker:Say("这里应该挺安全…")

    elseif inst.pet and inst.pet:IsValid() then
        local pos = Vector3(inst.pet:GetPosition():Get()) + Vector3(0, 2, 0)
        SpawnPrefab("spawn_fx_small").Transform:SetPosition(pos:Get())  

        inst.pet:Remove()
        inst.pet = nil

        doer.components.talker:Say("有些事情总该独自面对。")
    end 
end

local function OnEnterLimbo(inst)
    inst:DoTaskInTime(0, function(inst) 
    local owner = inst.components.inventoryitem.owner or nil
    if owner and owner:HasTag("player") and inst.pet and inst.pet:IsValid() then
        owner.components.leader:AddFollower(inst.pet)
        inst.pet.components.follower.leader = owner
    end
    end)    
end

local function OnExitLimbo(inst)
    inst:DoTaskInTime(0, function(inst) 
    local owner = inst.components.inventoryitem.owner or nil
    if owner == nil and inst.pet and inst.pet:IsValid() then
        inst.components.leader:AddFollower(inst.pet)
        inst.pet.components.follower.leader = inst
    end
    end)    
end

local function OnSave(inst, data) 
    data.pet = inst.pet ~= nil and inst.pet:GetSaveRecord() or nil
    data.pet_time = inst.pet_time or 0
end

local function OnLoad(inst, data)
    if data ~= nil then
        if data.pet ~= nil then
            local pet = SpawnSaveRecord(data.pet)
            inst.pet = pet
            if pet ~= nil then
                inst:ListenForEvent("onremove", inst._pet_onremove, pet)
            end
        end

        if data.pet_time then
            inst.pet_time = data.pet_time
        end    
    end
end

local function CheckNum(inst)
    local owner = inst.components.inventoryitem.owner 
    if owner and owner.components.inventory and (owner.prefab ~= "archetto" or owner.components.inventory:Has("archetto_petctrl", 2)) then
        owner.components.inventory:DropItem(inst)     
    end  
end

local function OnRemoved(inst)
    if inst.pet and inst.pet:IsValid() then 
        inst.pet.sg:GoToState("death")
        --inst.pet:Remove()
    end    
end

local function on()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("nosteal")
    inst:AddTag("archetto_petctrlon")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("archetto_petctrlon")
    inst.AnimState:SetBuild("archetto_petctrlon")
    inst.AnimState:PlayAnimation("idle")

    inst._fx = net_event(inst.GUID, "moonrockseed._fx")

    inst.Light:SetFalloff(1.15)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(0)
    inst.Light:SetColour(150 / 255, 180 / 255, 200 / 255)
    inst.Light:Enable(false)

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("moonrockseed._fx", OnFX)
    end

    inst._haspet = net_bool(inst.GUID, "ball_haspet", "ball_haspet_dirty")
    --inst._haspet:set(false) 

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._tasks = {}
    inst._light = 0
    inst._targetlight = 0
    inst._owner = nil
    inst._container = nil

    inst.pet_time = 0

    inst._oncontainerownerchanged = function(container)
        tostore(inst, container)
    end

    inst._oncontainerremoved = function()
        unstore(inst)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.imagename = "archetto_petctrlon"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/archetto_petctrlon.xml" 
    inst.components.inventoryitem.canonlygoinpocket = true   
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst:ListenForEvent("onputininventory", topocket)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 4.5)
    inst.components.playerprox:SetOnPlayerNear(onturnon)
    inst.components.playerprox:SetOnPlayerFar(onturnoff)

    inst:AddComponent("leader")

    inst._pet_onremove = function(woby) inst.pet = nil end

    inst:DoPeriodicTask(0.2, function()
        CheckNum(inst)
        if inst.pet and inst.pet:IsValid() then
            inst._haspet:set(true)
        else
            inst._haspet:set(false)            
        end    

        local owner = inst.components.inventoryitem.owner or nil
        if inst:HasTag("INLIMBO") and owner and owner:HasTag("archetto") and inst.pet and inst.pet:IsValid() then
            owner.components.leader:AddFollower(inst.pet)

        elseif inst.pet and inst.pet:IsValid() then 
            inst.components.leader:AddFollower(inst.pet)            
        end    
    end)

    inst:DoPeriodicTask(1, function()
        if inst.pet and inst.pet:IsValid() then 
            inst.pet_time = inst.pet_time + 1

            if inst.pet_time >= 16 * 60 then
                inst.pet_time = 0

                local x, y, z = inst.pet.Transform:GetWorldPosition()           
                SpawnPrefab("feather_canary").Transform:SetPosition(x, 2.5, z)
            end    
        end    
    end)

    inst:ListenForEvent("onremove", OnRemoved)

    inst.SpawnPet = SpawnPet
    inst.OnSpawned = OnSpawned

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    MakeHauntableLaunch(inst)

    return inst
end

local function CanTakeItem(inst, ammo, giver)
    return ammo.prefab == "amulet" or ammo.prefab == "reviver"
end

local function OnGetItemFromPlayer(inst, giver, item)  
    local owner = inst.components.inventoryitem.owner 
    if owner and owner.prefab == "archetto" then
        local item = SpawnPrefab("archetto_petctrl")
        owner.components.inventory:GiveItem(item)
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("archetto_petctrl").Transform:SetPosition(x, y, z)     
    end

    inst:Remove()    
end

local function off()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("nosteal")
    inst:AddTag("archetto_petctrloff")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.AnimState:SetBank("archetto_petctrloff")
    inst.AnimState:SetBuild("archetto_petctrloff")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.imagename = "archetto_petctrloff"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/archetto_petctrloff.xml" 
    inst.components.inventoryitem.canonlygoinpocket = true   

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("archetto_petctrl", on, assets),
       Prefab("archetto_petctrl_off", off)
