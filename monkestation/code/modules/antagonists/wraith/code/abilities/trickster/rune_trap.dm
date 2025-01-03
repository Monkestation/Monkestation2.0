#define trap_icons 'monkestation/code/modules/antagonists/wraith/icons/radial_menu_icons.dmi'

/datum/action/cooldown/spell/wraith/rune_trap
	name = "Rune Trap"
	desc = "Create a trap below your feet to harm foes. Can only be done whilst materialized."
	button_icon_state = "rune_trap"

	essence_cost = 50
	cooldown_time = 30 SECONDS

	var/list/trap_effects = list(
//		"Madness" = icon(trap_icons, "madness"), -- Give someone a monke AI
		"Burning" = icon(trap_icons, "burning"),
		"Teleporting" = icon(trap_icons, "teleporting"),
		"Illusions" = icon(trap_icons, "illusions"),
		"EMP" = icon(trap_icons, "EMP"),
		"Blinding" = icon(trap_icons, "blinding"),
//		"Sleepyness" = icon(trap_icons, "sleepyness"),
		"Random" = icon(trap_icons, "random"),
	)

/datum/action/cooldown/spell/wraith/rune_trap/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE

	if(!owner.density)
		if(feedback)
			to_chat(owner, span_warning("You can't cast [src] whilst unmaterialized!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/wraith/rune_trap/cast(atom/cast_on)
	. = ..()
	var/choice = show_radial_menu(owner, owner, trap_effects, radius = 60, tooltips = TRUE)
	if(choice == "Random")
		choice = pick(trap_effects - "Random")

	switch(choice)
		if("Madness") // TODO

		if("Burning")
			new /obj/structure/wraith_trap/burning(get_turf(owner))

		if("Teleporting")
			new /obj/structure/wraith_trap/teleport(get_turf(owner))

		if("Illusions")
			new /obj/structure/wraith_trap/illusions(get_turf(owner))

		if("EMP")
			new /obj/structure/wraith_trap/emp(get_turf(owner))

		if("Blinding")
			new /obj/structure/wraith_trap/blinding(get_turf(owner))

		if("Sleepyness") // TODO

		else
			reset_spell_cooldown()

/obj/structure/wraith_trap // not to mistake for /obj/structure/trap
	name = "strange rune"
	desc = "Probably would be wise to not step on it."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "alert_rune"
	density = FALSE
	anchored = TRUE

	var/antimagic_flags = MAGIC_RESISTANCE_HOLY

/obj/structure/wraith_trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	START_PROCESSING(SSobj, src)

/obj/structure/wraith_trap/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/wraith_trap/process(seconds_per_tick)
	var/turf/our_turf = get_turf(src)
	var/light = our_turf.get_lumcount()
	light *= 255 // We convert it into alpha
	if(alpha != light)
		animate(src, time = (seconds_per_tick / 4) SECONDS, alpha = light)

/obj/structure/wraith_trap/proc/on_entered(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || iswraith(victim))
		return

	if(victim.can_block_magic(antimagic_flags))
		visible_message("[src] dissapears below [victim] as they step on it!")
		qdel(src)
		return

	to_chat(victim, span_userdanger("You feel something grasp at your leg!"))
	trap_effect(victim)
	qdel(src)

/obj/structure/wraith_trap/proc/trap_effect(mob/living/target)
	return

/obj/structure/wraith_trap/burning/trap_effect(mob/living/target)
	explosion(src, flame_range = 2)
	target.apply_damage(35, BURN, spread_damage = TRUE) // An actual light explosion was too much

/obj/structure/wraith_trap/teleport/trap_effect(mob/living/target)
	var/turf/target_turf = get_turf(target)
	do_teleport(target, target_turf, 10, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/structure/wraith_trap/illusions/trap_effect(mob/living/target)
	target.adjust_hallucinations_up_to(1 MINUTE, 2 MINUTES)

/obj/structure/wraith_trap/emp/trap_effect(mob/living/target)
	target.emp_act(EMP_HEAVY) // Wow, so simple

/obj/structure/wraith_trap/blinding/trap_effect(mob/living/target)
	target.flash_act(affect_silicon = 1, length = 2 SECONDS)
	target.Stun(4 SECONDS) // Its what it does on goon, but is it really right?
	to_chat(target, span_danger("[src] emits a blinding light as you step on it!"))

#undef trap_icons
