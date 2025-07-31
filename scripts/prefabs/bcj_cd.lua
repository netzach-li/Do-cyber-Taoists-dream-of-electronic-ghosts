local assets =
{
    Asset("ANIM", "anim/bcj_cd2.zip"), 
    Asset("ATLAS", "images/inventoryimages/bcj_cd2.xml") 
} 

local WAGSTAFF_CHATTER_COLOUR = Vector3(231/256, 165/256, 75/256)



local function CheckPlayer(inst)
    local player = FindEntity(inst, 6, nil, {"player"})
    if player then
       --print("说")
       -- inst.components.talker:Chatter("WAGSTAFF_NPC_NOTTHAT", nil, nil, nil, CHATPRIORITIES.LOW)
       inst.components.talker:Say(STRINGS.BCJ_CD2_SPEECH[math.random(1, 6)])
    end   
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bcj_cd2")
    inst.AnimState:SetBuild("bcj_cd2")
    inst.AnimState:PlayAnimation("idle", true)
    --inst.Transform:SetScale(1.5, 1.5, 1.5) 

    MakeObstaclePhysics(inst, 1)

    local talker = inst:AddComponent("talker")
    talker.fontsize = 40
    talker.font = TALKINGFONT_WORMWOOD
    talker.offset = Vector3(-100, -600, 0)  --c_findnext("bcj_cd2", 10).components.talker.offset = Vector3(-100, -600, 0)
    talker.name_colour = WAGSTAFF_CHATTER_COLOUR
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()

    local npc_talker = inst:AddComponent("npc_talker")
    npc_talker.default_chatpriority = CHATPRIORITIES.HIGH
    npc_talker.speaktime = 3.5

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:DoPeriodicTask(5, CheckPlayer)

    return inst
end

return Prefab("bcj_cd2", fn, assets),
       MakePlacer("bcj_cd2_placer", "bcj_cd2", "bcj_cd2", "idle")
