GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
--table.insert(PrefabFiles, "yuki_flyer_fx")

local IsFlying = function(inst) return inst and inst.components.yuki_flyer and inst.components.yuki_flyer:IsFlying()end
local IsInRoom = function(inst) local pos = inst and inst:GetPosition() return pos and math.abs(pos.z) > 1200 end

local YKFLYLAND = Action({ priority = 3})
YKFLYLAND.id = "YKFLYLAND"
YKFLYLAND.str = "着陆"
YKFLYLAND.fn = function(act)
    if act.doer and act.doer.components.yuki_flyer  then  --ThePlayer.components.yuki_flyer:SetFlying(true)
		act.doer.components.yuki_flyer:SetFlying(false)  --.sg:GoToState("myth_flyskill_up")
		return true
	end
	return false
end
AddAction(YKFLYLAND)
AddStategraphActionHandler("wilson", ActionHandler(YKFLYLAND, "gyc_flyskill_down"))
AddStategraphActionHandler("wilson_client",ActionHandler(YKFLYLAND, "gyc_flyskill_down"))

AddComponentAction("SCENE", "yuki_flyer" , function(inst, doer, actions, right)
    if right and (inst == ThePlayer or TheWorld.ismastersim) then
		if IsFlying(doer) and not inst:HasTag("playerghost") then
			table.insert(actions, ACTIONS.YKFLYLAND)
		end
    end   
end) 

local oldPlayFootstep=GLOBAL.PlayFootstep
GLOBAL.PlayFootstep=function(inst, ...) --去除脚步声
	if inst and IsFlying(inst) then
		return
	end
	return oldPlayFootstep(inst, ...)
end

local function StopFlying(inst, noAnim) --服务器
	if inst and IsFlying(inst) then
		inst.components.yuki_flyer:SetFlying(false)
		inst.components.yuki_flyer._yukipercent:set(0)
	end
end

AddClassPostConstruct("components/builder_replica", function(self, inst)
	local old_MakeRecipeAtPoint = self.MakeRecipeAtPoint
	function self:MakeRecipeAtPoint(...)
		if IsFlying(self.inst) then
			return false
		end
		return old_MakeRecipeAtPoint(self,...)
	end
end)

AddComponentPostInit("freezable",function(self)
	local oldFreeze=self.Freeze
	self.Freeze=function(self, freezetime, ...)
		local inst=self.inst
		StopFlying(inst, true) --冰冻结束飞行
		return oldFreeze(self, freezetime, ...)
	end
end)

AddComponentPostInit("grogginess",function(self)
	local oldKnockOut=self.KnockOut
	self.KnockOut=function(self, ...)
		local inst=self.inst
		StopFlying(inst, true) --睡眠结束飞行
		return oldKnockOut(self, ...)
	end
end)

AddComponentPostInit("highlight",function(self)
	local oldHighlight=self.Highlight
	self.Highlight=function(self, r, g, b, ...)
		local inst=self.inst
		if inst:HasTag("NOHIGHLIGHT") then --禁止高亮
			return
		end
		return oldHighlight(self, r, g, b, ...)
	end
end)

AddPrefabPostInit("lureplant", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:DoTaskInTime(0.1,function()
		local pt = Point(inst.Transform:GetWorldPosition())
		if inst.Physics then
			inst.Physics:Teleport(pt.x, 0, pt.z)
		end	
	end)
end)

AddPrefabPostInit("rock_ice", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:DoTaskInTime(0.1,function()
		local pt = Point(inst.Transform:GetWorldPosition())
		if inst.Physics then
			inst.Physics:Teleport(pt.x,0,pt.z)
		end	
	end)
end)

local function checkfly(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15, {"player"}, {"INLIMBO","playerghost"})
    for i, v in ipairs(ents) do
        if v:IsValid() and v.components.health and not v.components.health:IsDead() and IsFlying(v) then	
			if v.components.yuki_flyer:GetPercent() >= 1 then
				StopFlying(v)
				v.components.combat:GetAttacked(inst, 20, nil, "darkness")
				v.components.sanity:DoDelta(-10)	
			end
		end
	end
end

AddPrefabPostInit("stalker", function(inst)
	if not TheWorld.ismastersim then
		return
	end
	inst:DoPeriodicTask(1, checkfly, 1)
end)

local flyrecipe = {
	  yuki_flyskill = true
}

local function AddPlayerSgPostInit(fn)
    AddStategraphPostInit('wilson', fn)
    AddStategraphPostInit('wilson_client', fn)
end

AddPlayerSgPostInit(function(self)
	local run = self.states.run 
	if run then
		local old_enter = run.onenter
		function run.onenter(inst, ...)
			if old_enter then 
				old_enter(inst, ...)
			end
			if IsFlying(inst) then
				if not inst.AnimState:IsCurrentAnimation("myth_surf_loop") then
					inst.AnimState:PlayAnimation("myth_surf_loop", true)
				end
				inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.01)
			end
		end
	end

	local run_start = self.states.run_start 
	if run_start then
		local old_enter = run_start.onenter
		function run_start.onenter(inst, ...)
			if old_enter then 
				old_enter(inst, ...)
			end
			if IsFlying(inst) then
				inst.AnimState:PlayAnimation("myth_surf_pre")
			end
		end
	end

	local run_stop = self.states.run_stop 
	if run_stop then
		local old_enter = run_stop.onenter
		function run_stop.onenter(inst, ...)
			if old_enter then 
				old_enter(inst, ...)
			end
			if IsFlying(inst) then
				inst.AnimState:PlayAnimation("myth_surf_pst")
			end
		end
	end
