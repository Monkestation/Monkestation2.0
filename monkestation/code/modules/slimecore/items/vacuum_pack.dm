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

/obj/item/vacuum_pack
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

	/// The nozzle that is attached to our vacuum pack
	var/obj/item/vacuum_nozzle/nozzle
	/// Type of nozzle that is created on initialize
	var/nozzle_type = /obj/item/vacuum_nozzle
	/// List of mobs that are stores inside the vacuum
	var/list/stored = list()
	/// How many mobs can be stored inside the vacuum
	var/capacity = NORMAL_VACUUM_PACK_CAPACITY
	/// How far away the vacuum can pick up mobs
	var/range = NORMAL_VACUUM_PACK_RANGE
	/// How fast the vacuum picks up mobs
	var/speed = NORMAL_VACUUM_PACK_SPEED
	/// Boolean, if the vacuum is illegal
	var/illegal = FALSE
	/// List of upgrades installed
	var/list/upgrades = list()
	/// The biomass recycler we are linked to
	var/obj/machinery/biomass_recycler/linked
	/// If set to true the pack will give the owner a radial selection to choose which object they want to shoot on left click
	var/give_choice = TRUE
	/// If it can only be used while worn on the back
	var/check_backpack = TRUE
	/// If the gun is modified to fight with revenants
	var/modified = FALSE
	/// Stores the revenant we're currently sucking in
	var/mob/living/basic/revenant/ghost_busting
	/// Stores the user
	var/mob/living/ghost_buster
	/// Stores visual effects
	var/busting_beam
	COOLDOWN_DECLARE(busting_throw_cooldown)

/obj/item/vacuum_pack/Initialize(mapload)
	. = ..()
	nozzle = new nozzle_type(src)

