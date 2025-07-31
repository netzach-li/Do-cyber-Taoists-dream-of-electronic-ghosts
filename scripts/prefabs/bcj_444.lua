local assets =
{
    Asset("ANIM", "anim/444.zip"),  
    Asset("ATLAS", "images/inventoryimages/bcj_444.xml") 
} 

local function Make444(name, health, absorb, level)

local function isOnWater(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    if not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and not TheWorld.Map:GetPlatformAtPoint(x,z) then
        return true
    end
end

local function CanOnWater(inst)
    if inst.components.drownable then
        inst.components.drownable.enabled = false
    end

    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true , allowocean = true}  
end

local function CanNotOnWater(inst) 
    if inst.components.drownable then
        inst.components.drownable.enabled = true
    end

    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.GROUND)       
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true }
end

local function GetNearestValidLandPosition(inst, range)
    -- 获取角色的当前位置
    local x, y, z = inst.Transform:GetWorldPosition()

    -- 定义搜索范围和步长
    local step = 6 -- 搜索步长
    local max_attempts = 50 -- 最大尝试次数，避免无限循环

    -- 从近到远搜索有效位置
    for r = 0, range, step do
        for i = 1, max_attempts do
            -- 随机生成一个角度
            local angle = math.random() * 2 * PI
            -- 计算目标位置
            local offset_x = math.cos(angle) * r
            local offset_z = math.sin(angle) * r
            local target_x = x + offset_x
            local target_z = z + offset_z

            -- 检查目标位置是否有效（非海上且可通行）
            if TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z) and
               not TheWorld.Map:IsOceanAtPoint(target_x, 0, target_z) then
                return Vector3(target_x, 0, target_z) -- 返回有效位置
            end
        end
    end

    -- 如果没有找到有效位置，返回 nil
    return nil
end

local function onequip(inst, owner)
    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end

    if owner.show_444 and owner.show_444 == 0 then
    if inst.fx == nil or (inst.fx and not inst.fx:IsValid()) then
    inst.fx = SpawnPrefab("bcj_444_pet")
    inst.fx.AnimState:PlayAnimation("idle_loop_"..name, true) 
    inst.fx.Transform:SetRotation(owner.Transform:GetRotation())
    inst.fx.entity:AddFollower()
    inst.fx.Follower:FollowSymbol(owner.GUID, nil, 0, -300, 0)
    end
    end

    if name == "5" then
        CanOnWater(owner)
        inst.on_water_task = inst:DoPeriodicTask(0.5, function()
            local owner = inst.components.inventoryitem.owner 
            if owner and owner:HasTag("player") and isOnWater(owner) == true then
                inst.components.armor:Repair(-5)
            end 
        end)
    end
end 

local function onunequip(inst, owner)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end

    if inst.fx and inst.fx:IsValid() then
        inst.fx:Remove()
        inst.fx = nil
    end	

    if name == "5" then
        CanNotOnWater(owner)
        if inst.on_water_task then
            inst.on_water_task:Cancel()
            inst.on_water_task = nil
        end	
    end         
end  

local level_up_prefab = {
	"butterfly",
	"spider_warrior",
	"mole",
	"crow",	
}

local function CanLevelUp(inst)
	local canUp = true
    local container = inst.components.container
    if container:IsOpen() or inst.components.inventoryitem.owner 
    or inst.components.equippable:IsEquipped() then
        canUp = false
    end

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if (item == nil or item.prefab ~= level_up_prefab[inst.level]) and canUp == true then
            canUp = false
        end
    end

    if canUp == true and ((name == "3" and not TheWorld.state.isfullmoon) or (name == "4" and not TheWorld.state.isnewmoon)) then
        canUp = false
    end	

    return canUp
end

local function CheckLevelUp(inst)
    if CanLevelUp(inst) == true then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst:Remove()

        local new_back = SpawnPrefab("bcj_444_"..(inst.level + 1))
        new_back.Transform:SetPosition(x, y, z)

        local fx = SpawnPrefab("chester_transform_fx")
        fx.Transform:SetPosition(x, y + 1, z)
    end	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("444")
    inst.AnimState:SetBuild("444")
    inst.AnimState:PlayAnimation("idle_loop_"..name, true) 
    inst.Transform:SetScale(1.5, 1.5, 1.5) 

    inst:AddTag("bcj_444")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.level = level

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bcj_444"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bcj_444.xml"
    inst.components.inventoryitem.keepondeath = true

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("bcj_444_"..name)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.restrictedtag = "bcj"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(health, absorb)
    inst.components.armor.keeponfinished = true
    inst.components.armor.SetCondition = function(self, amount)
        self.condition = math.max(math.min(amount, self.maxcondition), 0)
        if self.condition > 0 then
            self:SetAbsorption(absorb)
            inst.components.container.canbeopened = true
            inst.components.equippable.restrictedtag = "bcj"
        else
            self:SetAbsorption(0)
            inst.components.container.canbeopened = false
            inst.components.equippable.restrictedtag = "no_equip"

            if inst.components.equippable:IsEquipped() then
                local owner = inst.components.inventoryitem.owner 
                if owner then
                if isOnWater(owner) then
                    local pos = GetNearestValidLandPosition(inst, 200)
                    if pos ~= nil then
                    owner.Transform:SetPosition(pos:Get())
                    end
                end	

                if owner.components.inventory then
                    owner.components.inventory:Unequip(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
                    owner.components.inventory:GiveItem(inst)
                end    
                end	
            end       
        end    
        self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() })
    end

    if name ~= "5" then
    inst:DoPeriodicTask(1, CheckLevelUp) 
    end

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("bcj_444_"..name, fn, assets)  --c_findnext("bcj_444_5").components.armor:SetPercent(0)
end   

return Make444("1", 666, 0.7, 1),
       Make444("2", 1111, 0.75, 2),
       Make444("3", 2222, 0.8, 3),
       Make444("4", 3333, 0.85, 4),
       Make444("5", 4444, 0.9, 5)  