local ex_fns = require "prefabs/player_common_extensions"

local FlyConfig = {
    configs = {},

    AddData = function(self, data)
        -- id链接
        table.insert(self.configs, data)
        data.id = #self.configs
        -- 缺省值
        data.owner_prefab = data.owner_prefab
        data.height = data.height or 2
        data.shadow_size = data.shadow_size or {3.6, 2}
        data.speed = data.speed or 5
        self.configs[data.owner_prefab] = data
    end,

    GetDataById = function(self, id)
        return self.configs[id]
    end,

    GetDataByPrefab = function(self, pf)
        return self.configs[pf] or self.configs["common"]
    end,
}
 
FlyConfig:AddData{
    owner_prefab = "common",
    height = 0,    
    speed = 12/6,
    build = "yuki_cloudfx",
}

-- 尾巴默认和主体一致
for i,v in ipairs(FlyConfig.configs)do
    if v.tail then
        v.tail.build = v.tail.build or v.build
    end
end

local function DefaultEmitPosFn(rot) -- 默认的圆环发散器
    local offsangle = math.random() * 2 * PI
    local offsradius = math.random() * .2
    return math.cos(offsangle) * offsradius, math.sin(offsangle) * offsradius
end

local Tail = Class(function(self)
    self.enabled = true
    self.tails = {}
    self.config = {}

    self.Emit = function(self)
        local tail = SpawnPrefab(self.config.prefab or "yuki_flyerfx_cloud_tail") --default 
        tail:config(self.config)
        tail:init() -- 大小/动画/透明度均已在prefab内部实现, 这里只需要控制速度
        self.tails[tail] = true
        return tail
    end

    self.GetEmitOffset = function(self, ...)
        if self.config.pos_fn then
            return self.config.pos_fn(...)
        else
            return DefaultEmitPosFn(...)
        end
    end
end)


local IsFlying = function(inst) return inst and inst.components.yuki_flyer and inst.components.yuki_flyer:IsFlying()end
local banactions ={
    --[[
    [ACTIONS.PICKUP]= true, --拾取
    [ACTIONS.PICK]= true, --采集
    [ACTIONS.SLEEPIN]= true, --睡觉
    [ACTIONS.MOUNT]= true,--骑牛
    [ACTIONS.MIGRATE]= true,
    [ACTIONS.HAUNT]= true,
    [ACTIONS.JUMPIN]= true,
    [ACTIONS.ATTACK]= true, 
    ]]
    [ACTIONS.LOOKAT]= true,  
    [ACTIONS.TALKTO]= true,  
    [ACTIONS.WALKTO]= true,  
    [ACTIONS.YKFLYLAND]= true,            
}

local bansgs = {
    abandon_ship = true,
    exittownportal = true,
    combat_leap = true,
    combat_superjump_pst = true,
    portal_jumpout = true,
    nzcombat_superjump_pst = true,
}
local function changephysics(inst, data)
    if inst.oldbansg ~= nil then 
        if inst.Physics then
            RemovePhysicsColliders(inst)
        end
        inst.oldbansg = nil
    end
    
    if data and bansgs[data.statename] then
        inst.oldbansg = data.statename
    end
end

local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable", "mineactive", "intense" }
local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
    table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
    table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
end
local CATCHABLE_TAGS = { "catchable" }
local PINNED_TAGS = { "pinned" }
local CORPSE_TAGS = { "corpse" }
local function ValidateCorpseReviver(target, inst)
    return target.components.revivablecorpse:CanBeRevivedBy(inst)
end
local function ValidateBugNet(target)
    return not target.replica.health:IsDead()
