/datum/outfit/allmightyjanitor //I know "CLEAN IT UP JANNIE, THEY DO IT FOR FREE!" gag is for admins but whatever
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
	department_color = COLOR_CENTCOM_BLUE

/obj/machinery/mentor_machine
	name = "Mentor Asssistance Button"
	desc = "A mentor can be requested to assist prospective virtual tutorial users, or choose to spawn themselves into one."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	icon_state = "bigred"
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE
	var/datum/action/cooldown/spell/self_destruct/suicide_spell

/obj/machinery/mentor_machine/Destroy()
	. = ..()
	QDEL_NULL(suicide_spell)

/obj/machinery/mentor_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "Would you like to request assistance of mentor to assist you in completing this tutorial?", "Mentor Request", list("Yes", "No"))
	if(choice != "Yes")
		return

	poll_a_jannie(user)
	//poll and spawn mentor here

/obj/machinery/mentor_machine/attack_ghost(mob/user)
	. = ..()
	if(is_mentor(user))
		spawn_a_jannie(user)

/obj/machinery/mentor_machine/proc/poll_a_jannie(mob/living/requester)
	//polling
	var/mob/dead/observer/candidate = SSpolling.poll_mentor_ghost_candidates(question = "MENTOR ONLY GHOST ROLE: Would you like to assist [requester.name] in finishing a tutorial domain? THIS WILL UNLINK YOU WITH ORIGINAL BODY", poll_time = 15 SECONDS, alert_pic = src, amount_to_pick = 1)

	if(candidate)
		spawn_a_jannie(candidate)

/obj/machinery/mentor_machine/proc/spawn_a_jannie(mob/candidate)
	var/mob/living/carbon/human/mentor = new /mob/living/carbon/human(get_turf(loc), src)
	mentor.PossessByPlayer(candidate.key)

	if(isobserver(candidate))
		var/mob/dead/observer/observer = candidate
		mentor.real_name = observer.real_name
		mentor.name = observer.name
		mentor.hairstyle = observer.hairstyle
		mentor.facial_hairstyle = observer.facial_hairstyle
		mentor.hair_color = observer.hair_color
		mentor.facial_hair_color = observer.facial_hair_color
		mentor.update_body(is_creating = TRUE)


	var/datum/action/cooldown/spell/self_destruct/new_spell = new /datum/action/cooldown/spell/self_destruct(mentor.mind || mentor)
	new_spell.Grant(mentor)

	mentor.equipOutfit(/datum/outfit/allmightyjanitor)
