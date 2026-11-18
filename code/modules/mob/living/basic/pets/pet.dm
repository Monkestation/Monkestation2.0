/mob/living/basic/pet
	icon = 'icons/mob/simple/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	blood_volume = BLOOD_VOLUME_NORMAL

	/// if the mob is protected from being renamed by collars.
	var/unique_pet = FALSE
	var/static/list/pet_foods = list(
		/obj/item/food/
	)

/mob/living/basic/pet/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_ADVANCEDTOOLUSER, TRAIT_CAN_STRIP), ROUNDSTART_TRAIT)
	AddElement(/datum/element/dextrous)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_BAREFOOT)
	AddElement(/datum/element/basic_eating, heal_amt = 10, food_types = pet_foods)
	AddComponent(/datum/component/personal_crafting)

/mob/living/basic/pet/attackby(obj/item/thing, mob/user, params)
	if(istype(thing, /obj/item/newspaper) && !stat)
		user.visible_message(span_notice("[user] baps [name] on the nose with the rolled up [thing]."))
		dance_rotate(src)
		return TRUE

	return ..()

/mob/living/basic/pet/death(gibbed)
	. = ..()
	add_memory_in_range(src, 7, /datum/memory/pet_died, deuteragonist = src) //Protagonist is the person memorizing it
