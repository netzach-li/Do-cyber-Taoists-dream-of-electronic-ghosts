GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local Ti_List = {meat = true, monstermeat = true, drumstick = true, bcj_lhs_big = true}

AddComponentAction("SCENE", "workable", function(inst, doer, actions, right)
    if not (doer.replica.rider and doer.replica.rider:IsRiding()) then
    	if doer.prefab == "gyc" then
            if (inst.prefab == "skeleton" or inst.prefab == "skeleton_player") and right then
               table.insert(actions, ACTIONS.BCJ_XIAZANG)

            elseif inst.prefab == "bcj_jianzhu11" and doer.replica.inventory and doer.replica.inventory:EquipHasTag("bcj_jianzhu14")  then
               table.insert(actions, ACTIONS.BCJ_ANZHUANG)            
            end 

        elseif doer.prefab == "bcj" and inst.prefab == "mound" and inst:HasTag("can_mojin") then
            table.insert(actions, ACTIONS.BCJ_MOJIN)

        elseif inst.prefab == "bcj_lhs_big" and doer.replica.inventory and doer.replica.inventory:EquipHasTag("bcj_ym") then 
            table.insert(actions, ACTIONS.BCJ_TI)      
        end	
    end
end)

AddComponentAction("SCENE", "inventoryitem" , function(inst, doer, actions, right)
    if doer.prefab == "gyc" and (inst.prefab == "bcj_cl1_full") then
    if right then    
        table.insert(actions, ACTIONS.UNPACK)
    else
        table.insert(actions, ACTIONS.PICKUP)           
    end
    end	

    if doer.replica.inventory and doer.replica.inventory:EquipHasTag("bcj_ym") and Ti_List[inst.prefab] == true then
        table.insert(actions, ACTIONS.BCJ_TI)          
    end  
end)

AddComponentAction("SCENE", "childspawner",  function(inst, doer, actions, right) 
    if doer.replica.inventory and doer.replica.inventory:EquipHasTag("dug_lhs")
    and inst.prefab == "mound" then
        table.insert(actions, ACTIONS.GIVE)         
    end    
end)
  
local BCJ_XIAZANG = Action({ distance = 1, priority = 20, mount_valid = false })
      BCJ_XIAZANG.id = "BCJ_XIAZANG"  
      BCJ_XIAZANG.str = "下葬"   
      BCJ_XIAZANG.fn = function(act)
      if act.target and act.target:IsValid() and act.doer then
            local x, y, z = act.target.Transform:GetWorldPosition()
            local grave = SpawnPrefab("gravestone")
            grave.Transform:SetPosition(x, 0, z)

            local fx = SpawnPrefab("fossilizing_fx")
            fx.Transform:SetPosition(x, 0, z)
          
            act.doer.components.sanity:DoDelta(30)
            act.doer.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
            act.target:Remove()
      end    
      return true 
end

AddAction(BCJ_XIAZANG) 
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BCJ_XIAZANG, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BCJ_XIAZANG, "dolongaction"))

local LOOTS =  
{
    nightmarefuel = 1,  
    amulet = 1,
    gears = 1,
    redgem = 5,
    bluegem = 5,    
}

local function SpawnItem(inst, worker)
	  local double = math.random() >= 0.95 and 2 or 1
	--print(double)
    if worker ~= nil then
        --if worker.components.sanity ~= nil then
            --worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        --end
        if math.random() >= 0.95 and c_countprefabs("dug_bcj_lhs") == 0  --世界只能有一个
        and c_countprefabs("bcj_lhs") == 0 and c_countprefabs("bcj_lhs_big") == 0 then
            inst.components.lootdropper:SpawnLootPrefab("dug_bcj_lhs")
        end	

        if math.random() >= 0.95 then
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl1")
        end 

        local item = math.random() < .5 and PickRandomTrinket() or weighted_random_choice(LOOTS) or nil
        if item ~= nil then
        for i = 1, double do	
            inst.components.lootdropper:SpawnLootPrefab(item)
        end     
        end

		    if math.random() < TUNING.COOKINGRECIPECARD_GRAVESTONE_CHANCE then
		    for i = 1, double do	
            inst.components.lootdropper:SpawnLootPrefab("cookingrecipecard")
        end    
		    end

        if math.random() < TUNING.SCRAPBOOK_PAGE_GRAVESTONE_CHANCE then
        for i = 1, double do	
            inst.components.lootdropper:SpawnLootPrefab("scrapbook_page")
        end    
        end

		  if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
			local ornament = math.random(NUM_HALLOWEEN_ORNAMENTS * 4)
			if ornament <= NUM_HALLOWEEN_ORNAMENTS then
			for i = 1, double do	
	            inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_"..tostring(ornament))
	        end    
			end
		  end
      end
