local Package = Class(function(self, inst)
    self.inst = inst
	self.content = nil
	
	self.onpack = nil
	self.onunpack = nil
end)

--------------------------------------------------------------------------

function Package:SetOnPackFn(fn)
    self.onpack = fn
end

function Package:SetOnUnpackFn(fn)
    self.onunpack = fn
end

--------------------------------------------------------------------------

function Package:Unpack(unpacker)
    if self.content ~= nil then		
		local entity = self:Empty()
		
		if self.onunpack ~= nil then
            self.onunpack(self.inst, entity, unpacker)
        end
    end
end

function Package:Pack(entity)
	if entity ~= nil and entity:HasTag("packable") ~= nil then
      	self.content = entity
		entity.Transform:SetPosition(0, -100, 0) -- hide entity away
		
		if self.onpack ~= nil then
            self.onpack(self.inst, entity)
        end
    end
end

function Package:Empty()
    if self.content ~= nil then
		local entity = self.content;
		local pt = self.inst:GetPosition()
		entity.Transform:SetPosition(pt:Get()) -- teleport entity back
		
		self.content = nil
		
		return entity
    end
end

--------------------------------------------------------------------------

function Package:OnSave()
    return
    {
		content = self.content ~= nil and self.content.GUID or nil,
    },
    {
        self.content ~= nil and self.content.GUID or nil,
    }
end

function Package:LoadPostPass(newents, savedata)
    if savedata.content ~= nil then
        local content = newents[savedata.content]
        if content ~= nil then
            self.content = content.entity
        end
    end
end

return Package


	