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
        name = "landcreepers_only_place_if_landfill_available",
        setting_type = "runtime-global",
        default_value = true,
        order = "02"
    },
	{
		type = "bool-setting",
		name = "landcreepers_only_place_if_robots_available",
		setting_type = "runtime-global",
		default_value = true,
		order = "03"
    },
    {
		type = "bool-setting",
		name = "landcreepers_iterate_less_than_one_roboport",
		setting_type = "runtime-global",
		default_value = true,
		order = "04"
    },
    {
		type = "int-setting",
		name = "landcreepers_iterate_less_than_one_roboport_number_of_columns",
		setting_type = "runtime-global",
        default_value = 5,
        min_value = 1,
		order = "04"
	}
})