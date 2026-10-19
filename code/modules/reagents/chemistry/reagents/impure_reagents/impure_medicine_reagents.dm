//Reagents produced by metabolising/reacting fermichems inoptimally these specifically are for medicines
//Inverse = Splitting
//Invert = Whole conversion
//Failed = End reaction below purity_min

//START SUBTYPES

//We don't want these to hide - they're helpful!
/datum/reagent/impurity/healing
	name = "Healing Impure Reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3.5)
	liver_damage = 0

/datum/reagent/inverse/healing
	name = "Healing Inverse Reagent"
	description = "Not all impure reagents are bad! Sometimes you might want to specifically make these!"
	chemical_flags = REAGENT_DONOTSPLIT
	addiction_types = list(/datum/addiction/medicine = 3)
	// tox_damage = 0 MONKESTATION REMOVAL

// END SUBTYPES

////////////////////MEDICINES///////////////////////////

//Catch all failed reaction for medicines - supposed to be non punishing
/datum/reagent/impurity/healing/medicine_failure
	name = "Insolvent Medicinal Precipitate"
	description = "A viscous mess of various medicines. Will heal a damage type at random"
	metabolization_rate = 1 * REM//This is fast
	addiction_types = list(/datum/addiction/medicine = 7.5)
	ph = 11
	affected_biotype = MOB_ORGANIC | MOB_MINERAL | MOB_PLANT // no healing ghosts
	affected_respiration_type = ALL

//Random healing of the 4 main groups
/datum/reagent/impurity/healing/medicine_failure/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	var/pick = pick("brute", "burn", "tox", "oxy")
	switch(pick)
		if("brute")
			owner.adjustBruteLoss(-0.5, required_bodytype = affected_bodytype)
		if("burn")
			owner.adjustFireLoss(-0.5, required_bodytype = affected_bodytype)
		if("tox")
			owner.adjustToxLoss(-0.5, required_biotype = affected_biotype)
		if("oxy")
			owner.adjustOxyLoss(-0.5, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	..()

// C2 medications
// Helbital
//Inverse:
/datum/reagent/inverse/helgrasp
	name = "Helgrasp"
	description = "This rare and forbidden concoction is thought to bring you closer to the grasp of the Norse goddess Hel."
	metabolization_rate = 1*REM //This is fast
	// tox_damage = 0.25 MONKESTATION REMOVAL
	ph = 14
	//Compensates for seconds_per_tick lag by spawning multiple hands at the end
	var/lag_remainder = 0
	//Keeps track of the hand timer so we can cleanup on removal
	var/list/timer_ids

//Warns you about the impenting hands
/datum/reagent/inverse/helgrasp/on_mob_add(mob/living/L, amount)
	to_chat(L, span_hierophant("You hear laughter as malevolent hands apparate before you, eager to drag you down to hell...! Look out!"))
	playsound(L.loc, 'sound/chemistry/ahaha.ogg', 80, TRUE, -1) //Very obvious tell so people can be ready
	. = ..()

//Sends hands after you for your hubris
/*
How it works:
Standard seconds_per_tick for a reagent is 2s - and volume consumption is equal to the volume * seconds_per_tick.
In this chem, I want to consume 0.5u for 1 hand created (since 1*REM is 0.5) so on a single tick I create a hand and set up a callback for another one in 1s from now. But since delta time can vary, I want to be able to create more hands for when the delay is longer.

Initally I round seconds_per_tick to the nearest whole number, and take the part that I am rounding down from (i.e. the decimal numbers) and keep track of them. If the decimilised numbers go over 1, then the number is reduced down and an extra hand is created that tick.

Then I attempt to calculate the how many hands to created based off the current seconds_per_tick, since I can't know the delay to the next one it assumes the next will be in 2s.
I take the 2s interval period and divide it by the number of hands I want to make (i.e. the current seconds_per_tick) and I keep track of how many hands I'm creating (since I always create one on a tick, then I start at 1 hand). For each hand I then use this time value multiplied by the number of hands. Since we're spawning one now, and it checks to see if hands is less than, but not less than or equal to, seconds_per_tick, no hands will be created on the next expected tick.
Basically, we fill the time between now and 2s from now with hands based off the current lag.
*/
/datum/reagent/inverse/helgrasp/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	owner.adjustToxLoss(0.125 * seconds_per_tick) // MONKESTATION EDIT
	spawn_hands(owner)
	lag_remainder += seconds_per_tick - FLOOR(seconds_per_tick, 1)
	seconds_per_tick = FLOOR(seconds_per_tick, 1)
	if(lag_remainder >= 1)
		seconds_per_tick += 1
		lag_remainder -= 1
	var/hands = 1
	var/time = 2 / seconds_per_tick
	while(hands < seconds_per_tick) //we already made a hand now so start from 1
		LAZYADD(timer_ids, addtimer(CALLBACK(src, PROC_REF(spawn_hands), owner), (time*hands) SECONDS, TIMER_STOPPABLE)) //keep track of all the timers we set up
		hands += time
	return ..()

/datum/reagent/inverse/helgrasp/proc/spawn_hands(mob/living/carbon/owner)
	if(!owner && iscarbon(holder.my_atom))//Catch timer
		owner = holder.my_atom
	fire_curse_hand(owner)

//At the end, we clear up any loose hanging timers just in case and spawn any remaining lag_remaining hands all at once.
/datum/reagent/inverse/helgrasp/on_mob_delete(mob/living/owner)
	var/hands = 0
	while(lag_remainder > hands)
		spawn_hands(owner)
		hands++
	for(var/id in timer_ids) // So that we can be certain that all timers are deleted at the end.
		deltimer(id)
	timer_ids?.Cut()
	return ..()

/datum/reagent/inverse/helgrasp/heretic
	name = "Grasp of the Mansus"
	description = "The Hand of the Mansus is at your neck."
	metabolization_rate = 1 * REM
	// tox_damage = 0 MONKESTATION REMOVAL

//libital
//Impure
//Simply reduces your alcohol tolerance, kinda simular to prohol
/datum/reagent/impurity/libitoil
	name = "Libitoil"
	description = "Temporarilly interferes a patient's ability to process alcohol."
	chemical_flags = REAGENT_DONOTSPLIT
	ph = 13.5
	liver_damage = 0.1
	addiction_types = list(/datum/addiction/medicine = 4)

/datum/reagent/impurity/libitoil/on_mob_add(mob/living/L, amount)
	. = ..()
	var/mob/living/carbon/consumer = L
	if(!consumer)
		return
	RegisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/internal/liver/this_liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	this_liver.alcohol_tolerance *= 2

/datum/reagent/impurity/libitoil/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/liver))
		return
	var/obj/item/organ/internal/liver/this_liver = organ
	this_liver.alcohol_tolerance *= 2

