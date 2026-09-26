local Components, Component = dofile("component.lua")

local Health = Component()
assert(Health.Components == Components, "local registries must expose the global Components registry")
assert(Health.Component == Component, "local registries must expose the Component constructor")

Health.health = 100
function Health:damage(amount)
	self.health = self.health - amount
end

local Position = Component()
Position.x = 10

Components.Health = Health
Components.Position = Position

local player = Components:Apply{
	target = {},
	tags = { "Health", "Position" },
}
assert(player.health == 100)
assert(player.x == 10)
player:damage(25)
assert(player.health == 75)

local Local = Component()
local LocalHealth = Component()
LocalHealth.health = 50
Local.Health = LocalHealth

local localTarget = Local:Apply{
	target = {},
	tags = { "Health" },
}
assert(localTarget.health == 50, "local registries must resolve their own components")

local globalTarget = Components:Apply{
	target = {},
	tags = { "Health" },
}
assert(globalTarget.health == 100, "local registrations must not mutate the global registry")

local First = Component()
First.shared = function()
	return "first"
end
local Second = Component()
Second.shared = function()
	return "second"
end
Components.First = First
Components.Second = Second

local ordered = Components:Apply{
	target = {},
	tags = { "First", "Second" },
}
assert(ordered:shared() == "first", "earlier tags must take precedence")

local parent = {
	shared = function()
		return "parent"
	end,
}
local overridden = Components:Apply{
	target = {},
	tags = { "First" },
	parents = { parent },
}
assert(overridden:shared() == "parent", "explicit parents must precede tagged components")

print("lua-simple-components tests passed")
