/**
 * Uplinks
 *
 * All /obj/item(s) have a hidden_uplink var. By default it's null. Give the item one with 'new(src') (it must be in it's contents). Then add 'uses.'
 * Use whatever conditionals you want to check that the user has an uplink, and then call interact() on their uplink.
 * You might also want the uplink menu to open if active. Check if the uplink is 'active' and then interact() with it.
**/
/datum/component/uplink
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Name of the uplink
	var/name = "syndicate uplink"
	/// Whether the uplink is currently active or not
	var/active = FALSE
	/// Whether this uplink can be locked or not
	var/lockable = TRUE
	/// Whether the uplink is locked or not.
	var/locked = TRUE
	/// Whether this uplink allows restricted items to be accessed
	var/allow_restricted = TRUE
	/// Key of the current owner of the uplink
	var/owner = null
	/// Purchase log, listing all the purchases this uplink has made
	var/datum/uplink_purchase_log/purchase_log
	/// The current linked uplink handler.
	var/datum/uplink_handler/uplink_handler
	/// Code to unlock the uplink.
	var/unlock_code
	/// Used for pen uplink
	var/list/previous_attempts

	// Not modular variables. These variables should be removed sometime in the future

	/// The unlock text that is sent to the traitor with this uplink. This is not modular and not recommended to expand upon
	var/unlock_text
	/// The unlock note that is sent to the traitor with this uplink. This is not modular and not recommended to expand upon
	var/unlock_note
	/// The failsafe code that causes this uplink to blow up.
	var/failsafe_code
	/// The action used to activate us by certain types of implants
	var/datum/action/innate/activate_uplink/activation_action

/datum/component/uplink/Initialize(
	owner,
	lockable = TRUE,
	enabled = FALSE,
	uplink_flag = UPLINK_TRAITORS,
	starting_tc = TELECRYSTALS_DEFAULT,
	has_progression = FALSE,
	datum/uplink_handler/uplink_handler_override,
)

	if(!isitem(parent) && !istype(parent, /datum/mind) && !istype(parent, /datum/antagonist))
		return COMPONENT_INCOMPATIBLE

	if(owner)
		set_owner(owner)

	src.lockable = lockable
	src.active = enabled
	if(!uplink_handler_override)
		uplink_handler = new()
		uplink_handler.has_objectives = FALSE
		uplink_handler.uplink_flag = uplink_flag
		uplink_handler.telecrystals = starting_tc
		uplink_handler.has_progression = has_progression
		uplink_handler.purchase_log = purchase_log
	else
		uplink_handler = uplink_handler_override

	if(!lockable)
		active = TRUE
		locked = FALSE

