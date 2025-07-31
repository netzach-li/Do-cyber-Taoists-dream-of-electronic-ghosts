local function GetHopDistance(inst, speed_mult)
    return speed_mult < 0.8 and TUNING.WILSON_HOP_DISTANCE_SHORT
            or speed_mult >= 1.2 and TUNING.WILSON_HOP_DISTANCE_FAR
            or TUNING.WILSON_HOP_DISTANCE
end

local function ConfigurePlayerLocomotor(inst)
    inst.components.locomotor:SetSlowMultiplier(0.6)
    inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
    inst.components.locomotor.walkspeed = TUNING.WILSON_WALK_SPEED -- 4
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED -- 6
    inst.components.locomotor.fasteronroad = true
    inst.components.locomotor:SetFasterOnCreep(inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetTriggersCreep(not inst:HasTag("spiderwhisperer"))
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst.components.locomotor:EnableHopDelay(true)
    inst.components.locomotor.hop_distance_fn = GetHopDistance
    inst.components.locomotor.pusheventwithdirection = true
end


local function ConfigurePlayerActions(inst)
    if inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(GhostActionFilter)
    end
end

local function CommonActualRez(inst)
    inst.player_classified.MapExplorer:EnableUpdate(true)

    if inst.components.revivablecorpse ~= nil then
        inst.components.inventory:Show()
    else
        inst.components.inventory:Open()
        inst.components.age:ResumeAging()
    end

    inst.components.health.canheal = true
    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:Resume()
    end
    if not GetGameModeProperty("no_temperature") then
        inst.components.temperature:SetTemp() --nil param will resume temp
    end
    inst.components.frostybreather:Enable()

    MakeMediumBurnableCharacter(inst, "torso")
    inst.components.burnable:SetBurnTime(TUNING.PLAYER_BURN_TIME)
    inst.components.burnable.nocharring = true

    MakeLargeFreezableCharacter(inst, "torso")
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

    inst:AddComponent("grogginess")
    inst.components.grogginess:SetResistance(3)
    inst.components.grogginess:SetKnockOutTest(ShouldKnockout)

    inst:AddComponent("slipperyfeet")

    inst.components.moisture:ForceDry(false, inst)

    inst.components.sheltered:Start()

    inst.components.debuffable:Enable(true)

    --don't ignore sanity any more
    inst.components.sanity.ignore = GetGameModeProperty("no_sanity")

    ConfigurePlayerLocomotor(inst)
    ConfigurePlayerActions(inst)

    if inst.rezsource ~= nil then
        local announcement_string = GetNewRezAnnouncementString(inst, inst.rezsource)
        if announcement_string ~= "" then
            TheNet:AnnounceResurrect(announcement_string, inst.entity)
        end
        inst.rezsource = nil
    end
    inst.remoterezsource = nil

    inst.last_death_position = nil
    inst.last_death_shardid = nil

    inst:RemoveTag("reviving")
end

local function DoActualRez(inst, source, item) --彻底复活！
    local x, y, z
    if source ~= nil then
        x, y, z = source.Transform:GetWorldPosition()
    else
        x, y, z = inst.Transform:GetWorldPosition()
    end

    local diefx = SpawnPrefab("lavaarena_player_revive_from_corpse_fx")
    if diefx and x and y and z then
        diefx.Transform:SetPosition(x, y, z)
    end

    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:Show("HAIR_NOHAT")
    inst.AnimState:Show("HAIR")
    inst.AnimState:Show("HEAD")
    inst.AnimState:Hide("HEAD_HAT")

    inst:SetStateGraph("SGwilson")

    inst.Physics:Teleport(x, y, z)

    inst:DoTaskInTime(2.7,function()
        inst:Show()
        inst.player_classified:SetGhostMode(false)
        if source ~= nil then            
            inst.DynamicShadow:Enable(true)
            inst.AnimState:SetBank("wilson")
            --inst.components.skinner:SetSkinMode("normal_skin")
            inst.ApplySkinOverrides(inst)
            inst.components.bloomer:PopBloom("playerghostbloom")
            inst.AnimState:SetLightOverride(0)
            inst.sg:GoToState("gravestone_rebirth", source)
            source:Remove()
        else
            inst.AnimState:SetBank("wilson")
            inst.ApplySkinOverrides(inst)
            inst.sg:GoToState("reviver_rebirth", item)
        end
 
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(.5)
        inst.Light:SetFalloff(.65)
        inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)
        inst.Light:Enable(false)

        MakeCharacterPhysics(inst, 75, .5)

        CommonActualRez(inst, source, item)

        inst:RemoveTag("playerghost")
        inst.Network:RemoveUserFlag(USERFLAGS.IS_GHOST)

        inst:PushEvent("ms_respawnedfromghost")
    end)
end

local function OnRespawnFromGhost(inst, data) --复活开始！
    if not inst:HasTag("playerghost") then
        return
    end
    inst.deathclientobj = nil
    inst.deathcause = nil
    inst.deathpkname = nil
    inst.deathbypet = nil
    inst:ShowHUD(false)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    if inst.components.talker ~= nil then
        inst.components.talker:ShutUp()
    end

    if inst.KillSoulFire then
        inst:KillSoulFire()
    end

    inst.sg:AddStateTag("busy")

    inst:DoTaskInTime(0, DoActualRez,data.source )
    inst.rezsource =
        data ~= nil and (
            (data.source ~= nil and data.source.prefab ~= "reviver" and data.source:GetBasicDisplayName()) or
            (data.user ~= nil and data.user:GetDisplayName())
        ) or
        STRINGS.NAMES.SHENANIGANS

    inst.remoterezsource =
        data ~= nil and
        data.source ~= nil and
        data.source.components.attunable ~= nil and
        data.source.components.attunable:GetAttunableTag() == "remoteresurrector"
end

local ex_fns = require "prefabs/player_common_extensions"
local old_Ghost  = ex_fns.OnRespawnFromGhost
ex_fns.OnRespawnFromGhost = function(inst,data)
    if inst and inst.prefab == "bcj"
    and data and data.source and data.source.prefab == "gravestone" then
        OnRespawnFromGhost(inst, data)
        return
    end
    old_Ghost(inst,data)
end
