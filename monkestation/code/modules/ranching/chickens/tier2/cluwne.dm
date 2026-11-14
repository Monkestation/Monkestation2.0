/mob/living/basic/chicken/clown_sad
	icon_suffix = "sad_clown"
	worn_slot_flags = null

	breed_name_male = "huOnkHoNkHoeNK"
	breed_name_female = "huOnkHoNkHoeNK"
	minimum_survivable_temperature = 0

	egg_type = /obj/item/food/egg/clown_sad
	mutation_list = list()

	targeted_ability = /datum/action/cooldown/mob_cooldown/chicken/honk

	book_desc = "These are the product of being incredibly cruel to your Henks. Space PETA would be furious."
/// Clucking mad, goes after anyone on the station
/mob/living/basic/chicken/clown_sad/pick_ability_target(datum/ai_controller/controller)
	var/list/clucking_mad = list()
	for(var/mob/living/carbon/human/unlucky in GLOB.player_list)
		clucking_mad |= unlucky
	return length(clucking_mad) ? pick(clucking_mad) : null

/obj/item/food/egg/clown_sad
	name = "Clown? Egg"
	icon_state = "clown"

	layer_hen_type = /mob/living/basic/chicken/clown_sad

/datum/status_effect/ranching/angry_honk
	id = "pissed_sad_clown"
	duration = 5 SECONDS

/datum/status_effect/ranching/angry_honk/on_apply()
	owner.pass_flags |= PASSMOB
	owner.pass_flags |= PASSDOORS
	owner.pass_flags |= PASSGRILLE
	owner.pass_flags |= PASSGLASS
	owner.pass_flags |= PASSCLOSEDTURF
	return ..()

/datum/status_effect/ranching/angry_honk/on_remove()
	owner.pass_flags -= PASSMOB
	owner.pass_flags -= PASSDOORS
	owner.pass_flags -= PASSGRILLE
	owner.pass_flags -= PASSGLASS
	owner.pass_flags -= PASSCLOSEDTURF
