/obj/structure/closet/crate/coffin/Destroy()
	unclaim_coffin()
	return ..()

/obj/structure/closet/crate/coffin/examine(mob/user)
	. = ..()
	if(user.mind == resident)
		. += span_cult("This is your Claimed Coffin.")
		. += span_cult("Rest in it while injured to enter Torpor. Entering it with unspent Ranks will allow you to spend one.")
		. += span_cult("Alt-Click while inside the Coffin to Lock/Unlock.")
		. += span_cult("Alt-Click while outside of your Coffin to Unclaim it, unwrenching it and all your other structures as a result.")

/obj/structure/closet/crate/coffin/can_open(mob/living/user, force)
	if(!locked)
		return ..()
	if(user.mind == resident)
		if(welded)
			welded = FALSE
			update_appearance(UPDATE_ICON)
		locked = FALSE
		return TRUE
	playsound(get_turf(src), 'sound/machines/door_locked.ogg', vol = 20, vary = TRUE)
	to_chat(user, span_notice("[src] appears to be locked tight from the inside."))
	return FALSE

/obj/structure/closet/crate/coffin/after_close(mob/living/user, force)
	if(user.loc != src)
		return
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(user)
	if(!vampire)
		return
	if(!vampire.coffin && !resident)
		switch(tgui_alert(user, "Do you wish to claim this as your coffin? [get_area(src)] will be your lair.", "Claim lair", list("Yes", "No")))
			if("Yes")
				claim_coffin(user)
			if("No")
				return
	lock_me(user)

	// You're in a Coffin, everything else is done, you're likely here to heal. Let's offer them the opportunity to do so.
	vampire.check_begin_torpor()

/obj/structure/closet/crate/click_alt(mob/living/user)
	if(!isliving(user) || !IS_VAMPIRE(user))
		return NONE
	if(user.loc == src)
		return lock_me(user) ? CLICK_ACTION_SUCCESS : CLICK_ACTION_BLOCKING
	if(user.mind == resident && user.Adjacent(src))
		balloon_alert(user, "unclaim coffin?")
		var/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
		)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		if(unclaim_response == "Yes")
			unclaim_coffin(TRUE)
		return CLICK_ACTION_SUCCESS
	return NONE

/obj/structure/closet/crate/coffin/crowbar_act(mob/living/user, obj/item/tool)
	if((user.istate & ISTATE_HARM) || !locked)
		return FALSE
	user.visible_message(
		span_notice("[user] tries to pry the lid off of [src] with [tool]."),
		span_notice("You begin prying the lid off of [src] with [tool]."),
	)
	if(!tool.use_tool(src, user, pry_lid_timer))
		return FALSE
	bust_open()
	user.visible_message(
		span_notice("[user] snaps the door of [src] wide open."),
		span_notice("The door of [src] snaps open."),
	)
	return TRUE

/obj/structure/closet/crate/coffin/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!resident)
		return ..()
	to_chat(user, span_danger("The coffin won't detach from the floor.[user.mind == resident ? " You can Alt-Click to unclaim and unwrench your Coffin." : ""]"))
	return TRUE

/obj/structure/closet/crate/coffin/proc/claim_coffin(mob/living/claimer)
	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(claimer)
	if(vampiredatum.claim_coffin(src))
		resident = claimer.mind
		set_anchored(TRUE)

/obj/structure/closet/crate/proc/unclaim_coffin(manual = FALSE)
	if(!resident)
		return

	// Unanchor it (If it hasn't been broken, anyway)
	if(!QDELETED(src))
		set_anchored(FALSE)

	// Unclaiming
	var/datum/antagonist/vampire/vampiredatum = resident.has_antag_datum(/datum/antagonist/vampire)
	if(vampiredatum?.coffin == src)
		vampiredatum.coffin = null
		vampiredatum.vampire_lair_area = null

	for(var/obj/structure/vampire/vampire_structure in get_area(src))
		if(vampire_structure.owner == resident)
			vampire_structure.unbolt()

	if(manual)
		to_chat(resident.current, span_cultitalic("You have unclaimed your coffin! This also unclaims all your other Vampire structures!"))
	else
		to_chat(resident.current, span_cultitalic("You sense that the link with your coffin and your lair has been broken! You will need to seek another."))

	// Remove resident. Because this objec (GC?) we need to give them a way to see they don't have a home anymore.
	resident = null

