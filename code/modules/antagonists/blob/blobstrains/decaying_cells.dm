//deals low toxin and injects a chem that deals very low clone over time, all special structures(besides overmind hosting nodes) will take damage over time
//structures always give their refund value on destruction
/datum/blobstrain/reagent/decaying_cells
	name = "Decaying Cells"
	description = "does low toxin damage as well as inject a chemical that does low cell damage over time."
	effectdesc = "structures(besides overmind hosting nodes) will slowly take damage over time, and always give their refund value when destroyed"
	analyzerdescdamage = "Does low toxin damage and injects a chemical that does low cell damage over time."
	color = "#9b4fff"
	complementary_color = "#622bf8"
	blobbernaut_message = "ruptures"
	message = "The blob makes your insides ache."
	reagent = /datum/reagent/blob/decaying_cells

/datum/blobstrain/reagent/decaying_cells/death_reaction(obj/structure/blob/dying, damage_flag, coefficient)
	if(istype(dying, /obj/structure/blob/special))
		blob_team.main_overmind?.add_points(dying.point_return)

/datum/blobstrain/reagent/decaying_cells/on_special_pulsed(obj/structure/blob/special/pulsed)
	if(astype(pulsed, /obj/structure/blob/special/node)?.hosting)
		return

	if(COOLDOWN_FINISHED(pulsed, heal_timestamp))
		pulsed.update_integrity(pulsed.get_integrity() - (pulsed.health_regen + 1))
		if(pulsed.integrity_failure && pulsed.get_integrity() <= pulsed.integrity_failure * pulsed.max_integrity)
			pulsed.atom_break()

		if(pulsed.get_integrity() <= 0)
			pulsed.atom_destruction()

/datum/reagent/blob/decaying_cells
	name = "Decaying Cells"
	taste_description = "radiation"
	color = "#9b4fff"
	metabolization_rate = 10

/datum/reagent/blob/decaying_cells/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message, touch_protection, mob/eye/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(trunc(reac_volume/5), TOX, forced = TRUE)
	exposed_mob.reagents?.add_reagent(/datum/reagent/blob/decaying_cells, reac_volume)

/datum/reagent/blob/decaying_cells/on_mob_life(mob/living/carbon/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	metabolizer.adjustCloneLoss(1 * REM * seconds_per_tick)
