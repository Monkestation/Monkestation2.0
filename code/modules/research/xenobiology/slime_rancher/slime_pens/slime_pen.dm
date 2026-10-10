GLOBAL_LIST_EMPTY(slime_pens)

/// Is this slime in a pen? (or it left one less than 10 minutes ago, close enough)
/mob/living/basic/slime/proc/is_ranched()
	return pen || !COOLDOWN_FINISHED(src, pen_expiry_cooldown)

/// slime food doesn't need to screech in your ear for the whole shift
/datum/idle_behavior/idle_monkey/penned
	common_emotes = list(
		"scratch",
		"jump",
		"roll",
		"tail",
	)

/// handles a single slime pen and tracks the slimes in it
/datum/slime_pen
	/// Slimes in the pen rn, null when it's empty
	var/list/slimes
	/// The tiles inside the pen
	var/list/turf/turfs = list()
	/// The four corner posts
	var/list/obj/structure/slime_pen_post/posts = list()
	/// The fence bits around the edge
	var/list/obj/structure/slime_pen_barrier/barriers = list()
	/// Fence color, as a hex string
	var/barrier_color = SLIME_PEN_DEFAULT_COLOR
	/// Pen size in tiles (pen size... hahaha)
	var/width = 0
	/// Same as width, but north to south
	var/height = 0

/datum/slime_pen/New(list/turf/interior, list/obj/structure/slime_pen_post/new_posts)
	GLOB.slime_pens += src
	posts = new_posts.Copy()
	for(var/obj/structure/slime_pen_post/post as anything in posts)
		post.pen = src
		post.update_construction_markers()
		if(post.barrier_color)
			barrier_color = post.barrier_color
		RegisterSignals(post, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_piece_lost))
	var/list/xs = list()
	var/list/ys = list()
	for(var/turf/spot as anything in interior)
		add_turf(spot)
		xs += spot.x
		ys += spot.y
	width = max(xs) - min(xs) + 1
	height = max(ys) - min(ys) + 1
	build_barriers()
	START_PROCESSING(SSxenobio, src)

/datum/slime_pen/Destroy(force)
	STOP_PROCESSING(SSxenobio, src)
	GLOB.slime_pens -= src
	for(var/atom/movable/piece as anything in barriers + posts)
		UnregisterSignal(piece, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	QDEL_LIST(barriers)
	for(var/obj/structure/slime_pen_post/post as anything in posts)
		post.pen = null
		post.update_construction_markers()
	posts = null
	for(var/turf/turf as anything in turfs)
		remove_turf(turf)
	// cleaning up all turfs SHOULD remove all slimes, but this is BYOND, "should" doesn't mean jack shit, so better safe than sorry
	for(var/mob/living/basic/slime/slime as anything in slimes)
		stop_tracking_slime(slime)
	turfs = null
	return ..()

/datum/slime_pen/process(seconds_per_tick)
	for(var/turf/turf as anything in turfs)
		for(var/mob/living/carbon/human/monke in turf)
			if(!ismonkeybasic(monke) || monke.stat != DEAD || monke.ckey || monke.mind || monke.pulledby)
				continue
			if((monke.timeofdeath + (5 MINUTES)) <= world.time && !monke.get_filter("dust_animation")) // stupid janky way of avoiding dusting the same chimp repeatedly while the dusting animation is ongoing
				monke.visible_message(span_warning("[monke] is automatically dissolved by the slime corral."))
				monke.dust(just_ash = TRUE, drop_items = TRUE)

/datum/slime_pen/proc/track_slime(mob/living/basic/slime/slime)
	SIGNAL_HANDLER
	if(!isslime(slime))
		CRASH("somehow tried to add something that isn't a slime as a slime in a pen")
	if(QDELING(slime) || (slime in slimes) || !(slime.loc in turfs) || QDELETED(src))
		return
	LAZYADD(slimes, slime)
	slime.pen = src
	RegisterSignal(slime, COMSIG_QDELETING, PROC_REF(stop_tracking_slime))
	RegisterSignal(slime, COMSIG_MOVABLE_MOVED, PROC_REF(slime_moved))

/// Forgets about a slime, and starts its 10 minute pen_expiry_cooldown
/datum/slime_pen/proc/stop_tracking_slime(mob/living/basic/slime/slime)
	SIGNAL_HANDLER
	if(isnull(slime) || !(slime in slimes))
		return
	UnregisterSignal(slime, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED))
	LAZYREMOVE(slimes, slime)
	// the pen next door's Entered runs before our Moved, so it may have already claimed this one
	if(slime.pen != src)
		return
	slime.pen = null
	COOLDOWN_START(slime, pen_expiry_cooldown, 10 MINUTES)

