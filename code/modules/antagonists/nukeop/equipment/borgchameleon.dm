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
	/// The cyborg that is currently disguised.
	var/mob/living/silicon/robot/disguised_cyborg
	/// The typepath of the robot model that we will be using as a disguise.
	var/datum/robot_model/disguise_model_type = /datum/robot_model/engineering
	/// The typepath of the robot model that we previously had before disguising.
	var/datum/robot_model/original_model_type
	/// The typepath of the robot skin that we will be using as a disguise.
	var/datum/robot_skin/disguise_skin_type
	/// The typepath of the robot skin that we previously had before disguising.
	var/datum/robot_skin/original_skin_type
	/// When the disguise is applied, this is the new name the the cyborg will get.
	var/disguise_name
	/// When the disguise is removed, this is the old name that the cyborg will revert back to.
	var/original_name
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
	disguise_skin_type = disguise_model_type.default_skin
	disguise_name = pick(GLOB.ai_names)

/obj/item/borg_chameleon/Destroy()
	deactivate()
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
	. += span_notice("[EXAMINE_HINT("Right-click")] the item to set your next disguise's model and its skin.")
	. += span_notice("[EXAMINE_HINT("Ctrl-click")] the item to randomize your next disguise's name.")

/obj/item/borg_chameleon/dropped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/equipped(mob/user)
	. = ..()
	disrupt()

/obj/item/borg_chameleon/attack_self(mob/user, modifiers)
	if(!iscyborg(user))
		to_chat(user, span_notice("This device doesn't seem to work for non-cyborgs."))
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
	if(!iscyborg(user))
		to_chat(user, span_notice("This device doesn't seem to work for non-cyborgs."))
		return
	var/mob/living/silicon/robot/cyborg_user = user
	var/datum/robot_model/chosen_robot_model = cyborg_user.prompt_model_selection()
	if(!chosen_robot_model)
		return FALSE
	var/datum/robot_skin/chosen_robot_skin = cyborg_user.prompt_skin_selection(chosen_robot_model)
	if(!chosen_robot_skin)
		return FALSE
	disguise_model_type = chosen_robot_model
	disguise_skin_type = chosen_robot_skin
	to_chat(user, span_notice("The next disguised model will be: [initial(disguise_model_type.name)]."))

/obj/item/borg_chameleon/item_ctrl_click(mob/user)
	disguise_name = pick(GLOB.ai_names)
	to_chat(user, span_notice("The next disguised name will be: [disguise_name]."))
	return CLICK_ACTION_SUCCESS

/// Makes the cyborg appear as if they look like a certain model and certain skin.
/obj/item/borg_chameleon/proc/apply_appearance_as(mob/living/silicon/robot/cyborg_user, datum/robot_model/disguising_model, datum/robot_skin/disguising_skin)
	cyborg_user.model.name = initial(disguising_model.name) // Will fool people examining us.
	cyborg_user.apply_skin(disguising_skin, FALSE, FALSE)

/**
 * Toggles the item. It will either:
 *
 * A. Remove the active disguise.
 *
 * B. Begin the process of putting on a disguise.
 */
/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/cyborg_user)
	if(LAZYACCESS(cyborg_user.do_afters, REF(src)))
		return
	if(disguised_cyborg)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You deactivate \the [src]."))
		deactivate()
		return
	to_chat(cyborg_user, span_notice("You activate \the [src]."))
	playsound(src, 'sound/effects/seedling_chargeup.ogg', 100, TRUE, -6)
	apply_wibbly_filters(cyborg_user)
	if(do_after(cyborg_user, 5 SECONDS, cyborg_user, interaction_key = REF(src), hidden = TRUE) && cyborg_user.cell.use(ACTIVATION_COST))
		playsound(src, 'sound/effects/bamf.ogg', 100, TRUE, -6)
		to_chat(cyborg_user, span_notice("You are now disguised as the Nanotrasen [initial(disguise_model_type.name)] borg \"[disguise_name]\"."))
		activate(cyborg_user)
	else
		to_chat(cyborg_user, span_warning("The chameleon field fizzles."))
		do_sparks(3, FALSE, cyborg_user)
	remove_wibbly_filters(cyborg_user)

/// Applies the disguise and its skin.
/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/cyborg_user)
	START_PROCESSING(SSobj, src)
	if(disguised_cyborg)
		return
	original_name = cyborg_user.name
	original_model_type = cyborg_user.model.type
	original_skin_type = cyborg_user.skin.type
	disguised_cyborg = cyborg_user
	disguised_cyborg.name = disguise_name
	apply_appearance_as(disguised_cyborg, disguise_model_type, disguise_skin_type)
	RegisterSignals(disguised_cyborg, signal_cache, PROC_REF(disrupt))

/// Removes the disguise and resets the skin to the original skin.
/obj/item/borg_chameleon/proc/deactivate()
	STOP_PROCESSING(SSobj, src)
	if(!disguised_cyborg)
		return
	UnregisterSignal(disguised_cyborg, signal_cache)
	do_sparks(5, FALSE, disguised_cyborg)
	apply_appearance_as(disguised_cyborg, original_model_type, original_skin_type)
	disguised_cyborg.name = original_name
	disguised_cyborg = null
	original_name = null
	original_model_type = null
	original_skin_type = null

/// Removes the disguise and tells the cyborg that it happened.
/obj/item/borg_chameleon/proc/disrupt()
	SIGNAL_HANDLER
	if(QDELETED(disguised_cyborg))
		return
	to_chat(disguised_cyborg, span_danger("Your chameleon field deactivates."))
	deactivate()

#undef ACTIVATION_COST
#undef ACTIVATION_UP_KEEP
