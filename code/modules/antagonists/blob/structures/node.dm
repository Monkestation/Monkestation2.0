/obj/structure/blob/special/node
	name = "blob node"
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blank_blob"
	desc = "A large, pulsating yellow mass."
	max_integrity = BLOB_NODE_MAX_HP
	health_regen = BLOB_NODE_HP_REGEN
	armor_type = /datum/armor/blob_node
	point_cost = 50
	point_return = 30
	resistance_flags = LAVA_PROOF
	///The icon state we use for our overlay
	var/overlay_icon_state = "blob_node_overlay"
	/// The radius inside which (previously dead) blob tiles are 'claimed' again by the pulsing overmind. Very rarely used.
	var/claim_range = BLOB_NODE_CLAIM_RANGE
	/// The radius inside which blobs are pulsed by this overmind. Does stuff like expanding, making blob spores from factories, make resources from nodes etc.
	var/pulse_range = BLOB_NODE_PULSE_RANGE
	/// The radius up to which this special structure naturally grows normal blobs.
	var/expand_range = BLOB_NODE_EXPAND_RANGE
//COULD PROBABLY JUST CHECK THE STRAIN VALUES DIRECTLY
	// Area reinforcement vars: used by cores and nodes, for strains to modify
	/// Range this blob free upgrades to strong blobs at: for the core, and for strains
	var/strong_reinforce_range = 0
	/// Range this blob free upgrades to reflector blobs at: for the core, and for strains
	var/reflector_reinforce_range = 0
	/// The overmind this node is hosting
	var/mob/eye/blob/hosting

/datum/armor/blob_node
	fire = 65
	acid = 90
	laser = 25

/obj/structure/blob/special/node/Initialize(mapload, datum/team/blob/owning_team)
	GLOB.blob_nodes += src
	START_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/special/node/Destroy()
	GLOB.blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(hosting)
	return ..()

/obj/structure/blob/special/node/scannerreport()
	return "Gradually expands and sustains nearby blob spores and blobbernauts."

/obj/structure/blob/special/node/update_icon()
	. = ..()
	color = null

/obj/structure/blob/special/node/update_overlays()
	. = ..()
	var/mutable_appearance/blob_overlay = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob")
	if(blob_team)
		blob_overlay.color = blob_team.blobstrain.color
		if(!legit)
			blob_overlay.color = blob_team.blobstrain.cached_faded_color
	. += blob_overlay
	. += mutable_appearance('icons/mob/nonhuman-player/blob.dmi', overlay_icon_state)

/obj/structure/blob/special/node/take_damage(damage_amount, damage_type = BRUTE, damage_flag = FALSE, sound_effect = TRUE, attack_dir, overmind_reagent_trigger = TRUE)
	. = ..()
	if(atom_integrity > 0)
		hosting?.update_health_hud()

/obj/structure/blob/special/node/process(seconds_per_tick)
	hosting?.update_health_hud()
	if(blob_team)
		pulse_area(claim_range, pulse_range, expand_range)
		reinforce_area(seconds_per_tick)

/obj/structure/blob/special/node/on_changed_z_level(turf/old_turf, turf/new_turf)
	if(hosting && is_station_level(new_turf?.z))
		hosting.forceMove(get_turf(src))
	return ..()

/obj/structure/blob/special/node/handle_ctrl_click(mob/eye/blob/overmind)
	var/non_lesser_click = !istype(overmind, /mob/eye/blob/lesser)
	if(!hosting && non_lesser_click) //base cost of 80, 10 more per lesser overmind we already have
		var/lesser_overmind_cost = 80 + (10 * (length(overmind.antag_team.overminds) - 1))
		if(lesser_overmind_cost > OVERMIND_MAX_POINTS_DEFAULT)
			balloon_alert(overmind, "maximum lesser overminds reached")
			return FALSE

		if(!overmind.buy(lesser_overmind_cost))
			balloon_alert(overmind, "not enough resources, need [lesser_overmind_cost]")
			return FALSE

		if(!spawn_lesser_overmind(overmind))
			balloon_alert(overmind, "no willing ghosts")
			overmind.add_points(lesser_overmind_cost)
			return FALSE
		else
			balloon_alert(overmind, "lesser overmind spawned")
			return TRUE

	var/host_click = hosting == overmind
	if(hosting && (host_click || (non_lesser_click && overmind.antag_team == hosting.antag_team)))
		if(tgui_alert(overmind, "Are you sure you want to offer [host_click ? "Yourself" : "This overmind([hosting])"] to ghosts?", "Ghost offer", list("Yes", "No")) != "Yes")
			return FALSE
		var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
				"Do you want to play as [hosting.real_name], a ghost offered overmind?",
				role = ROLE_BLOB,
				poll_time = 5 SECONDS,
				checked_target = hosting,
				alert_pic = hosting,
				role_name_text = "blob overmind"
			)
		if(chosen_one)
			to_chat(hosting, "Your body has been taken over due to being ghost offered, if you believe this to be an error please ahelp.")
			message_admins("[key_name_admin(chosen_one)] has taken control of ([key_name_admin(hosting)]) to replace a ghost offered player.")
			hosting.ghostize(FALSE)
			hosting.PossessByPlayer(chosen_one.key)
			return TRUE
		else
			to_chat(overmind, "No willing ghosts!")
	return FALSE

