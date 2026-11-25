#define ABYSSAL_GRASP_FILTER "abyssal_grasp"

/datum/action/cooldown/vampire/targeted/arms_of_the_abyss
	name = "Arms of the Abyss"
	desc = "Drag an arm of nullspace up through the dark floor beneath someone to hold them."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "abyssal_call"
	power_explanation = "Click someone in view who is standing in the dark. A shadowy arm rises under them and follows them through the dark for a second, then grabs them.\n\
		Getting into the light before it grabs leaves it behind.\n\
		Anyone it grabs is heavily slowed for 5 seconds, but can still act.\n\
		The grip holds through your own blows, but breaks if anyone else hurts them or they step into the light."
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 40
	cooldown_time = 20 SECONDS
	target_range = 7
	prefire_message = "Select someone standing in the dark."
	costs_double_in_light = TRUE

/datum/action/cooldown/vampire/targeted/arms_of_the_abyss/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target_atom))
		return FALSE
	if(!is_abyssal_arm_floor(target_atom.loc))
		owner.balloon_alert(owner, "they're not in the dark!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/arms_of_the_abyss/fire_targeted_power(atom/target_atom)
	. = ..()
	new /obj/effect/abyssal_arm(target_atom.loc, owner, target_atom)

/proc/is_abyssal_arm_floor(turf/target)
	if(!isopenturf(target) || isspaceturf(target) || isopenspaceturf(target))
		return FALSE
	return is_obtenebration_dark(target)

/// The arm itself. Rises for a second (that's your warning), grabs, then sinks back down.
/obj/effect/abyssal_arm
	name = "arm of the abyss"
	desc = "A grasping limb of solid dark, reaching up out of the floor."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath_tentacle_spawn"
	color = "#1a0a10"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_system = COMPLEX_LIGHT
	light_outer_range = 1.5
	light_power = -1
	/// Whoever summoned us, so we don't grab them.
	var/datum/weakref/caster_ref
	var/datum/weakref/quarry_ref

/obj/effect/abyssal_arm/Initialize(mapload, mob/living/caster, mob/living/quarry)
	. = ..()
	caster_ref = WEAKREF(caster)
	quarry_ref = WEAKREF(quarry)
	RegisterSignal(quarry, COMSIG_MOVABLE_MOVED, PROC_REF(on_quarry_moved))
	add_filter("abyssal_arm_outline", 1, outline_filter(size = 1, color = "#7a0018"))
	playsound(src, 'sound/effects/nightmare_poof.ogg', 40, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(wiggle)), 0.7 SECONDS)

/obj/effect/abyssal_arm/proc/on_quarry_moved(mob/living/source)
	SIGNAL_HANDLER
	if(is_abyssal_arm_floor(source.loc))
		forceMove(source.loc)

/obj/effect/abyssal_arm/proc/wiggle()
	icon_state = "goliath_tentacle_wiggle"
	addtimer(CALLBACK(src, PROC_REF(grab)), 0.3 SECONDS)

/obj/effect/abyssal_arm/proc/grab()
	var/mob/living/quarry = quarry_ref?.resolve()
	if(quarry)
		UnregisterSignal(quarry, COMSIG_MOVABLE_MOVED)
	for(var/mob/living/victim in loc)
		if(IS_WEAKREF_OF(victim, caster_ref) || victim.stat == DEAD)
			continue
		visible_message(span_danger("[src] wraps around [victim]'s legs!"))
		victim.apply_status_effect(/datum/status_effect/abyssal_grasp, caster_ref)
	addtimer(CALLBACK(src, PROC_REF(retract)), 0.5 SECONDS)

/obj/effect/abyssal_arm/proc/retract()
	icon_state = "goliath_tentacle_retract"
	QDEL_IN(src, 0.7 SECONDS)

/datum/status_effect/abyssal_grasp
	id = "abyssal_grasp"
	status_type = STATUS_EFFECT_REFRESH
	duration = 5 SECONDS
	tick_interval = 0.2 SECONDS
	alert_type = null
	var/datum/weakref/caster_ref

/datum/status_effect/abyssal_grasp/on_creation(mob/living/new_owner, datum/weakref/caster_ref)
	src.caster_ref = caster_ref
	return ..()

/datum/status_effect/abyssal_grasp/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/abyssal_grasp)
	owner.AddElement(/datum/element/relay_attackers)
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	owner.add_filter(ABYSSAL_GRASP_FILTER, 3, outline_filter(size = 1, color = "#000000"))
	var/outline = owner.get_filter(ABYSSAL_GRASP_FILTER)
	animate(outline, size = 3, time = 0.5 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(size = 1, time = 0.5 SECONDS, easing = SINE_EASING)
	to_chat(owner, span_userdanger("Cold hands of shadow close around your legs!"))
	return TRUE

/datum/status_effect/abyssal_grasp/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/abyssal_grasp)
	UnregisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED)
	animate(owner.get_filter(ABYSSAL_GRASP_FILTER))
	owner.remove_filter(ABYSSAL_GRASP_FILTER)

/datum/status_effect/abyssal_grasp/tick(seconds_between_ticks)
	if(is_obtenebration_dark(get_turf(owner)))
		return
	to_chat(owner, span_notice("The light burns the shadows off you."))
	qdel(src)

/datum/status_effect/abyssal_grasp/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] wreathed in grasping shadow.")

/datum/status_effect/abyssal_grasp/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(!(attack_flags & ATTACKER_DAMAGING_ATTACK) || IS_WEAKREF_OF(attacker, caster_ref))
		return
	to_chat(owner, span_notice("The pain jolts you free of the shadows!"))
	qdel(src)

/datum/movespeed_modifier/status_effect/abyssal_grasp
	multiplicative_slowdown = 2

#undef ABYSSAL_GRASP_FILTER