/obj/item/vacuum_pack/Destroy()
	linked = null
	QDEL_NULL(nozzle)
	if(VACUUM_PACK_UPGRADE_HEALING in upgrades)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/vacuum_pack/multitool_act(mob/living/user, obj/item/tool)
	modified = !modified
	to_chat(user, span_notice("You turn the safety switch on [src] [modified ? "off" : "on"]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/vacuum_pack/process(seconds_per_tick)
	if(!(VACUUM_PACK_UPGRADE_HEALING in upgrades))
		return PROCESS_KILL

	for(var/mob/living/basic/animal in stored)
		animal.adjustBruteLoss(-5 * seconds_per_tick)

/obj/item/vacuum_pack/examine(mob/user)
	. = ..()
	if(LAZYLEN(stored))
		. += span_notice("It has [LAZYLEN(stored)] creatures stored in it.")
	if(LAZYLEN(upgrades))
		for(var/upgrade in upgrades)
			. += span_notice("It has \a [upgrade] upgrade installed.")
	if(!linked)
		return
	. += span_info("It has [linked.stored_matter] unit\s of biomass.")

/obj/item/vacuum_pack/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(tool == nozzle)
		remove_nozzle()
		return ITEM_INTERACT_SUCCESS

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

/obj/item/vacuum_pack/ui_action_click(mob/user)
	toggle_nozzle(user)

/obj/item/vacuum_pack/proc/toggle_nozzle(mob/living/user)
	if(!istype(user))
		return

	if(user.get_item_by_slot(user.getBackSlot()) != src && check_backpack)
		to_chat(user, span_warning("[src] must be worn properly to use!"))
		return

	if(user.incapacitated())
		return

	if(QDELETED(nozzle))
		nozzle = new nozzle_type(src)

	if(nozzle in src)
		if(!user.put_in_hands(nozzle))
			to_chat(user, span_warning("You need a free hand to hold [nozzle]!"))
			return
		else
			playsound(user, 'sound/mecha/mechmove03.ogg', 75, TRUE)
	else
		remove_nozzle()

/obj/item/vacuum_pack/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_BACK)
		remove_nozzle()

/obj/item/vacuum_pack/proc/remove_nozzle()
	if(!QDELETED(nozzle))
		if(ismob(nozzle.loc))
			var/mob/wearer = nozzle.loc
			wearer.temporarilyRemoveItemFromInventory(nozzle, TRUE)
			playsound(loc, 'sound/mecha/mechmove03.ogg', 75, TRUE)
		nozzle.forceMove(src)

/obj/item/vacuum_pack/attack_hand(mob/user, list/modifiers)
	if (user.get_item_by_slot(user.getBackSlot()) == src)
		toggle_nozzle(user)
	else
		return ..()

/obj/item/vacuum_pack/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	var/mob/wearer = loc
	if(istype(wearer) && istype(over, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/hand = over
		wearer.putItemFromInventoryInHandIfPossible(src, hand.held_index)
	return ..()

/obj/item/vacuum_pack/dropped(mob/user)
	..()
	remove_nozzle()

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

	/// The vacuum pack this nozzle is from
	var/obj/item/vacuum_pack/pack
	/// Boolean, if enabled it shows a radial wheel of what to shoot on left click
	var/is_selecting = FALSE
	/// The mob we have selected with attack_self_alternate
	var/selected_creature = /mob/living/carbon/human/species/monkey // Shoot monkeys by default until something else is chosen
	/// Conversion list of type to name for the examine of the nozzle
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
/obj/item/vacuum_nozzle/Initialize(mapload)
	. = ..()
	pack = loc
	if(!istype(pack))
		return INITIALIZE_HINT_QDEL

/obj/item/vacuum_nozzle/examine(mob/user)
	. = ..()
	if (!pack.illegal)
		. += span_notice("Activate to change firing modes. Currently set to [pack.give_choice ? "selective" : "indiscriminate"].")
	else
		. += span_notice("It's selection mechanism is hotwired to fire indiscriminately.")
	if(!pack.linked)
		return
	. += span_notice("Right click in hand to select the type of creature to spawn.")
	. += span_info("It is currently set to spawn a [name_of_mobs[selected_creature]]")
	. += span_info("It has [pack.linked.stored_matter] unit\s of biomass.")

/obj/item/vacuum_nozzle/equipped(mob/user, slot, initial)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(on_user_altclick), override = TRUE)

/obj/item/vacuum_nozzle/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_ALTCLICKON)
	is_selecting = FALSE

/obj/item/vacuum_nozzle/doMove(atom/destination)
	if(destination && (destination != pack.loc || !ismob(destination)))
		if (loc != pack)
			to_chat(pack.loc, span_notice("[src] snaps back onto [pack]."))
		destination = pack
		is_selecting = FALSE
	. = ..()

/obj/item/vacuum_nozzle/attack_self(mob/user, modifiers)
	. = ..()
	if (!pack.illegal)
		pack.give_choice = !pack.give_choice
		var/mode_desc = pack.give_choice ? "selectively" : "indiscriminately"
		visible_message(
			span_notice("[user] switches the [pack] to fire [mode_desc]."),
			span_notice("You switch the [pack] to fire [mode_desc]."),
			span_hear("You hear a click.")
		)

/obj/item/vacuum_nozzle/attack_self_secondary(mob/user, modifiers)
	. = ..()
	var/choosing_creature = select_spawned_mob(user)
	if(!choosing_creature)
		return
	selected_creature = choosing_creature

/obj/item/vacuum_nozzle/proc/select_spawned_mob(mob/user)
	if(!pack.linked)
		user.balloon_alert(user, "needs to be linked to biomass recycler!")
		return
	var/list/items = list()
	var/list/item_names = list()

	for(var/printable_type in GLOB.biomass_unlocks)
		pack.linked.vacuum_printable_types |= printable_type
		pack.linked.vacuum_printable_types[printable_type] = GLOB.biomass_unlocks[printable_type]

	for(var/printable_type in pack.linked.vacuum_printable_types)
		var/atom/movable/printable = printable_type
		var/image/printable_image = image(icon = initial(printable.icon), icon_state = initial(printable.icon_state))
		items += list(initial(printable.name) = printable_image)
		item_names[initial(printable.name)] = printable_type

	var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)

	if(!pick)
		return FALSE

	var/spawn_type = item_names[pick]
	if(pack.linked.stored_matter < pack.linked.vacuum_printable_types[spawn_type])
		to_chat(user, span_warning("[pack.linked] does not have enough stored biomass for that! It currently has [pack.linked.stored_matter] out of [pack.linked.vacuum_printable_types[spawn_type]] unit\s required."))
		return FALSE

	return spawn_type

