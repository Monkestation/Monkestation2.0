/// The particle numbers below are tuned for a stream this many tiles long.
#define VACUUM_STREAM_BASE_TILES 3

/// Swirls that fly back toward the user.
/particles/vacuum_suction
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("curl" = 2, "dot" = 3)
	width = 256
	height = 256
	count = 60
	spawning = 8
	lifespan = 0.6 SECONDS
	fadein = 0.1 SECONDS
	fade = 0.2 SECONDS
	// drawn pointing north, the stream effect turns it to face wherever you clicked
	position = generator(GEN_BOX, list(-16, 32, 0), list(16, 96, 0), UNIFORM_RAND)
	velocity = list(0, -12)
	bound1 = list(-1000, 0, -1000)
	spin = generator(GEN_NUM, -20, 20, UNIFORM_RAND)
	gradient = list(0, "#ffb3e6", 1, "#b3f0ff", 2, "#fff3b3", "loop")
	color = generator(GEN_NUM, 0, 3, UNIFORM_RAND)

/// Stretches the stream to cover this many tiles.
/particles/vacuum_suction/proc/scale_to_range(tiles)
	var/scale = tiles / VACUUM_STREAM_BASE_TILES
	if(scale == 1)
		return
	width = round(256 * scale, 1)
	height = round(256 * scale, 1)
	count = round(60 * scale, 1)
	spawning = 8 * scale
	position = generator(GEN_BOX, list(-16, 32, 0), list(16, tiles * ICON_SIZE_Y, 0), UNIFORM_RAND)
	velocity = list(0, -12 * scale)

/// Sparkles on whatever is being sucked up.
/particles/vacuum_sparkles
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = "cross"
	width = 64
	height = 64
	count = 10
	spawning = 1
	lifespan = 0.4 SECONDS
	fade = 0.2 SECONDS
	position = generator(GEN_CIRCLE, 0, 10, UNIFORM_RAND)
	gradient = list(0, "#ffb3e6", 1, "#b3f0ff", 2, "#fff3b3", "loop")
	color = generator(GEN_NUM, 0, 3, UNIFORM_RAND)

/// The suction particles, turned to face the aim angle.
/obj/effect/temp_visual/vacuum_suction_stream
	duration = 1.2 SECONDS
	randomdir = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/vacuum_suction_stream/Initialize(mapload, aim_angle, reach_tiles = VACUUM_STREAM_BASE_TILES)
	. = ..()
	var/particles/vacuum_suction/stream = new
	stream.scale_to_range(reach_tiles)
	particles = stream
	var/matrix/aim = matrix()
	aim.Turn(aim_angle)
	particles.transform = aim
	// stop spawning early so the last swirls finish flying in instead of blinking out
	addtimer(VARSET_CALLBACK(particles, spawning, 0), duration - particles.lifespan)

/obj/effect/temp_visual/vacuum_suction_stream/Destroy()
	particles = null
	return ..()

/// Pulls extracts within 45 degrees of the aim toward the user.
/obj/item/vacuum_pack/proc/suck_extracts(atom/target, mob/living/user)
	if(!COOLDOWN_FINISHED(src, extract_suction_cooldown) || !can_use_nozzle(user, feedback = TRUE))
		return
	COOLDOWN_START(src, extract_suction_cooldown, 1 SECONDS)
	var/turf/user_turf = get_turf(user)
	extract_pitch_count = 0
	var/aim_angle = start_suction(target, user)

	// yoink extracts from monkeys
	for(var/mob/living/carbon/monkey in range(capture_range, user))
		if(monkey == user || !ismonkeybasic(monkey))
			continue
		if(monkey.loc != user_turf)
			if(abs(closer_angle_difference(aim_angle, get_angle(user, monkey))) > 45)
				continue
			if(!CheckToolReach(nozzle, monkey, capture_range))
				continue
		for(var/obj/item/slime_extract/extract in monkey.held_items)
			monkey.dropItemToGround(extract)

	var/found = FALSE
	for(var/obj/item/slime_extract/extract in range(capture_range, user))
		if(!isturf(extract.loc) || extract.anchored || pulled_extracts[extract])
			continue
		if(extract.loc == user_turf)
			found = TRUE
			extract_arrived(extract, user)
			continue
		if(abs(closer_angle_difference(aim_angle, get_angle(user, extract))) > 45)
			continue
		if(!CheckToolReach(nozzle, extract, capture_range))
			continue
		found = TRUE
		start_extract_pull(extract, user)
	if(!found)
		balloon_alert(user, "no extracts!")

/// Faces the target and plays the stream. Returns the aim angle.
/obj/item/vacuum_pack/proc/start_suction(atom/target, mob/living/user)
	user.face_atom(target)
	playsound(nozzle, 'sound/items/vacuum/vacuum_use.ogg', 40, falloff_exponent = 4)
	var/turf/user_turf = get_turf(user)
	var/aim_angle = get_turf(target) == user_turf ? dir2angle(user.dir) : get_angle(user, target)
	new /obj/effect/temp_visual/vacuum_suction_stream(user_turf, aim_angle, capture_range)
	return aim_angle

