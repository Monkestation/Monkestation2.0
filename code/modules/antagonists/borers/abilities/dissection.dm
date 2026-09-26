/datum/action/cooldown/borer/dissection
	name = "Dissect Corspe"
	button_icon_state = "mendwound"
	cooldown_time = 1 MINUTES
	chemical_cost = 100
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Aggressivley probes the dead grey matter of a brain to further one's own growth.\n\
	If successful, the rate at which one produces chemicals and evolution points \n\
	"

/datum/action/cooldown/borer/dissection/IsAvailable(feedback)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/cortical_borer/neutered/user = owner
	if(HAS_TRAIT(user.human_host, TRAIT_BORER_DISSECTION))
		if(feedback)
			owner.balloon_alert(owner, "host already dissected!")
		return FALSE

/datum/action/cooldown/borer/dissection/check_conditions()
	. = ..()
	if(.)
		return
	var/mob/living/basic/cortical_borer/user = owner
	if(user.human_host.stat != DEAD)
		owner.balloon_alert(owner, "dead host required")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/dissection/Activate(mob/living/basic/cortical_borer/neutered/user)
	var/obj/item/organ/internal/brain/victim_brain = user.human_host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(victim_brain)
		user.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25 * user.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
		var/eggroll = rand(1,80)
		switch(eggroll)
			if(6 to 39)
				user.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
			if(40 to 65)
				user.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
			if(66 to 76)
				user.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
			if(77 to 80)
				user.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

	ADD_TRAIT(user.human_host, TRAIT_BORER_DISSECTION, user.tag)
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	var/datum/antagonist/cortical_borer/antag = owner.mind?.has_antag_datum(/datum/antagonist/cortical_borer)
	if(antag)
		var/datum/objective/borer/dissect_bodies/objective = locate() in antag.objectives
		if(objective)
			objective.dissected_bodies++
			objective.check_completion()

	user.chemical_storage -= chemical_cost
	var/turf/borer_turf = get_turf(user)
	playsound(borer_turf, 'sound/effects/splat.ogg', 50, TRUE)
	owner.balloon_alert(owner, "grey Matter Analzyed")
	return ..()
