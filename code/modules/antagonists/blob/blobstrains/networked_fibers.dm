//does massive brute and burn damage, but can only expand manually
/datum/blobstrain/reagent/networked_fibers
	name = "Networked Fibers"
	description = "will do a high mix of brute and burn damage, and will generate resources quicker, but can only expand manually using the core or nodes."
	shortdesc = "will do a high mix of brute and burn damage."
	effectdesc = "will move your core or node when manually expanding near it."
	analyzerdescdamage = "Does a high mix of brute and burn damage."
	analyzerdesceffect = "Is mobile and generates resources rapidly."
	color = "#4F4441"
	complementary_color = "#414C4F"
	reagent = /datum/reagent/blob/networked_fibers
	core_regen_bonus = 3

/datum/blobstrain/reagent/networked_fibers/expand_reaction(obj/structure/blob/expanding, obj/structure/blob/new_blob, turf/target_turf, mob/eye/blob/controller)
	if(!controller || isspaceturf(target_turf))
		return

	if(!istype(expanding, /obj/structure/blob/special/node))
		for(var/obj/structure/blob/special/node/possible_expander in range(1, new_blob))
			if(possible_expander.blob_team == blob_team)
				expanding = possible_expander
				break

	if(expanding)
		new_blob.forceMove(get_turf(expanding))
		expanding.forceMove(target_turf)
		expanding.setDir(get_dir(new_blob, expanding))
	else
		controller.add_points(4)
		qdel(new_blob)

/datum/blobstrain/reagent/networked_fibers/core_process()
	return ..() + length(blob_team.all_blobs_by_type[/obj/structure/blob/special/node])

//does massive brute and burn damage, but can only expand manually
/datum/reagent/blob/networked_fibers
	name = "Networked Fibers"
	taste_description = "efficiency"
	color = "#4F4441"

/datum/reagent/blob/networked_fibers/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, BRUTE, wound_bonus = CANT_WOUND)
	if(!QDELETED(exposed_mob))
		exposed_mob.apply_damage(0.6*reac_volume, BURN, wound_bonus = CANT_WOUND)
