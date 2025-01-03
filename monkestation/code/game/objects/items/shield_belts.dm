/obj/item/shield_belt
	name = "shield belt"
	desc = "A belt that engulfs the user in a shield that blocks both incoming and outgoing high-energy projectiles."
	icon = 'monkestation/icons/obj/items/shield_belts.dmi'
	icon_state = "shield_belt"
	worn_icon = 'monkestation/icons/mob/clothing/belt.dmi'
	worn_icon_state = "shield_belt"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	inhand_icon_state = "utility"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes", "disciplines")
	attack_verb_simple = list("whip", "lash", "discipline")
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	w_class = WEIGHT_CLASS_BULKY
	/// The mob wearing our shield
	var/mob/wearer
	/// Should we actually work
	var/cored = FALSE
	/// The current health of our shield
	var/current_shield_integrity
	/// The maximum health of our shield
	var/maximum_shield_integrity = 120
	/// Toggles if the shield should regenerate naturally or not
	var/shield_regeneration = FALSE
	/// The color of the shield
	var/shield_color = COLOR_BLUE_LIGHT

/obj/item/shield_belt/examine(mob/user)
	. = ..()
	if(!cored)
		. += span_notice("The shield belt appears to have no flux core powering it.")
		return

	if(current_shield_integrity > 1)
		var/shield_health = floor((current_shield_integrity / maximum_shield_integrity) * 100)
		. += span_notice("The shield's charge indicator shows [shield_health]%")
	else if(shield_regeneration)
		var/shield_health = floor((-current_shield_integrity / maximum_shield_integrity) * 100)
		. += span_notice("The shield's charge indicator shows the shield is offline, with its reboot progress at [shield_health]%")

/obj/item/shield_belt/Initialize(mapload)
	. = ..()
	current_shield_integrity = maximum_shield_integrity
	if(shield_regeneration)
		START_PROCESSING(SSobj, src)
	if(!cored)
		name = "inactive [name]"

/obj/item/shield_belt/Destroy(force)
	if(wearer)
		deactivate_shield()
	if(shield_regeneration)
		STOP_PROCESSING(SSobj, src)
	return ..()

// Okay this might be a TINY BIT cursed but it emulates very well what rimworld does so forgive me
/obj/item/shield_belt/process(seconds_per_tick)
	switch(current_shield_integrity)
		if(-INFINITY to -120) // Enough time has passed, regenerate the shield
			current_shield_integrity = seconds_per_tick
			if(wearer)
				ADD_TRAIT(wearer, TRAIT_NOGUNS, "shield belt")
				update_color(TRUE)

		if(-119.9 to 0) // Start slowly regenerating the shield's charge, 60 seconds will fix us up
			current_shield_integrity -= seconds_per_tick * 2

		else
			current_shield_integrity = min(current_shield_integrity + (seconds_per_tick * 2), maximum_shield_integrity)
			if(wearer)
				update_color(FALSE)

/obj/item/shield_belt/emp_act(severity)
	. = ..()
	if(current_shield_integrity > 0)
		if(wearer)
			REMOVE_TRAIT(wearer, TRAIT_NOGUNS, "shield belt")
			wearer.remove_filter("shield_filter")
			wearer.visible_message(span_danger("[wearer]'s [src] overloads from the EMP, its shield immediatelly dissapearing!"))
		playsound(src, 'sound/effects/magic.ogg', BLOCK_SOUND_VOLUME, vary = TRUE)
		do_sparks(5, source = src)

	current_shield_integrity = 0

/obj/item/shield_belt/attackby(obj/item/attacking_item, mob/user, params)
	if(!cored && istype(attacking_item, /obj/item/assembly/signaler/anomaly/flux))
		qdel(attacking_item)
		user.visible_message(span_notice("[user] slots [attacking_item] into [src], powering it on!"))
		cored = TRUE
		shield_regeneration = TRUE
		icon_state = "[icon_state]_active"
		name = initial(name)
		START_PROCESSING(SSobj, src)
		if(wearer)
			activate_shield()
		return TRUE

	return ..()

