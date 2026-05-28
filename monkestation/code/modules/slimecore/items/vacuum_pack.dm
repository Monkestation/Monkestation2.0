#define NORMAL_VACUUM_PACK_CAPACITY 3
#define UPGRADED_VACUUM_PACK_CAPACITY 6
#define ILLEGAL_VACUUM_PACK_CAPACITY 12

#define NORMAL_VACUUM_PACK_RANGE 3
#define UPGRADED_VACUUM_PACK_RANGE 4
#define ILLEGAL_VACUUM_PACK_RANGE 5

#define NORMAL_VACUUM_PACK_SPEED 12
#define UPGRADED_VACUUM_PACK_SPEED 8
#define ILLEGAL_VACUUM_PACK_SPEED 6

#define VACUUM_PACK_UPGRADE_STASIS "stasis"
#define VACUUM_PACK_UPGRADE_HEALING "healing"
#define VACUUM_PACK_UPGRADE_CAPACITY "capacity"
#define VACUUM_PACK_UPGRADE_RANGE "range"
#define VACUUM_PACK_UPGRADE_SPEED "speed"
#define VACUUM_PACK_UPGRADE_PACIFY "pacification"
#define VACUUM_PACK_UPGRADE_BIOMASS "biomass printer"

/datum/action/item_action/toggle_nozzle
	name = "Toggle Vacuum Nozzle"

/obj/item/slime_vacuum
	name = "slime vacuum"
	desc = "A large nozzle that sucks in slimes."
	icon = 'monkestation/code/modules/slimecore/icons/equipment.dmi'
	icon_state = "vacuum_nozzle"
	inhand_icon_state = "vacuum_nozzle"
	lefthand_file = 'monkestation/code/modules/slimecore/icons/mister_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/slimecore/icons/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = NOBLUDGEON | ABSTRACT
	slot_flags = NONE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Conversion list of type to name for examine.
	var/static/list/name_of_mobs = list(
		/mob/living/carbon/human/species/monkey = "monkey",
		/mob/living/basic/cockroach/rockroach = "rock roach",
		/mob/living/basic/cockroach/iceroach = "ice roach",
		/mob/living/basic/xenofauna/meatbeast = "meat beast",
		/mob/living/basic/xenofauna/diyaab = "diyaab",
		/mob/living/basic/xenofauna/thinbug = "thin bug",
		/mob/living/basic/cockroach/recursive = "recursive roach",
		/mob/living/basic/xenofauna/thoom = "thoom",
		/mob/living/basic/xenofauna/greeblefly = "greeblefly",
		/mob/living/basic/xenofauna/lavadog = "lava dog",
		/mob/living/basic/xenofauna/voxslug = "strange slug",
		/mob/living/basic/xenofauna/possum = "possum",
		/mob/living/basic/xenofauna/dron = "semi-organic bug",
	)
	/// The mob we have selected with attack_self_alternate.
	var/selected_creature = /mob/living/carbon/human/species/monkey // Shoot monkeys by default until something else is chosen.
	/// Can this item be used by itself to do what it intends to do?
	var/requires_nozzle = FALSE
	/// The nozzle that is attached to our vacuum, if we ever use one.
	var/obj/item/vacuum_nozzle/nozzle
	/// Type of nozzle that is created on initialize, if we ever use one.
	var/nozzle_type
	/// List of mobs that are stored inside the vacuum.
	var/list/stored = list()
	/// How many mobs can be stored inside the vacuum?
	var/capacity = NORMAL_VACUUM_PACK_CAPACITY
	/// How far away the vacuum can pick up mobs?
	var/range = NORMAL_VACUUM_PACK_RANGE
	/// How fast the vacuum picks up mobs?
	var/speed = NORMAL_VACUUM_PACK_SPEED
	/// Is the vacuum illegal? This disables the user's ability to toggle selective mode at will.
	var/illegal = FALSE
	/// Should they shoot their selected creature on left click?
	var/selective_mode = TRUE
	/// Is the user currently selecting from the radical menu of targets?
	var/selecting_radial_target = FALSE
	/// List of upgrades installed
	var/list/upgrades = list()
	/// The biomass recycler we are linked to.
	var/obj/machinery/biomass_recycler/linked
	/// Has this been modified to fight revenants?
	var/modified = FALSE
	/// Stores the revenant we're currently sucking in.
	var/mob/living/basic/revenant/ghost_busting
	/// Stores the user.
	var/mob/living/ghost_buster
	/// Stores visual effects.
	var/busting_beam
	COOLDOWN_DECLARE(busting_throw_cooldown)

