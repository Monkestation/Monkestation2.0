///ripped from the zombie code, for plague doctor summon ability
/mob/living/basic/space_fauna/plague_doc/minion_zombies
	name = "Mutilated Corpse"
	desc = "One of the doctor's 'cured' ones."
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	faction = list(FACTION_HOSTILE, FACTION_PLAGUE)
	sentience_type = SENTIENCE_HUMANOID
	maxHealth = 100
	health = 100
	basic_mob_flags = DEL_ON_DEATH
	melee_damage_lower = 21
	melee_damage_upper = 21
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	istate = ISTATE_HARM|ISTATE_BLOCKING
	bodytemp_cold_damage_limit = -1
	status_flags = CANPUSH
	ai_controller = /datum/ai_controller/basic_controller/minion_zombies
	icon_gib = "syndicate_gib"
	death_message = "blood starts spewing out of every orifice."
	var/outfit

/mob/living/basic/space_fauna/plague_doc/minion_zombies/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/decal/remains/human)
	AddElement(/datum/element/death_drops, death_loot)
	apply_dynamic_human_appearance(src, outfit, /datum/species/zombie, bloody_slots = ITEM_SLOT_OCLOTHING)

/datum/ai_controller/basic_controller/minion_zombies
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/mob/living/basic/space_fauna/plague_doc/minion_zombies/zombieprisoner
	name = "Cured Prisoner"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "weakly slashes"
	attack_verb_simple = "slash"
	outfit = /datum/outfit/dclassoutfit

/mob/living/basic/space_fauna/plague_doc/minion_zombies/zombielguard
	name = "Cured Facility Guard"
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	outfit = /datum/outfit/lightguardcorpse

/mob/living/basic/space_fauna/plague_doc/minion_zombies/zombiehguard
	name = "Cured Facility Guard"
	melee_damage_lower = 21
	melee_damage_upper = 25
	attack_verb_continuous = "strongly slashes"
	attack_verb_simple = "slash"
	outfit = /datum/outfit/heavyguardcorpse

/mob/living/basic/space_fauna/plague_doc/minion_zombies/zombiescientist
	name = "Cured Scientist"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "weakly slashes"
	attack_verb_simple = "slash"
	outfit = /datum/outfit/scpscientistcorpse

/mob/living/basic/space_fauna/plague_doc/minion_zombies/zombiemanager
	name = "Cured Manager"
	melee_damage_lower = 15
	melee_damage_upper = 17
	attack_verb_continuous = "weakly slashes"
	attack_verb_simple = "slash"
	outfit = /datum/outfit/facilitymanagercorpse