/obj/structure/closet/crate/proc/lock_me(mob/user, in_locked = TRUE)
	if(user.mind != resident)
		return FALSE
	if(!broken)
		locked = in_locked
		if(locked)
			to_chat(user, span_notice("You flip a secret latch and lock yourself inside [src]."))
		else
			to_chat(user, span_notice("You flip a secret latch and unlock [src]."))
		return TRUE

	// Broken? Let's fix it.
	to_chat(user, span_notice("The secret latch that would lock [src] from the inside is broken. You set it back into place..."))
	if(!do_after(user, 5 SECONDS, src))
		to_chat(user, span_notice("You fail to fix [src]'s mechanism."))
		return TRUE
	to_chat(user, span_notice("You fix the mechanism and lock it."))
	broken = FALSE
	locked = TRUE
	return TRUE

/obj/structure/closet/crate/coffin/blackcoffin
	name = "black coffin"
	desc = "For those departed who are not so dear."
	icon_state = "coffin"
	base_icon_state = "coffin"
	icon = 'icons/vampires/vamp_obj.dmi'
	open_sound = 'sound/vampires/coffin_open.ogg'
	close_sound = 'sound/vampires/coffin_close.ogg'
	breakout_time = 30 SECONDS
	pry_lid_timer = 20 SECONDS
	resistance_flags = NONE
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 2
	armor_type = /datum/armor/blackcoffin

/datum/armor/blackcoffin
	melee = 50
	bullet = 20
	laser = 30
	bomb = 50
	fire = 70
	acid = 60

/obj/structure/closet/crate/coffin/securecoffin
	name = "secure coffin"
	desc = "For those too scared of having their place of rest disturbed."
	icon_state = "securecoffin"
	base_icon_state = "securecoffin"
	icon = 'icons/vampires/vamp_obj.dmi'
	open_sound = 'sound/vampires/coffin_open.ogg'
	close_sound = 'sound/vampires/coffin_close.ogg'
	breakout_time = 35 SECONDS
	pry_lid_timer = 35 SECONDS
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 2
	armor_type = /datum/armor/securecoffin

/datum/armor/securecoffin
	melee = 35
	bullet = 20
	laser = 20
	bomb = 100
	fire = 100
	acid = 100

/obj/structure/closet/crate/coffin/meatcoffin
	name = "meat coffin"
	desc = "When you're ready to meat your maker, the steaks can never be too high."
	icon_state = "meatcoffin"
	base_icon_state = "meatcoffin"
	icon = 'icons/vampires/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF
	open_sound = 'sound/effects/footstep/slime1.ogg'
	close_sound = 'sound/effects/footstep/slime1.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 20 SECONDS
	material_drop = /obj/item/food/meat/slab/human
	material_drop_amount = 3
	armor_type = /datum/armor/meatcoffin

/datum/armor/meatcoffin
	melee = 70
	bullet = 10
	laser = 10
	bomb = 70
	fire = 70
	acid = 60

/obj/structure/closet/crate/coffin/metalcoffin
	name = "metal coffin"
	desc = "A big metal sardine can inside of another big metal sardine can, in space."
	icon_state = "metalcoffin"
	base_icon_state = "metalcoffin"
	icon = 'icons/vampires/vamp_obj.dmi'
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	open_sound = 'sound/effects/pressureplate.ogg'
	close_sound = 'sound/effects/pressureplate.ogg'
	breakout_time = 25 SECONDS
	pry_lid_timer = 30 SECONDS
	material_drop = /obj/item/stack/sheet/iron
	material_drop_amount = 5
	armor_type = /datum/armor/metalcoffin

/datum/armor/metalcoffin
	melee = 40
	bullet = 15
	laser = 50
	bomb = 10
	fire = 70
	acid = 60
