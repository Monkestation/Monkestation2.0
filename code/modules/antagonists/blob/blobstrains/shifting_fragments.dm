//does brute damage, shifts away when damaged
/datum/blobstrain/reagent/shifting_fragments
	name = "Shifting Fragments"
	description = "will do medium brute damage."
	effectdesc = "will also cause blob parts to shift away when attacked."
	analyzerdescdamage = "Does medium brute damage."
	analyzerdesceffect = "When attacked, may shift away from the attacker."
	color = "#C8963C"
	complementary_color = "#3C6EC8"
	reagent = /datum/reagent/blob/shifting_fragments

/datum/blobstrain/reagent/shifting_fragments/expand_reaction(obj/structure/blob/expanding, obj/structure/blob/new_blob, turf/target_turf, mob/eye/blob/owner)
	if(istype(expanding, /obj/structure/blob/normal) || (istype(expanding, /obj/structure/blob/shield)))
		new_blob.forceMove(get_turf(expanding))
		expanding.forceMove(target_turf)

/datum/blobstrain/reagent/shifting_fragments/damage_reaction(obj/structure/blob/damaged, damage, damage_type, damage_flag)
	if((damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) && damage > 0 && damaged.get_integrity() - damage > 0 && prob(60 - damage))
		var/list/blobstopick = list()
		for(var/obj/structure/blob/range_blob in orange(1, damaged))
			if((istype(range_blob, /obj/structure/blob/normal) || (istype(range_blob, /obj/structure/blob/shield))) && range_blob.blob_team.blobstrain.type == src.type)
				blobstopick += range_blob //as long as the blob picked is valid; ie, a normal or shield blob that has the same chemical as we do, we can swap with it

		if(length(blobstopick))
			var/obj/structure/blob/targeted = pick(blobstopick) //randomize the blob chosen, because otherwise it'd tend to the lower left
			var/turf/target = get_turf(targeted)
			targeted.forceMove(get_turf(damaged))
			damaged.forceMove(target) //swap the blobs
	return ..()

/datum/reagent/blob/shifting_fragments
	name = "Shifting Fragments"
	color = "#C8963C"

/datum/reagent/blob/shifting_fragments/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.7*reac_volume, BRUTE, wound_bonus = CANT_WOUND)