/obj/item/slime_vacuum/Destroy()
	linked = null
	if(VACUUM_PACK_UPGRADE_HEALING in upgrades)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/slime_vacuum/process(seconds_per_tick)
	if(!(VACUUM_PACK_UPGRADE_HEALING in upgrades))
		return PROCESS_KILL

	for(var/mob/living/basic/animal in stored)
		animal.adjustBruteLoss(-5 * seconds_per_tick)

/obj/item/slime_vacuum/examine(mob/user)
	. = ..()
	if(LAZYLEN(stored))
		. += span_notice("It has [LAZYLEN(stored)] creatures stored in it.")
	if(LAZYLEN(upgrades))
		for(var/upgrade in upgrades)
			. += span_notice("It has \a [upgrade] upgrade installed.")
	if(requires_nozzle)
		return
	. += get_nozzle_examine()

/obj/item/slime_vacuum/equipped(mob/user, slot, initial)
	. = ..()
	if(requires_nozzle)
		return
	handle_signal_registration(user)

/obj/item/slime_vacuum/dropped(mob/user, silent)
	. = ..()
	if(requires_nozzle)
		return
	handle_signal_unregistration(user)

/obj/item/slime_vacuum/attack_self(mob/user, modifiers)
	. = ..()
	toggle_selective_mode(user)

/obj/item/slime_vacuum/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if(requires_nozzle)
		return
	var/chosen_creature = choose_selected_creature(user, src)
	if(!chosen_creature)
		return
	selected_creature = chosen_creature

/obj/item/slime_vacuum/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(requires_nozzle && (QDELETED(nozzle) || nozzle.loc == src))
		return NONE
	if(!do_suck(interacting_with, user))
		return NONE
	return ITEM_INTERACT_SUCCESS