/datum/reagent/impurity/libitoil/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/liver))
		return
	var/obj/item/organ/internal/liver/this_liver = organ
	this_liver.alcohol_tolerance /= 2

/datum/reagent/impurity/libitoil/on_mob_delete(mob/living/L)
	. = ..()
	var/mob/living/carbon/consumer = L
	UnregisterSignal(consumer, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(consumer, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/internal/liver/this_liver = consumer.get_organ_slot(ORGAN_SLOT_LIVER)
	if(!this_liver)
		return
	this_liver.alcohol_tolerance /= 2


//probital
/datum/reagent/impurity/probital_failed//Basically crashed out failed metafactor
	name = "Metabolic Inhibition Factor"
	description = "This enzyme catalyzes crashes the conversion of nutricious food into healing peptides."
	metabolization_rate = 0.0625  * REAGENTS_METABOLISM //slow metabolism rate so the patient can self heal with food even after the troph has metabolized away for amazing reagent efficency.
	reagent_state = SOLID
	color = "#b3ff00"
	overdose_threshold = 10
	ph = 1
	addiction_types = list(/datum/addiction/medicine = 5)
	liver_damage = 0

/datum/reagent/impurity/probital_failed/overdose_start(mob/living/carbon/M)
	metabolization_rate = 4  * REAGENTS_METABOLISM
	..()

/datum/reagent/peptides_failed
	name = "Prion Peptides"
	taste_description = "spearmint frosting"
	description = "These inhibitory peptides cause cellular damage and cost nutrition to the patient!"
	ph = 2.1

/datum/reagent/peptides_failed/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	owner.adjustCloneLoss(0.25 * seconds_per_tick)
	owner.adjust_nutrition(-5 * REAGENTS_METABOLISM * seconds_per_tick)
	. = ..()

//Lenturi
//impure
/datum/reagent/impurity/lentslurri //Okay maybe I should outsource names for these
	name = "Lentslurri"//This is a really bad name please replace
	description = "A highly addicitive muscle relaxant that is made when Lenturi reactions go wrong."
	addiction_types = list(/datum/addiction/medicine = 8)
	liver_damage = 0

/datum/reagent/impurity/lentslurri/on_mob_metabolize(mob/living/carbon/owner)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

/datum/reagent/impurity/lentslurri/on_mob_end_metabolize(mob/living/carbon/owner)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/lenturi)
	return ..()

//failed
/datum/reagent/inverse/ichiyuri
	name = "Ichiyuri"
	description = "Prolonged exposure to this chemical can cause an overwhelming urge to itch oneself."
	reagent_state = LIQUID
	color = "#C8A5DC"
	ph = 1.7
	addiction_types = list(/datum/addiction/medicine = 2.5)
	// tox_damage = 0.1 MONKESTATION REMOVAL
	///Probability of scratch - increases as a function of time
	var/resetting_probability = 0
	///Prevents message spam
	var/spammer = 0

//Just the removed itching mechanism - omage to it's origins.
/datum/reagent/inverse/ichiyuri/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	if(prob(resetting_probability) && !(HAS_TRAIT(owner, TRAIT_RESTRAINED) || owner.incapacitated()))
		if(spammer < world.time)
			to_chat(owner,span_warning("You can't help but itch yourself."))
			spammer = world.time + (10 SECONDS)
		var/scab = rand(1,7)
		owner.adjustBruteLoss(scab*REM)
		owner.bleed(scab)
		resetting_probability = 0
	resetting_probability += (5*(current_cycle/10) * seconds_per_tick) // 10 iterations = >51% to itch
	..()
	return TRUE

//Aiuri
//impure
/datum/reagent/impurity/aiuri
	name = "Aivime"
	description = "This reagent is known to interfere with the eyesight of a patient."
	ph = 3.1
	addiction_types = list(/datum/addiction/medicine = 1.5)
	liver_damage = 0.1
	/// blurriness at the start of taking the med
	var/amount_of_blur_applied = 0 SECONDS

/datum/reagent/impurity/aiuri/on_mob_add(mob/living/owner, amount)
	. = ..()
	amount_of_blur_applied = creation_purity * (volume / metabolization_rate) * 2 SECONDS
	owner.adjust_eye_blur(amount_of_blur_applied)

/datum/reagent/impurity/aiuri/on_mob_delete(mob/living/owner, amount)
	. = ..()
	owner.adjust_eye_blur(-amount_of_blur_applied)

//Hercuri
//inverse
/datum/reagent/inverse/hercuri
	name = "Herignis"
	description = "This reagent causes a dramatic raise in the patient's body temperature. Overdosing makes the effect even stronger and causes severe liver damage."
	ph = 0.8
	// tox_damage = 0 MONKESTATION REMOVAL
	color = "#ff1818"
	overdose_threshold = 25
	reagent_weight = 0.6
	taste_description = "heat! Ouch!"
	addiction_types = list(/datum/addiction/medicine = 2.5)

/datum/reagent/inverse/hercuri/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	. = ..()
	var/heating = rand(5, 25) * creation_purity * REM * seconds_per_tick
	owner.reagents?.expose_temperature(owner.reagents.chem_temp + heating, 1)
	owner.adjust_bodytemperature(heating * 0.2 KELVIN)

/datum/reagent/inverse/hercuri/expose_mob(mob/living/carbon/exposed_mob, methods=VAPOR, reac_volume)
	. = ..()
	if(!(methods & VAPOR))
		return

	exposed_mob.adjust_bodytemperature(reac_volume * 0.33 KELVIN, use_insulation = TRUE)
	exposed_mob.adjust_fire_stacks(reac_volume / 2)

/datum/reagent/inverse/hercuri/overdose_process(mob/living/carbon/owner, seconds_per_tick, times_fired)
	. = ..()
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, 2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags) //Makes it so you can't abuse it with pyroxadone very easily (liver dies from 25u unless it's fully upgraded)
	owner.adjust_bodytemperature(0.5 KELVIN * creation_purity * REM * seconds_per_tick) //hot hot

/datum/reagent/inverse/healing/tirimol
	name = "Super Melatonin"//It's melatonin, but super!
	description = "This will send the patient to sleep, adding a bonus to the efficacy of all reagents administered."
	ph = 12.5 //sleeping is a basic need of all lifeformsa
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 5)

