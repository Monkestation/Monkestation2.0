/proc/random_rgb_pairlists(list/red_pairs, list/green_pairs, list/blue_pairs, list/alpha_pairs)
	if(!length(red_pairs) || !length(blue_pairs) || !length(green_pairs) || !length(alpha_pairs))
		return COLOR_CULT_RED

	if(!length(red_pairs) >= 2)
		red_pairs[2] = 255
	if(!length(blue_pairs) >= 2)
		blue_pairs[2] = 255
	if(!length(green_pairs) >= 2)
		green_pairs[2] = 255
	if(!length(alpha_pairs) >= 2)
		alpha_pairs[2] = 255

	var/red = rand(red_pairs[1], red_pairs[2])
	var/green = rand(green_pairs[1], green_pairs[2])
	var/blue = rand(blue_pairs[1], blue_pairs[2])
	var/alpha = rand(alpha_pairs[1], alpha_pairs[2])

	return rgb(red, green, blue, alpha)

///Spawn a new artifact
/proc/spawn_artifact(turf/loc, datum/artifact_origin/forced_origin = null, datum/artifact_effect/forced_effect = null)
	if (!loc)
		return
	if(!length(GLOB.artifact_effect_rarity))
		build_weighted_rarities()

	var/obj/type_of_artifact = pick_weight(list(
		/obj/structure/artifact = 60,
		/obj/item/artifact_item = 5,
		/obj/item/artifact_item_tiny = 5,
		/obj/item/stock_parts/power_store/cell/artifact = 5,
		/obj/item/gun/magic/artifact = 5,
		/obj/item/melee/artifact = 5,
		/obj/machinery/power/generator_artifact = 5
	))
	if(forced_effect) //Ok this gon be really scuffed.
		if(forced_effect.artifact_size == 1) //can be any item
			type_of_artifact = pick_weight(list(
				/obj/item/artifact_item = 1,
				/obj/item/gun/magic/artifact = 1,
				/obj/item/melee/artifact = 1,
			))
		if(forced_effect.artifact_size == 0) //Ok TINY item
			type_of_artifact = pick_weight(list(
				/obj/item/artifact_item_tiny = 50,
				/obj/item/stock_parts/power_store/cell/artifact = 50,
			))
		switch(forced_effect) //Ok its a specific type, it HAS to be this one.
			if(/datum/artifact_effect/cell)
				type_of_artifact = /obj/item/stock_parts/power_store/cell/artifact
			if(/datum/artifact_effect/gun)
				type_of_artifact = /obj/item/gun/magic/artifact
			if(/datum/artifact_effect/melee)
				type_of_artifact = /obj/item/melee/artifact
			if(/datum/artifact_effect/generator)
				type_of_artifact = /obj/machinery/power/generator_artifact

	var/obj/A = new type_of_artifact(loc,forced_origin,forced_effect)
	return A


/proc/build_weighted_rarities()
	GLOB.artifact_effect_rarity["all"] = list() ///this needs to be created first for indexing sake
	for(var/datum/artifact_origin/origin as anything in subtypesof(/datum/artifact_origin))
		GLOB.artifact_effect_rarity[initial(origin.type_name)] = list()

	for(var/datum/artifact_effect/artifact_effect as anything in subtypesof(/datum/artifact_effect))
		if(artifact_effect.do_not_roll)
			continue
		var/weight = initial(artifact_effect.weight)
		if(!weight)
			continue
		GLOB.artifact_effect_rarity["all"][artifact_effect] = weight
		for(var/origin in GLOB.artifact_effect_rarity)
			if(origin in initial(artifact_effect.valid_origins))
				GLOB.artifact_effect_rarity[origin][artifact_effect] = weight
