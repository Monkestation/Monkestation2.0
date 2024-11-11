/datum/scripture/abscond
	name = "Abscond"
	desc = "After a long delay recalls you and anyone you are dragging to reebe. Takes longer from a non marked area."
	tip = "If using this with a prisoner dont forget to cuff them first."
	button_icon_state = "Abscond"
	invocation_time = 1 MINUTE
	invocation_text = list("Return to our home, the city of cogs.")
	category = SPELLTYPE_SERVITUDE
	power_cost = 5

/datum/scripture/abscond/get_true_invocation_time()
	. = ..()
	if(!(get_area(invoker) in GLOB.clock_warp_areas))
		. *= 3

/datum/scripture/abscond/invoke_success()
	try_servant_warp(invoker, get_turf(pick(GLOB.abscond_markers)))
