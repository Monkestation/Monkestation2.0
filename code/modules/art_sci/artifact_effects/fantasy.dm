/datum/artifact_effect/fantasy
	examine_discovered = "Makes objects better?"
	weight = ARTIFACT_VERYRARE
	research_value = TECHWEB_TIER_5_POINTS //wat
	type_name = "Fantasy Forge Effect"

/datum/artifact_effect/fantasy/effect_activate(silent)
	var/owner_turf = get_turf(our_artifact.holder)
	if(owner_turf)
		for(var/obj/thing in range(1,owner_turf))
			if(thing.GetComponent(/datum/component/fantasy) || !isitem(thing) || HAS_TRAIT(thing,TRAIT_INNATELY_FANTASTICAL_ITEM))
				continue
			thing.AddComponent(/datum/component/fantasy,null,null,FALSE,TRUE)
	our_artifact?.artifact_deactivate()

