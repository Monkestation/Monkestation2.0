/datum/antagonist/evil_clone
	name = "\improper Evil Clone"
	show_in_antagpanel = TRUE
	roundend_category = "evil clones"
	antagpanel_category = "Evil Clones"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_count_points = 1
	stinger_sound = 'sound/ambience/antag/revolutionary_tide.ogg'

/datum/antagonist/evil_clone/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/evil_clone/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	current.AddElement(/datum/element/cult_eyes, initial_delay = 0 SECONDS)

/datum/antagonist/evil_clone/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if (HAS_TRAIT(current, TRAIT_UNNATURAL_RED_GLOWY_EYES))
		current.RemoveElement(/datum/element/cult_eyes)
