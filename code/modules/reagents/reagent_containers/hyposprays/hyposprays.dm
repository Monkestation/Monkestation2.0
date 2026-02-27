GLOBAL_LIST_INIT(hypospray_mode_icons, list(
	HYPO_INJECT = image(icon = 'icons/obj/medical/syringe.dmi', icon_state = "hypo_mode_inject"),
	HYPO_SPRAY = image(icon = 'icons/obj/medical/syringe.dmi', icon_state = "hypo_mode_spray"),
	HYPO_DRAW = image(icon = 'icons/obj/medical/syringe.dmi', icon_state = "hypo_mode_draw"),
))

/obj/item/hypospray
	name = "hypospray"
	icon = 'icons/obj/medical/syringe.dmi'
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon_state = "hypo"
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_COMMAND * 3
	/// Determines what using this hypospray on a person will do
	var/mode = HYPO_INJECT
	/// The amount to transfer from the hypospray
	var/transfer_amount = 5
	/// The different amounts for *transfer_amount* that this hypospray has available
	var/list/possible_transfer_amounts = list(1, 2, 3, 5, 10)
	/// Index of the transfer aomunts list
	var/amount_list_position = 1

	// Container Vars //
	/// The currently inserted container
	var/obj/item/reagent_containers/cup/vial/vial
	/// What containers are allowed within this hypospray
	var/list/allowed_containers = list(/obj/item/reagent_containers/cup/vial, /obj/item/reagent_containers/cup/vial/bluespace)
	/// The default vial that this hypospray starts preloaded with
	var/obj/item/reagent_containers/cup/vial/default_vial

	//  Wait Time Vars  //
	var/inject_other = 1.5 SECONDS
	var/inject_self = 0 SECONDS
	var/spray_other = 1.5 SECONDS
	var/spray_self = 0 SECONDS
	var/draw_other = 0.5 SECONDS
	var/draw_self= 0 SECONDS

	//  Misc Vars  //
	var/upgrade_flags = NONE
	var/can_remove_vials = TRUE

	//	Sound Vars	//
	/// The sound that plays when you insert a vial into the hypospray
	var/load_sound = 'sound/weapons/autoguninsert.ogg'
	/// The sound that plays when you eject a vial from the hypospray
	var/eject_sound = 'sound/weapons/empty.ogg'
	/// The sound that plays when you inject someone with the hypospray
	var/inject_sound = 'sound/items/hypospray.ogg'
	/// The sound that plays when you spray someone with the hypospray
	var/spray_sound = 'sound/effects/spray2.ogg'
	/// The sound that plays when you draw from someone with the hypospray
	var/draw_sound = 'sound/items/autoinjector.ogg'
	/// Buffer for the maximum reagents amount of the most recent vial to be inserted
	var/last_vial_maximum = 15

/obj/item/hypospray/Initialize(mapload)
	. = ..()
	if(default_vial)
		vial = new default_vial

/obj/item/hypospray/examine(mob/user)
	. = ..()
	if(vial)
		. += span_notice("[vial] has [vial.reagents.total_volume]u remaining.")
	else
		. += span_notice("It has no container loaded in.")
	. += span_notice("Currently injects [transfer_amount]u. Ctrl L-click/R-click to increase/decrease transfer amount.")
	if(upgrade_flags & HYPO_UPGRADE_PIERCING)
		. += span_notice("[src] has a polycarbonate diamond tipped needle, allowing it to pierce thick clothing.")
	if(upgrade_flags & HYPO_UPGRADE_SPEED)
		. += span_notice("[src] has gold plated electronics, allowing it to inject with reduced delay.")
	if(upgrade_flags & HYPO_UPGRADE_NOZZLE)
		. += span_notice("[src] has a widened titanium nozzle, allowing it to spray or inject more units at a time.")
	if(!can_remove_vials)
		. += span_notice("It's loading mechanism is blocked, preventing vials from being removed, permanently, once loaded.")
	switch(mode)
		if(HYPO_INJECT)
			. += span_notice("[src] is set to inject contents on application.")
		if(HYPO_SPRAY)
			. += span_notice("[src] is set to spray contents on application.")
		if(HYPO_DRAW)
			. += span_notice("[src] is set to draw on application.")

