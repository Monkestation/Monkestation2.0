/datum/reagent/consumable/ethanol/melon_liquor
	name = "Melon Liquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	taste_description = "fruity alcohol"
	color = "#138808d0" // rgb: 19, 136, 8
	boozepwr = 30
	liquid_fire_power = 3

/datum/reagent/consumable/ethanol/poison_wine
	name = "Fungal Wine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	taste_description = "purified alcoholic death"
	color = "#000000d0"
	boozepwr = 1
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/poison_wine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	drinker.adjust_hallucinations(1.5 SECONDS)
	drinker.adjust_drugginess(5 SECONDS)

	drinker.adjustToxLoss(3 * seconds_per_tick)

/datum/reagent/consumable/ethanol/candy_wine
	name = "Candy Liquor"
	description = "Made from assorted sweets, candies and even flowers."
	taste_description = "sweet and smooth alcohol"
	color = "#E33232d0" // rgb: 227, 50, 50
	boozepwr = 15
	liquid_fire_power = 0

/datum/reagent/consumable/ethanol/dry_vermouth
	name = "Dry Vermouth"
	description = "What's the difference between this and sweet Vermouth?"
	color = "#9E2F2F" // rgb: 158, 47, 47
	boozepwr = 60
	taste_description = "very dry alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	liquid_fire_power = 5

/datum/reagent/consumable/ethanol/sweet_vermouth
	name = "Sweet Vermouth"
	description = "What's the difference between this and dry Vermouth?"
	color = "#B9FFB3" // rgb: 189, 255, 179
	boozepwr = 60
	taste_description = "somewhat dry alcohol"
	liquid_fire_power = 5

/datum/reagent/consumable/ethanol/dry_voltaic_yellow
	name = "Dry Voltaic Yellow"
	description = "Electrically charged wine reinforced with herbs, spices, and brandy. Recharges etherials, but also nontoxic."
	boozepwr = 60
	color = "#ffce6c"
	taste_description = "very dry static"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	liquid_fire_power = 9

/datum/reagent/consumable/ethanol/dry_voltaic_yellow/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/internal/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 3)
