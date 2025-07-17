GLOBAL_LIST_EMPTY(bingle_pit_mobs)
GLOBAL_LIST_EMPTY(bingle_mobs)

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
	var/max_item_value = 300
	var/bingles_ready = 0
	var/datum/mind/bingleprime = null
	var/bingle_per_item_value = 30
	var/list/pit_contents_mobs = list()
	var/list/pit_contents_items = list()
	var/ghost_edible = FALSE
	var/static/datum/team/bingles/bingle_team
	var/current_pit_size = 1 // 1 = 1x1, 2 = 2x2, 3 = 3x3 can go higher
	var/list/pit_overlays = list()
	var/last_bingle_spawn_value = 0
	var/last_bingle_poll_value = 0
	var/max_pit_size = 80 // Maximum size (80x80) for the pit

/obj/structure/bingle_hole/examine(mob/user)
	. = .. ()
	if(IS_BINGLE(user) || !isliving(user))
		. += span_alert("The bingle pit has [item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")

/obj/structure/bingle_hole/proc/spit_em_out()
	var/turf/target_turf = get_turf(src)
	if(!target_turf)
		return

	var/area/bingle_pit = GLOB.areas_by_type[/area/station/bingle_pit]
	for(var/atom/movable/thing in bingle_pit?.contents)
		if(QDELETED(thing))
			continue
		thing.forceMove(target_turf)
		var/dir = pick(GLOB.alldirs)
		var/turf/edge = get_edge_target_turf(src, dir)
		if(ismob(thing) || isobj(thing))
			thing.throw_at(edge, rand(1, 5), rand(1, 5))

	// Clear the pit contents lists
	pit_contents_mobs.Cut()
	pit_contents_items.Cut()

/datum/armor/structure_bingle_hole
	energy = 75
	bomb = 95
	bio = 100
	fire = 50
	acid = 80

/obj/structure/bingle_hole/Initialize(mapload)
	. = ..()
	var/datum/antagonist/bingle/prime_antag = locate() in bingleprime?.antag_datums
	if(prime_antag)
		bingle_team = prime_antag.get_team()
	AddComponent(/datum/component/aura_healing, range = 3, simple_heal = 5, limit_to_trait = TRAIT_HEALS_FROM_BINGLE_HOLES, healing_color = COLOR_BLUE_LIGHT)
	START_PROCESSING(SSfastprocess, src)

/obj/structure/bingle_hole/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	spit_em_out()
	// Gib all bingles in the world on pit destruction
	for(var/mob/living/basic/bingle/bingle in GLOB.bingle_mobs)
		bingle?.gib()
	QDEL_LIST(pit_overlays)
	return ..()

/obj/structure/bingle_hole/process(seconds_per_tick)
	for(var/turf/pit in get_all_pit_turfs())
		// Gather items to swallow first, then process them asynchronously
		var/list/to_swallow = list()
		for(var/atom/item in pit.contents)
			if(item == src) // Prevent the pit from swallowing itself
				continue
			if(istype(item, /obj/structure/bingle_pit_overlay)) // Prevent swallowing overlays
				continue
			if(isliving(item))
				if(istype(item, /mob/living/basic/bingle))
					continue
				to_swallow += item
			else if(isitem(item))
				to_swallow += item
		// Async swallow: process one per tick to avoid stutter
		if(length(to_swallow))
			ASYNC
				for(var/atom/A in to_swallow)
					if(QDELETED(A)) continue
					swallow(A)
					CHECK_TICK // Yield to avoid lag

	// Only spawn a new bingle for each 30 item value milestone, and only once per milestone
	// Calculate how many bingles should exist based on current item value
	var/target_bingle_count = round(item_value_consumed / 30)
	var/current_bingle_count = round(last_bingle_spawn_value / 30)

	// If we need more bingles, spawn one
	if(target_bingle_count > current_bingle_count)
		last_bingle_spawn_value = target_bingle_count * 30
		spawn_bingle_from_ghost()

	// Pit grows every 100 item value - calculate target size
	var/desired_pit_size = 1 + round(item_value_consumed / 100)
	desired_pit_size = min(desired_pit_size, max_pit_size)

	if(desired_pit_size > current_pit_size)
		grow_pit(desired_pit_size)

	// Evolve bingles and buff if item_value_consumed >= 100
	if(bingle_team)
		for(var/mob/living/basic/bingle/bong in bingle_team.members)
			if(item_value_consumed >= 100)
				bong.icon_state = "bingle_armored"
				bong.maxHealth = 300
				bong.health = max(bong.health, 300)
				bong.obj_damage = 100
				bong.melee_damage_lower = 30
				bong.melee_damage_upper = 30
				bong.armour_penetration = 20
				bong.evolved = TRUE

			SEND_SIGNAL(bong, BINGLE_EVOLVE)

