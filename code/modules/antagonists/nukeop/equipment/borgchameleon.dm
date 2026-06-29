#define ACTIVATION_COST (0.3 * STANDARD_CELL_CHARGE)
#define ACTIVATION_UP_KEEP (0.025 * STANDARD_CELL_RATE)

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// The cyborg that is actively disguised.
	var/mob/living/silicon/robot/disguised_cyborg
	/// When the disguise is applied, this is the new name the the cyborg will get.
	var/disguised_name
	/// When the disguise is removed, this is the old name that the cyborg will revert back to.
	var/original_name
	/// The typepath of the robot model that we will be using as a disguise.
	var/obj/item/robot_model/disguise_model_type = /obj/item/robot_model/engineering
	/// Is the item in the process of being activated?
	var/animation_playing = FALSE
	/// List of signals that should break the disguise.
	var/static/list/signal_cache = list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_MOVABLE_IMPACT_ZONE,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_EX_ACT,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_ATOM_EMP_ACT
	)

/obj/item/borg_chameleon/Initialize(mapload)
	. = ..()
	if(!iscyborg(loc))
		return INITIALIZE_HINT_QDEL
	disguised_name = pick(GLOB.ai_names)

/obj/item/borg_chameleon/Destroy()
	disguised_cyborg = null
	return ..()

/obj/item/borg_chameleon/process(seconds_per_tick)
	if(QDELETED(disguised_cyborg))
		return PROCESS_KILL
	if(disguised_cyborg.cell?.use(ACTIVATION_UP_KEEP * seconds_per_tick))
		return
	disrupt()

/obj/item/borg_chameleon/examine(mob/user)
	. = ..()
	. += span_notice("[EXAMINE_HINT("Left-click")] the item to [disguised_cyborg ? "drop your disguise" : "begin disguising"]." )
	. += span_notice("[EXAMINE_HINT("Right-click")] the item to set your next disguise's model.")
	. += span_notice("[EXAMINE_HINT("Ctrl-click")] the item to randomize your next disguise's name.")

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/attack_self(mob/user, modifiers)
	if(iscyborg(user))
		return
	var/mob/living/silicon/robot/cyborg_user = user
	if(!cyborg_user.cell || cyborg_user.cell.charge <= ACTIVATION_COST)
		to_chat(cyborg_user, span_warning("You need at least [display_energy(ACTIVATION_COST)] charge in your cell to use [src]!"))
		return
	if(!isturf(cyborg_user.loc))
		to_chat(cyborg_user, span_warning("You can't use [src] while inside something!"))
		return
	toggle(cyborg_user)

/obj/item/borg_chameleon/attack_self_secondary(mob/user, modifiers)
	initialize_cyborg_model_lists()
	var/input_model = show_radial_menu(user = user, anchor = src, choices = GLOB.cyborg_base_models_icon_list, radius = 42, require_near = TRUE)
	if(!input_model)
		return
	var/obj/item/robot_model/selected_model = GLOB.cyborg_model_list[input_model]
	if(!selected_model)
		return
	disguise_model_type = selected_model
	to_chat(user, span_notice("The next disguised model will be: [initial(disguise_model_type.name)]."))

/obj/item/borg_chameleon/item_ctrl_click(mob/user)
	disguised_name = pick(GLOB.ai_names)
	to_chat(user, span_notice("The next disguised name will be: [disguised_name]."))
	return CLICK_ACTION_SUCCESS

/**
 * Toggles the item. It will either:
 *
 * A. Remove the active disguise.
 *
 * B. Begin the process of putting on a disguise.
 */
/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/cyborg_user)
	if(disguised_cyborg)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You deactivate \the [src]."))
		deactivate()
		return
	if(animation_playing)
		to_chat(cyborg_user, span_notice("\the [src] is recharging."))
		return
	animation_playing = TRUE
	to_chat(cyborg_user, span_notice("You activate \the [src]."))
	playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, TRUE, -6)
	apply_wibbly_filters(cyborg_user)
	if(do_after(cyborg_user, 5 SECONDS, target = cyborg_user, hidden = TRUE) && cyborg_user.cell.use(ACTIVATION_COST))
		playsound(src, 'sound/effects/bamf.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You are now disguised as the Nanotrasen [initial(disguise_model_type.name)] borg \"[disguised_name]\"."))
		activate(cyborg_user)
	else
		to_chat(cyborg_user, span_warning("The chameleon field fizzles."))
		do_sparks(3, FALSE, cyborg_user)
	remove_wibbly_filters(cyborg_user)
	animation_playing = FALSE

/// Applies the disguise.
/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/cyborg_user)
	START_PROCESSING(SSobj, src)
	if(disguised_cyborg)
		return
	original_name = cyborg_user.name
	disguised_cyborg = cyborg_user
	disguised_cyborg.name = disguised_name
	disguised_cyborg.model.cyborg_base_icon = initial(disguise_model_type.cyborg_base_icon)
	disguised_cyborg.model.name = initial(disguise_model_type.name)
	disguised_cyborg.bubble_icon = "robot"
	disguised_cyborg.update_icons()
	RegisterSignals(disguised_cyborg, signal_cache, PROC_REF(disrupt))

/// Removes the disguise.
/obj/item/borg_chameleon/proc/deactivate()
	STOP_PROCESSING(SSobj, src)
	if(!disguised_cyborg)
		return
	UnregisterSignal(disguised_cyborg, signal_cache)
	do_sparks(5, FALSE, disguised_cyborg)
	disguised_cyborg.name = original_name
	disguised_cyborg.model.cyborg_base_icon = initial(disguised_cyborg.model.cyborg_base_icon)
	disguised_cyborg.model.name = initial(disguised_cyborg.model.name)
	disguised_cyborg.bubble_icon = "syndibot"
	disguised_cyborg.update_icons()
	disguised_cyborg = null

/// Removes the disguise and tells the cyborg that it happened.
/obj/item/borg_chameleon/proc/disrupt()
	SIGNAL_HANDLER
	if(QDELETED(disguised_cyborg))
		return
	to_chat(disguised_cyborg, span_danger("Your chameleon field deactivates."))
	deactivate()

#undef ACTIVATION_COST
#undef ACTIVATION_UP_KEEP
