/datum/nanite_program/regenerative
	name = "Accelerated Regeneration"
	desc = "The nanites boost the host's natural regeneration, healing 0.3 brute and 0.3 burn damage per second. \
		Will not consume nanites while the host is unharmed. Grants 0.2 extra healing while in low pressure environments such as Lavaland."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/regenerative/check_conditions()
	if(!host_mob.getBruteLoss() && !host_mob.getFireLoss())
		return FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/host_carbon = host_mob
		var/list/parts = host_carbon.get_damaged_bodyparts(brute = TRUE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)
		if(!parts.len)
			return FALSE
	return ..()

/datum/nanite_program/regenerative/active_effect()
	if(!iscarbon(host_mob))
		host_mob.adjustBruteLoss(-0.5, TRUE)
		host_mob.adjustFireLoss(-0.5, TRUE)
		return
	var/lavaland_bonus = (lavaland_equipment_pressure_check(get_turf(host_mob)) ? 1 : 0.6) // 0.5 on lavaland, 0.3 on station
	host_mob.heal_overall_damage(brute = (0.5 * lavaland_bonus), brute = (0.5 * lavaland_bonus), required_bodytype = BODYTYPE_ORGANIC)

/datum/nanite_program/regenerative_advanced
	name = "Bio-Reconstruction"
	desc = "The nanites manually repair and replace organic cells, healing 1.2 brute damage and 1.2 burn damage per second. \
			However, this program cannot detect the difference between harmed and unharmed, causing it to consume nanites even if it has no effect. \
			Grants 0.3 extra healing while in low pressure environments such as Lavaland."
	use_rate = 5.5
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/regenerative_advanced/active_effect()
	if(!iscarbon(host_mob))
		host_mob.adjustBruteLoss(-3, TRUE)
		host_mob.adjustFireLoss(-3, TRUE)
		return
	var/lavaland_bonus = (lavaland_equipment_pressure_check(get_turf(host_mob)) ? 1 : 0.8) // 1.5 on Lavaland, 1.2 on station
	host_mob.heal_overall_damage(brute = (1.5 * lavaland_bonus), brute = (1.5 * lavaland_bonus), required_bodytype = BODYTYPE_ORGANIC)

/datum/nanite_program/temperature
	name = "Temperature Adjustment"
	desc = "The nanites adjust the host's internal temperature to an ideal level at a rate of 10 Kelvin per second. Will not consume nanites while the host is at a normal body temperature."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/temperature/check_conditions()
	if(host_mob.bodytemperature > host_mob.bodytemp_heat_damage_limit)
		if(HAS_TRAIT(host_mob, TRAIT_RESISTHEAT))
			return FALSE
	else if(host_mob.bodytemperature < host_mob.bodytemp_cold_damage_limit)
		if(HAS_TRAIT(host_mob, TRAIT_RESISTCOLD))
			return FALSE
	else
		return FALSE
	return ..()

/datum/nanite_program/temperature/enable_passive_effect()
	. = ..()
	host_mob.add_homeostasis_level(REF(src), host_mob.standard_body_temperature, 10 KELVIN, TRUE, TRUE)

/datum/nanite_program/temperature/disable_passive_effect()
	. = ..()
	host_mob.remove_homeostasis_level(REF(src))

/datum/nanite_program/purging
	name = "Blood Purification"
	desc = "The nanites purge toxins and chemicals from the host's bloodstream, healing 1 toxin damage and removing 1 unit of each chemical per second. \
		Consumes nanites even if it has no effect. Ineffective against Radiomagnetic Disruptor."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/purging/check_conditions()
	var/foreign_reagent = length(host_mob.reagents?.reagent_list)
	if(!host_mob.getToxLoss() && !foreign_reagent)
		return FALSE
	return ..()

/datum/nanite_program/purging/active_effect()
	host_mob.adjustToxLoss(-1)
	for(var/datum/reagent/reagents as anything in host_mob.reagents.reagent_list)
		host_mob.reagents.remove_reagent(reagents.type, amount = 1)

