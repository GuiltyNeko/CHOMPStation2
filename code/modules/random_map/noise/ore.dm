/datum/random_map/noise/ore
	descriptor = "ore distribution map"
	var/deep_val = 0.8              // Threshold for deep metals, set in new as percentage of cell_range.
	var/rare_val = 0.7              // Threshold for rare metal, set in new as percentage of cell_range.
	var/chunk_size = 3              // Size each cell represents on map

/datum/random_map/noise/ore/New()
	rare_val = cell_range * rare_val
	deep_val = cell_range * deep_val
	..()

/datum/random_map/noise/ore/check_map_sanity()

	var/rare_count = 0
	var/surface_count = 0
	var/deep_count = 0

	// Increment map sanity counters.
	for(var/value in map)
		if(value < rare_val)
			surface_count++
		else if(value < deep_val)
			rare_count++
		else
			deep_count++
	// Sanity check.
	if(surface_count < MIN_SURFACE_COUNT)
		admin_notice("<span class='danger'>Insufficient surface minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else if(rare_count < MIN_RARE_COUNT)
		admin_notice("<span class='danger'>Insufficient rare minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else if(deep_count < MIN_DEEP_COUNT)
		admin_notice("<span class='danger'>Insufficient deep minerals. Rerolling...</span>", R_DEBUG)
		return 0
	else
		return 1

/datum/random_map/noise/ore/apply_to_turf(var/x,var/y)

	var/tx = ((origin_x-1)+x)*chunk_size
	var/ty = ((origin_y-1)+y)*chunk_size

	for(var/i=0,i<chunk_size,i++)
		for(var/j=0,j<chunk_size,j++)
			var/turf/simulated/T = locate(tx+j, ty+i, origin_z)
			if(!istype(T) || !T.has_resources)
				continue
			if(!priority_process) sleep(-1)
			T.resources = list()
			T.resources["silicates"] = rand(3,5)
			T.resources["carbon"] = rand(3,5)

			var/current_cell = map[get_map_cell(x,y)]
			if(current_cell < rare_val)      // Surface metals.
				T.resources["hematite"] = rand(RESOURCE_HIGH_MIN, RESOURCE_HIGH_MAX)
				T.resources["gold"] =     rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources["silver"] =   rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources["uranium"] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources["marble"] =   rand(RESOURCE_LOW_MIN, RESOURCE_MID_MAX)
				T.resources["diamond"] =  0
				T.resources["phoron"] =   0
				T.resources["osmium"] =   0
				T.resources["hydrogen"] = 0
				T.resources["verdantium"] = 0
				T.resources["lead"]     = 0
				//T.resources["copper"] =   rand(RESOURCE_MID_MIN, RESOURCE_HIGH_MAX)
				//T.resources["tin"] =      rand(RESOURCE_LOW_MIN, RESOURCE_MID_MAX)
				//T.resources["bauxite"] =  rand(RESOURCE_LOW_MIN, RESOURCE_LOW_MAX)
				T.resources["rutile"] =   0
				//T.resources["void opal"] = 0
				//T.resources["quartz"] = 0
				//T.resources["painite"] = 0
			else if(current_cell < deep_val) // Rare metals.
				T.resources["gold"] =     rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["silver"] =   rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["uranium"] =  rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["phoron"] =   rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["osmium"] =   rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["verdantium"] = rand(RESOURCE_LOW_MIN, RESOURCE_LOW_MAX)
				T.resources["lead"] =     rand(RESOURCE_LOW_MIN, RESOURCE_MID_MAX)
				T.resources["hydrogen"] = 0
				T.resources["diamond"] =  0
				T.resources["hematite"] = 0
				T.resources["marble"] =   0
				//T.resources["copper"] =   0
				//T.resources["tin"] =      rand(RESOURCE_MID_MIN, RESOURCE_MID_MAX)
				//T.resources["bauxite"] =  0
				T.resources["rutile"] =   0
				//T.resources["void opal"] = 0
				//T.resources["quartz"] = 0
				//T.resources["painite"] = 0
			else                             // Deep metals.
				T.resources["uranium"] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources["diamond"] =  rand(RESOURCE_LOW_MIN,  RESOURCE_LOW_MAX)
				T.resources["verdantium"] = rand(RESOURCE_LOW_MIN, RESOURCE_MID_MAX)
				T.resources["phoron"] =   rand(RESOURCE_HIGH_MIN, RESOURCE_HIGH_MAX)
				T.resources["osmium"] =   rand(RESOURCE_HIGH_MIN, RESOURCE_HIGH_MAX)
				T.resources["hydrogen"] = rand(RESOURCE_MID_MIN,  RESOURCE_MID_MAX)
				T.resources["marble"] =   rand(RESOURCE_MID_MIN, RESOURCE_HIGH_MAX)
				T.resources["lead"] =     rand(RESOURCE_LOW_MIN, RESOURCE_HIGH_MAX)
				T.resources["hematite"] = 0
				T.resources["gold"] =     0
				T.resources["silver"] =   0
				//T.resources["copper"] =   0
				//T.resources["tin"] =      0
				//T.resources["bauxite"] =  0
				T.resources["rutile"] =   0
				//T.resources["void opal"] = 0
				//T.resources["quartz"] = 0
				//T.resources["painite"] = 0
	return

/datum/random_map/noise/ore/get_map_char(var/value)
	if(value < rare_val)
		return "S"
	else if(value < deep_val)
		return "R"
	else
		return "D"