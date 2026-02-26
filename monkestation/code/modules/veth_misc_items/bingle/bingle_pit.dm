/// Trait used to ensure that things don't get animated as falling in multiple times
#define TRAIT_FALLING_INTO_BINGLE_HOLE "falling_into_bingle_pit"

/obj/structure/bingle_hole
	name = "bingle pit"
	desc = "An all-consuming pit of endless horrors... and bingles."
	armor_type = /datum/armor/structure_bingle_hole
	max_integrity = 500
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	icon_state = "binglepit"
	light_color = LIGHT_COLOR_BABY_BLUE
	light_outer_range = 5
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER + 0.1
	var/item_value_consumed = 0
	var/current_pit_size = 1 // 1 = 1x1, 2 = 2x2, 3 = 3x3 can go higher
	var/list/pit_overlays = list()
	var/last_bingle_spawn_value = 0
	var/max_pit_size = 40 // Maximum size (40x40) for the pit
	var/healing_range = 3
	var/static/datum/team/bingles/bingle_team
	/// Typecache of things that won't be swallowed by the pit.
	var/static/list/swallow_blacklist
	/// Cooldown for taking bomb damage - basically a cheat solution to handle it taking damage for each tile from one bomb.
	COOLDOWN_DECLARE(bomb_cooldown)
	var/announcement_made = FALSE

/obj/structure/bingle_hole/Initialize(mapload)
	..()
	if(isnull(swallow_blacklist))
		swallow_blacklist = typecacheof(list(
			/mob/living/basic/bingle,
			/obj/effect,
			/obj/projectile,
			/obj/structure/bingle_hole,
			/obj/structure/bingle_pit_overlay,
		))
	SSbingle_pit.add_bingle_hole(src)
	ADD_TRAIT(src, TRAIT_PROJECTILE_SINK, INNATE_TRAIT)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bingle_hole/LateInitialize(mapload_arg)
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_BINGLE_PIT)
	log_game("Bingle Pit Template loaded.")

/obj/structure/bingle_hole/Destroy()
	SSbingle_pit.remove_bingle_hole(src)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(eject_bingle_hole_contents), get_turf(src))
	QDEL_LIST(pit_overlays)
	return ..()

/obj/structure/bingle_hole/examine(mob/user)
	. = .. ()
	if(IS_BINGLE(user) || !isliving(user))
		. += span_alert("The bingle pit has [item_value_consumed] items in it!")
		. += span_notice("Creatures are worth more, but cannot be deposited until 100 item value!")

/obj/structure/bingle_hole/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!pass_info.is_living)
		return TRUE
	if(isbingle(pass_info.caller_ref?.resolve()))
		return TRUE
	if(pass_info.thrown || pass_info.incorporeal_move)
		return TRUE
	if(!pass_info.incapacitated)
		if(!pass_info.has_gravity)
			return TRUE
		if(pass_info.movement_type & (FLYING | FLOATING))
			return TRUE
	return FALSE

/obj/structure/bingle_hole/ex_act(severity, target)
	if(!COOLDOWN_FINISHED(src, bomb_cooldown))
		return FALSE
	COOLDOWN_START(src, bomb_cooldown, 2 SECONDS)
	return ..()

/obj/structure/bingle_hole/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	swallow(arrived) // swallow does all the needed checks

/datum/armor/structure_bingle_hole
	energy = 75
	bomb = 99.5
	bio = 100
	fire = 50
	acid = 80

/obj/structure/bingle_hole/process(seconds_per_tick)
	// Only spawn a new bingle for each 30 item value milestone, and only once per milestone
	// Calculate how many bingles should exist based on current item value
	var/target_bingle_count = round(item_value_consumed / 50)
	var/current_bingle_count = round(last_bingle_spawn_value / 50)

	// If we need more bingles, spawn one
	if(target_bingle_count > current_bingle_count)
		last_bingle_spawn_value = target_bingle_count * 50
		INVOKE_ASYNC(src, PROC_REF(spawn_bingle_from_ghost))

	// Pit grows every 100 item value - calculate target size
	var/desired_pit_size = 1 + round(item_value_consumed / 100)
	desired_pit_size = min(desired_pit_size, max_pit_size)

	if(desired_pit_size > current_pit_size)
		grow_pit(desired_pit_size)

	// Evolve bingles and buff if item_value_consumed >= 100
	for(var/mob/living/basic/bingle/bong in bingle_team?.members)
		if(item_value_consumed >= 500)
			bong.icon_state = "bingle_armored"
			bong.maxHealth = 200
			bong.health = 200
			bong.obj_damage = 100
			bong.melee_damage_lower = 15
			bong.melee_damage_upper = 15
			bong.armour_penetration = 10
			bong.evolved = TRUE

		SEND_SIGNAL(bong, COMSIG_LIVING_BINGLE_EVOLVE)

/obj/structure/bingle_hole/proc/swallow_mob(mob/living/victim)
	if(!isliving(victim))
		return FALSE
	if(victim.buckled) // you'll fall in once your buddy falls in
		return FALSE
	if(victim.incorporeal_move)
		return FALSE
	if(victim.body_position == STANDING_UP)
		if(!victim.has_gravity())
			return FALSE
		if(victim.movement_type & (FLYING | FLOATING))
			return FALSE

	if(item_value_consumed < 100)
		var/turf/target = get_edge_target_turf(src, pick(GLOB.alldirs))
		victim.throw_at(target, rand(1, 5), rand(1, 5))
		to_chat(victim, span_warning("The pit has not swallowed enough items to accept creatures yet!"))
		return FALSE
	victim.add_traits(list(TRAIT_FALLING_INTO_BINGLE_HOLE, TRAIT_NO_TRANSFORM), REF(src))
	item_value_consumed += get_item_value(victim)
	// Only animate if we're actually swallowing
	animate_falling_into_pit(victim)
	// Delay the actual movement to let animation play
	addtimer(CALLBACK(src, PROC_REF(finish_swallow_mob), victim), 1 SECONDS)
	return TRUE

/obj/structure/bingle_hole/proc/get_item_value(thing)
	if(isliving(thing))
		return 10
	else if(isstack(thing))
		var/obj/item/stack/stack = thing
		return stack.amount
	else
		return 1

/obj/structure/bingle_hole/proc/swallow_obj(obj/thing)
	if(!isobj(thing))
		return FALSE
	ADD_TRAIT(thing, TRAIT_FALLING_INTO_BINGLE_HOLE, REF(src))
	item_value_consumed += get_item_value(thing)
	for(var/atom/movable/content as anything in thing.get_all_contents(HOLOGRAM_1) - thing) // ensure holograms are ignored!!
		if(QDELETED(content) || HAS_TRAIT(content, TRAIT_FALLING_INTO_BINGLE_HOLE) || isbrain(content))
			continue
		if(isliving(content) || is_type_in_typecache(content, swallow_blacklist))
			content.forceMove(content.drop_location())
		else if(isobj(content))
			item_value_consumed += get_item_value(content)
	// Only animate if we're actually swallowing
	animate_falling_into_pit(thing)
	// Delay the actual movement to let animation play
	addtimer(CALLBACK(src, PROC_REF(finish_swallow_obj), thing), 1 SECONDS)
	return TRUE

/obj/structure/bingle_hole/proc/swallow(atom/movable/item)
	if(QDELETED(src) || QDELETED(item) || item == src)
		return
	if(is_type_in_typecache(item, swallow_blacklist) || (item.flags_1 & HOLOGRAM_1))
		return
	if(HAS_TRAIT(item, TRAIT_FALLING_INTO_BINGLE_HOLE) || HAS_TRAIT(item, TRAIT_NO_TRANSFORM))
		return
	if(item.throwing && item.throwing.target_turf != loc) // you can throw things over the pit
		return
	if(swallow_mob(item) || swallow_obj(item))
		item.pulledby?.stop_pulling()
		item.stop_pulling()
		item.unbuckle_all_mobs()

