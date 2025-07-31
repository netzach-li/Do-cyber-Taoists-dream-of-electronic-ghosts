local assets =
{ 
	Asset( "ANIM", "anim/gyc.zip" ),
	Asset( "ANIM", "anim/gyc_skin.zip" ),
	Asset( "ANIM", "anim/ghost_build.zip" ),
}

local skins =
{
	normal_skin = "gyc",
	ghost_skin = "ghost_build",
}

local skins2 =
{
	normal_skin = "gyc_skin",
	ghost_skin = "ghost_build",
}

local base_prefab = "gyc"

local tags = {"BASE" ,"gyc", "CHARACTER"}

return
CreatePrefabSkin("gyc_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	skin_tags = tags,
	
	build_name_override = "gyc",
	rarity = "Character",
}),

CreatePrefabSkin("gyc_skin1_none",  
{
	base_prefab = base_prefab, 	
	skins = skins2,  
	assets = assets,
	skin_tags = tags,
	build_name_override = "gyc",
	rarity = "Spiffy",
	skip_item_gen = true,
	skip_giftable_gen = true,	
})