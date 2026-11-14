/mob/living/basic/red_rabbit
	name = "jabberwocky"
	desc = "Servant of the moon."
	icon = 'icons/mob/red_rabbit.dmi'
	icon_state = "red_rabbit"
	pixel_x = -16
	base_pixel_x = -16

	health = 500
	maxHealth = 500
	speed = 5
	attack_verb_continuous = "claws"
	attack_verb_simple = "claw"
	attack_sound = 'sound/effects/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_CLAW
	speak_emote = list("roars")
	mob_size = MOB_SIZE_HUGE
	mob_biotypes = MOB_ORGANIC | MOB_BEAST | MOB_EPIC

	armour_penetration = 40
	melee_damage_upper = 40
	melee_damage_lower = 40
	obj_damage = 400

	faction = list(FACTION_RABBITS)
	death_message = "succumbs to the moonlight."
	death_sound = 'sound/effects/gravhit.ogg'
	environment_smash = ENVIRONMENT_SMASH_WALLS
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	sentience_type = SENTIENCE_BOSS

	habitable_atmos = null
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0

	ai_controller = /datum/ai_controller/basic_controller/red_rabbit
	basic_mob_flags = DEL_ON_DEATH

	var/list/actions_to_give = list(
		/datum/action/cooldown/spell/pointed/red_rabbit_hole,
		/datum/action/cooldown/spell/rabbit_spawn,
		/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/red_rabbit,
		/datum/action/cooldown/mob_cooldown/charge/rabbit
	)

/mob/living/basic/red_rabbit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL)
	AddComponent(/datum/component/seethrough_mob)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	for(var/action_type in actions_to_give)
		var/datum/action/action = new action_type(src)
		action.Grant(src)