/obj/structure/bingle_hole/proc/swallow(atom/item)
	// Create falling animation before moving the item
	animate_falling_into_pit(item)

	if(ismob(item))
		var/mob/swallowed_mob = item
		if(item_value_consumed < 100)
			var/dir = pick(GLOB.alldirs)
			var/turf/target = get_edge_target_turf(src, dir)
			swallowed_mob.throw_at(target, rand(1,5), rand(1,5))
			to_chat(swallowed_mob, "The pit has not swallowed enough items to accept creatures yet!")
			return
		if(!(swallowed_mob in pit_contents_mobs))
			pit_contents_mobs += swallowed_mob
			item_value_consumed += 10
		// Delay the actual movement to let animation play
		addtimer(CALLBACK(src, PROC_REF(finish_swallow_mob), swallowed_mob), 1 SECONDS)
	else if(isobj(item))
		var/obj/swallowed_obj = item
		if(!(swallowed_obj in pit_contents_items))
			pit_contents_items += swallowed_obj
			item_value_consumed++
		// Delay the actual movement to let animation play
		addtimer(CALLBACK(src, PROC_REF(finish_swallow_obj), swallowed_obj), 1 SECONDS)

/obj/structure/bingle_hole/proc/animate_falling_into_pit(atom/item)
	if(!item || QDELETED(item))
		return

	var/turf/item_turf = get_turf(item)
	var/turf/pit_turf = get_turf(src)

	if(!item_turf || !pit_turf)
		return

	// Create visual effects
	playsound(item_turf, 'sound/effects/gravhit.ogg', 50, TRUE)

	// Make the item spin and shrink as it falls toward the center
	var/original_transform = item.transform

	// Calculate movement toward pit center
	var/dx = pit_turf.x - item_turf.x
	var/dy = pit_turf.y - item_turf.y

	// Animate the item moving toward pit center while spinning and shrinking
	animate(item, pixel_x = dx * 32, pixel_y = dy * 32, transform = turn(original_transform, 360) * 0.3, alpha = 100, time = 0.8 SECONDS, easing = EASE_IN)

	// Final disappear animation
	animate(transform = turn(original_transform, 720) * 0.1, alpha = 0, time = 0.2 SECONDS, easing = EASE_IN)

	// Create swirling particle effect at the pit
	create_pit_swirl_effect(pit_turf)

/obj/structure/bingle_hole/proc/create_pit_swirl_effect(turf/target_turf)
	// Create a temporary visual effect object for the swirl
	var/obj/effect/temp_visual/bingle_pit_swirl/swirl = new(target_turf)
	swirl.icon = 'icons/effects/effects.dmi'
	swirl.icon_state = "quantum_sparks" // You can change this to a custom swirl icon if you have one
	swirl.layer = ABOVE_MOB_LAYER
	swirl.alpha = 150

	// Animate the swirl effect
	animate(swirl, transform = turn(swirl.transform, 360), time = 1 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS)

	QDEL_IN(swirl, 1.5 SECONDS)

/obj/effect/temp_visual/bingle_pit_swirl
	name = "swirling void"
	desc = "Reality bends around the pit..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "quantum_sparks"
	layer = ABOVE_MOB_LAYER
	duration = 1.5 SECONDS

/obj/structure/bingle_hole/proc/finish_swallow_mob(mob/swallowed_mob)
	if(QDELETED(swallowed_mob))
		return

	// Reset visual effects in case they're still applied
	swallowed_mob.pixel_x = 0
	swallowed_mob.pixel_y = 0
	swallowed_mob.transform = null
	swallowed_mob.alpha = 255

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(bingle_pit_turf)
		swallowed_mob.forceMove(bingle_pit_turf)
	else
		qdel(swallowed_mob)

/obj/structure/bingle_hole/proc/finish_swallow_obj(obj/swallowed_obj)
	if(QDELETED(swallowed_obj))
		return

	// Reset visual effects in case they're still applied
	swallowed_obj.pixel_x = 0
	swallowed_obj.pixel_y = 0
	swallowed_obj.transform = null
	swallowed_obj.alpha = 255

	var/turf/bingle_pit_turf = get_random_bingle_pit_turf()
	if(bingle_pit_turf)
		swallowed_obj.forceMove(bingle_pit_turf)
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

			var/obj/structure/bingle_pit_overlay/overlay = new(T)
			overlay.icon_state = icon_state_to_use
			overlay.parent_pit = src
			pit_overlays += overlay

			// If pit is larger than 3x3, consume walls on these tiles
			if(new_size > 3)
				for(var/obj/O in T)
					if(O.density && istype(O, /obj/structure/) && !istype(O, /obj/structure/bingle_pit_overlay))
						qdel(O)
						item_value_consumed++
				// Remove wall turf itself, if present
				if(istype(T, /turf/closed/wall))
					T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					item_value_consumed++

	current_pit_size = new_size