/obj/structure/bingle_hole/proc/animate_falling_into_pit(atom/movable/item)
	var/turf/item_turf = get_turf(item)
	var/turf/pit_turf = get_turf(src)

	if(isnull(item_turf) || isnull(pit_turf))
		return

	// Create visual effects
	playsound(item_turf, 'sound/effects/gravhit.ogg', 50, TRUE)

	var/original_px = item.pixel_x
	var/original_py = item.pixel_y
	var/original_alpha = item.alpha

	// Make the item spin and shrink as it falls toward the center
	var/original_transform = matrix(item.transform)

	// Calculate movement toward pit center
	var/dx = pit_turf.x - item_turf.x
	var/dy = pit_turf.y - item_turf.y

	// Animate the item moving toward pit center while spinning and shrinking
	animate(item, pixel_x = dx * world.icon_size, pixel_y = dy * world.icon_size, transform = turn(original_transform, 360) * 0.3, alpha = 100, time = 0.8 SECONDS, easing = EASE_IN)

	// Final disappear animation
	animate(transform = turn(original_transform, 720) * 0.1, alpha = 0, time = 0.2 SECONDS, easing = EASE_IN)

	// and ensure they animate back to normal afterwards
	animate(pixel_x = original_px, pixel_y = original_py, alpha = original_alpha, transform = original_transform, time = 0.5 SECONDS, easing = EASE_IN)

	// Create swirling particle effect at the pit
	new /obj/effect/temp_visual/bingle_pit_swirl(pit_turf)

/obj/effect/temp_visual/bingle_pit_swirl
	name = "swirling void"
	desc = "Reality bends around the pit..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "quantum_sparks"
	layer = ABOVE_MOB_LAYER
	duration = 1.5 SECONDS
	alpha = 150

/obj/effect/temp_visual/bingle_pit_swirl/Initialize(mapload)
	. = ..()
	animate(src, transform = turn(transform, 360), time = 1 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS)

/obj/structure/bingle_hole/proc/finish_swallow_mob(mob/living/swallowed_mob)
	if(QDELETED(swallowed_mob))
		return

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(bingle_pit_turf)
		swallowed_mob.forceMove(bingle_pit_turf)
		swallowed_mob.remove_traits(list(TRAIT_FALLING_INTO_BINGLE_HOLE, TRAIT_NO_TRANSFORM), REF(src))
	else
		if(swallowed_mob.client || swallowed_mob.mind)
			swallowed_mob.moveToNullspace()
		else
			qdel(swallowed_mob)

/obj/structure/bingle_hole/proc/finish_swallow_obj(obj/swallowed_obj)
	if(QDELETED(swallowed_obj))
		return

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(bingle_pit_turf)
		swallowed_obj.forceMove(bingle_pit_turf)
		REMOVE_TRAIT(swallowed_obj, TRAIT_FALLING_INTO_BINGLE_HOLE, REF(src))
	else
		qdel(swallowed_obj)