end
local function GetPickupAction(self, target, tool)
    if target:HasTag("smolder") then
        return ACTIONS.SMOTHER
    elseif tool ~= nil then
        for k, v in pairs(TOOLACTIONS) do
            if target:HasTag(k.."_workable") then
                if tool:HasTag(k.."_tool") then
                    return ACTIONS[k]
                end
                break
            end
        end
    end
    if target:HasTag("quagmireharvestabletree") and not target:HasTag("fire") then
        return ACTIONS.HARVEST_TREE
    elseif target:HasTag("trapsprung") then
        return ACTIONS.CHECKTRAP
    elseif target:HasTag("minesprung") and not target:HasTag("mine_not_reusable") then
        return ACTIONS.RESETMINE
    elseif target:HasTag("inactive") then
        return (not target:HasTag("wall") or self.inst:IsNear(target, 2.5)) and ACTIONS.ACTIVATE or nil

    elseif tool ~= nil and tool:HasTag("unsaddler") and target:HasTag("saddled") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.UNSADDLE
    elseif tool ~= nil and tool:HasTag("brush") and target:HasTag("brushable") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.BRUSH
    elseif self.inst.components.revivablecorpse ~= nil and target:HasTag("corpse") and ValidateCorpseReviver(target, self.inst) then
        return ACTIONS.REVIVE_CORPSE
    end
end

local function ActionButton(inst, force_target)
    local self = inst.components.playercontroller
    if not self:IsDoingOrWorking() then
        local force_target_distsq = force_target ~= nil and self.inst:GetDistanceSqToInst(force_target) or nil
        
        if self.inst:HasTag("playerghost") then
            return
        end

        local tool = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        --捕虫网
        if tool ~= nil and tool:HasTag(ACTIONS.NET.id.."_tool") then
            if force_target == nil then
                local target = FindEntity(self.inst, 5, ValidateBugNet, { "_health", ACTIONS.NET.id.."_workable" }, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.NET, tool)
                end
            elseif force_target_distsq <= 25 and
                force_target.replica.health ~= nil and
                ValidateBugNet(force_target) and
                force_target:HasTag(ACTIONS.NET.id.."_workable") then
                return BufferedAction(self.inst, force_target, ACTIONS.NET, tool)
            end
        end

        --接东西
        if self.inst:HasTag("cancatch") then
            if force_target == nil then
                local target = FindEntity(self.inst, 10, nil, CATCHABLE_TAGS, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.CATCH)
                end
            elseif force_target_distsq <= 100 and
                force_target:HasTag("catchable") then
                return BufferedAction(self.inst, force_target, ACTIONS.CATCH)
            end
        end

        --unstick
        if force_target == nil then
            local target = FindEntity(self.inst, self.directwalking and 3 or 6, nil, PINNED_TAGS, TARGET_EXCLUDE_TAGS)
            if CanEntitySeeTarget(self.inst, target) then
                return BufferedAction(self.inst, target, ACTIONS.UNPIN)
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) and
            force_target:HasTag("pinned") then
            return BufferedAction(self.inst, force_target, ACTIONS.UNPIN)
        end

        --revive (only need to do this if i am also revivable)
        if self.inst.components.revivablecorpse ~= nil then
            if force_target == nil then
                local target = FindEntity(self.inst, 3, ValidateCorpseReviver, CORPSE_TAGS, TARGET_EXCLUDE_TAGS)
                if CanEntitySeeTarget(self.inst, target) then
                    return BufferedAction(self.inst, target, ACTIONS.REVIVE_CORPSE)
                end
            elseif force_target_distsq <= 9
                and force_target:HasTag("corpse")
                and ValidateCorpseReviver(force_target, self.inst) then
                return BufferedAction(self.inst, force_target, ACTIONS.REVIVE_CORPSE)
            end
        end

        --misc: pickup, tool work, smother
        if force_target == nil then
            local pickup_tags =
            {
                "smolder",
                "saddled",
                "brushable",
            }
            if tool ~= nil then
                for k, v in pairs(TOOLACTIONS) do
                    if tool:HasTag(k.."_tool") then
                        table.insert(pickup_tags, k.."_workable")
                    end
                end
            end
            if self.inst.components.revivablecorpse ~= nil then
                table.insert(pickup_tags, "corpse")
            end
            local x, y, z = self.inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, self.directwalking and 3 or 6, nil, PICKUP_TARGET_EXCLUDE_TAGS, pickup_tags)
            for i, v in ipairs(ents) do
                if v ~= self.inst and v.entity:IsVisible() and CanEntitySeeTarget(self.inst, v) then
                    local action = GetPickupAction(self, v, tool)
                    if action ~= nil then
                        return BufferedAction(self.inst, v, action, action ~= ACTIONS.SMOTHER and tool or nil)
                    end
                end
            end
        elseif force_target_distsq <= (self.directwalking and 9 or 36) then
            local action = GetPickupAction(self, force_target, tool)
            if action ~= nil then
                return BufferedAction(self.inst, force_target, action, action ~= ACTIONS.SMOTHER and tool or nil)
            end
        end
    end