end)

local function JumpState(client, is_up)
	-- timeline
	local tl = client and {
		TimeEvent(0* FRAMES, function(inst)inst:PerformPreviewBufferedAction() end),
    	TimeEvent(4* FRAMES, function(inst)inst.sg:RemoveStateTag('busy') end),
	}or {
		TimeEvent(1* FRAMES, function(inst)inst:PerformBufferedAction() end)
	}
	-- onupdate
	local up = client and function(inst)
		if inst:HasTag("doing") then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle", true)
        end
    end or function() end
    -- events
    local evt = {
    	EventHandler(client and "animqueueover" or "animover", function(inst) inst.sg:GoToState("idle") end)
    }

	return State{
		name = "gyc_flyskill".. (is_up and "_up" or "_down"),
	    tags ={"idle", "myth_flyskill","busy","doing","notalking"},
	    onenter = function(inst)
	        --inst.Physics:Stop() 
	        inst.components.locomotor:Stop()
			if  inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
				inst.sg:GoToState("idle")
				inst:ClearBufferedAction()
				return 
			end

	        inst.AnimState:HideSymbol("droplet")
	        inst.AnimState:PlayAnimation("jumpboat")
	        if inst.components.yuki_flyer then
	            inst.components.yuki_flyer._yukipercent:set_local(is_up and 0 or 1)
	            --inst.components.yuki_flyer:SetFlying(is_up and true or false)
            end	

	        if inst.components.health then
				inst.components.health:SetInvincible(true)
			end

			inst.sg:SetTimeout(2)
	    end,

	    timeline = tl,
	    onupdate = function(inst, dt)
	    	if is_up then
	    		if inst.components.yuki_flyer then
	    		    inst.components.yuki_flyer._yukipercent:set_local(math.min(inst.components.yuki_flyer:GetPercent() + 1.4*dt, 1))
	    		end      
	    	else
	    		if inst.components.yuki_flyer then
	    		    inst.components.yuki_flyer._yukipercent:set_local(math.max(inst.components.yuki_flyer:GetPercent() - 2*dt, 0))
	    		end      
	    	end
	    end,

	    ontimeout = function(inst)
	    	inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("idle")
            inst.sg:GoToState("idle", true)
        end,

	    events = evt,

	    onexit = function(inst)
	    	if inst.components.yuki_flyer then
			    if not inst.components.yuki_flyer:IsFlying() then --避免起飞过程下来触发bug
				    inst.components.yuki_flyer._yukipercent:set(0)
			     else
				    inst.components.yuki_flyer._yukipercent:set(is_up and 1 or 0)
			    end			
			end 

	    	if inst.components.health then
				inst.components.health:SetInvincible(false)
			end
		end,
	}
end

AddStategraphState("wilson", JumpState(false, true))
AddStategraphState("wilson_client", JumpState(true, true))
AddStategraphState("wilson", JumpState(false, false))
AddStategraphState("wilson_client", JumpState(true, false))

------------------------------------改写SG-------------------------------------
local function CheckCanFly(inst)
    if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("doing") and inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("runing") or inst:HasTag("playerghost")
    or inst.components.rider:IsRiding() or inst.components.freezable:IsFrozen() or inst.components.inventory:IsHeavyLifting()
    or inst.components.pinnable:IsStuck() or inst.components.playercontroller:IsEnabled() == false
    or inst.components.llmy_power.current < 25
    or IsFlying(inst) == true or IsInRoom(inst) == true
    or inst.level2 < 2 then  --and )
    	if inst:HasTag("can_fly") then
            inst:RemoveTag("can_fly")
        end
        
    elseif not inst:HasTag("can_fly") then 
        inst:AddTag("can_fly")        
    end
end

AddPlayerPostInit(function(inst)
	if inst.prefab ~= "gyc" then return end
	inst.AnimState:HideSymbol("droplet")
	
    if inst.components.yuki_flyer == nil then
	    inst:AddComponent("yuki_flyer")
    end

	if TheWorld.ismastersim then
		inst:ListenForEvent("hungerdelta", function(inst,data) --饱食度耗尽结束飞行
			if data and data.newpercent<=0 then
				StopFlying(inst)
			end
		end)
		inst:ListenForEvent("death", function(inst,data) --死亡结束飞行
			StopFlying(inst)
		end)
		inst:ListenForEvent("transform_wereplayer", function(inst,data) --死亡结束飞行
			StopFlying(inst)
		end)

		--if inst.components.playercontroller then
		inst:DoPeriodicTask(0, CheckCanFly)
		inst:ListenForEvent("Llmy_Power_delta", function(inst)
			if inst.components.llmy_power.current <= 0 then
		        local buffaction = BufferedAction(inst, nil, ACTIONS.YKFLYLAND)
                inst.components.locomotor:PushAction(buffaction, true)
            end
        end)
	    --end
	end
end)

