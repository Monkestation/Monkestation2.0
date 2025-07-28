/datum/action/cooldown/bloodling/build
	name = "Mold Flesh"
	desc = "Use your biomass to forge creatures or structures. Costs 30 biomass. Creatures are soulless, and need to be given life."
	button_icon_state = "build"
	biomass_cost = 30
	/// A list of all structures we can make.
	var/static/list/structures = list(
		"rat warren" = /obj/structure/bloodling/rat_warren,
		"harvester" = /mob/living/basic/bloodling/minion/harvester,
		"wall of flesh" = /mob/living/basic/bloodling/minion/wall,
	)

// Snowflake to check for what we build
/datum/action/cooldown/bloodling/build/proc/check_for_duplicate()
	for(var/blocker_name in structures)
		blocker_name = structures[blocker_name]
		if(locate(blocker_name) in get_turf(src))
			to_chat(owner, span_warning("There is already shaped flesh here!"))
			return FALSE

	return TRUE

/datum/action/cooldown/bloodling/build/Activate(atom/target)
	. = ..()

	var/choice = tgui_input_list(owner, "Select a shape to mold", "Flesh Construction", structures)
	if(isnull(choice) || QDELETED(src) || QDELETED(owner) || !check_for_duplicate() || !IsAvailable(feedback = TRUE))
		return FALSE

	var/atom/choice_path = structures[choice]
	if(!ispath(choice_path))
		return FALSE

	owner.visible_message(
		span_notice("[owner] vomits up a torrent of flesh and begins to shape it."),
		span_notice("You mold a [choice] out of your flesh."),
	)

	new choice_path(get_turf(owner))
	playsound(get_turf(owner), 'sound/items/eatfood.ogg', 20)
	return TRUE