/obj/structure/bingle_hole/proc/grow_pit(new_size)
	if(new_size > max_pit_size)
		new_size = max_pit_size
	if(current_pit_size >= new_size)
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return

	// Remove old overlays
	QDEL_LIST(pit_overlays)

	// If size is 1x1, use the default icon and no overlays
	if(new_size == 1)
		src.icon_state = "binglepit"
		current_pit_size = 1
		healing_range = 3
		return

	src.icon_state = "" // Make the pit itself invisible

	// Calculate coordinates properly for both even and odd sizes
	var/start_coord, end_coord
	if(new_size % 2 == 1) // Odd sizes (1, 3, 5, etc.)
		var/half = (new_size - 1) / 2
		start_coord = -half
		end_coord = half
	else // Even sizes (2, 4, 6, etc.)
		var/half = new_size / 2
		start_coord = -(half - 1)
		end_coord = half

	for(var/dx = start_coord to end_coord)
		for(var/dy = start_coord to end_coord)
			var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
			if(!T)
				continue

			var/icon_state_to_use
			// Corners first (check both dx and dy conditions)
			if(dx == start_coord && dy == end_coord)
				icon_state_to_use = "corner_north"      // top left
			else if(dx == end_coord && dy == end_coord)
				icon_state_to_use = "corner_west"       // top right
			else if(dx == end_coord && dy == start_coord)
				icon_state_to_use = "corner_south"      // bottom right
			else if(dx == start_coord && dy == start_coord)
				icon_state_to_use = "corner_east"       // bottom left
			// Edges (check single conditions)
			else if(dy == end_coord)
				icon_state_to_use = "edge_north"        // top edge
			else if(dy == start_coord)
				icon_state_to_use = "edge_south"        // bottom edge
			else if(dx == start_coord)
				icon_state_to_use = "edge_west"         // left edge
			else if(dx == end_coord)
				icon_state_to_use = "edge_east"         // right edge
			// Center fill
			else
				icon_state_to_use = "filler"

			var/obj/structure/bingle_pit_overlay/overlay = new(T, src)
			overlay.icon_state = icon_state_to_use
			pit_overlays += overlay

			// If pit is larger than 3x3, consume walls on these tiles
			if(new_size > 3)
				for(var/obj/thing in T)
					if(thing.density && isstructure(thing) && !istype(thing, /obj/structure/bingle_pit_overlay))
						swallow(thing)
				// Remove wall turf itself, if present
				if(iswallturf(T))
					T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					item_value_consumed++
				if(!announcement_made)
					priority_announce("The blue tide has been detected upon [station_name()]. All personnel must stop the consumption of the station.", "Biohazard Alert", ANNOUNCER_OUTBREAK5)
					announcement_made = TRUE
	current_pit_size = new_size
	healing_range = max(round(new_size / 2, 1) + 2, 3)

/obj/structure/bingle_pit_overlay
	name = "bingle pit"
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	layer = TURF_LAYER + 0.5
	plane = GAME_PLANE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	uses_integrity = TRUE
	var/obj/structure/bingle_hole/parent_pit

/obj/structure/bingle_pit_overlay/Initialize(mapload, obj/structure/bingle_hole/parent_pit)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	src.parent_pit = parent_pit
	ADD_TRAIT(src, TRAIT_PROJECTILE_SINK, INNATE_TRAIT)

/obj/structure/bingle_pit_overlay/Destroy()
	parent_pit?.pit_overlays -= src
	parent_pit = null
	return ..()

/obj/structure/bingle_pit_overlay/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	return parent_pit.CanAStarPass(to_dir, pass_info)

/obj/structure/bingle_pit_overlay/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		parent_pit.on_entered(source, arrived)

/obj/structure/bingle_pit_overlay/ex_act(severity, target)
	return parent_pit.ex_act(severity, target)

/obj/structure/bingle_pit_overlay/attackby(obj/item/W, mob/user)
	if(isbingle(user))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attackby(W, user)
	return ..()

/obj/structure/bingle_pit_overlay/attack_hand(mob/user)
	if(isbingle(user))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_hand(user)
	return ..()

