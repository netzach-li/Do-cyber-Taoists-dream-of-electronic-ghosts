GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
       
local function OnHitOther(inst, data)
    if data.target ~= nil and data.target.components.combat and inst.bcj_fu4_task then
        local x, y, z = data.target.Transform:GetWorldPosition()
        local lightning1 = SpawnPrefab("lightning")
        lightning1.Transform:SetPosition(x, y - .1, z)
        lightning1.AnimState:SetMultColour(1, 1, 0, 1)      
    end
end

local function GetAbiMois(inst)
    local val = 0

    if val == 0 then
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4, { "waterproofer", "bcj_san3" }) 
    for k, v in ipairs(ents) do
        if val == 0 and v.components.equippable:IsEquipped()
        and v.components.inventoryitem.owner and v.components.inventoryitem.owner.prefab == "bcj" then
            val = v.components.waterproofer:GetEffectiveness()
        end    
    end
    end

    --print("防水")

    return val
end

local function GetSanTemp(inst)
    local val1, val2 = 0, 0
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4, { "bcj" }) 
    for k, v in ipairs(ents) do
        if val1 == 0 and val2 == 0 and v ~= inst and v.components.inventory:EquipHasTag("bcj_san3") then
            val1, val2 = v.components.temperature:GetInsulation()
        end    
    end

    --print("a = "..val1)
    --print("b = "..val2) 

    return val1, val2
end


AddPlayerPostInit(function(inst) 
    if not TheWorld.ismastersim then
        return inst  --ThePlayer.components.temperature:SetTemperature()
    end     

    local OldSetTemperature = inst.components.temperature.SetTemperature
    inst.components.temperature.SetTemperature = function(self, value, ...)
        if (inst.bcj_food2_task ~= nil and value < 30) or inst.bcj_fu1_task then
            value = 30
        end 
        return OldSetTemperature(self, value, ...) 
    end

    local OldGetInsulation = inst.components.temperature.GetInsulation
    inst.components.temperature.GetInsulation = function(self, ...)
        local a, b = OldGetInsulation(self)
        if (a == 0 or b == 0) and (TheWorld.state.issummer or TheWorld.state.iswinter) and GetSanTemp(inst) then
            a, b = GetSanTemp(inst)
        end

        return a, b 
    end

    local _getAttacked = inst.components.combat.GetAttacked
    inst.components.combat.GetAttacked = function(self, attacker, damage, weapon, stimuli, spdamage, ...) 
        if inst.components.inventory:EquipHasTag("bcj_fu2") then
            damage = damage * 0.2
        end 
        return _getAttacked(self, attacker, damage, weapon, stimuli, spdamage, ...) 
    end

    local OldIsSane = inst.components.sanity.IsSane  --print(ThePlayer.components.sanity:IsSane())
    inst.components.sanity.IsSane = function(self, ...) 
        if inst.components.inventory:EquipHasTag("bcj_item2") then
            return false
        end 
        return OldIsSane(self, ...) 
    end

    local OldIsInsane = inst.components.sanity.IsInsane  --print(ThePlayer.components.sanity:IsSane())
    inst.components.sanity.IsInsane = function(self, ...) 
        if inst.components.inventory:EquipHasTag("bcj_item2") then
            return false
        end 
        return OldIsInsane(self, ...) 
    end

    local OldIsEnlightened = inst.components.sanity.IsEnlightened  --print(ThePlayer.components.sanity:IsEnlightened())
    inst.components.sanity.IsEnlightened = function(self, ...) 
        if inst.components.inventory:EquipHasTag("bcj_item2") then
            return false
        end 
        return OldIsEnlightened(self, ...) 
    end    

    local OldGetWaterproofness = inst.components.inventory.GetWaterproofness  --print(ThePlayer.components.inventory:GetWaterproofness())
    inst.components.inventory.GetWaterproofness = function(self, slot) 
        local GetFangShui = OldGetWaterproofness(self, slot)
        if GetAbiMois(inst) > 0 then
            GetFangShui = GetFangShui + GetAbiMois(inst)
        end

        if GetFangShui > 1 then
            GetFangShui = 1
        end    
       
        return GetFangShui
    end

    inst:ListenForEvent("onhitother", OnHitOther)     
end)

AddPrefabPostInitAny(function(inst)
    if not inst:HasTag("shadow_item") and not inst:HasTag("shadowlevel") then 
        return
    end

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.equippable and inst.components.equippable.dapperness and inst.components.equippable.dapperness < 0 then
    inst.dapperness = 0

    local OldEquip = inst.components.equippable.Equip
    inst.components.equippable.Equip = function(self, owner, from_ground, ...)
        if owner and owner.prefab == "bcj" then
        inst.dapperness = self.dapperness
        inst.components.equippable.dapperness = 0
        end
        return OldEquip(self, owner, from_ground, ...) 
    end

    local OldUnequip = inst.components.equippable.Unequip
    inst.components.equippable.Unequip = function(self, owner, ...)
        if owner and owner.prefab == "bcj" then
        inst.components.equippable.dapperness = inst.dapperness or 0
        end
        return OldUnequip(self, owner, ...) 
    end    
    end     
end) 