end

local function FlyActionFilter(inst, action)
    --if inst.prefab == "white_bone" then
        --banactions[ACTIONS.ATTACK] = false
    --end
    return banactions[action]
end

--------------------================================================
local Flyer = Class(function(self, inst)
    self.inst = inst
    self.fx = nil
    self.tail = Tail()
    self.extra_fx_task = nil -- 目前只有杨戬用得上
    
    self._yuki_isflying = net_bool(inst.GUID, "yuki_flyer._isflying", "yuki_flyer._isflying")
    self._yuki_isflying:set(false)

    self._yukipercent = net_float(inst.GUID, "yuki_flyer._percent")
    self._yukipercent:set(0)

    
    inst:ListenForEvent("yuki_flyer._isflying", function()
        local p = self._yuki_isflying:value()
        if not TheWorld.ismastersim then
            if p ~= (self.fx and self.fx:IsValid()) then
                self:SetFlying(p, TheSim:GetTick() <= 1+4) -- 5帧内的起飞视为读档
            end 
        end
    end)
    
    self.height_target = 0
    -- self.percent = 0
    -- self.isfloat = false
end)

local function OnBlocked(owner, data)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
end

function Flyer:GetPercent()
    return self._yukipercent:value()
end

function Flyer:UpdateHeight() -- 锁定玩家y高度, 仅主机和预估客机生效
    if self.inst.components.locomotor then 
        self.inst.components.locomotor.mythVar_height_override = self:GetFlyTargetHeight()
        local inst = self.inst
        local a,b,c = inst.Physics:GetMotorVel()
        local y = inst:GetPosition().y
        inst.Physics:SetMotorVel(a, (self.height_target - y)*32, c)
    else
        self:GetFlyTargetHeight()
    end
end

function Flyer:UpdatePlayerTween() -- 玩家透明度
    if TheNet:IsDedicated() or not self.inst.entity:IsVisible() then
        return
    end
    if self.current_data and self.current_data.is_invisible then
        local a = 1 - self:GetPercent()
        self.inst.AnimState:SetMultColour(a,a,a,a)
    end
end

function Flyer:UpdateTail()
    if TheNet:IsDedicated() or not self.inst.entity:IsVisible() then
        return
    end
    if not self.tail.enabled then
        return
    end
    local x,y,z = self.inst.Transform:GetWorldPosition()
    for k in pairs(self.tail.tails)do
        if k:IsAsleep() then
            k:Remove()
        end
        if k:IsValid() then
            k:ForceFacePoint(x,0,z)
        else
            self.tail.tails[k] = nil
        end
    end
    if not self.last_x then 
        self.last_x = x
        self.last_z = z
    else
        local distsq = (x-self.last_x)*(x-self.last_x) + (z-self.last_z)*(z-self.last_z)
        self.last_x = x 
        self.last_z = z
        if distsq > 0.01 then 
            for i = 1, self.tail.config.num or 1 do
                local tail = self.tail:Emit()
                local xoff, zoff = self.tail:GetEmitOffset(self.inst.Transform:GetRotation())
                tail:setheight(self.height_target)
                tail.Transform:SetPosition(x+xoff, 0, z+zoff)
                tail.Physics:SetMotorVel(.6 + math.random() * .4, 0, 0)
            end
        end
    end
end

function Flyer:OnUpdate(dt) -- 主客机通用
    if self.fx and self.fx:IsValid()then
        self:UpdateHeight()
        self:UpdatePlayerTween()
        self:UpdateTail()
    else
        self.fx = nil
        self.inst:StopUpdatingComponent(self)
    end
end

