/mob/living/basic/beetmin
	name = "beetmin"
	desc = "It's a very odd looking beet... with legs and eyes oh god"
	icon_state = "beetmin"
	icon_living = "beetmin"
	icon_dead = "beetmin_dead"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "whacks"
	response_harm_simple = "whack"

	speed = 1
	melee_damage_lower = 4
	melee_damage_upper = 4
	maxHealth = 60

	attack_verb_continuous = "headbutts"
	attack_verb_simple = "headbutt"
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	speak_emote = list("shrieks")
	death_message = "seizes!"
	ai_controller = /datum/ai_controller/basic_controller/mouse
