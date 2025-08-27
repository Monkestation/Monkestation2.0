/mob/living/basic/carp/pet/biodome
	gender = MALE
	faction = list(FACTION_NEUTRAL)

/mob/living/basic/carp/pet/biodome/funfun
	name = "Fun-Fun"
	desc = "This carp has been created as a decoration in the biodome. You feel you should love him and believe him."

/mob/living/basic/carp/pet/biodome/fangfang
	name = "Fang-Fang"
	desc = "This carp has been created as a decoration in the biodome. You feel you should come and see him."

/mob/living/basic/rabbit/trefoil
	name = "Trefoil"
	gold_core_spawnable = NO_SPAWN
	desc = "This rabbit is always planning elaborate set pieces for their newest act."

/mob/living/basic/creature/docile
	desc = "A moving lump of animated viscera which current science cannot yet explain."
	ai_controller = /datum/ai_controller/basic_controller/creature/docile

/mob/living/basic/creature/docile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/sedated_mob, /datum/ai_controller/basic_controller/creature)

/datum/ai_controller/basic_controller/creature/docile
	planning_subtrees = list()