end

local BCJ_MOJIN = Action({ distance = 1, priority = 20, mount_valid = false })
      BCJ_MOJIN.id = "BCJ_MOJIN"  
      BCJ_MOJIN.str = "摸金"   
      BCJ_MOJIN.fn = function(act)
      if act.target and act.target:IsValid() and act.doer then
            local x, y, z = act.target.Transform:GetWorldPosition()
            local fx = SpawnPrefab("fossilizing_fx")
            fx.Transform:SetPosition(x, 0, z)

            SpawnItem(act.target, act.doer)
            act.target:RemoveTag("can_mojin")
            act.target.components.timer:StartTimer("MoJin_Cd", 480 * 3) --坟墓进入cd
            --act.doer.SoundEmitter:PlaySound("dontstarve/creatures/together/fossil/repair")
      end    
      return true 
end

AddAction(BCJ_MOJIN) 
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BCJ_MOJIN, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BCJ_MOJIN, "dolongaction"))

AddComponentAction("USEITEM", "edible", function(inst, doer, target, actions, right) --and not (target:HasTag("haunted") or target:HasTag("catchable"))
    if inst.prefab == "bcj_food5" and not target:HasTag("player")
    and not (target:HasTag("haunted") or target:HasTag("catchable")) then 
        table.insert(actions, ACTIONS.GIVE)

    elseif inst.prefab ~= "bcj_food5" and target:HasTag("bcj_444") and right then 
        table.insert(actions, ACTIONS.FEED)            
    end 
end) 

AddComponentAction("USEITEM", "inventoryitem", function(inst, doer, target, actions, right) --and not (target:HasTag("haunted") or target:HasTag("catchable"))
    if inst.prefab == "bcj_jianzhu9" and target.prefab == "bcj_jianzhu11"
    and doer.prefab == "bcj" then 
        table.insert(actions, ACTIONS.BCJ_ANZHUANG) 
    end 
end) 

local PACK = AddAction("PACK", "打包", function(act)
    if act.doer.components.inventory then   
        local item = act.doer.components.inventory:RemoveItem(act.invobject)
        if item then
            item:Remove()
            local inst = GLOBAL.SpawnPrefab("bcj_cl1_full")
            inst.Transform:SetPosition(act.target.Transform:GetWorldPosition())
            inst.components.package:Pack(act.target)
            return true
        end
    end
end)
PACK.priority = 10

AddComponentAction("USEITEM", "package", function(inst, doer, target, actions)
    if target:HasTag("packable") and doer.prefab == "gyc" then
        table.insert(actions, GLOBAL.ACTIONS.PACK)
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(PACK, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(PACK, "dolongaction"))

------------
-- UNPACK --
------------

local UNPACK = AddAction("UNPACK", "搬出", function(act)
    if act.target.components.package.content ~= nil then  
        act.target.components.package:Unpack(act.doer)
        return true
    end
end)
--[[
AddComponentAction("SCENE", "package", function(inst, doer, actions, right)
    if right and inst:HasTag("full") then --and doer and doer.prefab == "gyc"
        table.insert(actions, GLOBAL.ACTIONS.UNPACK)
    end
end)
]]
AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(UNPACK, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(UNPACK, "dolongaction"))

local BCJ_ANZHUANG = Action({ distance = 1, priority = 20, mount_valid = false })
      BCJ_ANZHUANG.id = "BCJ_ANZHUANG"  
      BCJ_ANZHUANG.str = "安装"
      BCJ_ANZHUANG.encumbered_valid = true   
      BCJ_ANZHUANG.fn = function(act)
      if act.target and act.target:IsValid() and act.doer then
      if act.invobject and act.invobject.prefab == "bcj_jianzhu9" then
          local x, y, z = act.target.Transform:GetWorldPosition() 
          act.target:Remove()
          act.invobject:Remove()

          local tab = SpawnPrefab("bcj_table")
          tab.Transform:SetPosition(x, 0, z)
          tab.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")
          SpawnPrefab("winters_feast_food_depleted").Transform:SetPosition(x, 0, z) 

      elseif act.doer.components.inventory and act.doer.components.inventory:EquipHasTag("bcj_jianzhu14") then
          local jz = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil
          if jz and jz.prefab == "bcj_jianzhu14" then
          jz:Remove()
          end

          local x, y, z = act.target.Transform:GetWorldPosition() 
          act.target:Remove()

          local tab = SpawnPrefab("gyc_table1")
          tab.Transform:SetPosition(x, 0, z)
          tab.SoundEmitter:PlaySound("dontstarve/common/repair_stonefurniture")
          SpawnPrefab("winters_feast_food_depleted").Transform:SetPosition(x, 0, z)            
      end 
      end     
      return true 
end

AddAction(BCJ_ANZHUANG) 
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BCJ_ANZHUANG, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BCJ_ANZHUANG, "dolongaction"))


