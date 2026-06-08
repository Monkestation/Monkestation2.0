/datum/round_event_control/wizard/invincible //Boolet Proof
	name = "Invincibility"
	weight = 3
	typepath = /datum/round_event/wizard/invincible
	max_occurrences = 5
	earliest_start = 0 MINUTES
	description = "Everyone is given 40U of adminordrazine(100 ticks, theoretically)."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 100

/datum/round_event/wizard/invincible/start()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		H.reagents.add_reagent(/datum/reagent/medicine/adminordrazine, 40)
		to_chat(H, span_notice("You feel invincible, nothing can hurt you!"))
