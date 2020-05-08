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
        type = "bool-setting",
        name = "landcreep_ignore_placed_tiles",
        setting_type = "runtime-global",
        default_value = true,
		order = "03"
    }
})