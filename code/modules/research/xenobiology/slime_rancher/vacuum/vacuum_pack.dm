/// Slimes a pack holds before upgrades.
#define VACUUM_BASE_CAPACITY 5
/// How far the suction reaches in tiles, before upgrades.
#define VACUUM_BASE_CAPTURE_RANGE 3
/// How long it takes to suck something up, before upgrades.
#define VACUUM_BASE_CAPTURE_DELAY (1 SECONDS)

/datum/action/item_action/toggle_vacuum_nozzle
	name = "Toggle Vacuum Nozzle"

/// Backpack that sucks up slimes and extracts, and shoots the slimes back out.
/obj/item/vacuum_pack
	name = "slime vacuum pack"
	desc = "A backpack (or belt) vacuum for carrying and launching slimes. Anything else it sucks up goes straight to the linked recycler."
	icon = 'icons/obj/xenobiology/slime_rancher/vacuum.dmi'
	icon_state = "vacuum_pack"
	inhand_icon_state = "vacuum_pack"
	lefthand_file = 'icons/obj/xenobiology/slime_rancher/vacuum_pack_lefthand.dmi'
	righthand_file = 'icons/obj/xenobiology/slime_rancher/vacuum_pack_righthand.dmi'
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "waterbackpackjani"
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 2, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	item_flags = NOBLUDGEON
	actions_types = list(/datum/action/item_action/toggle_vacuum_nozzle)
	max_integrity = 200

	/// The nozzle. It lives inside the pack when nobody's holding it.
	var/obj/item/vacuum_nozzle/nozzle
	/// Matter bin that sets how many extracts fit.
	var/obj/item/stock_parts/matter_bin/extract_bin
	/// Bin the pack spawns with.
	var/extract_bin_type = /obj/item/stock_parts/matter_bin
	/// Most slimes the pack holds.
	var/capacity = VACUUM_BASE_CAPACITY
	/// How far the suction reaches, in tiles.
	var/capture_range = VACUUM_BASE_CAPTURE_RANGE
	/// How long it takes to suck something up, in deciseconds.
	var/capture_delay = VACUUM_BASE_CAPTURE_DELAY
	/// The upgrades we've got: upgrade type -> its /datum/vacuum_upgrade.
	var/list/upgrades = list()
	/// Weakref to the linked biomass recycler.
	var/datum/weakref/linked_recycler_ref
	/// The critter type the printer upgrade will print next.
	var/atom/selected_species
	/// If TRUE, firing asks which slime to shoot instead of picking one for you.
	var/selective_mode = FALSE
	/// TRUE while we're in the middle of something, so spam clicking doesn't stack.
	var/busy = FALSE
	var/retracting = FALSE // needed to avoid recursing dropped()
	/// VACUUM_CAN_* flags, turned on by installed upgrades.
	var/capabilities = NONE
	/// Extracts currently flying toward the user, mapped to the move loop pulling them.
	var/alist/pulled_extracts = alist()
	/// How many extracts this pull has sucked up so far, so each ploop is higher pitched.
	var/extract_pitch_count = 0
	COOLDOWN_DECLARE(extract_suction_cooldown)

/obj/item/vacuum_pack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/drag_pickup)
	nozzle = new(src)
	RegisterSignal(nozzle, COMSIG_MOVABLE_MOVED, PROC_REF(on_nozzle_moved))
	extract_bin = new extract_bin_type(src)
	RegisterSignal(src, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))

/obj/item/vacuum_pack/Destroy()
	var/turf/drop_turf = drop_location()
	for(var/atom/movable/cargo as anything in occupants() + stored_extracts())
		if(drop_turf)
			cargo.forceMove(drop_turf)
		else
			qdel(cargo)

	stop_extract_pulls()
	QDEL_NULL(nozzle)
	QDEL_NULL(extract_bin)
	QDEL_LIST_ASSOC_VAL(upgrades)
	linked_recycler_ref = null
	return ..()

/obj/item/vacuum_pack/Exited(atom/movable/gone, direction)
	. = ..()
	if(!isliving(gone))
		return
	var/mob/living/occupant = gone
	cleanup_occupant(occupant, deleting = QDELETED(occupant))