/obj/item/hypospray/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/reagent_containers))
		if(!(attacking_item.type in allowed_containers)) // I swear there was a better solution to this but i forgor
			user.balloon_alert(user, "won't fit!")
			return FALSE
		if(vial != null)
			if(!unload_vial(user, TRUE))
				return
		if(!user.transferItemToLoc(attacking_item,src))
			return FALSE
		vial = attacking_item
		last_vial_maximum = vial.reagents.maximum_volume
		user.visible_message(span_notice("[user] loads a vial into [src]."),span_notice("You have loaded [vial] into [src]."))
		playsound(src, load_sound, 50, 1)
		return TRUE
	else if(istype(attacking_item, /obj/item/hypospray_upgrade))
		var/obj/item/hypospray_upgrade/upgrade = attacking_item
		upgrade.install(src, user)
		return TRUE

/obj/item/hypospray/attack_self_secondary(mob/user, list/modifiers)
	if(user.can_perform_action(src))
		if("ctrl" in modifiers)
			if(upgrade_flags & HYPO_UPGRADE_NOZZLE)
				set_transfer_amount(user)
				return
			cycle_transfer_amount(BACKWARD, user)
			return
		unload_vial(user)

/obj/item/hypospray/attack_self(mob/user, list/modifiers)
	if(user.can_perform_action(src))
		mode = show_radial_menu(user, src, GLOB.hypospray_mode_icons, radius = 48)
		if(!mode)
			mode = HYPO_INJECT
		user.balloon_alert(user, "mode set to [mode].")

/obj/item/hypospray/item_ctrl_click(mob/user)
	. = ..()
	if(user.get_active_held_item() != src)
		return NONE
	if(upgrade_flags & HYPO_UPGRADE_NOZZLE)
		set_transfer_amount(user)
		return
	cycle_transfer_amount(FORWARD, user)

/obj/item/hypospray/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(vial)
		switch(mode)
			if(HYPO_INJECT)
				if(target.reagents)
					return inject(user, target)
				else
					return ITEM_INTERACT_BLOCKING
			if(HYPO_SPRAY)
				return spray(user, target)
			if(HYPO_DRAW)
				if(target.reagents)
					return draw(user, target)
				else
					return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_BLOCKING

/obj/item/hypospray/proc/cycle_transfer_amount(direction, user)
	var/list_len = length(possible_transfer_amounts)
	if(!list_len)
		return
	switch(direction)
		if(FORWARD)
			amount_list_position = (amount_list_position % list_len) + 1
		if(BACKWARD)
			amount_list_position = (amount_list_position - 1) || list_len
		else
			CRASH("cycle_transfer_amount() called with invalid direction value")
	transfer_amount = possible_transfer_amounts[amount_list_position]
	balloon_alert(user, "transferring [transfer_amount]u")

/obj/item/hypospray/proc/set_transfer_amount(mob/user)
	var/new_transfer_amount = tgui_input_number(user, "Set transfer amount", "Transfer Amount", 5, last_vial_maximum, 0.1, round_value = FALSE)
	if(!new_transfer_amount || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src))
		return
	transfer_amount = new_transfer_amount
	balloon_alert(user, "transferring [transfer_amount]u")

