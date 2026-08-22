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
		if(organ_owner.get_skin_temperature() < organ_owner.bodytemp_cold_damage_limit)
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
		if(HAS_TRAIT(organ_owner, TRAIT_GODMODE) || organ_owner.blood_volume <= 0)
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
