#define TENEBROUS_RISE_FILTER "tenebrous_rise"

/datum/action/cooldown/vampire/tenebrous_form
	name = "Tenebrous Form"
	desc = "Slip halfway into nullspace and become nothing but a shadow on the floor."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "void_jaunt"
	power_explanation = "Toggle while standing somewhere dark. You sink into your own shadow and become untouchable, sliding freely across dark tiles.\n\
		Light throws you back out, and so does running out of blood. You can't use other powers while you're a shadow, and your Shadow Play stays where you sank.\n\
		Very expensive to keep up."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 100
	constant_vitaecost = 8
	cooldown_time = 30 SECONDS
	costs_double_in_light = TRUE
	/// The shadow we're hiding in while this is on.
	var/obj/effect/dummy/phased_mob/shadow/lasombra/shadow

/datum/action/cooldown/vampire/tenebrous_form/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(SSticker.current_state < GAME_STATE_FINISHED)
		var/area/owner_area = get_area(owner)
		if((owner_area.area_flags & NOTELEPORT) || (owner_turf.turf_flags & NOJAUNT))
			owner.balloon_alert(owner, "something blocks the way!")
			return FALSE
	if(!is_obtenebration_dark(owner_turf))
		owner.balloon_alert(owner, "too bright here!")
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/tenebrous_form/activate_power()
	. = ..()
	var/mob/living/user = owner
	var/turf/pool_turf = get_turf(user)
	new /obj/effect/temp_visual/tenebrous_sink(pool_turf, user)
	new /obj/effect/temp_visual/shadow_pool(pool_turf)
	playsound(pool_turf, 'sound/effects/nightmare_poof.ogg', 50, TRUE, -1)
	user.visible_message(span_danger("[user] sinks into [user.p_their()] own shadow and is gone!"))
	shadow = new(pool_turf, user)
	user.add_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN), REF(src))
	RegisterSignal(shadow, COMSIG_MOB_EJECTED_FROM_JAUNT, PROC_REF(on_ejected))
	RegisterSignal(user, COMSIG_ATOM_INTERNAL_EXPLOSION, PROC_REF(on_internal_explosion))

/datum/action/cooldown/vampire/tenebrous_form/continue_active()
	. = ..()
	if(!.)
		return FALSE
	return owner.loc == shadow

/datum/action/cooldown/vampire/tenebrous_form/deactivate_power()
	var/mob/living/user = owner
	UnregisterSignal(user, COMSIG_ATOM_INTERNAL_EXPLOSION)
	if(shadow)
		UnregisterSignal(shadow, COMSIG_MOB_EJECTED_FROM_JAUNT)
		if(user.loc == shadow)
			shadow.eject_jaunter()
		shadow = null
	if(HAS_TRAIT_FROM(user, TRAIT_MAGICALLY_PHASED, REF(src)))
		user.remove_traits(list(TRAIT_MAGICALLY_PHASED, TRAIT_RUNECHAT_HIDDEN), REF(src))
		rise(user)
	return ..()

/// Plays the "climbing back out of the dark" effect on whoever just left the shadow.
/datum/action/cooldown/vampire/tenebrous_form/proc/rise(mob/living/user)
	var/turf/rise_turf = get_turf(user)
	if(rise_turf)
		new /obj/effect/temp_visual/shadow_pool(rise_turf)
	user.add_filter(TENEBROUS_RISE_FILTER, 10, color_matrix_filter(list(0,0,0, 0,0,0, 0,0,0, 0,0,0)))
	animate(user.get_filter(TENEBROUS_RISE_FILTER), color = list(1,0,0, 0,1,0, 0,0,1, 0,0,0), time = 1 SECONDS, easing = SINE_EASING)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/datum, remove_filter), TENEBROUS_RISE_FILTER), 1 SECONDS)

/datum/action/cooldown/vampire/tenebrous_form/proc/on_ejected(datum/source, mob/living/unjaunter)
	SIGNAL_HANDLER
	deactivate_power()

/// Blowing yourself up inside the shadow just throws you back out.
/datum/action/cooldown/vampire/tenebrous_form/proc/on_internal_explosion(datum/source)
	SIGNAL_HANDLER
	deactivate_power()

/obj/effect/dummy/phased_mob/shadow/lasombra
	name = "shadow"
	healing_rate = 0
	light_max = LIGHTING_TILE_IS_DARK

/// A shadowy copy of someone melting down into the floor.
/obj/effect/temp_visual/tenebrous_sink
	randomdir = FALSE
	duration = 0.6 SECONDS

/obj/effect/temp_visual/tenebrous_sink/Initialize(mapload, atom/movable/mimic)
	. = ..()
	if(QDELETED(mimic))
		return INITIALIZE_HINT_QDEL
	appearance = mimic.appearance
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	setDir(mimic.dir)
	var/matrix/squashed = matrix(transform)
	squashed.Scale(1.3, 0.05)
	squashed.Translate(0, -14)
	animate(src, color = "#000000", time = 0.2 SECONDS)
	animate(transform = squashed, alpha = 0, time = 0.4 SECONDS, easing = QUAD_EASING | EASE_IN)

/// A quick burst of black wisps where a Lasombra went into or came out of the dark.
/obj/effect/temp_visual/shadow_pool
	randomdir = FALSE
	duration = 1.6 SECONDS
	layer = BELOW_MOB_LAYER

/obj/effect/temp_visual/shadow_pool/Initialize(mapload)
	. = ..()
	particles = new /particles/lasombra_shadow/dense
	addtimer(CALLBACK(src, PROC_REF(stop_spawning)), 0.4 SECONDS)

/obj/effect/temp_visual/shadow_pool/Destroy()
	particles = null
	return ..()

/obj/effect/temp_visual/shadow_pool/proc/stop_spawning()
	particles.spawning = 0

#undef TENEBROUS_RISE_FILTER