/datum/component/uplink/RegisterWithParent()
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(OnAttackBy))

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))
	if(istype(parent, /obj/item/implant))
		RegisterSignal(parent, COMSIG_IMPLANT_ACTIVATED, PROC_REF(implant_activation))
		RegisterSignal(parent, COMSIG_IMPLANT_IMPLANTING, PROC_REF(implanting))
		RegisterSignal(parent, COMSIG_IMPLANT_OTHER, PROC_REF(old_implant))
		RegisterSignal(parent, COMSIG_IMPLANT_EXISTING_UPLINK, PROC_REF(new_implant))
		var/obj/item/implant/implant_parent = parent
		if(implant_parent.imp_in)
			RegisterSignal(implant_parent.imp_in, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

	else if(istype(parent, /obj/item/modular_computer))
		RegisterSignal(parent, COMSIG_TABLET_CHANGE_ID, PROC_REF(new_ringtone))
		RegisterSignal(parent, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(check_detonate))

	else if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(new_message))

	else if(istype(parent, /obj/item/pen))
		previous_attempts = list()
		RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(pen_rotation))

	else if(istype(parent, /obj/item/uplink/replacement))
		RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(on_heard))

	else if(istype(parent, /obj/item/organ))
		activation_action ||= new(null, src)
		RegisterSignal(parent, COMSIG_ORGAN_IMPLANTED, PROC_REF(organ_implanted))
		RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(organ_removed))
		var/obj/item/organ/organ_parent = parent
		if(organ_parent.owner)
			activation_action.Grant(organ_parent.owner)
			RegisterSignal(organ_parent.owner, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

	else if(istype(parent, /datum/mind))
		activation_action ||= new(null, src)
		RegisterSignal(parent, COMSIG_MIND_TRANSFERRED, PROC_REF(mind_transferred))
		var/datum/mind/mind_parent = parent
		if(mind_parent.current)
			activation_action.Grant(mind_parent.current)
			RegisterSignal(mind_parent.current, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

	else if(istype(parent, /datum/antagonist))
		activation_action ||= new(null, src)
		RegisterSignal(parent, COMSIG_ANTAGONIST_INNATE_EFFECTS_APPLIED, PROC_REF(antag_effects_applied))
		RegisterSignal(parent, COMSIG_ANTAGONIST_INNATE_EFFECTS_REMOVED, PROC_REF(antag_effects_removed))
		var/mob/living/current = astype(parent, /datum/antagonist).owner?.current
		if(current)
			activation_action.Grant(current)
			RegisterSignal(current, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))
	//parent type chain end

	if(owner)
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	RegisterSignal(uplink_handler, COMSIG_UPLINK_HANDLER_ON_UPDATE, PROC_REF(handle_uplink_handler_update))
	RegisterSignal(uplink_handler, COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED, PROC_REF(handle_uplink_replaced))

/datum/component/uplink/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_ITEM_ATTACK_SELF))
	if(istype(parent, /obj/item/implant))
		UnregisterSignal(parent, list(COMSIG_IMPLANT_ACTIVATED, COMSIG_IMPLANT_IMPLANTING, COMSIG_IMPLANT_OTHER, COMSIG_IMPLANT_EXISTING_UPLINK))
		var/obj/item/implant/implant_parent = parent
		if(implant_parent.imp_in)
			UnregisterSignal(implant_parent.imp_in, COMSIG_ATOM_ATTACKBY)

	else if(istype(parent, /obj/item/modular_computer))
		UnregisterSignal(parent, list(COMSIG_TABLET_CHANGE_ID, COMSIG_TABLET_CHECK_DETONATE))

	else if(istype(parent, /obj/item/radio))
		UnregisterSignal(parent, COMSIG_RADIO_NEW_MESSAGE)

	else if(istype(parent, /obj/item/pen))
		UnregisterSignal(parent, COMSIG_PEN_ROTATED)

	else if(istype(parent, /obj/item/uplink/replacement))
		UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)

	else if(istype(parent, /obj/item/organ))
		UnregisterSignal(parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
		UnregisterSignal(astype(parent, /obj/item/organ).owner, COMSIG_ATOM_ATTACKBY)

	else if(istype(parent, /datum/mind))
		UnregisterSignal(parent, COMSIG_MIND_TRANSFERRED)
		UnregisterSignal(astype(parent, /datum/mind).current, COMSIG_ATOM_ATTACKBY)

	else if(istype(parent, /datum/antagonist))
		UnregisterSignal(parent, list(COMSIG_ANTAGONIST_INNATE_EFFECTS_APPLIED, COMSIG_ANTAGONIST_INNATE_EFFECTS_REMOVED))
		UnregisterSignal(astype(parent, /datum/antagonist).owner?.current, COMSIG_ATOM_ATTACKBY)
	//parent type chain end

	if(activation_action?.owner)
		activation_action.Remove(activation_action.owner)

	if(owner)
		UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

	UnregisterSignal(uplink_handler, list(COMSIG_UPLINK_HANDLER_ON_UPDATE, COMSIG_UPLINK_HANDLER_REPLACEMENT_ORDERED))

/datum/component/uplink/Destroy()
	QDEL_NULL(activation_action)
	purchase_log = null
	uplink_handler = null
	previous_attempts = null
	return ..()

/datum/component/uplink/PostTransfer()
	if(!isitem(parent) && !istype(parent, /datum/mind) && !istype(parent, /datum/antagonist))
		return COMPONENT_INCOMPATIBLE

/datum/component/uplink/InheritComponent(datum/component/uplink/uplink)
	lockable |= uplink.lockable
	active |= uplink.active
	uplink_handler.uplink_flag |= uplink.uplink_handler.uplink_flag

///Should be called whenever owner is changed
/datum/component/uplink/proc/set_owner(new_owner)
	owner = new_owner
	if(!owner)
		purchase_log = null
		return

	LAZYINITLIST(GLOB.uplink_purchase_logs_by_key)
	if(GLOB.uplink_purchase_logs_by_key[owner])
		purchase_log = GLOB.uplink_purchase_logs_by_key[owner]
	else
		purchase_log = new(owner, src)

/datum/component/uplink/proc/handle_uplink_handler_update()
	SIGNAL_HANDLER
	SStgui.update_uis(src)
	SStgui.update_static_data_for_all_viewers()

/datum/component/uplink/proc/uplink_holder_attackby(atom/attacked, obj/item/stack/telecrystal/attacking_item, mob/living/attacking_mob, params)
	SIGNAL_HANDLER
	if(!istype(attacking_item) || (ismob(attacked) && attacked != attacking_mob))
		return

	to_chat(attacking_mob, span_notice("You press [attacking_item] onto [attacked == attacking_mob ? "yourself" : "\the [attacked]"] \
										and charge [attacked.p_theirs()] hidden uplink."))
	load_tc(attacking_mob, attacking_item)
	return COMPONENT_NO_AFTERATTACK

/// When a new uplink is made via the syndicate beacon it locks all lockable uplinks and destroys replacement uplinks
/datum/component/uplink/proc/handle_uplink_replaced()
	SIGNAL_HANDLER
	if(lockable)
		lock_uplink()
	if(!istype(parent, /obj/item/uplink/replacement))
		return
	var/obj/item/uplink_item = parent
	do_sparks(number = 3, cardinal_only = FALSE, source = uplink_item)
	uplink_item.visible_message(span_warning("The [uplink_item] suddenly combusts!"), vision_distance = COMBAT_MESSAGE_RANGE)
	new /obj/effect/decal/cleanable/ash(get_turf(uplink_item))
	qdel(uplink_item)

/// Adds telecrystals to the uplink. It is bad practice to use this outside of the component itself.
/datum/component/uplink/proc/add_telecrystals(telecrystals_added)
	set_telecrystals(uplink_handler.telecrystals + telecrystals_added)

/// Sets the telecrystals of the uplink. It is bad practice to use this outside of the component itself.
/datum/component/uplink/proc/set_telecrystals(new_telecrystal_amount)
	uplink_handler.telecrystals = new_telecrystal_amount
	uplink_handler.on_update()

/datum/component/uplink/proc/load_tc(mob/user, obj/item/stack/telecrystal/telecrystals, silent = FALSE)
	if(!silent)
		to_chat(user, span_notice("You slot [telecrystals] into [parent] and charge its internal uplink."))
	var/amt = telecrystals.amount
	add_telecrystals(amt)
	telecrystals.use(amt)
	log_uplink("[key_name(user)] loaded [amt] telecrystals into [parent]'s uplink")

/datum/component/uplink/proc/OnAttackBy(datum/source, obj/item/item, mob/user)
	SIGNAL_HANDLER
	if(!active)
		return //no hitting everyone/everything just to try to slot tcs in!

	if(istype(item, /obj/item/stack/telecrystal))
		load_tc(user, item)

	if(!istype(item))
		return

	SEND_SIGNAL(item, COMSIG_ITEM_ATTEMPT_TC_REIMBURSE, user, src)

/datum/component/uplink/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!owner || user.key != owner)
		return

	examine_list += span_warning("[parent] contains your hidden uplink\
		[unlock_code ? ", the code to unlock it is [span_boldwarning(unlock_code)]" : null].")

	if(failsafe_code)
		examine_list += span_warning("The failsafe code is [span_boldwarning(failsafe_code)].")

