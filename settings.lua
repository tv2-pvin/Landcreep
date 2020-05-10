data:extend({
    {
        type = "int-setting",
        name = "landcreep_range",
        setting_type = "runtime-global",
        default_value = 100,
        minimum_value = 0,
        maximum_value = 100,
        order = "01"
    },
    {
        type = "int-setting",
        name = "landcreep_construction_factor",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 100,
        order = "02"
    },
    {
        type = "int-setting",
        name = "landcreep_tick_interval",
        setting_type = "runtime-global",
        default_value = 180,
        minimum_value = 60,
        maximum_value = 6000,
        order = "03"
    },
    {
        type = "int-setting",
        name = "landcreep_maximum_number_of_orders",
        setting_type = "runtime-global",
        default_value = 0,
        minimum_value = 0,
        maximum_value = 10000,
        order = "04"
    },
    {
        type = "string-setting",
        name = "landcreep_landfill_tile_override",
        setting_type = "runtime-global",
        default_value = "landfill",
        order = "05"
    }
})