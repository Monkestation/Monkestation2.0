/datum/ai_project/ai_fax
	name = "AI Fax Machine"
	description = "Bodge together a working fax machine by using the mainframe's diagnostic printout machine."
	category = AI_PROJECT_MISC
	research_cost = 1
	var/datum/action/innate/ai/fax_machine_ability

/datum/ai_project/ai_fax/run_project(force_run = FALSE)
	. = ..(force_run)
	fax_machine_ability = add_ability(/datum/action/innate/ai/fax_machine)

/datum/ai_project/ai_fax/stop()
	remove_ability(fax_machine_ability)
	return ..()

/datum/action/innate/ai/fax_machine
	name = "Fax Machine"
	desc = "Access our jury-rigged fax-machine."
	button_icon_state = "emergency_lights"
	max_uses = 999
	auto_use_uses = FALSE
	var/obj/machinery/fax/ai/fax_machine

/datum/action/innate/ai/fax_machine/Grant(mob/living/player)
	. = ..()
	fax_machine = new /obj/machinery/fax/ai(src, owner_AI.name)


/datum/action/innate/ai/fax_machine/Destroy()
	. = ..()
	qdel(fax_machine)


/datum/action/innate/ai/fax_machine/Activate()
	. = ..()
	fax_machine.interact(owner_AI)
