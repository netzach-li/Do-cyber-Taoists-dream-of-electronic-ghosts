local function MakeJz(name, stackable, castspell)
local assets =
{
  Asset("ANIM", "anim/bcj_jianzhu.zip"),
  Asset("ANIM", "anim/swap_bcj_jianzhu_14.zip"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu1.xml"),  
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu4.xml"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu6.xml"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu8.xml"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu9.xml"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu10.xml"),  
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu11.xml"),
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu12.xml"),  
  Asset("ATLAS", "images/inventoryimages/bcj_jianzhu14.xml")
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
    if inst.components.fueled ~= nil then
        updatefuelrate(inst)
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        local anim = name == "6" and "6" or "4"
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation(anim, true)
    else
        local anim = name == "6" and "7" or "5"
        if name == "6" or (name == "4" and inst.components.machine and inst.components.machine.ison == true) then
        inst.Light:Enable(true)
        end
        inst.AnimState:PlayAnimation(anim, true)
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function ItemTradeTest(inst, item)
    if item and (item.prefab == "charcoal" or item.prefab == "boneshard" or item.prefab == "bcj_ghost_soul") then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item and (item.prefab == "charcoal" or item.prefab == "boneshard" or item.prefab == "bcj_ghost_soul") then
        local del = (item.prefab == "charcoal" and 0.05) or (item.prefab == "boneshard" and 0.1) or 0.5
        inst.components.fueled:DoDelta(TUNING.COLDFIREPIT_FUEL_MAX * del)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
        inst.components.fueled:StartConsuming()
       -- inst.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
end

local function ItemTradeTest2(inst, item)
    if item and item.prefab == "bcj_food1" then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer2(inst, giver, item)
    if item and item.prefab == "bcj_food1" then
        local x, y, z = inst.Transform:GetWorldPosition()
        local jz = SpawnPrefab("bcj_jianzhu3")
        jz.Transform:SetPosition(x, y, z)

        local fx = SpawnPrefab("chester_transform_fx")
        fx.Transform:SetPosition(x, y, z)

        inst:Remove()
    end
end

local Item3Table = {
   bcj_food1 = true,
   milkywhites = true,
   butter = true,
   goatmilk = true 
}

local function ItemTradeTest3(inst, item)
    if item and Item3Table[item.prefab] then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer3(inst, giver, item)
    if item and Item3Table[item.prefab] then
    	if item.prefab == "bcj_food1" then
        inst.components.finiteuses:SetPercent(1) 
    	else	
        local rapair_amount = inst.components.finiteuses.total * 0.2
        inst.components.finiteuses:Repair(rapair_amount)
        end
    end
end

local function ItemTradeTest11(inst, item)
    if item and item.prefab == "bcj_jianzhu9" then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer11(inst, giver, item)
    if item and item.prefab == "bcj_jianzhu9" then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst:Remove()
        
        local tab = SpawnPrefab("bcj_table")
        tab.Transform:SetPosition(x, 0, z)
        tab.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")

        SpawnPrefab("winters_feast_food_depleted").Transform:SetPosition(x, 0, z)  
        --inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end
end

local function TurnOff(inst, instant)
    inst.on = true
    inst.components.fueled:StopConsuming()
    inst.Light:Enable(false)
end

local function TurnOn(inst, instant)
    if not TheWorld.state.isday then
    inst.on = false
    inst.components.fueled:StartConsuming()
    inst.Light:Enable(true)
    else
    inst.components.machine:TurnOff()     
    end
end

local function CanInteract(inst)
    return not inst.components.fueled:IsEmpty()
end

local function oversized_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_bcj_jianzhu_14", "swap_body")
end

local function oversized_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnFinish(inst)
    local xmz = SpawnPrefab("bcj_jianzhu12")
    xmz.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()  

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    if name == "3" then
    inst.Transform:SetScale(0.8, 0.8, 0.8)
    end

    if name == "4" or name == "6" then
    inst.entity:AddLight()
    inst.Light:SetFalloff(.33)  --衰减
    inst.Light:SetIntensity(.8) --亮度
    inst.Light:SetRadius(name == "4" and 5 or 4)     --半径
    inst.Light:SetColour(0, 183 / 255, 1) 
    end

    if name == "11" or name == "14" then
    inst.entity:AddMiniMapEntity()
    end  
    inst.entity:AddNetwork()

    if name == "11" or name == "14" then
    inst.MiniMapEntity:SetIcon("bcj_jianzhu"..name..".tex") 
    end    

    inst.AnimState:SetBank("bcj_jianzhu")
    inst.AnimState:SetBuild("bcj_jianzhu")  
    inst.AnimState:PlayAnimation(name, true)

    --inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst:AddTag("bcj_jianzhu"..name)

    if name == "6" then
    inst:AddTag("structure")
    inst.Transform:SetNoFaced()
    end  

    if name == "8" or name == "12" then
    inst.AnimState:SetFinalOffset(-1)
    inst:AddTag("structure")
    --inst:AddTag("limited_chair")
    inst:AddTag("uncomfortable_chair")

    if name == "12" then
    inst.Transform:SetScale(1, 0.6, 1)
    end
    end

    if name == "13" then
    inst:AddTag("scarecrow")
    end

    if name == "14" then
    inst:AddTag("dug_lhs")
    inst:AddTag("heavy")
    inst:AddTag("irreplaceable")
    end 
 
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        if name == "1" then
        inst.OnEntityReplicated = function(inst)
        if inst.replica.container then
            inst.replica.container:WidgetSetup("bcj_jianzhu1")
        end    
        end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    if name == "1" then
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("bcj_jianzhu1")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("preserver")
    inst.components.preserver.perish_rate_multiplier = 0
    end

    if name == "3" then
    inst.sit_time = 0

    inst:AddComponent("sittable")  --Sittable:IsOccupied()
    inst:DoPeriodicTask(1, function(inst)  --c_findnext("bcj_jianzhu3", 4).components.finiteuses:Use(20)
        if inst.components.sittable:IsOccupied() then
        	inst.sit_time = inst.sit_time + 1
        	if inst.sit_time >= 5 then
                inst.components.finiteuses:Use(1)
        	end	
            local siter = inst.components.sittable.occupier
            if siter:HasTag("player") then
            siter.components.hunger:DoDelta(1, true)
            siter.components.sanity:DoDelta(1, true)
            siter.components.health:DoDelta(1, true)
            end
        end    
    end)

    inst:DoPeriodicTask(0.1, function(inst)
        if inst.components.sittable:IsOccupied() == false then
            inst:Show()     
        end 
    end)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
    inst.components.finiteuses:SetOnFinished(OnFinish)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest3)
    inst.components.trader.onaccept = OnGetItemFromPlayer3	
    end	

    if name == "4" or name == "6" then
    -------------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.COLDFIREPIT_FUEL_MAX
    inst.components.fueled.accepting = false
    inst.components.fueled:SetSections(4)
    inst.components.fueled.bonusmult = TUNING.COLDFIREPIT_BONUS_MULT
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:SetUpdateFn(onupdatefueled)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:StartConsuming()
    inst.components.fueled:InitializeFuelLevel(TUNING.COLDFIREPIT_FUEL_MAX)


    if name == "4" then
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0.5
    inst.components.machine.ison = true

    inst:DoPeriodicTask(0.1, function(inst)
        if inst.components.machine.ison and TheWorld.state.isday then
        inst.components.machine:TurnOff()
        end

        if inst.components.fueled:GetPercent() < 1 then
        local x, y, z = inst.Transform:GetWorldPosition()
        local exclude_tags = {'INLIMBO'}
        local ents = TheSim:FindEntities(x, y, z, 8, { "ghost_soul" }, exclude_tags) 
        for k, v in ipairs(ents) do
            if v and v:IsValid() then
                v.components.stackable:Get(1):Remove()
                inst.components.fueled:SetPercent(1)

                local fx = SpawnPrefab("wortox_soul_heal_fx")
                fx.AnimState:SetMultColour(0, 0.2, 1, 0.5)
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/heal")
                --local "wortox_soul_heal_fx"
                break
            end    
        end               
        end  
    end)
    end  

    if name == "6" then
    inst:AddComponent("cooker")

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    end

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.restart_firepit = function( inst )
        local fuel_percent = inst.components.fueled:GetPercent()
        inst.components.fueled:MakeEmpty()
        inst.components.fueled:SetPercent( fuel_percent )
    end
    end

    if name == "8" then
    inst:AddComponent("sittable")  --Sittable:IsOccupied()
    inst:DoPeriodicTask(1, function(inst)
        if inst.components.sittable:IsOccupied() then
            local siter = inst.components.sittable.occupier
            if siter:HasTag("player") then
            siter.components.hunger:DoDelta(-1, true)
            --siter.components.sanity:DoDelta(1/3, true)
            siter.components.health:DoDelta(0.5, true)
            end
        end    
    end)
    end 

    if name == "9" then
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_jianzhu9"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_jianzhu9.xml"
    end 

    if name == "11" then
    --inst:AddComponent("trader")
    --inst.components.trader:SetAbleToAcceptTest(ItemTradeTest11)
    --inst.components.trader.onaccept = OnGetItemFromPlayer11

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    end 

    if name == "12" then
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest2)
    inst.components.trader.onaccept = OnGetItemFromPlayer2

    inst:AddComponent("sittable")  --Sittable:IsOccupied()
    inst:DoPeriodicTask(1, function(inst)
        if inst.components.sittable:IsOccupied() then
            local siter = inst.components.sittable.occupier
            if siter:HasTag("player") then
            siter.components.hunger:DoDelta(-1, true)
            siter.components.sanity:DoDelta(1/3, true)
            siter.components.health:DoDelta(1/3, true)
            end
        end    
    end)
    end   

    if name == "14" then
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_jianzhu14"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_jianzhu14.xml"
    inst.components.inventoryitem.cangoincontainer = false
    --inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(oversized_onequip)
    inst.components.equippable:SetOnUnequip(oversized_onunequip)
    inst.components.equippable.walkspeedmult = 0.3

    inst.RemoveTask = inst:DoTaskInTime(0, function(inst)  --世界只能存在1只
        if c_countprefabs("bcj_jianzhu14", true) >= 2 then
            inst:Remove()
        end
    end) 
    end  

    return inst
