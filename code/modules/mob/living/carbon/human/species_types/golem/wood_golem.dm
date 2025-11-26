//Since this will usually be created from a collaboration between podpeople and free golems, wood golems are a mix between the two races
/datum/species/golem/wood
	name = "Wood Golem"
	id = SPECIES_GOLEM_WOOD
	fixed_mut_color = "#9E704B"
	meat = /obj/item/stack/sheet/mineral/wood
	//Can burn and take damage from heat
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_GENELESS,
		TRAIT_NOBREATH,
		TRAIT_NODISMEMBER,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	armor = 30
	burnmod = 1.25
	heatmod = 1.5
	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Woody", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)
	examine_limb_id = SPECIES_GOLEM

/datum/species/golem/wood/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(FALSE)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		H.adjust_nutrition(5 * light_amount * seconds_per_tick)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2) //if there's enough light, heal
			H.heal_overall_damage(brute = 0.5 * seconds_per_tick, burn = 0.5 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC)
			H.adjustToxLoss(-0.5 * seconds_per_tick)
			H.adjustOxyLoss(-0.5 * seconds_per_tick)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(brute = 2, required_bodytype = BODYTYPE_ORGANIC)

/datum/species/golem/wood/handle_chemical(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return TRUE
	return ..()
