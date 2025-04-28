//Vaechem
/datum/reagent/medicine/ventrite
	name = "Ventrite"
	description = "A once forgotten medicine that restores the stomach back to working condition, known to interfere with respiration as long as it is in the system."
	reagent_state = SOLID
	color = "#DCE298"
	metabolization_rate = 1 * REAGENTS_METABOLISM

/datum/reagent/medicine/ventrite/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_STOMACH, -3)
	M.adjustOxyLoss(rand(1,3))
	M.adjustCloneLoss(0.5)
	..()
	. = 1

/datum/reagent/medicine/spirozrite
	name = "Spirozrite"
	description = "A simple chemical that reverses the damage to injured lungs. Deals a small amount of clone damage while in the system."
	reagent_state = SOLID
	color = "#A7D7C4"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/medicine/spirozrite/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, -1.5)
	M.adjustCloneLoss(0.5)
	..()
	. = 1

/datum/reagent/medicine/citisrite
	name = "Citisrite"
	description = "An emergency chemical used to treat heart damage until surgery is avalidable, causes minor tissue damage."
	reagent_state = SOLID
	color = "#DCE298"
	metabolization_rate = 0.6 * REAGENTS_METABOLISM

/datum/reagent/medicine/citisrite/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_HEART, -1.5)
	M.adjustBruteLoss(1)
	M.adjustCloneLoss(0.5)
	..()
	. = 1

/datum/reagent/medicine/purgrite
	name = "Purgrite"
	description = "Restores the liver back to working condition while causing vomiting."
	reagent_state = SOLID
	color = "#5C7128"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM

/datum/reagent/medicine/purgrite/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, -1.5)
	M.adjust_disgust(3)
	M.adjustCloneLoss(0.5)
	..()
	. = 1