function Flyer:SetFlying(val, onload) 
    local inst = self.inst
    local data = FlyConfig:GetDataByPrefab(inst.prefab)
    self.current_data = data

    if TheWorld.ismastersim then
        self._yuki_isflying:set(val)
    else
        self._yuki_isflying:set_local(val)
    end

    if val then
        self.tail.enabled = true
        self.inst:StartUpdatingComponent(self)
        if onload then
            self._yukipercent:set_local(1) -- 不进行过渡
        end
        
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = ActionButton
        end     
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker:PushActionFilter(FlyActionFilter, 555)
        end
        if data.ridefn then
            data.ridefn(self, self.inst, true)
        end
        inst:ListenForEvent("newstate", changephysics)
        if data.is_invisible then -- 隐身
            inst:AddTag("NOHIGHLIGHT")
            inst:AddTag("NOTARGET")
            inst:AddTag("INVISIBLE")
        end
        if inst.Physics then
            RemovePhysicsColliders(inst)
        end
        if inst.components.locomotor then
            ex_fns.ConfigureGhostLocomotor(inst)
            inst.components.locomotor:SetExternalSpeedMultiplier(self, "myth_flyer.speed", data.speed)
            if inst.components.locomotor.pathcaps then
                inst.components.locomotor.pathcaps.allowocean = true
            end
        end
        if inst.components.drownable then
            inst.components.drownable.enabled = false
        end
        self:SpawnFx()
        -- For tail
        if data.tail then
            self.tail.enabled = true
            self.tail.config = data.tail
        end
        -- For extra fx 
        if data.extra_fx then
            self:SpawnExtraFx(data.extra_fx)
        end
    else
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end     
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker:PopActionFilter(FlyActionFilter)
        end
        if data.ridefn then
            data.ridefn(self, self.inst, false)
        end
        inst:RemoveEventCallback("newstate", changephysics)
        if data.is_invisible then
            inst:RemoveTag("NOHIGHLIGHT")
            inst:RemoveTag("NOTARGET")
            inst:RemoveTag("INVISIBLE")
        end
        if inst.Physics then
            ChangeToCharacterPhysics(inst)
        end
        if inst.components.locomotor then
            ex_fns.ConfigurePlayerLocomotor(inst)
            inst.components.locomotor:RemoveExternalSpeedMultiplier(self, "myth_flyer.speed")
        end
        if inst.components.drownable then
            inst.components.drownable.enabled = true
        end
        self:DespawnFx()
        self:DespawnExtraFx()
        self.tail.enabled = false
    end
end

function Flyer:IsFlying()
    return self._yuki_isflying:value()
end

function Flyer:SpawnFx()
    self:DespawnFx()
    local data = self.current_data
    if data.fx == nil then 
        local fx = SpawnPrefab('yuki_flyerfx_cloud')
        fx:config(data)
        fx:init()
        self.inst:AddChild(fx)
        self.fx = fx
    else                    -- 使用定制特效
        self.fx = self.inst:SpawnChild(data.fx.prefab)
    end
end

function Flyer:DespawnFx()
    if self.fx and self.fx:IsValid() then
        self.fx:Despawn()
    end
end

function Flyer:SpawnExtraFx(data)
    if self.extra_fx_task then
        self.extra_fx_task:Cancel()
    end
    self.extra_fx_task_fn = function()
        if self.fx and self.fx:IsValid() then
            local ent = self.fx:SpawnChild(data.prefab)
            if data.offset then
                ent.Transform:SetPosition(data.offset:Get())
            end
        end
        self.extra_fx_task = self.inst:DoTaskInTime(data.interval(), self.extra_fx_task_fn)
    end

    self.extra_fx_task_fn()
end

function Flyer:DespawnExtraFx()
    if self.extra_fx_task then
        self.extra_fx_task:Cancel()
    end
    self.extra_fx_task_fn = function() end
end

function Flyer:GetFlyTargetHeight() -- 主客机通用: 获取飞行高度
    if not self.current_data then
        return 0
    end
    self.height_target = self.current_data.height * self:GetPercent()
    return self.height_target
end


function Flyer:OnRemoveEntity()
    self:DespawnFx()
    self:DespawnExtraFx()
end

function Flyer:OnSave()
    return {isflying = self:IsFlying()}
end

function Flyer:OnLoad(data)
    if data.isflying then
        self:SetFlying(true, true)
    end
end
Flyer.OnRemoveFromEntity = Flyer.OnRemoveEntity

return Flyer