/obj/structure/bingle_pit_overlay
	name = "bingle pit"
	icon = 'monkestation/code/modules/veth_misc_items/bingle/icons/binglepit.dmi'
	layer = TURF_LAYER + 0.5
	plane = GAME_PLANE
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/obj/structure/bingle_hole/parent_pit = null
	uses_integrity = TRUE

/obj/structure/bingle_pit_overlay/attackby(obj/item/W, mob/user)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attackby(W, user)
	return ..()

/obj/structure/bingle_pit_overlay/attack_hand(mob/user)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_hand(user)
	return ..()

/obj/structure/bingle_pit_overlay/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("You cannot bring yourself to harm the sacred pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_animal(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/attack_basic_mob(mob/living/basic/user, list/modifiers)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("You cannot bring yourself to harm the sacred pit!"))
		return TRUE
	if(parent_pit)
		return parent_pit.attack_basic_mob(user, modifiers)
	return ..()

/obj/structure/bingle_pit_overlay/take_damage(amount, type, source, flags)
	if(istype(source, /mob/living/basic/bingle))
		return FALSE // No damage from bingles
	if(parent_pit)
		parent_pit.take_damage(amount, type, source, flags)
	else
		..()

/obj/structure/bingle_pit_overlay/bullet_act(var/obj/projectile/P)
	if(istype(P.firer, /mob/living/basic/bingle))
		return BULLET_ACT_FORCE_PIERCE // Projectiles from bingles pass through
	if(parent_pit)
		parent_pit.bullet_act(P)
	else
		..()

/obj/structure/bingle_hole/proc/get_all_pit_turfs()
	var/list/turfs = list(get_turf(src))
	for(var/obj/structure/bingle_pit_overlay/O in pit_overlays)
		turfs += get_turf(O)
	return turfs

// Update the spawn proc to ensure proper tracking
/obj/structure/bingle_hole/proc/spawn_bingle_from_ghost()
	var/list/mob/dead/observer/candidates = SSpolling.poll_ghost_candidates(
		question = "Do you want to play as a Bingle?",
		role = ROLE_BINGLE,
		check_jobban = ROLE_BINGLE,
		poll_time = 20 SECONDS,
		alert_pic = /mob/living/basic/bingle,
		role_name_text = "bingle"
	)

	if(!length(candidates))
		return

	var/mob/dead/observer/selected = pick_n_take(candidates)
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/turf/spawn_loc = get_turf(src) // Use the pit's location
	if(isnull(spawn_loc))
		return

	var/mob/living/basic/bingle/bingle = new(spawn_loc)
	// Ensure it's added to global list (should happen in Initialize, but double-check)
	if(!(bingle in GLOB.bingle_mobs))
		GLOB.bingle_mobs += bingle

	player_mind.transfer_to(bingle)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/bingle))
	player_mind.special_role = ROLE_BINGLE
	player_mind.add_antag_datum(/datum/antagonist/bingle)
	if(item_value_consumed >= 100)
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
	for(var/turf/open/open_turf in get_area_turfs(/area/station/bingle_pit))
		if(!open_turf.is_blocked_turf_ignore_climbable())
			eligible_turfs += open_turf
	if(length(eligible_turfs))
		return pick(eligible_turfs)

/area/station/bingle_pit
	name = "bingle pit"
	area_flags = NOTELEPORT | EVENT_PROTECTED | ABDUCTOR_PROOF
	has_gravity = TRUE

/obj/structure/bingle_pit_overlay/examine(mob/user)
	. = ..()
	if(parent_pit)
		. += span_alert("The bingle pit has [parent_pit.item_value_consumed] items in it! Creatures are worth more, but cannot be deposited until 100 item value!")

/obj/structure/bingle_hole/attackby(obj/item/W, mob/user)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return
	return ..()

/obj/structure/bingle_hole/attack_hand(mob/user)
	if(istype(user, /mob/living/basic/bingle))
		to_chat(user, span_warning("Your bingle hands pass harmlessly through the pit!"))
		return
	return ..()