/obj/item/vacuum_pack/examine(mob/user)
	. = ..()
	var/list/stored = occupants()
	. += span_notice("It contains [length(stored)] of [capacity] slimes.")
	. += span_notice("It holds [length(stored_extracts())] of [extract_capacity()] extracts in its [extract_bin.name].")
	. += span_notice("Drag it onto a bag, the extract fridge, or the floor to empty the extracts, or [EXAMINE_HINT("right-click")] it to take one out. Use a matter bin on it to swap the bin.")
	. += span_notice("Its suction reaches [capture_range] tiles and takes [DisplayTimeText(capture_delay)].")
	. += span_notice("It is set to [selective_mode ? "selective" : "random"] firing.")
	. += span_notice("[EXAMINE_HINT("Ctrl-right-click")] with the nozzle to suck up slime extracts in that direction.")
	. += span_notice("A confused slime should shake it off and go back to normal if you vacuum it up and fire it back out.")
	if(length(upgrades))
		var/list/upgrade_names = list()
		for(var/upgrade_type, value in upgrades)
			var/datum/vacuum_upgrade/upgrade = value
			upgrade_names += upgrade.name
		. += span_notice("Installed upgrades: [english_list(upgrade_names)].")
	else
		. += span_notice("It has no upgrades installed.")

	var/obj/machinery/biomass_recycler/recycler = resolve_recycler()
	if(recycler)
		. += span_notice("It is linked to [recycler], with [recycler.biomass] biomass available.")
	else
		. += span_notice("It is not linked to a biomass recycler.")
	if(selected_species)
		. += span_notice("It is set to print [selected_species::name].")

/obj/item/vacuum_pack/ui_action_click(mob/user)
	toggle_nozzle(user)

/obj/item/vacuum_pack/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		retract_nozzle()

/obj/item/vacuum_pack/dropped(mob/user, silent)
	. = ..()
	retract_nozzle()

/obj/item/vacuum_pack/attack_hand(mob/user, list/modifiers)
	if(!is_worn_by(user))
		return ..()
	toggle_nozzle(user)
	return TRUE

/obj/item/vacuum_pack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/stock_parts/matter_bin))
		return swap_extract_bin(tool, user)
	var/obj/item/disk/vacuum_upgrade/disk = tool
	if(!istype(disk))
		return NONE
	if(upgrades[disk.upgrade_type])
		balloon_alert(user, "upgrade already installed")
		return ITEM_INTERACT_BLOCKING

	upgrades[disk.upgrade_type] = new disk.upgrade_type(src)
	recalculate_stats()
	playsound(src, 'sound/machines/click.ogg', vol = 30, vary = TRUE)
	balloon_alert(user, "upgrade installed")
	qdel(disk)
	return ITEM_INTERACT_SUCCESS

/// Takes the nozzle out into a hand, or puts it back.
/obj/item/vacuum_pack/proc/toggle_nozzle(mob/living/user)
	if(!istype(user) || !is_worn_by(user))
		balloon_alert(user, "wear the pack first!")
		return FALSE
	if(user.incapacitated() || busy)
		return FALSE
	if(QDELETED(nozzle))
		nozzle = new(src)
		RegisterSignal(nozzle, COMSIG_MOVABLE_MOVED, PROC_REF(on_nozzle_moved))
	if(nozzle.loc == src)
		if(!user.put_in_hands(nozzle))
			balloon_alert(user, "need a free hand!")
			return FALSE
		playsound(src, 'sound/mecha/mechmove03.ogg', 75, TRUE)
		return TRUE
	retract_nozzle()
	return TRUE

/obj/item/vacuum_pack/proc/retract_nozzle()
	if(retracting || QDELETED(nozzle) || nozzle.loc == src)
		return
	retracting = TRUE
	stop_extract_pulls()
	if(ismob(nozzle.loc))
		var/mob/holder = nozzle.loc
		holder.temporarilyRemoveItemFromInventory(nozzle, force = TRUE)
	playsound(src, 'sound/mecha/mechmove03.ogg', vol = 75, vary = TRUE)
	nozzle.forceMove(src)
	retracting = FALSE