//Makes patients fall asleep, then boosts the purirty of their medicine reagents if they're asleep
/datum/reagent/inverse/healing/tirimol/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	switch(current_cycle)
		if(1 to 10)//same delay as chloral hydrate
			if(prob(50))
				owner.emote("yawn")
		if(10 to INFINITY)
			owner.Sleeping(40)
			. = 1
			if(owner.IsSleeping())
				for(var/datum/reagent/reagent as anything in owner.reagents.reagent_list)
					if(reagent in cached_reagent_list)
						continue
					if(!istype(reagent, /datum/reagent/medicine))
						continue
					reagent.creation_purity *= 1.25
					cached_reagent_list += reagent

			else if(!owner.IsSleeping() && length(cached_reagent_list))
				for(var/datum/reagent/reagent as anything in cached_reagent_list)
					if(!reagent)
						continue
					reagent.creation_purity *= 0.8
				cached_reagent_list = list()
	..()

/datum/reagent/inverse/healing/tirimol/on_mob_delete(mob/living/owner)
	if(owner.IsSleeping())
		owner.visible_message(span_notice("[icon2html(owner, viewers(DEFAULT_MESSAGE_RANGE, src))] [owner] lets out a hearty snore!"))//small way of letting people know the supersnooze is ended
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 0.8
	cached_reagent_list = list()
	..()

//convermol
//inverse
/datum/reagent/inverse/healing/convermol
	name = "Coveroli"
	description = "This reagent is known to coat the inside of a patient's lungs, providing greater protection against hot or cold air."
	ph = 3.82
	// tox_damage = 0 MONKESTATION REMOVAL
	addiction_types = list(/datum/addiction/medicine = 2.3)
	//The heat damage levels of lungs when added (i.e. heat_level_1_threshold on lungs)
	var/cached_heat_level_1
	var/cached_heat_level_2
	var/cached_heat_level_3
	//The cold damage levels of lungs when added (i.e. cold_level_1_threshold on lungs)
	var/cached_cold_level_1
	var/cached_cold_level_2
	var/cached_cold_level_3

/datum/reagent/inverse/healing/convermol/on_mob_add(mob/living/owner, amount)
	. = ..()
	RegisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	var/obj/item/organ/internal/lungs/lungs = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/on_gained_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/lungs))
		return
	var/obj/item/organ/internal/lungs/lungs = organ
	apply_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/apply_lung_levels(obj/item/organ/internal/lungs/lungs)
	cached_heat_level_1 = lungs.heat_level_warning_threshold
	cached_heat_level_2 = lungs.heat_level_hazard_threshold
	cached_heat_level_3 = lungs.heat_level_danger_threshold
	cached_cold_level_1 = lungs.cold_level_warning_threshold
	cached_cold_level_2 = lungs.cold_level_hazard_threshold
	cached_cold_level_3 = lungs.cold_level_danger_threshold
	//Heat threshold is increased
	lungs.heat_level_warning_threshold *= creation_purity * 1.5
	lungs.heat_level_hazard_threshold *= creation_purity * 1.5
	lungs.heat_level_danger_threshold *= creation_purity * 1.5
	//Cold threshold is decreased
	lungs.cold_level_warning_threshold *= creation_purity * 0.5
	lungs.cold_level_hazard_threshold *= creation_purity * 0.5
	lungs.cold_level_danger_threshold *= creation_purity * 0.5

/datum/reagent/inverse/healing/convermol/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/lungs))
		return
	var/obj/item/organ/internal/lungs/lungs = organ
	restore_lung_levels(lungs)

/datum/reagent/inverse/healing/convermol/proc/restore_lung_levels(obj/item/organ/internal/lungs/lungs)
	lungs.heat_level_warning_threshold = cached_heat_level_1
	lungs.heat_level_hazard_threshold = cached_heat_level_2
	lungs.heat_level_danger_threshold = cached_heat_level_3
	lungs.cold_level_warning_threshold = cached_cold_level_1
	lungs.cold_level_hazard_threshold = cached_cold_level_2
	lungs.cold_level_danger_threshold = cached_cold_level_3

