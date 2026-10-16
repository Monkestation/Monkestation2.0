/// Handheld control nozzle paired to a slime vacuum pack.
/obj/item/vacuum_nozzle
	name = "slime vacuum nozzle"
	desc = "A nozzle attached to a slime vacuum pack."
	icon = 'icons/obj/xenobiology/slime_rancher/vacuum.dmi'
	icon_state = "vacuum_nozzle"
	inhand_icon_state = "vacuum_nozzle"
	lefthand_file = 'icons/obj/xenobiology/slime_rancher/vacuum_nozzle_lefthand.dmi'
	righthand_file = 'icons/obj/xenobiology/slime_rancher/vacuum_nozzle_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = NOBLUDGEON | ABSTRACT
	slot_flags = NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// The pack we're attached to
	var/obj/item/vacuum_pack/pack
	/// Weakref to whoever's holding us, we listen to their clicks
	var/datum/weakref/registered_user_ref

/obj/item/vacuum_nozzle/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/vacuum_pack))
		return INITIALIZE_HINT_QDEL
	src.pack = loc
	register_item_context()

/obj/item/vacuum_nozzle/Destroy()
	unregister_user()
	if(pack?.nozzle == src)
		pack.nozzle = null
	pack = null
	return ..()

/obj/item/vacuum_nozzle/equipped(mob/user, slot, initial)
	. = ..()
	if(slot & ITEM_SLOT_HANDS)
		register_user(user)
	else
		pack?.retract_nozzle()

/obj/item/vacuum_nozzle/dropped(mob/user, silent)
	. = ..()
	unregister_user()
	pack?.retract_nozzle()

/obj/item/vacuum_nozzle/attack_self(mob/user, modifiers)
	. = ..()
	pack?.toggle_firing_mode(user)
	return TRUE

/obj/item/vacuum_nozzle/attack_self_secondary(mob/user, modifiers)
	. = ..()
	pack?.select_species(user)
	return TRUE

/obj/item/vacuum_nozzle/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!pack)
		return NONE
	if(istype(interacting_with, /obj/item/disk/vacuum_upgrade) && interacting_with.Adjacent(user))
		return pack.item_interaction(user, interacting_with)
	if(interacting_with == pack)
		pack.retract_nozzle()
		return ITEM_INTERACT_SUCCESS
	if(!is_world_target(interacting_with))
		return ITEM_INTERACT_BLOCKING
	pack.primary_action(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/vacuum_nozzle/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/vacuum_nozzle/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!pack)
		return NONE
	if(!is_world_target(interacting_with))
		return ITEM_INTERACT_BLOCKING
	pack.print_species(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/vacuum_nozzle/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/vacuum_nozzle/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(target == src)
		context[SCREENTIP_CONTEXT_LMB] = "Toggle firing mode"
		context[SCREENTIP_CONTEXT_RMB] = "Select printable species"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(target, /obj/machinery/biomass_recycler))
		context[SCREENTIP_CONTEXT_LMB] = "Link recycler"
	else if(istype(target, /obj/machinery/smartfridge/extract))
		context[SCREENTIP_CONTEXT_LMB] = "Fire extracts into fridge"
	else if(pack?.is_recyclable(target))
		context[SCREENTIP_CONTEXT_LMB] = "Recycle creature"
	else if(isliving(target))
		context[SCREENTIP_CONTEXT_LMB] = "Suck up slime"
	else
		context[SCREENTIP_CONTEXT_LMB] = "Launch stored slime"
	context[SCREENTIP_CONTEXT_RMB] = "Print and launch creature"
	context[SCREENTIP_CONTEXT_CTRL_RMB] = "Suck up extracts"
	return CONTEXTUAL_SCREENTIP_SET

// don't shit out a monkey if we click on our hud
/obj/item/vacuum_nozzle/proc/is_world_target(atom/target)
	return isturf(target) || isturf(target?.loc)

/// Starts listening for the holder's alt/ctrl clicks and such
/obj/item/vacuum_nozzle/proc/register_user(mob/living/user)
	var/mob/living/old_user = registered_user_ref?.resolve()
	if(old_user == user)
		return
	if(old_user)
		UnregisterSignal(old_user, list(COMSIG_MOB_ALTCLICKON, COMSIG_MOB_CLICKON))
	registered_user_ref = WEAKREF(user)
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(on_user_altclick))
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_user_click))

/// Stops listening to the holder's clicks
/obj/item/vacuum_nozzle/proc/unregister_user()
	var/mob/living/user = registered_user_ref?.resolve()
	if(user)
		UnregisterSignal(user, list(COMSIG_MOB_ALTCLICKON, COMSIG_MOB_CLICKON))
	registered_user_ref = null

/// Ctrl-right-click only, so plain ctrl-click still pulls things.
/obj/item/vacuum_nozzle/proc/on_user_click(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(!LAZYACCESS(modifiers, CTRL_CLICK) || !LAZYACCESS(modifiers, RIGHT_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, ALT_CLICK))
		return
	if(source.get_active_held_item() != src || !pack || pack.busy || !is_world_target(target))
		return
	pack.suck_extracts(target, source)
	return COMSIG_MOB_CANCEL_CLICKON

/// Alt-click opens the pick-a-creature menu for that turf.
/obj/item/vacuum_nozzle/proc/on_user_altclick(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if(source.get_active_held_item() != src || !pack || pack.busy)
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf || (!isturf(target) && target.loc != target_turf))
		return
	if(!pack.has_selectable_target(target_turf, source))
		return
	INVOKE_ASYNC(pack, TYPE_PROC_REF(/obj/item/vacuum_pack, select_turf_target), target_turf, source)
	return COMSIG_MOB_CANCEL_CLICKON

/// Shrinking copy of a creature flying into the nozzle.
/obj/effect/temp_visual/vacuum_intake
	duration = 0.5 SECONDS
	randomdir = FALSE

/obj/effect/temp_visual/vacuum_intake/Initialize(mapload, source_appearance, turf/destination)
	. = ..()
	appearance = copy_appearance_filter_overlays(source_appearance)
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/matrix/shrinking = matrix(transform)
	shrinking.Scale(0.25)
	if(destination)
		shrinking.Translate((destination.x - x) * ICON_SIZE_X, (destination.y - y) * ICON_SIZE_Y)
	animate(src, transform = shrinking, alpha = 0, time = duration, easing = QUAD_EASING|EASE_IN)
