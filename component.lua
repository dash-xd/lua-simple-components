-- Components.lua
-------------------------------------------------------------------------------------------
-- METATABLE INHERITOR FOR MULTIPLE INHERITANCE --
-------------------------------------------------------------------------------------------
local function searchParents(key, parents)
	for i = 1, #parents do
		local found = parents[i][key]
		if found then
			return found
		end
	end
end

local function RegisterParents(parents)
	-- Metatable to search across multiple parent components
	return {
		__index = function(self, key)
			return searchParents(key, parents) -- Search all parent components
		end
	}
end

-------------------------------------------------------------------------------------------
-- COMPONENT SYSTEM WITH CHAINED METATABLES --
-------------------------------------------------------------------------------------------
local Components = {}
function Components:Apply(entity, tags, parents)
	parents = parents or {}
	for _, tag in ipairs(tags) do
		local component = Components[tag]  -- Fetch the component based on the tag
		if component then
			table.insert(parents, component) -- Add to list for multi-parent search
		else
			warn("Component for tag '" .. tag .. "' not found in Components.")
		end
	end
	setmetatable(entity, RegisterParents(parents))
	return entity
end

local function Component()
	local Components = {}
	function Components:Apply(entity, tags, parents)
		parents = parents or {}
		for _, tag in ipairs(tags) do
			local component = Components[tag]  -- Fetch the component based on the tag
			if component then
				table.insert(parents, component) -- Add to list for multi-parent search
			else
				warn("Component for tag '" .. tag .. "' not found in Components.")
			end
		end
		setmetatable(entity, RegisterParents(parents))
		return entity
	end
	return Components
end

return Components, Component
