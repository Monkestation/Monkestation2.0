/// Places the core itself
/mob/eye/blob/proc/place_blob_core(placement_override = BLOB_NORMAL_PLACEMENT, pop_override = FALSE)
	if(placed && placement_override != BLOB_FORCE_PLACEMENT)
		return TRUE

	if(placement_override == BLOB_NORMAL_PLACEMENT)
		if(!pop_override && !check_core_visibility())
			return FALSE
		var/turf/placement = get_turf(src)
		if(placement.density)
			to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
			return FALSE
		if(!is_valid_turf(placement))
			to_chat(src, span_warning("You cannot place your core here!"))
			return FALSE
		if(!check_objects_tile(placement))
			return FALSE
		if(!pop_override && world.time <= manualplace_min_time && world.time <= autoplace_max_time)
			to_chat(src, span_warning("It is too early to place your blob core!"))
			return FALSE
	else
		if(placement_override == BLOB_RANDOM_PLACEMENT)
			var/turf/force_tile = pick(GLOB.blobstart)
			forceMove(force_tile) //got overrided? you're somewhere random, motherfucker

	if(placed && blob_core)
		blob_core.forceMove(loc)
	else
		var/obj/structure/blob/special/node/core/core = new(get_turf(src), antag_team, TRUE)
		core.hosting = src
		antag_team.blobs_legit++
		blob_core = core
		core.update_appearance()

	update_health_hud()
	placed = TRUE
	antag_team?.announcement_time = world.time + OVERMIND_ANNOUNCEMENT_MAX_TIME
	return TRUE

/// Places important blob structures
/mob/eye/blob/proc/create_special(obj/structure/blob/created_type, price = created_type::point_cost, needs_node = FALSE, min_separation = 0, turf/tile)
	if(!tile)
		tile = get_turf(src)
	var/obj/structure/blob/blob = (locate(/obj/structure/blob) in tile)
	if(!blob)
		to_chat(src, span_warning("There is no blob here!"))
		balloon_alert(src, "no blob here!")
		return null
	if(!istype(blob, /obj/structure/blob/normal))
		to_chat(src, span_warning("Unable to use this blob, find a normal one."))
		balloon_alert(src, "need normal blob!")
		return null
	if(needs_node)
		var/area/area = get_area(src)
		if(!(area.area_flags & BLOBS_ALLOWED)) //factory and resource blobs must be legit
			to_chat(src, span_warning("This type of blob must be placed on the station!"))
			balloon_alert(src, "can't place off-station!")
			return null
		if(nodes_required && !(locate(/obj/structure/blob/special/node) in orange(BLOB_NODE_PULSE_RANGE, tile)))
			to_chat(src, span_warning("You need to place this blob closer to a node or core!"))
			balloon_alert(src, "too far from node or core!")
			return null //handholdotron 2000
	if(min_separation)
		for(var/obj/structure/blob/other_blob in orange(min_separation, tile))
			if(other_blob.type == created_type)
				to_chat(src, span_warning("There is a similar blob nearby, move more than [min_separation] tiles away from it!"))
				other_blob.balloon_alert(src, "too close!")
				return null
	if(!buy(price))
		return null
	var/obj/structure/blob/node = blob.change_to(created_type, antag_team)
	return node

/// Toggles requiring nodes
/mob/eye/blob/proc/toggle_node_req()
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, span_warning("You now require a nearby node or core to place factory and resource blobs."))
	else
		to_chat(src, span_warning("You no longer require a nearby node or core to place factory and resource blobs."))

/// Preliminary check before polling ghosts.
/mob/eye/blob/proc/create_blobbernaut()
	var/turf/current_turf = get_turf(src)
	var/obj/structure/blob/special/factory/factory = locate(/obj/structure/blob/special/factory) in current_turf
	if(!factory)
		to_chat(src, span_warning("You must be on a factory blob!"))
		return FALSE
	if(factory.blobbernaut || factory.is_creating_blobbernaut) //if it already made or making a blobbernaut, it can't do it again
		to_chat(src, span_warning("This factory blob is already sustaining a blobbernaut."))
		return FALSE
	if(factory.get_integrity() < factory.max_integrity * 0.5)
		to_chat(src, span_warning("This factory blob is too damaged to sustain a blobbernaut."))
		return FALSE
	if(!buy(BLOBMOB_BLOBBERNAUT_RESOURCE_COST))
		return FALSE

	factory.is_creating_blobbernaut = TRUE
	to_chat(src, span_notice("You attempt to produce a blobbernaut."))
	pick_blobbernaut_candidate(factory)

