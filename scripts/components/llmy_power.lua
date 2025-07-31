local function onmax(self, max)  
    self.inst._llmy_powermax:set(max)  
end

local function oncurrent(self, current)   
    self.inst._llmy_powercurrent:set(current)
end

local function onratescale(self, ratescale)
    self.inst._llmy_powerratescale:set(ratescale) 
end

local IsFlying = function(inst) return inst and inst.components.yuki_flyer and inst.components.yuki_flyer:IsFlying() end

local function DoDel(inst)
    local self = inst.components.llmy_power or nil
    if self and self:GetRate() ~= 0 and not self.inst:HasTag("playerghost") then 
        self:DoDelta(self:GetRate()) 
    end    
end

local Llmy_Power = Class(function(self, inst)
    self.inst = inst
    self.max = 10
    self.current = 0

    self.ratescale = 0	   
	self.inst:StartUpdatingComponent(self)

    self.inst:DoPeriodicTask(1, DoDel)
end,
nil,
{
    max = onmax,
    current = oncurrent,
    ratescale = onratescale,
})
--

function Llmy_Power:OnSave()
    return
    {
        current = self.current,
        max = self.max,
    }
end

function Llmy_Power:OnLoad(data)
    if data.current ~= nil then
        self.current = data.current
    end

    if data.max ~= nil then
        self.max = data.max
    end
 
	self:DoDelta(0)
end

function Llmy_Power:SetMax(amount)
     self.max = amount
     self.current = amount        
end

function Llmy_Power:DoDelta(delta, overtime) 
	self._oldpercent = self:GetPercent()
    self.current = math.clamp(self.current + delta, 0, self.max)      
    self.inst:PushEvent("Llmy_Power_delta", { oldpercent = self._oldpercent, newpercent = self:GetPercent(), overtime = overtime })
end

function Llmy_Power:GetPercent()
    return self.current / self.max
end

function Llmy_Power:SetPercent(per, overtime) 
    local target = per * self.max
    local delta = target - self.current
    self:DoDelta(delta, overtime)
end

function Llmy_Power:OnUpdate(dt)
    if not self.inst:HasTag("playerghost") then
        self:Recalc(dt)
    end
end    

function Llmy_Power:GetRate()
    local rate = 0.5

    if self.inst.sg and self.inst.sg.statemem
    and self.inst.sg.statemem.chair
    and self.inst.sg.statemem.chair.prefab == "bcj_jianzhu8" then
        --local del = self.inst.components.inventory:EquipHasTag("gyc_power_hat") and 2 or 1
        rate = rate + 1
    end

    if self.inst.components.inventory:EquipHasTag("gyc_power_hat") then
        rate = rate * 2
    end    

    if IsFlying(self.inst) then
        rate = rate - 1
    end

    if self.inst.god == true then
        rate = rate - 20       
    end    
    return rate    
end

function Llmy_Power:Recalc(dt)
    self.ratescale = (self:GetRate() < 0 and RATE_SCALE.DECREASE_HIGH)
    or (self:GetPercent() < 1 and self:GetRate() > 0 and RATE_SCALE.INCREASE_HIGH)
    or RATE_SCALE.NEUTRAL  
end

return Llmy_Power

