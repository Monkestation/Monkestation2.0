/datum/quirk/shielding_exchange
	name = "Shielding Exchange"
	desc = "IPC ONLY: Your limbs are resistant to the effects of EMPs! This doesn't protect your organs, though, and it makes you cripplingly non-waterproof." //basically it replaces one bullshit stun with another, weaker but more accessable bullshit stun. the illusion of choice, people.
	icon = FA_ICON_SHIELD_HALVED
	value = 0
	gain_text = span_danger("You feel like water might be a problem.")
	lose_text = span_notice("You are once again IP68 compliant.") //i see no reason we wouldn't still be using IEEE standards in the far future. they're good standards.
	medical_record_text = "Patient has exchanged their internal waterproofing for EM insulation."
	hardcore_value = 2
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/clothing/suit/hooded/ethereal_raincoat) //raincoat! lol
	species_whitelist = list(SPECIES_IPC)
	COOLDOWN_DECLARE(water_yeowchy) //this is needed, trust me

/datum/quirk/shielding_exchange/add(client/client_source)
	RegisterSignal(quirk_holder, COMSIG_ATOM_EXPOSE_REAGENTS, PROC_REF(on_reagent_expose))
	var/mob/living/carbon/human/humie = quirk_holder
	for(var/obj/item/bodypart/part in humie.bodyparts)
		part.emp_multiplier = 0

/datum/quirk/shielding_exchange/remove(client/client_source)
	UnregisterSignal(quirk_holder, COMSIG_ATOM_EXPOSE_REAGENTS)
	var/mob/living/carbon/human/humie = quirk_holder
	for(var/obj/item/bodypart/part in humie.bodyparts)
		part.emp_multiplier = initial(part.emp_multiplier)


//shamelessly stolen from oozeling code because it was exactly what i needed (someone make this a mob proc some day [but not me (im lazy)])
#define WATER_PROTECTION_HEAD 0.3
#define WATER_PROTECTION_CHEST 0.2
#define WATER_PROTECTION_GROIN 0.1
#define WATER_PROTECTION_LEG (0.075 * 2)
#define WATER_PROTECTION_FOOT (0.025 * 2)
#define WATER_PROTECTION_ARM (0.075 * 2)
#define WATER_PROTECTION_HAND (0.025 * 2)

/datum/quirk/shielding_exchange/proc/water_damage_multiplier(mob/living/carbon/human/robit)
	. = 1

	var/protection_flags = NONE
	for(var/obj/item/clothing/worn in robit.get_equipped_items())
		if(worn.clothing_flags & THICKMATERIAL)
			protection_flags |= worn.body_parts_covered

	var/missing_limbs = FULL_BODY & ~(CHEST|GROIN)
	for(var/obj/item/bodypart/limb in robit.bodyparts)
		var/bodypart_flags = limb.body_part
		// stupid thing needed because arms/legs don't include the hand/foot flags.
		if(bodypart_flags & ARM_LEFT)
			bodypart_flags |= HAND_LEFT
		if(bodypart_flags & ARM_RIGHT)
			bodypart_flags |= HAND_RIGHT
		if(bodypart_flags & LEG_LEFT)
			bodypart_flags |= FOOT_LEFT
		if(bodypart_flags & LEG_RIGHT)
			bodypart_flags |= FOOT_RIGHT
		missing_limbs &= ~bodypart_flags

	protection_flags |= missing_limbs

	if(protection_flags)
		if(protection_flags & HEAD)
			. -= WATER_PROTECTION_HEAD
		if(protection_flags & CHEST)
			. -= WATER_PROTECTION_CHEST
		if(protection_flags & GROIN)
			. -= WATER_PROTECTION_GROIN
		if(protection_flags & LEGS)
			. -= WATER_PROTECTION_LEG
		if(protection_flags & FEET)
			. -= WATER_PROTECTION_FOOT
		if(protection_flags & ARMS)
			. -= WATER_PROTECTION_ARM
		if(protection_flags & HANDS)
			. -= WATER_PROTECTION_HAND

	return clamp(FLOOR(., 0.1), 0, 1)

#undef WATER_PROTECTION_HEAD
#undef WATER_PROTECTION_CHEST
#undef WATER_PROTECTION_GROIN
#undef WATER_PROTECTION_LEG
#undef WATER_PROTECTION_FOOT
#undef WATER_PROTECTION_ARM
#undef WATER_PROTECTION_HAND

/datum/quirk/shielding_exchange/proc/on_reagent_expose(mob/living/carbon/human/robit, list/reagents, datum/reagents/source, methods, volume_modifier, show_message)
	SIGNAL_HANDLER
	if(!(locate(/datum/reagent/water) in reagents)) // we only care if we're exposed to water
		return NONE
	if(HAS_TRAIT(robit, TRAIT_GODMODE))
		return NONE
	var/water_multiplier = water_damage_multiplier(robit)
	if(water_multiplier <= 0)
		return COMPONENT_NO_EXPOSE_REAGENTS
	if(robit.reagents.has_reagent(/datum/reagent/dinitrogen_plasmide))
		to_chat(robit, span_warning("The coolant compound protects your internal componentry from the water.")) //dont ask how it works its magic robot work good juice ok?
		return COMPONENT_NO_EXPOSE_REAGENTS
	var/how_much_water = source.get_reagent_amount(/datum/reagent/water) * water_multiplier
	switch(how_much_water)
		if(0 to 5)
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(2, 0, robit.loc)
			spark_system.start()
			playsound(robit, SFX_SPARKS, 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			robit.adjust_jitter_up_to(6 SECONDS, 1 MINUTES)
		if(5.0001 to 20)
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(4, 0, robit.loc)
			spark_system.start()
			playsound(robit, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			robit.adjust_jitter_up_to(20 SECONDS, 2 MINUTES)
			robit.adjust_confusion(5 SECONDS)
		if(20.0001 to 49.9999)
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(6, 0, robit.loc)
			spark_system.start()
			playsound(robit, SFX_SPARKS, 60, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			robit.adjust_jitter_up_to(1 MINUTE, 5 MINUTES)
			robit.adjust_confusion(10 SECONDS)
			if(COOLDOWN_FINISHED(src, water_yeowchy))
				robit.Stun(3 SECONDS)
				robit.Paralyze(2 SECONDS)
				COOLDOWN_START(src, water_yeowchy, 6 SECONDS)
		if(50 to INFINITY)
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
			spark_system.set_up(8, 0, robit.loc)
			spark_system.start()
			playsound(robit, SFX_SPARKS, 70, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			robit.adjust_jitter_up_to(2 MINUTE, 6 MINUTES)
			robit.adjust_confusion(10 SECONDS)
			if(COOLDOWN_FINISHED(src, water_yeowchy))
				robit.Stun(6 SECONDS)
				robit.Paralyze(4 SECONDS)
				COOLDOWN_START(src, water_yeowchy, 10 SECONDS)
	robit.force_say()
	robit.sharp_pain(BODY_ZONES_ALL, (how_much_water / 10), BURN, 10 SECONDS) //ough (for reference a full bluespace beaker of water would be greatly slowing but not quite immobilizing)
	to_chat(robit, span_robot(span_danger("BZZZTT!!")))
