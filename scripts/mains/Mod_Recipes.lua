GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
--[[
Recipe("gyc_item2", {Ingredient("goldnugget", 5), Ingredient("purplegem", 1), Ingredient("bcj_cl3", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_item2.xml", 
"gyc_item2.tex")

Recipe("gyc_item3", {Ingredient("dreadstone", 6), Ingredient("livinglog", 1), Ingredient("livinglog", 1), Ingredient("livinglog", 10)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_item3.xml",  
"gyc_item3.tex")
]]
--[[
Recipe("bcj_item4", {Ingredient("silk", 7)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/bcj_item4.xml", 
"bcj_item4.tex")

Recipe("bcj_item5", {Ingredient("silk", 7)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_item5.xml", 
"bcj_item5.tex")
]]
Recipe("bcj_glass", {Ingredient("goldnugget", 20), Ingredient("silk", 8), Ingredient("boneshard", 6), Ingredient("papyrus", 1), Ingredient("feather_robin", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_glass.xml", 
"bcj_glass.tex")

Recipe("bcj_glass2", {Ingredient("goldnugget", 20), Ingredient("silk", 8), Ingredient("boneshard", 6), Ingredient("papyrus", 1), Ingredient("feather_crow", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_glass.xml", 
"bcj_glass.tex", nil, "bcj_glass")

Recipe("bcj_glass3", {Ingredient("goldnugget", 20), Ingredient("silk", 8), Ingredient("boneshard", 6), Ingredient("papyrus", 1), Ingredient("feather_robin_winter", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_glass.xml", 
"bcj_glass.tex", nil, "bcj_glass")

Recipe("bcj_glass4", {Ingredient("goldnugget", 20), Ingredient("silk", 8), Ingredient("boneshard", 6), Ingredient("papyrus", 1), Ingredient("feather_canary", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_glass.xml", 
"bcj_glass.tex", nil, "bcj_glass")

Recipe("bcj_sword1", {Ingredient("boneshard", 20), Ingredient("goldnugget", 6), Ingredient("silk", 4)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_sword1.xml", 
"bcj_sword1.tex")

Recipe("bcj_sword2", {Ingredient("bcj_sword1", 1, "images/inventoryimages/bcj_sword1.xml"), Ingredient("nightmarefuel", 12), Ingredient("thulecite", 6)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_sword2.xml", 
"bcj_sword2.tex")

Recipe("bcj_sword3", {Ingredient("bcj_sword2", 1, "images/inventoryimages/bcj_sword2.xml"), Ingredient("shadowheart", 1), Ingredient("shroom_skin", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_sword3.xml", 
"bcj_sword3.tex")

Recipe("bcj_gun", {Ingredient("goldnugget", 20), Ingredient("papyrus", 5), Ingredient("bcj_ghost_soul", 3, "images/inventoryimages/bcj_ghost_soul.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_gun.xml", 
"bcj_gun.tex")

Recipe("bcj_san1", {Ingredient("boneshard", 4), Ingredient("silk", 7)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_san1.xml", 
"bcj_san1.tex")

Recipe("bcj_san2", {Ingredient("bcj_san1", 1, "images/inventoryimages/bcj_san1.xml"), Ingredient("nightmarefuel", 4), Ingredient("batwing", 7)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_san2.xml", 
"bcj_san2.tex")

Recipe("bcj_san3", {Ingredient("bcj_san2", 1, "images/inventoryimages/bcj_san2.xml"), Ingredient("cane", 1), Ingredient("gears", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_san3.xml", 
"bcj_san3.tex")

Recipe("gyc_fc", {Ingredient("walrus_tusk", 1), Ingredient("manrabbit_tail", 3), Ingredient("bcj_cl4", 1, "images/inventoryimages/bcj_cl4.xml"), Ingredient("orangegem", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_fc.xml", 
"gyc_fc.tex")

Recipe("gyc_mb1", {Ingredient("bcj_cl7", 2, "images/inventoryimages/bcj_cl7.xml"), Ingredient("manrabbit_tail", 1), Ingredient("goldnugget", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_mb1.xml", 
"gyc_mb1.tex")

Recipe("gyc_mb2", {Ingredient("gyc_mb1", 1, "images/inventoryimages/gyc_mb1.xml"), Ingredient("manrabbit_tail", 6), Ingredient("goldnugget", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_mb2.xml", 
"gyc_mb2.tex")

Recipe("gyc_mb3", {Ingredient("gyc_mb2", 1, "images/inventoryimages/gyc_mb2.xml"), Ingredient("bcj_cl4", 5, "images/inventoryimages/bcj_cl4.xml"), Ingredient("moonrocknugget", 5), Ingredient("opalpreciousgem", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_mb3.xml", 
"gyc_mb3.tex")
--诛邪剑x1，雷击木x5，彩虹宝石x1   
Recipe("gyc_tmj2", {Ingredient("gyc_tmj1", 1, "images/inventoryimages/gyc_tmj1.xml"), Ingredient("bcj_cl7", 2, "images/inventoryimages/bcj_cl7.xml"), Ingredient("silk", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg2",
"images/inventoryimages/gyc_tmj2.xml", 
"gyc_tmj2.tex")

Recipe("gyc_tmj3", {Ingredient("gyc_tmj2", 1, "images/inventoryimages/gyc_tmj2.xml"), Ingredient("bcj_cl4", 5, "images/inventoryimages/bcj_cl4.xml"), Ingredient("houndstooth", 6)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg3",
"images/inventoryimages/gyc_tmj3.xml", 
"gyc_tmj3.tex")

Recipe("gyc_tmj4", {Ingredient("gyc_tmj3", 1, "images/inventoryimages/gyc_tmj3.xml"), Ingredient("bcj_cl4", 5, "images/inventoryimages/bcj_cl4.xml"), Ingredient("purplegem", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg4",
"images/inventoryimages/gyc_tmj4.xml", 
"gyc_tmj4.tex")

Recipe("gyc_tmj5", {Ingredient("gyc_tmj4", 1, "images/inventoryimages/gyc_tmj4.xml"), Ingredient("bcj_cl4", 5, "images/inventoryimages/bcj_cl4.xml"), Ingredient("opalpreciousgem", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/gyc_tmj5.xml", 
"gyc_tmj5.tex")

Recipe("bcj_cl5", {Ingredient("bcj_cl10", 2, "images/inventoryimages/bcj_cl10.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, nil,
"images/inventoryimages/bcj_cl5.xml", 
"bcj_cl5.tex")

Recipe("bcj_fu1", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("papyrus", 1), Ingredient("bcj_cl6", 1, "images/inventoryimages/bcj_cl6.xml"), Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg4",
"images/inventoryimages/bcj_fu1.xml", 
"bcj_fu1.tex")

Recipe("bcj_fu2", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("papyrus", 1), Ingredient("goldnugget", 2)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg1",
"images/inventoryimages/bcj_fu2.xml", 
"bcj_fu2.tex")

Recipe("bcj_fu3", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("papyrus", 1), Ingredient("bcj_ghost_soul", 1, "images/inventoryimages/bcj_ghost_soul.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg1",
"images/inventoryimages/bcj_fu3.xml", 
"bcj_fu3.tex")

Recipe("bcj_fu3s", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("papyrus", 1), Ingredient("fireflies", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg5",
"images/inventoryimages/bcj_fu3.xml", 
"bcj_fu3.tex", nil, "bcj_fu3")

Recipe("bcj_fu4", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("papyrus", 1), Ingredient("bcj_cl4", 1, "images/inventoryimages/bcj_cl4.xml"), Ingredient("goose_feather", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg5",
"images/inventoryimages/bcj_fu4.xml", 
"bcj_fu4.tex")

Recipe("bcj_fu5", {Ingredient("mosquitosack", 1), Ingredient("bcj_cl3", 1, "images/inventoryimages/bcj_cl3.xml"), Ingredient("nightmarefuel", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc_sg5",
"images/inventoryimages/bcj_fu5.xml", 
"bcj_fu5.tex")

Recipe("bcj_cl11", {Ingredient("flint", 1), Ingredient("monstermeat", 1), Ingredient("petals", 1)}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "gyc",
"images/inventoryimages/bcj_cl11.xml", 
"bcj_cl11.tex")

Recipe("bcj_item2", {Ingredient("goldnugget", 5), Ingredient("purplegem", 1), Ingredient("bcj_cl3", 1, "images/inventoryimages/bcj_cl3.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_item2.xml", 
"bcj_item2.tex")

Recipe("bcj_item3", {Ingredient("dreadstone", 6), Ingredient("townportaltalisman", 1), Ingredient("orangegem", 1), Ingredient("bcj_ghost_soul", 10, "images/inventoryimages/bcj_ghost_soul.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_item3.xml", 
"bcj_item3.tex")

Recipe("bcj_ym", {Ingredient("goldnugget", 10), Ingredient("livinglog", 2), Ingredient("bluegem", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_ym.xml", 
"bcj_ym.tex")

Recipe("bcj_jianzhu9", {Ingredient("bcj_cl7", 12, "images/inventoryimages/bcj_cl7.xml"), Ingredient("bcj_cl4", 3, "images/inventoryimages/bcj_cl4.xml")}, RECIPETABS.TOWN, TECH.NONE, 
{no_deconstruction = true}, nil, nil, 1, "bcj",
"images/inventoryimages/bcj_jianzhu9.xml", 
"bcj_jianzhu9.tex")

local bcj_jianzhu4 = AddRecipe("bcj_jianzhu4", {Ingredient("cutstone", 10), Ingredient("bcj_ghost_soul", 5, "images/inventoryimages/bcj_ghost_soul.xml")}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu4_placer", nil, nil, nil, "bcj_char", "images/inventoryimages/bcj_jianzhu4.xml")
AddRecipeToFilter("bcj_jianzhu4", "LIGHT")

local bcj_jianzhu6 = AddRecipe("bcj_jianzhu6", {Ingredient("cutstone", 5), Ingredient("boneshard", 5), Ingredient("charcoal", 2)}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu6_placer", nil, nil, nil, "bcj_char", "images/inventoryimages/bcj_jianzhu6.xml")
AddRecipeToFilter("bcj_jianzhu6", "STRUCTURES")

local bcj_cd2 = AddRecipe("bcj_cd2", {Ingredient("goldnugget", 3), Ingredient("bluegem", 1), Ingredient("redgem", 1), Ingredient("purplegem", 1), Ingredient("boards", 3)}, RECIPETABS.TOWN, TECH.NONE, "bcj_cd2_placer", nil, nil, nil, "bcj_char", "images/inventoryimages/bcj_cd2.xml")
AddRecipeToFilter("bcj_cd2", "STRUCTURES")

local bcj_jianzhu1 = AddRecipe("bcj_jianzhu1", {Ingredient("bcj_cl1", 1, "images/inventoryimages/bcj_cl1.xml")}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu1_placer", nil, nil, nil, "bcj", "images/inventoryimages/bcj_jianzhu1.xml")
local bcj_jianzhu8 = AddRecipe("bcj_jianzhu8", {Ingredient("cutreeds", 12), Ingredient("cutgrass", 12), Ingredient("silk", 12)}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu8_placer", nil, nil, nil, "gyc", "images/inventoryimages/bcj_jianzhu8.xml")
local bcj_jianzhu10 = AddRecipe("bcj_jianzhu10", {Ingredient("bcj_cl11", 1, "images/inventoryimages/bcj_cl11.xml"), Ingredient("meat", 5), Ingredient("bcj_cl7", 4, "images/inventoryimages/bcj_cl7.xml"), Ingredient("bcj_cl4", 1, "images/inventoryimages/bcj_cl4.xml"), Ingredient("papyrus", 1)}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu10_placer", nil, nil, nil, "gyc_sg3", "images/inventoryimages/bcj_jianzhu10.xml")
local bcj_jianzhu11 = AddRecipe("bcj_jianzhu11", {Ingredient("bcj_cl7", 1, "images/inventoryimages/bcj_cl7.xml"), Ingredient("silk", 8), Ingredient("papyrus", 3), Ingredient("boards", 4), Ingredient("goldnugget", 2)}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu11_placer", nil, nil, nil, "bcj_char", "images/inventoryimages/bcj_jianzhu11.xml")
local bcj_jianzhu12 = AddRecipe("bcj_jianzhu12", {Ingredient("bcj_cl3", 3, "images/inventoryimages/bcj_cl3.xml"), Ingredient("rope", 1), Ingredient("goldnugget", 1)}, RECIPETABS.TOWN, TECH.NONE, "bcj_jianzhu12_placer", nil, nil, nil, "gyc", "images/inventoryimages/bcj_jianzhu12.xml")

CONSTRUCTION_PLANS["gyc_table1"] = { Ingredient("turkeydinner", 1), Ingredient("bcj_cl7", 1, "images/inventoryimages/bcj_cl7.xml"), Ingredient("livinglog", 2)}
CONSTRUCTION_PLANS["gyc_table2"] = { Ingredient("surfnturf", 2), Ingredient("bcj_cl7", 2, "images/inventoryimages/bcj_cl7.xml"), Ingredient("nightmarefuel", 10)}
CONSTRUCTION_PLANS["gyc_table3"] = { Ingredient("bcj_food11", 3, "images/inventoryimages/bcj_food11.xml"), Ingredient("bcj_cl7", 3, "images/inventoryimages/bcj_cl7.xml"), Ingredient("deerclops_eyeball", 1)}
CONSTRUCTION_PLANS["gyc_table4"] = { Ingredient("bcj_food7", 4, "images/inventoryimages/bcj_food7.xml"), Ingredient("bcj_cl7", 4, "images/inventoryimages/bcj_cl7.xml"), Ingredient("dragon_scales", 1)}
CONSTRUCTION_PLANS["gyc_table5"] = { Ingredient("mandrakesoup", 1), Ingredient("bcj_cl7", 5, "images/inventoryimages/bcj_cl7.xml"), Ingredient("shadowheart", 1)}

--AllRecipes["gyc_table1"].builder_tag = "123"

local recipe = {
   "gyc_fc",
   "gyc_mb1",
   "gyc_mb2",
   "gyc_mb3",
}

for k, v in pairs(recipe) do
    AddRecipeToFilter(v, "CHARACTER")
end
--[[
for k, v in pairs(special_recipe) do
    AddRecipeToFilter(v, "CRAFTING_STATION")
end
]]