#define HEAVEN_TIMETOGO (1<<0)
#define HEAVEN_TIMETOGO_PLAYED (1<<1)

/atom/movable/screen/fullscreen/divine
	icon = 'monkestation/code/modules/divine_warning/icons/divine_warning.dmi'
	icon_state = "he_waits_for_you"
	layer = EMISSIVE_LAYER_UNBLOCKABLE
	alpha = 120

/mob/living/proc/flash_divine_overlay(alpha = 120, soundvolume = 80, time = 2 SECONDS)
	if(client?.prefs)
		if(client.prefs.read_preference(/datum/preference/toggle/darkened_flash))
			clear_fullscreen("divine", time)
			return
	if (world.time - last_divine_sound > 2.5 SECONDS)
		soundvolume *= 0.8
		SEND_SOUND(src, sound('monkestation/code/modules/divine_warning/sounds/divine.ogg', volume = soundvolume))
		overlay_fullscreen("divine", /atom/movable/screen/fullscreen/divine, 1, alpha)
		last_divine_sound = world.time

	clear_fullscreen("divine", time)

/mob/living/death(gibbed)
	. = ..()
	if (!client || !src.mind || stat == DEAD) return

	if (HAS_TRAIT(src, TRAIT_SPIRITUAL) || src.mind.holy_role > 0)
		SEND_SOUND(src, sound('monkestation/code/modules/divine_warning/sounds/divine.ogg', 80))
		last_divine_sound = world.time

/mob/living
	var/last_divine_sound = 0
	var/heaven_flags = 0

/mob/living/update_damage_hud()
	. = ..()
	// if (!client || !HAS_TRAIT(src, TRAIT_DIVINE)) return
	if (!client || !src?.mind) return

	if(health <= hardcrit_threshold && (HAS_TRAIT(src, TRAIT_SPIRITUAL) || src.mind.holy_role > 0) && stat != DEAD)
		// playsound(src, 'monkestation/code/modules/divine_warning/sounds/divine.ogg', 60, TRUE, use_reverb = TRUE, pressure_affected = FALSE, )
		var/severity = 0.2
		switch(health)
			if(-40 to -30)
				severity = 0.5
				heaven_flags = 0
			if(-50 to -40)
				severity = 1
				heaven_flags = 0
			if(-50 to -40)
				severity = 2
				heaven_flags = 0
			if(-60 to -50)
				severity = 3
				heaven_flags = 0
			if(-70 to -60)
				severity = 4
				heaven_flags = 0
			if(-90 to -70)
				severity = 5
				heaven_flags = 0
			if(-95 to -90)
				severity = 6
				heaven_flags |= HEAVEN_TIMETOGO
			if(-INFINITY to -95)
				severity = 7
				heaven_flags |= HEAVEN_TIMETOGO
		if(health < -90)
			if (heaven_flags & HEAVEN_TIMETOGO && !(heaven_flags & HEAVEN_TIMETOGO_PLAYED))
				SEND_SOUND(src, sound('monkestation/code/modules/divine_warning/sounds/heaven_time.ogg'))
				heaven_flags |= HEAVEN_TIMETOGO_PLAYED

		var/atom/movable/screen/fullscreen/divine/base_divine
		var/alpha = initial(base_divine.alpha) * (severity / 10)
		var/soundvolume = 100 * (severity / 10)
		flash_divine_overlay(alpha, soundvolume)

#undef HEAVEN_TIMETOGO
#undef HEAVEN_TIMETOGO_PLAYED
