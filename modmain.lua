GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

PrefabFiles = {
    "bcj",
    "bcj_none",

    "bcj_fx",
    "bcj_cl",
    "bcj_item",
    "bcj_fu",
    "bcj_fu_fx",
    "bcj_foods",
    "bcj_lhs",
    "bcj_taos",
    "bcj_jianzhu",
    "bcj_jianzhu6",
    "bcj_sword",
    "bcj_san",
    "bcj_gun",
    "bch_table",
    "bcj_glass",
    "bcj_444",
    "bcj_444_pet",
    "bcj_cd",
    "bcj_ym",

    "gyc",
    "gyc_none",
    "gyc_fc",
    "gyc_mb",
    "gyc_tmj",
    "gyc_hat",
    "gyc_table",
    "yuki_flyer_fx",

    "my_cd"

    --"luole",
    --"luole_none",

    --"mengyi",
    --"mengyi_none" --c_findnext("bcj", 4).components.builder:GiveAllRecipes() 
}

Assets = {   
    Asset("SOUNDPACKAGE", "sound/MK.fev"),
    Asset("SOUND", "sound/MonkeyKing.fsb"),
    Asset("SOUNDPACKAGE", "sound/Nezha.fev"),
    Asset("SOUND", "sound/Nezha.fsb"),

    Asset("ATLAS", "images/map_icons/bcj_taos.xml"),
    Asset("ATLAS", "images/map_icons/bcj_lhs.xml"),

    Asset("ANIM", "anim/tzsama.zip"),
    Asset("ANIM", "anim/llmy_ui.zip"),
    Asset("ANIM", "anim/daofeng_actions_pistol.zip"),

    Asset("SOUNDPACKAGE", "sound/lw_homura.fev"),  
    Asset("SOUND", "sound/lw_homura.fsb"),

    Asset("ANIM", "anim/wahah.zip"),
    Asset("ANIM", "anim/bcj_jianzhu1_ui.zip"),
    Asset("ANIM", "anim/bcj_444_2x2.zip"),
    Asset("ANIM", "anim/bcj_444_2x4.zip"),
    Asset("ANIM", "anim/bcj_444_2x6.zip"),
    Asset("ANIM", "anim/bcj_444_2x8.zip"),

    Asset("ANIM", "anim/leaves_canopy_lhs.zip")
    --Asset("SHADER", "shaders/myshader.ksh")
}
--[[
AddPrefabPostInit("wilson", function(inst)
-- 设置腐蚀效果
local amount = 0
local speed = 0.01

-- 每帧更新腐蚀效果
inst:DoPeriodicTask(0.1, function()
    amount = amount + speed
    if amount > 1 then
        amount = 0 -- 重置腐蚀量
    end
    inst.AnimState:SetErosionParams(amount, 0.1, 1, {0.5, 0.5, 0.5, 1})
end)

    --inst.AnimState:SetBloomEffectHandle(resolvefilepath("shaders/myshader.ksh"))
end)
]]

RemapSoundEvent( "dontstarve/characters/monkey_king/death_voice", "monkey_king/monkey_king/death" )
RemapSoundEvent( "dontstarve/characters/monkey_king/hurt",      "monkey_king/monkey_king/hit" )
RemapSoundEvent( "dontstarve/characters/monkey_king/talk_LP", "monkey_king/monkey_king/talk_loop" )

RemapSoundEvent( "dontstarve/characters/neza/death_voice", "neza_sound/neza_sound/death" )
RemapSoundEvent( "dontstarve/characters/neza/hurt",      "neza_sound/neza_sound/hit" )
RemapSoundEvent( "dontstarve/characters/neza/talk_LP", "neza_sound/neza_sound/talk_loop" )

local characters ={
	"bcj",
    "gyc"
    --"luole",
    --"mengyi"   
}

function AddAssets(...)
    for _,v in ipairs({...})do table.insert(Assets, v) end
end

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

for k,v in pairs(characters) do 
    AddAssets(
        Asset("ATLAS", "bigportraits/"..v.."_none.xml"),
        Asset("ATLAS", "images/names_"..v..".xml" ),
        Asset("ATLAS", "images/avatars/self_inspect_"..v..".xml" ),
        Asset("ATLAS", "images/avatars/avatar_ghost_"..v..".xml" ),
        Asset("ATLAS", "images/avatars/avatar_"..v..".xml" ),
        Asset("ATLAS", "images/map_icons/"..v..'.xml')
    ) 

    AddModCharacter(v, "FEMALE") 
    AddMinimapAtlas("images/map_icons/"..v..".xml")
