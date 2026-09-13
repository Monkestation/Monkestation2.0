/// How much health do we take from the borer if its producing eggs without a host?
#define OUT_OF_HOST_EGG_COST 50

//we need a way to produce offspring
/datum/action/cooldown/borer/produce_offspring
	name = "Produce Offspring"
	cooldown_time = 1 MINUTES
	button_icon_state = "reproduce"
	chemical_cost = 100
	requires_host = TRUE
	ability_explanation = "\
	Forces your host to produce a borer egg inside of their stomach, then vomit it up\n\
	Be carefull as the egg is fragile and can be broken very easily by any human, along with being extremelly noticable\n\
	"

/datum/action/cooldown/borer/produce_offspring/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(owner, TRAIT_NEUTERED))
		if(feedback)
			owner.balloon_alert(owner, "you cannot reproduce!")
		return FALSE

/datum/action/cooldown/borer/produce_offspring/Activate(mob/living/basic/cortical_borer/user)
	user.chemical_storage -= chemical_cost
	if(isnull(user.human_host))
		no_host_egg()
		return ..()

	produce_egg()
	var/obj/item/organ/internal/brain/victim_brain = user.human_host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(victim_brain)
		user.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
		var/eggroll = rand(1,100)
		if(eggroll <= 75)
			switch(eggroll)
				if(1 to 34)
					user.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
					owner.balloon_alert(owner, "cerebrum damaged!")
				if(35 to 60)
					user.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "cerebellum damaged!")
				if(61 to 71)
					user.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "brainstem damaged!")
				if(72 to 75)
					user.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
					owner.balloon_alert(owner, "brainstem severelly damaged!")
	to_chat(user.human_host, span_warning("Your brain begins to hurt..."))
	var/turf/borer_turf = get_turf(user)
	new /obj/effect/decal/cleanable/vomit(borer_turf)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(user)] gave birth at [loc_name(borer_turf)]"
	user.log_message(logging_text, LOG_GAME)
	owner.balloon_alert(owner, "egg laid")
	return ..()

/datum/action/cooldown/borer/produce_offspring/proc/no_host_egg()
	var/mob/living/basic/cortical_borer/user = owner
	user.apply_damage(max(1, user.health -= OUT_OF_HOST_EGG_COST), BRUTE)
	produce_egg()
	var/turf/borer_turf = get_turf(user)
	new/obj/effect/decal/cleanable/blood/splatter(borer_turf)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(user)] gave birth alone at [loc_name(borer_turf)]"
	user.log_message(logging_text, LOG_GAME)
	owner.balloon_alert(owner, "egg laid")

/datum/action/cooldown/borer/produce_offspring/proc/produce_egg()
	var/mob/living/basic/cortical_borer/user = owner
	var/obj/effect/mob_spawn/ghost_role/borer_egg/spawned_egg = new(user.drop_location())
	spawned_egg.generation = (user.generation + 1)

	user.children_produced++
	var/datum/antagonist/cortical_borer/antag = owner.mind.has_antag_datum(/datum/antagonist/cortical_borer)
	if(antag)
		if(antag.team)
			spawned_egg.borer_team = antag.team

		var/datum/objective/borer/produce_egg/objective = locate() in antag.objectives
		if(objective)
			objective.borers[owner.tag] += 1
			objective.check_completion()

#undef OUT_OF_HOST_EGG_COST

/datum/action/cooldown/borer/empowered_offspring
	name = "Produce Empowered Offspring"
	cooldown_time = 1 MINUTES
	button_icon_state = "reproduce"
	chemical_cost = 150
	requires_host = TRUE
	ability_explanation = "\
	Implants an egg onto a dead host, the egg will take 3 minutes to hatch and will die if the host gets revived\n\
	If the egg hatches, a massivelly stronger than normal borer will be created. Surpassing all others.\n\
	"

/datum/action/cooldown/borer/empowered_offspring/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(owner, TRAIT_NEUTERED))
		if(feedback)
			owner.balloon_alert(owner, "you cannot reproduce!")
		return FALSE

/datum/action/cooldown/borer/empowered_offspring/check_conditions()
	. = ..()
	if(.)
		return

	var/mob/living/basic/cortical_borer/neutered/user = owner
	if(user.human_host.stat != DEAD)
		owner.balloon_alert(owner, "dead host required")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/empowered_offspring/Activate(mob/living/basic/cortical_borer/user)
	user.chemical_storage -= chemical_cost
	var/turf/borer_turf = get_turf(user)
	var/obj/item/bodypart/chest/chest = user.human_host.get_bodypart(BODY_ZONE_CHEST)
	if((!chest || IS_ORGANIC_LIMB(chest)) && !user.human_host.get_organ_by_type(/obj/item/organ/internal/empowered_borer_egg))
		var/obj/item/organ/internal/empowered_borer_egg/spawned_egg = new(user.human_host)
		spawned_egg.generation = (user.generation + 1)
		user.children_produced++
		var/datum/antagonist/cortical_borer/antag = owner.mind.has_antag_datum(/datum/antagonist/cortical_borer)
		if(antag)
			if(antag.team)
				spawned_egg.borer_team = antag.team

			var/datum/objective/borer/produce_egg/objective = locate(/datum/objective/borer/produce_egg) in antag.objectives
			if(objective)
				objective.borers[owner.tag] += 1
				objective.check_completion()

	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	var/logging_text = "[key_name(user)] gave birth to an empowered borer at [loc_name(borer_turf)]"
	user.log_message(logging_text, LOG_GAME)
	user.balloon_alert(owner, "egg laid")
	return ..()
