local util = require("util")

local base_artillery_shell = data.raw.ammo["artillery-shell"]
local base_artillery_projectile = data.raw["artillery-projectile"]["artillery-projectile"]
local atomic_bomb_item = data.raw.ammo["atomic-bomb"]
local atomic_rocket = data.raw.projectile["atomic-rocket"]

if not (base_artillery_shell and base_artillery_projectile and atomic_bomb_item and atomic_rocket) then
  error("simple-atomic-shell: required vanilla prototypes were not found")
end

local atomic_artillery_projectile = util.table.deepcopy(base_artillery_projectile)
atomic_artillery_projectile.name = "artillery-projectile-atomic"
atomic_artillery_projectile.map_color = { r = 0.3, g = 1.0, b = 0.3 }
atomic_artillery_projectile.action = util.table.deepcopy(atomic_rocket.action)
atomic_artillery_projectile.final_action = util.table.deepcopy(base_artillery_projectile.final_action)


local target_effects = atomic_artillery_projectile.action.action_delivery.target_effects

table.insert(target_effects, {
  type = "nested-result",
  action = {
    type = "area",
    radius = 12,
    -- This block is an artillery-targeting hint, not real gameplay damage.
    -- Why it exists:
    -- 1) Artillery target selection evaluates direct area damage to estimate whether a shell can kill a spawner.
    -- 2) The atomic rocket's lethal effect is mostly implemented via nested shockwave projectiles, which artillery
    --    targeting logic does not fully account for during that estimate.
    -- 3) Without this hint, artillery may over-target nearby nests with atomic shells because it underestimates
    --    effective kill radius.
    -- 4) We add a synthetic high explosion damage in radius 12 so the estimate matches practical nuke results.
    -- 5) entity_flags = {"not-on-map"} constrains this synthetic damage to hidden entities only, so it does not
    --    affect normal map entities during actual impact resolution.
    -- In short: this is a prediction-only heuristic to improve shell usage efficiency.
    -- entity_flags = { "not-on-map" },

    -- nevermind...
    probability = 0.000000000001,
    show_in_tooltip = false,
    action_delivery = {
      type = "instant",
      target_effects = {
        {
          type = "damage",
          damage = { amount = 3505, type = "explosion" }
        }
      }
    }
  }
})


local atomic_artillery_shell = util.table.deepcopy(base_artillery_shell)
atomic_artillery_shell.name = "artillery-shell-atomic"
atomic_artillery_shell.icon = "__simple-atomic-shell__/graphics/icons/artillery-shell-atomic.png"
atomic_artillery_shell.pictures = util.table.deepcopy(atomic_bomb_item.pictures)
atomic_artillery_shell.ammo_type.action.action_delivery.projectile = "artillery-projectile-atomic"
atomic_artillery_shell.subgroup = "ammo"
atomic_artillery_shell.order = "d[explosive-cannon-shell]-e[artillery-shell-atomic]"
atomic_artillery_shell.stack_size = 1

local atomic_artillery_shell_recipe =
{
  type = "recipe",
  name = "artillery-shell-atomic",
  enabled = false,
  energy_required = 60,
  ingredients =
  {
    { type = "item", name = "artillery-shell", amount = 1 },
    { type = "item", name = "atomic-bomb",     amount = 1 },
    { type = "item", name = "processing-unit", amount = 20 }
  },
  results = { { type = "item", name = "artillery-shell-atomic", amount = 1 } }
}

atomic_artillery_shell.icon_size = 64

local atomic_artillery_shell_technology =
{
  type = "technology",
  name = "artillery-shell-atomic",
  icon = "__simple-atomic-shell__/graphics/technology/artillery-shell-atomic.png",
  icon_size = 256,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = "artillery-shell-atomic"
    }
  },
  prerequisites = { "artillery", "atomic-bomb" },
  unit =
  {
    count = 3500,
    ingredients =
    {
      { "automation-science-pack", 1 },
      { "logistic-science-pack",   1 },
      { "chemical-science-pack",   1 },
      { "military-science-pack",   1 },
      { "production-science-pack", 1 },
      { "utility-science-pack",    1 },
      { "space-science-pack",      1 }
    },
    time = 45
  }
}

data:extend
{
  atomic_artillery_projectile,
  atomic_artillery_shell,
  atomic_artillery_shell_recipe,
  atomic_artillery_shell_technology
}