/// Snaps the nozzle back into the pack if it ends up anywhere else.
/obj/item/vacuum_pack/proc/on_nozzle_moved(atom/movable/source, atom/old_loc, direction)
	SIGNAL_HANDLER
	if(source.loc == src || source.loc == loc)
		return
	if(ismob(loc))
		balloon_alert(loc, "nozzle snaps back")
	source.forceMove(src)
	playsound(source, 'sound/mecha/mechmove03.ogg', 75, TRUE)

/obj/item/vacuum_pack/proc/is_worn_by(mob/user)
	return user.get_slot_by_item(src) & slot_flags

/// The critters inside the pack.
/obj/item/vacuum_pack/proc/occupants()
	. = list()
	for(var/mob/living/occupant in contents)
		. += occupant

/// Resets our stats, then applies every upgrade again.
/obj/item/vacuum_pack/proc/recalculate_stats()
	capacity = VACUUM_BASE_CAPACITY
	capture_range = VACUUM_BASE_CAPTURE_RANGE
	capture_delay = VACUUM_BASE_CAPTURE_DELAY
	capabilities = NONE
	for(var/upgrade_type, value in upgrades)
		var/datum/vacuum_upgrade/upgrade = value
		capacity += upgrade.capacity_bonus
		capture_range += upgrade.range_bonus
		capture_delay -= upgrade.capture_delay_reduction
		capabilities |= upgrade.capability

/// The linked recycler, or null (and clears the ref) if it's gone.
/obj/item/vacuum_pack/proc/resolve_recycler()
	var/obj/machinery/biomass_recycler/recycler = linked_recycler_ref?.resolve()
	if(isnull(recycler))
		linked_recycler_ref = null
	return recycler

/// Accepts the same floor or an existing connected floor, with no tile-distance limit.
/obj/item/vacuum_pack/proc/can_use_recycler(obj/machinery/biomass_recycler/recycler, mob/living/user, feedback = FALSE)
	if(QDELETED(recycler) || recycler != resolve_recycler())
		if(feedback)
			balloon_alert(user, "no recycler linked!")
		return FALSE
	if(!recycler.is_available())
		if(feedback)
			balloon_alert(user, "recycler unavailable!")
		return FALSE
	if(!are_zs_connected(user, recycler))
		if(feedback)
			balloon_alert(user, "recycler is too far away!")
		return FALSE
	return TRUE

/// Links to a working recycler the user is standing next to.
/obj/item/vacuum_pack/proc/link_recycler(obj/machinery/biomass_recycler/recycler, mob/living/user)
	if(!can_use_nozzle(user, feedback = TRUE))
		return FALSE
	if(!user.Adjacent(recycler))
		balloon_alert(user, "move next to the recycler")
		return FALSE
	if(QDELETED(recycler) || !recycler.is_available())
		balloon_alert(user, "recycler offline!")
		return FALSE
	linked_recycler_ref = WEAKREF(recycler)
	balloon_alert(user, "recycler linked")
	return TRUE

/// Whether the user is wearing the pack and holding the nozzle.
/obj/item/vacuum_pack/proc/can_use_nozzle(mob/living/user, feedback = FALSE)
	if(QDELETED(src) || QDELETED(nozzle) || !istype(user))
		return FALSE
	if(!is_worn_by(user) || user.get_active_held_item() != nozzle)
		if(feedback)
			balloon_alert(user, "hold the nozzle with the pack worn")
		return FALSE
	if(user.stat != CONSCIOUS || !user.can_perform_action(nozzle, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH))
		if(feedback)
			balloon_alert(user, "cannot use nozzle!")
		return FALSE
	return TRUE

