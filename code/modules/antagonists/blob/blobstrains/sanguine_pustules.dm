///how much blood is needed to make a spore
#define BLOOD_PER_SPORE 100

// Drains blood on hit and causes bleeding wounds, can abosorb blood on the ground to create spores
/datum/blobstrain/reagent/sanguine_pustules
	name = "Sanguine Pustules"
	description = "casues bleeding on targets and absorbs blood to create spores."
	analyzerdescdamage = "Causes servere bleeding and absorbs blood to create spores."
	color = "#e60a0a"
	complementary_color = "#a50d4c"
	blobbernaut_message = "drains"
	message = "The blob drains you"
	reagent = /datum/reagent/blob/sanguine_pustules
	///How much blood we have stored
	var/blood = 0

/datum/blobstrain/reagent/sanguine_pustules/expand_reaction(obj/structure/blob/expanding, obj/structure/blob/new_blob, turf/target_turf, mob/eye/blob/controller)
	var/blood_to_gain = 0
	for(var/obj/effect/decal/cleanable/blood/blood_decal in target_turf)
		if(blood_decal.decal_reagent == /datum/reagent/blood)
			blood_to_gain += max(blood_decal.bloodiness, 1)
			qdel(blood_decal)

	if(blood_to_gain)
		adjust_blood(blood_to_gain, target_turf)

///Set our blood value and spawn spores if able
/datum/blobstrain/reagent/sanguine_pustules/proc/adjust_blood(adjusted_by, turf/adjusted_from)
	blood += adjusted_by
	if(!adjusted_from)
		return

	while(blood > BLOOD_PER_SPORE)
		blood -= BLOOD_PER_SPORE
		blob_team.create_spore(adjusted_from)

/datum/reagent/blob/sanguine_pustules
	name = "Sanguine Pustules"
	taste_description = "iron deficiency"
	color = "#e60a0a"
	metabolized_traits = list(TRAIT_BLOODY_MESS) //might need to make this be less

/datum/reagent/blob/sanguine_pustules/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	//might want to make this use a custom very low level wound for the sake of only being meaningful if actively metabolising this
	if(!iscarbon(exposed_mob) || !exposed_mob.blood_volume || HAS_TRAIT(exposed_mob, TRAIT_NOBLOOD))
		exposed_mob.apply_damage(trunc(reac_volume/3), BRUTE)
	else
		var/mob/living/carbon/carbon_exposed = exposed_mob
		if(prob(reac_volume))
			for(var/obj/item/bodypart/bodypart in shuffle(carbon_exposed.bodyparts))
				if(length(bodypart.wounds))
					continue

				var/datum/wound/slash/flesh/moderate/applied_wound = new
				applied_wound.apply_wound(bodypart)
				return

		var/datum/blobstrain/reagent/sanguine_pustules/overmind_strain = overmind?.antag_team.blobstrain
		if(istype(overmind_strain))
			var/old_volume = carbon_exposed.blood_volume
			carbon_exposed.blood_volume = max(carbon_exposed.blood_volume - trunc(reac_volume * 0.8), 0)
			overmind_strain.adjust_blood(trunc(old_volume - carbon_exposed.blood_volume), get_turf(carbon_exposed))

#undef BLOOD_PER_SPORE
