local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local Llmy_Power_Ui = Class(Badge, function(self, owner) 
	Badge._ctor(self, "llmy_ui", owner)

	self.anim:GetAnimState():SetBank("health")  

    self.llmy_power = self.underNumber:AddChild(UIAnim())
    self.llmy_power:GetAnimState():SetBank("sanity_arrow")
    self.llmy_power:GetAnimState():SetBuild("sanity_arrow")
    self.llmy_power:GetAnimState():PlayAnimation("neutral")	
	self.llmy_power:SetClickable(false)
  	
	self:StartUpdating()
end)

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function Llmy_Power_Ui:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    local max = self.owner._llmy_powermax:value() or 10
    local newpercent = self.owner._llmy_powercurrent:value()/max or 1
    self:SetPercent(newpercent, max)

    local anim = "neutral"
    local ratescale = self.owner._llmy_powerratescale:value()
    if ratescale == RATE_SCALE.INCREASE_LOW or
            ratescale == RATE_SCALE.INCREASE_MED or
            ratescale == RATE_SCALE.INCREASE_HIGH or
            ratescale == RATE_SCALE.DECREASE_LOW or
            ratescale == RATE_SCALE.DECREASE_MED or
            ratescale == RATE_SCALE.DECREASE_HIGH then
            anim = RATE_SCALE_ANIM[ratescale]
    end

    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.llmy_power:GetAnimState():PlayAnimation(anim, true)
    end 
end

return Llmy_Power_Ui