//all the parent type specific signal handlers go here

#define PEN_ROTATIONS 2
// Implant signal responses
/datum/component/uplink/proc/implant_activation()
	SIGNAL_HANDLER

	var/obj/item/implant/implant = parent
	locked = FALSE
	interact(null, implant.imp_in)

/datum/component/uplink/proc/implanting(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/mob/user = arguments[2]
	set_owner(user.key)

/datum/component/uplink/proc/old_implant(datum/source, list/arguments, obj/item/implant/new_implant)
	SIGNAL_HANDLER

	// It kinda has to be weird like this until implants are components
	return SEND_SIGNAL(new_implant, COMSIG_IMPLANT_EXISTING_UPLINK, src)

/datum/component/uplink/proc/new_implant(datum/source, datum/component/uplink/uplink)
	SIGNAL_HANDLER

	return COMPONENT_DELETE_NEW_IMPLANT

// PDA signal responses
/datum/component/uplink/proc/new_ringtone(datum/source, mob/living/user, new_ring_text)
	SIGNAL_HANDLER

	if(trim(lowertext(new_ring_text)) != trim(lowertext(unlock_code)))
		if(trim(lowertext(new_ring_text)) == trim(lowertext(failsafe_code)))
			failsafe(user)
			return COMPONENT_STOP_RINGTONE_CHANGE
		return
	locked = FALSE
	interact(null, user)
	to_chat(user, span_hear("The computer softly beeps."))
	return COMPONENT_STOP_RINGTONE_CHANGE

/datum/component/uplink/proc/check_detonate()
	SIGNAL_HANDLER

	return COMPONENT_TABLET_NO_DETONATE

// Radio signal responses
/datum/component/uplink/proc/new_frequency(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/obj/item/radio/master = parent
	var/frequency = arguments[1]
	if(frequency != unlock_code)
		if(frequency == failsafe_code)
			failsafe(master.loc)
		return
	locked = FALSE
	if(ismob(master.loc))
		interact(null, master.loc)

/datum/component/uplink/proc/new_message(datum/source, mob/living/user, message, channel)
	SIGNAL_HANDLER

	if(channel != RADIO_CHANNEL_UPLINK)
		return

	if(!findtext(lowertext(message), lowertext(unlock_code)))
		if(failsafe_code && findtext(lowertext(message), lowertext(failsafe_code)))
			failsafe(user)  // no point returning cannot radio, youre probably ded
		return
	locked = FALSE
	interact(null, user)
	to_chat(user, "As you whisper the code into your headset, a soft chime fills your ears.")
	return COMPONENT_CANNOT_USE_RADIO

// Pen signal responses
/datum/component/uplink/proc/pen_rotation(datum/source, degrees, mob/living/carbon/user)
	SIGNAL_HANDLER

	var/obj/item/pen/master = parent
	previous_attempts += degrees
	if(length(previous_attempts) > PEN_ROTATIONS)
		popleft(previous_attempts)

	if(compare_list(previous_attempts, unlock_code))
		locked = FALSE
		previous_attempts.Cut()
		master.degrees = 0
		interact(null, user)
		to_chat(user, span_warning("Your pen makes a clicking noise, before quickly rotating back to 0 degrees!"))

	else if(compare_list(previous_attempts, failsafe_code))
		failsafe(user)

/datum/component/uplink/proc/setup_unlock_code()
	unlock_code = generate_code()
	var/obj/item/P = parent
	if(istype(parent,/obj/item/modular_computer))
		unlock_note = "<B>Uplink Passcode:</B> [unlock_code] ([P.name])."
	else if(istype(parent,/obj/item/radio))
		unlock_note = "<B>Radio Passcode:</B> [unlock_code] ([P.name], [RADIO_TOKEN_UPLINK] channel)."
	else if(istype(parent,/obj/item/pen))
		unlock_note = "<B>Uplink Degrees:</B> [english_list(unlock_code)] ([P.name])."

/datum/component/uplink/proc/generate_code()
	var/returnable_code = ""

	if(istype(parent, /obj/item/modular_computer))
		returnable_code = "[rand(100,999)] [pick(GLOB.phonetic_alphabet)]"

	else if(istype(parent, /obj/item/radio))
		returnable_code = pick(GLOB.phonetic_alphabet)

	else if(istype(parent, /obj/item/pen))
		returnable_code = list()
		for(var/i in 1 to PEN_ROTATIONS)
			returnable_code += rand(1, 360)

	if(!unlock_code) // assume the unlock_code is our "base" code that we don't want to duplicate, and if we don't have an unlock code, immediately return out of it since there's nothing to compare to.
		return returnable_code

	// duplicate checking, re-run the proc if we get a dupe to prevent the failsafe explodey code being the same as the unlock code.
	if(islist(returnable_code))
		if(english_list(returnable_code) == english_list(unlock_code)) // we pass english_list to the user anyways and for later processing, so we can just compare the english_list of the two lists.
			return generate_code()

	else if(unlock_code == returnable_code)
		return generate_code()

	return returnable_code

// Replacement uplink signal responses
/// Proc that unlocks a locked replacement uplink when it hears the unlock code from their datum
/datum/component/uplink/proc/on_heard(datum/source, list/hearing_args)
	SIGNAL_HANDLER
	if(!locked)
		return
	if(!findtext(hearing_args[HEARING_RAW_MESSAGE], unlock_code))
		return
	var/atom/replacement_uplink = parent
	locked = FALSE
	replacement_uplink.balloon_alert_to_viewers("beep", vision_distance = COMBAT_MESSAGE_RANGE)

//organ parent
/datum/component/uplink/proc/organ_implanted(obj/item/organ/implanted, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	activation_action.Grant(receiver)
	RegisterSignal(receiver, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

/datum/component/uplink/proc/organ_removed(obj/item/organ/removed, mob/living/carbon/old_owner)
	SIGNAL_HANDLER
	activation_action.Remove(old_owner)
	UnregisterSignal(old_owner, COMSIG_ATOM_ATTACKBY)

//mind parent
/datum/component/uplink/proc/mind_transferred(datum/mind/transferred, mob/previous_body)
	SIGNAL_HANDLER
	activation_action.Remove(previous_body)
	activation_action.Grant(transferred.current)
	UnregisterSignal(previous_body, COMSIG_ATOM_ATTACKBY)
	RegisterSignal(transferred.current, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

//antag datum parent
/datum/component/uplink/proc/antag_effects_applied(datum/antagonist/gained, mob/living/applied_to)
	SIGNAL_HANDLER
	activation_action.Grant(applied_to)
	RegisterSignal(applied_to, COMSIG_ATOM_ATTACKBY, PROC_REF(uplink_holder_attackby))

/datum/component/uplink/proc/antag_effects_removed(datum/antagonist/lost, mob/living/removed_from)
	SIGNAL_HANDLER
	activation_action.Remove(removed_from)
	UnregisterSignal(removed_from, COMSIG_ATOM_ATTACKBY)

#undef PEN_ROTATIONS