/// Keeps normal and monkey intake on the same physical path and starting turf.
/obj/item/vacuum_pack/proc/can_reach_for_intake(mob/living/target, mob/living/user, feedback = FALSE)
	if(!can_use_nozzle(user, feedback) || QDELETED(target) || !isturf(target.loc))
		return FALSE
	if(target.z != user.z || get_dist(user, target) > capture_range)
		if(feedback)
			balloon_alert(user, "too far away!")
		return FALSE
	if(!CheckToolReach(nozzle, target, capture_range))
		if(feedback)
			balloon_alert(user, "suction path blocked!")
		return FALSE
	return TRUE

/// Whether this creature can be vacuumed into the pack right now.
/obj/item/vacuum_pack/proc/can_suck(mob/living/target, mob/living/user, feedback = FALSE)
	if(!can_reach_for_intake(target, user, feedback))
		return FALSE
	if(length(occupants()) >= capacity)
		if(feedback)
			balloon_alert(user, "pack is full!")
		return FALSE
	if(target.stat == DEAD || target.client || target.mind || target.anchored || target.buckled || target.has_buckled_mobs())
		if(feedback)
			balloon_alert(user, "cannot be sucked up!")
		return FALSE

	var/mob/living/basic/basic_target = target
	if(!isslime(basic_target))
		if(feedback)
			balloon_alert(user, "cannot be sucked up!")
		return FALSE
	if(HAS_TRAIT(basic_target, TRAIT_AI_PAUSED))
		if(feedback)
			balloon_alert(user, "already restrained!")
		return FALSE

	var/mob/living/basic/slime/slime = basic_target
	if(slime.has_status_effect(/datum/status_effect/slime_reproducing))
		if(feedback)
			balloon_alert(user, "slime is reproducing!")
		return FALSE
	if(slime.ai_controller?.blackboard[BB_SLIME_RABID] && !(capabilities & VACUUM_CAN_PACIFY))
		if(feedback)
			balloon_alert(user, "slime is rabid!")
		return FALSE
	return TRUE

/// Waits out capture_delay, then stuffs the slime in the pack.
/obj/item/vacuum_pack/proc/capture(mob/living/target, mob/living/user, turf/required_turf)
	var/turf/starting_turf = required_turf || target.loc
	if(!can_suck(target, user, feedback = TRUE))
		return FALSE
	start_mob_suction(target, user)
	var/finished = do_after(user, capture_delay, target = target, extra_checks = CALLBACK(src, PROC_REF(can_suck), target, user, FALSE))
	stop_mob_suction(target)
	if(!finished)
		return FALSE
	if(!can_suck(target, user, feedback = TRUE))
		return FALSE
	return store(target, user, starting_turf)

/// Moves the slime into the pack and pauses its AI.
/obj/item/vacuum_pack/proc/store(mob/living/basic/slime/target, mob/living/user, turf/original_turf)
	if(QDELETED(target))
		return FALSE
	target.forceMove(src)
	if(target.loc != src)
		return FALSE

	target.pause_ai(VACUUM_STORED_TRAIT)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_occupant_deleting))
	if(capabilities & VACUUM_CAN_PACIFY)
		target.ai_controller?.clear_blackboard_key(BB_SLIME_RABID)
	SEND_SIGNAL(src, COMSIG_VACUUM_STORED, target)
	new /obj/effect/temp_visual/vacuum_intake(original_turf, target.appearance, get_turf(nozzle))
	play_ploop(nozzle)
	user.visible_message(span_notice("[user] sucks [target] into [nozzle]."), span_notice("You suck [target] into [nozzle]."))
	return TRUE

/obj/item/vacuum_pack/proc/on_occupant_deleting(mob/living/source)
	SIGNAL_HANDLER
	cleanup_occupant(source, deleting = TRUE)

/// Wakes the occupant back up; upgrade signals handle stasis.
/obj/item/vacuum_pack/proc/cleanup_occupant(mob/living/basic/slime/occupant, deleting = FALSE)
	if(deleting)
		return
	UnregisterSignal(occupant, COMSIG_QDELETING)
	occupant.unpause_ai(VACUUM_STORED_TRAIT)
	occupant.reset_stuck_ai()
	SEND_SIGNAL(src, COMSIG_VACUUM_RELEASED, occupant)