/obj/item/hypospray/proc/inject(mob/living/user, atom/target)
	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE_INJECT, user)

	if(!vial.reagents.total_volume)
		user.balloon_alert(user, container empty!")
		return ITEM_INTERACT_BLOCKING

	if(!isliving(target) && !target.is_injectable(user))
		user.balloon_alert(user, "you cannot directly fill [target]!")
		return ITEM_INTERACT_BLOCKING

	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		user.balloon_alert(user, "[target] is full!")
		return ITEM_INTERACT_BLOCKING

	var/contained = vial.reagents.get_reagent_log_string()
	log_combat(user, target, "attempted to inject with a hypospray", src, addition="which had [contained]")

	var/use_delay = (target == user) ? inject_self : inject_other
	var/inject_flags = upgrade_flags & HYPO_UPGRADE_PIERCING ? INJECT_CHECK_PENETRATE_THICK : null
	var/self_use = (target == user) ? TRUE : FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(!living_target.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE|inject_flags))
			return ITEM_INTERACT_BLOCKING

		if(!self_use)
			living_target.visible_message(
				span_danger("[user] is trying to inject [living_target]!"),
				span_userdanger("[user] is trying to inject you!"),
			)

		if(use_delay) // Skip entirely if no delay, to avoid drawing a bar at all
			if(!do_after(user, CHEM_INTERACT_DELAY(use_delay, user), living_target))
				return ITEM_INTERACT_BLOCKING

		if(!self_use)
			living_target.visible_message(
				span_danger("[user] injects [living_target] with the hypospray!"),
				span_userdanger("[user] injects you with the hypospray!"),
			)

		if(living_target == user)
			living_target.log_message("injected themselves ([contained]) with [src]", LOG_ATTACK, color="orange")
		else
			log_combat(user, living_target, "injected", src, addition="which had [contained]")

		playsound(src, inject_sound, 50, 1)

	//The actual reagent transfer
	if(vial.reagents.trans_to(target, transfer_amount, transfered_by = user, methods = INJECT))
		to_chat(user, span_notice("You inject [transfer_amount] units of the solution. The vial now contains [vial.reagents.total_volume] units."))
		target.update_appearance()
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/item/hypospray/proc/spray(mob/living/user, atom/target) // Colorful Reagent hypos when?
	if(!vial.reagents.total_volume)
		user.balloon_alert(user, "container empty!")
		return ITEM_INTERACT_BLOCKING

	var/contained = vial.reagents.get_reagent_log_string()
	log_combat(user, target, "attempted to spray with a hypospray", src, addition="which had [contained]")

	var/use_delay = (target == user) ? spray_self : spray_other
	var/self_use = (target == user) ? TRUE : FALSE

	if(isliving(target))
		var/mob/living/living_target = target
		if(!self_use)
			living_target.visible_message(
				span_danger("[user] is trying to spray [living_target]!"),
				span_userdanger("[user] is trying to spray you!"),
			)
		if(use_delay) // Skip entirely if no delay, to avoid drawing a bar at all
			if(!do_after(user, CHEM_INTERACT_DELAY(use_delay, user), living_target))
				return ITEM_INTERACT_BLOCKING

		if(!self_use)
			living_target.visible_message(
				span_danger("[user] sprays [living_target] with the hypospray!"),
				span_userdanger("[user] sprays you with the hypospray!"),
			)

		if(living_target == user)
			living_target.log_message("sprayed themselves ([contained]) with [src]", LOG_ATTACK, color="orange")
		else
			log_combat(user, living_target, "sprayed", src, addition="which had [contained]")

		playsound(src, spray_sound, 50, 1)
	//The actual reagent transfer
	var/datum/reagents/holder = new()
	vial.reagents.trans_to(holder, transfer_amount, methods = INJECT)
	holder.expose(target, VAPOR)
	qdel(holder)
	to_chat(user, span_notice("You spray [transfer_amount] units of the solution. The vial now contains [vial.reagents.total_volume] units."))
	target.update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/hypospray/proc/draw(mob/living/user, atom/target)
	if(vial.reagents.total_volume >= vial.reagents.maximum_volume)
		user.balloon_alert(user, "container full!")
		return ITEM_INTERACT_BLOCKING

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE_WITHDRAW, user)

	var/use_delay = (target == user) ? draw_self : draw_other
	var/self_use = (target == user) ? TRUE : FALSE
	var/inject_flags = upgrade_flags & HYPO_UPGRADE_PIERCING ? INJECT_CHECK_PENETRATE_THICK : null

	if(isliving(target))
		var/mob/living/living_target = target

		if(!living_target.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE|inject_flags))
			return ITEM_INTERACT_BLOCKING

		if(!self_use)
			target.visible_message(
				span_danger("[user] is trying to take a blood sample from [target]!"),
				span_userdanger("[user] is trying to take a blood sample from you!"),
			)
		if(use_delay)
			if(!do_after(user, CHEM_INTERACT_DELAY(use_delay, user), living_target))
				return ITEM_INTERACT_BLOCKING

		if(living_target.transfer_blood_to(vial, transfer_amount))
			user.visible_message(span_notice("[user] takes a blood sample from [living_target]."))
			playsound(src, draw_sound, 50, 1)
			return ITEM_INTERACT_SUCCESS
		else
			to_chat(user, span_warning("You are unable to draw any blood from [living_target]!"))
			return ITEM_INTERACT_BLOCKING

	if(!target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty!"))
		return ITEM_INTERACT_BLOCKING

	if(!target.is_drawable(user))
		to_chat(user, span_warning("You cannot directly remove reagents from [target]!"))
		return ITEM_INTERACT_BLOCKING

	if(target.reagents.trans_to(vial.reagents, transfer_amount, transfered_by = user))
		to_chat(user, span_notice("You draw [transfer_amount] units of the solution. The vial now contains [vial.reagents.total_volume] units."))
		playsound(src, draw_sound, 50, 1)
		target.update_appearance()
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/hypospray/proc/unload_vial(mob/user, silent = FALSE)
	if(vial)
		if(!can_remove_vials)
			return FALSE
		if(!silent)
			to_chat(user, span_notice("You remove the [vial] from [src]."))
			playsound(src, eject_sound, 50, 1)
		vial.forceMove(user.loc)
		user.put_in_hands(vial)
		vial = null
		return TRUE
	else
		to_chat(user, span_notice("This hypo isn't loaded!"))
		return FALSE

/obj/item/hypospray/cmo
	name = "Deluxe Hypospray"
	icon_state = "hypo_cmo"
	desc = "The Deluxe Hypospray can use larger size vials, and deliver more reagents per injection."
	allowed_containers = list(/obj/item/reagent_containers/cup/vial/large/bluespace, /obj/item/reagent_containers/cup/vial/large, /obj/item/reagent_containers/cup/vial/bluespace)
	possible_transfer_amounts = list(1, 2, 3, 5, 10, 15, 20)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	inject_other = 1 SECONDS
	draw_other = 0 SECONDS
	spray_other = 0.5 SECONDS

//combat

/obj/item/hypospray/combat
	name = "Combat Hypospray"
	icon_state = "hypo_combat"
	desc = "A reverse engineered Syndicate Hypospray. Capable of using large vials, and piercing armor."
	allowed_containers = list(/obj/item/reagent_containers/cup/vial/large/bluespace, /obj/item/reagent_containers/cup/vial/large, /obj/item/reagent_containers/cup/vial/bluespace)
	possible_transfer_amounts = list(1, 2, 3, 5, 10, 15, 20)
	upgrade_flags = HYPO_UPGRADE_PIERCING
	default_vial = /obj/item/reagent_containers/cup/vial/large/combat

/obj/item/hypospray/combat/no_vial
	default_vial = null

/obj/item/hypospray/combat/anti_tox
	name = "Combat Hypospray (Anti-Tox)"
	desc = "A advanced hypospray, preloaded with a antitoxin mix."
	icon_state = "hypo_combat_tox"
	possible_transfer_amounts = list(1, 2, 3, 5, 10, 15, 20, 40, 60)
	default_vial = /obj/item/reagent_containers/cup/vial/large/pen_acid

/obj/item/hypospray/combat/nanites
	name = "Combat Hypospray (Nanites)"
	desc = "A advanced hypospray, preloaded with a advanced and experimental nanite combat mix."
	icon_state = "nanite_hypo"
	possible_transfer_amounts = list(1, 2, 3, 5, 10, 15, 20, 40, 60)
	can_remove_vials = FALSE
	default_vial = /obj/item/reagent_containers/cup/vial/large/ert

/obj/item/hypospray/combat/heresypurge
	name = "Combat Hypospray (Holy)"
	desc = "A advanced hypospray, preloaded with a blessed mix, damaging to all heretical entities."
	icon_state = "holy_hypo"
	possible_transfer_amounts = list(1, 2, 3, 5, 10, 15, 20, 40, 60)
	can_remove_vials = FALSE
	default_vial = /obj/item/reagent_containers/cup/vial/large/ert/holy
