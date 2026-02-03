//does tons of oxygen damage and a little stamina, immune to tesla bolts, weak to EMP
/datum/blobstrain/reagent/energized_jelly
	name = "Energized Jelly"
	description = "will cause high stamina and medium oxygen damage, and cause targets to be unable to breathe."
	effectdesc = "will also conduct electricity, but takes damage from EMPs."
	analyzerdescdamage = "Does high stamina damage, medium oxygen damage, and prevents targets from breathing."
	analyzerdesceffect = "Is immune to electricity and will easily conduct it, but is weak to EMPs."
	color = "#EFD65A"
	complementary_color = "#00E5B1"
	reagent = /datum/reagent/blob/energized_jelly

/datum/blobstrain/reagent/energized_jelly/damage_reaction(obj/structure/blob/damaged, damage, damage_type, damage_flag)
	if((damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) && damaged.get_integrity() - damage <= 0 && prob(10))
		do_sparks(rand(2, 4), FALSE, damaged)
	return ..()

/datum/blobstrain/reagent/energized_jelly/tesla_reaction(obj/structure/blob/zapped, power)
	return FALSE

/datum/blobstrain/reagent/energized_jelly/emp_reaction(obj/structure/blob/emped, severity)
	var/damage = rand(20, 30) - (severity * 10)
	emped.take_damage(damage, BURN, ENERGY)

/datum/reagent/blob/energized_jelly
	name = "Energized Blob Jelly"
	taste_description = "gelatin"
	color = "#EFD65A"

/datum/reagent/blob/energized_jelly/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.losebreath += round(0.3*reac_volume)
	exposed_mob.stamina.adjust(trunc(-reac_volume * 1.5))
	if(exposed_mob)
		exposed_mob.apply_damage(round(0.6*reac_volume), OXY)