/obj/structure/bingle_pit_overlay/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(isbingle(user))
		to_chat(user, span_warning("You cannot bring yourself to harm the sacred pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_animal(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/attack_basic_mob(mob/living/basic/user, list/modifiers)
	if(isbingle(user))
		to_chat(user, span_warning("You cannot bring yourself to harm the sacred pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_basic_mob(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/take_damage(amount, type, source, flags)
	if(isbingle(source))
		return FALSE // No damage from bingles
	if(parent_pit)
		parent_pit.take_damage(amount, type, source, flags)
	else
		..()

/obj/structure/bingle_pit_overlay/bullet_act(obj/projectile/projectile)
	if(isbingle(projectile.firer))
		return BULLET_ACT_FORCE_PIERCE // Projectiles from bingles pass through
	if(parent_pit)
		return parent_pit.bullet_act(projectile)
	else
		return ..()

// Update the spawn proc to ensure proper tracking
/obj/structure/bingle_hole/proc/spawn_bingle_from_ghost()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		question = "<span class='ooc'>Do you want to play as a Bingle?</span>\
		\n<span class='boldnotice'>You will return to your previous body on conclusion.</span>",
		role = ROLE_BINGLE,
		check_jobban = ROLE_BINGLE,
		poll_time = 20 SECONDS,
		ignore_category = POLL_IGNORE_BINGLE,
		alert_pic = icon(/mob/living/basic/bingle::icon, /mob/living/basic/bingle::icon_state, SOUTH),
		role_name_text = "bingle"
	)

	if(!length(candidates) || QDELETED(src))
		return

	var/turf/spawn_loc = get_turf(src) // Use the pit's location
	if(isnull(spawn_loc))
		return

	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/ghost_mind = selected.mind
	ghost_mind?.active = TRUE

	var/mob/living/basic/bingle/bingle = new(spawn_loc, src)
	bingle.PossessByPlayer(selected.key)

	if(ghost_mind)
		bingle.AddComponent(/datum/component/temporary_body, ghost_mind, ghost_mind.current, TRUE)

	var/datum/mind/antag_mind = bingle.mind
	antag_mind.add_antag_datum(/datum/antagonist/bingle)

	if(item_value_consumed >= 500)
		bingle.icon_state = "bingle_armored"
		bingle.maxHealth = 300
		bingle.health = max(bingle.health, 300)
		bingle.obj_damage = 100
		bingle.melee_damage_lower = 15
		bingle.melee_damage_upper = 20
		bingle.armour_penetration = 20
		bingle.evolved = TRUE
	message_admins("[ADMIN_LOOKUPFLW(bingle)] has been made into Bingle (pit spawn).")
	log_game("[key_name(bingle)] was spawned as Bingle by the pit.")

/obj/structure/bingle_hole/proc/get_random_bingle_pit_turf()
	var/list/eligible_turfs = list()
	for(var/turf/open/open_turf in get_area_turfs(/area/misc/bingle_pit))
		if(!open_turf.is_blocked_turf_ignore_climbable())
			eligible_turfs += open_turf
	if(length(eligible_turfs))
		return pick(eligible_turfs)

/obj/structure/bingle_pit_overlay/examine(mob/user)
	. = ..()
	if(parent_pit)
		. += span_alert("The bingle pit has [parent_pit.item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")

/obj/structure/bingle_hole/attackby(obj/item/W, mob/user)
	if(isbingle(user))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return
	return ..()

/obj/structure/bingle_hole/attack_hand(mob/user)
	if(isbingle(user))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return
	return ..()

/proc/eject_bingle_hole_contents(turf/target_turf)
	if(!target_turf)
		return

	var/area/bingle_pit = GLOB.areas_by_type[/area/misc/bingle_pit]
	for(var/atom/movable/thing in bingle_pit?.contents)
		thing.forceMove(target_turf)
		if(QDELETED(thing))
			continue
		var/dir = pick(GLOB.alldirs)
		var/turf/edge = get_edge_target_turf(target_turf, dir)
		thing.throw_at(edge, rand(1, 5), rand(1, 5))
		CHECK_TICK

/area/misc/bingle_pit
	name = "Bingle Pit"
	area_flags = NOTELEPORT | EVENT_PROTECTED | ABDUCTOR_PROOF | ALWAYS_VALID_BLOODSUCKER_LAIR | UNIQUE_AREA
	has_gravity = TRUE
	requires_power = FALSE
	static_lighting = TRUE

#undef TRAIT_FALLING_INTO_BINGLE_HOLE
