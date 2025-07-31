GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

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
        inst.dapperness = self.dapperness
        inst.components.equippable.dapperness = 0
        return OldEquip(self, owner, from_ground, ...) 
    end

    local OldUnequip = inst.components.equippable.Unequip
    inst.components.equippable.Unequip = function(self, owner, ...)
        inst.components.equippable.dapperness = inst.dapperness or 0
        return OldUnequip(self, owner, ...) 
    end    
    end     
end) 
