// subtype for organs, like ornithid tongues
/datum/song/organ
	cares_about_distance = FALSE

/datum/song/organ/updateDialog(mob/user)
	var/obj/item/organ/owner = parent
	ui_interact(owner?.owner)

/datum/song/organ/should_stop_playing(obj/player)
	var/obj/item/organ/owner = parent
	return owner?.owner?.stat >= UNCONSCIOUS

/datum/song/organ/do_hearcheck()
	var/obj/item/organ/player = parent
	last_hearcheck = world.time
	var/list/old = hearing_mobs.Copy()
	hearing_mobs.len = 0
	var/turf/source = get_turf(player.owner)
	for(var/mob/M in get_hearers_in_view(instrument_range, player.owner))
		hearing_mobs[M] = get_dist(M, source)
	var/list/exited = old - hearing_mobs
	for(var/i in exited)
		terminate_sound_mob(i)

/datum/action/innate/singing
	name = "Sing"
	desc = "Mimic an instrument and sing."
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE|AB_CHECK_INCAPACITATED
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sing"

/datum/action/innate/singing/Activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/internal/tongue/ornithid/music_maker = human.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(istype(music_maker))
		music_maker?.song?.ui_interact(human)

/datum/component/particle_spewer/music_notes
	icon_file = 'goon/icons/effects/particles.dmi'
	particle_state = "beamed_eighth"

	unusual_description = "melody"
	duration = 2.5 SECONDS
	burst_amount = 2
	spawn_interval = 0.75 SECONDS
	offsets = FALSE

/datum/component/particle_spewer/music_notes/animate_particle(obj/effect/abstract/particle/spawned)
	var/matrix/first = matrix()

	if(prob(30))
		spawned.icon_state = "eighth"
	if(prob(25))
		spawned.icon_state = "quarter"

	spawned.pixel_x += rand(-24, 24)
	spawned.pixel_y += rand(-6, 6)
	first.Turn(rand(-90, 90))
	spawned.transform = first

	. = ..()

/datum/component/particle_spewer/music_notes/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(2, 2, MATRIX_SCALE), time = 0))
	animate_holder.set_transform_type(1, MATRIX_SCALE)

	animate_holder.add_animation_step(list(transform = "RANDOM", alpha = 220, time = 1))
	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_transform_type(2, MATRIX_ROTATE)

	animate_holder.add_animation_step(list(transform = matrix(), time = "RANDOM", pixel_y = 32, alpha = 1))
	animate_holder.set_parent_copy(3, "pixel_y")
	animate_holder.set_random_var(3, "time", list(20, 30))