/// Plops a critter from the pack out onto a turf.
/obj/item/vacuum_pack/proc/release(mob/living/occupant, turf/destination)
	if(QDELETED(occupant) || occupant.loc != src || !isturf(destination))
		return FALSE
	occupant.forceMove(destination)
	return occupant.loc == destination

/// Dense target turfs check the approach tile so visible walls remain valid targets.
/obj/item/vacuum_pack/proc/can_aim_at(atom/target, mob/living/user, feedback = FALSE)
	if(!can_use_nozzle(user, feedback) || QDELETED(target))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(!target_turf || target_turf.z != user.z || get_dist(user, target_turf) > VACUUM_LAUNCH_RANGE)
		if(feedback)
			balloon_alert(user, "too far away!")
		return FALSE
	return TRUE

/// Yeets a critter at the target, and lets it fly over other mobs.
/obj/item/vacuum_pack/proc/launch(mob/living/creature, atom/target, mob/living/user)
	if(QDELETED(creature) || !isturf(creature.loc) || !can_aim_at(target, user, feedback = TRUE))
		return FALSE
	new /obj/effect/temp_visual/small_smoke/halfsecond(creature.loc)
	creature.apply_status_effect(/datum/status_effect/slime_food, user)
	var/datum/callback/restore = (creature.pass_flags & PASSMOB) ? null : CALLBACK(src, PROC_REF(un_passmob), creature)
	creature.pass_flags |= PASSMOB
	if(!creature.throw_at(get_turf(target), VACUUM_LAUNCH_RANGE, VACUUM_LAUNCH_SPEED, user, gentle = TRUE, callback = restore))
		restore?.Invoke()
		return FALSE
	playsound(nozzle, 'sound/misc/moist_impact.ogg', vol = 50, vary = TRUE)
	if(prob(99) && isslime(creature) && creature.stat != DEAD)
		playsound(creature, 'sound/misc/woohoo.ogg', vol = 50, vary = TRUE)
	user.visible_message(
		span_notice("[user] launches [creature] from [nozzle]."),
		span_notice("You launch [creature] from [nozzle].")
	)
	return TRUE

/// Takes back the PASSMOB that launch() gave.
/obj/item/vacuum_pack/proc/un_passmob(mob/living/creature)
	creature.pass_flags &= ~PASSMOB

/// Takes one slime out of the pack and shoots it at the target.
/obj/item/vacuum_pack/proc/fire(atom/target, mob/living/user)
	if(!can_aim_at(target, user, feedback = TRUE))
		return FALSE
	var/list/stored = occupants()
	if(!length(stored))
		balloon_alert(user, "empty!")
		return FALSE

	var/mob/living/selected = selective_mode ? choose_occupant(user) : pick(stored)
	if(!selected || selected.loc != src || !can_aim_at(target, user, feedback = TRUE))
		return FALSE
	var/turf/drop_turf = get_turf(nozzle)
	if(!release(selected, drop_turf))
		return FALSE
	return launch(selected, target, user)

/// Numbered labels keep same-named occupants individually selectable.
/obj/item/vacuum_pack/proc/choose_occupant(mob/living/user)
	var/list/choices = list()
	var/list/datum/weakref/occupant_refs = list()
	var/index = 0
	for(var/mob/living/occupant as anything in occupants())
		var/label = "[occupant.name] ([++index])"
		choices[label] = copy_appearance_filter_overlays(occupant.appearance)
		occupant_refs[label] = WEAKREF(occupant)
	var/selection = show_radial_menu(user, nozzle, choices, custom_check = CALLBACK(src, PROC_REF(can_continue_menu), user), require_near = TRUE, tooltips = TRUE)
	var/mob/living/selected = occupant_refs[selection]?.resolve()
	if(selected?.loc != src)
		return
	return selected

/// Keeps a radial menu open only while the pack is busy and usable.
/obj/item/vacuum_pack/proc/can_continue_menu(mob/living/user)
	return busy && can_use_nozzle(user)

