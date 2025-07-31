GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

AddStategraphState('wilson',  --ThePlayer.sg:GoToState("cointosscastspell", true)
    State{
        name = "gyc_xuli",
        tags = {"doing", "nointerrupt"}, --, "busy", "nodangle"

        onenter = function(inst)
            local pos = buffaction ~= nil and buffaction:GetActionPoint() or nil
            if pos ~= nil then
                inst:ForceFacePoint(pos:Get())
            end
            inst:AddTag("gyc_xuli")
            inst.xl_time = 0
            inst.xl_task = inst:DoPeriodicTask(1, function(inst)  --每秒加一级，最多三级
                inst.xl_time = inst.xl_time + 1
            end)

            inst.sg:SetTimeout(4)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_dir_pre")  --ThePlayer.AnimState:PlayAnimation("remotecast_pre")
            inst.AnimState:PushAnimation("remotecast_pre", false)
--[[
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
                inst.AnimState:SetFrame(3)
            end
]]
        end,
        
        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.xl_task then
                inst.xl_task:Cancel()
                inst.xl_task = nil
            end    
            inst:RemoveTag("gyc_xuli")
            --end)
            inst.SoundEmitter:KillSound("make")
            inst.sg:RemoveStateTag("busy")
            --inst:ClearBufferedAction()
        end,       
    }
)

AddStategraphState('wilson_client',
    State{
        name = "gyc_xuli",
        tags = {"doing"}, 

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            inst:PerformPreviewBufferedAction()
            if buffaction ~= nil and buffaction.target ~= nil then
                inst:ForceFacePoint(buffaction.target:GetPosition())
            end

            inst.sg:SetTimeout(4)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("useitem_dir_pre")  --ThePlayer.AnimState:PlayAnimation("remotecast_pre")
            inst.AnimState:PushAnimation("remotecast_pre", false)
            --inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
        end,

        --onexit = function(inst)
            --inst.SoundEmitter:KillSound("make")
            --inst.sg:RemoveStateTag("busy")
            --inst:ClearBufferedAction()
        --end,               
    }
)

--AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.STARTREMOVE, "gyc_xuli"))
--AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.STARTREMOVE, "gyc_xuli")) 

local function NewAtk(sg)
    local old_handler = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
    if inst:HasTag("gyc") and action.invobject and action.invobject.prefab == "gyc_mb3" then 
        print("123")  
        return "gyc_xuli"                             
    else
        return old_handler(inst, action)
    end
    end
end

local function NewAtk_Client(sg)
    local old_handler = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
    if inst:HasTag("gyc") and action.invobject and action.invobject.prefab == "gyc_mb3" then
        return "gyc_xuli"                              
    else
        return old_handler(inst, action)
    end
    end
end

AddStategraphPostInit("wilson", NewAtk)
AddStategraphPostInit("wilson_client", NewAtk_Client) 


local function GYC_XL_ATK(inst, doer, pos, actions, right)
    local isriding = doer and doer.replica.rider and doer.replica.rider:IsRiding()
    if doer and doer:HasTag("gyc") and doer:HasTag("gyc_xuli") and (isriding == nil or not isriding)
    and doer.replica.inventory and doer.replica.inventory:EquipHasTag("gyc_mb3") then
        table.insert(actions, ACTIONS.GYC_XL_ATK)
    end    
end

AddComponentAction('POINT', 'equippable', GYC_XL_ATK)

local function DoAreaAtk(inst)
    if inst.owner == nil then return end

    local self = inst.owner.components.combat
    local damageNum = (40 + (inst.mult * 10))
            * (self.damagemultiplier or 1)
            * self.externaldamagemultipliers:Get()
            * (self.customdamagemultfn ~= nil and self.customdamagemultfn(self.inst, target, inst, multiplier) or 1) 
            + (self.damagebonus or 0)

    local x, y, z = inst.Transform:GetWorldPosition()
    local exclude_tags = {'FX', 'NOCLICK', 'INLIMBO', 'player', 'wall'}
    local ents = TheSim:FindEntities(x, 0, z, 1.5, { "_combat" }, exclude_tags) 
    for k, v in ipairs(ents) do
        if v and v.components.combat and inst.owner.replica.combat:CanTarget(v) and not inst.owner.replica.combat:IsAlly(v) then

           local x, y, z = v.Transform:GetWorldPosition()
           v.components.combat:GetAttacked(inst.owner, damageNum)
        end    
    end
