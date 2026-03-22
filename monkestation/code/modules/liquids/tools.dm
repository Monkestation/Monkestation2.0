ADMIN_VERB(spawn_liquid, R_FUN, FALSE, "Spawn Liquid", "Spawns an amount of chosen liquid at your current location.", ADMIN_CATEGORY_FUN)
	var/choice
	var/valid_id
	while(!valid_id)
		choice = stripped_input(user, "Enter the ID of the reagent you want to add.", "Search reagents")
		if(isnull(choice)) //Get me out of here!
			break
		if (!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if (ispath(choice))
				valid_id = TRUE
		else
			valid_id = TRUE
		if(!valid_id)
			to_chat(user, span_warning("A reagent with that ID doesn't exist!"))
	if(!choice)
		return
	var/volume = input(user, "Volume:", "Choose volume") as num
	if(!volume)
		return
	if(volume >= 100000)
		to_chat(user, span_warning("Please limit the volume to below 100000 units!"))
		return
	var/turf/epicenter = get_turf(user.mob)
	epicenter.add_liquid(choice, volume, FALSE, 300)
	message_admins("[ADMIN_LOOKUPFLW(user)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(user)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Liquid")

ADMIN_VERB(remove_liquid, R_FUN, FALSE, "Remove Liquids", "Removes a chosen liquid in a radius at your current location.", ADMIN_CATEGORY_FUN)
	var/turf/epicenter = get_turf(user.mob)

	var/range = input(user, "Enter range:", "Range selection", 2) as num

	var/old_can_fire = SSliquids.can_fire
	SSliquids.can_fire = FALSE
	if(SSliquids.state == SS_RUNNING)
		SSliquids.pause()
		sleep(world.tick_lag)
	for(var/obj/effect/abstract/liquid_turf/liquid in range(range, epicenter))
		if(QDELETED(liquid))
			continue
		if(!QDELETED(liquid.liquid_group))
			liquid.liquid_group.remove_any(liquid, liquid.liquid_group.reagents_per_turf)
		qdel(liquid)
	SSliquids.can_fire = old_can_fire

	message_admins("[key_name_admin(user)] removed liquids with range [range] in [epicenter.loc.name]")
	log_game("[key_name_admin(user)] removed liquids with range [range] in [epicenter.loc.name]")
	BLACKBOX_LOG_ADMIN_VERB("Remove Liquids")

ADMIN_VERB(change_ocean, R_FUN, FALSE, "Change Ocean Liquid", "Changes the reagent of the ocean.", ADMIN_CATEGORY_FUN)
	var/choice = tgui_input_list(user, "Choose a reagent", "Ocean Reagent", subtypesof(/datum/reagent))
	if(!choice)
		return
	message_admins("[ADMIN_LOOKUPFLW(user)] changed the ocean reagent to [choice]")
	log_admin("[key_name(user)] changed the ocean reagent to [choice]")
	var/datum/reagent/chosen_reagent = choice
	var/rebuilt = FALSE
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in SSliquids.ocean_turfs)
		if(!rebuilt)
			listed_ocean.ocean_reagents = list()
			listed_ocean.ocean_reagents[chosen_reagent] = 10
			listed_ocean.static_overlay.mix_colors(listed_ocean.ocean_reagents)
			for(var/area/ocean/ocean_types in GLOB.initalized_ocean_areas)
				ocean_types.base_lighting_color = listed_ocean.static_overlay.color
				ocean_types.update_base_lighting()
			rebuilt = TRUE
	BLACKBOX_LOG_ADMIN_VERB("Change Ocean Liquid")
