/datum/action/cooldown/vampire/targeted/shroud_of_night
	name = "Shroud of Night"
	desc = "Tear a hole into nullspace and let its darkness pour out somewhere you can see."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "blinding_miasma"
	power_explanation = "Click a spot in view. Darkness gathers there for a second, then fills a 3x3 area for 8 seconds.\n\
		Anyone caught inside is blind and can only whisper.\n\
		Creatures that call nullspace home, like darkspawn and nightmares, see through it just fine."
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 60
	cooldown_time = 30 SECONDS
	target_range = 7
	prefire_message = "Select where the darkness should fall."
	costs_double_in_light = TRUE
	shared_cooldown = VAMPIRE_SHARED_COOLDOWN_MIND

/datum/action/cooldown/vampire/targeted/shroud_of_night/fire_targeted_power(atom/target_atom)
	. = ..()
	var/turf/target_turf = get_turf(target_atom)
	owner.visible_message(
		span_danger("[owner]'s shadow stretches out across the floor, and the dark starts to pool!"),
		span_notice("You tear nullspace open and let it pour through."),
	)
	playsound(target_turf, 'sound/effects/nightmare_poof.ogg', 50, TRUE, -1)
	new /obj/effect/temp_visual/shroud_of_night(target_turf, owner)

/// The cloud itself. Gathers for a second as a warning, then blinds whoever is inside.
/obj/effect/temp_visual/shroud_of_night
	name = "shroud of night"
	randomdir = FALSE
	duration = 10 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	alpha = 0
	light_system = COMPLEX_LIGHT
	light_outer_range = 3
	light_power = -4
	light_on = FALSE
	/// Whoever made this, who gets to see through it.
	var/datum/weakref/caster_ref

/obj/effect/temp_visual/shroud_of_night/Initialize(mapload, mob/living/caster)
	. = ..()
	caster_ref = WEAKREF(caster)
	particles = new /particles/lasombra_shadow/cloud
	// the caster gets an empty override instead of the cloud, so they can see what they're doing in there
	if(caster)
		var/image/see_through = image(loc = src)
		see_through.override = TRUE
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person, "shroud_caster_[REF(src)]", see_through, NONE, caster)
	var/matrix/gathering = matrix()
	gathering.Scale(0.3)
	transform = gathering
	animate(src, alpha = 255, transform = matrix(), time = 1 SECONDS, easing = CUBIC_EASING | EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(fall)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(lift)), duration - 1 SECONDS)

/obj/effect/temp_visual/shroud_of_night/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	particles = null
	return ..()

/obj/effect/temp_visual/shroud_of_night/proc/fall()
	set_light(l_on = TRUE)
	START_PROCESSING(SSfastprocess, src)

/obj/effect/temp_visual/shroud_of_night/proc/lift()
	STOP_PROCESSING(SSfastprocess, src)
	set_light(l_on = FALSE)
	particles.spawning = 0
	animate(src, alpha = 0, time = 1 SECONDS)

/obj/effect/temp_visual/shroud_of_night/process(seconds_per_tick)
	for(var/mob/living/victim in range(1, src))
		if(IS_WEAKREF_OF(victim, caster_ref) || victim.stat == DEAD)
			continue
		if(IS_TEAM_DARKSPAWN(victim) || isnightmare(victim))
			continue
		victim.apply_status_effect(/datum/status_effect/shrouded)

/datum/status_effect/shrouded
	id = "shrouded"
	status_type = STATUS_EFFECT_REFRESH
	duration = 0.6 SECONDS
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null

/datum/status_effect/shrouded/on_apply()
	owner.become_blind(TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_userdanger("Darkness swallows you whole. You can't see a thing!"))
	return TRUE

/datum/status_effect/shrouded/on_remove()
	owner.cure_blind(TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_SOFTSPOKEN, TRAIT_STATUS_EFFECT(id))
