local assets = {
	-- anim
	Asset( "ANIM", "anim/myth_surf.zip"),
	Asset( "ANIM", "anim/act_jumpboat.zip"),
	-- build
	Asset( "ANIM", "anim/yuki_cloudfx.zip" ),
	--Asset( "ANIM", "anim/mk_cloudfx1.zip" ),
	--Asset( "ANIM", "anim/mk_cloudfx2.zip" ),
	--Asset( "ANIM", "anim/mk_cloudfx3.zip" )

	--Asset( "ANIM", "anim/yj_spear_elec_shockfx_build.zip"), -- 人物才会触发所以不加了
}

local function Root()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")

	return inst
end

local function SingleCloud() -- 圆云
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.AnimState:SetBank("mk_cloudfx")
    inst.AnimState:PlayAnimation("anim_loop", true)
    inst.AnimState:SetTime(math.random())
	inst.AnimState:SetFinalOffset(-1)
	inst.base_alpha = 0.5

	inst.persists = false
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")

	return inst
end

local function cloud_update(inst) -- 控制云的大小
	local base = math.sin((GetTime()+inst.timeoffset)*inst.scalespeed) -- -1~1
	local scale = inst.scale + inst.scale_v*base
	scale = scale * inst.scale_mult 
	inst.Transform:SetScale(scale, scale, scale)
end

local function cloud_config(inst, data)
	-- 缩放大小
	inst.scale = data.scale or 1
	inst.scale_v = data.scale_v or 0.3
	-- 缩放速度
	inst.scalespeed = data.scalespeed or 1
	inst.scalespeed_v = data.scalespeed_v or 0.2
	-- 动画速度
	inst.animspeed = data.animspeed or 1
	inst.animspeed_v = data.animspeed_v or 0
	-- 半径
	inst.radius = data.radius or 0.6
	-- build
	inst.build = "yuki_cloudfx" or error("Must set a build!")

	inst.base_alpha = data.base_alpha or 1
end

local function applyconfig(inst, other)
	other.scale = inst.scale
	other.scale_v = inst.scale_v
	other.scale_mult = 1

	other.scalespeed = GetRandomWithVariance(inst.scalespeed, inst.scalespeed_v)
	other.timeoffset = 2*PI*math.random()/other.scalespeed

	other.AnimState:SetDeltaTimeMultiplier(GetRandomWithVariance(inst.animspeed, inst.animspeed_v))

	other.AnimState:SetBuild(inst.build)

	other.base_alpha = inst.base_alpha

	local a = other.base_alpha
	--other.AnimState:SetMultColour(128/255, 0.1, 128/255, 1)
end

local function cloud_init(inst)
	for i = 1,7 do
		local r = i == 7 and 0 or inst.radius
		local a = i* PI/3
		local offset = Vector3(math.cos(a)*r, 0, math.sin(a)*r)
		local fx = SingleCloud()
		inst:applyconfig(fx)
		inst:AddChild(fx)
		inst.fx[fx] = true
		fx.Transform:SetPosition(offset:Get())
		fx:DoPeriodicTask(0, cloud_update)
	end
end

local function Despawn(inst, time)
	-- 渐隐消失
	time = time or 1
	local progress = 1
	inst:DoPeriodicTask(0, function()
		for k in pairs(inst.fx)do
			if k:IsValid() then
				k.scale_mult = progress
				local a = progress * inst.base_alpha
				--k.AnimState:SetMultColour(128/255, 0.1, 128/255, 1)
			end
		end
		progress = progress - FRAMES/time
		if progress < 0 then
			inst:Remove()
		end
	end)
end

local function CloudFx()
	local inst = Root()
	local s = 0.7
	inst.Transform:SetScale(s,s,s)
	inst.fx = {}
	inst.config = cloud_config
	inst.applyconfig = applyconfig
	inst.init = cloud_init
	inst.Despawn = Despawn

	return inst
end

local function tail_config(inst, data)
	-- 初始大小
	inst.scale = data.scale or 1
	inst.scale_v = data.scale_v or 0.1
	-- 渐隐时间
	inst.fadetime = data.fadetime or 2
	-- 变小
	inst.changescale = data.changescale ~= false
	-- 变透明
	inst.changealpha = data.changealpha ~= false
	-- build
	inst.build = "yuki_cloudfx" or error("Must set a build!")

	inst.base_alpha = data.base_alpha or 1
end

local function tail_apply(inst, other)
	other.scale = 0.7* GetRandomWithVariance(inst.scale, inst.scale_v)
	other.Transform:SetScale(other.scale, other.scale, other.scale)
	other.AnimState:SetBuild(inst.build)

	other.fadetime = inst.fadetime
	other.changescale = inst.changescale
	other.changealpha = inst.changealpha  

	other.base_alpha = inst.base_alpha
	local a = inst.base_alpha
	--other.AnimState:SetMultColour(128/255, 0.1, 128/255, 1)
end

local function tail_update(inst, parent)
	local p = inst.progress
	if inst.changescale then
		local s = inst.scale * p
		inst.Transform:SetScale(s,s,s)
	end
	if inst.changealpha then
		local a = p * inst.base_alpha
		--inst.AnimState:SetMultColour(128/255, 0.1, 128/255, 1)
	end
	inst.progress = p - FRAMES/inst.fadetime
	if inst.progress < 0 then
		if parent:IsValid() then
			parent:Remove()
		end
		if inst:IsValid() then
			inst:Remove()
		end
	end
end

local function tail_init(inst)
	local fx = SingleCloud()
	inst:AddChild(fx)
	inst.fx = fx
	tail_apply(inst, fx)
	fx.progress = 1
	fx:DoPeriodicTask(0, tail_update, nil, inst)
end

local function setheight(inst, height)
	if inst.fx and inst.fx:IsValid() then
		inst.fx.Transform:SetPosition(0,height,0)
	end
end

local function CloudTailFx()
	local inst = Root()
	MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)

	inst.config = tail_config
	inst.init = tail_init
	inst.setheight = setheight

	return inst
end

return Prefab("yuki_flyerfx_cloud", CloudFx, assets),
	   Prefab("yuki_flyerfx_cloud_tail", CloudTailFx, assets)