/obj/item/vacuum_pack/proc/play_ploop(atom/source, pitch = 1)
	playsound(source, 'sound/items/vacuum/vacuum_ploop.ogg', vol = 40, frequency = pitch)

/// Plays the stream and puts sparkles on the creature.
/obj/item/vacuum_pack/proc/start_mob_suction(mob/living/target, mob/living/user)
	start_suction(target, user)
	target.add_shared_particles(/particles/vacuum_sparkles)

/obj/item/vacuum_pack/proc/stop_mob_suction(mob/living/target)
	target.remove_shared_particles(/particles/vacuum_sparkles)

/// Makes the extract fly over to the user.
/obj/item/vacuum_pack/proc/start_extract_pull(obj/item/slime_extract/extract, mob/living/user)
	var/datum/move_loop/loop = SSmove_manager.home_onto(extract, user, delay = 0.1 SECONDS, timeout = 2 SECONDS, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!loop)
		return
	pulled_extracts[extract] = loop
	RegisterSignal(loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(on_extract_pull_step))
	RegisterSignals(loop, list(COMSIG_MOVELOOP_STOP, COMSIG_QDELETING), PROC_REF(on_extract_pull_stopped))
	RegisterSignal(extract, COMSIG_MOVABLE_MOVED, PROC_REF(on_pulled_extract_moved))
	RegisterSignal(extract, COMSIG_QDELETING, PROC_REF(on_pulled_extract_deleted))
	extract.add_shared_particles(/particles/vacuum_sparkles)
	extract.SpinAnimation(0.4 SECONDS, loops = 2)

/// Takes the extract in once it reaches the user's tile.
/obj/item/vacuum_pack/proc/on_extract_pull_step(datum/move_loop/has_target/source)
	SIGNAL_HANDLER
	var/mob/living/user = source.target
	if(get_turf(source.moving) != get_turf(user))
		return
	extract_arrived(source.moving, user)
	return MOVELOOP_SKIP_STEP

/obj/item/vacuum_pack/proc/on_extract_pull_stopped(datum/move_loop/source)
	SIGNAL_HANDLER
	end_extract_pull(source.moving)

/obj/item/vacuum_pack/proc/on_pulled_extract_moved(obj/item/slime_extract/source)
	SIGNAL_HANDLER
	if(!isturf(source.loc))
		end_extract_pull(source)

/obj/item/vacuum_pack/proc/on_pulled_extract_deleted(obj/item/slime_extract/source)
	SIGNAL_HANDLER
	end_extract_pull(source)

/// Stops pulling an extract, and cleans up its signals and sparkles.
/obj/item/vacuum_pack/proc/end_extract_pull(obj/item/slime_extract/extract)
	var/datum/move_loop/loop = pulled_extracts[extract]
	if(!loop)
		return
	pulled_extracts -= extract
	UnregisterSignal(loop, list(COMSIG_MOVELOOP_PREPROCESS_CHECK, COMSIG_MOVELOOP_STOP, COMSIG_QDELETING))
	UnregisterSignal(extract, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	extract.remove_shared_particles(/particles/vacuum_sparkles)
	if(!QDELETED(loop))
		qdel(loop)

/obj/item/vacuum_pack/proc/stop_extract_pulls()
	for(var/extract in pulled_extracts)
		end_extract_pull(extract)

/// Stores the extract. If we're full it tries a xeno bag, and if that's a no-go it just drops.
/obj/item/vacuum_pack/proc/extract_arrived(obj/item/slime_extract/extract, mob/living/user)
	end_extract_pull(extract)
	// bloop~ bloop~~ bloop~~~ bloop~~~!
	var/pitch = min(1 + 0.1 * extract_pitch_count, 2)
	extract_pitch_count++
	play_ploop(user, pitch)
	if(length(stored_extracts()) < extract_capacity())
		extract.forceMove(src)
		return
	var/obj/item/storage/bag/xeno/bag = astype(user.get_inactive_held_item())
	if(isnull(bag))
		var/static/list/slots_to_check = list(ITEM_SLOT_SUITSTORE, ITEM_SLOT_BELT, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET)
		for(var/slot in slots_to_check)
			var/obj/item/item_in_slot = user.get_item_by_slot(slot)
			if(istype(item_in_slot, /obj/item/storage/bag/xeno))
				bag = item_in_slot
				break
		if(isnull(bag) && istype(user.pulling, /obj/item/storage/bag/xeno))
			bag = user.pulling
	if(bag?.atom_storage?.attempt_insert(extract, user))
		return
	extract.pixel_x = extract.base_pixel_x + rand(-6, 6)
	extract.pixel_y = extract.base_pixel_y + rand(-6, 6)

#undef VACUUM_STREAM_BASE_TILES
