/// How much damage you take from an emp when wearing a hardsuit
#define HARDSUIT_EMP_BURN 2 // a very orange number
#define THERMAL_REGULATOR_COST 6 // this runs out fast if 18

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon = 'monkestation/icons/obj/clothing/hardsuits/suit.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/hardsuit/hardsuit_body.dmi'
	icon_state = "hardsuit-engineering"
	max_integrity = 300
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/hardsuit
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals,
		/obj/item/tank/jetpack,
		/obj/item/t_scanner,
		/obj/item/construction/rcd,
		/obj/item/pipe_dispenser,
	)
	siemens_coefficient = 0
	actions_types = list(/datum/action/item_action/toggle_spacesuit)
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)

	/// Type of helmet that is attached to our hardsuit. Can be retracted/deployed at a press of a button. Should never be null
	var/hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit
	/// If our helmet is deployed. If the suit is removed and re-equipped, the helmet will automatically deploy if it was already engaged
	var/helmet_deployed = FALSE

	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/hardsuit_type

/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	if(isnull(hardsuit_helmet))
		CRASH("[type] is a hardsuit which does not have a `hardsuit_helmet` defined")
	AddComponent(\
		/datum/component/toggle_attached_clothing,\
		deployable_type = hardsuit_helmet,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Helmet",\
		on_deployed = CALLBACK(src, PROC_REF(on_helmet_toggle)),\
		on_removed = CALLBACK(src, PROC_REF(on_helmet_toggle)),\
	)
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)

/// Plays a sound when the helmet is toggled
/obj/item/clothing/suit/space/hardsuit/proc/on_helmet_toggle()
	playsound(loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(jetpack)
		QDEL_NULL(jetpack)
	return ..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return ..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, span_warning("[src] already has a jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, span_notice("You successfully install the jetpack into [src]."))
			return
	else if(!cell_cover_open && I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, span_warning("[src] has no jetpack installed."))
			return
		if(src == user.get_item_by_slot(ITEM_SLOT_OCLOTHING))
			to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, span_notice("You successfully remove the jetpack from [src]."))
		return
	return ..()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	. = ..()
	if(jetpack)
		if(slot == ITEM_SLOT_OCLOTHING)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	. = ..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/// Burn the person inside the hard suit just a little, the suit got really hot for a moment
/obj/item/clothing/suit/space/emp_act(severity)
	. = ..()
	var/mob/living/carbon/human/user = src.loc
	if(istype(user))
		user.apply_damage(HARDSUIT_EMP_BURN, BURN, spread_damage=TRUE)
		to_chat(user, span_warning("You feel \the [src] heat up from the EMP burning you slightly."))

		// Chance to scream
		if (user.stat < UNCONSCIOUS && prob(10))
			user.emote("scream")

//////////////// JETPACK /////////////////////
/obj/item/tank/jetpack/suit
	name = "hardsuit jetpack upgrade"
	desc = "A modular, compact set of thrusters designed to integrate with a hardsuit. It has its own internal buffer which must be refilled by gas."
	icon_state = "jetpack-mining"
	inhand_icon_state = "jetpack-black"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/toggle_jetpack, /datum/action/item_action/jetpack_stabilization)
	volume = 70
	slot_flags = null
	gas_type = null
	full_speed = FALSE
	/// The person wearing the suit
	var/mob/living/carbon/human/active_user = null
	/// The hardsuit the jetpack is placed inside
	var/obj/item/clothing/suit/space/hardsuit/active_hardsuit = null

/obj/item/tank/jetpack/suit/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/tank/jetpack/suit/Destroy()
	if(on)
		turn_off()
	return ..()

/obj/item/tank/jetpack/suit/attack_self()
	return

/obj/item/tank/jetpack/suit/cycle(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit))
		to_chat(user, span_warning("\The [src] must be connected to a hardsuit!"))
		return
	return ..()

/obj/item/tank/jetpack/suit/turn_on(mob/user)
	if(!istype(loc, /obj/item/clothing/suit/space/hardsuit) || !ishuman(loc.loc) || loc.loc != user)
		return FALSE

	. = ..()
	if(!.)
		active_user = null
		return
	active_hardsuit = loc
	RegisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED, PROC_REF(on_hardsuit_moved))
	RegisterSignal(active_user, COMSIG_QDELETING, PROC_REF(on_user_del))
	START_PROCESSING(SSobj, src)

/obj/item/tank/jetpack/suit/turn_off(mob/user)
	STOP_PROCESSING(SSobj, src)
	if(active_hardsuit)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = null
	if(active_user)
		UnregisterSignal(user, COMSIG_QDELETING)
		active_user = null
	return ..()

/// Called when the jetpack moves, presumably away from the hardsuit.
/obj/item/tank/jetpack/suit/proc/on_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit) && ishuman(loc.loc) && loc.loc == active_user)
		UnregisterSignal(active_hardsuit, COMSIG_MOVABLE_MOVED)
		active_hardsuit = loc
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_hardsuit_moved))
		return
	turn_off(active_user)

/// Called when the hardsuit loc moves, presumably away from the human user.
/obj/item/tank/jetpack/suit/proc/on_hardsuit_moved(atom/movable/source, atom/old_loc, movement_dir, forced, list/atom/old_locs)
	SIGNAL_HANDLER
	turn_off(active_user)

/// Called when the human wearing the suit that contains this jetpack is deleted.
/obj/item/tank/jetpack/suit/proc/on_user_del(mob/living/carbon/human/source, force)
	SIGNAL_HANDLER
	turn_off(active_user)