/obj/structure/blob/special/node/attempt_removal(mob/eye/blob/overmind)
	if(hosting && (istype(overmind, /mob/eye/blob/lesser) || (tgui_alert(overmind, "This node is currently hosting an overmind, \
				are you sure you want to remove it?(You can offer it to ghosts by control clicking it instead)", "Remove Node", list("Yes", "No")) != "Yes")))
		return FALSE
	overmind.add_points(20) //give them a few extra points for the host
	return ..()

/obj/structure/blob/special/node/proc/spawn_lesser_overmind(mob/eye/blob/overmind)
	var/list/candidates = SSpolling.poll_ghost_candidates(
				"Do you want to play as a lesser overmind for [overmind?.real_name]?",
				role = ROLE_BLOB,
				poll_time = 10 SECONDS,
				alert_pic = hosting,
				role_name_text = "blob overmind"
			)
	if(!length(candidates) || QDELETED(src))
		return FALSE

	var/mob/eye/blob/lesser/new_overmind = new /mob/eye/blob/lesser(get_turf(src), 20, (overmind?.antag_team || blob_team)) //should convert the starting points to a define
	new_overmind.PossessByPlayer(astype(pick(candidates), /mob).key)
	hosting = new_overmind
	return TRUE

/obj/structure/blob/special/node/proc/reinforce_area(seconds_per_tick) // Used by cores and nodes to upgrade their surroundings
	//most strains only have shields
	var/higher_range_type = (strong_reinforce_range > reflector_reinforce_range) ? /obj/structure/blob/shield/core : /obj/structure/blob/shield/reflective/core
	var/lower_range_type
	var/lower_range = 0 //if this needs to be modularized then assoc lists could probably be used(very cursed)
	var/high_range = strong_reinforce_range || reflector_reinforce_range //if only 1 is set then this handles it
	if(strong_reinforce_range && reflector_reinforce_range)
		if(higher_range_type != /obj/structure/blob/shield/reflective/core)
			lower_range = reflector_reinforce_range
			lower_range_type = /obj/structure/blob/shield/reflective/core
		else
			higher_range_type = reflector_reinforce_range
			lower_range = strong_reinforce_range
			high_range = reflector_reinforce_range
			lower_range_type = /obj/structure/blob/shield/core

	if(high_range)
		for(var/obj/structure/blob/normal/tile in range(high_range, src))
			if(SPT_PROB(BLOB_REINFORCE_CHANCE, seconds_per_tick))
				var/selected_type = higher_range_type
				if(lower_range && get_dist(tile, src) <= lower_range)
					selected_type = lower_range_type
				tile.change_to(selected_type, hosting.antag_team)

/obj/structure/blob/special/node/proc/pulse_area(claim_range = 10, pulse_range = 3, expand_range = 2, apply_strain_bonuses = TRUE)
	if(apply_strain_bonuses && blob_team)
		var/datum/blobstrain/strain = blob_team.blobstrain
		var/range_bonus = (src.type == /obj/structure/blob/special/node/core ? strain.core_range_bonus : strain.node_range_bonus)
		claim_range += range_bonus
		pulse_range += range_bonus
		expand_range += range_bonus

	be_pulsed()
	var/expanded = FALSE
	if(prob(70*(1/BLOB_EXPAND_CHANCE_MULTIPLIER)) && expand())
		expanded = TRUE

	var/list/blobs_to_affect = list()
	for(var/obj/structure/blob/to_affect in (claim_range > 8 ? urange(claim_range, src, TRUE) : orange(claim_range, src)))
		blobs_to_affect += to_affect

	shuffle_inplace(blobs_to_affect)
	for(var/obj/structure/blob/affected in blobs_to_affect)
		if(!affected.blob_team)
			affected.set_owner(blob_team)
			affected.update_appearance()
		var/distance = get_dist(get_turf(src), get_turf(affected))
		var/expand_probablity = max(20 - distance * 8, 1)
		if(affected.Adjacent(src))
			expand_probablity = 20
		if(distance <= expand_range)
			var/can_expand = TRUE
			if(length(blobs_to_affect) >= 120 && !(COOLDOWN_FINISHED(affected, heal_timestamp)))
				can_expand = FALSE
			if(can_expand && COOLDOWN_FINISHED(affected, pulse_timestamp) && prob(expand_probablity*BLOB_EXPAND_CHANCE_MULTIPLIER))
				if(!expanded)
					var/obj/structure/blob/new_blob = affected.expand(null, null, !expanded) //expansion falls off with range but is faster near the blob causing the expansion
					if(new_blob)
						expanded = TRUE
		if(distance <= pulse_range)
			affected.be_pulsed()
