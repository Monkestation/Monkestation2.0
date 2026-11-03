/datum/artifact_effect/philostone
	examine_discovered = "Turns nearby iron structures into gold!"
	weight = ARTIFACT_VERYRARE
	research_value = TECHWEB_TIER_7_POINTS //GOOOOOOOOOLD
	discovered_credits = CARGO_CRATE_VALUE*50//It literally prints money
	type_name = "Midas Stone Effect"
	var/datum/dimension_theme/transmute_to


/datum/artifact_effect/philostone/setup()
	transmute_to = new /datum/dimension_theme/gold

/datum/artifact_effect/philostone/effect_process()
	var/owner_turf = get_turf(our_artifact.holder)
	if(owner_turf && transmute_to)
		for(var/turf/place in range(1,owner_turf))
			transmute_to.apply_theme(place)
	if(prob(40))
		our_artifact?.artifact_deactivate()