end

GLOBAL.PREFAB_SKINS["bcj"] = {   
	"bcj_none",
	"bcj_skin1_none"
}

GLOBAL.PREFAB_SKINS["gyc"] = {   
	"gyc_none",
	"gyc_skin1_none",	
}

local function sorabaseenable(self)
    if self.name == "LoadoutSelect" then
        if not table.contains(DST_CHARACTERLIST, "bcj") then
           table.insert(DST_CHARACTERLIST, "bcj")
        end
        if not table.contains(DST_CHARACTERLIST, "gyc") then
           table.insert(DST_CHARACTERLIST, "gyc")
        end          
   elseif  self.name == "LoadoutRoot" then
        if table.contains(DST_CHARACTERLIST, "bcj") then
            RemoveByValue(DST_CHARACTERLIST, "bcj")
        end
        if table.contains(DST_CHARACTERLIST, "gyc") then
            RemoveByValue(DST_CHARACTERLIST, "gyc")
        end        
    end
end

AddClassPostConstruct("widgets/widget", sorabaseenable)

AddIngredientValues({"petals"}, {petals = 1}, false, false)
AddIngredientValues({"saltrock"}, {saltrock = 1}, false, false)
AddIngredientValues({"wetgoop"}, {wetgoop = 1}, false, false)
AddIngredientValues({"bcj_cl2"}, {bcj_cl2 = 1}, false, false)
AddIngredientValues({"bcj_cl5"}, {bcj_cl5 = 1}, false, false)
AddIngredientValues({"bcj_cl6"}, {bcj_cl6 = 1}, false, false)
AddIngredientValues({"bcj_cl10"}, {bcj_cl10 = 1}, false, false)

TUNING.BCJ_HEALTH = 111
TUNING.BCJ_HUNGER = 222
TUNING.BCJ_SANITY = 333

TUNING.GYC_HEALTH = 150
TUNING.GYC_HUNGER = 150
TUNING.GYC_SANITY = 150

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.BCJ = {"bcj_san1", "bcj_444_1"}
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.GYC = {"gyc_mb1", "gyc_hat", "bcj_item1"}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["bcj_san1"] = {
  atlas = "images/inventoryimages/bcj_san1.xml",
  image = "bcj_san1.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["bcj_444_1"] = {
  atlas = "images/inventoryimages/bcj_444.xml",
  image = "bcj_444.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["gyc_mb1"] = {
  atlas = "images/inventoryimages/gyc_mb1.xml",
  image = "gyc_mb1.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["gyc_hat"] = {
  atlas = "images/inventoryimages/gyc_hat.xml",
  image = "gyc_hat.tex",
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["bcj_item1"] = {
  atlas = "images/inventoryimages/bcj_item1.xml",
  image = "bcj_item1.tex",
}

for k, recipe in pairs(require("preparedfoods_bcj")) do
	recipe.no_cookbook = true
    AddCookerRecipe("cookpot", recipe)
end
--[[
for k, recipe in pairs(require("preparedfoods_bcj")) do
    AddCookerRecipe("bcj_cookpot", recipe)
end
]]
for k, recipe in pairs(require("preparedfoods_bcj_spiced")) do
    AddCookerRecipe("portablespicer", recipe)
end

modimport("scripts/postinits/skin.lua")

modimport("scripts/bcj_Strings.lua")
modimport("scripts/mains/Mod_Recipes.lua")
modimport("scripts/mains/Mod_Hook.lua")
modimport("scripts/mains/Mod_SG.lua")
modimport("scripts/mains/Mod_Action.lua")
modimport("scripts/mains/Mod_Respawn.lua")

AddMinimapAtlas("images/map_icons/bcj_lhs.xml")
AddMinimapAtlas("images/map_icons/bcj_taos.xml")
AddMinimapAtlas("images/inventoryimages/bcj_jianzhu11.xml")
AddMinimapAtlas("images/inventoryimages/bcj_jianzhu14.xml")
modimport("scripts/yuki_flyer.lua")

local function OnPerformaction(inst, data)
    if data.action then
        print(data.action.action.id)
    end
end
--[[
AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
         return inst
    end

    inst:ListenForEvent("performaction", OnPerformaction)
end)
]]
--[[
GLOBAL.PREFAB_SKINS["mengyi"] = {   
	"mengyi_none",
}
]]