/obj/item/vacuum_nozzle/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/vacuum_nozzle/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(pack.modified && pack.ghost_busting && interacting_with != pack.ghost_busting && COOLDOWN_FINISHED(pack, busting_throw_cooldown))
		pack.ghost_busting.throw_at(get_turf(interacting_with), get_dist(pack.ghost_busting, interacting_with), 3, user)
		COOLDOWN_START(pack, busting_throw_cooldown, 3 SECONDS)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!(VACUUM_PACK_UPGRADE_BIOMASS in pack.upgrades))
		to_chat(user, span_warning("[pack] does not posess a required upgrade!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!pack.linked)
		to_chat(user, span_warning("[pack] is not linked to a biomass recycler!"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!selected_creature)
		var/choosing_creature = select_spawned_mob(user)
		if(!choosing_creature)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		selected_creature = choosing_creature

	if(pack.linked.stored_matter < pack.linked.vacuum_printable_types[selected_creature])
		to_chat(user, span_warning("[pack.linked] does not have enough stored biomass for that! It currently has [pack.linked.stored_matter] out of [pack.linked.vacuum_printable_types[selected_creature]] unit\s required."))
		return FALSE

	var/atom/movable/spawned = new selected_creature(user.loc)
	spawned.AddComponent(/datum/component/vac_tagged, user)

	pack.linked.stored_matter -= pack.linked.vacuum_printable_types[selected_creature]
	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spawned.transform = matrix().Scale(0.5)
	spawned.alpha = 0
	animate(spawned, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)

	if(isturf(user.loc))
		ADD_TRAIT(spawned, VACPACK_THROW, "vacpack")
		spawned.pass_flags |= PASSMOB
		spawned.throw_at(interacting_with, min(get_dist(user, interacting_with), (pack.illegal ? 5 : 11)), 1, user, gentle = TRUE) //Gentle so eggs have 50% instead of 12.5% to spawn a chick

	user.visible_message(span_warning("[user] shoots [spawned] out their [src]!"), span_notice("You fabricate and shoot [spawned] out of your [src]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/vacuum_nozzle/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(do_suck(interacting_with, user))
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/vacuum_nozzle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/biomass_recycler))
		return ranged_interact_with_atom(interacting_with, user, modifiers)
	if(!(VACUUM_PACK_UPGRADE_BIOMASS in pack.upgrades))
		to_chat(user, span_warning("[pack] does not posess a required upgrade!"))
		return ITEM_INTERACT_BLOCKING
	pack.linked = interacting_with
	to_chat(user, span_notice("You link [pack] to [interacting_with]."))
	return ITEM_INTERACT_SUCCESS

/obj/item/vacuum_nozzle/proc/do_suck(atom/movable/target, mob/user)
	if(pack.ghost_busting)
		return FALSE

	if(pack.modified && !pack.ghost_busting && isrevenant(target) && get_dist(user, target) < 4)
		start_busting(target, user)
		return TRUE

	if(!isliving(target))
		spew_contents(target, user)
		return TRUE
	var/mob/living/living_target = target

	if(isslime(living_target))
		if(get_dist(user, living_target) > pack.range)
			to_chat(user, span_warning("[living_target] is too far away!"))
			return FALSE
		if(!(living_target in view(user, pack.range)))
			to_chat(user, span_warning("You can't reach [living_target]!"))
			return FALSE
		if(living_target.anchored || living_target.move_resist > MOVE_FORCE_STRONG)
			to_chat(user, span_warning("You can't manage to suck [living_target] in!"))
			return FALSE
		if(HAS_TRAIT(living_target, TRAIT_SLIME_RABID) && !pack.illegal && !(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades))
			to_chat(user, span_warning("[living_target] is wiggling far too much for you to suck it in!"))
			return FALSE
		if(LAZYLEN(pack.stored) >= pack.capacity)
			to_chat(user, span_warning("[pack] is already filled to the brim!"))
			return FALSE
		if(!do_after(user, pack.speed, living_target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(suck_checks), living_target, user)))
			return FALSE
		if(LAZYLEN(pack.stored) >= pack.capacity) // This is checked again after the do_after because otherwise you can bypass the cap by clicking fast enough
			return FALSE
		if(SEND_SIGNAL(living_target, COMSIG_LIVING_VACUUM_PRESUCK, src, user) & COMPONENT_LIVING_VACUUM_CANCEL_SUCK)
			return FALSE
		suck_victim(living_target, user)
		return TRUE

	if(pack.linked && (living_target.type in pack.linked.recyclable_types))
		if(get_dist(user, living_target) > pack.range)
			to_chat(user, span_warning("[living_target] is too far away!"))
			return FALSE
		if(!(living_target in view(user, pack.range)))
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
		if(!do_after(user, pack.speed, living_target, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
			return FALSE
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)
		var/matrix/animation_matrix = matrix()
		animation_matrix.Scale(0.5)
		animation_matrix.Translate((user.x - living_target.x) * 32, (user.y - living_target.y) * 32)
		animate(living_target, alpha = 0, time = 8, easing = QUAD_EASING|EASE_IN, transform = animation_matrix, flags = ANIMATION_PARALLEL)
		sleep(0.8 SECONDS)
		user.visible_message(span_warning("[user] sucks [living_target] into their [pack]!"), span_notice("You successfully suck [living_target] into your [src] and recycle it."))
		qdel(living_target)
		playsound(user, 'sound/machines/juicer.ogg', 50, TRUE)
		pack.linked.use_energy(500)
		pack.linked.stored_matter += pack.linked.cube_production * pack.linked.recyclable_types[living_target.type]
		return TRUE

/// Shoots out whatever is stored inside the vacuum
/obj/item/vacuum_nozzle/proc/spew_contents(atom/movable/target, mob/user)
	if(LAZYLEN(pack.stored) <= 0)
		to_chat(user, span_warning("[pack] is empty!"))
		return

	var/mob/living/spewed

	if(pack.give_choice)
		var/list/items = list()
		var/list/items_stored = list()
		for(var/atom/movable/stored_obj in pack.stored)
			var/image/stored_image = image(icon = stored_obj.icon, icon_state = stored_obj.icon_state)
			stored_image.color = stored_obj.color
			items += list(stored_obj.name = stored_image)
			items_stored[stored_obj.name] = stored_obj
		var/pick = show_radial_menu(user, src, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
		if(!pick)
			return
		spewed = items_stored[pick]
	else
		spewed = pick(pack.stored)

	playsound(user, 'sound/misc/moist_impact.ogg', 50, TRUE)
	spewed.transform = matrix().Scale(0.5)
	spewed.alpha = 0
	animate(spewed, alpha = 255, time = 8, easing = QUAD_EASING|EASE_OUT, transform = matrix(), flags = ANIMATION_PARALLEL)
	spewed.forceMove(user.loc)

	if(isturf(user.loc))
		ADD_TRAIT(spewed, VACPACK_THROW, "vacpack")
		spewed.pass_flags |= PASSMOB
		spewed.throw_at(target, min(get_dist(user, target), (pack.illegal ? 5 : 11)), 1, user)
		if(prob(99) && spewed.stat != DEAD)
			playsound(spewed, 'sound/misc/woohoo.ogg', 50, TRUE)

	if(isslime(spewed))
		var/mob/living/basic/slime/slime = spewed
		slime.slime_flags &= ~STORED_SLIME
		slime.ai_controller?.reset_ai_status()
		if(VACUUM_PACK_UPGRADE_STASIS in pack.upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")

		if(pack.illegal)
			ADD_TRAIT(slime, TRAIT_SLIME_RABID, "syndicate_slimepack")
			user.changeNext_move(CLICK_CD_RAPID) //Like a machine gun
		else if(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades)
			REMOVE_TRAIT(slime, TRAIT_SLIME_RABID, null)

	pack.stored -= spewed
	user.visible_message(span_warning("[user] shoots [spewed] out their [src]!"), span_notice("You shoot [spewed] out of your [src]."))

/obj/item/vacuum_nozzle/proc/suck_checks(atom/movable/target, mob/user)
	if(get_dist(user, target) > pack.range)
		return FALSE

	if(!(target in view(user, pack.range)))
		return FALSE

	if(target.anchored || target.move_resist > MOVE_FORCE_STRONG)
		return FALSE

	if(isslime(target))
		var/mob/living/basic/slime/slime = target
		if(HAS_TRAIT(slime, TRAIT_SLIME_RABID) && !pack.illegal && !(VACUUM_PACK_UPGRADE_PACIFY in pack.upgrades))
			return FALSE

	if(LAZYLEN(pack.stored) >= pack.capacity)
		return FALSE

	return TRUE

/obj/item/vacuum_nozzle/proc/suck_victim(atom/movable/target, mob/user, silent = FALSE)
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
	target.forceMove(pack)
	pack.stored += target

	SEND_SIGNAL(target, COMSIG_ATOM_SUCKED)
	if(!silent)
		user.visible_message(span_warning("[user] sucks [target] into their [pack]!"), span_notice("You successfully suck [target] into your [src]."))

	if(!isslime(target))
		return
	var/mob/living/basic/slime/slime = target
	slime.slime_flags |= STORED_SLIME
	if((VACUUM_PACK_UPGRADE_STASIS in pack.upgrades))
		ADD_TRAIT(slime, TRAIT_SLIME_STASIS, "vacuum_pack_stasis")

/obj/item/vacuum_nozzle/proc/start_busting(mob/living/basic/revenant/revenant, mob/living/user)
	revenant.visible_message(span_warning("[user] starts sucking [revenant] into their [src]!"), span_userdanger("You are being sucked into [user]'s [src]!"))
	pack.ghost_busting = revenant
	pack.ghost_buster = user
	pack.busting_beam = user.Beam(revenant, icon_state="drain_life")
	bust_the_ghost()

/obj/item/vacuum_nozzle/proc/bust_the_ghost()
	while(check_busting())
		if(!do_after(pack.ghost_buster, 0.5 SECONDS, target = pack.ghost_busting, extra_checks = CALLBACK(src, PROC_REF(check_busting)), timed_action_flags = IGNORE_TARGET_LOC_CHANGE|IGNORE_USER_LOC_CHANGE))
			pack.ghost_busting = null
			pack.ghost_buster = null
			QDEL_NULL(pack.busting_beam)
			return

		pack.ghost_busting.adjust_health(5)
		pack.ghost_busting.apply_status_effect(/datum/status_effect/revenant/revealed, 0.5 SECONDS)

/obj/item/vacuum_nozzle/proc/check_busting()
	if(isnull(pack.ghost_busting?.loc) || QDELING(pack.ghost_busting))
		return FALSE

	if(isnull(pack.ghost_buster?.loc) || QDELING(pack.ghost_buster))
		return FALSE

	if(loc != pack.ghost_buster)
		return FALSE

	if(get_dist(pack.ghost_buster, pack.ghost_busting) > pack.range)
		return FALSE

	if(pack.ghost_busting.essence <= 0) //Means that the revenant is dead
		return FALSE

	return TRUE

/obj/item/vacuum_nozzle/proc/on_user_altclick(mob/living/user, atom/movable/target)
	SIGNAL_HANDLER
	if(!isliving(user) || user != loc) // what
		UnregisterSignal(user, COMSIG_MOB_ALTCLICKON)
		return
	if(is_selecting || user.get_active_held_item() != src || user.incapacitated())
		return
	. = COMSIG_MOB_CANCEL_CLICKON // avoids loot panel showing up
	is_selecting = TRUE
	ASYNC
		select_suck_target(user, target)
		is_selecting = FALSE

/obj/item/vacuum_nozzle/proc/select_suck_target(mob/living/user, atom/movable/target)
	var/turf/target_turf = get_turf(target)
	if(isnull(target_turf))
		return
	if(get_dist(user, target_turf) > pack.range)
		user.balloon_alert(user, "out of range!")
		return
	var/list/options = list()
	for(var/atom/movable/thing as anything in target_turf)
		if(!isslime(thing) && !(thing.type in pack.linked?.recyclable_types))
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
		custom_check = CALLBACK(src, PROC_REF(extra_selection_checks), user, target_turf),
		tooltips = TRUE,
		autopick_single_option = FALSE,
	)
	if(chosen)
		do_suck(chosen, user)

/obj/item/vacuum_nozzle/proc/extra_selection_checks(mob/living/user, turf/target_turf)
	return user.get_active_held_item() == src && !user.incapacitated() && CAN_THEY_SEE(target_turf, user)

/obj/item/disk/vacuum_upgrade
	name = "vacuum pack upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage."
	icon_state = "rndmajordisk"
	var/upgrade_type

/obj/item/disk/vacuum_upgrade/proc/on_upgrade(obj/item/vacuum_pack/pack)

/obj/item/disk/vacuum_upgrade/stasis
	name = "vacuum pack stasis upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to keep all slimes inside of it in stasis."
	upgrade_type = VACUUM_PACK_UPGRADE_STASIS

/obj/item/disk/vacuum_upgrade/healing
	name = "vacuum pack healing upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that makes the pack passively heal all the slimes inside of it."
	upgrade_type = VACUUM_PACK_UPGRADE_HEALING

/obj/item/disk/vacuum_upgrade/healing/on_upgrade(obj/item/vacuum_pack/pack)
	START_PROCESSING(SSobj, pack)

/obj/item/disk/vacuum_upgrade/capacity
	name = "vacuum pack capacity upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that expands it's internal slime storage."
	upgrade_type = VACUUM_PACK_UPGRADE_CAPACITY

/obj/item/disk/vacuum_upgrade/capacity/on_upgrade(obj/item/vacuum_pack/pack)
	pack.capacity = UPGRADED_VACUUM_PACK_CAPACITY

/obj/item/disk/vacuum_upgrade/range
	name = "vacuum pack range upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that strengthens it's pump and allows it to reach further."
	upgrade_type = VACUUM_PACK_UPGRADE_RANGE

/obj/item/disk/vacuum_upgrade/range/on_upgrade(obj/item/vacuum_pack/pack)
	pack.range = UPGRADED_VACUUM_PACK_RANGE

/obj/item/disk/vacuum_upgrade/speed
	name = "vacuum pack speed upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that upgrades it's motor and allows it to suck slimes up faster."
	upgrade_type = VACUUM_PACK_UPGRADE_SPEED

/obj/item/disk/vacuum_upgrade/speed/on_upgrade(obj/item/vacuum_pack/pack)
	pack.speed = UPGRADED_VACUUM_PACK_SPEED

/obj/item/disk/vacuum_upgrade/pacification
	name = "vacuum pack pacification upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to pacify all stored slimes."
	upgrade_type = VACUUM_PACK_UPGRADE_PACIFY

/obj/item/disk/vacuum_upgrade/biomass
	name = "vacuum pack biomass printer upgrade disk"
	desc = "An upgrade disk for a backpack vacuum xenofauna storage that allows it to automatically recycle dead biomass and make living creatures on right click."
	upgrade_type = VACUUM_PACK_UPGRADE_BIOMASS

/obj/item/vacuum_pack/syndicate
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
	give_choice = FALSE

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
