#define HUNTER_DASH_PROBABILITY 12

/// Heals slightly on melee hits, and more when devouring
/mob/living/basic/boss/blood_drunk_miner/guidance
	heal_per_hit = 2
	devour_heal_bonus = 1

/// Better at dash attacking
/mob/living/basic/boss/blood_drunk_miner/hunter

/mob/living/basic/boss/blood_drunk_miner/hunter/post_attack_effects(mob/living/victim, list/modifiers)
	if(!prob(HUNTER_DASH_PROBABILITY))
		return

	var/datum/action/cooldown/dash = ai_controller?.blackboard[BB_BDM_DASH_ABILITY]
	if(!isnull(dash))
		INVOKE_ASYNC(dash, TYPE_PROC_REF(/datum/action/cooldown, Trigger), NONE, victim)

/// Slow but constantly dashes and has faster barrages
/mob/living/basic/boss/blood_drunk_miner/doom
	name = "hostile-environment miner"
	desc = "A miner destined to hop across dimensions for all eternity, hunting anomalous creatures."
	speed = 8
	ranged_attack_cooldown_duration = 0.8 SECONDS
	ai_controller = /datum/ai_controller/blood_drunk_miner/doom

/mob/living/basic/boss/blood_drunk_miner/doom/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/dash_ability = ai_controller.blackboard[BB_BDM_DASH_ABILITY]
	if(!isnull(dash_ability))
		dash_ability.cooldown_time = 0.8 SECONDS

#undef HUNTER_DASH_PROBABILITY
