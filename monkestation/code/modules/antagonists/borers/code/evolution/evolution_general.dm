/datum/borer_evolution/upgrade_injection
	name = "Upgrade Injection"
	desc = "Upgrade your possible injection amount to 10 units."
	gain_text = "Their growth is astounding, their organs and glands can expand several times their size in mere days."
	unlocked_evolutions = list(/datum/borer_evolution/upgrade_injection/t2)
	tier = 1

/datum/borer_evolution/upgrade_injection/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.injection_rates_unlocked += cortical_owner.injection_rates[length(cortical_owner.injection_rates_unlocked) + 1]

/datum/borer_evolution/upgrade_injection/t2
	name = "Upgrade Injection II"
	desc = "Upgrade your possible injection amount to 25 units."
	unlocked_evolutions = list(/datum/borer_evolution/upgrade_injection/t3)
	tier = 2

/datum/borer_evolution/upgrade_injection/t3
	name = "Upgrade Injection III"
	desc = "Upgrade your possible injection amount to 50 units."
	unlocked_evolutions = list()
	tier = 3

/datum/borer_evolution/sugar_immunity
	name = "Sugar Immunity"
	desc = "Become immune to the ill effects of sugar in you or a host."
	gain_text = "Of the biggest ones, a few have managed to resist the effects of sugar. Truly concerning if we wish to keep them contained."
	evo_cost = 5
	tier = 6
	unlocked_evolutions = list(/datum/borer_evolution/acidic_boring)


/datum/borer_evolution/sugar_immunity/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.upgrade_flags |= BORER_SUGAR_IMMUNE

/datum/borer_evolution/acidic_boring
	name = "Acidic Boring"
	desc = "Gain the ability to bore through thick clothing, through the use of acid."
	gain_text = "Over time, some became painful to the touch, later identififed to be acid on their skin."
	evo_cost = 4
	tier = 7

/datum/borer_evolution/acidic_boring/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.upgrade_flags |= BORER_ACID_SKIN

/datum/borer_evolution/advanced_borer
	name = "Advanced Boring"
	desc = "Gain the ability to take more complex lifeforms as hosts. Namely, changlings and IPCs."
	gain_text = "Now, we used robots to take care of the worms when they're alive, but one day... they all went haywire. Security took them down, closer inspection showed that the worms managed their way into the processing units."
	evo_cost = 6
	tier = 6

/datum/borer_evolution/advanced_borer/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.organic_restricted = FALSE
	cortical_owner.changeling_restricted = FALSE

/datum/borer_evolution/synthetic_chems_positive
	name = "Synthetic Chemicals (+)"
	desc = "Gain access to a list of helpful, synthetic-compatible chemicals."
	gain_text = "Once we had established that robots weren't safe either, we began to experiment with them. Interestingly enough, some of them never needed to be oiled again."
	tier = 6
	evo_cost = 6
	var/static/list/added_chemicals = list(
		/datum/reagent/medicine/system_cleaner,
		/datum/reagent/medicine/liquid_solder,
		/datum/reagent/fuel/oil,
		/datum/reagent/fuel,
		/datum/reagent/medicine/nanite_slurry,
		/datum/reagent/medicine/painkiller/robopiates,
		/datum/reagent/drug/methamphetamine/robo,
	)

/datum/borer_evolution/synthetic_chems_positive/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.potential_chemicals |= added_chemicals

/datum/borer_evolution/synthetic_chems_negative
	name = "Synthetic Chemicals (-)"
	desc = "Gain access to a list of synthetic-damaging chemicals."
	gain_text = "Good thing is, some of the worms were hostile to the robots, too. Corroded from the inside, some of them were basically husks."
	tier = 6
	evo_cost = 6
	var/static/list/added_chemicals = list(
		/datum/reagent/toxin/acid/fluacid, // More like anti everything but :shrug:
		/datum/reagent/thermite,
		/datum/reagent/pyrosium,
		/datum/reagent/oxygen,
		/datum/reagent/medicine/painkiller/robopiates
	)

/datum/borer_evolution/synthetic_chems_negative/on_evolve(mob/living/basic/cortical_borer/cortical_owner)
	. = ..()
	cortical_owner.potential_chemicals |= added_chemicals