local function OnPick(inst, data)
    if data and data.picker and data.picker.components.inventory and math.random() <= 0.1 then
        local loot = SpawnPrefab("bcj_cl10")
        data.picker.components.inventory:GiveItem(loot)
    end    
end

AddPrefabPostInit("grass", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("picked", OnPick)
end)    

local function onattunecost(inst, player)
    local amount_required = player:HasTag("health_as_oldage") and math.ceil(TUNING.EFFIGY_HEALTH_PENALTY * TUNING.OLDAGE_HEALTH_SCALE) or TUNING.EFFIGY_HEALTH_PENALTY
    if player.components.health == nil or math.ceil(player.components.health.currenthealth) <= amount_required then
        return false, "NOHEALTH"
    end
    
    player:PushEvent("consumehealthcost")
    player.components.health:DoDelta(-TUNING.EFFIGY_HEALTH_PENALTY, false, "statue_attune", true, inst, true)
    return true
end

local function onlink(inst, player, isloading)
    if not isloading then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/on")
        inst.AnimState:PlayAnimation("10")
    end
end

local function onunlink(inst, player, isloading)
    if not (isloading or inst.AnimState:IsCurrentAnimation("attune_on")) then
        inst.SoundEmitter:PlaySound("dontstarve/common/together/meat_effigy_attune/off")
        inst.AnimState:PlayAnimation("10")
    end
end

local function onbuilt(inst, data)
    inst.components.attunable:SetOnAttuneCostFn(nil)
    inst.components.attunable:SetOnLinkFn(nil)
    inst.components.attunable:SetOnUnlinkFn(nil)
    --End hack
    inst.components.attunable:SetOnAttuneCostFn(onattunecost)  --ThePlayer.components.health:Kill()
    inst.components.attunable:SetOnLinkFn(onlink)
    inst.components.attunable:SetOnUnlinkFn(onunlink)
end

local function OnRespawn(inst)
    inst.respawn_time = inst.respawn_time - 1
    if inst.respawn_time <= 0 then
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("fx_dock_pop").Transform:SetPosition(x, 0, z) 
        inst:Remove()
    else
        inst:Hide()
        inst:DoTaskInTime(5, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("fx_dock_pop").Transform:SetPosition(x, 0, z) 
        inst:Show()            
        end)    
    end    
end

AddPrefabPostInit("bcj_jianzhu10", function(inst)
    inst:AddTag("structure")
    inst:AddTag("resurrector")

    if not TheWorld.ismastersim then
        return
    end

    inst.respawn_time = 1

    inst:AddComponent("attunable")
    inst.components.attunable:SetAttunableTag("remoteresurrector")
    inst.components.attunable:SetOnAttuneCostFn(onattunecost)
    inst.components.attunable:SetOnLinkFn(onlink)
    inst.components.attunable:SetOnUnlinkFn(onunlink)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("activateresurrection", OnRespawn)
end)    

local function OnIsRaining(inst, raining)
    if raining and TheWorld.state.isspring then
        local tree = c_findnext("bcj_taos")
        if tree and tree:IsValid() then
            local x, y, z = tree.Transform:GetWorldPosition()
            tree:Remove()
            SpawnPrefab("lightning").Transform:SetPosition(x, 0, z)            
            SpawnPrefab("bcj_taos_burnt").Transform:SetPosition(x, 0, z)
        end    
    end
end

AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    inst:WatchWorldState("israining", OnIsRaining)
end)    

--添加鬼火
--添加摸金效果

local function ItemTradeTest(inst, item)
    if item and item.prefab == "dug_bcj_lhs" and inst.components.workable == nil then
        return true  
    end

    return false
end

local function OnGetItemFromPlayer(inst, giver, item)------------给金子回耐久
    if item and item.prefab == "dug_bcj_lhs" then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst:Remove()
        item:Remove()
        local tree = SpawnPrefab("bcj_lhs")
        tree.Transform:SetPosition(x, 0, z)
        tree.SoundEmitter:PlaySound("dontstarve/common/plant")

        SpawnPrefab("slide_puff").Transform:SetPosition(x, 0, z) 
        
        local ents = TheSim:FindEntities(x, y, z, 2, { "grave" }) 
        for k, v in ipairs(ents) do
        if v and v:IsValid() then
            local x, y, z = v.Transform:GetWorldPosition()
            v:Remove()
            break
        end
        end    
    end