/// Anything sucked up that isn't a slime gets ground down instead of stored.
/obj/item/vacuum_pack/proc/is_recyclable(mob/living/target)
	if(ismonkeybasic(target))
		return TRUE
	var/mob/living/basic/basic_target = target
	return istype(basic_target) && !isslime(basic_target) && basic_target.biomass_value > 0

/// Whether the linked recycler can take this creature right now.
/obj/item/vacuum_pack/proc/can_recycle_creature(mob/living/target, mob/living/user, obj/machinery/biomass_recycler/recycler, feedback = FALSE)
	if(!is_recyclable(target) || !can_reach_for_intake(target, user, feedback))
		return FALSE
	if(!can_use_recycler(recycler, user, feedback))
		return FALSE
	return recycler.can_recycle(target, user, feedback)

/// Commits through the machine so part efficiency and credit stay in one place.
/obj/item/vacuum_pack/proc/recycle_creature(mob/living/target, mob/living/user, turf/required_turf)
	var/obj/machinery/biomass_recycler/recycler = resolve_recycler()
	var/turf/starting_turf = required_turf || target.loc
	if(!can_recycle_creature(target, user, recycler, feedback = TRUE))
		return FALSE
	start_mob_suction(target, user)
	var/finished = do_after(user, capture_delay, target = target, extra_checks = CALLBACK(src, PROC_REF(can_recycle_creature), target, user, recycler, FALSE))
	stop_mob_suction(target)
	if(!finished)
		return FALSE
	if(!can_recycle_creature(target, user, recycler, feedback = TRUE))
		return FALSE
	new /obj/effect/temp_visual/vacuum_intake(starting_turf, target.appearance, get_turf(nozzle))
	play_ploop(nozzle)
	return recycler.recycle(target, user, feedback = TRUE)

/// Nozzle left-click: picks what to do from what was clicked.
/obj/item/vacuum_pack/proc/primary_action(atom/target, mob/living/user)
	if(busy)
		balloon_alert(user, "busy!")
		return FALSE
	busy = TRUE
	var/succeeded = FALSE
	if(istype(target, /obj/machinery/biomass_recycler))
		succeeded = link_recycler(target, user)
	else if(istype(target, /obj/machinery/smartfridge/extract))
		succeeded = fire_extracts(target, user)
	else if(is_recyclable(target))
		succeeded = recycle_creature(target, user)
	else if(isliving(target))
		succeeded = capture(target, user)
	else
		succeeded = fire(target, user)
	busy = FALSE
	return succeeded

/// Radial menu to pick one creature off a turf, then take it in.
/obj/item/vacuum_pack/proc/select_turf_target(turf/target_turf, mob/living/user)
	if(busy || !has_selectable_target(target_turf, user))
		return FALSE
	busy = TRUE
	var/list/choices = list()
	var/list/datum/weakref/target_refs = list()
	var/index = 0
	for(var/mob/living/candidate in target_turf)
		if(!is_selectable_target(candidate, user, target_turf))
			continue
		var/label = "[candidate.name] ([++index])"
		choices[label] = copy_appearance_filter_overlays(candidate.appearance)
		target_refs[label] = WEAKREF(candidate)

	var/selection = show_radial_menu(user, target_turf, choices, custom_check = CALLBACK(src, PROC_REF(can_continue_menu), user), tooltips = TRUE, autopick_single_option = FALSE)
	var/mob/living/selected = target_refs[selection]?.resolve()
	var/succeeded = FALSE
	if(selected?.loc == target_turf)
		if(is_recyclable(selected))
			succeeded = recycle_creature(selected, user, target_turf)
		else
			succeeded = capture(selected, user, target_turf)
	busy = FALSE
	return succeeded

/// Whether anything on the turf could go in the selection menu.
/obj/item/vacuum_pack/proc/has_selectable_target(turf/target_turf, mob/living/user)
	if(busy || !isturf(target_turf))
		return FALSE
	for(var/mob/living/candidate in target_turf)
		if(is_selectable_target(candidate, user, target_turf))
			return TRUE
	return FALSE

/obj/item/vacuum_pack/proc/is_selectable_target(mob/living/candidate, mob/living/user, turf/target_turf)
	if(is_recyclable(candidate))
		return can_recycle_creature(candidate, user, resolve_recycler())
	return can_suck(candidate, user)

