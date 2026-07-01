/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai_core
	name = "\improper AI core display"
	desc = "A big screen which the AI can use to present a self-chosen image of itself. NOTE: For display purposes only. Is not capable of hosting an AI."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-empty"
	circuit = /obj/item/circuitboard/machine/ai_core_display
	density = TRUE

	var/mode = SD_BLANK
	var/emotion = "Neutral"

/obj/machinery/status_display/ai_core/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.ai_core_displays.Add(src)
	set_ai(resolve_ai_icon(emotion))

/obj/machinery/status_display/ai_core/Destroy()
	GLOB.ai_core_displays.Remove(src)
	return ..()

/obj/machinery/status_display/ai_core/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return
	. += "<b>Networked AI Laws:</b>"
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		var/active_status = "(Core: [FOLLOW_LINK(user, AI.loc)], Eye: [FOLLOW_LINK(user, AI.eyeobj)])"
		if(!AI.mind && AI.deployed_shell)
			active_status = "(Controlling [FOLLOW_LINK(user, AI.deployed_shell)][AI.deployed_shell.name])"
		else if(!AI.mind)
			active_status = "([span_warning("OFFLINE")])"

		. += "<b>[AI] [active_status] has the following laws: </b>"
		for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
			. += law

/obj/machinery/status_display/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!default_unfasten_wrench(user, tool, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/machinery/status_display/ai_core/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.pick_icon()

/obj/machinery/status_display/ai_core/proc/set_ai(new_icon_state, new_icon)
	icon = initial(icon)
	if(new_icon)
		icon = new_icon
	if(new_icon_state)
		icon_state = new_icon_state

/obj/machinery/status_display/ai_core/process()
	if(machine_stat & NOPOWER)
		icon = initial(icon)
		icon_state = initial(icon_state)
		return PROCESS_KILL
