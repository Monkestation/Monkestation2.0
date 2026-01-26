#define POWER_PER_USE 3
#define HEAL_PER_USE 2

/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism
	name = "prosperity prism"
	desc = "A prism that seems to somehow always have its gaze locked to you."
	clockwork_desc = "A prism that will heal nearby servants of various damage types, along with purging poisons."
	icon_state = "prolonging_prism"
	base_icon_state = "prolonging_prism"
	anchored = TRUE
	break_message = span_warning("The prism falls apart, smoke leaking out into the air.")
	max_integrity = 150
	passive_consumption = 5
	///typecache of chem types to purge
	var/static/list/chems_to_purge

/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism/Initialize(mapload)
	. = ..()
	if(!chems_to_purge)
		chems_to_purge = typecacheof(list(/datum/reagent/toxin, /datum/reagent/water/holywater))

/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism/process(seconds_per_tick)
	. = ..()
	if(!.)
		return

	for(var/mob/living/possible_cultist in range(3, src))
		if(isnull(possible_cultist) || !IS_CLOCK(possible_cultist) || possible_cultist.health >= possible_cultist.maxHealth || !use_energy(-POWER_PER_USE))
			continue

		var/healed_amount = HEAL_PER_USE * seconds_per_tick
		possible_cultist.stamina.adjust(4 * seconds_per_tick, TRUE)
		possible_cultist.adjustOxyLoss(-healed_amount)
		possible_cultist.adjustCloneLoss(-(HEAL_PER_USE / 2) * seconds_per_tick)
		possible_cultist.heal_overall_damage(healed_amount, healed_amount, updating_health = TRUE)
		new /obj/effect/temp_visual/heal(get_turf(possible_cultist), "#1E8CE1")
		if(!possible_cultist.reagents)
			continue

		for(var/datum/reagent/negative_chem in possible_cultist.reagents?.reagent_list)
			if(is_type_in_typecache(negative_chem, chems_to_purge))
				possible_cultist.reagents?.remove_reagent(negative_chem.type, 2.5 * seconds_per_tick)

#undef POWER_PER_USE
#undef HEAL_PER_USE