/datum/component/uplink/proc/interact(datum/source, mob/user)
	SIGNAL_HANDLER

	if(locked || HAS_MIND_TRAIT(user, TRAIT_UPLINK_USE_BLOCKED))
		return

	active = TRUE
	if(user)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
	// an unlocked uplink blocks also opening the PDA or headset menu
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Proc that locks uplinks
/datum/component/uplink/proc/lock_uplink()
	active = FALSE
	locked = TRUE
	SStgui.close_uis(src)

/datum/component/uplink/proc/failsafe(mob/living/carbon/user) //TODO: make this be remotely triggerable
	if(!parent)
		return
	var/turf/T = get_turf(parent)
	if(!T)
		return
	message_admins("[ADMIN_LOOKUPFLW(user)] has triggered an uplink failsafe explosion at [AREACOORD(T)] The owner of the uplink was [ADMIN_LOOKUPFLW(owner)].")
	user.log_message("triggered an uplink failsafe explosion. Uplink owner: [key_name(owner)].", LOG_ATTACK)

	explosion(parent, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3)
	qdel(parent) //Alternatively could brick the uplink.


///Generic action to active an uplink
/datum/action/innate/activate_uplink
	name = "Activate Uplink"
	desc = "Activate a concealed uplink."
	button_icon = 'icons/obj/radio.dmi'
	button_icon_state = "radio"
	///Ref to our uplink component
	var/datum/component/uplink/link

/datum/action/innate/activate_uplink/New(Target, datum/component/uplink/link)
	. = ..()
	src.link = link

/datum/action/innate/activate_uplink/Destroy()
	link = null
	return ..()

/datum/action/innate/activate_uplink/Activate()
	. = ..()
	link.locked = FALSE
	link.interact(null, owner)