/datum/reagent/inverse/healing/convermol/on_mob_delete(mob/living/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	var/obj/item/organ/internal/lungs/lungs = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		return
	restore_lung_levels(lungs)

//seiver
//Inverse
//Allows the scanner to detect organ health to the nearest 1% (similar use to irl) and upgrates the scan to advanced
/datum/reagent/inverse/technetium
	name = "Technetium 99"
	description = "A radioactive tracer agent that can improve a scanner's ability to detect internal organ damage. Will poison the patient when present very slowly, purging or using a low dose is recommended after use."
	metabolization_rate = 0.3 * REM
	chemical_flags = REAGENT_DONOTSPLIT //Do show this on scanner
	// tox_damage = 0 MONKESTATION REMOVAL

	var/time_until_next_poison = 0

	var/poison_interval = (9 SECONDS)

/datum/reagent/inverse/technetium/on_mob_life(mob/living/carbon/owner, seconds_per_tick, times_fired)
	time_until_next_poison -= seconds_per_tick * (1 SECONDS)
	if (time_until_next_poison <= 0)
		time_until_next_poison = poison_interval
		owner.adjustToxLoss(creation_purity * 1, required_biotype = affected_biotype)

	..()

//Kind of a healing effect, Presumably you're using syrinver to purge so this helps that
/datum/reagent/inverse/healing/syriniver
	name = "Syrinifergus"
	description = "This reagent reduces the impurity of all non medicines within the patient, reducing their negative effects."
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	///The list of reagents we've affected
	var/cached_reagent_list = list()
	addiction_types = list(/datum/addiction/medicine = 1.75)

/datum/reagent/inverse/healing/syriniver/on_mob_add(mob/living/affected_mob)
	if(!(iscarbon(affected_mob)))
		return ..()
	var/mob/living/carbon/affected_carbon = affected_mob
	for(var/datum/reagent/reagent as anything in affected_carbon.reagents.reagent_list)
		if(reagent in cached_reagent_list)
			continue
		if(istype(reagent, /datum/reagent/medicine))
			continue
		reagent.creation_purity *= 0.8
		cached_reagent_list += reagent
	..()

/datum/reagent/inverse/healing/syriniver/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(!(iscarbon(affected_mob)))
		return
	if(!cached_reagent_list)
		return
	for(var/datum/reagent/reagent as anything in cached_reagent_list)
		if(!reagent)
			continue
		reagent.creation_purity *= 1.25
	cached_reagent_list = null

//Multiver
//Inverse
//Reaction product when between 0.2 and 0.35 purity.
/datum/reagent/inverse/healing/monover
	name = "Monover"
	description = "A toxin treating reagent, that only is effective if it's the only reagent present in the patient."
	ph = 0.5
	addiction_types = list(/datum/addiction/medicine = 3.5)

//Heals toxins if it's the only thing present - kinda the oposite of multiver! Maybe that's why it's inverse!
/datum/reagent/inverse/healing/monover/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(length(affected_mob.reagents.reagent_list) > 1)
		affected_mob.adjustOrganLoss(ORGAN_SLOT_LUNGS, 0.5 * seconds_per_tick, required_organ_flag = affected_organ_flags) //Hey! It's everyone's favourite drawback from multiver!
		return ..()
	affected_mob.adjustToxLoss(-2 * REM * creation_purity * seconds_per_tick, FALSE, required_biotype = affected_biotype)
	..()
	return TRUE

///Can bring a corpse back to life temporarily (if heart is intact)
///Makes wounds bleed more, if it brought someone back, they take additional brute and heart damage
///They can't die during this, but if they're past crit then take increasing stamina damage
///If they're past fullcrit, their movement is slowed by half
///If they OD, their heart explodes (if they were brought back from the dead)
/datum/reagent/inverse/penthrite
	name = "Nooartrium"
	description = "A reagent that is known to stimulate the heart in a dead patient, temporarily bringing back recently dead patients at great cost to their heart. Mildly toxic when inert in a patient."
	ph = 14
	metabolization_rate = 0.05 * REM
	addiction_types = list(/datum/addiction/medicine = 12)
	overdose_threshold = 20
	self_consuming = TRUE //No pesky liver shenanigans
	chemical_flags = REAGENT_DONOTSPLIT | REAGENT_DEAD_PROCESS
	///If we brought someone back from the dead
	var/back_from_the_dead = FALSE
	/// List of trait buffs to give to the affected mob, and remove as needed.
	var/static/list/trait_buffs = list(
		TRAIT_NOCRITDAMAGE,
		TRAIT_NOCRITOVERLAY,
		TRAIT_NODEATH,
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_STABLEHEART,
	)

/datum/reagent/inverse/penthrite/on_mob_dead(mob/living/carbon/affected_mob, seconds_per_tick)
	if (HAS_TRAIT(affected_mob, TRAIT_SUICIDED))
		return
	var/obj/item/organ/internal/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		return ..()
	metabolization_rate = 0.2 * REM
	affected_mob.add_traits(trait_buffs, type)
	affected_mob.set_stat(CONSCIOUS) //This doesn't touch knocked out
	affected_mob.updatehealth()
	affected_mob.update_sight()
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, STAT_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT) //Because these are normally updated using set_health() - but we don't want to adjust health, and the addition of NOHARDCRIT blocks it being added after, but doesn't remove it if it was added before
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT) //Prevents the user from being knocked out by oxyloss
	affected_mob.set_resting(FALSE) //Please get up, no one wants a deaththrows juggernaught that lies on the floor all the time
	affected_mob.SetAllImmobility(0)
	affected_mob.grab_ghost(force = FALSE) //Shoves them back into their freshly reanimated corpse.
	back_from_the_dead = TRUE
	affected_mob.emote("gasp")
	affected_mob.playsound_local(affected_mob, 'sound/health/fastbeat.ogg', 65)
	..()

/datum/reagent/inverse/penthrite/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(!back_from_the_dead)
		affected_mob.adjustToxLoss(0.2 * seconds_per_tick) // MONKESTATION EDIT: Lower toxin from 0.5/s to 0.2/s and only apply it if inert.
		return ..()
	//Following is for those brought back from the dead only
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT)
	REMOVE_TRAIT(affected_mob, TRAIT_KNOCKEDOUT, OXYLOSS_TRAIT)
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		iter_wound.adjust_blood_flow(1-creation_purity)
	affected_mob.adjustBruteLoss(5 * (1-creation_purity) * seconds_per_tick, required_bodytype = affected_bodytype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, (1 + (1-creation_purity)) * seconds_per_tick, required_organ_flag = affected_organ_flags)
	if(affected_mob.health < affected_mob.crit_threshold)
		affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	if(affected_mob.health < affected_mob.hardcrit_threshold)
		affected_mob.add_actionspeed_modifier(/datum/actionspeed_modifier/nooartrium)
	var/obj/item/organ/internal/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart || heart.organ_flags & ORGAN_FAILING)
		remove_buffs(affected_mob)
	..()

/datum/reagent/inverse/penthrite/on_mob_delete(mob/living/carbon/affected_mob)
	remove_buffs(affected_mob)
	var/obj/item/organ/internal/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(affected_mob.health < -500 || heart.organ_flags & ORGAN_FAILING)//Honestly commendable if you get -500
		explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
		qdel(heart)
		affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	return ..()

/datum/reagent/inverse/penthrite/overdose_start(mob/living/carbon/affected_mob)
	if(!back_from_the_dead)
		return ..()
	var/obj/item/organ/internal/heart/heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!heart) //No heart? No life!
		REMOVE_TRAIT(affected_mob, TRAIT_NODEATH, type)
		affected_mob.stat = DEAD
		return ..()
	explosion(affected_mob, light_impact_range = 1, explosion_cause = src)
	qdel(heart)
	affected_mob.visible_message(span_boldwarning("[affected_mob]'s heart explodes!"))
	return..()

/datum/reagent/inverse/penthrite/proc/remove_buffs(mob/living/carbon/affected_mob)
	affected_mob.remove_traits(trait_buffs, type)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nooartrium)
	affected_mob.remove_actionspeed_modifier(/datum/actionspeed_modifier/nooartrium)
	affected_mob.update_sight()

/*				Non c2 medicines 				*/

/datum/reagent/impurity/mannitol
	name = "Mannitoil"
	description = "Gives the patient a temporary speech impediment."
	color = "#CDCDFF"
	addiction_types = list(/datum/addiction/medicine = 5)
	ph = 12.4
	liver_damage = 0
	///The speech we're forcing on the affected mob
	var/speech_option

/datum/reagent/impurity/mannitol/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(!affected_carbon.dna)
		return
	var/list/speech_options = list(
		/datum/mutation/swedish,
		/datum/mutation/unintelligible,
		/datum/mutation/stoner,
		/datum/mutation/medieval,
		/datum/mutation/wacky,
		/datum/mutation/piglatin,
		/datum/mutation/nervousness,
		/datum/mutation/mute,
		)
	speech_options = shuffle(speech_options)
	for(var/option in speech_options)
		if(affected_carbon.dna.get_mutation(option, MUTATION_SOURCE_MANNITOIL))
			continue
		affected_carbon.dna.add_mutation(option, MUTATION_SOURCE_MANNITOIL)
		speech_option = option
		return