/obj/item/slime_vacuum/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(requires_nozzle && (QDELETED(nozzle) || nozzle.loc == src))
		return NONE
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/slime_vacuum/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(requires_nozzle && (QDELETED(nozzle) || nozzle.loc == src))
		return NONE

	if(modified && ghost_busting && interacting_with != ghost_busting && COOLDOWN_FINISHED(src, busting_throw_cooldown))
		ghost_busting.throw_at(get_turf(interacting_with), get_dist(ghost_busting, interacting_with), 3, user)
		COOLDOWN_START(src, busting_throw_cooldown, 3 SECONDS)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!linked)
		to_chat(user, span_warning("[src] is not linked to the biomass recycler!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!(VACUUM_PACK_UPGRADE_BIOMASS in upgrades))
		to_chat(user, span_warning("[src] does not possess the required upgrade to create creatures!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!selected_creature)
		to_chat(user, span_warning("[src] doesn't have a selected creature!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(linked.stored_matter < linked.vacuum_printable_types[selected_creature])
		to_chat(user, span_warning("[linked] does not have enough stored biomass for that! It currently has [linked.stored_matter] out of [src.linked.vacuum_printable_types[selected_creature]] unit\s required."))
		return FALSE

	var/atom/movable/spawned = new selected_creature(user.loc)
	spawned.AddComponent(/datum/component/vac_tagged, user)

	linked.stored_matter -= linked.vacuum_printable_types[selected_creature]
	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spawned.transform = matrix().Scale(0.5)
	spawned.alpha = 0
	animate(spawned, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)

	if(isturf(user.loc))
		ADD_TRAIT(spawned, VACPACK_THROW, "vacpack")
		spawned.pass_flags |= PASSMOB
		spawned.throw_at(interacting_with, min(get_dist(user, interacting_with), (illegal ? 5 : 11)), 1, user, gentle = TRUE) // Gentle so that eggs have 50% instead of 12.5% to spawn a chick.

	var/launcher_name = requires_nozzle ? nozzle.name : src.name
	user.visible_message(span_warning("[user] shoots [spawned] out their [launcher_name]!"), span_notice("You fabricate and shoot [spawned] out of your [launcher_name]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/slime_vacuum/multitool_act(mob/living/user, obj/item/tool)
	modified = !modified
	to_chat(user, span_notice("You turn the safety switch on [src] [modified ? "off" : "on"]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/slime_vacuum/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/disk/vacuum_upgrade))
		return NONE

	var/obj/item/disk/vacuum_upgrade/upgrade = tool
	if(illegal)
		to_chat(user, span_warning("[src] has no slot to insert [upgrade] into!"))
		return ITEM_INTERACT_BLOCKING
	if(upgrade.upgrade_type in upgrades)
		to_chat(user, span_warning("[src] already has a [upgrade.upgrade_type] upgrade!"))
		return ITEM_INTERACT_BLOCKING
	upgrades += upgrade.upgrade_type
	upgrade.on_upgrade(src)
	to_chat(user, span_notice("You install a [upgrade.upgrade_type] upgrade into [src]."))
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)
	qdel(upgrade)
	return ITEM_INTERACT_SUCCESS

/obj/item/slime_vacuum/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/disk/vacuum_upgrade))
		return item_interaction(user, interacting_with, modifiers)
	if(istype(interacting_with, /obj/machinery/biomass_recycler))
		if(!(VACUUM_PACK_UPGRADE_BIOMASS in src.upgrades))
			to_chat(user, span_warning("[src] does not possess the required upgrade to link with \the [interacting_with]."))
			return ITEM_INTERACT_BLOCKING
		linked = interacting_with
		to_chat(user, span_notice("You link [src] to [interacting_with]."))
		return ITEM_INTERACT_SUCCESS
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/// Registers signals associated with the item.
/obj/item/slime_vacuum/proc/handle_signal_registration(mob/user)
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(on_user_altclick), override = TRUE)

/// Unregisters signals associated with the item.
/obj/item/slime_vacuum/proc/handle_signal_unregistration(mob/user)
	UnregisterSignal(user, COMSIG_MOB_ALTCLICKON)
	selecting_radial_target = FALSE

/// Ttoggles selective mode if they are allowed to.
/obj/item/slime_vacuum/proc/toggle_selective_mode(mob/user)
	if(illegal)
		return
	selective_mode = !selective_mode
	var/mode_desc = selective_mode ? "selectively" : "indiscriminately"
	visible_message(
		span_notice("[user] switches \the [src] to fire [mode_desc]."),
		span_notice("You switch \the [src] to fire [mode_desc]."),
		span_hear("You hear a click.")
	)

/// Offers a radial menu to select what creature to shoot out.
/obj/item/slime_vacuum/proc/choose_selected_creature(mob/user, atom/radial_anchor)
	if(!linked)
		user.balloon_alert(user, "needs to be linked to biomass recycler!")
		return

	var/list/items = list()
	var/list/item_names = list()
	for(var/printable_type in GLOB.biomass_unlocks)
		linked.vacuum_printable_types |= printable_type
		linked.vacuum_printable_types[printable_type] = GLOB.biomass_unlocks[printable_type]
	for(var/printable_type in linked.vacuum_printable_types)
		var/atom/movable/printable = printable_type
		var/image/printable_image = image(icon = initial(printable.icon), icon_state = initial(printable.icon_state))
		items += list(initial(printable.name) = printable_image)
		item_names[initial(printable.name)] = printable_type

	var/pick = show_radial_menu(user, radial_anchor || src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)

	if(!pick)
		return FALSE

	var/spawn_type = item_names[pick]
	if(linked.stored_matter < linked.vacuum_printable_types[spawn_type])
		to_chat(user, span_warning("[linked] does not have enough stored biomass for that! It currently has [linked.stored_matter] out of [linked.vacuum_printable_types[spawn_type]] unit\s required."))
		return FALSE

	return spawn_type

/// Gets additional examine information for its nozzle.
/obj/item/slime_vacuum/proc/get_nozzle_examine()
	. = list()
	if(!illegal)
		. += span_notice("Activate to change firing modes. Currently set to [selective_mode ? "selective" : "indiscriminate"].")
	else
		. += span_notice("It is hotwired to fire [selective_mode ? "selectively" : "indiscriminately"].")
	if(!linked)
		return
	. += span_notice("Right click in hand to select the type of creature to spawn.")
	. += span_info("It is currently set to spawn a [name_of_mobs[selected_creature]].")
	. += span_info("It has [linked.stored_matter] unit\s of biomass.")


/// Tries to suck our target.
/obj/item/slime_vacuum/proc/do_suck(atom/movable/target, mob/user)
	if(ghost_busting)
		return FALSE

	if(modified && !ghost_busting && isrevenant(target) && get_dist(user, target) < 4)
		start_busting(target, user)
		return TRUE

	if(!isliving(target))
		spew_contents(target, user)
		return TRUE

	var/mob/living/living_target = target
	if(isslime(living_target))
		if(get_dist(user, living_target) > range)
			to_chat(user, span_warning("[living_target] is too far away!"))
			return FALSE
		if(!(living_target in view(user, range)))
			to_chat(user, span_warning("You can't reach [living_target]!"))
			return FALSE
		if(living_target.anchored || living_target.move_resist > MOVE_FORCE_STRONG)
			to_chat(user, span_warning("You can't manage to suck [living_target] in!"))
			return FALSE
		if(HAS_TRAIT(living_target, TRAIT_SLIME_RABID) && !illegal && !(VACUUM_PACK_UPGRADE_PACIFY in upgrades))
			to_chat(user, span_warning("[living_target] is wiggling far too much for you to suck it in!"))
			return FALSE
		if(LAZYLEN(stored) >= capacity)
			to_chat(user, span_warning("[src] is already filled to the brim!"))
			return FALSE
		if(!do_after(user, speed, living_target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(suck_checks), living_target, user)))
			return FALSE
		if(LAZYLEN(stored) >= capacity) // This is checked again after the do_after because otherwise you can bypass the cap by clicking fast enough
			return FALSE
		if(SEND_SIGNAL(living_target, COMSIG_LIVING_VACUUM_PRESUCK, src, user) & COMPONENT_LIVING_VACUUM_CANCEL_SUCK)
			return FALSE
		suck_victim(living_target, user)
		return TRUE

	if(linked && (living_target.type in linked.recyclable_types))
		if(get_dist(user, living_target) > range)
			to_chat(user, span_warning("[living_target] is too far away!"))
			return FALSE
		if(!(living_target in view(user, range)))
			to_chat(user, span_warning("You can't reach [living_target]!"))
			return FALSE
		if(living_target.anchored || living_target.move_resist > MOVE_FORCE_STRONG)
			to_chat(user, span_warning("You can't manage to suck [living_target] in!"))
			return FALSE
		if(ismonkey(living_target)) // Snowflake that blocks recycling healthy monkeys
			var/mob/living/carbon/human/species/monkey/target_monkey = living_target
			if(target_monkey.stat == CONSCIOUS)
				to_chat(user, span_warning("[target_monkey] is struggling far too much for you to suck it in!"))
				return FALSE

		living_target.buckled?.unbuckle_mob(living_target, force = TRUE)
		living_target.unbuckle_all_mobs(force = TRUE)
		if(!do_after(user, speed, living_target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
			return FALSE
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		var/matrix/animation_matrix = matrix()
		animation_matrix.Scale(0.5)
		animation_matrix.Translate((user.x - living_target.x) * 32, (user.y - living_target.y) * 32)
		animate(living_target, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, transform = animation_matrix, flags = ANIMATION_PARALLEL)
		sleep(0.8 SECONDS)
		user.visible_message(span_warning("[user] sucks [living_target] into their [name]!"), span_notice("You successfully suck [living_target] into your [name] and recycle it."))
		qdel(living_target)
		playsound(user, 'sound/machines/juicer.ogg', 50, TRUE)
		linked.use_energy(500 JOULES)
		linked.stored_matter += linked.cube_production * linked.recyclable_types[living_target.type]
		return TRUE


/// Shoots out whatever is stored inside the vacuum.
/obj/item/slime_vacuum/proc/spew_contents(atom/movable/target, mob/user)
	if(LAZYLEN(stored) <= 0)
		to_chat(user, span_warning("[src] is empty!"))
		return

	var/mob/living/spewed
	if(!selective_mode)
		spewed = pick(stored)
	else
		var/list/items = list()
		var/list/items_stored = list()
		for(var/atom/movable/stored_obj in src.stored)
			var/image/stored_image = image(icon = stored_obj.icon, icon_state = stored_obj.icon_state)
			stored_image.color = stored_obj.color
			items += list(stored_obj.name = stored_image)
			items_stored[stored_obj.name] = stored_obj
		var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
		if(!pick)
			return
		spewed = items_stored[pick]

	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spewed.transform = matrix().Scale(0.5)
	spewed.alpha = 0
	animate(spewed, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)
	spewed.forceMove(user.loc)

	if(isturf(user.loc))
		ADD_TRAIT(spewed, VACPACK_THROW, "vacpack")
		spewed.pass_flags |= PASSMOB
		spewed.throw_at(target, min(get_dist(user, target), (src.illegal ? 5 : 11)), 1, user)
		if(prob(99) && spewed.stat != DEAD)
			playsound(spewed, 'sound/misc/woohoo.ogg', 50, TRUE)

	if(isslime(spewed))
		var/mob/living/basic/slime/slime = spewed
		slime.slime_flags &= ~STORED_SLIME
		slime.ai_controller?.reset_ai_status()
		if(VACUUM_PACK_UPGRADE_STASIS in upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")
		if(illegal)
			ADD_TRAIT(slime, TRAIT_SLIME_RABID, "syndicate_slimepack")
			user.changeNext_move(CLICK_CD_RAPID) //Like a machine gun
		else if(VACUUM_PACK_UPGRADE_PACIFY in upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_RABID, null)

	stored -= spewed

	var/launcher_name = requires_nozzle && !QDELETED(nozzle) && nozzle != src ? nozzle.name : src.name
	user.visible_message(span_warning("[user] shoots [spewed] out their [launcher_name]!"), span_notice("You shoot [spewed] out of your [launcher_name]."))

/obj/item/slime_vacuum/proc/suck_victim(atom/movable/target, mob/user, silent = FALSE)
	if(!suck_checks(target, user))
		return

	target.ai_controller?.set_ai_status(AI_STATUS_OFF)
	target.ai_controller?.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, null)
	if(!silent)
		playsound(user, 'sound/effects/refill.ogg', 50, TRUE)
	var/matrix/animation_matrix = target.transform
	animation_matrix.Scale(0.5)
	animation_matrix.Translate((user.x - target.x) * 32, (user.y - target.y) * 32)
	animate(target, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, transform = animation_matrix, flags = ANIMATION_PARALLEL)
	sleep(0.8 SECONDS)
	target.unbuckle_all_mobs(force = TRUE)
	target.forceMove(src)
	stored += target

	SEND_SIGNAL(target, COMSIG_ATOM_SUCKED)
	if(!silent)
		user.visible_message(span_warning("[user] sucks [target] into their [name]!"), span_notice("You successfully suck [target] into your [name]."))

	if(!isslime(target))
		return
	var/mob/living/basic/slime/slime = target
	slime.slime_flags |= STORED_SLIME
	if((VACUUM_PACK_UPGRADE_STASIS in upgrades))
		ADD_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")

/obj/item/slime_vacuum/proc/start_busting(mob/living/basic/revenant/revenant, mob/living/user)
	revenant.visible_message(span_warning("[user] starts sucking [revenant] into their [src.name]!"), span_userdanger("You are being sucked into [user]'s [src.name]!"))
	ghost_busting = revenant
	ghost_buster = user
	busting_beam = user.Beam(revenant, icon_state = "drain_life")
	bust_the_ghost()

/obj/item/slime_vacuum/proc/bust_the_ghost()
	while(check_busting())
		if(!do_after(ghost_buster, 0.5 SECONDS, target = ghost_busting, extra_checks = CALLBACK(src, PROC_REF(check_busting)), timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE))
			ghost_busting = null
			ghost_buster = null
			QDEL_NULL(busting_beam)
			return
		ghost_busting.adjust_health(5)
		ghost_busting.apply_status_effect(/datum/status_effect/revenant/revealed, 0.5 SECONDS)

/obj/item/slime_vacuum/proc/check_busting()
	if(isnull(ghost_busting?.loc) || QDELING(ghost_busting))
		return FALSE

	if(isnull(ghost_buster?.loc) || QDELING(ghost_buster))
		return FALSE

	if(loc != ghost_buster)
		return FALSE

	if(get_dist(ghost_buster, ghost_busting) > range)
		return FALSE

	if(ghost_busting.essence <= 0) //Means that the revenant is dead
		return FALSE

	return TRUE

/obj/item/slime_vacuum/proc/on_user_altclick(mob/living/user, atom/movable/target)
	SIGNAL_HANDLER
	if(!isliving(user) || user != loc)
		UnregisterSignal(user, COMSIG_MOB_ALTCLICKON)
		return
	if(selecting_radial_target || user.incapacitated())
		return
	if(requires_nozzle)
		if(QDELETED(nozzle) || nozzle == src)
			return
	else if(user.get_active_held_item() != src)
		return
	. = COMSIG_MOB_CANCEL_CLICKON // Avoids loot panel showing up.
	selecting_radial_target = TRUE
	ASYNC
		select_suck_target(user, target)
		selecting_radial_target = FALSE

/obj/item/slime_vacuum/proc/select_suck_target(mob/living/user, atom/movable/target)
	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		return
	if(get_dist(user, target_turf) > range)
		user.balloon_alert(user, "out of range!")
		return
	var/list/options = list()
	for(var/atom/movable/thing as anything in target_turf)
		if(!isslime(thing) && !(thing.type in linked?.recyclable_types))
			continue
		var/mutable_appearance/copied_appearance = copy_appearance_filter_overlays(thing.appearance)
		copied_appearance.dir = SOUTH
		copied_appearance.pixel_x = thing.base_pixel_x
		copied_appearance.pixel_y = thing.base_pixel_y
		copied_appearance.pixel_w = 0 /* thing.base_pixel_w */
		copied_appearance.pixel_z = 0 /* thing.base_pixel_z */
		options[thing] = copied_appearance
	if(!length(options))
		user.balloon_alert(user, "no valid targets on turf!")
		return
	var/chosen = show_radial_menu(
		user,
		user,
		options,
		radius = 40,
		custom_check = CALLBACK(src, PROC_REF(suck_radial_checks), user, target_turf),
		tooltips = TRUE,
		autopick_single_option = FALSE,
	)
	if(chosen)
		do_suck(chosen, user)

/// Additional checks for sucking targets into the backpack.
/obj/item/slime_vacuum/proc/suck_checks(atom/movable/target, mob/user)
	if(get_dist(user, target) > range)
		return FALSE
	if(!(target in view(user, range)))
		return FALSE
	if(target.anchored || target.move_resist > MOVE_FORCE_STRONG)
		return FALSE
	if(isslime(target))
		var/mob/living/basic/slime/slime = target
		if(HAS_TRAIT(slime, TRAIT_SLIME_RABID) && !illegal && !(VACUUM_PACK_UPGRADE_PACIFY in upgrades))
			return FALSE
	if(LAZYLEN(stored) >= capacity)
		return FALSE
	return TRUE

/// Additional checks for the suck radial menu that must be passed to be kept open.
/obj/item/slime_vacuum/proc/suck_radial_checks(mob/living/user, turf/target_turf)
	if(user.incapacitated())
		return FALSE
	if(!CAN_THEY_SEE(target_turf, user))
		return FALSE
	if(requires_nozzle)
		if(QDELETED(nozzle) || nozzle == src)
			return FALSE
	else if(user.get_active_held_item() != src)
		return FALSE
	return TRUE

/obj/item/slime_vacuum/backpack
	name = "backpack xenofauna storage"
	desc = "A Xynergy Solutions brand vacuum xenofauna storage with an extendable nozzle. Do not use to practice kissing."
	icon = 'monkestation/code/modules/slimecore/icons/equipment.dmi'
	icon_state = "vacuum_pack"
	inhand_icon_state = "vacuum_pack"
	worn_icon_state = "waterbackpackjani"
	lefthand_file = 'monkestation/code/modules/slimecore/icons/backpack_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/slimecore/icons/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	actions_types = list(/datum/action/item_action/toggle_nozzle)
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF
	requires_nozzle = TRUE
	nozzle_type = /obj/item/vacuum_nozzle

/obj/item/slime_vacuum/backpack/Initialize(mapload)
	. = ..()
	nozzle = new nozzle_type(src)

/obj/item/slime_vacuum/backpack/Destroy()
	QDEL_NULL(nozzle)
	return ..()

/obj/item/slime_vacuum/backpack/dropped(mob/user)
	..()
	remove_nozzle()

/obj/item/slime_vacuum/backpack/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_BACK)
		remove_nozzle()

/obj/item/slime_vacuum/backpack/attack_hand(mob/user, list/modifiers)
	if(user.get_item_by_slot(user.getBackSlot()) != src)
		return ..()
	toggle_nozzle(user)

/obj/item/slime_vacuum/backpack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == nozzle)
		remove_nozzle()
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/slime_vacuum/backpack/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	var/mob/wearer = loc
	if(istype(wearer) && istype(over, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over
		wearer.putItemFromInventoryInHandIfPossible(src, hand.held_index)
	return ..()

/obj/item/slime_vacuum/backpack/ui_action_click(mob/user)
	toggle_nozzle(user)

/obj/item/slime_vacuum/backpack/proc/toggle_nozzle(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return

	if(user.get_item_by_slot(user.getBackSlot()) != src)
		to_chat(user, span_warning("[src] must be worn properly to use!"))
		return

	if(QDELETED(nozzle))
		nozzle = new nozzle_type(src)

	if(!(nozzle in src))
		remove_nozzle()
		return

	if(!user.put_in_hands(nozzle))
		to_chat(user, span_warning("You need a free hand to hold [nozzle]!"))
		return

	playsound(user, 'sound/mecha/mechmove03.ogg', 75, TRUE)

/obj/item/slime_vacuum/backpack/proc/remove_nozzle()
	if(QDELETED(nozzle))
		return
	if(ismob(nozzle.loc))
		var/mob/wearer = nozzle.loc
		wearer.temporarilyRemoveItemFromInventory(nozzle, TRUE)
		playsound(loc, 'sound/mecha/mechmove03.ogg', 75, TRUE)
	nozzle.forceMove(src)

/obj/item/vacuum_nozzle
	name = "vacuum pack nozzle"
	desc = "A large nozzle attached to a vacuum pack."
	icon = 'monkestation/code/modules/slimecore/icons/equipment.dmi'
	icon_state = "vacuum_nozzle"
	inhand_icon_state = "vacuum_nozzle"
	lefthand_file = 'monkestation/code/modules/slimecore/icons/mister_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/slimecore/icons/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = NOBLUDGEON | ABSTRACT
	slot_flags = NONE
	/// The vacuum pack this nozzle is from.
	var/obj/item/slime_vacuum/backpack/pack

/obj/item/vacuum_nozzle/Initialize(mapload)
	. = ..()
	pack = loc
	if(!istype(pack))
		return INITIALIZE_HINT_QDEL

/obj/item/vacuum_nozzle/examine(mob/user)
	. = ..()
	. += pack.get_nozzle_examine()

/obj/item/vacuum_nozzle/equipped(mob/user, slot, initial)
	. = ..()
	pack.handle_signal_registration(user)

/obj/item/vacuum_nozzle/dropped(mob/user, silent)
	. = ..()
	pack.handle_signal_unregistration(user)

/obj/item/vacuum_nozzle/doMove(atom/destination)
	if(destination && (destination != pack.loc || !ismob(destination)))
		if (loc != pack)
			to_chat(pack.loc, span_notice("[src] snaps back onto [pack]."))
		destination = pack
		pack.selecting_radial_target = FALSE
	. = ..()

/obj/item/vacuum_nozzle/attack_self(mob/user, modifiers)
	. = ..()
	pack.toggle_selective_mode(user)

/obj/item/vacuum_nozzle/attack_self_secondary(mob/user, modifiers)
	. = ..()
	var/chosen_creature = pack.choose_selected_creature(user, src)
	if(!chosen_creature)
		return
	pack.selected_creature = chosen_creature

/obj/item/vacuum_nozzle/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return pack.do_suck(interacting_with, user)

/obj/item/vacuum_nozzle/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return pack.ranged_interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/vacuum_nozzle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return pack.interact_with_atom(interacting_with, user, modifiers)

/obj/item/vacuum_nozzle/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return pack.interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/disk/vacuum_upgrade
	name = "vacuum pack upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage."
	icon_state = "rndmajordisk"
	var/upgrade_type

/obj/item/disk/vacuum_upgrade/proc/on_upgrade(obj/item/slime_vacuum/vaccum)

/obj/item/disk/vacuum_upgrade/stasis
	name = "vacuum pack stasis upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to keep all slimes inside of it in stasis."
	upgrade_type = VACUUM_PACK_UPGRADE_STASIS

/obj/item/disk/vacuum_upgrade/healing
	name = "vacuum pack healing upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that makes the pack passively heal all the slimes inside of it."
	upgrade_type = VACUUM_PACK_UPGRADE_HEALING

/obj/item/disk/vacuum_upgrade/healing/on_upgrade(obj/item/slime_vacuum/vaccum)
	START_PROCESSING(SSobj, src)

/obj/item/disk/vacuum_upgrade/capacity
	name = "vacuum pack capacity upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that expands it's internal slime storage."
	upgrade_type = VACUUM_PACK_UPGRADE_CAPACITY

/obj/item/disk/vacuum_upgrade/capacity/on_upgrade(obj/item/slime_vacuum/vaccum)
	vaccum.capacity = UPGRADED_VACUUM_PACK_CAPACITY

/obj/item/disk/vacuum_upgrade/range
	name = "vacuum pack range upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that strengthens it's pump and allows it to reach further."
	upgrade_type = VACUUM_PACK_UPGRADE_RANGE

/obj/item/disk/vacuum_upgrade/range/on_upgrade(obj/item/slime_vacuum/vaccum)
	vaccum.range = UPGRADED_VACUUM_PACK_RANGE

/obj/item/disk/vacuum_upgrade/speed
	name = "vacuum pack speed upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that upgrades it's motor and allows it to suck slimes up faster."
	upgrade_type = VACUUM_PACK_UPGRADE_SPEED

/obj/item/disk/vacuum_upgrade/speed/on_upgrade(obj/item/slime_vacuum/vaccum)
	vaccum.speed = UPGRADED_VACUUM_PACK_SPEED

/obj/item/disk/vacuum_upgrade/pacification
	name = "vacuum pack pacification upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to pacify all stored slimes."
	upgrade_type = VACUUM_PACK_UPGRADE_PACIFY

/obj/item/disk/vacuum_upgrade/biomass
	name = "vacuum pack biomass printer upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to automatically recycle dead biomass and make living creatures on right click."
	upgrade_type = VACUUM_PACK_UPGRADE_BIOMASS

/obj/item/slime_vacuum/backpack/syndicate
	name = "modified backpack xenofauna storage"
	desc = "An illegally modified vacuum backpack xenofauna storage that has much more power, capacity and will make every slime it shoots out rabid."
	icon_state = "vacuum_pack_syndicate"
	inhand_icon_state = "vacuum_pack_syndicate"
	range = ILLEGAL_VACUUM_PACK_RANGE
	capacity = ILLEGAL_VACUUM_PACK_CAPACITY
	speed = ILLEGAL_VACUUM_PACK_SPEED
	illegal = TRUE
	nozzle_type = /obj/item/vacuum_nozzle/syndicate
	upgrades = list(VACUUM_PACK_UPGRADE_HEALING, VACUUM_PACK_UPGRADE_STASIS, VACUUM_PACK_UPGRADE_BIOMASS)
	selective_mode = FALSE

/obj/item/vacuum_nozzle/syndicate
	name = "modified vacuum pack nozzle"
	desc = "A large black and red nozzle attached to a vacuum pack."
	icon_state = "vacuum_nozzle_syndicate"
	inhand_icon_state = "vacuum_nozzle_syndicate"

#undef NORMAL_VACUUM_PACK_CAPACITY
#undef UPGRADED_VACUUM_PACK_CAPACITY
#undef ILLEGAL_VACUUM_PACK_CAPACITY

#undef NORMAL_VACUUM_PACK_RANGE
#undef UPGRADED_VACUUM_PACK_RANGE
#undef ILLEGAL_VACUUM_PACK_RANGE

#undef NORMAL_VACUUM_PACK_SPEED
#undef UPGRADED_VACUUM_PACK_SPEED
#undef ILLEGAL_VACUUM_PACK_SPEED

#undef VACUUM_PACK_UPGRADE_STASIS
#undef VACUUM_PACK_UPGRADE_HEALING
#undef VACUUM_PACK_UPGRADE_CAPACITY
#undef VACUUM_PACK_UPGRADE_RANGE
#undef VACUUM_PACK_UPGRADE_SPEED
#undef VACUUM_PACK_UPGRADE_PACIFY
#undef VACUUM_PACK_UPGRADE_BIOMASS