AddPrefabPostInit("cookpot", function(inst)
    if not TheWorld.ismastersim then
        return
    end
	
    if inst.components.stewer then  --
        local old_oncook = inst.components.stewer.StartCooking
        inst.components.stewer.StartCooking = function(self, chef)
            if old_oncook then
                old_oncook(self, chef)
            end
            if chef and chef.prefab == "bcj" and math.random() > 0.5 then
                self.product = nil
                self.product = "bcj_food5"
            end
        end
    end
end)

AddComponentPostInit("locomotor", function(self)
    self.mythVar_height_override = 0

    local oldRunForward = self.RunForward 
    function self:RunForward(direct, ...)
        oldRunForward(self, direct, ...)
        if self.mythVar_height_override ~= 0 then
            local a, b, c = self.inst.Physics:GetMotorVel()
            local y = self.inst:GetPosition().y
            local h = self.inst.components.yuki_flyer and self.inst.components.yuki_flyer:GetFlyTargetHeight() 
            if y and h then
                self.inst.Physics:SetMotorVel(a, (h - y) * 32, c)
            end
        end
    end
--[[
    local oldStop = self.Stop 
    function self:Stop(sgparams, ...)
        oldStop(self, sgparams, ...)
        if self.mythVar_height_override ~= 0 then
            local a, b, c = self.inst.Physics:GetMotorVel()
            local y = self.inst:GetPosition().y
            local h = self.inst.components.yuki_flyer and self.inst.components.yuki_flyer:GetFlyTargetHeight() 
            if y and h then
                self.inst.Physics:SetMotorVel(a, (h - y) * 32, c)
            end
        end
    end
]]
    local oldGetRunSpeed = self.GetRunSpeed
    function self:GetRunSpeed(...)
        if self.inst.components.yuki_flyer ~= nil and self.inst.components.yuki_flyer:IsFlying() then
            if self.inst.prefab == "gyc" then
                return 10
            end
        end
        return oldGetRunSpeed(self, ...)
    end
end)

local function GYC_FLY(inst)
    if inst.sg and inst.components.llmy_power.current >= 25 then
        inst.sg:GoToState("gyc_flyskill_up")
        inst.components.yuki_flyer:SetFlying(true) 
        inst.components.llmy_power:DoDelta(-20)      
    end
end

AddModRPCHandler(modname, "GYC_FLY", GYC_FLY)

TheInput:AddKeyDownHandler(KEY_Z, function()
   local player = ThePlayer
   local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
   local IsHUDActive = screen and screen.name == "HUD"
    if player.prefab == "gyc" and player:HasTag("can_fly")
    and player._llmy_powercurrent:value() and player._llmy_powercurrent:value() >= 25 then
        if player.sg then
        player.sg:GoToState("gyc_flyskill_up")
        end 
        SendModRPCToServer(MOD_RPC[modname]["GYC_FLY"])
    end 
end)

local function GYC_FLY(inst)
    if inst.sg and inst.components.llmy_power.current >= 25 then
        inst.sg:GoToState("gyc_flyskill_up")
        inst.components.yuki_flyer:SetFlying(true) 
        inst.components.llmy_power:DoDelta(-20)      
    end
end

AddModRPCHandler(modname, "GYC_FLY", GYC_FLY)

local function GYC_GOD(inst)
    if inst.level2 < 5 then
        inst.components.talker:Say("技能未解锁！")
        return
    end    
    if inst.components.llmy_power.current >= 100 then
    inst:TransGod(true)
    end
end

AddModRPCHandler(modname, "GYC_GOD", GYC_GOD)

TheInput:AddKeyDownHandler(KEY_X, function()
   local player = ThePlayer
   local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
   local IsHUDActive = screen and screen.name == "HUD"
    if player.prefab == "gyc" and player._llmy_powercurrent:value() and player._llmy_powercurrent:value() >= 100 then
        SendModRPCToServer(MOD_RPC[modname]["GYC_GOD"])
    end 
end)

AddComponentPostInit("locomotor", function(self)
    local _OldPushAction = self.PushAction
        function self:PushAction(bufferedaction, run, try_instant, ...)
        if self.inst.prefab ~= "bcj" and bufferedaction and bufferedaction.target and bufferedaction.target.prefab == "bcj_table"
        and bufferedaction.action and bufferedaction.action == ACTIONS.SLEEPIN then
            return
        else 
            return _OldPushAction(self, bufferedaction, run, try_instant, ...)            
        end
    end
    
    local _OldPreviewAction = self.PreviewAction
    function self:PreviewAction(bufferedaction, run, try_instant, ...)
        if self.inst.prefab ~= "bcj" and bufferedaction and bufferedaction.target and bufferedaction.target.prefab == "bcj_table"
        and bufferedaction.action and bufferedaction.action == ACTIONS.SLEEPIN then
            return
        else
            return _OldPreviewAction(self, bufferedaction, run, try_instant, ...)  
        end  
    end
end)