/datum/reagent/impurity/mannitol/on_mob_delete(mob/living/affected_mob)
	. = ..()
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbon = affected_mob
	carbon.dna?.remove_mutation(speech_option, MUTATION_SOURCE_MANNITOIL)

/datum/reagent/inverse/neurine
	name = "Neruwhine"
	description = "Induces a temporary brain trauma in the patient by redirecting neuron activity."
	color = "#DCDCAA"
	ph = 13.4
	addiction_types = list(/datum/addiction/medicine = 8)
	metabolization_rate = 0.025 * REM
	// tox_damage = 0 MONKESTATION REMOVAL
	//The temporary trauma passed to the affected mob
	var/datum/brain_trauma/temp_trauma

/datum/reagent/inverse/neurine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	.=..()
	if(temp_trauma)
		return
	if(!(SPT_PROB(creation_purity*10, seconds_per_tick)))
		return
	var/traumalist = subtypesof(/datum/brain_trauma)
	var/list/forbiddentraumas = list(
		/datum/brain_trauma/severe/split_personality,  // Split personality uses a ghost, I don't want to use a ghost for a temp thing
		/datum/brain_trauma/special/obsessed, // Obsessed sets the owner as an antag - I presume this will lead to problems, so we'll remove it
		/datum/brain_trauma/hypnosis, // Hypnosis, same reason as obsessed, plus a bug makes it remain even after the neurowhine purges and then turn into "nothing" on the med reading upon a second application
		/datum/brain_trauma/special/honorbound, // Designed to be chaplain exclusive
	)
	traumalist -= forbiddentraumas
	var/obj/item/organ/internal/brain/brain = affected_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
	traumalist = shuffle(traumalist)
	for(var/trauma in traumalist)
		if(brain.brain_gain_trauma(trauma, TRAUMA_RESILIENCE_MAGIC))
			temp_trauma = trauma
			return

/datum/reagent/inverse/neurine/on_mob_delete(mob/living/carbon/affected_mob)
	.=..()
	if(!temp_trauma)
		return
	if(istype(temp_trauma, /datum/brain_trauma/special/imaginary_friend))//Good friends stay by you, no matter what
		return
	affected_mob.cure_trauma_type(temp_trauma, resilience = TRAUMA_RESILIENCE_MAGIC)

/datum/reagent/inverse/corazargh
	name = "Corazargh" //It's what you yell! Though, if you've a better name feel free. Also an omage to an older chem
	description = "Interferes with the body's natural pacemaker, forcing the patient to manually beat their heart."
	color = "#5F5F5F"
	self_consuming = TRUE
	ph = 13.5
	addiction_types = list(/datum/addiction/medicine = 2.5)
	metabolization_rate = REM
	chemical_flags = REAGENT_DEAD_PROCESS
	// tox_damage = 0 MONKESTATION REMOVAL
	///The old heart we're swapping for
	var/obj/item/organ/internal/heart/original_heart
	///The new heart that's temp added
	var/obj/item/organ/internal/heart/cursed/manual_heart

///Creates a new cursed heart and puts the old inside of it, then replaces the position of the old
/datum/reagent/inverse/corazargh/on_mob_metabolize(mob/living/affected_mob)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/carbon_mob = affected_mob
	original_heart = affected_mob.get_organ_slot(ORGAN_SLOT_HEART)
	if(!original_heart)
		return
	manual_heart = new(null, src)
	original_heart.Remove(carbon_mob, special = TRUE) //So we don't suddenly die
	original_heart.forceMove(manual_heart)
	original_heart.organ_flags |= ORGAN_FROZEN //Not actually frozen, but we want to pause decay
	manual_heart.Insert(carbon_mob, special = TRUE)
	//these last so instert doesn't call them
	RegisterSignal(carbon_mob, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_gained_organ))
	RegisterSignal(carbon_mob, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_removed_organ))
	to_chat(affected_mob, span_userdanger("You feel your heart suddenly stop beating on it's own - you'll have to manually beat it!"))
	..()

///Intercepts the new heart and creates a new cursed heart - putting the old inside of it
/datum/reagent/inverse/corazargh/proc/on_gained_organ(mob/affected_mob, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!istype(organ, /obj/item/organ/internal/heart))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	original_heart = organ
	original_heart.Remove(affected_carbon, special = TRUE)
	original_heart.forceMove(manual_heart)
	original_heart.organ_flags |= ORGAN_FROZEN //Not actually frozen, but we want to pause decay
	if(!manual_heart)
		manual_heart = new(null, src)
	manual_heart.Insert(affected_carbon, special = TRUE)

///If we're ejecting out the organ - replace it with the original
/datum/reagent/inverse/corazargh/proc/on_removed_organ(mob/prev_owner, obj/item/organ/organ)
	SIGNAL_HANDLER
	if(!organ == manual_heart)
		return
	original_heart.forceMove(organ.loc)
	original_heart.organ_flags &= ~ORGAN_FROZEN //enable decay again
	qdel(organ)

