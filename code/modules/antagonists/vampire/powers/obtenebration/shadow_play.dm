#define SHADOW_PLAY_OUTLINE "shadow_play_outline"

/datum/action/cooldown/vampire/shadow_play
	name = "Shadow Play"
	desc = "Pull a little of nullspace's dark around yourself. The lights stay on; they just stop reaching you."
	button_icon = 'icons/mob/actions/actions_darkspawn.dmi'
	button_icon_state = "creep"
	power_explanation = "Toggle a field of darkness around yourself. No light is ever broken, and the dark lifts the moment you turn this off.\n\
		Your other Obtenebration powers cost double in bright light, so this is how you make them cheap.\n\
		Higher levels widen the darkness."
	vampire_power_flags = BP_AM_TOGGLE
	vampire_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 10
	constant_vitaecost = 1
	cooldown_time = 3 SECONDS
	/// How far the darkness reaches, in tiles.
	var/darkness_range = 2
	/// The negative light that follows us around while this is on.
	var/obj/effect/dummy/lasombra_darkness/darkness

/datum/action/cooldown/vampire/shadow_play/two
	darkness_range = 2.5

/datum/action/cooldown/vampire/shadow_play/three
	darkness_range = 3

/datum/action/cooldown/vampire/shadow_play/four
	darkness_range = 3.5

/datum/action/cooldown/vampire/shadow_play/five
	darkness_range = 4

/datum/action/cooldown/vampire/shadow_play/activate_power()
	. = ..()
	var/mob/living/user = owner
	darkness = new(user)
	darkness.set_light(l_outer_range = darkness_range, l_on = TRUE)
	// complex lights only follow their own holder moving, not whoever carries the holder.
	// tenebrous form moves the shadow dummy instead of us, so the dark stays where we sank, which is what we want
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_owner_moved))
	user.add_shared_particles(/particles/lasombra_shadow)
	user.add_filter(SHADOW_PLAY_OUTLINE, 2, outline_filter(size = 1, color = "#000000aa"))
	var/outline = user.get_filter(SHADOW_PLAY_OUTLINE)
	animate(outline, size = 2, time = 1 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(size = 1, time = 1 SECONDS, easing = SINE_EASING)
	user.visible_message(
		span_warning("The light around [user] gutters and dims."),
		span_notice("You draw the dark around you."),
	)

/datum/action/cooldown/vampire/shadow_play/deactivate_power()
	var/mob/living/user = owner
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(darkness)
	user.remove_shared_particles(/particles/lasombra_shadow)
	var/outline = user.get_filter(SHADOW_PLAY_OUTLINE)
	if(outline)
		animate(outline)
		user.remove_filter(SHADOW_PLAY_OUTLINE)
	return ..()

/datum/action/cooldown/vampire/shadow_play/proc/on_owner_moved(datum/source)
	SIGNAL_HANDLER
	darkness?.update_light()

/datum/action/cooldown/vampire/shadow_play/Destroy()
	QDEL_NULL(darkness)
	return ..()

/// Carries Shadow Play's darkness around inside the vampire.
/// Has to be a complex light: a negative overlay light only ever takes a flat 0.5 off a tile, which barely dents a hallway.
/// It gets a negative overlay light on top anyway, since that's the only thing that can eat flashlights and other overlay lights.
/obj/effect/dummy/lasombra_darkness
	name = "darkness"
	light_system = COMPLEX_LIGHT
	light_power = -3
	// the color is what gets taken away, so leaving a bit of red in makes the dark faintly bloody
	light_color = "#e8ffff"

/obj/effect/dummy/lasombra_darkness/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/overlay_lighting, force = TRUE)

#undef SHADOW_PLAY_OUTLINE