end

local function AddExtraFx(inst, prefabname, offset, pt) 
    local fx = SpawnPrefab(prefabname)
    local pos = inst:GetPosition()
    local angle = inst.Transform:GetRotation()*DEGREES
    local dir = offset.z < 0 and -1 or 1
    local radius = offset.x
    local height = offset.y

    offset = Vector3(math.cos(angle)*radius*dir, height, -math.sin(angle)*radius*dir)

    fx.Transform:SetRotation(inst.Transform:GetRotation())
    fx.Transform:SetPosition((offset+pos):Get())

    local x, y, z = pt:Get()
    fx:FacePoint(x, y, z)

    fx.AnimState:SetScale(1.5, 1.5, 1.5)
    fx.owner = inst
    fx.mult = inst.xl_time
    fx:DoPeriodicTask(0.1, function()
        DoAreaAtk(fx)
        fx.Physics:SetMotorVel(20, 0, 0)
    end)

    fx:DoTaskInTime(0.5+(fx.mult*0.3), function()
        fx:Remove()
    end)      
end

local GYC_XL_ATK = Action({ priority = 30, distance = 30, mount_valid = false })
      GYC_XL_ATK.id = "GYC_XL_ATK"    --这个操作的id  EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
      GYC_XL_ATK.str = "发射" 
      GYC_XL_ATK.fn = function(act) --这个操作执行时进行的功能函数)
            local act_pos = act:GetActionPoint()
            AddExtraFx(act.doer, "houndstooth_proj", Vector3(1.5, 0, 0), act_pos)
            act.doer.components.talker:Say("发射")
            return true --我把具体操作加进sg中了，不再在动作这里执行
      end

AddAction(GYC_XL_ATK)      
AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.GYC_XL_ATK, "quickcastspell"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.GYC_XL_ATK, "quickcastspell"))


AddStategraphPostInit("wilson", function(sg)
    sg.states["moluo_gun_atk"] = State {
        name = "moluo_gun_atk",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },
        onenter = function(inst)
            --print("射击1")
            inst.AnimState:PlayAnimation("hand_shoot")
            inst.AnimState:SetDeltaTimeMultiplier(1.5)

            local weapon = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
            if weapon and weapon:HasTag("krm_gun") then

            end    

            local buffaction = inst:GetBufferedAction()
            if buffaction then   
                local target = buffaction.target or nil
                inst.components.combat:SetTarget(target)
                inst.components.combat:StartAttack()
                inst.sg.statemem.target = target
            end

            inst.components.locomotor:Stop()
        end,
        timeline = {
            TimeEvent(14 * FRAMES, function(inst)
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
                if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
                     inst.SoundEmitter:PlaySound("lw_homura/pistol/silent", nil, 0.3)
                     --inst.components.combat:DoAttack(inst.sg.statemem.target)
                     inst:PerformBufferedAction()
                else
                     inst:ClearBufferedAction()
                     inst.components.talker:Say("没有子弹了。。。") 
                     inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")               
                end     
            end)
        },
        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        }
    }
end)

AddStategraphPostInit("wilson_client", function(sg)
    sg.states["moluo_gun_atk"] = State {
        name = "moluo_gun_atk",
        tags = { "attack", "notalking", "abouttoattack" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hand_shoot")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(14 * FRAMES)
            inst.components.locomotor:Stop()
        end,
        ontimeout = function(inst)
            --inst.sg:GoToState("idle")
        end,
        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat then
                inst.replica.combat:CancelAttack()
            end
        end,
        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        }
    }
end)

