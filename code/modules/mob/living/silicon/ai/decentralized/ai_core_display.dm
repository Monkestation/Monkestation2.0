/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai_core
	name = "\improper AI core display"
	desc = "A big screen which the AI can use to present a self-chosen image of itself. NOTE: For display purposes only. Is not capable of hosting an AI."
	icon = 'icons/mob/silicon/ai.dmi'
	icon_state = "ai-empty"
	circuit = /obj/item/circuitboard/machine/ai_core_display
	density = TRUE

	///If this is set, this will be the emotion the display uses, and it will not be able to be edited by an AI. Used for map VV edits.
	var/custom_emotion
	///The AI that controls the core display, it changes emotions as they do.
	var/mob/living/silicon/ai/connected_ai

/obj/machinery/status_display/ai_core/Initialize(mapload)
	. = ..()
	if(custom_emotion)
		custom_emotion = resolve_ai_icon(custom_emotion)
		set_ai(custom_emotion)
		return

	if(!length(GLOB.ai_list))
		RegisterSignal(SSdcs, COMSIG_GLOB_AI_CREATED, PROC_REF(on_ai_creation))
	else if(length(GLOB.ai_list) == 1)
		var/mob/living/silicon/ai/living_ai = locate() in GLOB.ai_list
		assign_ai(living_ai)

/obj/machinery/status_display/ai_core/Destroy()
	connected_ai = null
	custom_emotion = null
	return ..()

/obj/machinery/status_display/ai_core/examine(mob/user)
	. = ..()
	if(!isobserver(user) || isnull(connected_ai))
		return .
	connected_ai.examine(user)

/obj/machinery/status_display/ai_core/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(!default_unfasten_wrench(user, tool, 4 SECONDS))
		return ITEM_INTERACT_BLOCKING
	return ITEM_INTERACT_SUCCESS

/obj/machinery/status_display/ai_core/attack_ai(mob/living/silicon/ai/user)
	if(isnull(connected_ai))
		assign_ai(user)
	if(user == connected_ai)
		user.pick_icon()

/obj/machinery/status_display/ai_core/proc/set_ai(new_icon_state, new_icon)
	icon = initial(icon)
	if(new_icon)
		icon = new_icon
	if(new_icon_state)
		icon_state = new_icon_state

/obj/machinery/status_display/ai_core/on_set_machine_stat(old_value)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/status_display/ai_core/update_icon_state()
	. = ..()
	if(machine_stat & NOPOWER)
		icon = initial(icon)
		icon_state = initial(icon_state)
		return .
	set_ai(custom_emotion)
	return .

/obj/machinery/status_display/ai_core/proc/assign_ai(mob/living/silicon/ai/new_ai)
	if(connected_ai == new_ai)
		return
	if(connected_ai)
		UnregisterSignal(connected_ai, list(COMSIG_QDELETING, COMSIG_AI_ICON_CHANGE))
	connected_ai = new_ai
	RegisterSignal(connected_ai, COMSIG_QDELETING, PROC_REF(on_ai_deleting))
	RegisterSignal(connected_ai, COMSIG_AI_ICON_CHANGE, PROC_REF(on_ai_screen_change))
	INVOKE_ASYNC(connected_ai, TYPE_PROC_REF(/mob/living/silicon/ai, set_core_display_icon), null, connected_ai?.client)

///Called when the first AI of the round is created, as we get automatically assigned to it.
/obj/machinery/status_display/ai_core/proc/on_ai_creation(atom/source, mob/living/silicon/ai/new_ai)
	SIGNAL_HANDLER
	if(connected_ai)
		return
	//Not on our level, we don't care.
	var/datum/ai_os/os_using = GLOB.ai_os["[z]"]
	if(isnull(os_using) || !(new_ai in os_using.ai_list))
		return
	assign_ai(new_ai)

///Called when our assigned AI is being deleted.
/obj/machinery/status_display/ai_core/proc/on_ai_deleting(mob/living/silicon/ai/source, icon_used)
	SIGNAL_HANDLER
	connected_ai = null

///Called when an AI we're registered to changes their screen, we follow to what icon_used is.
/obj/machinery/status_display/ai_core/proc/on_ai_screen_change(mob/living/silicon/ai/source, icon_used)
	SIGNAL_HANDLER
	custom_emotion = icon_used
	set_ai(custom_emotion)
