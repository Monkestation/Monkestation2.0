/obj/structure/vampire
	pass_flags_self = parent_type::pass_flags_self | LETPASSCLICKS
	/// Who owns this structure?
	var/datum/mind/owner
	/*
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/ghost_desc
	var/vampire_desc
	var/vassal_desc
	var/curator_desc

/obj/structure/vampire/Destroy()
	owner = null
	return ..()

/obj/structure/vampire/examine(mob/user)
	. = ..()
	if(!user.mind && ghost_desc)
		. += span_cult(ghost_desc)
	if(IS_VAMPIRE(user) && vampire_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential")
			return
		. += span_cult(vampire_desc)
	if(IS_VASSAL(user) && vassal_desc)
		. += span_cult(vassal_desc)
	if(IS_VAMPIRE_HUNTER(user) && curator_desc)
		. += span_cult(curator_desc)

/// This handles bolting down the structure.
/obj/structure/vampire/proc/bolt(mob/user)
	if(!user?.mind)
		return
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Vampire Tip: Examine [src] to understand how it functions!"))
	user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(TRUE)
	owner = user.mind

/// This handles unbolting of the structure.
/obj/structure/vampire/proc/unbolt(mob/user)
	if(user)
		to_chat(user, span_danger("You have unsecured [src]."))
		user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
	set_anchored(FALSE)
	owner = null

/obj/structure/vampire/attackby(obj/item/item, mob/living/user, params)
	/// If a Vampire tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_VAMPIRE(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Vampire Tip: Examine vampire structures to understand how they function!"))
		return
	return ..()

/obj/structure/vampire/attack_hand(mob/user, list/modifiers)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(user)
	/// Claiming the Rack instead of using it?
	if(vampiredatum && !owner)
		if(!vampiredatum.vampire_lair_area)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(vampiredatum.vampire_lair_area != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [vampiredatum.vampire_lair_area]."))
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, span_notice("Do you wish to secure [src] here?"))
		var/list/secure_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"))
		var/secure_response = show_radial_menu(user, src, secure_options, radius = 36, require_near = TRUE)
		if(secure_response == "Yes")
			bolt(user)
		return FALSE
	return TRUE

/obj/structure/vampire/click_alt(mob/user)
	if(!owner || user != owner.current || !user.Adjacent(src))
		return NONE
	balloon_alert(user, "unbolt [src]?")
	var/list/unsecure_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
	)
	var/unsecure_response = show_radial_menu(user, src, unsecure_options, radius = 36, require_near = TRUE)
	if(unsecure_response == "Yes")
		unbolt(user)
	return CLICK_ACTION_SUCCESS
