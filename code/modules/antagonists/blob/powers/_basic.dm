//these files are for organization and contrain procs of /mob/eye/blob
#define BLOB_REROLL_RADIUS (BLOB_POWER_REROLL_CHOICES * 10) //this might not scale correctly

/// Attempt to buy something
/mob/eye/blob/proc/buy(cost = 15)
	if(blob_points < cost)
		to_chat(src, span_warning("You cannot afford this, you need at least [cost] resources!"))
		balloon_alert(src, "need [cost-blob_points] more resource\s!")
		return FALSE
	add_points(-cost)
	return TRUE

/// Checks proximity for mobs
/mob/eye/blob/proc/check_core_visibility()
	for(var/mob/living/player in range(7, src))
		if(ROLE_BLOB in player.faction)
			continue
		if(player.client)
			to_chat(src, span_warning("There is someone too close to place your blob core!"))
			return FALSE

	for(var/mob/living/player in view(13, src))
		if(ROLE_BLOB in player.faction)
			continue
		if(player.client)
			to_chat(src, span_warning("Someone could see your blob core from here!"))
			return FALSE
	return TRUE

/// Checks for previous blobs or dense objects on the tile.
/mob/eye/blob/proc/check_objects_tile(turf/placement)
	for(var/obj/object in placement)
		if(istype(object, /obj/structure/blob))
			if(istype(object, /obj/structure/blob/normal))
				qdel(object)
			else
				to_chat(src, span_warning("There is already a blob here!"))
				return FALSE
		else
			if(object.density)
				to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
				return FALSE
	return TRUE

/// Finds cardinal and diagonal attack directions and then tries to expand from cardinals
/mob/eye/blob/proc/directional_attack(turf/tile, list/possible_blobs, attack_success = FALSE)
	var/list/cardinal_blobs = list()
	var/list/diagonal_blobs = list()
	for(var/obj/structure/blob/blob in possible_blobs)
		(get_dir(blob, tile) in GLOB.cardinals) ? (cardinal_blobs += blob) : (diagonal_blobs += blob)

	var/obj/structure/blob/attacker
	if(length(cardinal_blobs))
		attacker = pick(cardinal_blobs)
		if(!attacker.expand(tile, src))
			add_points(BLOB_ATTACK_REFUND) //assume it's attacked SOMETHING, possibly a structure
	else
		attacker = pick(diagonal_blobs)
		if(attack_success)
			attacker.blob_attack_animation(tile, src)
			playsound(attacker, 'sound/effects/splat.ogg', 50, TRUE)
			add_points(BLOB_ATTACK_REFUND)
		else
			add_points(BLOB_EXPAND_COST) //if we're attacking diagonally and didn't hit anything, refund
	return TRUE

/// Rally spores to a location
/mob/eye/blob/proc/rally_spores(turf/tile)
	to_chat(src, "You rally your spores.")
	var/list/surrounding_turfs = TURF_NEIGHBORS(tile)
	if(!length(surrounding_turfs))
		return FALSE
	for(var/mob/living/basic/blob_mob as anything in antag_team.blob_mobs)
		if(!isturf(blob_mob.loc) || get_dist(blob_mob, tile) > 35 || blob_mob.key)
			continue
		blob_mob.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		blob_mob.ai_controller.set_blackboard_key(BB_TRAVEL_DESTINATION, pick(surrounding_turfs))

/// Opens the reroll menu to change strains
/mob/eye/blob/proc/strain_reroll()
	if(!free_strain_rerolls && blob_points < BLOB_POWER_REROLL_COST)
		to_chat(src, span_warning("You need at least [BLOB_POWER_REROLL_COST] resources to reroll your strain again!"))
		return FALSE

	open_reroll_menu()

/// Controls changing strains
/mob/eye/blob/proc/open_reroll_menu()
	if(!strain_choices)
		strain_choices = list()

		var/list/new_strains = GLOB.valid_blobstrains.Copy() - antag_team.blobstrain.type
		for(var/unused in 1 to BLOB_POWER_REROLL_CHOICES)
			var/datum/blobstrain/strain = pick_n_take(new_strains)

			var/image/strain_icon = image('icons/mob/nonhuman-player/blob.dmi', "blob_core")
			strain_icon.color = initial(strain.color)

			var/info_text = span_boldnotice("[initial(strain.name)]")
			info_text += "<br>[span_notice("[initial(strain.analyzerdescdamage)]")]"
			if (!isnull(initial(strain.analyzerdesceffect)))
				info_text += "<br>[span_notice("[initial(strain.analyzerdesceffect)]")]"

			var/datum/radial_menu_choice/choice = new
			choice.image = strain_icon
			choice.info = info_text
			choice.name = strain::name

			strain_choices[strain] = choice

	var/strain_result = show_radial_menu(src, src, strain_choices, radius = BLOB_REROLL_RADIUS, tooltips = TRUE)
	if(isnull(strain_result))
		return

	if(!free_strain_rerolls && !buy(BLOB_POWER_REROLL_COST))
		return

	antag_team.set_team_strain(strain_result) //MAKE SURE THIS ACTUALLY WORKS
	if(free_strain_rerolls)
		free_strain_rerolls--

	last_reroll_time = world.time
	strain_choices = null
	/*for(var/_other_strain in GLOB.valid_blobstrains)
		var/datum/blobstrain/other_strain = _other_strain
		if(initial(other_strain.name) == strain_result)
			antag_team.set_team_strain(other_strain)

			if(free_strain_rerolls)
				free_strain_rerolls--

			last_reroll_time = world.time
			strain_choices = null

			return*/

#undef BLOB_REROLL_RADIUS