///We're done - remove the curse and restore the old one
/datum/reagent/inverse/corazargh/on_mob_end_metabolize(mob/living/affected_mob)
	//Do these first so Insert doesn't call them
	UnregisterSignal(affected_mob, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(affected_mob, COMSIG_CARBON_GAIN_ORGAN)
	if(!iscarbon(affected_mob))
		return
	var/mob/living/carbon/affected_carbon = affected_mob
	if(original_heart) //Mostly a just in case
		original_heart.organ_flags &= ~ORGAN_FROZEN //enable decay again
		original_heart.Insert(affected_carbon, special = TRUE)
	qdel(manual_heart)
	to_chat(affected_mob, span_userdanger("You feel your heart start beating normally again!"))
	..()

/datum/reagent/inverse/antihol
	name = "Prohol"
	description = "Promotes alcoholic substances within the patients body, making their effects more potent."
	taste_description = "alcohol" //mostly for sneaky slips
	chemical_flags = REAGENT_INVISIBLE
	metabolization_rate = 0.05 * REM//This is fast
	addiction_types = list(/datum/addiction/medicine = 4.5)
	color = "#4C8000"
	// tox_damage = 0 MONKESTATION REMOVAL

/datum/reagent/inverse/antihol/on_mob_life(mob/living/carbon/C, seconds_per_tick, times_fired)
	for(var/datum/reagent/consumable/ethanol/alcohol in C.reagents.reagent_list)
		alcohol.boozepwr += seconds_per_tick
	..()

/datum/reagent/inverse/oculine
	name = "Oculater"
	description = "Temporarily blinds the patient."
	reagent_state = LIQUID
	color = "#DDDDDD"
	metabolization_rate = 0.1 * REM
	addiction_types = list(/datum/addiction/medicine = 3)
	taste_description = "funky toxin"
	ph = 13
	// tox_damage = 0 MONKESTATION REMOVAL
	metabolization_rate = 0.2 * REM
	///Did we get a headache?
	var/headache = FALSE

/datum/reagent/inverse/oculine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	if(headache)
		return ..()
	if(SPT_PROB(100 * creation_purity, seconds_per_tick))
		affected_mob.become_blind(IMPURE_OCULINE)
		to_chat(affected_mob, span_danger("You suddenly develop a pounding headache as your vision fluxuates."))
		headache = TRUE
	..()

/datum/reagent/inverse/oculine/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.cure_blind(IMPURE_OCULINE)
	if(headache)
		to_chat(affected_mob, span_notice("Your headache clears up!"))
	..()

/datum/reagent/impurity/inacusiate
	name = "Tinacusiate"
	description = "Makes the patient's hearing temporarily funky."
	reagent_state = LIQUID
	addiction_types = list(/datum/addiction/medicine = 5.6)
	color = "#DDDDFF"
	taste_description = "the heat evaporating from your mouth."
	ph = 1
	liver_damage = 0.1
	metabolization_rate = 0.04 * REM
	///The random span we start hearing in
	var/randomSpan

/datum/reagent/impurity/inacusiate/on_mob_metabolize(mob/living/affected_mob, seconds_per_tick, times_fired)
	randomSpan = pick(list("clown", "small", "big", "hypnophrase", "alien", "cult", "alert", "danger", "emote", "yell", "brass", "sans", "papyrus", "robot", "his_grace", "phobia"))
	RegisterSignal(affected_mob, COMSIG_MOVABLE_HEAR, PROC_REF(owner_hear))
	to_chat(affected_mob, span_warning("Your hearing seems to be a bit off!"))
	..()

/datum/reagent/impurity/inacusiate/on_mob_end_metabolize(mob/living/affected_mob)
	UnregisterSignal(affected_mob, COMSIG_MOVABLE_HEAR)
	to_chat(affected_mob, span_notice("You start hearing things normally again."))
	..()

/datum/reagent/impurity/inacusiate/proc/owner_hear(mob/living/owner, list/hearing_args)
	SIGNAL_HANDLER

	// don't skip messages that the owner says or can't understand (since they still make sounds)
	if(HAS_TRAIT(owner, TRAIT_DEAF))
		return

	hearing_args[HEARING_RAW_MESSAGE] = "<span class='[randomSpan]'>[hearing_args[HEARING_RAW_MESSAGE]]</span>"

/datum/reagent/inverse/krokodil
	name = "Permonid"
	description = "Highly potent sedative that provides the best benefits for pain management and surgery. Extremely addictive."
	color = "#15b5dd55"
	metabolization_rate = 0.1 * REM
	overdose_threshold = 20
	ph = 2.5
	addiction_types = list(/datum/addiction/opioids = 30)
	metabolized_traits = list(TRAIT_ANALGESIA)

/datum/reagent/inverse/krokodil/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = max(0.3, surgery.speed_modifier)

/datum/reagent/inverse/krokodil/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.add_mood_event("smacked out", /datum/mood_event/narcotic_heavy)

/datum/reagent/inverse/krokodil/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_jitter_if_lower(10 SECONDS)
	affected_mob.set_dizzy_if_lower(5 SECONDS)
	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.emote("drool")
	if(SPT_PROB(5, seconds_per_tick))
		to_chat(affected_mob, span_warning("You briefly lose control of your legs!"))
		affected_mob.Knockdown(5 SECONDS)
	if(SPT_PROB(5, seconds_per_tick))
		to_chat(affected_mob, span_warning("The muscles in your arms give out!"))
		affected_mob.drop_all_held_items()

/datum/reagent/inverse/bath_salts
	name = "Monkey Dust"
	description = "Oop aak chee aak eek chee. Eek aak oop chee oop aak aak!!"
	color = "#7e3900"
	ph = 14
	metabolization_rate = 0.2 * REM
	var/datum/martial_art/jungle_arts/jungle_arts

/datum/reagent/inverse/bath_salts/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(is_simian(affected_mob))
		affected_mob.gain_trauma(/datum/brain_trauma/special/primal_instincts, TRAUMA_RESILIENCE_ABSOLUTE)
		affected_mob.add_traits(list(TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_ANALGESIA), type)
		jungle_arts = new(src)
		jungle_arts.teach(affected_mob)

/datum/reagent/inverse/bath_salts/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(jungle_arts)
		jungle_arts.remove(affected_mob)
		QDEL_NULL(jungle_arts)
	if(is_simian(affected_mob))
		affected_mob.cure_trauma_type(/datum/brain_trauma/special/primal_instincts, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
		affected_mob.remove_traits(list(TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_ANALGESIA), type)
		affected_mob.Sleeping(30 SECONDS)

/datum/reagent/inverse/bath_salts/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.reagents.has_reagent(/datum/reagent/drug/bath_salts))
		affected_mob.reagents.remove_reagent(type, volume)
		return

	if(is_simian(affected_mob))
		var/need_mob_update
		need_mob_update = affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)

		if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/monkey_energy))
			need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)

		if(need_mob_update)
			. = TRUE

	else if(SPT_PROB(10, seconds_per_tick))
		affected_mob.emote(pick("screech","scratch","jump","look"))

/datum/reagent/inverse/aranesp
	name = "Epoetin Alfa"
	description = "Synthetic medication that induces blood regeneration and wound clotting in patients. \
		Causes adverse side effects, including arterial damage and migraines when excessively used over time."
	color = "#dee4ff"
	metabolization_rate = 0.25 * REM
	overdose_threshold = 20
	ph = 6.1

