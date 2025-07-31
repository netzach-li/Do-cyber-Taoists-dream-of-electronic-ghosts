
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),  
}
local prefabs = {}


local start_inv = {
   "bcj_444_1",
   "bcj_san1"
}

local function onbecamehuman(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "bcj_speed_mod", 1.5)
end

local function onbecameghost(inst)
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "bcj_speed_mod")
end

local function onsave(inst, data)
    data.show_444 = inst.show_444
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

    if data and data.show_444 then
        inst.show_444 = data.show_444
    end

    if data and data.has_dg  ~= nil  then
        inst.has_dg = data.has_dg 
    end        
end

local function DayAtk(inst)
	local delta = 20/60
    if not TheWorld.state.isnight and not TheWorld.state.iscavenight then
        inst.components.health:DoDelta(-delta, true, "bcj_day")
    end	
end

local function sanityfn(inst)--, dt)
	local delta = 0
    if not TheWorld.state.isnight and not TheWorld.state.iscavenight then
        delta = -20/60
    else
        delta = 6/60        
    end	
    return delta
end

local function SetMonsterTarget(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local exclude_tags = {'FX', 'NOCLICK', 'INLIMBO', 'player'}
    local ents = TheSim:FindEntities(x, y, z, 24, { "_combat" }, exclude_tags) 
    for k, v in ipairs(ents) do
        if v and v.components.combat and v.components.combat.target and v.components.combat.target == inst
        and (v:HasTag("monster") or v:HasTag("shadow_aligned")) and inst.hit_table[v] == nil then
            v.components.combat:DropTarget()
        end    
    end

    local hands = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if hands and (hands:HasTag("shadow_item") or hands:HasTag("shadowlevel")) then
        inst.components.combat.damagemultiplier = 2
    else 
        inst.components.combat.damagemultiplier = 0.5
    end	
end

local function OnHitOther(inst, data)
	if data.target ~= nil and (data.target:HasTag("monster") or data.target:HasTag("shadow_aligned")) and inst.hit_table[data.target] == nil then
        inst.hit_table[data.target] = data.target
    end
end

local function SetGhostMode(inst, isghost)
    inst:SetGhostMode_Fake(inst, isghost)
    TheWorld:PushEvent("enabledynamicmusic", false)
    inst.HUD.controls:SetGhostMode(false)
    if inst.components.revivablecorpse == nil then
        TheMixer:PopMix("death")
    end    
end    

local function MakeAnim(inst)
    if inst:HasTag("playerghost") or (inst.components.health and inst.components.health:IsDead()) then return end
     
    if inst.has_dg == true then
    if not inst.components.inventory:EquipHasTag("bcj_glass") then
        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        if hat then
            inst.AnimState:OverrideSymbol("swap_hat", "bcj_glass", "swap_hat")
        end 
    end    

    inst.AnimState:ClearOverrideSymbol("swap_body")
    inst.AnimState:ClearOverrideSymbol("backpack")
    end
end

local function SetGhostMode2(inst, isghost)
    --[[
    TheWorld:PushEvent("enabledynamicmusic", not isghost)
    inst.HUD.controls:SetGhostMode(false)
    if inst.components.revivablecorpse == nil then
        if isghost then
            --TheMixer:PushMix("death")
        else
            --TheMixer:PopMix("death")
        end
    end

    if inst.ghostenabled then
        if not TheWorld.ismastersim then
            if USE_MOVEMENT_PREDICTION then
                if inst.components.locomotor ~= nil then
                    --inst:PushEvent("cancelmovementprediction")
                    if isghost then
                        ex_fns.ConfigureGhostLocomotor(inst)
                    else
                        ex_fns.ConfigurePlayerLocomotor(inst)
                    end
                end
                if inst.sg ~= nil then
                    inst:SetStateGraph(isghost and "SGwilsonghost_client" or "SGwilson_client")
                end
            end
            if isghost then
                ex_fns.ConfigureGhostActions(inst)
            else
                ex_fns.ConfigurePlayerActions(inst)
            end
        end
    end
     ]]
end

local common_postinit = function(inst) 
	inst:AddTag("bcj")
    inst:AddTag("bcj_char")
	inst:RemoveTag("scarytoprey")
	inst.MiniMapEntity:SetIcon( "bcj.tex" )  --ThePlayer.components.health:Kill()

	inst.soundsname = "sfx"  --ThePlayer.talker_path_override = 'Nezha/'
	inst.talker_path_override = 'Nezha/'
end

local master_postinit = function(inst)
	--inst.soundsname = "willow"
    --[[
    local OldSetGhostMode = inst.SetGhostMode
    inst.SetGhostMode = SetGhostMode2

    inst.SetGhostMode = function(inst, isghost)
        OldSetGhostMode(inst, isghost)
        print(isghost)
        if isghost then
        print("特殊操作一下")
        
        inst:DoTaskInTime(1, function()
        TheWorld:PushEvent("enabledynamicmusic", false)
        inst.HUD.controls:SetGhostMode(false)
        --inst.player_classified:SetGhostMode(false)
        if inst.components.revivablecorpse == nil then
            TheMixer:PopMix("death")
        end
        end)
        end
    end
]]
	inst:DoPeriodicTask(1, DayAtk)

	inst.hit_table = {}
    --inst:DoPeriodicTask(0, MakeAnim)
	inst:DoPeriodicTask(0.1, SetMonsterTarget)
	inst:ListenForEvent("onhitother", OnHitOther)

	inst.components.sanity.night_drain_mult = 0
	inst.components.sanity.custom_rate_fn = sanityfn

	inst.components.health:SetMaxHealth(TUNING.BCJ_HEALTH)
	inst.components.health.nonlethal_temperature = true

	inst.components.hunger:SetMax(TUNING.BCJ_HUNGER)
	inst.components.sanity:SetMax(TUNING.BCJ_SANITY)

    inst.components.temperature.hurtrate = 0
	
	-- 伤害系数
    inst.components.combat.damagemultiplier = 0.5
    local _getAttacked = inst.components.combat.GetAttacked
    inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...)
        if math.random() > 0.5 then  --shadow_shield1
        	local fx = SpawnPrefab("shadow_shield1")
            fx.entity:SetParent(inst.entity)
            return 
        end 
        return _getAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...) 
    end

    local _getHealth = inst.components.health.DoDelta  --ThePlayer.components.health:DoDelta(-10, nil, "cold")
    inst.components.health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if inst.components.inventory:EquipHasTag("bcj_san") and cause and (cause == "fire" or cause == "cold" or cause == "hot" or cause == "bcj_day") then
        local hands = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)     
        if amount < 0 and hands and hands.hel_abo then
            amount = amount * hands.hel_abo
        end
        end                                 
        return _getHealth(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...) 
    end 

    local _getSanity = inst.components.sanity.DoDelta
    inst.components.sanity.DoDelta = function(self, delta, overtime, ...)
        if inst.components.inventory:EquipHasTag("bcj_san") then
        local hands = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)     
        if delta < 0 and hands and hands.hel_abo == 0 then
            return
        end
        end                                 
        return _getSanity(self, delta, overtime, ...) 
    end 

    inst.components.cursable.ApplyCurse = function(s, it, cur,...)
    if it and it:AddTag("applied_curse") then
        it:RemoveTag("applied_curse")
    end
    if it.components.curseditem then
        it.components.curseditem.target = nil
    end
    if it.findplayertask then
        it.findplayertask:Cancel()
        it.findplayertask = nil
    end
    end

    local _getGrogginess = inst.components.grogginess.AddGrogginess
    inst.components.grogginess.AddGrogginess = function(self, grogginess, knockoutduration, ...)
        grogginess = 0
        return _getGrogginess(self, grogginess, knockoutduration, ...)
    end

    local OldEnableLunacy = inst.components.sanity.EnableLunacy
    inst.components.sanity.EnableLunacy = function(self, enable, sorce, ...)
        if enable == true then
            enable = false
        end 
        return OldEnableLunacy(self, enable, sorce, ...)
    end  

	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
    inst.level1 = {0, 0, 0, 0, 0}
    inst.level2 = {0, 0, 0, 0, 0}
    
    inst.show_444 = 0
    inst.OnSave = onsave
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
end

return MakePlayerCharacter("bcj", prefabs, assets, common_postinit, master_postinit, start_inv)