local BCJ_TI = Action({ distance = 2, priority = 20, mount_valid = false })
      BCJ_TI.id = "BCJ_TI"  
      BCJ_TI.str = "剃"   
      BCJ_TI.fn = function(act)
      if act.target and act.target:IsValid() and act.doer then
      if act.target.bcj_ti then
          local str = act.target.prefab == "bcj_lhs_big" and "还没长好呢" or "已经剃过了。"
          act.doer.components.talker:Say(str)
      else
          act.target.bcj_ti = true
          if act.target.prefab == "bcj_lhs_big" then
              act.target.components.timer:StartTimer("Ti_Cd", 480)
          end

          if act.target.prefab == "bcj_lhs_big" or math.random() >= 0.75 then
          local prefab = act.target.prefab == "bcj_lhs_big" and "bcj_cl3" or "boneshard"
          local item = SpawnPrefab(prefab)
          act.doer.components.inventory:GiveItem(item)
          end     
      end  
      end    
      return true 
end

AddAction(BCJ_TI) 
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.BCJ_TI, "dolongaction"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.BCJ_TI, "dolongaction"))

local OldPICKUPFn = ACTIONS.PICKUP.fn
ACTIONS.PICKUP.fn = function(act, ...)
    if act.doer and act.doer.prefab == "gyc" 
    and act.target and (act.target.prefab == "bcj_cl1_full") then
        act.doer.components.inventory:Equip(act.target)
        return true
    end  
    return OldPICKUPFn(act, ...)
end

local OldFEEDFn = ACTIONS.FEED.fn
ACTIONS.FEED.fn = function(act, ...)
    if act.target and act.target:HasTag("bcj_444") and act.invobject and act.invobject.components.edible then
        local amount = act.invobject.components.edible.hungervalue * 3
        if amount < 0 then amount = 0 end

        if act.invobject.components.stackable then
        act.invobject.components.stackable:Get():Remove()
        else	
        act.invobject:Remove()
        end
        act.target.components.armor:Repair(amount)
        return true
    end  
    return OldFEEDFn(act, ...)
end

ACTIONS.GIVE.encumbered_valid = true
local OldGiveFn = ACTIONS.GIVE.fn  --ACTIONS.GIVE.encumbered_valid = true
ACTIONS.GIVE.fn = function(act, ...)
    if act.doer and act.doer.components.inventory and act.doer.components.inventory:EquipHasTag("dug_lhs")
    and act.target and act.target.prefab == "mound" then
        if act.target.components.workable then
            act.doer.components.talker:Say("需要先把它挖个洞。。")
            return true
        else
            local dug_hs = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) or nil 
            if dug_hs and dug_hs:HasTag("dug_lhs") then
            act.target:GetHs(act.doer, dug_hs) 
            return true
            end 
        end     
    end    

    if act.invobject and act.invobject.prefab == "bcj_food5"
    and act.target and act.target:IsValid() and not act.target:IsInLimbo() and
        act.target.components.hauntable ~= nil and
        not (act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem:IsHeld()) and
        not (act.target:HasTag("haunted") or act.target:HasTag("catchable")) then
        act.doer:PushEvent("haunt", { target = act.target })
        act.target.components.hauntable:DoHaunt(act.invobject)
        act.invobject.components.stackable:Get():Remove()
        if act.target.components.werebeast and act.target.components.werebeast:IsInWereState() then
            act.target.components.werebeast:TriggerDelta(1000)
        end  
        return true
    end  
    return OldGiveFn(act, ...)
end