AddStategraphPostInit("wilson", function(sg)
    local oldStstate = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if inst:HasTag("bcj") and item and item:HasTag("bcj_gun") 
        and not (inst.components.rider and inst.components.rider:IsRiding()) then
            return "moluo_gun_atk"
        end
        return oldStstate(inst, action)
    end
end)
AddStategraphPostInit("wilson_client", function(sg)
    local oldStstate = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local item = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if inst:HasTag("bcj") and item and item:HasTag("bcj_gun") 
        and not (inst.replica.rider and inst.replica.rider:IsRiding()) then    
            return "moluo_gun_atk"
        end
        return oldStstate(inst, action)
    end
end)

local function nohitsg(sg)
    local old_yawn = sg.events['yawn'].fn
    sg.events['yawn'] = EventHandler('yawn', function(inst, data, ...)
        if inst:HasTag("bcj") then
            return
        end
        old_yawn(inst, data, ...)
    end)
end

AddStategraphPostInit("wilson", nohitsg)

local function AddPlayerSgPostInit(fn)
    AddStategraphPostInit('wilson', fn)
    AddStategraphPostInit('wilson_client', fn)
end

AddPlayerSgPostInit(function(self)
    local sitting = self.states.sitting 
    if sitting then
        local old_enter = sitting.onenter
        function sitting.onenter(inst, data, ...)
            if old_enter then 
                old_enter(inst, data, ...)
            end
            if data and data.chair and data.chair.prefab == "bcj_jianzhu3" then
                local wp = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if wp then 
                    inst.components.inventory:GiveItem(inst.components.inventory:Unequip(EQUIPSLOTS.HANDS))
                    inst.unequip_sit_task = inst:DoTaskInTime(0, function(inst)
                        inst.AnimState:SetBankAndPlayAnimation("wilson", "wahaha", true)
                        if inst.unequip_sit_task then
                            inst.unequip_sit_task:Cancel()
                            inst.unequip_sit_task = nil
                        end
                    end)   
                end
                data.chair:Hide()    
                inst.AnimState:SetBankAndPlayAnimation("wilson", "wahaha", true)
            end
        end       
    end
end)

AddPlayerPostInit(function(inst)  --ThePlayer.AnimState:AddOverrideBuild("wahaha")
   inst.AnimState:AddOverrideBuild("daofeng_actions_pistol")
   inst.AnimState:OverrideSymbol("wahaha", "wahah", "wahaha") 
   inst.AnimState:OverrideSymbol("chair", "wahah", "chair") 
end)

local extra_speed_mult = 1.5

AddPlayerPostInit(function(player)
    local doer = player
    local orangeperiod
    local function isAttackingSG(inst, statename)
        return statename == "attack" or inst.sg and inst.sg:HasStateTag("attack")
            and inst.sg:HasStateTag("abouttoattack")
    end
    doer:ListenForEvent("newstate", function(inst, data)
        if doer.prefab == "bcj" and doer.replica.inventory and doer.replica.inventory:EquipHasTag("bcj_sword") then
        if not inst.sg then return end
        local statename = data and data.statename
        if inst.mmdx_remove_sgtag_task then
            inst.mmdx_remove_sgtag_task:Cancel()
            inst.AnimState:SetDeltaTimeMultiplier(1)
            if orangeperiod then
                local combat = inst.components.combat or inst.replica.combat
                combat.min_attack_period = orangeperiod
            end
        end
        if isAttackingSG(inst, statename) then
            local timeout = inst.sg.timeout
            local combat = inst.components.combat or inst.replica.combat
            orangeperiod = orangeperiod or combat.min_attack_period or TUNING.WILSON_ATTACK_PERIOD

            local orange_attackspeed = 1 / timeout -- 2.5
            local new_attackspeed = orange_attackspeed * extra_speed_mult
            local newperiod = 1 / new_attackspeed
            combat.min_attack_period = newperiod
            inst.AnimState:SetDeltaTimeMultiplier(math.min(2.5, (new_attackspeed / orange_attackspeed)))
            inst.mmdx_remove_sgtag_task = inst:DoTaskInTime(newperiod,
                function()
                    inst.sg:RemoveStateTag("attack")
                    inst.sg:AddStateTag("idle")
                    if TheWorld.ismastersim then
                        inst:PerformBufferedAction()
                    end
                    inst.sg:RemoveStateTag("abouttoattack")
                end)
            end
        end
    end)
end)