/datum/nanite_program/brain_heal
	name = "Neural Regeneration"
	desc = "The nanites fix neural connections in the host's brain, reversing 1 point of brain damage per second with a 10% chance to fix minor traumas. \
		Will not consume nanites while it would not have an effect."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/brain_heal/check_conditions()
	var/problems = FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/carbon_host = host_mob
		if(carbon_host.has_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC, ignore_flags = TRAUMA_SPECIAL_CURE_PROOF))
			problems = TRUE
	if(host_mob.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		problems = TRUE
	return problems ? ..() : FALSE

/datum/nanite_program/brain_heal/active_effect()
	host_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)
	if(iscarbon(host_mob) && prob(10))
		var/mob/living/carbon/carbon_host = host_mob
		carbon_host.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC, ignore_flags = TRAUMA_SPECIAL_CURE_PROOF)

#define NANITE_BLOOD_RESTORE_DEFAULT 2

/datum/nanite_program/blood_restoring
	name = "Blood Regeneration"
	desc = "The nanites stimulate and boost blood cell production in the host, regenerating their blood at a rate of 2 units per second. \
		Will not consume nanites while the host has a safe blood level."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/suffocating)
	///The amount of blood that we restore every active effect tick.
	var/blood_restore_amount = NANITE_BLOOD_RESTORE_DEFAULT

/datum/nanite_program/blood_restoring/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/carbon_host = host_mob
	if(carbon_host.blood_volume >= BLOOD_VOLUME_SAFE)
		return FALSE
	return ..()

/datum/nanite_program/blood_restoring/active_effect()
	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/carbon_host = host_mob
	carbon_host.blood_volume += blood_restore_amount

#undef NANITE_BLOOD_RESTORE_DEFAULT

/datum/nanite_program/repairing
	name = "Mechanical Repair"
	desc = "The nanites fix damage in the host's mechanical limbs, healing 1 brute and 1 burn per second. \
		Will not consume nanites while the host's mechanical limbs are undamaged, or while the host has no mechanical limbs."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/repairing/check_conditions()
	if(!host_mob.getBruteLoss() && !host_mob.getFireLoss())
		return FALSE

	if(!iscarbon(host_mob))
		if(!(host_mob.mob_biotypes & MOB_ROBOTIC))
			return FALSE
		return ..()

	var/mob/living/carbon/carbon_host = host_mob
	var/list/parts = carbon_host.get_damaged_bodyparts(brute = TRUE, burn = TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	if(!parts.len)
		return FALSE
	return ..()

/datum/nanite_program/repairing/active_effect(mob/living/M)
	if(!iscarbon(host_mob))
		host_mob.adjustBruteLoss(-1.5, TRUE)
		host_mob.adjustFireLoss(-1.5, TRUE)
		return
	host_mob.heal_overall_damage(brute = 1.5, brute = 1.5, required_bodytype = BODYTYPE_ROBOTIC)

/datum/nanite_program/purging_advanced
	name = "Selective Blood Purification"
	desc = "The nanites purge toxins (healing one point of toxin damage per second) and toxic chemicals (purging 1 unit of toxins per second) from the host's bloodstream, while ignoring other chemicals. \
			The added processing power required to analyze the chemicals severely increases the nanite consumption rate. Consumes nanites even if it has no effect."
	use_rate = 2
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/purging_advanced/check_conditions()
	var/foreign_reagent = FALSE
	for(var/datum/reagent/toxin/toxic_reagents in host_mob.reagents.reagent_list)
		foreign_reagent = TRUE
		break
	if(!host_mob.getToxLoss() && !foreign_reagent)
		return FALSE
	return ..()

/datum/nanite_program/purging_advanced/active_effect()
	host_mob.adjustToxLoss(-1)
	for(var/datum/reagent/toxin/toxic_reagents in host_mob.reagents.reagent_list)
		host_mob.reagents.remove_reagent(toxic_reagents.type, 1)

/datum/nanite_program/brain_heal_advanced
	name = "Neural Reimaging"
	desc = "The nanites are able to backup and restore the host's neural connections, removing 2 points of brain damage per second with a 10% chance to heal deep-rooted traumas. \
		Consumes nanites even if it has no effect."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/brain_heal_advanced/check_conditions()
	var/problems = FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/carbon_host = host_mob
		if(length(carbon_host.get_traumas()))
			problems = TRUE
	if(host_mob.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		problems = TRUE
	return problems ? ..() : FALSE

/datum/nanite_program/brain_heal_advanced/active_effect()
	host_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2)
	if(iscarbon(host_mob) && prob(10))
		var/mob/living/carbon/carbon_host = host_mob
		carbon_host.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY, ignore_flags = TRAUMA_SPECIAL_CURE_PROOF)