local function HookComponent(name, fn)
    fn(require ("components/"..name))
end

local containers = require "containers"
local params = containers.params

params.bcj_jianzhu1 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "bcj_jianzhu1_ui",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 4, 0, -1 do
    for x = 0, 4 do
        table.insert(params.bcj_jianzhu1.widget.slotpos, Vector3(80 * x - 80 * 2+8, 80 * y - 80 * 2-10, 0))
    end
end

params.bcj_gun = {
    widget =
    {
        slotpos =
        {
            Vector3(0,   32 + 4,  0),
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0),
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
    excludefromcrafting = true,
}

function params.bcj_gun.itemtestfn(container, item, slot)
    return item.prefab and item.prefab == "bcj_ghost_soul"
end

params.bcj_444_1 = {
    widget =
    {
        slotpos =
        {
            Vector3(0,   32 + 4,  0),
            Vector3(0, -(32 + 4), 0),
        },
        animbank = "ui_chest_3x3",
        animbuild = "bcj_444_2x2",
        pos = Vector3(-130, -80, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

params.bcj_444_2 = {
    widget =
    {
        slotpos =
        {
            Vector3(-37.5, 32 + 4 + 17, 0),
            Vector3(37.5, 32 + 4 + 17, 0),
            Vector3(-37.5, -60 + 17, 0),
            Vector3(37.5, -60 + 17, 0),
        },
        animbank = "ui_chest_3x3",
        animbuild = "bcj_444_2x2",
        pos = Vector3(-130, -80, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

params.bcj_444_3 = {
    widget =
    {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "bcj_444_2x4",
        pos = Vector3(-130, -80, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 3 do
    table.insert(params.bcj_444_3.widget.slotpos, Vector3(-40, -75 * y + 114, 0))
    table.insert(params.bcj_444_3.widget.slotpos, Vector3(-40 + 75, -75 * y + 114, 0))
end

params.bcj_444_4 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "bcj_444_2x6",
        pos = Vector3(-50, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 5 do
    table.insert(params.bcj_444_4.widget.slotpos, Vector3(-162, -75 * y + 180, 0))
    table.insert(params.bcj_444_4.widget.slotpos, Vector3(-162 + 75, -75 * y + 180, 0))
end

params.bcj_444_5 =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_piggyback_2x6",
        animbuild = "bcj_444_2x8",
        pos = Vector3(-50, -90, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 7 do
    table.insert(params.bcj_444_5.widget.slotpos, Vector3(-162, -75 * y + 265, 0))
    table.insert(params.bcj_444_5.widget.slotpos, Vector3(-162 + 75, -75 * y + 265, 0))
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS,
                                       v.widget.slotpos ~= nil and
                                           #v.widget.slotpos or 0)
end


local llmy_ui2 = require("widgets/llmy_power_ui")

local function AddLlmy_Ui(self) 
  if self.owner and self.owner.prefab == "gyc" then   
      self.llmy_ui2 = self:AddChild(llmy_ui2(self.owner))  
      self.owner:DoTaskInTime(0.5, function()
      local x1 ,y1, z1 = self.stomach:GetPosition():Get()
      local x2 ,y2, z2 = self.brain:GetPosition():Get()   
      local x3 ,y3, z3 = self.heart:GetPosition():Get()   
      if y2 == y1 or y2 == y3 then
          self.llmy_ui2:SetPosition(self.stomach:GetPosition() + Vector3(x1-x2, 0, 0))
          self.boatmeter:SetPosition(self.moisturemeter:GetPosition() + Vector3(x1-x2, -100, 0))
      else
          self.llmy_ui2:SetPosition(self.stomach:GetPosition() + Vector3(x1-x3, 0, 0))
      end

         local s1 = self.stomach:GetScale().x
         local s2 = self.boatmeter:GetScale().x    
         local s3 = self.llmy_ui2:GetScale().x  
  
         if s1 ~= s2 then
            self.boatmeter:SetScale(s1/s2,s1/s2,s1/s2)  
         end

         if s1 ~= s3 then
            self.llmy_ui2:SetScale(s1/s3,s1/s3,s1/s3)
         end
      end)
   end
end

AddClassPostConstruct("widgets/statusdisplays", AddLlmy_Ui)


local Leafcanopy = require "widgets/leafcanopy_lhs"

AddClassPostConstruct("screens/playerhud", function(self)
    local Old_CreateOverlays = self.CreateOverlays
    function self:CreateOverlays(owner)
        Old_CreateOverlays(self, owner)
        self.lhs_leafcanopy = self.overlayroot:AddChild(Leafcanopy(owner))       
    end

    local Old_OnUpdate = self.OnUpdate
    function self:OnUpdate(dt)
        Old_OnUpdate(self, dt)
        --self.leafcanopy:Hide()
        if self.lhs_leafcanopy then
            self.lhs_leafcanopy:OnUpdate(dt)
        end                
    end   
end)