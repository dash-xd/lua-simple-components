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
local function Component()
	local components = {}

	function components:Apply(args)
		local entity = assert(args.entity, "Apply requires an entity")
		local tags = args.tags or {}
		local parents = args.parents or {}

		for _, tag in ipairs(tags) do
			local component = self[tag]
			if component then
				table.insert(parents, component)
			else
				warn("Component for tag '" .. tag .. "' not found in Components.")
			end
		end

		setmetatable(entity, RegisterParents(parents))
		return entity
	end

	return components
end

local Components = Component()

return Components, Component
