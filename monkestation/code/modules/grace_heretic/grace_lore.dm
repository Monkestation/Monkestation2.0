/*
* # Path of grace.
*
* Tree:
*
*	Beginning
*	Grasp
*	Dash
*		>Ashen Eyes
*		>Flesh (gloves)
*	Martial Mark
*	Ritual of Knowledge
*	Dash (upgrade)
*	Armor
*		>Curse of Paralysis
*		>Wave of Desparation
*	Martial Arts Improvement
*	Crush
*		>Ashen Ritual
*		>Apetra Vulnera
*	Ascension
*/
/datum/heretic_knowledge/limited_amount/starting/grace
	name = "martial placeholder"
	desc = "Sphynx of black quartz, judge my vow."
	gain_text = "the placeholder placeholder placeholder placeholder"
	next_knowledge = list(/datum/heretic_knowledge/graceful_grasp)
	required_atoms = list(
		/obj/item/pen,
		list(/obj/item/paper, /obj/item/book) = 2,
	)
	result_atoms = list(/obj/item/book/granter/martial/grace)
	limit = 1
	route = PATH_GRACE

/datum/heretic_knowledge/graceful_grasp
	name = "Graceful Grasp"
	desc = "Your masus grasp will empower your strength, allowing you to life heathens with ease."
	gain_text = "wuh woh"
	next_knowledge = list(/datum/heretic_knowledge/spell/graceful_dash)
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/graceful_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/graceful_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/graceful_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	ASYNC
	SIGNAL_HANDLER

	if(target.is_blind())
		return

	if(!target.get_organ_slot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("[source] picks you up and lifts you into the air!"))
	target.grabbedby(source, TRUE)
	source.setGrabState(GRAB_PASSIVE)
	target.Paralyze(2 SECONDS)
	target.adjustOxyLoss(30)
	target.set_eye_blur_if_lower(2 SECONDS)

/datum/heretic_knowledge/spell/graceful_dash //note: doesn't fucking work
	name = "Rapid Dash"
	desc = "Sprint with purpose. You will knock those in your path away."
	gain_text = "bitches be like \"you're so slow\" bitch I could throw you"
	next_knowledge = list(/datum/heretic_knowledge/mark/martial_mark)
	//add sidepath stuff here
	spell_to_add = /datum/action/cooldown/mob_cooldown/charge/basic_charge/dash
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/mark/martial_mark
	name = "Mark of Blood"
	desc = "the thingy"
	gain_text = "HATE HATE HATE DO YOU KNOW HOW MUCH I HATE????"
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/grace)
	route = PATH_GRACE
	mark_type = /datum/status_effect/eldritch/grace

/datum/heretic_knowledge/mark/martial_mark/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
	if(grasp)
		grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
		grasp.build_all_button_icons()

/datum/heretic_knowledge/knowledge_ritual/grace //beloathed
	next_knowledge = list(/datum/heretic_knowledge/shoulder)
	route = PATH_GRACE

/datum/heretic_knowledge/shoulder
	name = "Shoulder check"
	desc = "i thought you had stronger brakes sorry"
	gain_text = "Shoulder check security for 50 credits"
	next_knowledge = /datum/heretic_knowledge/agile_armor
	cost = 1
	route = PATH_GRACE
	var/had_heavy_dash = FALSE //presumably someone could have the trait for a heavy dash without being a heretic

/datum/heretic_knowledge/shoulder/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	//add trait stuff

/datum/heretic_knowledge/shoulder/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	//add trait stuff

/datum/heretic_knowledge/agile_armor
	name = "cool robes bro"
	desc = "gold plated lamborghini"
	gain_text = "hollywood hills"
	next_knowledge = /datum/heretic_knowledge/strength
	required_atoms = list(
		list(/obj/item/stack/sheet/mineral/gold, /obj/item/stack/sheet/mineral/silver),
		/obj/item/clothing/suit //any outerwear
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/martial)
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/strength
	name = "Eldritch Strength"
	desc = "the dance"
	gain_text = "you know the club"
	next_knowledge = /datum/heretic_knowledge/spell/crush
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/strength/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	ADD_TRAIT(user, TRAIT_ELDRITCH_STRENGTH, TRAIT_GENERIC)

/datum/heretic_knowledge/strength/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	REMOVE_TRAIT(user, TRAIT_ELDRITCH_STRENGTH, TRAIT_GENERIC)

/datum/heretic_knowledge/spell/crush
	name = "Crush"
	desc = "big stomp"
	gain_text = "clown shoes but cool"
	next_knowledge = list(/datum/heretic_knowledge/ultimate/grace_final)
	//spell_to_add =
	cost = 1
	route = PATH_GRACE

/datum/heretic_knowledge/ultimate/grace_final
	name = "oh god"
	desc = "oh fuck"
	gain_text = "oh shit"
	route = PATH_GRACE
	//ascension_achievement = /datum/award/achievement/misc/ash_ascension
	//announcement_text = "spooper"
	//announcement_sound = ''

/datum/heretic_knowledge/ultimate/grace_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	return