end

local function SpawnDugFx(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("fossilizing_fx")
    fx.Transform:SetPosition(x, 0, z)

    local fx = SpawnPrefab("chestupgrade_stacksize_fx")
    fx.Transform:SetPosition(x, 0, z)
end

local function FindGraveStone(inst)
    local target = nil
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2, { "grave" }) --直接铲子挖会导致坟墓和墓碑破坏消失
    for k, v in ipairs(ents) do
        if v:IsValid() and v.prefab == "gravestone" and v.mound and v.mound == inst and target == nil then    
            target = v
        end
    end
        
    return target
end

local function OnWork(inst, data)
    if data and data.worker and data.worker.prefab == "bcj" then
        if data.worker.components.inventory:EquipHasTag("bcj_ym") then
        local stone = FindGraveStone(inst)
        if stone ~= nil then
            stone.components.timer:StartTimer("SpawnMound", 480*3)
        end 
        else    
        local stone = FindGraveStone(inst)
        if stone ~= nil then
            stone:Remove()
        end	
        end

        SpawnDugFx(inst)

        local x, y, z = inst.Transform:GetWorldPosition()

        if inst:HasTag("can_mojin") or data.worker.components.inventory:EquipHasTag("bcj_ym") then
            if math.random() >= 0.5 and c_countprefabs("dug_bcj_lhs") == 0  --世界只能有一个
            and c_countprefabs("bcj_lhs") == 0 and c_countprefabs("bcj_lhs_big") == 0 then
            inst.components.lootdropper:SpawnLootPrefab("dug_bcj_lhs")
            end 
        end    

        if data.worker.components.inventory:EquipHasTag("bcj_ym") then
            if inst:HasTag("can_mojin") then
            local mat = math.random()
            if mat <= 0.25 then
            --print("摸金1")
            inst:AddTag("double_loot")

            elseif mat <= 0.5 then
            --print("摸金2")
            local skeleton = SpawnPrefab("skeleton")
            skeleton.Transform:SetPosition(x, 0, z)

            elseif mat <= 0.75 then
            --print("摸金3")    
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl1")                            
            end
            else
            --print("非摸金")
            local mat = math.random()
            if mat <= 0.25 then
            --print("非摸金1")
            inst:AddTag("double_loot")
            end     
            end 

        elseif not data.worker.components.inventory:EquipHasTag("bcj_ym") then   
        local mat = math.random()
        if mat <= 0.33 then 
        local skeleton = SpawnPrefab("skeleton")
        skeleton.Transform:SetPosition(x, 0, z)

        elseif mat <= 0.66 then 
        inst.components.lootdropper:SpawnLootPrefab("bcj_cl1")

        else
        inst:AddTag("bcj_dug")    
        end
        --print("百川玖普通挖")
        inst:DoTaskInTime(0, inst.Remove)
        end

        --inst.components.lootdropper:SpawnLootPrefab("dug_bcj_lhs")
    elseif data and data.worker and data.worker.components.inventory
    and data.worker.components.inventory:EquipHasTag("bcj_ym") then 
        SpawnDugFx(inst)

        if math.random() >= 0.5 and c_countprefabs("dug_bcj_lhs") == 0  --世界只能有一个
        and c_countprefabs("bcj_lhs") == 0 and c_countprefabs("bcj_lhs_big") == 0 then
            inst.components.lootdropper:SpawnLootPrefab("dug_bcj_lhs")
        end	

        local stone = FindGraveStone(inst)
        if stone ~= nil then
            stone.components.timer:StartTimer("SpawnMound", 480*3)
        end	

        if data.worker.prefab == "bcj" then
        	--print("百川玖永眠挖")
            inst:AddTag("bcj_dug")

            if math.random() > 0.5 then
            inst.components.lootdropper:SpawnLootPrefab("bcj_cl1")
            end   
        else 
        	--print("其它玩家永眠挖")
            if math.random() > 0.75 then
            inst:AddTag("double_loot")
            end	
        end
        --inst:DoTaskInTime(0, inst.Remove)	
    end    
end

