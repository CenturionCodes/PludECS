export type entity = {
	UniqueID: number;
	Components: {};
}
export type component<T> = {
	Storage: {[entity]: T};
	Pairs: {};
}

local plud_ecs = {}
plud_ecs.world = {}

local world = plud_ecs.world
world.__index = world

function world.new()
	return setmetatable({
		nxtc = 0;
		nxte = 0;
		entities = {};
		components = {}
	}, world)
end

function world:pair(component_id, entity_id)
	local component = self.components[component_id]
	local entity = self.entities[entity_id]
	
	local pair_data = {
		["Component"] = component;
		["Entity"] = entity;
		["Linked"] = {};
	}
	table.insert(component.Pairs, pair_data)
	return pair_data
end

function world:component(): component
	local nxtc = self.nxtc+1
	self.nxtc = nxtc
	self.components[nxtc] = {Storage = {}, Pairs = {}}
	return nxtc
end

function world:entity(): entity
	local nxte = self.nxte+1
	self.nxte = nxte
	self.entities[nxte] = {UniqueID = nxte, Components = {}}
	return nxte
end

function world:delete(entity_id)
	local entity: entity = self.entities[entity_id]
	
	for component_id, value in entity.Components do
		local component: component = self.components[component_id]
		component.Storage[entity_id] = nil
		entity.Components[component_id] = nil
	end
	
	self.entities[entity_id] = nil
end

function world:set(entity_id, component_id, data)
	local entity: entity = self.entities[entity_id]
	local component: component = self.components[component_id]
	
	component.Storage[entity_id] = data
	entity.Components[component_id] = data
end

function world:remove(entity_id, component_id)
	local entity: entity = self.entities[entity_id]
	local component: component = self.components[component_id]
	
	component.Storage[entity_id] = nil
	entity.Components[component_id] = nil
end

function world:add(entity_id, pair)
	local entity: entity = self.entities[entity_id]
	
	local linked = pair.Linked
	linked[entity.UniqueID] = entity
end

function world:target(entity_id, component_id)
	local component = self.components[component_id]
	
	local parent
	for i, pair in component.Pairs do
		if pair.Linked[entity_id] then
			parent = pair.Entity
		end
	end
	
	return parent.UniqueID
end

function world:get(entity_id, component_id)
	local entity: entity = self.entities[entity_id]
	return entity.Components[component_id]
end

function world:query(component_id, t)
	local queried = {}
	
	if typeof(t) == "table" and t.Linked then
		t = t.Linked
	end
	
	for i, entity: entity in self.entities do
		table.insert(queried, entity.Components[component_id])
	end
	
	return queried
end

return plud_ecs
