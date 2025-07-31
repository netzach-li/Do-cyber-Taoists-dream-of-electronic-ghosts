local assets =
{ 
	Asset( "ANIM", "anim/bcj.zip" ),
	Asset( "ANIM", "anim/bcj_skin.zip" ),
	Asset( "ANIM", "anim/ghost_build.zip" ),
}

local skins =
{
	normal_skin = "bcj",
	ghost_skin = "ghost_build",
}

local skins2 =
{
	normal_skin = "bcj_skin",
	ghost_skin = "ghost_build",
}


local base_prefab = "bcj"

local tags = {"BASE" ,"bcj", "CHARACTER"}

return CreatePrefabSkin("bcj_none",
{
	base_prefab = base_prefab, 
	skins = skins, 
	assets = assets,
	skin_tags = tags,
	
	build_name_override = "bcj",
	rarity = "Character",
}),

CreatePrefabSkin("bcj_skin1_none",  
{
	base_prefab = base_prefab, 	
	skins = skins2,  
	assets = assets,
	skin_tags = tags,
	build_name_override = "bcj",
	rarity = "Spiffy",
	skip_item_gen = true,
	skip_giftable_gen = true,	
})