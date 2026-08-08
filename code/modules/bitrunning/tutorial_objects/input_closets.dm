/obj/structure/closet/tutorial
	name = "Input Closet"
	desc = "Please deposit the requested item to complete the tutorial!"
	resistance_flags = INDESTRUCTIBLE
	var/datum/tutorial_reward/reward
	var/obj/item/item_to_be_checked = /obj/item/flashlight

/obj/structure/closet/tutorial/Initialize(mapload)
	. = ..()
	set_light(l_outer_range = 3, l_power = 1.4, l_color = LIGHT_COLOR_BLUE)
	reward = new(TUTORIAL_REWARD_LOW)

/obj/structure/closet/tutorial/after_close(mob/living/user, force)
	. = ..()
	for(var/obj/item/stuff in contents)
		if(check_stuff(user, stuff))
			qdel(stuff)
			break

/**
 * Checks if items has the typepath (or its subtypes) of item_to_be_checked
 *
 * Returns TRUE if it does, FALSE otherwise.
 * Override this for finer control over the item checks
 * Arguments:
 * * user - The mob that closed the closet thus completing the tutorial
 * * stuff - stuff that is to be checked
 */
/obj/structure/closet/tutorial/proc/check_stuff(mob/living/user, obj/item/stuff)
	if(istype(stuff, item_to_be_checked))
		reward.award(user)
		return TRUE

	return FALSE

//medical simulation centre
/obj/structure/closet/tutorial/surgery
	name = "Surgical Input Closet"
	desc = "Please input a brain, extracted from a human using organ manipulation to complete this tutorial and gain a reward."
	item_to_be_checked = /obj/item/organ/internal/brain

/obj/structure/closet/tutorial/chemistry
	name = "Pharmaceutical Input Closet"
	desc = "Please input a beaker with at least 30u of Multiver to complete this tutorial and gain a reward."

/obj/structure/closet/tutorial/chemistry/check_stuff(mob/living/user, obj/item/stuff)
	if(!is_reagent_container(stuff))
		return FALSE

	var/obj/item/reagent_containers/container = stuff
	for(var/datum/reagent/chemical in container.reagents?.reagent_list)
		if(istype(chemical, /datum/reagent/medicine/c2/multiver) && (chemical.volume >= 30))
			return TRUE

	return FALSE

/obj/structure/closet/tutorial/virology
	name = "Pathology Input Closet"
	desc = "Please input a petri dish containing a virus with the symptoms of sneezing to complete this tutorial and gain a reward."

/obj/structure/closet/tutorial/virology/check_stuff(mob/living/user, obj/item/stuff)
	if(!istype(stuff, /obj/item/weapon/virusdish))
		return FALSE

	var/obj/item/weapon/virusdish/virus_dish = stuff
	if(locate(/datum/symptom/sneeze) in virus_dish.contained_virus?.symptoms)
		return TRUE

	return FALSE