AddPrefabPostInit("mound", function(inst)  --c_spawn"gravestone"
    if not TheWorld.ismastersim then
        return
    end

    inst.GetHs = OnGetItemFromPlayer
    --[[
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    ]]
    local OldSpawnLootPrefab = inst.components.lootdropper.SpawnLootPrefab  --c_spawn"beefalo".components.health:SetMaxHealth(5000)
    inst.components.lootdropper.SpawnLootPrefab = function(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)
        if inst:HasTag("bcj_dug") and lootprefab and lootprefab ~= "bcj_cl1" then
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)

        elseif inst:HasTag("double_loot") and lootprefab and lootprefab ~= "bcj_cl1" then 
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...)
        else    
            OldSpawnLootPrefab(self, lootprefab, pt, linked_skinname, skin_id, userid, ...) 
        end
    end

    inst:ListenForEvent("worked", OnWork)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "MoJin_Cd" and not inst:HasTag("can_mojin") and inst.components.workable then
            inst:AddTag("can_mojin")             
        end 
    end)

    inst:DoTaskInTime(0, function(inst)  --不存在摸金cd或者cd等于0，添加可摸金标签
        local Buff_NoDead_Cd = inst.components.timer ~= nil and (inst.components.timer:GetTimeLeft("MoJin_Cd") or 0) or nil
        if Buff_NoDead_Cd == nil or (Buff_NoDead_Cd and Buff_NoDead_Cd <= 0)
        and inst.components.workable then  
            inst:AddTag("can_mojin")                       
        end
    end)     
end)  

local function OnHaunt(inst, doer)
    if inst.setepitaph == nil and #STRINGS.EPITAPHS > 1 then
        --change epitaph (if not a set custom epitaph)
        --guarantee it's not the same as b4!
        local oldepitaph = inst.components.inspectable.description
        local newepitaph = STRINGS.EPITAPHS[math.random(#STRINGS.EPITAPHS - 1)]
        if newepitaph == oldepitaph then
            newepitaph = STRINGS.EPITAPHS[#STRINGS.EPITAPHS]
        end
        inst.components.inspectable:SetDescription(newepitaph)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
    else
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
    end

    if doer.prefab == "bcj" then
        doer:PushEvent("respawnfromghost", { source = inst })
    end
    return true
end

local function SpawnMound(inst)
    if inst.mound and inst.mound:IsValid() then
        inst.mound:Remove()
        inst.mound = nil
    end	

	if inst.mound == nil or (inst.mound and not inst.mound:IsValid()) then
    inst.mound = inst:SpawnChild("mound")
    inst.mound.ghost_of_a_chance = 0.0
    inst.mound.Transform:SetPosition((TheCamera:GetDownVec()*.5):Get())
    end
end

AddPrefabPostInit("gravestone", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "SpawnMound" then
            SpawnMound(inst)
        end       
    end) 

    inst.components.hauntable:SetOnHauntFn(OnHaunt)
end)    

local Trad_List = {"treegrowthsolution", "boneshard", "bcj_jianzhu9", "livinglog", "nightmarefuel"}
    
for k, v in pairs(Trad_List) do
    AddPrefabPostInit(v, function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    if inst.components.tradable == nil then
    inst:AddComponent("tradable")
    end
    end)        
 end 

local Skeleton_List = {"skeleton", "skeleton_player"}
    
for k, v in pairs(Skeleton_List) do
    AddPrefabPostInit(v, function(inst)
    inst:AddTag("packable")

        
    if not TheWorld.ismastersim then
        return
    end
    end)        
 end 

local Ti_List = {"meat", "monstermeat", "drumstick", "bcj_lhs_big"}
    
local function CheckYm(inst)
    local player = FindEntity(inst, 4, nil, {"player"})
    if player and player.components.inventory and player.components.inventory:EquipHasTag("bcj_ym") and inst.bcj_ti == false then
        inst:RemoveTag(ACTIONS.CHOP.id.."_workable")
    elseif not inst:HasTag(ACTIONS.CHOP.id.."_workable") then 
        inst:AddTag(ACTIONS.CHOP.id.."_workable")       
    end	
end

for k, v in pairs(Ti_List) do
    AddPrefabPostInit(v, function(inst)
    if not TheWorld.ismastersim then
        return
    end
    
    inst.bcj_ti = false
    inst.OnSave = function(inst, data)
       data.bcj_ti = inst.bcj_ti
    end
    inst.OnLoad = function(inst, data)
       inst.bcj_ti = data.bcj_ti
    end

    if inst.prefab == "bcj_lhs_big" then
    inst:DoPeriodicTask(0.1, CheckYm)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", function(inst, data)
        if data.name == "Ti_Cd" then
            inst.bcj_ti = false
        end       
    end) 
    end    
    end)        
 end 