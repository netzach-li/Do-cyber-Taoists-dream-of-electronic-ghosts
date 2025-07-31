GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

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

local function SpawnTenc(inst, pt) 
    local angle = 0
    local radius = 5
    local number = 12
    for i = 1,number do        
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt + offset
        local x, y, z = newpt:Get()

        if TheWorld.Map:IsPassableAtPoint(x, y, z) then
            inst:DoTaskInTime(math.random()*0.3, function()            
                local rock = SpawnPrefab("moluo_tentacle")
                rock.owner = inst
                rock.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
            end)
        end
        angle = angle + (PI*2/number)
    end
end

local function ML_Skill2(inst)
    if inst:HasTag("moluo") then 

        if inst.skill2_task_cd then
            return
        end 	

        if inst.sg and not inst:HasTag("skill2_cd") then
            inst:AddTag("skill2_cd")
            inst:AddTag("skill2_cd_x")
            inst.sg:GoToState("play_strum")
            inst.skill2_task = inst:DoTaskInTime(0.5,function(inst)
                inst:RemoveTag("skill2_cd")
                SpawnTenc(inst, Vector3(inst.Transform:GetWorldPosition()))

                 if inst.skill2_task then
                    inst.skill2_task:Cancel()
                    inst.skill2_task = nil
                 end   
            end)

            inst.components.timer:StartTimer("skill2_task_cd", 10)
            --[[ 
            inst.skill2_task_cd = inst:DoTaskInTime(10,function(inst)
            	 inst:RemoveTag("skill2_cd_x")
                 if inst.skill2_task_cd then
                    inst.skill2_task_cd:Cancel()
                    inst.skill2_task_cd = nil
                 end   
            end)
            ]]                  
        end        
    end
end

AddModRPCHandler("ML_Skill2", "ML_Skill2", ML_Skill2)

TheInput:AddKeyDownHandler(KEY_X, function()                            
    local player = ThePlayer
    local screen = GLOBAL.TheFrontEnd:GetActiveScreen()
    local IsHUDActive = screen and screen.name == "HUD"
 
    if player and player:HasTag("moluo") and not player:HasTag("skill2_cd_x") and not player:HasTag("playerghost") and IsHUDActive then
        if player.sg and not player:HasTag("skill2_cd") then
            player.sg:GoToState("play_strum")
        end    
        SendModRPCToServer(MOD_RPC["ML_Skill2"]["ML_Skill2"]) 
    end 
end)
