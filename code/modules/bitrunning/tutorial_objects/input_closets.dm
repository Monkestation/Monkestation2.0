/obj/structure/closet/tutorial
	name = "Input Closet"
	desc = "Please deposit the requested item to complete the tutorial!"
	resistance_flags = INDESTRUCTIBLE
	var/list/players_that_completed = list()
	var/obj/item/item_to_be_checked = /obj/item/flashlight

/obj/structure/closet/tutorial/Initialize(mapload)
	. = ..()
	set_light(l_outer_range = 3, l_power = 1.4, l_color = LIGHT_COLOR_BLUE)

/obj/structure/closet/tutorial/after_close(mob/living/user, force)
	. = ..()
	var/input_succeded
	if(user.ckey in players_that_completed)
		to_chat(user, span_warning("You have already completed this tutorial!"))
		return

	for(var/obj/item/stuff in contents)
		if(check_stuff(user, stuff))
			input_succeded = TRUE
			players_that_completed += user.ckey
			qdel(stuff)
			break

	if(input_succeded)
		playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50)
		visible_message(span_notice("[user] has completed the tutorial!"))
	else
		playsound(src, 'sound/machines/buzz-two.ogg', 50)
		visible_message(span_notice("Required item was not detected!"))

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
		user.reward_tutorial_completion(user, TUTORIAL_REWARD_LOW)
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