#define GHOST_NOTIFY_COOLDOWN_DELAY (1 MINUTES)

/datum/nanite_program/defib
	name = "Defibrillation"
	desc = "The nanites shock the host's heart when triggered, bringing them back to life if the body can sustain it."
	can_trigger = TRUE
	trigger_cost = 25
	trigger_cooldown = 120
	rogue_types = list(/datum/nanite_program/shocking)
	///The cooldown between alerting the dead player that they're being revived.
	COOLDOWN_DECLARE(ghost_notify_cooldown)

/datum/nanite_program/defib/on_trigger(comm_message)
	if(COOLDOWN_FINISHED(src, ghost_notify_cooldown) && check_revivable())
		host_mob.notify_ghost_cloning("Your heart is being defibrillated by nanites. Re-enter your corpse if you want to be revived!")
		COOLDOWN_START(src, ghost_notify_cooldown, GHOST_NOTIFY_COOLDOWN_DELAY)
	addtimer(CALLBACK(src, PROC_REF(start_defibrilation)), 5 SECONDS)

/datum/nanite_program/defib/proc/check_revivable()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/carbon_host = host_mob
	return carbon_host.can_defib()

/datum/nanite_program/defib/proc/start_defibrilation()
	playsound(host_mob, 'sound/machines/defib_charge.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(perform_defibrilation)), 3 SECONDS)

/datum/nanite_program/defib/proc/perform_defibrilation()
	var/mob/living/carbon/carbon_host = host_mob
	playsound(carbon_host, 'sound/machines/defib_zap.ogg', 50, FALSE)
	if(!check_revivable())
		playsound(carbon_host, 'sound/machines/defib_failed.ogg', 50, FALSE)
		return
	playsound(carbon_host, 'sound/machines/defib_success.ogg', 50, FALSE)
	carbon_host.set_heartattack(FALSE)
	carbon_host.revive()
	carbon_host.emote("gasp")
	carbon_host.set_timed_status_effect(10 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	SEND_SIGNAL(carbon_host, COMSIG_LIVING_MINOR_SHOCK)
	carbon_host.investigate_log("[carbon_host] has been successfully defibrillated by nanites.", INVESTIGATE_NANITES)

#undef GHOST_NOTIFY_COOLDOWN_DELAY

/datum/nanite_program/oxygen_rush
	name = "Alveolic Deoxidation"
	desc = "The nanites deoxidze the carbon dioxide carried within the blood inside of the host's lungs through rapid electrical stimulus, healing 10 oxygen damage per second. \
			However, this process is extremely dangerous, leaving carbon deposits within the lungs and thus causing 4 points of lung damage per second."
	use_rate = 10
	rogue_types = list(/datum/nanite_program/suffocating)

	COOLDOWN_DECLARE(warning_cooldown)
	COOLDOWN_DECLARE(ending_cooldown)

/datum/nanite_program/oxygen_rush/check_conditions()
	var/obj/item/organ/internal/lungs/lungs = host_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return FALSE
	return ..() && !(lungs.organ_flags & ORGAN_FAILING)

/datum/nanite_program/oxygen_rush/active_effect()
	host_mob.adjustOxyLoss(-10, TRUE)
	host_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 4)
	var/mob/living/carbon/carbon_host = host_mob
	if(prob(8) && istype(carbon_host))
		to_chat(host_mob, span_userdanger("You feel a sudden flood of pain in your chest!"))
		carbon_host.vomit(blood = TRUE, harm = FALSE)

/datum/nanite_program/oxygen_rush/enable_passive_effect()
	. = ..()
	if(COOLDOWN_FINISHED(src, warning_cooldown))
		to_chat(host_mob, span_warning("You feel a hellish burning in your chest!"))
		COOLDOWN_START(src, warning_cooldown, 10 SECONDS)

/datum/nanite_program/oxygen_rush/disable_passive_effect()
	. = ..()
	if(COOLDOWN_FINISHED(src, ending_cooldown))
		to_chat(host_mob, span_notice("The fire in your chest subsides."))
		COOLDOWN_START(src, ending_cooldown, 10 SECONDS)
