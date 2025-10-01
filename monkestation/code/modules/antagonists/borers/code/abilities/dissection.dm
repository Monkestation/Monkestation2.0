/datum/action/cooldown/borer/dissection
	name = "Dissect Corspe"
	button_icon_state = "mendwound"
	cooldown_time = 1 MINUTE
	chemical_cost = 100
	requires_host = TRUE
	sugar_restricted = TRUE
	needs_dead_host = TRUE
	ability_explanation = "\
	Aggressivley probes the dead grey matter of a brain to further one's own growth.\n\
	If successful, the rate at which one produces chemicals and evolution points \n\
	"

/datum/action/cooldown/borer/dissection/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/cortical_borer/neutered/cortical_owner = owner

	if(HAS_TRAIT(cortical_owner.human_host, TRAIT_BORER_DISSECTION))
		owner.balloon_alert(owner, "Host has already been dissected.")
	var/obj/item/organ/internal/brain/victim_brain = cortical_owner.human_host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(victim_brain)
		cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)
		var/eggroll = rand(1,80)
		if(eggroll <= 75)
			switch(eggroll)
				if(1 to 34)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)
					owner.balloon_alert(owner, "Cerebrum damaged!")
				if(35 to 60)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "Cerebellum damaged!")
				if(61 to 71)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_SURGERY)
					owner.balloon_alert(owner, "Brainstem damaged!")
				if(72 to 75)
					cortical_owner.human_host.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
					owner.balloon_alert(owner, "Brainstem severelly damaged!")
	cortical_owner.human_host.add_traits(list(TRAIT_BORER_DISSECTION))
	cortical_owner.dissections++
	sleep(10)
	owner.balloon_alert(owner, "Grey Matter Analzyed")
	StartCooldown()