/datum/reagent/inverse/aranesp/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(overdosed)
		return
	var/datum/wound/bloodiest_wound
	for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
		if(iter_wound.blood_flow && iter_wound.blood_flow > bloodiest_wound?.blood_flow)
			bloodiest_wound = iter_wound
	bloodiest_wound?.adjust_blood_flow(-0.1 * REM * seconds_per_tick)

	if(affected_mob.blood_volume < BLOOD_VOLUME_NORMAL)
		affected_mob.blood_volume += min(1 * seconds_per_tick, BLOOD_VOLUME_NORMAL)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, 0.2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)

	switch(current_cycle)
		if(10)
			to_chat(affected_mob, span_warning("You feel a migraine coming on..."))
			affected_mob.adjust_eye_blur(2 SECONDS * REM * seconds_per_tick)

		if(15 to 30)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your head aches as your vision blurs."))
				affected_mob.adjust_eye_blur(5 SECONDS * REM * seconds_per_tick)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your face contorts as a sudden pain forms in your head."))
				affected_mob.Stun(1 SECONDS)

		if(31 to 45)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Intense pressure forms in your head, you can barely see!"))
				affected_mob.adjust_eye_blur(10 SECONDS * REM * seconds_per_tick)
				affected_mob.adjust_confusion_up_to(5 SECONDS, 20 SECONDS)
				affected_mob.adjust_hallucinations(10 SECONDS)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("You lose focus and stare ahead."))
				affected_mob.Stun(3 SECONDS)
				affected_mob.emote(pick("stare","drool","moan","look"))
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your inhaling becomes more stressed, it's getting harder to breathe!"))
				affected_mob.reagents.add_reagent(/datum/reagent/toxin/histamine, 4 * REM * seconds_per_tick)

		if(46 to INFINITY)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("It feels like your head is going to implode!"))
				affected_mob.adjust_eye_blur(10 SECONDS * REM * seconds_per_tick)
				affected_mob.adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
				affected_mob.adjust_hallucinations(30 SECONDS)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("You can't bring yourself to focus at all!"))
				affected_mob.Stun(5 SECONDS)
				affected_mob.emote(pick("stare","drool","tremble","shake"))
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your breathing becomes weak and raspy, you can barely stay conscious!"))
				affected_mob.reagents.add_reagent(/datum/reagent/toxin/histamine, 6 * REM * seconds_per_tick)
				affected_mob.losebreath += 3

/datum/reagent/inverse/aranesp/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(affected_mob, span_warning("It feels like your head is going to implode!"))
		affected_mob.adjust_eye_blur(10 SECONDS * REM * seconds_per_tick)
		affected_mob.adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
		affected_mob.adjust_hallucinations(30 SECONDS)
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(affected_mob, span_warning("You can't bring yourself to focus at all!"))
		affected_mob.Stun(50)
		affected_mob.emote(pick("stare","drool","tremble","shake"))
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(affected_mob, span_warning("Your breathing becomes weak and raspy, you can barely stay conscious!"))
		holder.add_reagent(/datum/reagent/toxin/histamine, 6 * REM * seconds_per_tick)
		affected_mob.losebreath += 3
		need_mob_update = TRUE

	if(need_mob_update)
		return TRUE

/datum/reagent/inverse/happiness
	name = "Sadness"
	description = "Causes severe depressive behavior in users, and actively purges other antidepressants."
	color = "#0004ff"
	ph = 12
	metabolization_rate = 0.1 * REM
	penetrates_skin = TOUCH|VAPOR

/datum/reagent/inverse/happiness/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_mood_event("sadness_inverse", /datum/mood_event/sadness_inverse)
	switch(volume)
		if(1 to INFINITY) // prevents microdosing from repeating this line
			affected_mob.say("What?? No... NO...", forced = type)

/datum/reagent/inverse/happiness/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.clear_mood_event("sadness_inverse")

/datum/reagent/inverse/happiness/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & (TOUCH|VAPOR))
		exposed_mob.emote("cry")
		return

/datum/reagent/inverse/happiness/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.mob_mood?.mood_events["friendly_hug"] && !HAS_TRAIT(affected_mob, TRAIT_BADTOUCH))
		affected_mob.reagents.remove_reagent(type, volume)
		return

	affected_mob.reagents.remove_reagent(/datum/reagent/drug/happiness, 5 * REM * seconds_per_tick)
	affected_mob.reagents.remove_reagent(/datum/reagent/medicine/psicodine, 5 * REM * seconds_per_tick)

	affected_mob.mob_mood.adjust_sanity(-7.5 * REM * seconds_per_tick, minimum = SANITY_INSANE)
	if(affected_mob.mob_mood != null && affected_mob.mob_mood.sanity < (SANITY_CRAZY))
		affected_mob.adjust_drowsiness_up_to(5 SECONDS, 30 SECONDS)
		if(SPT_PROB(25, seconds_per_tick))
			affected_mob.emote(pick("cry","frown","pout","whimper","sigh"))
		if(SPT_PROB(3, seconds_per_tick))
			affected_mob.say(pick("Why are we still here? Just to suffer?","To live is to suffer!","Life is suffering. It is the nature of existence!","Each day we wake up is another day closer to death.","Sometimes I can hear my bones straining under the weight of all the lives I'm not living.","There are no beautiful surfaces without a terrible depth."), forced = type)

/datum/reagent/inverse/baldium
	name = "Maldium"
	description = "Potent psychotropic that causes intense anger within users."
	color = "#ff0000"
	ph = 1
	metabolization_rate = 0.4 * REM
	var/delayed_burn_damage = 0

/datum/reagent/inverse/baldium/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.add_shared_particles(/particles/smoke/steam/mald)
	affected_mob.manual_emote("inhales sharply.")
	to_chat(affected_mob, span_warning("You can't help but find everything more irritating."))

/datum/reagent/inverse/baldium/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, "#fe0000")
	affected_mob.remove_shared_particles(/particles/smoke/steam/mald)
	affected_mob.manual_emote("exhales sharply.")
	to_chat(affected_mob, span_warning("You feel an intense burning sensation as your anger subsides!"))

/datum/reagent/inverse/baldium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	delayed_burn_damage += (seconds_per_tick * 1)
	if(affected_mob.reagents.has_reagent(/datum/reagent/consumable/salt))
		affected_mob.reagents.remove_reagent(/datum/reagent/inverse/baldium, 3 * REM * seconds_per_tick)
		affected_mob.reagents.remove_reagent(/datum/reagent/consumable/salt, 1 * REM * seconds_per_tick)

	switch(current_cycle)
		if(5)
			affected_mob.add_atom_colour("#fe0000", TEMPORARY_COLOUR_PRIORITY)
			if(!HAS_TRAIT(affected_mob, TRAIT_PACIFISM))
				var/turf/angery_blast = get_turf(affected_mob)
				goonchem_vortex(angery_blast, 1, 4)
				to_chat(affected_mob, span_warning("You can't control yourself as you yell out ANGRILY!!"))
				affected_mob.emote("scream")
				affected_mob.say(pick("RAGE!! UNLEASH THE RAGE!!","I'M SO ANGRY!!","WHY I OUGHTA...","AAARRRGGHH!!"), forced = type)
			else
				to_chat(affected_mob, span_warning("You calmly yet firmly state your discontent."))
				affected_mob.say(pick("Aaahhhh...","Rage, woo yeah...","I'm slightly upset...",), forced = type)

		if(6 to INFINITY)
			if(SPT_PROB(10, seconds_per_tick))
				affected_mob.manual_emote(pick("breathes rapidly!","huffs, and puffs...","stares MENACINGLY!","sighs AGGRESSIVELY!","sheds a tear ANGRILY!"))

