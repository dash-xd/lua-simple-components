local Components, Component = dofile("component.lua")

local function expectError(fn, message)
	local ok = pcall(fn)
	assert(not ok, message)
end

local Health = Component()
assert(Health.Components == Components, "component instances must expose the shared Components registry")
assert(Health.Component == Component, "component instances must expose the Component constructor")

local Nested = Health.Component()
assert(Nested.Components == Components, "components created from an instance must share the registry")

Health.health = 100

function Health:damage(amount)
	self.health = self.health - amount
end

local First = Component()
First.shared = function()
	return "first"
end

local Second = Component()
Second.shared = function()
	return "second"
end

Components.Health = Health
Components.First = First
Components.Second = Second

expectError(function()
	Components.Invalid = {}
end, "plain tables must not be registered as components")

local player = {}
Components:Apply{
	target = player,
	tags = { "Health" },
}

assert(player.health == 100, "tagged component data must be visible")
player:damage(25)
assert(player.health == 75, "tagged component methods must receive the target as self")

local ordered = {}
Components:Apply{
	target = ordered,
	tags = { "First", "Second" },
}
assert(ordered:shared() == "first", "earlier tags must take precedence")

local parent = {
	shared = function()
		return "parent"
	end,
}

local overridden = {}
Components:Apply{
	target = overridden,
	tags = { "First" },
	parents = { parent },
}
assert(overridden:shared() == "parent", "explicit parents must precede tagged components")

local localValue = {
	shared = function()
		return "target"
	end,
}
Components:Apply{
	target = localValue,
	tags = { "First" },
}
assert(localValue:shared() == "target", "target fields must precede composed lookup")

print("lua-simple-components tests passed")