/// Polls ghosts to get a blobbernaut candidate.
/mob/eye/blob/proc/pick_blobbernaut_candidate(obj/structure/blob/special/factory/factory)
	if(!factory)
		return

	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		"Do you want to play as a [antag_team.blobstrain.name] blobbernaut?",
		check_jobban = ROLE_BLOB,
		role = ROLE_BLOB,
		poll_time = 5 SECONDS,
		alert_pic = /mob/living/basic/blob_minion/blobbernaut/minion,
		role_name_text = "blobbernaut"
	)

	if(!length(candidates))
		to_chat(src, span_warning("You could not conjure a sentience for your blobbernaut. Your points have been refunded. Try again later."))
		add_points(BLOBMOB_BLOBBERNAUT_RESOURCE_COST)
		factory.assign_blobbernaut(null)
		return FALSE

	var/mob/living/basic/blob_minion/blobbernaut/minion/blobber = new(get_turf(factory))
	antag_team.make_minion(blobber)
	factory.assign_blobbernaut(blobber)
	var/mob/dead/observer/player = pick(candidates)
	blobber.assign_key(player.key, antag_team.blobstrain)
	RegisterSignal(blobber, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_blobbernaut_attacked))

/// When one of our boys attacked something, we sometimes want to perform extra effects
/mob/eye/blob/proc/on_blobbernaut_attacked(mob/living/basic/blobbynaut, atom/target, success) //move this over to the team
	SIGNAL_HANDLER
	if(!success || !isliving(target))
		return
	antag_team.blobstrain.blobbernaut_attack(target, blobbynaut)

/// Searches the tile for a blob structure and removes it.
/mob/eye/blob/proc/remove_blob(turf/tile)
	var/obj/structure/blob/blob = locate() in tile
	if(!blob)
		to_chat(src, span_warning("There is no blob there!"))
		return FALSE

	if(blob.point_return < 0)
		to_chat(src, span_warning("Unable to remove this blob."))
		return FALSE

	return blob.attempt_removal(src)

/// Expands to nearby tiles
/mob/eye/blob/proc/expand_blob(turf/tile)
	if(world.time < last_attack)
		return FALSE

	var/list/possible_blobs = list()
	for(var/obj/structure/blob/blob in range(tile, 1))
		possible_blobs += blob

	if(!length(possible_blobs))
		to_chat(src, span_warning("There is no blob adjacent to the target tile!"))
		return FALSE

	if(!buy(BLOB_EXPAND_COST))
		return FALSE

	var/attack_success
	for(var/mob/living/target in tile)
		if(!target.can_blob_attack() || (ROLE_BLOB in target.faction) || target.stat == DEAD)
			continue

		attack_success = TRUE
		antag_team.blobstrain.attack_living(target, possible_blobs)

	var/obj/structure/blob/blob = locate() in tile
	if(blob)
		if(attack_success) //if we successfully attacked a turf with a blob on it, only give an attack refund
			blob.blob_attack_animation(tile, src)
			add_points(BLOB_ATTACK_REFUND)
		else
			to_chat(src, span_warning("There is a blob there!"))
			add_points(BLOB_EXPAND_COST) //otherwise, refund all of the cost
	else
		directional_attack(tile, possible_blobs, attack_success)

	if(attack_success)
		last_attack = world.time + CLICK_CD_MELEE
	else
		last_attack = world.time + CLICK_CD_RAPID

/proc/create_blob_tile(turf/tile, obj/structure/blob/created, obj/structure/blob/created_from, mob/eye/blob/creator, needs_node = FALSE, price = created::point_cost, min_separation = 0)
	if(!tile)
		tile = get_turf(creator || created_from)
		if(!tile)
			return FALSE

	//are we converting from one tile type to another
	var/converting = (created_from && get_turf(created_from) == tile && !(created_from.type == created || istype(created_from, /obj/structure/blob/special)))
	if(needs_node)
		if((converting && !created_from.legit) || !(astype(tile.loc, /area).area_flags & BLOBS_ALLOWED))
			if(creator)
				to_chat(creator, span_warning("This type of blob must be placed on the station!"))
				creator.balloon_alert(creator, "can't place off-station!")
			return FALSE

		//currently ignores creator.nodes_required as its not actually used anywhere
		if(!(locate(/obj/structure/blob/special/node) in orange(BLOB_NODE_PULSE_RANGE, tile)))
			if(creator)
				to_chat(creator, span_warning("You need to place this blob closer to a node or core!"))
				creator.balloon_alert(creator, "too far from node or core!")
			return FALSE

	if(min_separation)
		for(var/obj/structure/blob/other_blob in orange(min_separation, tile))
			if(other_blob.type == created)
				if(creator)
					to_chat(creator, span_warning("There is a similar blob nearby, move more than [min_separation] tiles away from it!"))
					other_blob.balloon_alert(creator, "too close!")
				return FALSE

	if(creator && !creator.buy(price))
		return FALSE

	if(converting)
		return created_from.change_to(created, creator.antag_team)
	return new created(tile, (creator?.antag_team || created_from?.blob_team))
