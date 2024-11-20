/datum/scripture/abscond
	name = "Abscond"
	desc = "After a long delay recalls you and anyone you are dragging to reebe. Takes longer from a non marked area."
	tip = "If using this with a prisoner dont forget to cuff them first."
	button_icon_state = "Abscond"
	invocation_time = 45 SECONDS
	invocation_text = list("Return to our home, the city of cogs.")
	category = SPELLTYPE_SERVITUDE
	power_cost = 5

/datum/scripture/abscond/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return

	if(!(get_area(invoker) in SSthe_ark.marked_areas))
		to_chat(user, span_warning("We can only abscond from marked areas!"))
		return FALSE

/datum/scripture/abscond/invoke_success()
	try_servant_warp(invoker, get_turf(pick(GLOB.abscond_markers)))