/// Radial menu of species the recycler can print. Returns the chosen type.
/obj/item/vacuum_pack/proc/choose_species(mob/living/user)
	var/obj/machinery/biomass_recycler/recycler = resolve_recycler()
	if(!(capabilities & VACUUM_CAN_PRINT))
		balloon_alert(user, "upgrade needed!")
		return
	if(!can_use_recycler(recycler, user, feedback = TRUE))
		return
	var/list/catalog = recycler.get_printable_species()
	var/list/choices = list()
	var/list/species_by_label = list()
	for(var/atom/species as anything in catalog)
		var/species_name = ispath(species, /mob/living/carbon/human/species/monkey) ? "monkey" : species::name
		var/label = "[species_name] - [catalog[species]] biomass"
		choices[label] = image(icon = species::icon, icon_state = species::icon_state)
		species_by_label[label] = species
	var/selection = show_radial_menu(user, nozzle, choices, custom_check = CALLBACK(src, PROC_REF(can_continue_menu), user), require_near = TRUE, tooltips = TRUE)
	return species_by_label[selection]

/// Lets the user pick which species the printer prints next.
/obj/item/vacuum_pack/proc/select_species(mob/living/user)
	if(busy)
		balloon_alert(user, "busy!")
		return FALSE
	busy = TRUE
	var/atom/species_type = choose_species(user)
	if(species_type && can_use_nozzle(user))
		selected_species = species_type
		balloon_alert(user, "selected [species_type::name]")
	busy = FALSE
	return !!species_type

/// Purchase stays synchronous so multiple linked packs cannot overspend.
/obj/item/vacuum_pack/proc/print_species(atom/target, mob/living/user)
	if(busy)
		balloon_alert(user, "busy!")
		return FALSE
	busy = TRUE
	. = try_print_species(target, user)
	busy = FALSE

/// Spends the recycler's biomass to print the picked critter, then shoots it out.
/obj/item/vacuum_pack/proc/try_print_species(atom/target, mob/living/user)
	if(!selected_species)
		selected_species = choose_species(user)
	var/species_type = selected_species
	if(!species_type)
		return FALSE

	var/obj/machinery/biomass_recycler/recycler = resolve_recycler()
	if(!can_aim_at(target, user, feedback = TRUE) || !can_use_recycler(recycler, user, feedback = TRUE))
		return FALSE
	var/cost = recycler.get_printable_species()[species_type]
	if(!cost)
		return FALSE
	if(recycler.biomass < cost)
		balloon_alert(user, "not enough biomass!")
		return FALSE
	var/mob/living/created = recycler.purchase_type(species_type, get_turf(nozzle))
	if(!created)
		balloon_alert(user, "printing failed!")
		return FALSE
	return launch(created, target, user)

/obj/item/vacuum_pack/proc/toggle_firing_mode(mob/living/user)
	if(busy || !can_use_nozzle(user, feedback = TRUE))
		return FALSE
	selective_mode = !selective_mode
	balloon_alert(user, "[selective_mode ? "selective" : "random"] firing")
	return TRUE

/// Starts with every upgrade installed and a bluespace bin.
/obj/item/vacuum_pack/upgraded
	extract_bin_type = /obj/item/stock_parts/matter_bin/bluespace

/obj/item/vacuum_pack/upgraded/Initialize(mapload)
	. = ..()
	for(var/datum/vacuum_upgrade/upgrade_type as anything in subtypesof(/datum/vacuum_upgrade))
		upgrades[upgrade_type] = new upgrade_type(src)
	recalculate_stats()

/datum/design/vacuum_pack
	name = "Slime Vacuum Pack"
	id = "vacuum_pack"
	desc = "A backpack vacuum for carrying and launching slimes and feeding critters."
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/vacuum_pack
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_XENOBIOLOGY,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

#undef VACUUM_BASE_CAPACITY
#undef VACUUM_BASE_CAPTURE_RANGE
#undef VACUUM_BASE_CAPTURE_DELAY
