/datum/chemical_reaction/tricordizine
	results = list(/datum/reagent/medicine/tricordizine = 3)
	required_reagents = list(/datum/reagent/medicine/bicaridine = 1, /datum/reagent/medicine/kelotane = 1, /datum/reagent/toxin = 1)
	mix_message = "The mixture turns into a fluffy blue liquid."

/datum/chemical_reaction/tricorital
	results = list(/datum/reagent/medicine/tricorital = 3)
	required_reagents = list(/datum/reagent/medicine/bicarbital = 1, /datum/reagent/medicine/keluri = 1, /datum/reagent/toxin = 1)
	mix_message = "The mixture gives off a lovely odor."


/datum/chemical_reaction/omnizidrite
	results = list(/datum/reagent/medicine/omnizidrite = 1)
	required_reagents = list(/datum/reagent/medicine/omnizine = 1, /datum/reagent/medicine/omnidrite = 1)
	mix_message = "The mixture turns into a fluffy blue liquid."


/datum/chemical_reaction/adminordrazine
	results = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 1)
	required_reagents = list(/datum/reagent/medicine/omnizidrite = 10, /datum/reagent/medicine/tricordizine = 10, /datum/reagent/hellwater = 10, /datum/reagent/lube/superlube = 10, /datum/reagent/medicine/omnizine/godblood = 10)
	mix_message = "????"



//KL-6 Explosion
/datum/chemical_reaction/reagent_explosion/kl6_explosion
	required_reagents = list(/datum/reagent/kl6 = 1)
	required_temp = 350
	strengthdiv = 4
	modifier = 5

/datum/chemical_reaction/reagent_explosion/kl6_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/fire_range = round(created_volume/30)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(fire_range,T))
		new /obj/effect/hotspot(turf)
	holder.chem_temp = 500
	..()