/datum/reagent/inverse/baldium/on_mob_delete(mob/living/affected_mob)
	. = ..()
	affected_mob.log_message("has taken [delayed_burn_damage] burn damage from maldium's aftereffects", LOG_ATTACK)
	affected_mob.adjustFireLoss(delayed_burn_damage, updating_health = TRUE, required_bodytype = affected_bodytype)

/datum/reagent/inverse/colorful_reagent
	name = "Dulling Reagent"
	description = "Extremely drab coloring pigment that is favored by corporations who wish to maximize suffering."
	color = COLOR_GRAY
	ph = 10
	metabolization_rate = 0.4 * REM
	var/can_color_mobs = TRUE
	var/can_color_clothing = TRUE
	var/can_color_organs = FALSE
	var/datum/callback/color_callback
	var/list/random_color_list = list("#1a1a1a","#2e2e2e","#424242","#565656","#6a6a6a","#7e7e7e","#929292","#a6a6a6","#bababa","#cecece")

/datum/reagent/inverse/colorful_reagent/on_mob_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.gain_trauma(/datum/brain_trauma/mild/color_blindness, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/inverse/colorful_reagent/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.cure_trauma_type(/datum/brain_trauma/mild/color_blindness, resilience = TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/inverse/colorful_reagent/overdose_start(mob/living/affected_mob)
	. = ..()
	metabolization_rate = 0.04 * REM

/datum/reagent/inverse/colorful_reagent/New()
	color_callback = CALLBACK(src, PROC_REF(UpdateColor))
	SSticker.OnRoundstart(color_callback)
	return ..()

/datum/reagent/inverse/colorful_reagent/Destroy()
	LAZYREMOVE(SSticker.round_end_events, color_callback)
	color_callback = null
	return ..()

/datum/reagent/inverse/colorful_reagent/proc/UpdateColor()
	color_callback = null
	color = pick(random_color_list)

/datum/reagent/inverse/colorful_reagent/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	var/picked_color = pick(random_color_list)
	var/color_filter = color_transition_filter(picked_color, SATURATION_OVERRIDE)
	if (can_color_clothing && (methods & (TOUCH|VAPOR)))
		var/include_flags = INCLUDE_HELD|INCLUDE_ACCESSORIES
		if (methods & VAPOR || touch_protection >= 1)
			include_flags |= INCLUDE_POCKETS
		for (var/obj/item/to_color in exposed_mob.get_equipped_items(include_flags))
			to_color.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

	if (ishuman(exposed_mob))
		var/mob/living/carbon/human/exposed_human = exposed_mob
		exposed_human.set_facial_haircolor(picked_color, update = FALSE)
		exposed_human.set_haircolor(picked_color)

	if (!can_color_mobs)
		return

	if (!iscarbon(exposed_mob))
		exposed_mob.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob

	for (var/obj/item/organ/organ as anything in exposed_carbon.organs)
		organ.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

	for (var/obj/item/bodypart/part as anything in exposed_carbon.bodyparts)
		part.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

/datum/reagent/inverse/colorful_reagent/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	if (!iscarbon(affected_mob))
		if (can_color_mobs)
			affected_mob.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)
		return

	if(!can_color_organs)
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	var/color_priority = WASHABLE_COLOUR_PRIORITY
	if (current_cycle >= 30)
		color_priority = FIXED_COLOUR_PRIORITY

	for (var/obj/item/organ/organ as anything in carbon_mob.organs)
		organ.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), color_priority)

/datum/reagent/inverse/colorful_reagent/expose_atom(atom/exposed_atom, reac_volume)
	. = ..()
	if(!isliving(exposed_atom))
		exposed_atom.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)

/datum/reagent/inverse/gravitum
	name = "Newtonium"
	description = "Experimental reagent that induces heavy gravokinetic effects on users."
	color = "#4b0082"
	ph = 2.3
	metabolization_rate = 1 * REM
	overdose_threshold = 30

/datum/reagent/inverse/gravitum/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.AddElement(/datum/element/forced_gravity, gravity = 5, ignore_turf_gravity = TRUE, can_override = FALSE)

/datum/reagent/inverse/gravitum/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.RemoveElement(/datum/element/forced_gravity, gravity = 5, ignore_turf_gravity = TRUE, can_override = FALSE)

/datum/reagent/inverse/gravitum/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	switch(current_cycle)
		if(10)
			for(var/obj/item/bodypart/leg/leg in affected_mob.bodyparts)
				affected_mob.cause_wound_of_type_and_severity(WOUND_BLUNT, leg, WOUND_SEVERITY_MODERATE)
			to_chat(affected_mob, span_warning("Your legs start to cave in to your overwhelming gravity!"))

		if(20)
			for(var/obj/item/bodypart/leg/leg in affected_mob.bodyparts)
				affected_mob.cause_wound_of_type_and_severity(WOUND_BLUNT, leg, WOUND_SEVERITY_SEVERE)
			to_chat(affected_mob, span_warning("Your bones fragment horribly as the gravity pounds on you!"))

		if(30)
			for(var/obj/item/bodypart/leg/leg in affected_mob.bodyparts)
				affected_mob.cause_wound_of_type_and_severity(WOUND_BLUNT, leg, WOUND_SEVERITY_CRITICAL)
			to_chat(affected_mob, span_warning("The gravity of this situation makes your bones snap like popsicle sticks!"))

/datum/reagent/inverse/gravitum/overdose_start(mob/living/carbon/affected_mob)
	. = ..()
	affected_mob.AddElement(/datum/element/squish, 120 SECONDS)
	for(var/obj/item/bodypart/leg/leg in affected_mob.bodyparts)
		affected_mob.cause_wound_of_type_and_severity(WOUND_SLASH, leg, WOUND_SEVERITY_SEVERE)
