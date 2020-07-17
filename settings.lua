data:extend({
  {
    type = "string-setting",
    name = "landcreep_tile_override",
    setting_type = "runtime-global",
    default_value = "landfill",
    order = "01"
  },
  {
    type = "bool-setting",
    name = "landcreepers_circular_creep",
    setting_type = "runtime-global",
    default_value = false,
    order = "02"
  },
  {
    type = "int-setting",
    name = "landcreepers_max_tiles_per_iteration",
    setting_type = "runtime-global",
    default_value = 100,
    order = "03"
  }
})