/obj/item/shield_belt/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(wearer && !(slot & ITEM_SLOT_BELT))
		if(cored)
			deactivate_shield()
		return

	if(slot & ITEM_SLOT_BELT)
		wearer = user
		if(cored)
			activate_shield()

/obj/item/shield_belt/proc/activate_shield()
	if(current_shield_integrity > 0)
		update_color(TRUE)
	ADD_TRAIT(wearer, TRAIT_NOGUNS, "shield belt")
	RegisterSignal(wearer, COMSIG_PROJECTILE_PREHIT, PROC_REF(block_user_getting_shot_and_dying_horribly))

/obj/item/shield_belt/proc/deactivate_shield()
	if(current_shield_integrity > 0)
		wearer.remove_filter("shield_filter")
	REMOVE_TRAIT(wearer, TRAIT_NOGUNS, "shield belt")
	UnregisterSignal(wearer, COMSIG_PROJECTILE_PREHIT)
	wearer = null

/obj/item/shield_belt/proc/update_color(add_filter = TRUE)
	var/list/good = rgb2num(shield_color)
	var/list/bad = rgb2num(COLOR_RED)
	var/proportion = current_shield_integrity / maximum_shield_integrity
	var/colour_first = rgb(proportion * good[1] + (1 - proportion) * bad[1], proportion * good[2] + (1 - proportion) * bad[2], proportion * good[3] + (1 - proportion) * bad[3], 70)
	var/colour_second = rgb((proportion * good[1] + (1 - proportion) * bad[1]) * 0.8, (proportion * good[2] + (1 - proportion) * bad[2]) * 0.8, (proportion * good[3] + (1 - proportion) * bad[3]) * 0.8, 70)
	if(add_filter)
		wearer?.add_filter("shield_filter", 10, outline_filter(2, colour_first))
	wearer.transition_filter("shield_filter", list(size = 2, color = colour_second), 2 SECONDS, easing = SINE_EASING, loop = -1)
	animate(time = 2 SECONDS, color = colour_first, easing = SINE_EASING, loop = -1)

/obj/item/shield_belt/proc/block_user_firing(...)
	SIGNAL_HANDLER
	if(current_shield_integrity)
		to_chat(wearer, span_danger("You cannot fire a gun whilst your shield belt is active!"))
		return COMPONENT_CANCEL_GUN_FIRE

/obj/item/shield_belt/proc/block_user_getting_shot_and_dying_horribly(mob/living/victim, list/signal_args, obj/projectile/bullet)
	SIGNAL_HANDLER
	if(!current_shield_integrity || wearer.stat == DEAD)
		return

	if(current_shield_integrity <= bullet.damage)
		bullet.damage -= current_shield_integrity
		current_shield_integrity = 0
		REMOVE_TRAIT(wearer, TRAIT_NOGUNS, "shield belt")
		wearer.remove_filter("shield_filter")
		playsound(src, 'sound/effects/magic.ogg', BLOCK_SOUND_VOLUME, vary = TRUE)
		wearer.visible_message(span_danger("The [bullet] shatters the energy field surrounding [wearer]!"), span_userdanger("The [bullet] shatters your energy field!"))
		do_sparks(3, source = src)
		return

	current_shield_integrity -= bullet.damage
	update_color(FALSE)
	wearer.visible_message(span_warning("An energy field surrounding [wearer] blocks the [bullet]!"))
	var/owner_turf = get_turf(wearer)
	new block_effect(owner_turf, shield_color)
	playsound(src, 'sound/effects/empulse.ogg', BLOCK_SOUND_VOLUME, vary = TRUE)
	return PROJECTILE_INTERRUPT_HIT

// Holy shit is this a rimworld reference? (as if this whole item wasn't) ((not even vanilla rimworld))
/obj/item/shield_belt/archotech
	name = "archotech shield belt"
	desc = "A belt that engulfs the user in a shield that blocks both incoming and outgoing high-energy projectiles.\
			This one is from a long lost rimworld and whilst being precious it uses an unknown power source that cannot recharge."
	icon_state = "shield_belt_archotech"
	maximum_shield_integrity = 540 // 450% more than a normal shield belt... bit much aint it?
	shield_color = COLOR_EMERALD
	cored = TRUE
