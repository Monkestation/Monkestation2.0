/**
 * Blow up the mob into giblets
 *
 * Arguments:
 * * no_brain - Should the mob NOT drop a brain?
 * * no_organs - Should the mob NOT drop organs?
 * * no_bodyparts - Should the mob NOT drop bodyparts?
*/
/mob/living/proc/gib(no_brain, no_organs, no_bodyparts, safe_gib = TRUE)
	var/prev_lying = lying_angle
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	ghostize()
	spill_organs(no_brain, no_organs, no_bodyparts)

	if(!no_bodyparts)
		spread_bodyparts(no_brain, no_organs, TRUE)

	spawn_gibs(no_bodyparts)
	///lol I want it to be bloody as fuck
	blood_particles(5, min_deviation = 70, max_deviation = 120, min_pixel_z = 4, max_pixel_z = 11)
	blood_particles(6, min_deviation = -70, max_deviation = -30, min_pixel_z = 5, max_pixel_z = 7)
	blood_particles(4, min_deviation = -190, max_deviation = -80, min_pixel_z = 0, max_pixel_z = 9)
	blood_particles(7, min_deviation = 130, max_deviation = 160, min_pixel_z = 12, max_pixel_z = 16)
	blood_particles(4, min_deviation = -200, max_deviation = -220, min_pixel_z = 4, max_pixel_z = 6)
	blood_particles(2, min_deviation = 161, max_deviation = 200, min_pixel_z = 2, max_pixel_z = 12)
	///lol
	SEND_SIGNAL(src, COMSIG_LIVING_GIBBED, no_brain, no_organs, no_bodyparts)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	if(flags_1 & HOLOGRAM_1)
		return
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/mob/living/proc/spill_organs()
	return

/mob/living/proc/spread_bodyparts(skip_head, skip_organs, violent)
	return

/// Length of the animation in dust_animation.dmi
#define DUST_ANIMATION_TIME 1.3 SECONDS

/**
 * This is the proc for turning a mob into ash.
 * Dusting robots does not eject the MMI, so it's a bit more powerful than gib()
 *
 * Arguments:
 * * just_ash - If TRUE, ash will spawn where the mob was, as opposed to remains
 * * drop_items - Should the mob drop their items before dusting?
 * * force - Should this mob be FORCABLY dusted?
*/
/mob/living/proc/dust(just_ash, drop_items, force)
	death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	addtimer(CALLBACK(src, PROC_REF(spawn_dust), just_ash), DUST_ANIMATION_TIME - 0.3 SECONDS)
	ghostize()
	QDEL_IN(src, DUST_ANIMATION_TIME) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/// Animates turning into dust.
/// Does not delete src afterwards, BUT it will become invisible (and grey), so ensure you handle that yourself
/atom/movable/proc/dust_animation(atom/anim_loc = src.loc)
	if(isnull(anim_loc)) // the effect breaks if we have a null loc
		return
	var/obj/effect/temp_visual/dust_animation_filter/dustfx = new(anim_loc, REF(src))
	add_filter("dust_animation", 1, displacement_map_filter(render_source = dustfx.render_target, size = 256))
	add_filter("dust_color", 1, color_matrix_filter())
	transition_filter("dust_color", color_matrix_filter(COLOR_MATRIX_GRAYSCALE), DUST_ANIMATION_TIME - 0.3 SECONDS)
	animate(src, alpha = 0, time = DUST_ANIMATION_TIME - 0.1 SECONDS, easing = SINE_EASING | EASE_IN)

/// Holds the dust animation filter effect, so we can animate it
/obj/effect/temp_visual/dust_animation_filter
	icon = 'icons/mob/dust_animation.dmi'
	icon_state = "dust.1"
	duration = DUST_ANIMATION_TIME
	randomdir = FALSE

/obj/effect/temp_visual/dust_animation_filter/Initialize(mapload, anim_id = "random_default_anti_collision_text")
	. = ..()
	// we manually animate this, rather than just using an animated icon state or flick, to work around byond animated state memes
	// (normally, all animated icon states are synced to the same time, which would bad here)
	for(var/i in 2 to duration)
		if(PERFORM_ALL_TESTS(focus_only/runtime_icon_states) && !icon_exists(icon, "dust.[i]"))
			stack_trace("Missing dust animation icon state: dust.[i]")
		animate(src, time = 1, icon_state = "dust.[i]", flags = ANIMATION_CONTINUE)
	if(PERFORM_ALL_TESTS(focus_only/runtime_icon_states) && icon_exists(icon, "dust.[duration + 1]"))
		stack_trace("Extra dust animation icon state: dust.[duration + 1]")
	render_target = "*dust-[anim_id]"

#undef DUST_ANIMATION_TIME

/**
 * Spawns dust / ash or remains where the mob was
 *
 * just_ash: If TRUE, just ash will spawn where the mob was, as opposed to remains
 */
/mob/living/proc/spawn_dust(just_ash = FALSE)
	var/ash_type = /obj/effect/decal/cleanable/ash
	if(mob_size >= MOB_SIZE_LARGE)
		ash_type = /obj/effect/decal/cleanable/ash/large

	var/obj/effect/decal/cleanable/ash/ash = new ash_type(loc)
	ash.pixel_z = -5
	ash.pixel_w = rand(-1, 1)

/*
 * Called when the mob dies. Can also be called manually to kill a mob.
 *
 * Arguments:
 * * gibbed - Was the mob gibbed?
*/
/mob/living/proc/death(gibbed)
	if(stat == DEAD)
		return FALSE

	if(!gibbed && (death_sound || death_message || (living_flags & ALWAYS_DEATHGASP)))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "deathgasp")

	set_stat(DEAD)
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/death_turf = get_turf(src)
	var/area/death_area = get_area(src)
	// Display a death message if the mob is a player mob (has an active mind)
	var/player_mob_check = mind && mind.name && mind.active
	// and, display a death message if the area allows it (or if they're in nullspace)
	var/valid_area_check = !death_area || !(death_area.area_flags & NO_DEATH_MESSAGE)
	if(player_mob_check)
		if(valid_area_check)
			deadchat_broadcast(" has died at <b>[get_area_name(death_turf)]</b>.", "<b>[mind.name]</b>", follow_target = src, turf_target = death_turf, message_type=DEADCHAT_DEATHRATTLE)
		if(SSlag_switch.measures[DISABLE_DEAD_KEYLOOP] && !client?.holder)
			to_chat(src, span_deadsay(span_big("Observer freelook is disabled.\nPlease use Orbit, Teleport, and Jump to look around.")))
			ghostize(TRUE)
	set_disgust(0)
	SetSleeping(0, 0)
	reset_perspective(null)
	reload_fullscreen()
	update_mob_action_buttons()
	update_damage_hud()
	update_health_hud()
	med_hud_set_health()
	med_hud_set_status()
	stop_pulling()

	set_ssd_indicator(FALSE)

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_MOB_DEATH, src, gibbed)

	if (client)
		client.move_delay = initial(client.move_delay)

	persistent_client?.time_of_death = timeofdeath

	return TRUE
