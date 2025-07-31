
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {}


local start_inv = {
  "gyc_mb1",
  "gyc_hat",
  "bcj_item1"
}

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gyc_speed_mod", 1)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "gyc_speed_mod")
end

local function DoLevelUp_Change(inst)
	if inst.level1 and inst.level1 > 0 then
    inst.components.llmy_power:SetMax(50 + (inst.level1 * 30))
    inst.components.combat.damagemultiplier = 1 + (inst.level2 * 0.2)
    end

    if inst.level2 and inst.level2 > 0 then
    for i = 1, 5 do
    if inst.level2 >= i then --print(ThePlayer:HasTag("gyc_sg1"))
        inst:AddTag("gyc_sg"..i)
    end    
    end
    inst.components.builder:GiveAllRecipes()
    inst.components.builder:GiveAllRecipes()
    end    
end

local function DoLevelUp1(inst)
    inst.level1 = inst.level1 + 1
    DoLevelUp_Change(inst)

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("fx_book_temperature")
    fx.Transform:SetPosition(x, y, z) 

    inst:PushEvent("emote", { anim = "emoteXL_happycheer", mounted = true, mountsound = "yell" }) 
end

local function DoLevelUp2(inst)
    inst.level2 = inst.level2 + 1
    DoLevelUp_Change(inst)

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("fx_book_research_station")
    fx.Transform:SetPosition(x, y, z)

    inst:PushEvent("emote", { anim = "emoteXL_happycheer", mounted = true, mountsound = "yell" }) 
end

local function TransGod(inst, val)
    inst.god = val
    if inst.god then
        inst.Light:Enable(true)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "gyc_god", 1.5)
    else
        inst:AddTag("groggy") 
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "bcj_pibei", 0.4)
        inst.task_l_groggy = inst:DoTaskInTime(10, function(eater)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "bcj_pibei")
            end
            inst:RemoveTag("groggy")
            inst.task_l_groggy = nil
        end)

        inst.Light:Enable(false)
        inst.components.sanity:SetPercent(0)
        inst.AnimState:ClearBloomEffectHandle()
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "gyc_god")
    end 
end

local function StopTrans(inst)
    if inst.components.llmy_power.current < 20 and inst.god == true then
        TransGod(inst, false)
    end
end

local function MakeAnim(inst)
    if inst:HasTag("playerghost") or (inst.components.health and inst.components.health:IsDead()) then return end
     
    if inst.has_dg == true then
    if not inst.components.inventory:EquipHasTag("gyc_hat") then
        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat then
        inst.AnimState:OverrideSymbol("headbase", "gyc_eq_hat", "headbase")
        inst.AnimState:OverrideSymbol("headbase_hat", "gyc_eq_hat", "headbase_hat")
        inst.AnimState:ClearOverrideSymbol("swap_hat")
        inst.AnimState:Show("HEAD")
        inst.AnimState:Hide("HEAD_HAT")
        else
        inst.AnimState:Hide("HEAD")
        inst.AnimState:Show("HEAD_HAT")                
        end 
    end    

    inst.AnimState:ClearOverrideSymbol("swap_body")
    inst.AnimState:ClearOverrideSymbol("backpack")
    end
end

local function onsave(inst, data)
    data.level1 = inst.level1
    data.level2 = inst.level2 

    data.has_dg = inst.has_dg  
end

local function onload(inst, data)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end

    if data and data.level1 ~= nil then
        inst.level1 = data.level1
    end
    
    if data and data.level2 ~= nil  then
        inst.level2 = data.level2
    end

    if data and data.has_dg  ~= nil  then
        inst.has_dg = data.has_dg 
    end

    inst:DoTaskInTime(0, DoLevelUp_Change)	
end

local common_postinit = function(inst)
	inst.soundsname = "sfx"  --ThePlayer.soundsname = "sfx"
	inst.talker_path_override = 'MK/' 

    inst:AddTag("gyc")
    inst:AddTag("bcj_char")
	inst.MiniMapEntity:SetIcon( "gyc.tex" )

	inst._llmy_powermax = net_ushortint(inst.GUID, "llmy_power.current", "llmy_powermaxdirty")
    inst._llmy_powercurrent = net_ushortint(inst.GUID, "llmy_power.max", "llmy_powercurrentdirty")
    inst._llmy_powerratescale = net_tinybyte(inst.GUID, "llmy_power.ratescale") 
end

local master_postinit = function(inst)
	--inst.soundsname = "winona"

	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.GYC_HEALTH)
	inst.components.hunger:SetMax(TUNING.GYC_HUNGER)
	inst.components.sanity:SetMax(TUNING.GYC_SANITY)
	
    local _calcDamage = inst.components.combat.CalcDamage
    inst.components.combat.CalcDamage = function(self, target, weapon, multiplier)  
    local damage, spdamage = _calcDamage(self, target, weapon, multiplier)
        if inst.god == true then
            damage = 520
        end

        return damage, spdamage
    end 

    local _getHealth = inst.components.health.DoDelta
    inst.components.health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if amount < 0 and amount + self.currenthealth <= 0 and inst.god then
            amount = 0
            self.currenthealth = 1
        end
                            
        return _getHealth(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...) 
    end

	-- 伤害系数
    inst.components.combat.damagemultiplier = 1
	
	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

	inst:AddComponent("llmy_power")     
    inst.components.llmy_power:SetMax(50)
--[[
    inst:DoPeriodicTask(1, function(inst)
    inst.components.llmy_power:DoDelta(0.5)
    end)
]]
    inst.level1 = 0
    inst.level2 = 0   

    inst.DoLevelUp1 = DoLevelUp1
    inst.DoLevelUp2 = DoLevelUp2  

    inst.god = false
    inst.TransGod = TransGod
    inst:ListenForEvent("Llmy_Power_delta", StopTrans)
    --inst:DoPeriodicTask(0, MakeAnim)  
	
	inst.OnSave = onsave
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
end

return MakePlayerCharacter("gyc", prefabs, assets, common_postinit, master_postinit, start_inv)
