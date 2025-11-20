/mob/living/basic/chicken
	icon_suffix = "white"
	mutation_list = list(/datum/ranching_mutation/chicken/silkie_black, /datum/ranching_mutation/chicken/brown, /datum/ranching_mutation/chicken/glass, /datum/ranching_mutation/chicken/onagadori, /datum/ranching_mutation/chicken/clown, /datum/ranching_mutation/chicken/ixworth, /datum/ranching_mutation/chicken/silkie, /datum/ranching_mutation/chicken/void, /datum/ranching_mutation/chicken/silkie_white)
	instability = 25 // 25% more likely to mutate than other chickens

/datum/status_effect/ranching
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	show_duration = TRUE