/datum/slime_pen/proc/slime_moved(mob/living/basic/slime/slime, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(!(slime.loc in turfs))
		stop_tracking_slime(slime)

/// Adds a tile, plus any slimes already sitting on it
/datum/slime_pen/proc/add_turf(turf/new_turf)
	if(!isturf(new_turf))
		CRASH("somehow tried to add a non-turf as a slime pen turf")
	if(new_turf in turfs)
		return
	RegisterSignals(new_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(check_entered))
	turfs += new_turf
	for(var/mob/living/basic/slime/slime in new_turf)
		track_slime(slime)

/// Drops a tile, and forgets any slimes on it
/datum/slime_pen/proc/remove_turf(turf/old_turf)
	if(!isturf(old_turf))
		CRASH("somehow tried to remove a non-turf from the slime pen turfs?")
	if(!(old_turf in turfs))
		return
	UnregisterSignal(old_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	turfs -= old_turf
	for(var/mob/living/basic/slime/slime in old_turf)
		stop_tracking_slime(slime)

/// Keeps tabs on slimes that wander in, and tells monkeys to stfu
/datum/slime_pen/proc/check_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isslime(arrived))
		track_slime(arrived)
		return
	var/mob/living/penned_monkey = arrived
	if(!ismonkeybasic(penned_monkey) || !istype(penned_monkey.ai_controller, /datum/ai_controller/monkey) || penned_monkey.ai_controller.blackboard[BB_MONKEY_PENNED])
		return
	penned_monkey.ai_controller.idle_behavior = new /datum/idle_behavior/idle_monkey/penned
	penned_monkey.ai_controller.set_blackboard_key(BB_MONKEY_PENNED, TRUE)

/// actually sets up the fence piece and such
/datum/slime_pen/proc/build_barriers()
	for(var/turf/spot as anything in turfs)
		for(var/direction in GLOB.cardinals)
			if(get_step(spot, direction) in turfs)
				continue
			// side pieces on the top row need the little connector that closes the corner join
			var/top_row = (direction & (EAST|WEST)) && !(get_step(spot, NORTH) in turfs)
			var/obj/structure/slime_pen_barrier/barrier = new(spot, direction, top_row)
			barriers += barrier
			apply_color(barrier)
			RegisterSignals(barrier, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_piece_lost))

/// if we somehow manage to lose a barrier piece - which we SHOULDN'T - pen goes kablooey
/datum/slime_pen/proc/on_piece_lost(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/slime_pen/proc/set_barrier_color(new_color)
	barrier_color = new_color
	for(var/obj/structure/slime_pen_barrier/barrier as anything in barriers)
		apply_color(barrier)

/datum/slime_pen/proc/apply_color(obj/structure/slime_pen_barrier/barrier)
	barrier.set_barrier_color(barrier_color)

/datum/slime_pen/ui_data(mob/user)
	var/list/slime_data = list()
	for(var/mob/living/basic/slime/slime as anything in slimes)
		var/list/possible_mutations = list()
		for(var/datum/slime_mutation/mutation as anything in slime.mutation_progress)
			var/progress = "unfed"
			if(mutation.is_satisfied())
				progress = "ready"
			else if(mutation.has_progress())
				progress = "partial"
			possible_mutations += list(list(
				"type" = "[mutation.type]",
				"progress" = progress,
			))
		slime_data += list(list(
			"ref" = REF(slime),
			"name" = slime.name,
			"health" = round(slime.health / slime.maxHealth * 100, 1),
			"nutrition" = floor(slime.nutrition),
			"life_stage" = slime.life_stage,
			"amount_grown" = slime.amount_grown,
			"color" = slime.slime_type.color,
			"color_hex" = slime.slime_type.rgb_code,
			"possible_mutations" = possible_mutations,
			"sprite_icon" = get_icon_dmi_path(slime),
			"sprite_state" = slime.icon_state,
			"mood_state" = (!slime.stat && slime.current_mood && slime.current_mood != SLIME_MOOD_NONE) ? "aslime-[slime.current_mood]" : null,
			"transparent" = slime.slime_type.transparent,
		))
	return list(
		"slimes" = slime_data,
		"barrier_color" = barrier_color,
	)

/datum/slime_pen/ui_static_data(mob/user)
	var/list/mutation_types = list()
	for(var/datum/slime_mutation/mutation_type as anything in subtypesof(/datum/slime_mutation))
		var/datum/slime_type/mutates_into = mutation_type::mutates_into
		mutation_types["[mutation_type]"] = list(
			"color" = "[mutates_into::color]",
			"color_hex" = "[mutates_into::rgb_code]",
		)
	return list(
		"mutation_types" = mutation_types,
		"width" = width,
		"height" = height,
		"soft_capacity" = ceil(length(turfs) * 2),
		"max_nutrition" = SLIME_MAX_NUTRITION,
		"nutrition_hungry" = SLIME_HUNGER_NUTRITION,
		"nutrition_starving" = SLIME_STARVE_NUTRITION,
		"growth_threshold" = SLIME_EVOLUTION_THRESHOLD,
		"default_color" = SLIME_PEN_DEFAULT_COLOR,
	)
