
AddRoom("RosePatch", 
{
	colour = {r=.8,g=1,b=.8,a=.50}, 

	value = GROUND.DECIDUOUS,	--季节性地皮
	--tags = {"ExitPiece", "Chester_Eyebone"},

	contents =  
	{
		countprefabs =	--必定会出现对应数量的物品的表
		{
			bcj_taos = 5,
		},

		distributepercent = 0.2,	--distributeprefabs中物品的区域密集程度
		distributeprefabs =	--物品的数量分布比例
		{
            fireflies = 0.1,
			flower = 0.35,
			flower_rose = 0.35,
			deciduoustree = 0.52,
			catcoonden = 0.05,
			red_mushroom = 0.21,
			sapling = 0.2,
			rose = 0.2,
			rose = 0.3,
		},
	}
})