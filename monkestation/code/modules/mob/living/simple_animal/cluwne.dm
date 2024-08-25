/mob/living/simple_animal/cluwne
	name = "The Cluwne"
	real_name = "The Cluwne"
	desc = "A cluwne. A barely-human monstrosity that pissed off the gods."
	friendly_verb_continuous = "bops"
	friendly_verb_simple = "bop"
	turns_per_move = 10
	icon = 'monkestation/icons/mob/simple/cluwne.dmi'
	icon_state = "cluwne"
	icon_living = "cluwne"
	icon_dead = "cluwne_dead"
	speak_emote = list("sadly honks")
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	maxHealth = 150
	health = 150
	speak = list("HONK! HONK! HONK! HONK!", "AAAAAAAAAAAAAAAAAA!!", "KILLMEKILLME!!", "HONK HENK HONK!!", "Honk Honk!", "HEEEEEEEEEEEEENK!!")
	footstep_type = FOOTSTEP_MOB_SHOE
	chat_color = "#F37EF6"

/mob/living/simple_animal/cluwne/Initialize(mapload)
	. = ..()
	playsound(src, 'monkestation/sound/misc/honk_echo_distant.ogg', 90, 2)
	var/newname = pick(GLOB.clown_names)
	name = newname
	real_name = newname

/mob/living/simple_animal/cluwne/emote(act, m_type, message, intentional)
	if(intentional)
		message = "makes a sad honk."
		act = "me"
	..()

/mob/living/simple_animal/cluwne/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	playsound(src, 'sound/items/bikehorn.ogg', 20, 2)
	..()

/mob/living/simple_animal/cluwne/attacked_by(obj/item/I, mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 20, 2)
	..()

/mob/living/simple_animal/cluwne/attack_hand()
	playsound(src, 'sound/items/bikehorn.ogg', 20, 2)
	..()

/mob/living/simple_animal/cluwne/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof, message_range, datum/saymode/saymode)
	message = pick(speak)
	..()
