/datum/outfit/allmightyjanitor
	name = "Mentor Janitor"
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id/advanced
	head = /obj/item/clothing/head/soft/purple
	id_trim = /datum/id_trim/mentorjanitor
	uniform = /obj/item/clothing/under/rank/civilian/janitor
	belt = /obj/item/modular_computer/pda/janitor

/datum/id_trim/mentorjanitor
	assignment = "All-Mighty All-Knowing Janitor"

/obj/machinery/mentor_machine
	name = "Mentor Asssistance Button"
	desc = "A mentor can be requested to assist prospective virtual tutorial users, or choose to spawn themselves into one."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "bigred"
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE
	var/datum/action/cooldown/spell/self_destruct/suicide_spell

/obj/machinery/mentor_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "Would you like to request assistance of mentor to assist you in completing this tutorial?", "Mentor Request", list("Yes", "No"))
	if(isnull(choice))
		return
	if(choice == "No")
		return

	poll_a_jannie(user)
	//poll and spawn mentor here

/obj/machinery/mentor_machine/attack_ghost(mob/user)
	. = ..()
	if(is_mentor(user))
		spawn_a_jannie(user)

/obj/machinery/mentor_machine/proc/poll_a_jannie(mob/living/requester) //I know "CLEAN IT UP JANNIE, THEY DO IT FOR FREE!" gag is for admins but whatever
	//polling
	var/mob/dead/observer/candidate = SSpolling.poll_mentor_ghost_candidates(question = "Would you like to assist [requester.name] in finishing a tutorial domain?", poll_time = 15 SECONDS, alert_pic = src, amount_to_pick = 1)

	if(candidate)
		spawn_a_jannie(candidate)

/obj/machinery/mentor_machine/proc/spawn_a_jannie(mob/candidate)
	var/mob/living/carbon/human/mentor = new /mob/living/carbon/human(get_turf(loc), src)
	mentor.key = candidate.key
	mentor.real_name = mentor.key
	mentor.name = mentor.real_name

	var/datum/action/cooldown/spell/self_destruct/new_spell = new /datum/action/cooldown/spell/self_destruct(mentor.mind || mentor)
	new_spell.Grant(mentor)

	mentor.equipOutfit(/datum/outfit/allmightyjanitor)
