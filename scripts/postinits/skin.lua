-- In this file: Miscellaneous edits to prefabs, components, widgets, etc.

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local TUNING = GLOBAL.TUNING
local CHARACTER_INGREDIENT = GLOBAL.CHARACTER_INGREDIENT
local CHARACTER_INGREDIENT_SEG = GLOBAL.CHARACTER_INGREDIENT_SEG
local AllRecipes = GLOBAL.AllRecipes
local SpawnPrefab = GLOBAL.SpawnPrefab
local ACTIONS = GLOBAL.ACTIONS
local RemovePhysicsColliders = GLOBAL.RemovePhysicsColliders
local FRAMES = GLOBAL.FRAMES
local ActionHandler = GLOBAL.ActionHandler
local EventHandler = GLOBAL.EventHandler
local State = GLOBAL.State
local TimeEvent = GLOBAL.TimeEvent
local GetValidRecipe = GLOBAL.GetValidRecipe
local FOODTYPE = GLOBAL.FOODTYPE
local GetGameModeProperty = GLOBAL.GetGameModeProperty
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local PREFAB_SKINS = GLOBAL.PREFAB_SKINS
local PREFAB_SKINS_IDS = GLOBAL.PREFAB_SKINS_IDS
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")
local Vector3 = GLOBAL.Vector3
local Lerp = GLOBAL.Lerp
local DEGREES = GLOBAL.DEGREES

local PREFAB_SKINS = GLOBAL.PREFAB_SKINS
local PREFAB_SKINS_IDS = GLOBAL.PREFAB_SKINS_IDS  
local SKIN_AFFINITY_INFO = GLOBAL.require("skin_affinity_info")

modimport("scripts/util/bcj_skin_api.lua")

SKIN_AFFINITY_INFO.bcj = { "bcj_skin1_none" }
SKIN_AFFINITY_INFO.gyc = { "gyc_skin1_none" }

PREFAB_SKINS_IDS = {}
for prefab,skins in pairs(PREFAB_SKINS) do
    PREFAB_SKINS_IDS[prefab] = {}
    for k,v in pairs(skins) do
          PREFAB_SKINS_IDS[prefab][v] = k
    end
end

AddSkinnableCharacter("bcj") 
AddSkinnableCharacter("gyc") 