end

return Prefab("bcj_jianzhu"..name, fn, assets),
       MakePlacer("bcj_jianzhu1_placer", "bcj_jianzhu", "bcj_jianzhu", "1"),
       MakePlacer("bcj_jianzhu4_placer", "bcj_jianzhu", "bcj_jianzhu", "4"),
       --MakePlacer("bcj_jianzhu6_placer", "bcj_jianzhu", "bcj_jianzhu", "6"),
       MakePlacer("bcj_jianzhu8_placer", "bcj_jianzhu", "bcj_jianzhu", "8"),
       MakePlacer("bcj_jianzhu10_placer", "bcj_jianzhu", "bcj_jianzhu", "10"),
       MakePlacer("bcj_jianzhu11_placer", "bcj_jianzhu", "bcj_jianzhu", "11"),
       MakePlacer("bcj_jianzhu12_placer", "bcj_jianzhu", "bcj_jianzhu", "12")
end    

return MakeJz("1"),
       MakeJz("2"),
       MakeJz("3"),
       MakeJz("4"),
       MakeJz("5"),     
       --MakeJz("6"),
       MakeJz("7"),
       MakeJz("8"), 
       MakeJz("9"),
       MakeJz("10"),
       MakeJz("11"),
       MakeJz("12"),
       MakeJz("13"),
       MakeJz("14")              