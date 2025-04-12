/datum/action/cooldown/bloodling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We release a sound that disrupts nearby electronics. Costs 20 biomass."
	button_icon_state = "dissonant_shriek"
	biomass_cost = 30

/datum/action/cooldown/bloodling/dissonant_shriek/Activate(atom/target)
	. = ..()
	if(owner.movement_type & VENTCRAWLING)
		owner.balloon_alert(owner, "can't shriek in pipes!")
		return FALSE
	empulse(get_turf(owner), 2, 5, 1)
	for(var/obj/machinery/light/light_break in range(5, usr))
		light_break.on = TRUE
		light_break.break_light_tube()
		stoplag()
	playsound(get_turf(owner), 'sound/effects/screech.ogg')

	return TRUE
