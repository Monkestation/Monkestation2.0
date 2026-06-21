/obj/item/organ/internal/liver/clockwork
	name = "biometallic alembic"
	desc = "A series of small pumps and boilers, designed to facilitate proper metabolism."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "liver-clock"
	organ_flags = ORGAN_ROBOTIC
	alcohol_tolerance = 0
	liver_resistance = 0
	toxTolerance = 1 //while the organ isn't damaged by doing its job, it doesnt do it very well

/obj/item/organ/internal/liver/slime
	name = "endoplasmic reticulum"
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_UNREMOVABLE
	organ_traits = list(TRAIT_TOXINLOVER)

/obj/item/organ/internal/liver/slime/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	if(!(organ_owner.mob_biotypes & MOB_SLIME))
		return
	// slimes use plasma to fix wounds, and if they have enough blood, organs
	var/static/list/organs_we_mend = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
	)
	if(chem.type == /datum/reagent/toxin/plasma || chem.type == /datum/reagent/toxin/hot_ice)
		if(!organ_owner.getBruteLoss() && !organ_owner.getFireLoss())
			return
		if(HAS_TRAIT(organ_owner, TRAIT_SLIME_HYDROPHOBIA) || organ_owner.get_skin_temperature() < organ_owner.bodytemp_cold_damage_limit)
			to_chat(organ_owner, span_purple("Your membrane is too viscous to mend its wounds..."))
			return
		var/list/to_heal = rand(2) ? list(BRUTE, BURN) : list(BURN, BRUTE) // Randomize what is healed first
		organ_owner.heal_ordered_damage(HEALTH_HEALED * REM * seconds_per_tick, to_heal)

		if(organ_owner.blood_volume > BLOOD_VOLUME_SLIME_SPLIT)
			organ_owner.adjustOrganLoss(
				pick(organs_we_mend),
				-2 * seconds_per_tick,
			)
		if(SPT_PROB(5, seconds_per_tick))
			to_chat(organ_owner, span_purple("Your body's thirst for plasma is quenched, your inner and outer membrane using it to regenerate."))

	else if(chem.type == /datum/reagent/water)
		if(HAS_TRAIT(organ_owner, TRAIT_SLIME_HYDROPHOBIA) || HAS_TRAIT(organ_owner, TRAIT_GODMODE) || organ_owner.blood_volume <= 0)
			return

		var/datum/antagonist/bloodsucker/bloodsucker = IS_BLOODSUCKER(organ_owner)
		if(bloodsucker)
			bloodsucker.AddBloodVolume(-3 * seconds_per_tick)
		else
			organ_owner.blood_volume = max(organ_owner.blood_volume - (3 * seconds_per_tick), 0)

		if(SPT_PROB(25, seconds_per_tick))
			to_chat(organ_owner, span_warning("The water starts to weaken and adulterate your insides!"))

/obj/item/organ/internal/liver/slime/on_life(seconds_per_tick, times_fired)
	. = ..()
	operated = FALSE

/obj/item/organ/internal/liver/synth
	name = "reagent processing unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
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

/datum/design/synth_liver
	name = "Reagent Processing Unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	id = "synth_liver"
	build_type = PROTOLATHE | AWAY_LATHE | MECHFAB
	construction_time = 4 SECONDS
	materials = list(
		/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)
	build_path = /obj/item/organ/internal/liver/synth
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_SYNTHETIC_ORGANS
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE
