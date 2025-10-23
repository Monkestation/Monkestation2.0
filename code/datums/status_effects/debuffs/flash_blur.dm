/// The size of the gaussian blur applied to the screen when flashed.
#define FLASH_BLUR_AMOUNT 50
/// The time it takes for the flash blur to fully "fade in" to full intensity
#define FLASH_BLUR_FADE_IN_TIME (1 SECONDS)
/// The time it takes for the flash blur to fade out to remove the blur.
#define FLASH_BLUR_FADE_OUT_TIME (0.5 SECONDS)

/mob/living
	/// Timer ID for removing the screenblur from being flashed.
	/// Needed to prevent jank where being re-flashed while the blur is fading out can just completely remove the blur.
	var/flash_timer

/mob/living/Destroy()
	if(flash_timer)
		deltimer(flash_timer)
		flash_timer = null
	return ..()

/datum/status_effect/flash_blur
	id = "flash_blur"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	remove_on_fullheal = TRUE
	on_remove_on_mob_delete = TRUE

/datum/status_effect/flash_blur/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/flash_blur/on_apply()
	remove_owner_timer()
	// Refresh the blur when a client jumps into the mob, in case we get put on a clientless mob with no hud
	RegisterSignal(owner, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	// Apply initial blur
	if(owner.hud_used)
		var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.add_filter("flash_blur", 10, gauss_blur_filter(size = 0))
		game_plane_master_controller.transition_filter("flash_blur", gauss_blur_filter(size = FLASH_BLUR_AMOUNT), FLASH_BLUR_FADE_IN_TIME)
	return TRUE

/datum/status_effect/flash_blur/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_LOGIN)
	if(!owner.hud_used)
		return

	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.transition_filter("flash_blur", gauss_blur_filter(size = 0), FLASH_BLUR_FADE_OUT_TIME)
	owner.flash_timer = addtimer(CALLBACK(game_plane_master_controller, TYPE_PROC_REF(/datum, remove_filter), "flash_blur"), FLASH_BLUR_FADE_OUT_TIME + 1, TIMER_STOPPABLE | TIMER_OVERRIDE | TIMER_UNIQUE)

/datum/status_effect/flash_blur/refresh(effect, ...)
	remove_owner_timer()
	if(owner.hud_used)
		var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		game_plane_master_controller.transition_filter("flash_blur", gauss_blur_filter(size = FLASH_BLUR_AMOUNT), FLASH_BLUR_FADE_IN_TIME)
	return ..()

/// Updates the blur of the owner of the status effect.
/// Also a signal proc for [COMSIG_MOB_LOGIN], to trigger then when the mob gets a client.
/datum/status_effect/flash_blur/proc/on_login(datum/source)
	SIGNAL_HANDLER
	if(!owner.hud_used || QDELETED(src))
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = owner.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("flash_blur", 10, gauss_blur_filter(size = FLASH_BLUR_AMOUNT))

/datum/status_effect/flash_blur/proc/remove_owner_timer()
	if(!owner.flash_timer)
		return
	deltimer(owner.flash_timer)
	owner.flash_timer = null

#undef FLASH_BLUR_FADE_OUT_TIME
#undef FLASH_BLUR_FADE_IN_TIME
#undef FLASH_BLUR_AMOUNT
