/obj/item/organ/internal/liver/synth
	name = "reagent processing unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	icon = 'icons/obj/medical/ipc_organs.dmi'
	icon_state = "liver-ipc"
	filterToxins = FALSE //We dont filter them, we're immune to them
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	maxHealth = 1 * STANDARD_ORGAN_THRESHOLD
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES

/obj/item/organ/internal/liver/synth/emp_act(severity)
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("Alert: Critical! Reagent processing unit failure, seek maintenance immediately. Error Code: DR-1k"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maximum = maxHealth, required_organ_flag = ORGAN_ROBOTIC)

		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Reagent processing unit failure, seek maintenance for diagnostic. Error Code: DR-0k"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maximum = maxHealth, required_organ_flag = ORGAN_ROBOTIC)

/obj/item/organ/internal/liver/synth/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()

	if((. & COMSIG_MOB_STOP_REAGENT_TICK) || (organ_flags & ORGAN_FAILING))
		return
	if(!chem.synthetic_boozepwr)
		return
	var/booze_power = chem.synthetic_boozepwr
	if(organ_owner.nutrition < NUTRITION_LEVEL_ALMOST_FULL)
		organ_owner.adjust_nutrition(booze_power * 0.055) //one full glass of acetone = 1 full charge if my math is correct
	if(HAS_TRAIT(organ_owner, TRAIT_ALCOHOL_TOLERANCE))
		booze_power *= 0.7
	if(HAS_TRAIT(organ_owner, TRAIT_LIGHT_DRINKER))
		booze_power *= 2
	if(organ_owner.get_drunk_amount() < chem.volume * chem.synthetic_boozepwr)
		organ_owner.adjust_drunk_effect(sqrt(chem.volume) * booze_power * ALCOHOL_RATE * REM * seconds_per_tick)
	organ_owner.mind.add_addiction_points(/datum/addiction/alcohol, chem.synthetic_boozepwr/20)
